package ent;

import ent.Entity.ColType;
import format.abc.Data.NamespaceSet;
import h2d.Anim;
import h2d.Tile;
import h2d.TileGroup;
import hxd.PixelFormat;
import hxd.Res;
import h2d.Drawable;
import h2d.Bitmap;

class Floor extends Entity{
    //private var game : Game;
    private var dungeon : Dungeon;
    public var id : Int;

    public var tiles : Array<Bitmap> = [];
    public var container : Bitmap;
    public var background : Bitmap;
    public var middlegroundMin : Bitmap;
    public var middleground : Bitmap;
    public var foreground : Bitmap;
    public var type : Floor.Type;
    public var entrance : Entity;
    public var exit : Entity;

    public var active : Bool;
    public var noOfEnemies : Int;

    public static var width : Int = 7;
    public static var scale : Float = 1.0;
    public static var tilePx : Int = 32;
    public static var tileWidth : Int = tilePx * 2;
    public static var tileHeight : Int = tilePx * 5;
    public static var footing : Int = - tilePx;
    
    public function new(id:Int, fType:Floor.Type){
        var containerTile = h2d.Tile.fromColor(0x000000, tileWidth * (width + 2), tileHeight, 0.0);
        var containerBmp = new h2d.Bitmap(containerTile);
        super(Floor, containerBmp, ColType.BLOCK, "floor");

        game = Game.inst;
        dungeon = Dungeon.inst;

        this.id = id;
        if(id == 0) active = true;
        else active = false;
        build(fType, containerBmp);
    }

    override function update(dt:Float){
        noOfEnemies = children.filter(f -> {f.T == Npc && f.colType == ColType.HOSTILE;}).length;
        if(exit != null && noOfEnemies > 0){
            exit.colType = ColType.NONE;
            exit.drw.alpha = 0.0;
        } 
        else {
            exit.colType = ColType.EVENT;
            exit.drw.alpha = 1.0;
        }
        if(active)
            entrance.drw.alpha = 1.0;
    }

    function build(fType:Floor.Type, containerBmp:Bitmap):Floor{
        //var dungCont = Dungeon.inst.container;
        //var realTileSize = tileSize * Math.round(scale);
        /*var containerTile = h2d.Tile.fromColor(0x000000, tileWidth * (width + 2), tileHeight, 0.0);
        var containerBmp = new h2d.Bitmap(containerTile);*/
        game.layers.add(containerBmp, 0);
        containerBmp.setScale(game.scaling);
        
        var containerWidth = Math.round(containerBmp.getSize().width);
        var containerHeight =  Math.round(containerBmp.getSize().height);

        //containerBmp.name = (id == 0 ? "currentfloor" : "block:floor");
        if(id == 0)
            colType = ColType.NONE;
        
        this.x = game.s2d.width * 0.5 - containerBmp.getSize().width * 0.5;
        var dungFloorsCount = dungeon.floors.length;
        this.y = (dungFloorsCount != 0 ? dungeon.floors[dungFloorsCount - 1].container.y + containerBmp.getSize().height : 0 + containerBmp.getSize().height * 2);
        //containerBmp.y = (id != 0 ? dungeon.getFloor(id - 1).container.y + (tileHeight * game.scaling) : 0 + (tileHeight * game.scaling) * 1.5);
        
        //trace("Building floor " + floorId + " at " + containerBmp.x + ", " + containerBmp.y);
        
        containerBmp.tile.dy = - containerBmp.tile.height;

        var backgroundTile = h2d.Tile.fromColor(0x000000, containerWidth, tileHeight, 0.0);
        var backgroundBmp = new h2d.Bitmap(backgroundTile, containerBmp);
        backgroundBmp.tile.dy = - backgroundBmp.tile.height;

        var middlegroundMinTile = h2d.Tile.fromColor(0x000000, containerWidth, tileHeight, 0.0);
        var middlegroundMinBmp = new h2d.Bitmap(middlegroundMinTile, containerBmp);
        middlegroundMinBmp.tile.dy = - middlegroundMinBmp.tile.height;

        var middlegroundTile = h2d.Tile.fromColor(0x000000, containerWidth, tileHeight, 0.0);
        var middlegroundBmp = new h2d.Bitmap(middlegroundTile, containerBmp);
        middlegroundBmp.tile.dy = - middlegroundBmp.tile.height;

        var foregroundTile = h2d.Tile.fromColor(0x000000, containerWidth, tileHeight, 0.0);
        var foregroundBmp = new h2d.Bitmap(foregroundTile, containerBmp);
        foregroundBmp.tile.dy = - foregroundBmp.tile.height;

        container = containerBmp;
        background = backgroundBmp;
        middlegroundMin = middlegroundMinBmp;
        middleground = middlegroundBmp;
        foreground = foregroundBmp;
        
        for(i in 0...width + 2){
            createTiles(i, fType);
        }

        type = fType;

        createDoors();
        spawnEnemies();

        return this;
    }

