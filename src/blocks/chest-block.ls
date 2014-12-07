class @ChestBlock extends Block
  @reroll-chance = 0

  damage-frames: 4
  score-worth: 50

  (...args) ~>
    super 'chest-block', ...args
    @hit-sound   = @game.add.audio 'chest-hit'
    @break-sound = @game.add.audio 'chest-break'
    @emitter     = @death-emitter [4, 5]
    @health = 50

  take-damage: (dmg) ->
    return if @dying
    @health -= dmg if dmg
    @animations.frame =
      switch
      | (@health > 40) => 0
      | (@health > 25) => 1
      | (@health > 15) => 2
      | otherwise      => 3

    if @health <= 0
      @dead! if @dead
      false
    else
      true

  test-layer-collision: (layer) ->
    if @body.blocked.left
      @body.velocity.x += 100
    else if @body.blocked.right
      @body.velocity.x -= 100
    true
