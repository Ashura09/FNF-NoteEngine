package moddingtools;

import openfl.ui.Mouse;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.FlxUI;

class ModdingDesktop extends FlxState {
    var bg:FlxSprite;

    override public function create() {
        Mouse.show();
        bg = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromInt(Palette.TEAL));

        var window:Window;
        window = new Window(16, 16, 256, 256);

        add(bg);
        add(window);

        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}