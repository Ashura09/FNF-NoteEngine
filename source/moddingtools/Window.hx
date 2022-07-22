package moddingtools;

import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxG;

class Window extends FlxSprite {

    public function new(x:Int, y:Int, width:Int, height:Int) {
        super();

        loadGraphic("assets/images/moddingtools/window.png");
        antialiasing = false;
        scale = new FlxPoint(8,8);  
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}