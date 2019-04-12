package ent;

import Game.Axis;
import h2d.Drawable;

class Projectile extends Entity{

    public var strength : Float;
    var speedX : Float;
    var speedY : Float;
    
    public function new(drw:Drawable, speedX:Float, speedY:Float, strength:Float){
        super(Projectile, drw);
    }

    override function update(dt:Float){

    }

    override function move(axis:Axis, direction:Int, speed:Float):Bool{
        return false;
    }
}