// Generated by LiveScript 1.3.0
(function(){
  var ref$, each, all, map, leftRightAxis, Player;
  ref$ = require('prelude-ls'), each = ref$.each, all = ref$.all, map = ref$.map;
  leftRightAxis = curry$(function(l, r){
    var ref$;
    switch (ref$ = [l, r], false) {
    case !(true === ref$[0] && false === ref$[1]):
      return -1;
    case !(false === ref$[0] && true === ref$[1]):
      return 1;
    default:
      return 0;
    }
  });
  this.Player = Player = (function(superclass){
    var prototype = extend$((import$(Player, superclass).displayName = 'Player', Player), superclass).prototype, constructor = Player;
    prototype.keys = null;
    prototype.punchKey = null;
    prototype.direction = 1;
    prototype.airTimer = 0.0;
    prototype.jumpWhileOffGroundTime = 0.1;
    prototype.jumpBoostFactor = 0.01;
    prototype.jumpBoostTime = 0.1;
    prototype.jumpForce = 500;
    prototype.jumped = false;
    prototype.doubleClickTimer = {
      left: 0,
      right: 0
    };
    prototype.doubleClickCounter = {
      left: 0,
      right: 0
    };
    prototype.punch = 0;
    prototype.punchTimer = 0;
    prototype.punchDelay = 0;
    prototype.spinningTimer = 0.0;
    prototype.spinCooldownTimer = 0.0;
    prototype.hitboxWidth = 36;
    prototype.hitboxHeight = 49;
    prototype.fistSize = 16;
    prototype.score = 0;
    function Player(game, core, x, y){
      var x$, y$, z$;
      Player.superclass.call(this, game, x, y, 'breaker');
      this.core = core;
      game.physics.arcade.enable(this);
      this.anchor.setTo(31 / 64, 42 / 64);
      x$ = this.body;
      x$.bounce.y = 0.1;
      x$.bounce.x = 0.3;
      x$.gravity.y = 2000;
      x$.collideWorldBounds = false;
      x$.setSize(this.hitboxWidth, this.hitboxHeight);
      this.checkWorldBounds = true;
      this.events.onOutOfBounds.add(function(){
        return this.die(true);
      }, this);
      this.punchSound = this.game.add.audio('punch-sound');
      this.chargeDown = this.game.add.audio('charge-down');
      y$ = this.fist = game.add.sprite(0, 0);
      y$.player = this;
      game.physics.arcade.enable(this.fist);
      this.fist.body.setSize(this.fistSize, this.fistSize);
      z$ = this.animations;
      z$.add('idle', [0, 1, 2, 1], 4, true);
      z$.add('walk', [3, 4, 5, 6, 7, 8], 10, true);
      z$.add('jump', [12], 0, false);
      z$.add('spinning', [11], 0, false);
      z$.add('punch1', [11, 9], 25, false);
      z$.add('punch2', [11, 10], 25, false);
      z$.play('idle');
    }
    prototype.initializeSmoke = function(){
      var x$;
      x$ = this.smoke = this.game.add.emitter(0, 0, 25);
      x$.makeParticles('smoke');
      x$.gravity = 10;
    };
    prototype.updateFistPositions = function(){
      var position, offset;
      position = this.body.position;
      offset = this.hitboxWidth / 2 - this.fistSize / 2;
      this.fist.body.x = position.x + offset - 23 * this.direction;
      this.fist.body.y = position.y + 23;
    };
    prototype.debugFistPositions = function(){
      this.game.debug.body(this.fist);
    };
    prototype.cancelPowerUp = function(){
      if (!this.powerUp) {
        return;
      }
      this.removeChild(this.powerUp.effect);
      this.powerUp.finish(this);
      return this.powerUp = null;
    };
    prototype.addPowerUp = function(effect, onUse, updateAfterUse, onFinish){
      this.cancelPowerUp();
      this.powerUp = {
        effect: effect,
        use: onUse,
        update: updateAfterUse,
        finish: onFinish
      };
      return this.addChild(effect);
    };
    prototype.update = function(){
      var delta, axis, grounded, targetSpeed, towardsTargetBy, x$, anim, velocity, this$ = this;
      this.updateFistPositions();
      if (isNaN(
      this.body.velocity.x)) {
        this.body.velocity.x = 0;
      }
      delta = this.game.time.physicsElapsed;
      if (this.keys === null) {
        return;
      }
      axis = leftRightAxis(this.keys.left.isDown, this.keys.right.isDown);
      if (this.dying || this.disableControls) {
        axis = 0;
      }
      if (axis !== 0) {
        this.direction = -axis;
      }
      grounded = this.grounded();
      if (grounded) {
        this.airTimer = 0;
      } else {
        this.airTimer += delta;
      }
      if (this.body.touching.down) {
        this.body.gravity.y = 100;
      } else {
        this.body.gravity.y = 2000;
      }
      if (this.spinCooldownTimer > 0) {
        this.spinCooldownTimer -= delta;
      } else {
        this.doubleClickTimer.left -= delta;
        this.doubleClickTimer.right -= delta;
        each(function(it){
          var key;
          if (this$.doubleClickTimer[it] < 0) {
            this$.doubleClickCounter[it] = 0;
          }
          key = this$.keys[it];
          if (key.downDuration(10) && !this$.disableControls) {
            this$.doubleClickCounter[it] += 1;
            this$.doubleClickTimer[it] = 0.25;
            if (this$.doubleClickCounter[it] === 2) {
              this$.body.velocity.x = 1200 * axis;
              this$.doubleClickCounter[it] = 0;
              this$.spinningTimer = 0.3;
              return this$.spinCooldownTimer = 0.2;
            }
          }
        })(
        ['left', 'right']);
      }
      if (!this.dontAdjustVelocity) {
        targetSpeed = this.punchDelay <= 0 ? 250 * axis : 0;
        towardsTargetBy = towards(this.body.velocity.x, targetSpeed);
        this.body.velocity.x = towardsTargetBy(3000 * delta);
      }
      if (this.keys.up.isDown) {
        if (this.grounded() || this.airTimer < this.jumpWhileOffGroundTime) {
          this.body.velocity.y = -this.jumpForce;
        } else if (this.airTimer < this.jumpBoostTime) {
          this.body.velocity.y -= this.jumpForce * this.jumpBoostFactor;
        }
      }
      if (axis !== 0) {
        this.punchTimer = 0;
      }
      if (this.punchKey.downDuration(10) && this.punchDelay <= 0) {
        this.punch += 1;
        this.punchDelay = 0.1;
        this.punchTimer = 0.5;
        this.punchSound.play('', 0, 1, false);
        x$ = this.smoke;
        x$.x = this.body.position.x + this.hitboxWidth / 2 - 25 * this.direction;
        x$.y = this.body.position.y + 35;
        x$.start(true, 100, null, 5);
        this.body.velocity.x += 100 * -this.direction;
        this.core.punch(this.fist);
      }
      this.punchDelay -= delta;
      if (!this.dying) {
        if (this.punchTimer > 0) {
          this.rotation = 0;
          anim = "punch" + (this.punch % 2 + 1);
          if (this.animations.name !== anim) {
            this.animations.play(anim);
          }
          this.punchTimer -= delta;
        } else if (this.spinningTimer > 0) {
          this.scale.x = this.direction;
          this.animations.play('spinning');
          this.rotation += -0.3 * this.direction;
          this.spinningTimer -= delta;
        } else {
          if (axis !== 0) {
            this.scale.x = -axis;
          }
          this.rotation = 0;
          if (this.grounded()) {
            this.animations.play(axis === 0 ? 'idle' : 'walk');
          } else {
            velocity = this.body.velocity;
            this.animations.play(velocity.y > 0 ? 'walk' : 'jump');
          }
        }
      }
      if (this.powerUp && this.powerUp.inUse) {
        this.powerUp.update(this);
      }
      if (this.specialKey.downDuration(10) && this.powerUp && !this.powerUp.inUse) {
        this.powerUp.use(this);
        this.powerUp.inUse = true;
      }
    };
    prototype.spinning = function(){
      return this.spinningTimer > 0;
    };
    prototype.onCollide = function(block){
      var left, right;
      if (this.spinning()) {
        if (block.alreadyHurtByRoll && block.alreadyHurtByRoll()) {
          return;
        }
        left = this.body.touching.left && block.body.touching.right;
        right = this.body.touching.right && block.body.touching.left;
        if (left || right) {
          block.punched(this.fist);
        }
        return block.hurtByRollTimer = 0.05;
      } else if (this.body.touching.up && this.grounded() && block.body.velocity.y > 100) {
        if (!this.die()) {
          return block.body.velocity.y = -5;
        }
      }
    };
    prototype.die = function(force){
      if (this.dying || (!force && this.invincible)) {
        return false;
      }
      if (this.powerUp) {
        this.chargeDown.play('', 0, 1, false);
        this.cancelPowerUp();
        if (!force) {
          return false;
        }
      }
      console.log('WASTED');
      this.body.velocity.y = 0;
      this.body.gravity.y = 500;
      this.dying = true;
      this.core.bgm.stop();
      this.core.deathSound.play('', 0, 2, false);
      this.animations.stop();
      this.game.time.events.add(5000, function(){
        return this.state.start('Game');
      }, this.game);
      return true;
    };
    prototype.grounded = function(){
      return this.body.blocked.down || this.body.touching.down;
    };
    return Player;
  }(Phaser.Sprite));
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
  function extend$(sub, sup){
    function fun(){} fun.prototype = (sub.superclass = sup).prototype;
    (sub.prototype = new fun).constructor = sub;
    if (typeof sup.extended == 'function') sup.extended(sub);
    return sub;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
