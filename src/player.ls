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
      increment := (- amount)
      passed    := (<)
    else
      increment := (+ amount)
      passed    := (>)

    result = increment current
    if result `passed` target
      target
    else
      result

class @Player extends Phaser.Sprite
  # Assigned by Game
  keys: null

  direction: 0

  air-timer: 0.0
  jump-while-off-ground-time: 0.1
  jump-boost-factor: 0.01
  jump-boost-time: 0.1
  jump-force: 500
  jumped: false

  double-click-timer: { left: 0, right: 0 }
  double-click-counter: { left: 0, right: 0 }

  spinning-timer: 0.0

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
      ..set-size 36 49

    @animations
      ..add 'idle' [0, 1, 2, 1]       4 true
      ..add 'walk' [3, 4, 5, 6, 7, 8] 10 true
      ..play 'idle'

  update: !->
    @body.velocity.x = 0 if @body.velocity.x |> isNaN

    delta = @game.time.physics-elapsed
    return if @keys is null
    axis  = left-right-axis @keys.left.is-down, @keys.right.is-down
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
    const target-speed = 250 * axis
    towards-target-by = @body.velocity.x `towards` target-speed

    @body.velocity.x = towards-target-by 3000 * delta

    # ================ JUMP =====================
    if @keys.up.is-down
      if @grounded! or @air-timer < @jump-while-off-ground-time
        @body.velocity.y = -@jump-force
      else if @air-timer < @jump-boost-time
        @body.velocity.y -= @jump-force * @jump-boost-factor

    # ================ ANIMATION ================
    if @spinning-timer > 0
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
