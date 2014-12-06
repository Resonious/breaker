{each, all, map} = require 'prelude-ls'

class @GameCore
  (game) !->
    @game = game

  preload: !->
    asset = (p) -> "game/assets/#p"
    @game.load
      ..spritesheet 'basic-tile' (asset 'better-basic-tile.png'), 32 32
      ..spritesheet 'breaker' (asset 'breaker.png'), 64 64

  create: !->
    let (add     = @game.add,
         physics = @game.physics,
         world   = @game.world
         camera  = @game.camera)

      @game.stage.background-color = '#FFFFFF'
      @game.time.advancedTiming    = true

      physics.start-system Phaser.Physics.Arcade

      @arrow-keys = @game.input.keyboard.create-cursor-keys!

      @player = add.existing new Player(@game, this, 100, 100)
        ..keys = @arrow-keys

  render: !->
    @game.debug.body @player
