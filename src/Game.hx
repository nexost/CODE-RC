import ent.Npc;
import ent.Player;
import h2d.Object;
import h2d.Tile;
import h2d.col.Point;
import h2d.Layers;
import ent.Dungeon;
import ent.Entity;
import h2d.Drawable;
import hxd.res.DefaultFont;
import h2d.Bitmap;
import h2d.Text;
import h2d.TextInput;
import hxd.Res;

import hxd.Key in K;

class Game extends hxd.App {

    public var font : h2d.Font;
    var textCollision : Text;
    var textMoveSpeed : Text;
    var inputMoveSpeed : h2d.TextInput;

    var baseSceneWidth : Int = Math.round(1280 * 0.65);
    var baseSceneHeight : Int = Math.round(720 * 0.65);
    var sceneWidth : Int;
    var sceneHeight : Int;
    public var scaling : Float;

    var playButton : Bitmap;
    var xButton : Bitmap;

    public var gameState : GameState;

    public var layers : Layers;

    public var entities : Array<ent.Entity> = [];
    public var player : Player;

    override function init() {
        sceneWidth = s2d.width; sceneHeight = s2d.height;
        updateScaling();
        trace("Scale " + scaling);
        
        Res.initEmbed();
        engine.backgroundColor = 0x202020;
        layers = new Layers(s2d);

        font = DefaultFont.get();
        //font.resizeTo(12);

        setState(GameState.MAIN_MENU);

        /*textCollision = new Text(font, s2d);
        textCollision.text = "Collision";
        textCollision.textColor = 0xFF0000;
        textCollision.x = s2d.width - textCollision.textWidth;
        textCollision.textAlign = Align.Center;
        textCollision.setScale(1.0);
        textCollision.visible = false;*/

        /*textMoveSpeed = new Text(font, s2d);
        textMoveSpeed.text = "Movement Speed: ";
        textMoveSpeed.textColor = 0xFFFFFF;

        inputMoveSpeed = new h2d.TextInput(font, s2d);
        inputMoveSpeed.backgroundColor = 0x80808080;
        inputMoveSpeed.inputWidth = 100;
        inputMoveSpeed.text = Std.string(moveSpeed);
        inputMoveSpeed.textColor = 0xFFFFFF;
        inputMoveSpeed.x = textMoveSpeed.getSize().width + 10;*/
        //inputMoveSpeed.onKeyDown = function(e){
            /*if(inputMoveSpeed.selectionRange != null){
                inputMoveSpeed.text = inputMoveSpeed.text.substr(0, inputMoveSpeed.selectionRange.start) + inputMoveSpeed.text.substr(inputMoveSpeed.selectionRange.start + inputMoveSpeed.selectionRange.length);
                inputMoveSpeed.cursorIndex = inputMoveSpeed.selectionRange.start;
                inputMoveSpeed.selectionRange = null;
            }
            inputMoveSpeed.text = inputMoveSpeed.text.substring(0, inputMoveSpeed.cursorIndex) + K.getKeyName(e.keyCode) + inputMoveSpeed.text.substr(inputMoveSpeed.cursorIndex);
            inputMoveSpeed.cursorIndex += 1;
            trace(e.keyCode);*/
        //}
    }

    function setState(state:GameState){
        reset();
        switch(state){
            case GameState.MAIN_MENU:
                gameState = GameState.MAIN_MENU;
                 createPlayButton();
            case GameState.DUNGEON:
                gameState = GameState.DUNGEON;
                new Dungeon();

                createXButton();
            default:
        }
        updateElementsPos();
    }

    function createPlayButton(){
        var tile = h2d.Tile.fromColor(0xe2bf2d, 100, 25);
        playButton = new h2d.Bitmap(tile, s2d);
        playButton.tile.dx = - playButton.tile.width / 2;
        playButton.tile.dy = - playButton.tile.height / 2;

        var textPlayButton = new Text(font, playButton);
        textPlayButton.text = "PLAY";
        textPlayButton.textColor = 0x000000;
        textPlayButton.setScale(2.0);
        textPlayButton.y =  - (textPlayButton.getSize().height / 2) - 4;
        textPlayButton.textAlign = Align.Center;
    }

