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

class AchievementsState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

    var AchievementID:Array<String> = ['no_miss', 'chart', 'test', 'tut_hard', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6'];
	var AchievementNames:Array<String> = ['Osu! Mania player', 'Modder', 'Tester', 'Tutorial', "Call me daddy.", 'Spooky Month!', 'Go Pico!', 'Show mommy the deal', 'DO NOT KILL SANTA', 'Doki Dok... Senpai!'];
    var AchievementDesc:Array<String> = ['Beat a song with 0 misses', 'Launch chart menu', 'Play song from a chart menu', 'Beat tutorial on hard with no misses', 'Complete week 1', 'Complete week 2', 'Complete week 3' ,'Complete week 4', 'Complete week 5', 'Complete week 6'];

	private var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/hud/menuDesat.png');
		menuBG.color = 0xFFFFFFFF;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...AchievementID.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, AchievementNames[i] + ': ', false, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			switch(curSelected)
			{
			}
				
		}
		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
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
