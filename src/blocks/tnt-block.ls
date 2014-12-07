class @TntBlock extends Block
  @reroll-chance = 75

  damage-frames: 3
  score-worth: 2
  play-hit-sound-on-death: true
  max-frame: 2

  death-timer: 1.0
  countdown-num: 3

  (...args) ~>
    super 'tnt-block', ...args
    @hit-sound     = @game.add.audio 'box-hit'
    @explode-sound = @game.add.audio 'boom'
    @beep-sound    = @game.add.audio 'beep'
    @emitter       = @death-emitter [3, 4, 5]
    @countdown = new Phaser.Text(@game, 0, 0, '3',
      font: '28px Monaco'
      fill: '#FFFFFF'
      align: 'center'
    )
    @explosion = new Phaser.Sprite(@game, 0, 0, 'explosion')
      ..anchor.set-to 0.5 0.5
      ..x = 0
      ..y = 0
      ..frame = 0

  dead: ->
    return if @dying
    @beep-sound.play '' 0 1 false
    @dying = true
    @add-child @countdown
    @countdown.x -= 8
    @countdown.y -= 16

    @add-child @explosion

  damage-adjacent: (after) ->
    @explosion.animations.frame = 1
    @explosion.scale.set-to 0 0
    @game.add.tween(@explosion.scale)
      ..to { x: 1.5, y: 1.5 }, 500, Phaser.Easing.Quadratic.None, true, 0, 0, false
      ..on-complete.add after, this
      ..start!

    const radius = new Phaser.Circle(@x, @y, 192)
    @core.blocks.for-each ->
      return if this is it
      const bounds = it.get-bounds!
      if Phaser.Circle.intersects-rectangle radius, bounds
        it.hit-sound.play '' 0 1 false if it.hit-sound
        it.take-damage 5               if it.take-damage

    const bounds = @core.player.get-bounds!
    if Phaser.Circle.intersects-rectangle radius, bounds
      @core.player.die!

  update: ->
    super!
    return unless @dying
    return if @countdown-num is -1
    const delta = @game.time.physics-elapsed
    @death-timer -= delta

    if @death-timer <= 0
      @death-timer = 1.0
      @countdown-num -= 1
      if @countdown-num == -1
        @explode-sound.play '' 0 1 false
        @animations.frame  = 6
        @countdown.visible = false
        @body.enable       = false

        @emitter
          ..max-particle-speed.set-to 100 500
          ..max-rotation *= 2
          ..x = @x
          ..y = @y
          ..start true 500 null 5

        @damage-adjacent @die
      else
        @beep-sound.play '' 0 1 false
        @countdown.text = "#{@countdown-num}"
