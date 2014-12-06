{each, all, map} = require 'prelude-ls'

left-right-axis = (l, r) --> match l, r
  | true, false => -1
  | false, true =>  1
  | otherwise   =>  0

towards = (current, target, amount) -->
  | current is target => return current
  | otherwise =>
    increment = null
    passed    = null
    if current > target
      increment = (- amount)
      passed    = (<)
    else
      increment = (+ amount)
      passed    = (>)

    result = increment current
    if result `passed` target
      target
    else
      result

class @Player extends Phaser.Sprite
  # Assigned by Game
  keys: null
  punch-key: null

  direction: 0

  air-timer: 0.0
  jump-while-off-ground-time: 0.1
  jump-boost-factor: 0.01
  jump-boost-time: 0.1
  jump-force: 500
  jumped: false

  double-click-timer: { left: 0, right: 0 }
  double-click-counter: { left: 0, right: 0 }

  punch: 0
  punch-timer: 0
  punch-delay: 0

  spinning-timer: 0.0

  hitbox-width: 36
  hitbox-height: 49
  fist-size: 16

  (game, core, x, y) ->
    super game, x, y, 'breaker'

    @core = core
    game.physics.arcade.enable this
    @anchor.set-to 31 / 64, 42 / 64
    @body
      ..bounce.y = 0.1
      ..bounce.x = 0.3
      ..gravity.y = 2000
      ..collide-world-bounds = true
      ..set-size @hitbox-width, @hitbox-height

    @punch-sound = @game.add.audio 'punch-sound'

    @fist  = game.add.sprite 0 0
    game.physics.arcade.enable @fist
    @fist.body.set-size @fist-size, @fist-size

    @animations
      ..add 'idle' [0, 1, 2, 1]       4 true
      ..add 'walk' [3, 4, 5, 6, 7, 8] 10 true
      ..add 'spinning' [11] 0 false
      ..add 'punch1'   [11, 9]  25 false
      ..add 'punch2'   [11, 10] 25 false
      ..play 'idle'

  # Called by Game so that smoke is above player
  initialize-smoke: !->
    @smoke = @game.add.emitter 0, 0, 25
      ..make-particles 'smoke'
      ..gravity = 10

  update-fist-positions: !->
    const position = @body.position
    const offset   = (@hitbox-width / 2) - (@fist-size / 2)

    @fist.body.x = position.x + offset - 23 * @direction
    @fist.body.y = position.y + 23

  debug-fist-positions: !->
    @game.debug.body @fist

  update: !->
    @update-fist-positions!
    @body.velocity.x = 0 if @body.velocity.x |> isNaN

    const delta = @game.time.physics-elapsed
    return if @keys is null
    axis = left-right-axis @keys.left.is-down, @keys.right.is-down
    @direction = -axis if axis isnt 0

    # =========== AIR TIMING AND GROUND MANAGEMENT ===
    grounded = @grounded!
    if grounded
      @air-timer = 0
    else
      @air-timer += delta

    # =============== DODGE ROLL ===============
    @double-click-timer.left  -= delta
    @double-click-timer.right -= delta

    ['left', 'right'] |> each ~>
      # Reset counter to 0 if time for doubleclick has run out
      if @double-click-timer[it] < 0
        @double-click-counter[it] = 0

      const key = @keys[it]

      if key.down-duration(10)
        @double-click-counter[it] += 1
        @double-click-timer[it]   = 0.25

        if @double-click-counter[it] == 2
          @body.velocity.x = 1200 * axis
          @double-click-counter[it] = 0
          @spinning-timer = 0.3

    # ================ MOVEMENT ================
    const target-speed = if @punch-delay <= 0 then 250 * axis else 0
    towards-target-by  = @body.velocity.x `towards` target-speed

    @body.velocity.x = towards-target-by 3000 * delta

    # ================ JUMP =====================
    if @keys.up.is-down
      if @grounded! or @air-timer < @jump-while-off-ground-time
        @body.velocity.y = -@jump-force
      else if @air-timer < @jump-boost-time
        @body.velocity.y -= @jump-force * @jump-boost-factor

    # ================ PUNCH ====================
    if axis isnt 0
      @punch-timer = 0

    if @punch-key.down-duration(10) and @punch-delay <= 0
      @punch += 1
      @punch-delay = 0.1
      @punch-timer = 0.5

      @punch-sound.play '' 0 1 false
      @smoke
        ..x = @body.position.x + @hitbox-width / 2 - 25 * @direction
        ..y = @body.position.y + 35
        ..start true, 100, null, 5

      @body.velocity.x += 100 * -@direction
      @core.punch @fist

    @punch-delay -= delta

    # ================ ANIMATION ================
    if @punch-timer > 0
      @rotation = 0
      const anim = "punch#{@punch % 2 + 1}"
      @animations.play anim unless @animations.name is anim
      @punch-timer -= delta

    else if @spinning-timer > 0
      @scale.x = @direction
      @animations.play 'spinning'
      @rotation += -0.3 * @direction
      @spinning-timer -= delta

    else
      @rotation = 0
      unless axis is 0
        @scale.x = -axis
        @animations.play 'walk'
      else
        @animations.play 'idle'

    # = DEBUG =
    # if @keys.down.is-down
      # @rotation += 0.1

  grounded: -> @body.blocked.down or @body.touching.down