    function createXButton(){
        var tile = h2d.Tile.fromColor(0xe2bf2d, 20, 20);
        xButton = new h2d.Bitmap(tile);
        layers.add(xButton, 1);

        var textXButton = new Text(font, xButton);
        textXButton.text = "X";
        textXButton.textColor = 0x000000;
        textXButton.setScale(1.5);
        textXButton.x = (xButton.getSize().width / 2) + 1;// + textXButton.getSize().width / 2;
        textXButton.y = - (xButton.getSize().width / 2) + textXButton.getSize().height / 2 - 1;
        textXButton.textAlign = Align.Center;
    }

    function updateElementsPos(){
        if(playButton != null){
            playButton.setScale(scaling);
            playButton.x = s2d.width * 0.5;
            playButton.y = s2d.height * 0.5;
        }
        if(xButton != null){
            xButton.setScale(scaling);
            xButton.x = s2d.width - xButton.getSize().width - 5;
            xButton.y = 5;
        }

        
    }

    public function reset(){
        Dungeon.destroy();
        s2d.removeChildren();
        layers = null;
        entities = [];
        layers = new Layers(s2d);
    }

    override function update(dt:Float) {
        if(s2d.width != sceneWidth || s2d.height != sceneHeight){
            sceneWidth = s2d.width; sceneHeight = s2d.height;
            //trace("Scene size " + s2d.width + " x " + s2d.height);
            trace("Scale " + scaling);
            updateScaling();
            //trace("Scene size " + s2d.width + " x " + s2d.height + " || 16x9 Size " + stnRW + " x " + stnRH);
            updateElementsPos();
            if(Dungeon.inst != null)
                Dungeon.inst.updatePos();
        }
        
        switch(gameState){
            case GameState.MAIN_MENU:
                if(playButton.getBounds().contains(new Point(s2d.mouseX, s2d.mouseY))){
                    playButton.tile.switchTexture(Tile.fromColor(0xF7DE76, 100, 25));
                    if(leftClicked())
                        setState(GameState.DUNGEON);
                }
                else 
                    playButton.tile.switchTexture(Tile.fromColor(0xe2bf2d, 100, 25)); // 0xF4D142
            case GameState.DUNGEON:
                if(xButton.getBounds().contains(new Point(s2d.mouseX, s2d.mouseY))){
                    xButton.tile.switchTexture(Tile.fromColor(0xF7DE76, 20, 20));
                    if(leftClicked())
                        setState(GameState.MAIN_MENU);
                }
                else 
                    xButton.tile.switchTexture(Tile.fromColor(0xe2bf2d, 20, 20)); // 0xF4D142
            default:
        }

        var updEnts = entities.filter(f -> {!f.noUpdate;});
        for(e in updEnts)
            e.update(dt);
    }

    function updateScaling(){
        var stnRW = sceneWidth * 1.0;
        var stnRH = (stnRW * 9) / 16;
        if(stnRH >= sceneHeight){
            stnRH = sceneHeight;
            stnRW = (stnRH * 16) / 9;
        }
        scaling = (stnRW / baseSceneWidth) * 1.2;
    }

    var mouseLeftClicked = false;
    public function leftClicked():Bool{
        if(K.isDown(K.MOUSE_LEFT) && !mouseLeftClicked){
            mouseLeftClicked = true;
            return true;
        }
        else if(!K.isDown(K.MOUSE_LEFT))
            mouseLeftClicked = false;
        return false;
    }
    
    function getKeyName(id) {
		var name = hxd.Key.getKeyName(id);
		if( name == null ) name = "#"+id;
		return name;
	}

    public static var inst : Game;

    static function main() {
        inst = new Game();
    }
}

enum Axis {
    X;
    Y;
}

enum GameState{
    MAIN_MENU;
    DUNGEON;
}
