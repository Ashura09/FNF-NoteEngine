package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxBasic;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Modifiers', 'Toggle Replay', 'Exit to menu'];
	var modifierItems:Array<String> = ['Back', 'Toggle Botplay', 'Toggle Nofail', 'Toggle Instakill'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var inModifiers:Bool = false;

	var songName:FlxText;
	var songDiff:FlxText;
	var nofail:FlxText;

	public function new(x:Float, y:Float)
	{
		super();

		songName = new FlxText(FlxG.width - 5, 16, 0, "", 64);
		songName.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE);
		songName.scrollFactor.set();
		songName.borderSize = 1;

		songDiff = new FlxText(FlxG.width - 5, 50, 0, "", 64);
		songDiff.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE);
		songDiff.scrollFactor.set();
		songDiff.borderSize = 1;
		
		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + TitleState.soundExt, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		
		FlxG.sound.list.add(pauseMusic);
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		add(songName);
		add(songDiff);

		songName.text = PlayState.SONG.song;
		songDiff.text = CoolUtil.fancyDifficulty().toUpperCase();

		songName.x = FlxG.width - 15 - songName.width;
		songDiff.x = FlxG.width - 15 - songDiff.width;

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);


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

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			var m_daSelected:String = modifierItems[curSelected];

			if (!inModifiers)
			{			
				switch (daSelected)
				{
					case "Resume":
						close();
					case "Restart Song":
						restart();		
					case "Exit to menu":
						FlxG.switchState(new MainMenuState());
					case "Modifiers":
						loadModifiers();	
					case "Toggle Replay":
						PlayState.isReplaying = !PlayState.isReplaying;
						restart();
				}
			}
			else {
				switch (m_daSelected)
				{
					case "Back":
							loadMenu();
					case "Toggle Botplay":
						PlayState.botplay = !PlayState.botplay;
					case "Toggle Nofail":
						PlayState.nofail = !PlayState.nofail;
					case "Toggle Instakill":
						Preferences.instakill = !Preferences.instakill;
				}
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	function restart() {
		FlxTween.tween(PlayState.camHUD, {alpha: 0.0}, 0.45, {ease: FlxEase.circInOut});
		new FlxTimer().start(0.45, function(tmr:FlxTimer) {
			FlxG.resetState();
		});	
	}

	function loadModifiers()
	{
		curSelected = 0;
		inModifiers = true;
		grpMenuShit.clear();
		for (i in 0...modifierItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, modifierItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}
		changeSelection(0);
	}

	function loadMenu()
	{
		curSelected = 0;
		inModifiers = false;
		grpMenuShit.clear();
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}
		changeSelection(0);
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (!inModifiers) {
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;
		}
		if (inModifiers) {
			if (curSelected < 0)
				curSelected = modifierItems.length - 1;
			if (curSelected >= modifierItems.length)
				curSelected = 0;
		}

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
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
