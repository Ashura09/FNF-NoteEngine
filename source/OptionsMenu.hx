package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class OptionsMenu extends MusicBeatState
{
	var options:Array<String> = [];
	var optionBools:Array<Bool> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var checkboxes:Array<Checkbox> = [];

	override function create()
	{
		options = ['Botplay', 'No fail', 'Instakill'];
		optionBools = [Preferences.botplay, Preferences.nofail, Preferences.instakill];

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/hud/menuDesat.png');
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);

			var checkbox:Checkbox = new Checkbox(optionBools[i]);
			checkbox.sprTracker = optionText;
			checkboxes.push(checkbox);
			add(checkbox);
			// FlxTween.tween(checkbox, {scale: 0.5}, 1, {ease: FlxEase.circOut});
		}

		changeSelection();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			optionBools[curSelected] = !optionBools[curSelected];
			checkboxes[curSelected].refresh();
			trace(optionBools[curSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(options[curSelected], curDifficulty);
		// lerpScore = 0;
		#end

		// FlxG.sound.playMusic('assets/songs/' + songs[curSelected] + "/Inst" + TitleState.soundExt, 0);
		// trace('assets/songs/' + songs[curSelected] + "/Inst" + TitleState.soundExt);

		var bullShit:Int = 0;

		for (i in 0...checkboxes.length)
		{
			checkboxes[i].alpha = 0.6;
		}

		checkboxes[curSelected].alpha = 1;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