    function createTiles(i:Int, fType:Type){
        var floorTileColor = 0x000000;
        var floorTile = h2d.Tile.fromColor(floorTileColor, tileWidth, tileHeight);
        var groupTileBack = h2d.Tile.fromColor(floorTileColor, tileWidth, tileHeight);
        var groupTileGrounds : Array<Tile> = [];
        var groupTileGroundTops : Array<Tile> = [];
        var groupTileCeilings : Array<Tile> = [];
        var groupHeadTileTopCorners : Array<Tile> = [];
        var groupHeadTileTops : Array<Tile> = [];
        var groupHeadTileMidSides : Array<Tile> = [];
        var groupHeadTileBottoms : Array<Tile> = [];
        var groupHeadTileBottomCorners : Array<Tile> = [];
        var groupHeadTileFill : Array<Tile> = [];
        switch fType{
            case Floor.Type.TEST_RED:
                if(i%2 == 0)
                    floorTileColor = 0xFF0000;
                else
                    floorTileColor = 0xAA0000;
                groupTileBack = h2d.Tile.fromColor(floorTileColor, tilePx, tilePx);
            case Floor.Type.TEST_GREEN:
                if(i%2 == 0)
                    floorTileColor = 0x00AA00;
                else
                    floorTileColor = 0x00FF00;
                groupTileBack = h2d.Tile.fromColor(floorTileColor, tilePx, tilePx);
            case Floor.Type.DIRT_LIGHT:
                groupTileBack = Res.tile_cave_platform.toTile().grid(32)[0][0];
                //groupTileBack = h2d.Tile.fromColor(0x000000, tilePx, tilePx);
                //groupTileFrontTop = Res.dirtfronttop.toTile();
                //groupTileFrontBottom = Res.tile_cave_platform.toTile();//Res.dirtfrontbottom.toTile();
                groupTileCeilings.push(Res.tile_cave_platform.toTile().grid(32)[5][10]);//Res.dirtback.toTile();
                /*groupTileGrounds.push(Res.tile_cave_platform.toTile().grid(32)[5][2]);
                groupTileGroundTops.push(Res.tile_cave_platform.toTile().grid(32)[5][1]);*/

                groupTileGrounds.push(Res.tile_cave_platform.toTile().grid(32)[6][2]);
                groupTileGroundTops.push(Res.tile_cave_platform.toTile().grid(32)[6][1]);
            case Floor.Type.DIRT_DARK:
                groupTileBack = Res.FloorTileSet.toTile().grid(32)[1][1];
                groupHeadTileTopCorners.push(Res.FloorTileSet.toTile().grid(32)[0][0]);
                groupHeadTileTopCorners.push(Res.FloorTileSet.toTile().grid(32)[3][0]);
                groupHeadTileTops.push(Res.FloorTileSet.toTile().grid(32)[0][1]);
                groupHeadTileTops.push(Res.FloorTileSet.toTile().grid(32)[3][1]);
                groupHeadTileMidSides.push(Res.FloorTileSet.toTile().grid(32)[0][2]);
                groupHeadTileMidSides.push(Res.FloorTileSet.toTile().grid(32)[3][2]);
                groupHeadTileBottoms.push(Res.FloorTileSet.toTile().grid(32)[0][3]);
                groupHeadTileBottoms.push(Res.FloorTileSet.toTile().grid(32)[3][3]);
                groupHeadTileBottomCorners.push(Res.FloorTileSet.toTile().grid(32)[0][4]);
                groupHeadTileBottomCorners.push(Res.FloorTileSet.toTile().grid(32)[3][4]);
                groupHeadTileFill.push(Res.FloorTileSet.toTile().grid(32)[1][2]);


                groupTileCeilings.push(Res.FloorTileSet.toTile().grid(32)[1][0]);
                groupTileCeilings.push(Res.FloorTileSet.toTile().grid(32)[2][0]);
                groupTileGrounds.push(Res.FloorTileSet.toTile().grid(32)[1][4]);
                groupTileGrounds.push(Res.FloorTileSet.toTile().grid(32)[2][4]);
                groupTileGroundTops.push(Res.FloorTileSet.toTile().grid(32)[1][3]);
                groupTileGroundTops.push(Res.FloorTileSet.toTile().grid(32)[2][3]);
            default:
        }

        if(i == 0){
            createHeadTile(floorTile, groupTileBack, groupHeadTileFill, groupHeadTileTopCorners, groupHeadTileTops, groupHeadTileMidSides, groupHeadTileBottoms, groupHeadTileBottomCorners);
        } else if (i == width+1){
            //createTailTile();
            createTailTile(floorTile, groupTileBack, groupHeadTileFill, groupHeadTileTopCorners, groupHeadTileTops, groupHeadTileMidSides, groupHeadTileBottoms, groupHeadTileBottomCorners);
        } else {
            createGroundTile(i, floorTile, groupTileBack, groupTileCeilings, groupTileGrounds, groupTileGroundTops);
        }
        
    }

