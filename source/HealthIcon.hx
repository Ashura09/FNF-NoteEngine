package;

import openfl.Assets;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		if (openfl.utils.Assets.exists('assets/images/hud/icons/icon-' + char + '.png')) {
			loadGraphic('assets/images/hud/icons/icon-' + char + '.png', true, 150, 150);
		}
		else if (openfl.utils.Assets.exists('assets/images/hud/icons/' + char + '.png')) {			
			loadGraphic('assets/images/hud/icons/' + char + '.png', true, 150, 150);
		}
		else {
			loadGraphic('assets/images/hud/icons/icon-dummy.png', true, 150, 150);
		}

		antialiasing = true;
		animation.add('player', [0, 1], 0, false, isPlayer);
		animation.play('player');
		scrollFactor.set();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
