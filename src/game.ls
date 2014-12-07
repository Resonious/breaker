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
      ..tilemap     'map',        (asset 'map/basic-map.json'), null, Phaser.Tilemap.TILED_JSON
      ..image       'smoke'       asset 'smoke-cloud.png'
      ..audio       'punch-sound' asset 'sounds/punch.wav'
      ..audio       'dead-sound'  asset 'sounds/dead.ogg'
      ..audio       'box-hit'     asset 'sounds/box-hit.wav'
      ..audio       'box-break'   asset 'sounds/box-break.wav'
      ..audio       'box-shoot'   asset 'sounds/bullet-shoot.wav'

      ..audio 'bgm' asset 'bgm.ogg'

      ..spritesheet 'basic-block' (asset 'blocks/basic.png'), 64 64
      ..spritesheet 'bullet-block' (asset 'blocks/bullet.png'), 64 64

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
      physics.arcade.OVERLAP_BIAS = 32

      map = add.tilemap 'map'
        ..add-tileset-image 'basic', 'basic-tile'
        ..set-collision 1
      @layer = map.create-layer 'Tile Layer 1'
         ..resize-world!

      @arrow-keys = @game.input.keyboard.create-cursor-keys!
      @punch-key = @game.input.keyboard.add-key Phaser.Keyboard.Z

      @player = add.existing new Player(@game, this, 400, 500)
        ..keys      = @arrow-keys
        ..punch-key = @punch-key
        ..initialize-smoke!

      @blocks = add.group!
      @block-interval = 2
      @block-timer    = @block-interval

      @score-text = add.text 40 5 'Score: 0',
        font: '24px Arial'
        fill: '#000000'
        align: 'center'

      # DEBUG KEY BEHAVIOR
      # @game.input.keyboard.add-key Phaser.Keyboard.D
        # ..on-down.add ~> @add-block(BasicBlock, 300, 0)

  score: ->
    @score-text.text = "Score: #{@player.score}"

  add-block: (type, x, y) ->
    @blocks.add type(@game, this, x, y)

  punch: (fist) !->
    @game.physics.arcade
      ..collide fist, @blocks, null, (_, block) ->
        block.punched(fist) if block.punched
        false

  update: !->
    unless @player.dying
      @game.physics.arcade
        ..collide @player, @layer
        ..collide @player, @blocks, (plr, blck) ->
          blck.on-collide(plr) if blck.on-collide
          plr.on-collide(blck)

    @game.physics.arcade
      ..collide @blocks, @layer, null, (b, l) -> b.is-block
      ..collide @blocks, @blocks, (b1, b2) ->
        b1.on-block-collide(b2) if b1.on-block-collide
        b2.on-block-collide(b1) if b2.on-block-collide

    const delta = @game.time.physics-elapsed
    const rnd   = @game.rnd
    @block-timer -= delta

    if @block-timer <= 0
      const possible-blocks = [BasicBlock, BulletBlock]
      const block-index     = rnd.integer-in-range 0 possible-blocks.length - 1
      const next-block-x    = rnd.integer-in-range 1, 800 / 64 - 1

      @add-block possible-blocks[block-index], next-block-x * 64, 0
      @block-timer = @block-interval
      @block-interval *= 0.9 unless @block-interval <= 0.7

  render: !->
    # @player.debug-fist-positions!
    # @game.debug.body @player
