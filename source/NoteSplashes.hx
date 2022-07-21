package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
    public var splashData:Int;
    public static var isPixel:Bool = false;

    public function new(X:Float = 0, Y:Float = 0, pixel:Bool = false) {
        super();

        scale.set(0.5, 0.5);
        updateHitbox();
        x = X;
        y = Y;
        offset.x = 175;
        offset.y = 156;
        
        if (isPixel) {
            frames = FlxAtlasFrames.fromSparrow('assets/images/hud/notes/splashes-pixel.png', 'assets/images/hud/notes/splashes-pixel.xml');
            // offset.x = -48;
            // offset.y = -16;
            antialiasing = false;
            // scale.set(5, 5);
            animation.addByPrefix('purple', 'PurpleSplash', 12, false);
            animation.addByPrefix('blue', 'BlueSplash', 12, false);
            animation.addByPrefix('green', 'GreenSplash', 12, false);
            animation.addByPrefix('red', 'RedSplash', 12, false);
        }
        else {
            frames = FlxAtlasFrames.fromSparrow('assets/images/hud/notes/splashes.png', 'assets/images/hud/notes/splashes.xml');
            antialiasing = true;
            animation.addByPrefix('purple', 'PurpleSplash', 24, false);
            animation.addByPrefix('blue', 'BlueSplash', 24, false);
            animation.addByPrefix('green', 'GreenSplash', 24, false);
            animation.addByPrefix('red', 'RedSplash', 24, false);
        }

        switch (splashData)
        {
            case 0:
                animation.play('purple');
            case 1:
                animation.play('blue');
            case 2:
                animation.play('green');
            case 3:
                animation.play('red');
        }
    }

    override function update(elapsed:Float) {
        if (animation.finished) {
            kill();
        }
        super.update(elapsed);
    }
    
    override public function destroy() {
        super.destroy();
    }
}