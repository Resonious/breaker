class @TutorialZBlock extends Block
  damage-frames: 3
  score-worth: 1

  (...args) ~>
    super 'noob-z-block', ...args
    @hit-sound   = @game.add.audio 'box-hit'
    @break-sound = @game.add.audio 'box-break'
    @emitter     = @death-emitter [3, 4, 5]

  die: ->
    super!
    @after-die!

class @TutorialDBlock extends Block
  damage-frames: 4
  score-worth: 1

  (...args) ~>
    super 'noob-d-block', ...args
    @hit-sound   = @game.add.audio 'box-hit'
    @break-sound = @game.add.audio 'box-break'
    @emitter     = @death-emitter [4, 5, 6]

  die: ->
    super!
    @after-die!
