{each, all, map} = require 'prelude-ls'

class @GameCore
  (game) !->
    @game = game

  preload: !->
    asset = (p) -> "game/assets/#p"
    @game.load
      ..spritesheet 'breaker'     (asset 'breaker.png'), 64 64
      ..image       'basic-tile'  asset 'better-basic-tile.png'
      ..image       'bg'          asset 'bg.png'
      ..spritesheet 'stars'       (asset 'stars.png'), 8 8
      ..spritesheet 'explosion'   (asset 'explosion.png'), 192 192
      ..spritesheet 'power-up'    (asset 'power-up.png'), 32 32
      ..tilemap     'map',        (asset 'map/basic-map.json'), null, Phaser.Tilemap.TILED_JSON
      ..image       'smoke'       asset 'smoke-cloud.png'
      ..audio       'punch-sound' asset 'sounds/punch.wav'
      ..audio       'dead-sound'  asset 'sounds/dead.ogg'
      ..audio       'box-hit'     asset 'sounds/box-hit.wav'
      ..audio       'box-break'   asset 'sounds/box-break.wav'
      ..audio       'box-shoot'   asset 'sounds/bullet-shoot.wav'
      ..audio       'chest-hit'   asset 'sounds/chest-hit.wav'
      ..audio       'chest-break' asset 'sounds/chest-break.wav'
      ..audio       'boom'        asset 'sounds/explosion.wav'
      ..audio       'beep'        asset 'sounds/beep.wav'
      ..audio       'charge-up'   asset 'sounds/charge-up.wav'
      ..audio       'charge-down' asset 'sounds/charge-down.wav'
      ..audio       'blast-off'   asset 'sounds/blast-off.wav'
      ..audio       'steel-hit'   asset 'sounds/steel-hit.wav'
      ..audio       'steel-break' asset 'sounds/steel-break.wav'

      ..audio 'bgm' asset 'bgm.ogg'

      ..spritesheet 'basic-block'  (asset 'blocks/basic.png') , 64 64
      ..spritesheet 'bullet-block' (asset 'blocks/bullet.png'), 64 64
      ..spritesheet 'tnt-block'    (asset 'blocks/tnt.png')   , 64 64
      ..spritesheet 'chest-block'  (asset 'blocks/chest.png') , 64 64

  create: !->
    let (add     = @game.add,
         physics = @game.physics,
         world   = @game.world
         camera  = @game.camera)

      @death-sound = add.audio 'dead-sound'
      @bgm = add.audio 'bgm'
        ..play '' 0 1 true

      @game.stage.background-color = '#1B03E38'
      add.emitter @game.world.center-x, 200, 200
        ..width = 800
        ..make-particles 'stars', [0, 1, 2, 3, 4, 5, 6]
        ..min-particle-speed.set 0 0
        ..max-particle-speed.set 0 400
        ..y = 0
        ..start false 3000 80
      add.image 0 0 'bg'
      @game.time.advancedTiming    = true

      physics.start-system Phaser.Physics.Arcade
      physics.arcade.TILE_BIAS    = 32
      physics.arcade.OVERLAP_BIAS = 16

      map = add.tilemap 'map'
        ..add-tileset-image 'basic', 'basic-tile'
        ..set-collision 1
      @layer = map.create-layer 'Tile Layer 1'
         ..resize-world!

      @arrow-keys = @game.input.keyboard.create-cursor-keys!
      @punch-key = @game.input.keyboard.add-key Phaser.Keyboard.Z
      @special-key = @game.input.keyboard.add-key Phaser.Keyboard.X

      @player = add.existing new Player(@game, this, 400, 500)
        ..keys        = @arrow-keys
        ..punch-key   = @punch-key
        ..special-key = @special-key
        ..initialize-smoke!

      @blocks    = add.group!
      @power-ups = add.group!
      @block-interval = 2
      @block-timer    = @block-interval
      @chest-block-in = 5

      @score-text = add.text 40 5 'Score: 0',
        font: '24px Arial'
        fill: '#000000'
        align: 'center'

      # DEBUG KEY BEHAVIOR
      @game.input.keyboard.add-key Phaser.Keyboard.D
        ..on-down.add ~>
          @add-power-up PowerUp, 400, 450

  score: ->
    @score-text.text = "Score: #{@player.score}"

  add-power-up: (type, x, y) ->
    @power-ups.add new type(@game, this, x, y)

  add-block: (type, x, y) ->
    @blocks.add new type(@game, this, x, y)

  # Called by Player
  punch: (fist) !->
    @game.physics.arcade
      ..collide fist, @blocks, null, (_, block) ->
        if block.punched
          block.punched(fist, if fist.player.spinning! then 2 else 1)
        false

  update: !->
    unless @player.dying
      const plr-blk-collide = (plr, blck) ->
          blck.on-collide(plr) if blck.on-collide
          plr.on-collide(blck)

      @game.physics.arcade
        ..collide @player, @layer
        ..collide @player, @blocks, plr-blk-collide, @player.block-collide-test,
        ..collide @player, @power-ups, null, (plr, pwr) ->
          pwr.picked-up(plr)
          false

    @game.physics.arcade
      ..collide @blocks, @layer, null, (b, l) ->
        if b.test-layer-collision then b.test-layer-collision(l) else b.is-block
      ..collide @blocks, @blocks, (b1, b2) ->
        b1.on-block-collide(b2) if b1.on-block-collide
        b2.on-block-collide(b1) if b2.on-block-collide

    const delta = @game.time.physics-elapsed
    @block-timer -= delta

    if @block-timer <= 0
      @chest-block-in -= 1
      chest = null
      if @chest-block-in <= 0
        chest = ChestBlock
        @chest-block-in = 20

      @generate-block(@game.rnd, chest)
      @block-timer = @block-interval
      unless @block-timer <= 0.7
        @block-interval *= 0.85
      else if @block-interval > 0.5
        @block-interval -= 0.001

  generate-block: (rnd, use-this-one) ->
    const possible-blocks = [BasicBlock, BulletBlock, TntBlock]
    const block-index     = rnd.integer-in-range 0 possible-blocks.length - 1
    const next-block-x    = rnd.integer-in-range 1, 800 / 64 - 2
    block = use-this-one or possible-blocks[block-index]
    if block.reroll-chance
      const chance = rnd.integer-in-range 0 100
      return @generate-block(rnd) if chance < block.reroll-chance

    @add-block block, next-block-x * 64, 0

  render: !->
    # @game.debug.text "chest health: #{@d-chest.health}" 200 200 if @d-chest
    # @player.debug-fist-positions!
    # @game.debug.body @player
