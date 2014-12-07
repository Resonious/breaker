class @TntBlock extends Block
  damage-frames: 3
  score-worth: 2
  play-hit-sound-on-death: true

  death-timer: 1.0
  countdown-num: 3

  (...args) ~>
    super 'tnt-block', ...args
    @hit-sound = @game.add.audio 'box-hit'
    @emitter = @death-emitter [3, 4, 5]
    @countdown = new Phaser.Text(@game, 0, 0, '3',
      font: '28px Monaco'
      fill: '#FFFFFF'
      align: 'center'
    )

  dead: ->
    return if @dying
    @dying = true
    @animations.frame -= 1
    @add-child @countdown
    @countdown.x -= 8
    @countdown.y -= 16

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
        console.log 'BOOM!!!!!!!!!!!!!!!!!!'
        @visible     = false
        @body.enable = false
        @emitter
          ..max-particle-speed.set-to 100 500
          ..max-rotation *= 2
          ..x = @x
          ..y = @y
          ..start true 500 null 5

        @game.time.events.add 500 @die, this
      else
        @countdown.text = "#{@countdown-num}"
