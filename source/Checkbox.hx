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
        FlxTween.tween(this.scale, {x:0.5, y:0.5}, 1, { ease: FlxEase.quadInOut, type: FlxTween.ONESHOT } );
        updateHitbox();
        centerOffsets();
        boundOption = option;
        trace("My option is value: " + boundOption);
        updateHitbox();
        centerOffsets();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 60, sprTracker.y + 10);
    }

    public function refresh() {
        if (boundOption == true) {
            animation.play('check', true, false);
        }
        else if (boundOption == false) {
            animation.play('check', true, true);
        }
    }
}