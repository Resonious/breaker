class Bullet extends Phaser.Sprite
  score-worth: 1

  (game, x, y, direction) ~>
    super game, x, y, 'bullet-block'
    game.physics.arcade.enable this

    @anchor.set-to 0.5 0.5
    @body
      ..set-size 16 16
      ..velocity.x = 500 * direction

    @check-world-bounds = true
    @events.on-out-of-bounds.add @dead, this

    @animations.frame = 7

  on-collide: (plr) ->
    plr.die!
    @dead!

  on-block-collide: (block) ->
    block.punched!
    @dead!

  punched: (fist) ->
    # TODO so play sound.
    @dead!

  dead: ->
    # TODO play sound????
    @exists = false

class @BulletBlock extends Block
  damage-frames: 5
  score-worth: 2

  bullet-timer: 5.0

  (...args) ~>
    super 'bullet-block', ...args
    @hit-sound   = @game.add.audio 'box-hit'
    @break-sound = @game.add.audio 'box-break'
    @emitter     = @death-emitter [5, 6]
    @laser-eye = @add-child new Phaser.Sprite(
      @game, 0, 0, 'bullet-block')
      ..anchor.set-to 0.5 0.5
      ..x = 0
      ..y = 0
      ..animations.frame = 8
      ..alpha = 0

    const scales = [-1, 1]
    @scale.x = scales[@game.rnd.integer-in-range 0 1]
    @shoot-sound = @game.add.audio 'box-shoot'

  bullet: ->
    const x = @x + 16 * @scale.x
    const y = @y

    new Bullet(@game, x, y, @scale.x)

  update: !->
    super!
    const delta = @game.time.physics-elapsed
    @bullet-timer -= delta
    @laser-eye.alpha = 1 - @bullet-timer / 5.5

    if @bullet-timer <= 0
      @shoot-sound.play '' 0 1 false
      @core.blocks.add @bullet!
      @bullet-timer = 5.5
