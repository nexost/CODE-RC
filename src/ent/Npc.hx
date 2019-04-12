package ent;

import Game.Axis;
import ent.Entity.ColType;
import h2d.Drawable;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;

class Npc extends Character{

    private static var MOVE_SPEED = 100;

    public var type : Type;
    public var hostile : Bool;
    public var currHp : Float;
    public var maxHp : Int;

    public var spr : Bitmap;
    public var back : Bitmap;

    var textHp : Text;

    public function new(x:Float, y:Float, hostile:Bool, ?hp:Int){
        var tile = Tile.fromColor((hostile? 0x550000 : 0x00FF00), 16, 16);
        spr = new Bitmap(tile);
        super(Npc, spr, false, (hostile ? ColType.HOSTILE : ColType.ALLY), "npc");

        spr.name = "hostile:npc";
        this.x = x;
        this.y = y;
        spr.tile.dx = 0;
        spr.tile.dy = - spr.tile.height;
        this.hostile = hostile;
        

        if(hp != null && hp != 0){
            this.currHp = hp;
            this.maxHp = hp;
            createHpLabel();
        }
    }

    public function addTo(parent:Drawable){
        parent.addChild(spr);
        parent.addChild(back);
    }

    function createHpLabel(){
        textHp = new Text(Game.inst.font);
        //textHp.setScale(0.5);
        
        textHp.text = Math.round(currHp) + " / " + maxHp;
        textHp.textColor = 0xFFFFFF;
        //textHp = textHp.getSize() / 2;
        textHp.x = textHp.textWidth / 2;
        textHp.y =  0;
        textHp.textAlign = Align.Center;
        

        back = new Bitmap(Tile.fromColor(0x000000, Math.round(textHp.textWidth), Math.round(textHp.textHeight)));
        back.setScale(0.5);
        
        /*back.x = (spr.tile.width / 2) - (back.tile.width / 4);
        back.y =  - ((spr.tile.height / 2) + textHp.textHeight + 2);*/
        

        //sprUI.addChild(back);
        back.addChild(textHp);
        //spr.addChild(back);
    }

    override function update( dt : Float ) {
        super.update(dt);
        back.x = x + (spr.tile.width / 2) - (back.tile.width / 4);
        back.y = y - ((spr.tile.height / 2) + back.tile.height + 2);

        var playerEntities = parent.children.filter(f -> {f.T == Player;});
        if(playerEntities.length > 0){
            spr.tile.switchTexture(Tile.fromColor((hostile? 0xFF0000 : 0x00FF00), 16, 16));
            chase(playerEntities[0], MOVE_SPEED * dt);
        }

        updateHpText();
	}

    function updateHpText(){
        if(textHp != null)
            textHp.text = Math.round(currHp) + " / " + maxHp;
        if(currHp <= 0)
            kill();
    }

    function chase(entity:Entity, speed:Float){
        if(entity.x + entity.drw.getSize().width < this.x){ // move left
            move(Axis.X, -1, speed);
        } else if(this.x + this.drw.getSize().width < entity.x){ // move right
            move(Axis.X, 1, speed);
        }
    }

    public function kill(){
        game.player.levelUp();
        spr.remove();
        back.remove();
        drw.remove();
        this.parent.children.remove(this);
        game.entities.remove(this);
    }

}

enum NpcType{
    ENEMY;
    ALLY;
}