class @Block extends Phaser.Sprite
  is-block: true

  (spritesheet, game, core, x, y) ~>
    super game, x, y, spritesheet

    @core = core
    game.physics.arcade.enable this
    @anchor.set-to 0.5 0.5
    @body
      ..bounce.y = 0.1
      ..bounce.x = 0.3
      ..gravity.y = 700
      ..collide-world-bounds = false

  take-damage: (dmg) ->
    @animations.frame += dmg or 1
    if @animations.frame >= @damage-frames
      @dead! if @dead
      false
    else
      true

  update: !->
    const delta = @game.time.physics-elapsed
    const velocity = @body.velocity
    # Friction sorta
    velocity.x = towards velocity.x, 0, 3000 * delta

class @BasicBlock extends Block
  damage-frames: 3

  (...args) ~>
    super 'basic-block', ...args
    @hit-sound = @game.add.audio 'box-hit'
    @break-sound = @game.add.audio 'box-break'
    @emitter = @game.add.emitter 0 0 20
      ..make-particles 'basic-block', [3, 4, 5]
      ..gravity = 200

  punched: (fist) ->
    @body.velocity.x += 135 * -fist.player.direction
    @body.velocity.y -= 100
    if @take-damage!
      @hit-sound.play '' 0 1 false

  dead: ->
    return if @dying
    @dying       = true
    @visible     = false
    @body.enable = false
    @emitter
      ..max-particle-speed.set-to 100 500
      ..max-rotation *= 2
      ..x = @body.position.x + 32
      ..y = @body.position.y + 32
      ..start true, 500, null, 5

    @game.time.events.add 500 @die, this
    @break-sound.play '' 0 1 false

  die: ->
    @emitter.destroy!
    @destroy!