    function createHeadTile(floorTile:Tile, groupTileBack:Tile, groupHeadTileFill:Array<Tile>, groupHeadTileTopCorners:Array<Tile>, groupHeadTileTops:Array<Tile>, groupHeadTileMidSides:Array<Tile>, groupHeadTileBottoms:Array<Tile>, groupHeadTileBottomCorners:Array<Tile>){
        var headTile = h2d.Tile.fromColor(0x000000, tileWidth, tileHeight);
        var headTileBmp = new h2d.Bitmap(headTile, background);
        //headTileBmp.name = "block:wall";
        headTileBmp.tile.dy = - headTileBmp.tile.height;

        //var floorTileGroupBackBmp = new h2d.Bitmap(floorTile, background);
        var headTileFrontBmp = new h2d.Bitmap(Res.floortransparent.toTile(), background);
        headTileFrontBmp.x = 0;
        headTileFrontBmp.tile.dy = - headTileFrontBmp.tile.height;

        var mulJ = Math.round(tileWidth / groupTileBack.width);
        var mulH = Math.round(tileHeight / groupTileBack.width);
        for(j in 0...mulJ){
            for(h in 0...mulH){
                var floorTileBmp = new h2d.Bitmap(groupTileBack, headTileBmp);
                floorTileBmp.x = (j * groupTileBack.width);
                floorTileBmp.y = -(h * groupTileBack.height);
                floorTileBmp.tile.dy = - floorTileBmp.tile.height;

                var headTileBmp : Bitmap;
                if(j == mulJ - 1){
                    if(h == mulH - 1){
                        headTileBmp = new h2d.Bitmap(groupHeadTileTopCorners[0], headTileFrontBmp);
                    } else if(h == mulH - 2){
                        headTileBmp = new h2d.Bitmap(groupHeadTileTops[0], headTileFrontBmp);
                    } else if(h == 1){
                        headTileBmp = new h2d.Bitmap(groupHeadTileBottoms[0], headTileFrontBmp);
                    } else if(h == 0){
                        headTileBmp = new h2d.Bitmap(groupHeadTileBottomCorners[0], headTileFrontBmp);
                    } else {
                        headTileBmp = new h2d.Bitmap(groupHeadTileMidSides[0], headTileFrontBmp);
                    }
                } else {
                    headTileBmp = new h2d.Bitmap(groupHeadTileFill[0], headTileFrontBmp);
                }

                headTileBmp.x = (j * groupTileBack.width);
                headTileBmp.y = -(h * groupTileBack.height);
                headTileBmp.tile.dy = - floorTileBmp.tile.height;
            }
        }

        var headTileEntity = new Entity(Bitmap, headTileBmp, ColType.BLOCK, "wall");
        headTileEntity.noUpdate = true;
        this.addChild(headTileEntity);
    }

