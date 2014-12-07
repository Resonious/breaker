class @ChestBlock extends Block
  damage-frames: 4
  score-worth: 50

  (...args) ~>
    super 'chest-block', ...args
    @hit-sound   = @game.add.audio 'chest-hit'
    @break-sound = @game.add.audio 'chest-break'
    @emitter     = @death-emitter [4, 5]
    @health = 10

  take-damage: (dmg) ->
    return if @dying
    @health -= dmg or 1
    @animations.frame =
      switch
      | (@health > 7) => 0
      | (@health > 5) => 1
      | (@health > 2) => 2
      | otherwise     => 3

    if @health <= 0
      @dead! if @dead
      false
    else
      true

#   test-layer-collision: (layer) ->
#     if @body.blocked.left
#       @body.velocity.x += 100
#     else if @body.blocked.right
#       @body.velocity.x -= 100
#     true

  dead: ->
    super!
    @core.add-power-up PowerUp, @x, @y
