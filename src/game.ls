{each, all, map} = require 'prelude-ls'

class @GameCore
  @done-tutorial = false

  (game) !->
    @game = game

  preload: !->
    asset = (p) -> "game/assets/#p"
    @game.load
      ..spritesheet 'breaker'     (asset 'breaker.png'), 64 64
      ..image       'basic-tile'  asset 'better-basic-tile.png'
      ..image       'bg'          asset 'bg.png'
      ..image       'block-hole'  asset 'block-hole.png'
      ..spritesheet 'stars'       (asset 'stars.png'), 8 8
      ..spritesheet 'explosion'   (asset 'explosion.png'), 192 192
      ..spritesheet 'power-up'    (asset 'power-up.png'), 32 32
      ..tilemap     'map',        (asset 'map/basic-map.json'), null, Phaser.Tilemap.TILED_JSON
      ..image       'smoke'       asset 'smoke-cloud.png'
      ..audio       'punch-sound' asset 'sounds/punch.ogg'
      ..audio       'dead-sound'  asset 'sounds/dead.ogg'
      ..audio       'box-hit'     asset 'sounds/box-hit.ogg'
      ..audio       'box-break'   asset 'sounds/box-break.ogg'
      ..audio       'box-shoot'   asset 'sounds/bullet-shoot.ogg'
      ..audio       'chest-hit'   asset 'sounds/chest-hit.ogg'
      ..audio       'chest-break' asset 'sounds/chest-break.ogg'
      ..audio       'boom'        asset 'sounds/explosion.ogg'
      ..audio       'beep'        asset 'sounds/beep.ogg'
      ..audio       'charge-up'   asset 'sounds/charge-up.wav'
      ..audio       'charge-down' asset 'sounds/charge-down.wav'
      ..audio       'blast-off'   asset 'sounds/blast-off.wav'
      ..audio       'steel-hit'   asset 'sounds/steel-hit.wav'
      ..audio       'steel-break' asset 'sounds/steel-break.wav'
      ..audio       'bh-sound'    asset 'sounds/block-hole-sound.ogg'

      ..audio 'bgm'     asset 'bgm.ogg'
      ..audio 'tut-bgm' asset 'tutorial.ogg'

      ..spritesheet 'basic-block'  (asset 'blocks/basic.png') , 64 64
      ..spritesheet 'bullet-block' (asset 'blocks/bullet.png'), 64 64
      ..spritesheet 'tnt-block'    (asset 'blocks/tnt.png')   , 64 64
      ..spritesheet 'chest-block'  (asset 'blocks/chest.png') , 64 64
      ..spritesheet 'steel-block'  (asset 'blocks/steel.png') , 64 64
      ..spritesheet 'noob-z-block' (asset 'blocks/noob-z.png'), 64 64
      ..spritesheet 'noob-d-block' (asset 'blocks/noob-d.png'), 64 64

  create: !->
    let (add     = @game.add,
         physics = @game.physics,
         world   = @game.world
         camera  = @game.camera)

      @death-sound = add.audio 'dead-sound'
      @block-hole-sound = add.audio 'bh-sound'
      @bgm = add.audio 'bgm'
      @tut = add.audio 'tut-bgm'
      if @@done-tutorial
        @bgm.play '' 0 1 true
      else
        @tut.play '' 0 1 true

      @game.stage.background-color = '#1B03E38'
      @stars = add.emitter @game.world.center-x, 200, 200
        ..width = 800
        ..make-particles 'stars', [0, 1, 2, 3, 4, 5, 6]
        ..min-particle-speed.set 0 0
        ..max-particle-speed.set 0 400
        ..y = 0

      if @@done-tutorial
        @stars.start false 3000 80

      add.image 0 0 'bg'
      @game.time.advancedTiming = true

      physics.start-system Phaser.Physics.Arcade
      physics.arcade.TILE_BIAS    = 32
      physics.arcade.OVERLAP_BIAS = 16

      map = add.tilemap 'map'
        ..add-tileset-image 'basic', 'basic-tile'
        ..set-collision 1
      @layer = map.create-layer 'Tile Layer 1'
         ..resize-world!

      @arrow-keys  = @game.input.keyboard.create-cursor-keys!
      @punch-key   = @game.input.keyboard.add-key Phaser.Keyboard.Z
      @special-key = @game.input.keyboard.add-key Phaser.Keyboard.X

      @player = add.existing new Player(@game, this, 400, 500)
        ..keys        = @arrow-keys
        ..punch-key   = @punch-key
        ..special-key = @special-key
        ..initialize-smoke!

      @spawned-block-hole = false
      @block-hole-timer   = 0.0
      @block-hole-score   = 50
      @blocks    = add.group!
      @power-ups = add.group!
      @block-interval = 2
      @block-timer    = @block-interval
      @chest-block-in = 5

      try
        if @high-score and local-storage
          local-storage.ld-breaker-high-score = @high-score
        @high-score = local-storage.ld-breaker-high-score or 0 if local-storage
      catch

      @score-text = add.text 40 5 @score-str!,
        font: '24px Arial'
        fill: '#000000'
        align: 'left'

      @start-tutorial! unless @@done-tutorial
      # DEBUG KEY BEHAVIOR
      # @game.input.keyboard.add-key Phaser.Keyboard.D
      #   ..on-down.add ~>
      #     @add-power-up PowerUp, 400, 450
      #     @spawn-block-hole!

  score-str: ->
    const str = "Score: #{@player.score}"
    if @high-score
      "High Score: #{@high-score}\n#str"
    else
      str

  score: ->
    @high-score = @player.score if @player.score > @high-score
    @score-text.text = @score-str!
    if @player.score >= @block-hole-score and not @spawned-block-hole
      @spawn-block-hole!

  spawn-block-hole: ->
    @block-hole-sound.play '' 0 0.5 false
    @block-hole-timer = 10.0
    @block-hole = @game.add.sprite 400, 200, 'block-hole'
      ..anchor.set-to 0.5 0.5
      ..x = 100
      ..y = 400
      ..update = -> @rotation += 6 * @game.time.physics-elapsed
    @spawned-block-hole = true

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

    return unless @@done-tutorial
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

    if @block-hole-timer > 0
      @block-hole-timer -= delta
      @block-hole.x += 50 * delta
      @blocks.for-each (block) ~>
        const y-dist = @block-hole.y - block.y
        const x-dist = @block-hole.x - block.x
        const dist = Math.sqrt(x-dist^2 + y-dist^2)
        angle = Math.atan2 y-dist, x-dist
        angle -= 1

        block.body.velocity.y = dist * 2 * Math.sin(angle)
        block.body.velocity.x = dist * 2 * Math.cos(angle)
    else if @block-hole
      # @blocks.for-each (block) ~>
      #  block.body.gravity.y = block.gravity
      @block-hole.destroy!
      @block-hole = undefined
      @spawned-block-hole = false
      @block-hole-score = @player.score + 60

  complete-tutorial: ->
    @tut.stop!
    @bgm.play '' 0 1 true
    @@done-tutorial = true
    @stars.start false 3000 80

  start-tutorial: ->
    @tut-z-block = @add-block TutorialZBlock, 64 * 1, 0
      ..after-die = ~>
        @game.time.events.add 1000, @tut-spawn-dodge-block, this

  tut-spawn-dodge-block: ->
    @block-count = 7
    dec-block-count = ~>
      @block-count -= 1
      if @block-count <= 0
        @game.add.tween(@tut)
          ..to { volume: 0 }, 500, Phaser.Easing.Linear.None, true, 0, 0, false
          ..on-complete.add @complete-tutorial, this
          ..start!

    @tut-d-block = @add-block TutorialDBlock, 64 * 1, 0
      ..after-die = dec-block-count

    @game.time.events.add 2000, ~>
      for i from 2 to 7
        @add-block TutorialZBlock, 64 * i, 0
          ..after-die = dec-block-count

  generate-block: (rnd, use-this-one) ->
    const possible-blocks = [BasicBlock, BulletBlock, TntBlock, SteelBlock]
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
