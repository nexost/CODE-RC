package ent;

import Game.Axis;
import ent.Entity.ColType;
import h2d.Drawable;

class Character extends Entity{

    var gravAffected : Bool;
    var jumpStr : Int;

    private function new(type:Any, drw:Drawable, ?gravAffected:Bool, ?colType:ColType, ?colSubType:String) {
        super(type, drw, colType, colSubType);
        if(gravAffected != null)
            this.gravAffected = gravAffected;
        else 
            this.gravAffected = false;

		//game = Game.inst;
		//game.entities.push(this);
        
        jumpStr = 0;
	}


    public var velocityY = 0.0;
    var g = 2000;
    override function update( dt : Float ) {
        super.update(dt);
        if(gravAffected){
            
            if(move(Axis.Y, -1, ((velocityY * dt))))
                velocityY -= g * dt;
            else {
                if(jumped())
                    velocityY = jumpStr;
                else {
                    velocityY = 0.0;
                    hasJumped = false;
                }
            }
        }
	}

    var hasJumped = false;
    public function jumped():Bool{
        return false;
    }

    public function stopFall(){
        velocityY = 0.0;
    }

}