class @PowerUp extends Phaser.Sprite
  @glow = (game) ->
    s = new Phaser.Sprite(game, 0, 0, 'explosion')
      ..anchor.set-to 0.5 0.5
      ..x = 0
      ..y = 0
      ..animations.frame = 1
  @effect = (game) ->
    s = new Phaser.Sprite(game, 0, 0, 'power-up')
      ..anchor.set-to 0.5 0.5
      ..x = 0
      ..y = 0
      ..animations.add 'blaze' [1, 2, 3, 2] 5, true
      ..play 'blaze'
    s

  (game, core, x, y) ->
    super game, x, y, 'power-up'
    game.physics.arcade.enable this
    @anchor.set-to 0.5 0.5
    @scale.set-to 2 2
    @x = x
    @y = y
    @add-child @@glow(game)
      ..scale.set-to 0.4 0.4
      ..alpha = 0.3
    @add-child @@effect(game)
      ..scale.set-to 2 2
    @bring-to-top!

  picked-up: (player) ->
    effect = @@effect(@game)
    effect.glow = effect.add-child @@glow(@game)
      ..scale.set-to 0.4 0.4
      ..alpha = 0.1
    effect.scale.set-to 2 2
    player.add-power-up effect, @on-use, @use-update, @finish
    @destroy!

  on-use: (player) ->
    const game = player.game
    @charge-up   = game.add.audio 'charge-up'
    @blast-off   = game.add.audio 'blast-off'
    @charge-down = game.add.audio 'charge-down'
    @charging-up = true

    # player.power-up.effect.glow.alpha = 1
    const break-blocks = (me, block) ->
      block.punched(me.fist, 20) if block.punched
      false

    const gravity-y = player.body.gravity.y
    const velocity-x = player.body.velocity.x
    player
      ..disable-controls     = true
      ..dont-adjust-velocity = true
      ..invincible           = true
      ..block-collide-test   = break-blocks
      ..body
        ..gravity.y = 0
        ..velocity.x = 0
        ..velocity.y = -50

    blast-off = ->
      player.body
        ..gravity.y = gravity-y
        ..velocity
          ..x = velocity-x
          ..y = -1200
      @blast-off.play '' 0 1 false
      @charging-up = false

    @charge-up.play '' 0 1 false
    game.add.tween(player.power-up.effect.glow)
      ..to { alpha: 1 }, 500, Phaser.Easing.Quadratic.None, true, 0, 0, false
      ..on-complete.add blast-off, this
      ..start!


  use-update: (player) ->
    if player.body.blocked.down and not @charging-up
      # maybe shake ground/damage everything
      @charge-down.play '' 0 1 false
      player.cancel-power-up!

  finish: (player) ->
    player
      ..disable-controls     = false
      ..dont-adjust-velocity = false
      ..block-collide-test   = undefined
    player.game.time.events.add 500, (-> @invincible = false), player

