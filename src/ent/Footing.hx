package ent;

class Footing{
    private var tilePx : Int;

    public var y : Int;
    public var offset : Int;

    public function new(px:Int){
        tilePx = px;

        offset = Math.round(tilePx / 4);
        y = - tilePx + offset;
    }
}