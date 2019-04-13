package ent;

import Game.Axis;
import h2d.Anim;
import h2d.Tile;
import hxd.Res;

import hxd.Key in K;

class Player extends Character{

    public static var MOVE_SPEED = 100;
    public static var SPRINT_SPEED = 200;

    public var spr : Anim;

    public var level : Int;

    var moveSpeed : Int;
    var facing : Float;

    public function new(x:Float, y:Float){
        var tiles = new Array<Tile>();
        /*tiles.push(Res.mario.run1.toTile());
		tiles.push(Res.mario.run2.toTile());*/
        tiles.push(Res.Robot.toTile().grid(32)[0][0]);
        tiles.push(Res.Robot.toTile().grid(32)[1][0]);
        tiles.push(Res.Robot.toTile().grid(32)[2][0]);
        tiles.push(Res.Robot.toTile().grid(32)[3][0]);
        tiles.push(Res.Robot.toTile().grid(32)[4][0]);
        spr = new Anim(tiles, 10);
        spr.pause = true;
        
        
        level = 1;
        super(Player, spr, true);
        game.player = this;
        
        
        this.x = x;
        this.y = y;
        for(f in spr.frames){
            f.dx = 0;
            f.dy = - f.height;
        }
        facing = 1.0;
        //spr.setScale(1.0);
        jumpStr = MOVE_SPEED * 4;
    }

    override function update(dt:Float){
        super.update(dt);
        //Sprint key
        if(K.isDown(K.SHIFT)){
            moveSpeed = SPRINT_SPEED;
            spr.speed = 20;
        }
        else{
            moveSpeed = MOVE_SPEED;
            spr.speed = 10;
        }

        //Move keys
        if(K.isDown(K.A)){
            for(f in spr.frames)f.dx = -f.width;
            facing = -1.0;
            spr.pause = false;
            move(Axis.X, -1, (moveSpeed * dt));
        }
        if(K.isDown(K.D)){
            for(f in spr.frames)f.dx = 0;
            facing = 1.0;
            spr.pause = false;
            move(Axis.X, 1, (moveSpeed  * dt));
        }
        if(!K.isDown(K.D) && !K.isDown(K.A)){
            spr.play(spr.frames, 0);
            spr.pause = true;
        }

        //Attack key
        if(game.leftClicked()){
            var px = game.s2d.mouseX;
            var py = game.s2d.mouseY;
            trace("Attack at " + px + ", " + py);
        }

        var colHostile = collides(ent.Entity.ColType.HOSTILE);
        for(h in colHostile){
            if(h.T == Npc){
                cast(h, Npc).currHp -= level * 2;//(level * level) / 2;
            }
        }

        spr.scaleX = facing;
        /*spr.scaleX = (1.0 + (level / 100 <= 2.5 ? level / 100 : 2.5)) * facing;
        spr.scaleY = (1.0 + (level / 100 <= 2.5 ? level / 100 : 2.5));*/
        /*if(colHostile != null){
            //trace("Col on hostile " + Type.getClassName(colHostile.T));
            if(colHostile.T == Npc){
                cast(colHostile, Npc).currHp -= 0.5;
            }
            
        }*/
            //trace("Col on hostile");

        
    }

    override function jumped(){
        if(K.isDown(K.SPACE) && !hasJumped){
            //trace("Jumped!");
            hasJumped = true;
            return true;
        }
        else if(!K.isDown(K.SPACE))
            hasJumped = false;
        return false;
    }

    public function levelUp(){
        level += 1;
    }

}