    function createGroundTile(i:Int, floorTile:Tile, groupTileBack:Tile, groupTileCeilings:Array<Tile>, groupTileGrounds:Array<Tile>, groupTileGroundTops:Array<Tile>){
        var floorTileGroupBackBmp = new h2d.Bitmap(floorTile, background);
        var floorTileGroupMidMinBmp = new h2d.Bitmap(Res.floortransparent.toTile(), middlegroundMin);
        var floorTileGroupFrontBmp = new h2d.Bitmap(Res.floortransparent.toTile(), background);
        //var mul = Math.round(tileSize / groupTileBack.width);
        var mulJ = Math.round(tileWidth / groupTileBack.width);
        var mulH = Math.round(tileHeight / groupTileBack.width);
        for(j in 0...mulJ){
            for(h in 0...mulH){
                var floorTileBmp;

                if(h == mulH - 1) {
                    var floorTileCeilingBmp = new h2d.Bitmap(groupTileCeilings[Std.random(groupTileCeilings.length)], floorTileGroupMidMinBmp);
                    floorTileCeilingBmp.x = (j * groupTileBack.width);
                    floorTileCeilingBmp.y = -(h * groupTileBack.height);
                    floorTileCeilingBmp.tile.dy = - floorTileCeilingBmp.tile.height;
                }
                if (h == 0) {

                    floorTileBmp = new h2d.Bitmap(groupTileGrounds[Std.random(groupTileGrounds.length)], floorTileGroupBackBmp);
                    floorTileBmp.name = "block:ground";
                    floorTileBmp.x = (j * groupTileBack.width);
                    floorTileBmp.y = -(h * groupTileBack.height);
                    floorTileBmp.tile.dy = - floorTileBmp.tile.height;
                    var floorTileEntity = new Entity(Bitmap, floorTileBmp, ColType.BLOCK, "ground");
                    floorTileEntity.noUpdate = true;
                    this.addChild(floorTileEntity);
                } else {
                    floorTileBmp = new h2d.Bitmap(groupTileBack, floorTileGroupBackBmp);
                }
                if (h == 1) {
                    var floorTileGroundTopBmp = new h2d.Bitmap(groupTileGroundTops[Std.random(groupTileGroundTops.length)], floorTileGroupMidMinBmp);
                    floorTileGroundTopBmp.x = (j * groupTileBack.width);
                    floorTileGroundTopBmp.y = -(h * groupTileBack.height);
                    floorTileGroundTopBmp.tile.dy = - floorTileGroundTopBmp.tile.height;
                }

                floorTileBmp.x = (j * groupTileBack.width);
                floorTileBmp.y = -(h * groupTileBack.height);
                floorTileBmp.tile.dy = - floorTileBmp.tile.height;
            }
        }
        floorTileGroupBackBmp.x = (i * tileWidth);
        floorTileGroupBackBmp.tile.dy = - floorTileGroupBackBmp.tile.height;
        floorTileGroupMidMinBmp.x = (i * tileWidth);
        floorTileGroupMidMinBmp.tile.dy = - floorTileGroupMidMinBmp.tile.height;
        floorTileGroupFrontBmp.x = (i * tileWidth);
        floorTileGroupFrontBmp.tile.dy = - floorTileGroupFrontBmp.tile.height;
    }

    function createTailTile(floorTile:Tile, groupTileBack:Tile, groupHeadTileFill:Array<Tile>, groupHeadTileTopCorners:Array<Tile>, groupHeadTileTops:Array<Tile>, groupHeadTileMidSides:Array<Tile>, groupHeadTileBottoms:Array<Tile>, groupHeadTileBottomCorners:Array<Tile>){
        var tailTile = h2d.Tile.fromColor(0x000000, tileWidth, tileHeight);
        var tailTileBmp = new h2d.Bitmap(tailTile, background);
        tailTileBmp.name = "block:wall";
        tailTileBmp.x = (width + 1) * tileWidth;
        tailTileBmp.y = 0;
        tailTileBmp.tile.dy = - tailTileBmp.tile.height;

        //var floorTileGroupBackBmp = new h2d.Bitmap(floorTile, background);
        var headTileFrontBmp = new h2d.Bitmap(Res.floortransparent.toTile(), background);
        headTileFrontBmp.x = (width + 1) * tileWidth;
        headTileFrontBmp.y = 0;
        headTileFrontBmp.tile.dy = - headTileFrontBmp.tile.height;

        var mulJ = Math.round(tileWidth / groupTileBack.width);
        var mulH = Math.round(tileHeight / groupTileBack.width);
        for(j in 0...mulJ){
            for(h in 0...mulH){
                var floorTileBmp = new h2d.Bitmap(groupTileBack, tailTileBmp);
                floorTileBmp.x = (j * groupTileBack.width);
                floorTileBmp.y = -(h * groupTileBack.height);
                floorTileBmp.tile.dy = - floorTileBmp.tile.height;

                var headTileBmp : Bitmap;
                if(j == 0){
                    if(h == mulH - 1){
                        headTileBmp = new h2d.Bitmap(groupHeadTileTopCorners[1], headTileFrontBmp);
                    } else if(h == mulH - 2){
                        headTileBmp = new h2d.Bitmap(groupHeadTileTops[1], headTileFrontBmp);
                    } else if(h == 1){
                        headTileBmp = new h2d.Bitmap(groupHeadTileBottoms[1], headTileFrontBmp);
                    } else if(h == 0){
                        headTileBmp = new h2d.Bitmap(groupHeadTileBottomCorners[1], headTileFrontBmp);
                    } else {
                        headTileBmp = new h2d.Bitmap(groupHeadTileMidSides[1], headTileFrontBmp);
                    }
                } else {
                    headTileBmp = new h2d.Bitmap(groupHeadTileFill[0], headTileFrontBmp);
                }

                headTileBmp.x = (j * groupTileBack.width);
                headTileBmp.y = -(h * groupTileBack.height);
                headTileBmp.tile.dy = - floorTileBmp.tile.height;
            }
        }

        var tailTileEntity = new Entity(Bitmap, tailTileBmp, ColType.BLOCK, "wall");
        tailTileEntity.noUpdate = true;
        this.addChild(tailTileEntity);
    }

