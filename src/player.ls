{each, all, map} = require 'prelude-ls'

left-right-axis = (l, r) --> match l, r
  | true, false => -1
  | false, true =>  1
  | otherwise   =>  0

class @Player extends Phaser.Sprite
  # Assigned by Game
  keys: null
  punch-key: null

  direction: 1

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
  spin-cooldown-timer: 0.0

  hitbox-width: 36
  hitbox-height: 49
  fist-size: 16

  score: 0

  (game, core, x, y) ->
    super game, x, y, 'breaker'

    @core = core
    game.physics.arcade.enable this
    @anchor.set-to 31 / 64, 42 / 64
    @body
      ..bounce.y = 0.1
      ..bounce.x = 0.3
      ..gravity.y = 2000
      ..collide-world-bounds = false
      ..set-size @hitbox-width, @hitbox-height

    @check-world-bounds = true
    @events.on-out-of-bounds.add (-> @die true), this

    @punch-sound = @game.add.audio 'punch-sound'
    @charge-down = @game.add.audio 'charge-down'

    @fist = game.add.sprite 0 0
      ..player = this
    game.physics.arcade.enable @fist
    @fist.body.set-size @fist-size, @fist-size

    @animations
      ..add 'idle' [0, 1, 2, 1]       4 true
      ..add 'walk' [3, 4, 5, 6, 7, 8] 10 true
      ..add 'jump' [12] 0 false
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

  cancel-power-up: ->
    return unless @power-up
    @remove-child @power-up.effect
    @power-up.finish(this)
    @power-up = null

  add-power-up: (effect, on-use, update-after-use, on-finish) ->
    @cancel-power-up!
    @power-up = { effect: effect, use: on-use, update: update-after-use, finish: on-finish }
    @add-child effect

  update: !->
    @update-fist-positions!
    @body.velocity.x = 0 if @body.velocity.x |> isNaN

    const delta = @game.time.physics-elapsed
    return if @keys is null
    axis = left-right-axis @keys.left.is-down, @keys.right.is-down
    axis = 0 if @dying or @disable-controls
    @direction = -axis if axis isnt 0

    # =========== AIR TIMING AND GROUND MANAGEMENT ===
    grounded = @grounded!
    if grounded
      @air-timer = 0
    else
      @air-timer += delta

    if @body.touching.down
      @body.gravity.y = 100
    else
      @body.gravity.y = 2000

    # =============== DODGE ROLL ===============
    if @spin-cooldown-timer > 0
      @spin-cooldown-timer -= delta
    else
      @double-click-timer.left  -= delta
      @double-click-timer.right -= delta

      ['left', 'right'] |> each ~>
        # Reset counter to 0 if time for doubleclick has run out
        if @double-click-timer[it] < 0
          @double-click-counter[it] = 0

        const key = @keys[it]

        if key.down-duration(10) and not @disable-controls
          @double-click-counter[it] += 1
          @double-click-timer[it]   = 0.25

          if @double-click-counter[it] == 2
            @body.velocity.x = 1200 * axis
            @double-click-counter[it] = 0
            @spinning-timer = 0.3
            @spin-cooldown-timer = 0.2

    # ================ MOVEMENT ================
    unless @dont-adjust-velocity
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
    unless @dying
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
        @scale.x = -axis unless axis is 0
        @rotation = 0
        if @grounded!
          @animations.play if axis is 0 then 'idle' else 'walk'
        else
          const velocity = @body.velocity
          @animations.play if velocity.y > 0 then 'walk' else 'jump'

    # ================ SPECIAL ==============
    if @power-up and @power-up.in-use
      @power-up.update(this)

    if @special-key.down-duration(10) and @power-up and not @power-up.in-use
      @power-up.use(this)
      @power-up.in-use = true

  spinning: -> @spinning-timer > 0

  on-collide: (block) ->
    if @spinning!
      return if block.already-hurt-by-roll and block.already-hurt-by-roll!
      const left  = @body.touching.left  && block.body.touching.right
      const right = @body.touching.right && block.body.touching.left
      block.punched(@fist) if left or right
      block.hurt-by-roll-timer = 0.1
    else if @body.touching.up && @grounded! && block.body.velocity.y > 100
      block.body.velocity.y = -5 unless @die!

  die: (force) ->
    return false if @dying or (!force and @invincible)
    if @power-up
      @charge-down.play '' 0 1 false
      @cancel-power-up!
      return false unless force
    console.log 'WASTED'
    @body.velocity.y = 0
    @body.gravity.y = 500
    @dying = true
    @core.bgm.stop!
    @core.death-sound.play '' 0 2 false
    @animations.stop!

    @game.time.events.add 5000, (-> @state.start 'Game'), @game
    true

  grounded: -> @body.blocked.down or @body.touching.down
