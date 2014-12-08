// Generated by LiveScript 1.3.0
(function(){
  var TutorialZBlock, TutorialDBlock, slice$ = [].slice;
  this.TutorialZBlock = TutorialZBlock = (function(superclass){
    var prototype = extend$((import$(TutorialZBlock, superclass).displayName = 'TutorialZBlock', TutorialZBlock), superclass).prototype, constructor = TutorialZBlock;
    prototype.damageFrames = 3;
    prototype.scoreWorth = 1;
    function TutorialZBlock(){
      var args, this$ = this instanceof ctor$ ? this : new ctor$;
      args = slice$.call(arguments);
      TutorialZBlock.superclass.apply(this$, ['noob-z-block'].concat(slice$.call(args)));
      this$.hitSound = this$.game.add.audio('box-hit');
      this$.breakSound = this$.game.add.audio('box-break');
      this$.emitter = this$.deathEmitter([3, 4, 5]);
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.die = function(){
      superclass.prototype.die.call(this);
      return this.afterDie();
    };
    return TutorialZBlock;
  }(Block));
  this.TutorialDBlock = TutorialDBlock = (function(superclass){
    var prototype = extend$((import$(TutorialDBlock, superclass).displayName = 'TutorialDBlock', TutorialDBlock), superclass).prototype, constructor = TutorialDBlock;
    prototype.damageFrames = 4;
    prototype.scoreWorth = 1;
    function TutorialDBlock(){
      var args, this$ = this instanceof ctor$ ? this : new ctor$;
      args = slice$.call(arguments);
      TutorialDBlock.superclass.apply(this$, ['noob-d-block'].concat(slice$.call(args)));
      this$.hitSound = this$.game.add.audio('box-hit');
      this$.breakSound = this$.game.add.audio('box-break');
      this$.emitter = this$.deathEmitter([4, 5, 6]);
      return this$;
    } function ctor$(){} ctor$.prototype = prototype;
    prototype.die = function(){
      superclass.prototype.die.call(this);
      return this.afterDie();
    };
    return TutorialDBlock;
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
