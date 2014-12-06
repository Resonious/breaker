class @Block extends Phaser.Sprite
  is-block: true

  (game, core, key, x, y) ->
    super game, x, y, key

    @core = core
    game.physics.arcade.enable this
    @anchor.set-to 0.5 0.5
    @body
      ..bounce.y = 0.1
      ..bounce.x = 0.3
      ..gravity.y = 2000
      ..collide-world-bounds = false

  update: !->
