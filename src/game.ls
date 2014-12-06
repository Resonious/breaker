{each, all, map} = require 'prelude-ls'

class @GameCore
  (game) !->
    @game = game

  preload: !->
    asset = (p) -> "game/assets/#p"
    @game.load
      ..spritesheet 'breaker'    (asset 'breaker.png'), 64 64
      ..image       'basic-tile' asset 'better-basic-tile.png'
      ..tilemap     'map',       (asset 'map/basic-map.json'), null, Phaser.Tilemap.TILED_JSON

  create: !->
    let (add     = @game.add,
         physics = @game.physics,
         world   = @game.world
         camera  = @game.camera)

      @game.stage.background-color = '#FFFFFF'
      @game.time.advancedTiming    = true

      physics.start-system Phaser.Physics.Arcade

      map = add.tilemap 'map'
        ..add-tileset-image 'basic', 'basic-tile'
        ..set-collision 1
      @layer = map.create-layer 'Tile Layer 1'
         ..resize-world!

      @arrow-keys = @game.input.keyboard.create-cursor-keys!

      @player = add.existing new Player(@game, this, 400, 500)
        ..keys = @arrow-keys

  update: !->
    @game.physics.arcade.collide @player, @layer

  # render: !->
    # @game.debug.body @player
