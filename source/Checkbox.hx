import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Assets.FNFAssets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.atlas.FlxAtlas;
import flixel.FlxSprite;

class Checkbox extends FlxSprite {

    public var sprTracker:FlxSprite;
    public var boundOption:Bool;

    public function new(?option:Bool) {
        super();
        frames = FNFAssets.GetSparrowAtlas(FNFAssets.ImagePath('hud/checkbox'));
        antialiasing = true;
        animation.addByPrefix('idle', 'Checkbox', 24, false);
        animation.addByPrefix('check', 'CheckboxChecked', 24, false);
        scrollFactor.set();
        scale = new flixel.math.FlxPoint(0.1, 0.1);
        updateHitbox();
        centerOffsets();
        boundOption = option;
        if (boundOption == true) {
            animation.play('check');
        }
        else {
            animation.play('idle');
        }
        trace("My option is value: " + boundOption);
        updateHitbox();
        centerOffsets();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 20, sprTracker.y - 30);
    }

    public function toggle() {
        boundOption = !boundOption;
        // Hahah, copypasting cuz i'm lazy to make a function for this
        switch (boundOption) {
            case true:
                animation.play("check", true);
            case false:
                animation.play("idle", true);
        }
        trace("My option is value: " + boundOption);
    }
}