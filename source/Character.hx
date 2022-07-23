package;

import Assets.FNFAssets;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.format.JsonParser;
import haxe.Json;
#if sys
import sys.io.File;
#end

using StringTools;

// OMFG, i'm so sorry for borrowing so much code from Psych Engine
// Forgive me pls

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	
	var trail:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var healthColor:Int = 0xFFFF0000;

	public var hasTrail:Bool = false;
	public var trail:FlxTrail;

	public var holdTimer:Float = 0;
	public var camPos:Array<Float> = [0.0,0.0];
	public var movePos:Array<Float> = [0.0,0.0];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			default:	
				var path = 'assets/characters/' + curCharacter + '.json';
				var rawJson = "";
				#if sys
				rawJson = sys.io.File.getContent(path);
				#end
				var json:CharacterFile = Json.parse(rawJson);
				#if sys
				if (sys.FileSystem.exists(FNFAssets.ImagePath(json.image + ".xml"))) {
					frames = FNFAssets.GetSparrowAtlas(FNFAssets.ImagePath(json.image));
				}
				if (sys.FileSystem.exists(FNFAssets.ImagePath(json.image + ".txt"))) {
					frames = FNFAssets.GetSpriteSheetPacker(FNFAssets.ImagePath(json.image));
				}
				#end
				for (i in 0...json.animations.length) {
					if (json.animations[i].indices != null && json.animations[i].indices.length > 0) {
						animation.addByIndices(json.animations[i].anim, json.animations[i].name, json.animations[i].indices, '', json.animations[i].fps, json.animations[i].loop);
					}
					else {
						animation.addByPrefix(json.animations[i].anim, json.animations[i].name, json.animations[i].fps, json.animations[i].loop);
					}
					addOffset(json.animations[i].anim, json.animations[i].offsets[0], json.animations[i].offsets[1]);
				}
				healthColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
				antialiasing = !json.no_antialiasing;
				flipX = json.flip_x;
				if (json.scale != 1) {
					setGraphicSize(Std.int(width * json.scale));
					updateHitbox();
				}
				camPos[0] = json.camera_position[0];
				camPos[1] = json.camera_position[1];
				movePos[0] = json.position[0];
				movePos[1] = json.position[1];
				if (animation.getNameList().contains("danceRight")) {
					playAnim('danceRight');
				}
				else {
					playAnim('idle');
				}
				if (json.trail != null && json.trail.length > 0) 
				{
					trail = new FlxTrail(this, null, Std.int(json.trail[0]), Std.int(json.trail[1]), json.trail[2], json.trail[3]);
					hasTrail = true;
				}
				trace("JSON Character Loaded!\nInfo: " + curCharacter + "\nPath: " + path);
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
