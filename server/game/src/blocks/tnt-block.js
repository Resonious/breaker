// Generated by LiveScript 1.3.0
(function(){
  var TntBlock, slice$ = [].slice;
  this.TntBlock = TntBlock = (function(superclass){
    var prototype = extend$((import$(TntBlock, superclass).displayName = 'TntBlock', TntBlock), superclass).prototype, constructor = TntBlock;
    TntBlock.rerollChance = 45;
    prototype.damageFrames = 3;
    prototype.scoreWorth = 2;
    prototype.playHitSoundOnDeath = true;
    prototype.maxFrame = 2;
    prototype.deathTimer = 1.0;
    prototype.countdownNum = 3;
    function TntBlock(){
      var args, x$, this$ = this instanceof ctor$ ? this : new ctor$;
      args = slice$.call(arguments);
      TntBlock.superclass.apply(this$, ['tnt-block'].concat(slice$.call(args)));
      this$.hitSound = this$.game.add.audio('box-hit');
      this$.explodeSound = this$.game.add.audio('boom');
      this$.beepSound = this$.game.add.audio('beep');
      this$.emitter = this$.deathEmitter([3, 4, 5]);
      this$.countdown = new Phaser.Text(this$.game, 0, 0, '3', {
        font: '28px Monaco',
        fill: '#FFFFFF',
        align: 'center'
      });
      x$ = this$.explosion = new Phaser.Sprite(this$.game, 0, 0, 'explosion');
      x$.anchor.setTo(0.5, 0.5);
      x$.x = 0;
      x$.y = 0;
      x$.frame = 0;
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.dead = function(){
      if (this.dying) {
        return;
      }
      this.beepSound.play('', 0, 1, false);
      this.dying = true;
      this.addChild(this.countdown);
      this.countdown.x -= 8;
      this.countdown.y -= 16;
      return this.addChild(this.explosion);
    };
    prototype.damageAdjacent = function(after){
      var x$, radius, bounds;
      this.explosion.animations.frame = 1;
      this.explosion.scale.setTo(0, 0);
      x$ = this.game.add.tween(this.explosion.scale);
      x$.to({
        x: 1.5,
        y: 1.5
      }, 500, Phaser.Easing.Quadratic.None, true, 0, 0, false);
      x$.onComplete.add(after, this);
      x$.start();
      radius = new Phaser.Circle(this.x, this.y, 192);
      this.core.blocks.forEach(function(it){
        var bounds;
        if (this === it) {
          return;
        }
        bounds = it.getBounds();
        if (Phaser.Circle.intersectsRectangle(radius, bounds)) {
          if (it.hitSound) {
            it.hitSound.play('', 0, 1, false);
          }
          if (it.takeDamage) {
            return it.takeDamage(5);
          }
        }
      });
      bounds = this.core.player.getBounds();
      if (Phaser.Circle.intersectsRectangle(radius, bounds)) {
        return this.core.player.die();
      }
    };
    prototype.update = function(){
      var delta, x$;
      superclass.prototype.update.call(this);
      if (!this.dying) {
        return;
      }
      if (this.countdownNum === -1) {
        return;
      }
      delta = this.game.time.physicsElapsed;
      this.deathTimer -= delta;
      if (this.deathTimer <= 0) {
        this.deathTimer = 1.0;
        this.countdownNum -= 1;
        if (this.countdownNum === -1) {
          this.explodeSound.play('', 0, 1, false);
          this.animations.frame = 6;
          this.countdown.visible = false;
          this.body.enable = false;
          x$ = this.emitter;
          x$.maxParticleSpeed.setTo(100, 500);
          x$.maxRotation *= 2;
          x$.x = this.x;
          x$.y = this.y;
          x$.start(true, 500, null, 5);
          return this.damageAdjacent(this.die);
        } else {
          this.beepSound.play('', 0, 1, false);
          return this.countdown.text = this.countdownNum + "";
        }
      }
    };
    return TntBlock;
  }(Block));
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