    public function createDoors(){
        //var exitTile = Res.exit.toTile();
        var exitTile = h2d.Tile.fromColor(0xAAAAAA, tilePx, tilePx * 2);
        var exitBmp = new h2d.Bitmap(exitTile, background);
        //exitBmp.setScale(2.0);
        exitBmp.name = "event:floorDoorExit";
        exitBmp.x = exitBmp.tile.width * ((width + 1) * (tileWidth / exitBmp.tile.width)) - exitBmp.tile.width;//exitBmp.tile.width; //container.tile.width - 
        exitBmp.y = - tilePx;
        exitBmp.tile.dy = - exitBmp.tile.height;

        //exit = exitBmp;
        var exitEntity = new Entity(Bitmap, exitBmp, ColType.EVENT, "floorDoorExit");
        exitEntity.noUpdate = true;
        this.addChild(exitEntity);

        exit = exitEntity;

        var entranceTile = h2d.Tile.fromColor(0xAAAAAA, tilePx, tilePx * 2);
        var entranceBmp = new h2d.Bitmap(entranceTile, background);
        //entranceBmp.setScale(2.0);
        entranceBmp.name = "event:floorDoorEntrance";
        entranceBmp.x = tileWidth;
        entranceBmp.y = - tilePx;
        entranceBmp.tile.dy = - entranceBmp.tile.height;
        entranceBmp.alpha = 0.0;

        //entrance = entranceBmp;
        var entranceEntity = new Entity(Bitmap, entranceBmp, ColType.EVENT, "floorDoorEntrance");
        entranceEntity.noUpdate = true;
        this.addChild(entranceEntity);

        entrance = entranceEntity;
    }

    function spawnEnemies(){
        var a = Math.round((width - 2) * tileWidth / tilePx);
        noOfEnemies = 0;
        var enemies : Array<Npc> = [];
        for(i in 0...a + 0){
            var spawnEnemy = (Std.random(2) == 0 ? true : false);
            if(spawnEnemy){
                var milestone = Math.floor(this.id / 10) + 1;
                var hp = (((id + 1) * 100) + Std.random(Math.round(((id + 1) * 100)/2))) * Math.round((Math.pow(milestone, 2)));
                var enemy = new Npc(i * tilePx + (tileWidth * 2) + tilePx / 2, footing - 1, true, hp);
                enemy.x -= enemy.drw.getSize().width / 2;
                enemy.addTo(middleground);
                noOfEnemies += 1;
                enemies.push(enemy);
                this.addChild(enemy);
            }
        }
        if(noOfEnemies > 0){
            var enemiesMissing = (a - noOfEnemies);
            for(e in enemies){
                var hpToAdd = Math.round((e.currHp * enemiesMissing) / noOfEnemies);
                e.currHp += hpToAdd;
                e.maxHp += hpToAdd;
            }
        }
    }

}

enum Type{
    TEST_RED;
    TEST_GREEN;
    DIRT_LIGHT;
    DIRT_DARK;
}