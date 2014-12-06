class @Block extends Phaser.Sprite
  is-block: true

  (spritesheet, game, core, x, y) ~>
    console.log "sprite sheet is #spritesheet"
    super game, x, y, spritesheet

    @core = core
    game.physics.arcade.enable this
    @anchor.set-to 0.5 0.5
    @body
      ..bounce.y = 0.1
      ..bounce.x = 0.3
      ..gravity.y = 2000
      ..collide-world-bounds = false

    @initialize! if @initialize

class @BasicBlock extends Block
  (...args) ~> super 'basic-block', ...args
