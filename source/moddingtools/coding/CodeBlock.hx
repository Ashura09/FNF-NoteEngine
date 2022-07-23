package moddingtools.coding;

import flixel.FlxSprite;

class Block extends FlxSprite {
    var inputPins:Array<Pin> = [];
    var outputPins:Array<Pin> = [];
    var blockName:String = "";

    public function new(xPos:Int, yPos:Int) {
        loadGraphic('assets/images/moddingtools/code_block.png');
        x = xPos;
        y = yPos;
        super();
    }
}

class Pin extends FlxSprite {
    var pinName:String = "";
}