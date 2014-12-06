// Generated by LiveScript 1.3.0
(function(){
  var ref$, each, all, map, leftRightAxis, towards, Player;
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
  towards = curry$(function(current, target, amount){
    var increment, passed, result;
    switch (false) {
    case current !== target:
      return current;
    default:
      increment = null;
      passed = null;
      if (current > target) {
        increment = (function(it){
          return it - amount;
        });
        passed = curry$(function(x$, y$){
          return x$ < y$;
        });
      } else {
        increment = (function(it){
          return it + amount;
        });
        passed = curry$(function(x$, y$){
          return x$ > y$;
        });
      }
      result = increment(current);
      if (passed(result, target)) {
        return target;
      } else {
        return result;
      }
    }
  });
  this.Player = Player = (function(superclass){
    var prototype = extend$((import$(Player, superclass).displayName = 'Player', Player), superclass).prototype, constructor = Player;
    prototype.keys = null;
    prototype.punchKey = null;
    prototype.direction = 0;
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
    prototype.hitboxWidth = 36;
    prototype.hitboxHeight = 49;
    function Player(game, core, x, y){
      var x$, y$;
      Player.superclass.call(this, game, x, y, 'breaker');
      this.core = core;
      game.physics.arcade.enable(this);
      this.anchor.setTo(31 / 64, 42 / 64);
      x$ = this.body;
      x$.bounce.y = 0.1;
      x$.bounce.x = 0.3;
      x$.gravity.y = 2000;
      x$.collideWorldBounds = true;
      x$.setSize(this.hitboxWidth, this.hitboxHeight);
      this.punchSound = this.game.add.audio('punch-sound');
      this.leftFist = game.add.sprite(0, 0);
      this.rightFist = game.add.sprite(0, 0);
      y$ = this.animations;
      y$.add('idle', [0, 1, 2, 1], 4, true);
      y$.add('walk', [3, 4, 5, 6, 7, 8], 10, true);
      y$.add('spinning', [11], 0, false);
      y$.add('punch1', [11, 9], 25, false);
      y$.add('punch2', [11, 10], 25, false);
      y$.play('idle');
    }
    prototype.initializeSmoke = function(){
      var x$;
      x$ = this.smoke = this.game.add.emitter(0, 0, 25);
      x$.makeParticles('smoke');
      x$.gravity = 10;
    };
    prototype.updateFistPositions = function(){
      var position;
      position = this.body.position;
      this.leftFist.x = position.x - 30;
      this.leftFist.y = position.y;
      this.rightFist.x = position.x + 30;
      this.rightFist.y = position.y;
      this.game.debug.body(this.leftFist);
      this.game.debug.body(this.rightFist);
    };
    prototype.update = function(){
      var delta, axis, grounded, targetSpeed, towardsTargetBy, x$, anim, this$ = this;
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
      if (axis !== 0) {
        this.direction = -axis;
      }
      grounded = this.grounded();
      if (grounded) {
        this.airTimer = 0;
      } else {
        this.airTimer += delta;
      }
      this.doubleClickTimer.left -= delta;
      this.doubleClickTimer.right -= delta;
      each(function(it){
        var key;
        if (this$.doubleClickTimer[it] < 0) {
          this$.doubleClickCounter[it] = 0;
        }
        key = this$.keys[it];
        if (key.downDuration(10)) {
          this$.doubleClickCounter[it] += 1;
          this$.doubleClickTimer[it] = 0.25;
          if (this$.doubleClickCounter[it] === 2) {
            this$.body.velocity.x = 1200 * axis;
            this$.doubleClickCounter[it] = 0;
            return this$.spinningTimer = 0.3;
          }
        }
      })(
      ['left', 'right']);
      targetSpeed = this.punchDelay <= 0 ? 250 * axis : 0;
      towardsTargetBy = towards(this.body.velocity.x, targetSpeed);
      this.body.velocity.x = towardsTargetBy(3000 * delta);
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
      }
      this.punchDelay -= delta;
      if (this.punchTimer > 0) {
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
        this.rotation = 0;
        if (axis !== 0) {
          this.scale.x = -axis;
          this.animations.play('walk');
        } else {
          this.animations.play('idle');
        }
      }
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
