// Generated by LiveScript 1.3.0
(function(){
  var Block, BasicBlock, slice$ = [].slice;
  this.Block = Block = (function(superclass){
    var prototype = extend$((import$(Block, superclass).displayName = 'Block', Block), superclass).prototype, constructor = Block;
    prototype.isBlock = true;
    function Block(spritesheet, game, core, x, y){
      var x$, this$ = this instanceof ctor$ ? this : new ctor$;
      Block.superclass.call(this$, game, x, y, spritesheet);
      this$.core = core;
      game.physics.arcade.enable(this$);
      this$.anchor.setTo(0.5, 0.5);
      x$ = this$.body;
      x$.bounce.y = 0.1;
      x$.bounce.x = 0.3;
      x$.gravity.y = 2000;
      x$.collideWorldBounds = false;
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.takeDamage = function(dmg){
      this.animations.frame += dmg || 1;
      if (this.animations.frame >= this.damageFrames) {
        if (this.dead) {
          this.dead();
        }
        return false;
      } else {
        return true;
      }
    };
    prototype.update = function(){
      var delta, velocity;
      delta = this.game.time.physicsElapsed;
      velocity = this.body.velocity;
      velocity.x = towards(velocity.x, 0, 3000 * delta);
    };
    return Block;
  }(Phaser.Sprite));
  this.BasicBlock = BasicBlock = (function(superclass){
    var prototype = extend$((import$(BasicBlock, superclass).displayName = 'BasicBlock', BasicBlock), superclass).prototype, constructor = BasicBlock;
    prototype.damageFrames = 3;
    function BasicBlock(){
      var args, x$, this$ = this instanceof ctor$ ? this : new ctor$;
      args = slice$.call(arguments);
      BasicBlock.superclass.apply(this$, ['basic-block'].concat(slice$.call(args)));
      this$.hitSound = this$.game.add.audio('box-hit');
      this$.breakSound = this$.game.add.audio('box-break');
      x$ = this$.emitter = this$.game.add.emitter(0, 0, 20);
      x$.makeParticles('basic-block', [3, 4, 5]);
      x$.gravity = 200;
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.punched = function(fist){
      this.body.velocity.x += 200 * -fist.player.direction;
      this.body.velocity.y -= 100;
      if (this.takeDamage()) {
        return this.hitSound.play('', 0, 1, false);
      }
    };
    prototype.dead = function(){
      var x$;
      if (this.dying) {
        return;
      }
      this.dying = true;
      this.visible = false;
      this.body.enable = false;
      x$ = this.emitter;
      x$.maxParticleSpeed.setTo(100, 500);
      x$.maxRotation *= 2;
      x$.x = this.body.position.x + 32;
      x$.y = this.body.position.y + 32;
      x$.start(true, 500, null, 5);
      this.game.time.events.add(500, this.die, this);
      return this.breakSound.play('', 0, 1, false);
    };
    prototype.die = function(){
      this.emitter.destroy();
      return this.destroy();
    };
    return BasicBlock;
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
