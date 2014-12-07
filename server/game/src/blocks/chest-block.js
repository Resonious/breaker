// Generated by LiveScript 1.3.0
(function(){
  var ChestBlock, slice$ = [].slice;
  this.ChestBlock = ChestBlock = (function(superclass){
    var prototype = extend$((import$(ChestBlock, superclass).displayName = 'ChestBlock', ChestBlock), superclass).prototype, constructor = ChestBlock;
    prototype.damageFrames = 4;
    prototype.scoreWorth = 50;
    function ChestBlock(){
      var args, this$ = this instanceof ctor$ ? this : new ctor$;
      args = slice$.call(arguments);
      ChestBlock.superclass.apply(this$, ['chest-block'].concat(slice$.call(args)));
      this$.hitSound = this$.game.add.audio('chest-hit');
      this$.breakSound = this$.game.add.audio('chest-break');
      this$.emitter = this$.deathEmitter([4, 5]);
      this$.health = 20;
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.takeDamage = function(dmg){
      if (this.dying) {
        return;
      }
      this.health -= dmg || 1;
      this.animations.frame = (function(){
        switch (false) {
        case !(this.health > 15):
          return 0;
        case !(this.health > 10):
          return 1;
        case !(this.health > 5):
          return 2;
        default:
          return 3;
        }
      }.call(this));
      if (this.health <= 0) {
        if (this.dead) {
          this.dead();
        }
        return false;
      } else {
        return true;
      }
    };
    prototype.testLayerCollision = function(layer){
      if (this.body.blocked.left) {
        this.body.velocity.x += 100;
      } else if (this.body.blocked.right) {
        this.body.velocity.x -= 100;
      }
      return true;
    };
    prototype.dead = function(){
      superclass.prototype.dead.call(this);
      return this.core.addPowerUp(PowerUp, this.x, this.y);
    };
    return ChestBlock;
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
