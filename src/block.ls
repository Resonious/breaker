class @Block extends Phaser.Sprite
  is-block: true
  gravity: 700

  (spritesheet, game, core, x, y) ~>
    super game, x, y, spritesheet

    @spritesheet = spritesheet
    @core = core
    game.physics.arcade.enable this
    @anchor.set-to 0.5 0.5
    @body
      ..bounce.y = 0.1
      ..bounce.x = 0.3
      ..gravity.y = @gravity
      ..collide-world-bounds = false

  take-damage: (dmg) ->
    @animations.frame += dmg or 1
    if @animations.frame >= @damage-frames
      @dead! if @dead
      false
    else
      true

  death-emitter: (frames) ->
    @game.add.emitter 0 0 20
      ..make-particles @spritesheet, frames
      ..gravity = 200

  punched: (fist) ->
    @body.velocity.x += 135 * -fist.player.direction if fist
    @body.velocity.y -= 100
    if @take-damage!
      @hit-sound.play '' 0 1 false
    else
      fist.player.score += @score-worth if fist
      @core.score!

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

  update: !->
    const delta = @game.time.physics-elapsed
    const velocity = @body.velocity
    # Friction sorta
    velocity.x = towards velocity.x, 0, 3000 * delta

    if @body.touching.down
      @body.gravity.y = 0
    else
      @body.gravity.y = @gravity

class @BasicBlock extends Block
  damage-frames: 3
  score-worth: 1

  (...args) ~>
    super 'basic-block', ...args
    @hit-sound   = @game.add.audio 'box-hit'
    @break-sound = @game.add.audio 'box-break'
    @emitter     = @death-emitter [3, 4, 5]
