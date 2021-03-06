// Generated by LiveScript 1.3.0
(function(){
  var ref$, each, all, map, GameCore;
  ref$ = require('prelude-ls'), each = ref$.each, all = ref$.all, map = ref$.map;
  this.GameCore = GameCore = (function(){
    GameCore.displayName = 'GameCore';
    var prototype = GameCore.prototype, constructor = GameCore;
    GameCore.doneTutorial = false;
    function GameCore(game){
      this.game = game;
    }
    prototype.preload = function(){
      var asset, x$;
      asset = function(p){
        return "game/assets/" + p;
      };
      x$ = this.game.load;
      x$.spritesheet('breaker', asset('breaker.png'), 64, 64);
      x$.image('basic-tile', asset('better-basic-tile.png'));
      x$.image('bg', asset('bg.png'));
      x$.image('block-hole', asset('block-hole.png'));
      x$.spritesheet('stars', asset('stars.png'), 8, 8);
      x$.spritesheet('explosion', asset('explosion.png'), 192, 192);
      x$.spritesheet('power-up', asset('power-up.png'), 32, 32);
      x$.tilemap('map', asset('map/basic-map.json'), null, Phaser.Tilemap.TILED_JSON);
      x$.image('smoke', asset('smoke-cloud.png'));
      x$.audio('punch-sound', asset('sounds/punch.ogg'));
      x$.audio('dead-sound', asset('sounds/dead.ogg'));
      x$.audio('box-hit', asset('sounds/box-hit.ogg'));
      x$.audio('box-break', asset('sounds/box-break.ogg'));
      x$.audio('box-shoot', asset('sounds/bullet-shoot.ogg'));
      x$.audio('chest-hit', asset('sounds/chest-hit.ogg'));
      x$.audio('chest-break', asset('sounds/chest-break.ogg'));
      x$.audio('boom', asset('sounds/explosion.ogg'));
      x$.audio('beep', asset('sounds/beep.ogg'));
      x$.audio('charge-up', asset('sounds/charge-up.wav'));
      x$.audio('charge-down', asset('sounds/charge-down.wav'));
      x$.audio('blast-off', asset('sounds/blast-off.wav'));
      x$.audio('steel-hit', asset('sounds/steel-hit.wav'));
      x$.audio('steel-break', asset('sounds/steel-break.wav'));
      x$.audio('bh-sound', asset('sounds/block-hole-sound.ogg'));
      x$.audio('bgm', asset('bgm.ogg'));
      x$.audio('tut-bgm', asset('tutorial.ogg'));
      x$.spritesheet('basic-block', asset('blocks/basic.png'), 64, 64);
      x$.spritesheet('bullet-block', asset('blocks/bullet.png'), 64, 64);
      x$.spritesheet('tnt-block', asset('blocks/tnt.png'), 64, 64);
      x$.spritesheet('chest-block', asset('blocks/chest.png'), 64, 64);
      x$.spritesheet('steel-block', asset('blocks/steel.png'), 64, 64);
      x$.spritesheet('noob-z-block', asset('blocks/noob-z.png'), 64, 64);
      x$.spritesheet('noob-d-block', asset('blocks/noob-d.png'), 64, 64);
    };
    prototype.create = function(){
      (function(add, physics, world, camera){
        var x$, y$, map, z$, z1$, e;
        this.deathSound = add.audio('dead-sound');
        this.blockHoleSound = add.audio('bh-sound');
        this.bgm = add.audio('bgm');
        this.tut = add.audio('tut-bgm');
        if (constructor.doneTutorial) {
          this.bgm.play('', 0, 1, true);
        } else {
          this.tut.play('', 0, 1, true);
        }
        this.game.stage.backgroundColor = '#1B03E38';
        x$ = this.stars = add.emitter(this.game.world.centerX, 200, 200);
        x$.width = 800;
        x$.makeParticles('stars', [0, 1, 2, 3, 4, 5, 6]);
        x$.minParticleSpeed.set(0, 0);
        x$.maxParticleSpeed.set(0, 400);
        x$.y = 0;
        if (constructor.doneTutorial) {
          this.stars.start(false, 3000, 80);
        }
        add.image(0, 0, 'bg');
        this.game.time.advancedTiming = true;
        physics.startSystem(Phaser.Physics.Arcade);
        physics.arcade.TILE_BIAS = 32;
        physics.arcade.OVERLAP_BIAS = 16;
        y$ = map = add.tilemap('map');
        y$.addTilesetImage('basic', 'basic-tile');
        y$.setCollision(1);
        z$ = this.layer = map.createLayer('Tile Layer 1');
        z$.resizeWorld();
        this.arrowKeys = this.game.input.keyboard.createCursorKeys();
        this.punchKey = this.game.input.keyboard.addKey(Phaser.Keyboard.Z);
        this.specialKey = this.game.input.keyboard.addKey(Phaser.Keyboard.X);
        z1$ = this.player = add.existing(new Player(this.game, this, 400, 500));
        z1$.keys = this.arrowKeys;
        z1$.punchKey = this.punchKey;
        z1$.specialKey = this.specialKey;
        z1$.initializeSmoke();
        this.spawnedBlockHole = false;
        this.blockHoleTimer = 0.0;
        this.blockHoleScore = 50;
        this.blocks = add.group();
        this.powerUps = add.group();
        this.blockInterval = 2;
        this.blockTimer = this.blockInterval;
        this.chestBlockIn = 5;
        try {
          if (this.highScore && localStorage) {
            localStorage.ldBreakerHighScore = this.highScore;
          }
          if (localStorage) {
            this.highScore = localStorage.ldBreakerHighScore || 0;
          }
        } catch (e$) {
          e = e$;
        }
        this.scoreText = add.text(40, 5, this.scoreStr(), {
          font: '24px Arial',
          fill: '#000000',
          align: 'left'
        });
        if (!constructor.doneTutorial) {
          this.startTutorial();
        }
      }.call(this, this.game.add, this.game.physics, this.game.world, this.game.camera));
    };
    prototype.scoreStr = function(){
      var str;
      str = "Score: " + this.player.score;
      if (this.highScore) {
        return "High Score: " + this.highScore + "\n" + str;
      } else {
        return str;
      }
    };
    prototype.score = function(){
      if (this.player.score > this.highScore) {
        this.highScore = this.player.score;
      }
      this.scoreText.text = this.scoreStr();
      if (this.player.score >= this.blockHoleScore && !this.spawnedBlockHole) {
        return this.spawnBlockHole();
      }
    };
    prototype.spawnBlockHole = function(){
      var x$;
      this.blockHoleSound.play('', 0, 0.5, false);
      this.blockHoleTimer = 10.0;
      x$ = this.blockHole = this.game.add.sprite(400, 200, 'block-hole');
      x$.anchor.setTo(0.5, 0.5);
      x$.x = 100;
      x$.y = 400;
      x$.update = function(){
        return this.rotation += 6 * this.game.time.physicsElapsed;
      };
      return this.spawnedBlockHole = true;
    };
    prototype.addPowerUp = function(type, x, y){
      return this.powerUps.add(new type(this.game, this, x, y));
    };
    prototype.addBlock = function(type, x, y){
      return this.blocks.add(new type(this.game, this, x, y));
    };
    prototype.punch = function(fist){
      var x$;
      x$ = this.game.physics.arcade;
      x$.collide(fist, this.blocks, null, function(_, block){
        if (block.punched) {
          block.punched(fist, fist.player.spinning() ? 2 : 1);
        }
        return false;
      });
    };
    prototype.update = function(){
      var plrBlkCollide, x$, y$, delta, chest, this$ = this;
      if (!this.player.dying) {
        plrBlkCollide = function(plr, blck){
          if (blck.onCollide) {
            blck.onCollide(plr);
          }
          return plr.onCollide(blck);
        };
        x$ = this.game.physics.arcade;
        x$.collide(this.player, this.layer);
        x$.collide(this.player, this.blocks, plrBlkCollide, this.player.blockCollideTest, x$.collide(this.player, this.powerUps, null, function(plr, pwr){
          pwr.pickedUp(plr);
          return false;
        }));
      }
      y$ = this.game.physics.arcade;
      y$.collide(this.blocks, this.layer, null, function(b, l){
        if (b.testLayerCollision) {
          return b.testLayerCollision(l);
        } else {
          return b.isBlock;
        }
      });
      y$.collide(this.blocks, this.blocks, function(b1, b2){
        if (b1.onBlockCollide) {
          b1.onBlockCollide(b2);
        }
        if (b2.onBlockCollide) {
          return b2.onBlockCollide(b1);
        }
      });
      delta = this.game.time.physicsElapsed;
      this.blockTimer -= delta;
      if (!constructor.doneTutorial) {
        return;
      }
      if (this.blockTimer <= 0) {
        this.chestBlockIn -= 1;
        chest = null;
        if (this.chestBlockIn <= 0) {
          chest = ChestBlock;
          this.chestBlockIn = 20;
        }
        this.generateBlock(this.game.rnd, chest);
        this.blockTimer = this.blockInterval;
        if (!(this.blockTimer <= 0.7)) {
          this.blockInterval *= 0.85;
        } else if (this.blockInterval > 0.5) {
          this.blockInterval -= 0.001;
        }
      }
      if (this.blockHoleTimer > 0) {
        this.blockHoleTimer -= delta;
        this.blockHole.x += 50 * delta;
        this.blocks.forEach(function(block){
          var yDist, xDist, dist, angle;
          yDist = this$.blockHole.y - block.y;
          xDist = this$.blockHole.x - block.x;
          dist = Math.sqrt(Math.pow(xDist, 2) + Math.pow(yDist, 2));
          angle = Math.atan2(yDist, xDist);
          angle -= 1;
          block.body.velocity.y = dist * 2 * Math.sin(angle);
          return block.body.velocity.x = dist * 2 * Math.cos(angle);
        });
      } else if (this.blockHole) {
        this.blockHole.destroy();
        this.blockHole = undefined;
        this.spawnedBlockHole = false;
        this.blockHoleScore = this.player.score + 60;
      }
    };
    prototype.completeTutorial = function(){
      this.tut.stop();
      this.bgm.play('', 0, 1, true);
      constructor.doneTutorial = true;
      return this.stars.start(false, 3000, 80);
    };
    prototype.startTutorial = function(){
      var x$, this$ = this;
      x$ = this.tutZBlock = this.addBlock(TutorialZBlock, 64 * 1, 0);
      x$.afterDie = function(){
        return this$.game.time.events.add(1000, this$.tutSpawnDodgeBlock, this$);
      };
      return x$;
    };
    prototype.tutSpawnDodgeBlock = function(){
      var decBlockCount, x$, this$ = this;
      this.blockCount = 7;
      decBlockCount = function(){
        var x$;
        this$.blockCount -= 1;
        if (this$.blockCount <= 0) {
          x$ = this$.game.add.tween(this$.tut);
          x$.to({
            volume: 0
          }, 500, Phaser.Easing.Linear.None, true, 0, 0, false);
          x$.onComplete.add(this$.completeTutorial, this$);
          x$.start();
          return x$;
        }
      };
      x$ = this.tutDBlock = this.addBlock(TutorialDBlock, 64 * 1, 0);
      x$.afterDie = decBlockCount;
      return this.game.time.events.add(2000, function(){
        var i$, i, x$, results$ = [];
        for (i$ = 2; i$ <= 7; ++i$) {
          i = i$;
          x$ = this$.addBlock(TutorialZBlock, 64 * i, 0);
          x$.afterDie = decBlockCount;
          results$.push(x$);
        }
        return results$;
      });
    };
    prototype.generateBlock = function(rnd, useThisOne){
      var possibleBlocks, blockIndex, nextBlockX, block, chance;
      possibleBlocks = [BasicBlock, BulletBlock, TntBlock, SteelBlock];
      blockIndex = rnd.integerInRange(0, possibleBlocks.length - 1);
      nextBlockX = rnd.integerInRange(1, 800 / 64 - 2);
      block = useThisOne || possibleBlocks[blockIndex];
      if (block.rerollChance) {
        chance = rnd.integerInRange(0, 100);
        if (chance < block.rerollChance) {
          return this.generateBlock(rnd);
        }
      }
      return this.addBlock(block, nextBlockX * 64, 0);
    };
    prototype.render = function(){};
    return GameCore;
  }());
}).call(this);
