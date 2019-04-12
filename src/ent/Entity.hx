package ent;

import h2d.col.Bounds;
import h2d.Drawable;
import Game.Axis;
import h2d.Anim;

import hxd.Key in K;

class Entity{

    //public var id : Guid;
    public var T : Any;
    public var colType : ColType;
    public var colSubType : String;

    public var name : String;
    public var x(default, set) : Float;
    public var y(default, set) : Float;
    public var drw : Drawable;
    public var parent : Entity;
    public var children : Array<Entity> = [];
    public var noUpdate : Bool;

    var game : Game;

    function set_x(newX) {
        drw.x = newX;
        return x = newX;
    }
    function set_y(newY) {
        drw.y = newY;
        return y = newY;
    }

    function new(type:Any, drw:Drawable, ?colType:ColType, ?colSubType:String) {
        this.T = type;
        this.drw = drw;
        if(drw != null && (x == null || y == null)){
            this.x = drw.x;
            this.y = drw.y;
        }
        this.colType = colType;
        this.colSubType = colSubType;
        noUpdate = false;

		game = Game.inst;
		game.entities.push(this);
	}

    
    public function update( dt : Float ) {
        /*if(drw != null){
            drw.x = x;
            drw.y = y;
        }*/
	}

    public function addChild(child:Entity){
        this.children.push(child);
        child.parent = this;
    }

    var collided = false;
    function move(axis:Axis, direction:Int, speed:Float):Bool{
        var playerMoved = false;
        //speed = speed * game.scaling;/// game.scaling;//Floor.scale;
        var m = speed * direction;
        if(axis == Axis.X) {
            if(collidesAt(m, 0, ColType.BLOCK).length == 0){//!checkCol(drw, speed, 0, direction)){
                x += m;
                playerMoved = true;
                collided = false;
            } else if(!collided) {
                var colSpeed = m / 2;
                var moved = false;
                while(!moved){
                    if(collidesAt(colSpeed, 0, ColType.BLOCK).length != 0){//checkCol(drw, colSpeed, 0, direction)){
                        if(colSpeed <= 2){
                            moved = true;
                            collided = true;
                        }
                        else
                            colSpeed = colSpeed / 2;
                    } else {
                        x += colSpeed;
                        playerMoved = true;
                        moved = true;
                    }
                }
            }
        }
        if(axis == Axis.Y){
            if(collidesAt(0, m, ColType.BLOCK).length == 0){//!checkCol(drw, 0, speed, direction)){
                y += m;
                playerMoved = true;
                collided = false;
            } else if(!collided) {
                var colSpeed = m / 2;
                var moved = false;
                while(!moved){
                    if(collidesAt(0, colSpeed, ColType.BLOCK).length != 0){//checkCol(drw, 0, colSpeed, direction)){
                        if(colSpeed <= 2){
                            moved = true;
                            collided = true;
                        }
                        else
                            colSpeed = colSpeed / 2;
                    }
                    else {
                        y += colSpeed;
                        playerMoved = true;
                        moved = true;
                    }
                }
            }
        }
        return playerMoved;
    }

    function collidesAt(x:Float, y:Float, type:ColType, ?subType:String):Array<Entity>{
        x = x * game.scaling;
        y = y * game.scaling;
        var bounds = drw.getBounds();
        bounds.x += x;
        bounds.y += y;


        return collides(type, subType, bounds);
    }

    function collides(type:ColType, ?subType:String, ?bounds:Bounds):Array<Entity>{
        if(bounds == null)
            bounds = drw.getBounds();
        var objs : Array<Entity> = game.entities.filter(f -> {
            (f.colType == type);
        });//Array<Drawable> = game.colObjs;
        
        //var colEntity : Entity = null;
        var colEntities : Array<Entity> = [];
        for(o in objs){
            if(o.colType != null && o.colType == type && (subType == null ? true : o.colSubType == subType)){ //if(o.name != null && o.name.indexOf(type) != -1 && (subType == null ? true : o.name.indexOf(subType) != -1)){
                var oBounds = o.drw.getBounds();
                if(bounds.intersects(oBounds)){
                    //colEntity = o;
                    colEntities.push(o);
                    //break;
                }
            }
        }
        return colEntities;
    }
}

enum ColType{
    NONE;
    BLOCK;
    EVENT;
    HOSTILE;
    ALLY;
}