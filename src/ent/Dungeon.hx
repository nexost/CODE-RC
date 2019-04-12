package ent;

import ent.Entity.ColType;
import h2d.Tile;
import hxd.Res;
import h2d.Bitmap;
import h2d.Text;
import ent.Floor.Type;
import h2d.Drawable;

class Dungeon extends Entity{
    var textFloor : Text;
    //public var container : Bitmap;
    public var floors : Array<Floor> = [];

    public var activeFloor : Int;

    public static var inst : Dungeon;

    var player : Player;

    public function new(){
        super(Dungeon, null);
        game = Game.inst;
        if(inst == null)
            inst = this;
        //container = new h2d.Bitmap(Tile.fromColor(0x202020, game.s2d.width, game.s2d.height));
        //game.layers.add(container, 0);
        buildFloors(0, 25);
        addPlayer();
        buildUIElements();
    }

    public function buildFloors(start:Int, end:Int):Dungeon{
        for (i in start...end){
            var f = new Floor(i, Floor.Type.DIRT_DARK);

            if(i==0)
                activeFloor = 0;

            floors.push(f);
        }

        return this;
    }

    public function buildUIElements(){
        textFloor = new Text(game.font);
        game.layers.add(textFloor, 1);
        textFloor.text = "Floor 1";
        textFloor.textColor = 0xFFFFFF;
        textFloor.x = game.s2d.width / 2;
        textFloor.textAlign = Align.Center;
        textFloor.setScale(3.0);
    }

    public function addPlayer(){
        var floorEntrance = getFloor(activeFloor).entrance;
        player = new Player(floorEntrance.x + floorEntrance.drw.getSize().width / 2, Floor.footing - 1);//new Player(Floor.tileWidth + (Floor.tilePx / 2), Floor.footing - 1);
        getFloor(0).middleground.addChild(player.spr);
        getFloor(0).children.push(player);
    }

    var floorTime = 0.0;
    override function update(dt:Float) {
        var difHeight = (player.spr.localToGlobal().y + game.s2d.y) - (game.s2d.y + ((Floor.tileHeight * game.scaling) * 1) + (player.spr.getFrame().height * game.scaling));

        if(difHeight > 0){
            var scrollSpeed = (difHeight / 50) + 5;

            moveUp(scrollSpeed * dt  * 100);
        }
        //Checking collisions
        //Events

        if(player.collides(ent.Entity.ColType.EVENT, "floorDoorExit").length  != 0){ //checkColOn(player.spr, "event", "floorDoorExit")){
            moveEntityToNextFloor(player);
            textFloor.text = "Floor " + activeFloor;
            //trace("floorTime " + floorTime);
            floorTime = 0.0;
        }
        else 
            floorTime += dt;
    }

    public function updatePos(){
        textFloor.x = game.s2d.width / 2;
        for(f in floors){
            f.container.setScale(game.scaling);
            //f.container.x = game.s2d.width / 2 - f.container.getSize().width / 2;
            f.x = (game.s2d.width / 2 - (f.container.tile.width * game.scaling) * 0.5);
            f.y = (f.id != 0 ? getFloor(f.id - 1).y + f.container.getSize().height : 0 + f.container.getSize().height * 2);
            //f.x = f.container.x;
            //f.y = f.container.y;
            /*if(game.scaling >= 1)
                f.container.y += 50 * game.scaling;
            else
                f.container.y -= 50 * game.scaling;*/
        }
    }

    public function moveUp(dy:Float){
        for(floor in floors){
            floor.y -= dy;
            if(floor.id == floors[floors.length - 1].id)
                trace("Last floor Y " + floor.y);
        }
    }

    public function moveEntityToNextFloor(entity:Entity){
        //entity.visible = false;
        var floorFrom = getFloor(activeFloor);
        floorFrom.middleground.removeChild(entity.drw);
        floorFrom.children.remove(entity);
        
        changeActiveFloor(activeFloor + 1);
        
        var floorTo = getFloor(activeFloor);
        floorTo.middleground.addChild(entity.drw);
        floorTo.children.push(entity);
        //entity.visible = true;

        /*game.s2d.removeChild(entity);
        game.s2d.addChild(entity);
        entity.x = floor.bmp.x;
        entity.y = floor.bmp.y - entity.getSize().height - 1;*/

        var floorEntrance = getFloor(activeFloor).entrance;
        
        if(entity.T == Player || entity.T == Npc)
            cast(entity, Character).stopFall();
        entity.x = floorEntrance.x + floorEntrance.drw.getSize().width / 2;
        entity.y = Floor.footing - 1;
    }

    public function changeActiveFloor(newActiveFloor:Int){
        var newFloor = getFloor(newActiveFloor);
        newFloor.colType = ColType.NONE;//"currentfloor";
        newFloor.active = true;
        var oldFloor = getFloor(activeFloor);
        oldFloor.colType = ColType.BLOCK;//"block:floor";
        oldFloor.colSubType = "floor";
        oldFloor.active = false;
        activeFloor = newActiveFloor;
        //trace("Floor " + activeFloor);

        if(activeFloor >= 10){
            deconstructFloor(activeFloor - 10);
            var lastFloorId = floors[floors.length - 1].id;
            buildFloors(lastFloorId + 1, lastFloorId + 2);
        }
    }

    public function deconstructFloor(ind:Int){
        var floor = getFloor(ind);
        floors.remove(floor);
        game.entities.remove(floor);
        for(o in floor.children)
            game.entities.remove(o);

        /*for(e in floor.characters)
            game.entities.remove(e);*/
        game.layers.removeChild(floor.container);
        //game.s2d.removeChild(floor.container);
    }

    public function getFloor(id:Int):Floor{
        for(f in floors){
            if(f.id == id)
                return f;
        }
        return null;
    }

    public static function destroy(){
        if(inst != null){
            inst.floors = null;
            inst.player = null;
            inst = null;
        }
    }
}