package;
import NoteSplashes.NoteSplash;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import Replay.ReplayFile;
import Replay.ReplayInput;
import Replay.ReplayParser;
import Assets.FNFAssets;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var isPixelStage:Bool = false;
	public static var STRUM_X = 42;

	public var replayparser:ReplayParser;
	public static var isReplaying = false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var ratingsData:Array<Rating> = [];
	private var replay:ReplayFile;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var opponentStrums:FlxTypedGroup<FlxSprite>;
	private var grpNoteSplash:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "None";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var songPercent:Float = 0.0;
	private var combo:Int = 0;
	private var missedNotes:Int = 0;
	private var Accuracy:Float = 1.00;
	private var songLength:Float = FlxG.sound.music.length;
	public static var botplay:Bool = Preferences.botplay;
	public static var nofail:Bool = Preferences.nofail;
	private var nofailed:Bool = false;

	public static var totalNotesHit:Float = 0.0;
	public static var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var missTxt:FlxText;
	var accuracyTxt:FlxText;
	var songTxt:FlxText;
	var healthClr1:Int = 0xFFFF0000;
	var healthClr2:Int = 0xFF31B0D1;
	var botplayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	// var NoteSplash:NoteSplash = new NoteSplash(); // 715 - left, 100

	override public function create()
	{
		instance = this;
		replay = new ReplayFile();
		if (isReplaying) trace("*** REPLAY MODE ***");
		else trace("*** RECORD MODE ***");

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (openfl.Assets.exists("assets/data/" + SONG.song.toLowerCase() + "/dialogue.txt"))
		{
			dialogue = CoolUtil.coolTextFile("assets/data/" + SONG.song.toLowerCase() + "/dialogue.txt");
		}

		/*switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/tutorialDialogue.txt');
			case 'bopeebo':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/bopeeboDialogue.txt');
			case 'fresh':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/freshDialogue.txt');
			case 'dadbattle':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/dadbattleDialogue.txt');
			case 'senpai':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/senpaiDialogue.txt');
			case 'roses':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/rosesDialogue.txt');
			case 'thorns':
				dialogue = CoolUtil.coolTextFile('assets/cooltextfiles/dialogues/thornsDialogue.txt');
		}*/

		
		//Ratings
		ratingsData.push(new Rating('sick', 1.0, false, 0)); //default rating
		// grpNoteSplash.add(new NoteSplash(0,0,isPixelStage));
		totalNotesHit = 0.0;
		totalPlayed = 0;

		curStage = SONG.stage;
		if (curStage == null) {
			switch (SONG.song.toLowerCase().replace(' ', '-')) {
				case 'bopeebo' | 'fresh' | 'dad-battle':
					curStage = 'stage';
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'philly-nice' | 'blammed':
					curStage = 'philly';
				case 'satin-panties' | 'high' | 'milf':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}

		if (SONG.player2 == null) {
			SONG.player2 = 'dad';
		}
		if (SONG.player1 == null) {
			SONG.player1 = 'bf';
		}

		if (curStage.startsWith('school')) {
			isPixelStage = true;
		}
		else {
			isPixelStage = false;
		}

		if (curStage == 'spooky')
			{
				halloweenLevel = true;
	
				var hallowTex = FlxAtlasFrames.fromSparrow('assets/images/stages/halloween_bg.png', 'assets/images/stages/halloween_bg.xml');
	
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
	
				isHalloween = true;
			}
			else if (curStage == 'philly')
			{
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic('assets/images/stages/philly/sky.png');
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);
	
				var city:FlxSprite = new FlxSprite(-10).loadGraphic('assets/images/stages/philly/city.png');
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);
	
				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);
	
				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic('assets/images/stages/philly/win' + i + '.png');
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}
	
				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic('assets/images/stages/philly/behindTrain.png');
				add(streetBehind);
	
				phillyTrain = new FlxSprite(2000, 360).loadGraphic('assets/images/stages/philly/train.png');
				add(phillyTrain);
	
				trainSound = new FlxSound().loadEmbedded('assets/sounds/train_passes' + TitleState.soundExt);
				FlxG.sound.list.add(trainSound);
	
				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);
	
				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic('assets/images/stages/philly/street.png');
				add(street);
			}
			else if (curStage == 'limo')
			{
				defaultCamZoom = 0.90;
	
				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic('assets/images/stages/limo/limoSunset.png');
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);
	
				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/limo/bgLimo.png', 'assets/images/stages/limo/bgLimo.xml');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);
	
				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);
	
				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}
	
				var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic('assets/images/stages/limo/limoOverlay.png');
				overlayShit.alpha = 0.5;
				// add(overlayShit);
	
				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
	
				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
	
				// overlayShit.shader = shaderBullshit;
	
				var limoTex = FlxAtlasFrames.fromSparrow('assets/images/stages/limo/limoDrive.png', 'assets/images/stages/limo/limoDrive.xml');
	
				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;
	
				fastCar = new FlxSprite(-300, 160).loadGraphic('assets/images/stages/limo/fastCarLol.png');
				// add(limo);
			}
			else if (curStage == 'mall')
			{
				defaultCamZoom = 0.80;
	
				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic('assets/images/stages/christmas/bgWalls.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);
	
				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/christmas/upperBop.png', 'assets/images/stages/christmas/upperBop.xml');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);
	
				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic('assets/images/stages/christmas/bgEscalator.png');
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);
	
				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic('assets/images/stages/christmas/christmasTree.png');
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);
	
				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/christmas/bottomBop.png', 'assets/images/stages/christmas/bottomBop.xml');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);
	
				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic('assets/images/stages/christmas/fgSnow.png');
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);
	
				santa = new FlxSprite(-840, 150);
				santa.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/christmas/santa.png', 'assets/images/stages/christmas/santa.xml');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			}
			else if (curStage == 'mallEvil')
			{
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic('assets/images/stages/christmas/evilBG.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);
	
				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic('assets/images/stages/christmas/evilTree.png');
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);
	
				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic("assets/images/stages/christmas/evilSnow.png");
				evilSnow.antialiasing = true;
				add(evilSnow);
			}
			else if (curStage == 'school')
			{
				var bgSky = new FlxSprite().loadGraphic('assets/images/stages/weeb/weebSky.png');
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);
	
				var repositionShit = -200;
	
				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic('assets/images/stages/weeb/weebSchool.png');
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);
	
				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic('assets/images/stages/weeb/weebStreet.png');
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);
	
				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic('assets/images/stages/weeb/weebTreesBack.png');
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);
	
				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = FlxAtlasFrames.fromSpriteSheetPacker('assets/images/stages/weeb/weebTrees.png', 'assets/images/stages/weeb/weebTrees.txt');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
	
				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/weeb/petals.png', 'assets/images/stages/weeb/petals.xml');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);
	
				var widShit = Std.int(bgSky.width * 6);
	
				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);
	
				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();
	
				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);
	
				if (SONG.song.toLowerCase() == 'roses')
				{
					bgGirls.getScared();
				}
	
				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			}
			else if (curStage == 'schoolEvil')
			{
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
	
				var posX = 400;
				var posY = 200;
	
				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/weeb/animatedEvilSchool.png', 'assets/images/stages/weeb/animatedEvilSchool.xml');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);
	
				/* 
					var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic('assets/images/weeb/evilSchoolBG.png');
					bg.scale.set(6, 6);
					// bg.setGraphicSize(Std.int(bg.width * 6));
					// bg.updateHitbox();
					add(bg);
	
					var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic('assets/images/weeb/evilSchoolFG.png');
					fg.scale.set(6, 6);
					// fg.setGraphicSize(Std.int(fg.width * 6));
					// fg.updateHitbox();
					add(fg);
	
					wiggleShit.effectType = WiggleEffectType.DREAMY;
					wiggleShit.waveAmplitude = 0.01;
					wiggleShit.waveFrequency = 60;
					wiggleShit.waveSpeed = 0.8;
				 */
	
				// bg.shader = wiggleShit.shader;
				// fg.shader = wiggleShit.shader;
	
				/* 
					var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
					var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
	
					// Using scale since setGraphicSize() doesnt work???
					waveSprite.scale.set(6, 6);
					waveSpriteFG.scale.set(6, 6);
					waveSprite.setPosition(posX, posY);
					waveSpriteFG.setPosition(posX, posY);
	
					waveSprite.scrollFactor.set(0.7, 0.8);
					waveSpriteFG.scrollFactor.set(0.9, 0.8);
	
					// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
					// waveSprite.updateHitbox();
					// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
					// waveSpriteFG.updateHitbox();
	
					add(waveSprite);
					add(waveSpriteFG);
				 */
			}
			else
			{
				defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stages/stageback.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
	
				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stages/stagefront.png');
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);
	
				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stages/stagecurtains.png');
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
	
				add(stageCurtains);
			}

		var gfVersion:String = '';
		gfVersion = SONG.gf;
		trace(gfVersion);
		if (gfVersion == null) {
			switch (curStage) {
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
		}
		

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;


		strumLine = new FlxSprite(0, Preferences.downscroll ? FlxG.height - 50 - 112: 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		opponentStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		//botplayTxt = new FlxText();

		//add(botplayTxt);

		//botplayTxt.x = healthBarBG.x + healthBarBG.width / 2;
		//botplayTxt.y = healthBarBG.y - 150;
		//botplayTxt.text = "BOTPLAY";
		
		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, Preferences.downscroll ? 72 : FlxG.height * 0.9).loadGraphic('assets/images/hud/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		timeBarBG = new FlxSprite(0, Preferences.downscroll ? FlxG.height * 0.9 : 16).loadGraphic('assets/images/hud/healthBar.png');
		timeBarBG.screenCenter(X);
		timeBarBG.scrollFactor.set();
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, RIGHT_TO_LEFT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		/*switch(dad.curCharacter.toLowerCase())
		{
			case 'gf':
				healthClr1 = 0xFFA5004D;
			case 'dad':
				healthClr1 = 0xFFAF66CE;
			case 'spooky':
				healthClr1 = 0xFFD57E00;
			case 'monster':
				healthClr1 = 0xFFF3FF6E;
			case 'pico':
				healthClr1 = 0xFFB7D855;
			case 'mom':
				healthClr1 = 0xFFD8558E;
			case 'mom-car':
				healthClr1 = 0xFFD8558E;
			case 'parents-christmas':
				healthClr1 = 0xFFCC07FF;
			case 'monster-christmas':
				healthClr1 = 0xFFFFE13A;
			case 'senpai':
				healthClr1 = 0xFFFFAA6F;
			case 'spirit':
				healthClr1 = 0xFFFF3C6E;
		}*/

		healthBar.createFilledBar(dad.healthColor, boyfriend.healthColor);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.alpha = 0;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.alpha = 0;
		add(iconP2);
	
		scoreTxt = new FlxText(0 + 50, healthBarBG.y - 50, 0, "", 20);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 2;
		scoreTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		scoreTxt.borderColor = FlxColor.BLACK;
		add(scoreTxt);
		
		missTxt = new FlxText(0 + 50, scoreTxt.y + 25, 0, "", 20);
		missTxt.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT);
		missTxt.scrollFactor.set();
		missTxt.borderSize = 2;
		missTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		missTxt.borderColor = FlxColor.BLACK;
		add(missTxt);
		
		accuracyTxt = new FlxText(0 + 50, missTxt.y + 25, 0, "", 20);
		accuracyTxt.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT);
		accuracyTxt.scrollFactor.set();
		accuracyTxt.borderSize = 2;
		accuracyTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		accuracyTxt.borderColor = FlxColor.BLACK;
		add(accuracyTxt);
		
		songTxt = new FlxText(0 + 50, accuracyTxt.y + 25, 0, "", 20);
		songTxt.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, RIGHT);
		songTxt.scrollFactor.set();
		songTxt.borderSize = 2;
		songTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		songTxt.borderColor = FlxColor.BLACK;
		add(songTxt);

		botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 92, healthBarBG.y - 150, 0, "", 20);
		botplayTxt.setFormat("assets/fonts/vcr.ttf", 48, FlxColor.WHITE, RIGHT);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
		botplayTxt.borderColor = FlxColor.BLACK;
		botplayTxt.borderSize = 4;
		add(botplayTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		missTxt.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		songTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'bopeebo':
					schoolIntro(doof);
				case 'fresh':
					schoolIntro(doof);
				case 'dadbattle':
					schoolIntro(doof);
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play('assets/sounds/ANGRY' + TitleState.soundExt);
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();

		replayparser = new ReplayParser();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/weeb/senpaiCrazy.png', 'assets/images/stages/weeb/senpaiCrazy.xml');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play('assets/sounds/Senpai_Dies' + TitleState.soundExt, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = true;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		FlxTween.tween(iconP1, {alpha: 1.0}, 1, {ease: FlxEase.circInOut});
		FlxTween.tween(iconP2, {alpha: 1.0}, 1, {ease: FlxEase.circInOut});

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['hud/ready.png', "hud/set.png", "hud/go.png"]);
			introAssets.set('school', [
				'hud/pixelUI/ready-pixel.png',
				'hud/pixelUI/set-pixel.png',
				'hud/pixelUI/date-pixel.png'
			]);
			introAssets.set('schoolEvil', [
				'hud/pixelUI/ready-pixel.png',
				'hud/pixelUI/set-pixel.png',
				'hud/pixelUI/date-pixel.png'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + altSuffix + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[0]);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school')) {
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
						isPixelStage = true;
					}		

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + altSuffix + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[1]);
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + altSuffix + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[2]);
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + altSuffix + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			if (Assets.exists("assets/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Inst" + TitleState.soundExt)) {
				FlxG.sound.playMusic("assets/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Inst" + TitleState.soundExt, 1, false);
			}
			else if (Assets.exists("mods/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Inst" + TitleState.soundExt)) {
				FlxG.sound.playMusic("mods/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Inst" + TitleState.soundExt, 1, false);
			}
			trace("Loading: " + "assets/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Inst" + TitleState.soundExt);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			// vocals = new FlxSound().loadEmbedded("assets/songs/" + curSong.toLowerCase() + "/Voices" + TitleState.soundExt);
			if (Assets.exists("assets/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Voices" + TitleState.soundExt)) {
				vocals = new FlxSound().loadEmbedded("assets/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Voices" + TitleState.soundExt);
			}
			else if (Assets.exists("mods/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Voices" + TitleState.soundExt)) {
				vocals = new FlxSound().loadEmbedded("mods/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Voices" + TitleState.soundExt);
			}
			trace("Loading: " + "assets/songs/" + SONG.song.toLowerCase().replace(' ', '-') + "/Voices" + TitleState.soundExt);
		}
		else
		{
			vocals = new FlxSound();
		}
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteType:String = songNotes[3];
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daNoteType);

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteType);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2 + STRUM_X - 42; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2 + STRUM_X - 42; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(STRUM_X, strumLine.y);

			switch (curStage)
			{
				case 'school':
					NoteSplash.isPixel = true;
					babyArrow.loadGraphic('assets/images/hud/notes/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
					
					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
							case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
				case 'schoolEvil':
					NoteSplash.isPixel = true;
					babyArrow.loadGraphic('assets/images/hud/notes/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);
					
					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
					
					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					NoteSplash.isPixel = false;
					babyArrow.frames = FlxAtlasFrames.fromSparrow('assets/images/hud/notes/NOTE_assets.png', 'assets/images/hud/notes/NOTE_assets.xml');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0 + 8;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1 + 8;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2 + 8;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3 + 8;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				babyArrow.angle = -45;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1, angle: 0}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			// babyArrow.x += STRUM_X;
			babyArrow.x += ((FlxG.width / 2) * player + 50);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		/*if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}*/

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore;
		missTxt.text = "Misses:" + missedNotes;
		accuracyTxt.text = "Accuracy:" + FlxMath.roundDecimal(Accuracy * 100, 2);
		songTxt.text = curSong + " - " + CoolUtil.fancyDifficulty();
		botplayTxt.text = "BOTPLAY";

		botplayTxt.visible = botplay;

		songPercent = (Conductor.songPosition / songLength);

		// if (Accuracy > 1.0) Accuracy = 1.0;
		// if (Accuracy < 0.0) Accuracy = 0.0;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (!nofailed) {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (!nofail)
		{
			if (health <= 0)
				{
					boyfriend.stunned = true;
		
					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					vocals.stop();
					FlxG.sound.music.stop();
		
					// 1 / 1000 chance for Gitaroo Man easter egg
					if (FlxG.random.bool(0.5))
					{
						// gitaroo man easter egg
						FlxG.switchState(new GitarooPause());
					}
					else
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}
		if (nofail && health <= 0) {
			nofailed = true;
			healthBarBG.kill();
			healthBar.kill();
			iconP2.kill();
			iconP1.animation.curAnim.curFrame = 1;
			iconP1.x = healthBar.x + (healthBar.width / 2 - iconP1.width / 2);
		}

		for (playerStrumNote in playerStrums) {
			// playerStrumNote.y = Math.sin(songTime) * 10;
		}


		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height && Preferences.downscroll)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (Preferences.downscroll) {
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				}
				else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				}
				
				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					if (Preferences.downscroll) {
						swagRect.height -= -swagRect.y;
					}
					else {
						swagRect.height -= swagRect.y;
					}

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					opponentStrums.forEach(function(spr:FlxSprite) {
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm');
							if (!curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							var time:Float = 0.15;
							//if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
							if(daNote.isSustainNote) {
								time += 0.15;
							}	
							new FlxTimer().start(time, function(tmr:FlxTimer)
							{
								// boyfriend.dance();
								spr.animation.play('static', false);
								spr.centerOffsets();
								if (!curStage.startsWith('school'))
								{
									//spr.offset.x += 13;
									//spr.offset.y += 13;
								}
							});
						}
					});

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && botplay)
				{
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height && !Preferences.downscroll)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						if (!daNote.wasGoodHit)
						{
							if (Preferences.instakill)
								{
									health = 0;
								}
								health -= 0.0475;
								vocals.volume = 0;
								missedNotes++;
								combo = 0;
								totalPlayed++;
								recalculateAccuracy();
				
								FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
								// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
								// FlxG.log.add('played imss note');
					
								boyfriend.stunned = true;
					
								// get stunned for 5 seconds
								new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
								{
									boyfriend.stunned = false;
								});
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			});
		}

		if (!inCutscene && !botplay)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		#if sys
		sys.io.File.saveContent(FNFAssets.ReplayPath('replay.rpl'), /*SONG.song + curDifficulty + ";" + */replay.toString());
		#end
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 1)
					difficulty = '';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			ratingsData.push(new Rating('shit', 0.2, false, 50, 0.004));
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			ratingsData.push(new Rating('bad', 0.4, false, 100, 0.007));
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.6)
		{
			ratingsData.push(new Rating('ok', 0.6, false, 150, 0.01));
			
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.35)
		{
			ratingsData.push(new Rating('good', 0.8, false, 250, 0.015));
		}
		else {
			ratingsData.push(new Rating('sick', 1.0, true, 350, 0.024));
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic('assets/images/hud/' + pixelShitPart1 + ratingsData[ratingsData.length-1].name + pixelShitPart2 + ".png");
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camHUD];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic('assets/images/hud/' + pixelShitPart1 + 'combo' + pixelShitPart2 + '.png');
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.cameras = [camHUD];

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		if (comboSplit.length == 2)
			seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

		for(i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/hud/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2 + '.png');
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10) {
				add(numScore);
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	public function recalculateAccuracy()
	{
		if(totalPlayed != 0)
		{
			Accuracy = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
			trace("Total: " + totalPlayed + ", Hit: " + totalNotesHit);
		}
	}

	// Making New Input System from scratch! Yay!
	// Several months:
	// I copied the input system from kade engine, and slightly edited it

	private function keyShit():Void
		{	
			var replayAccuracy = 10000;

			var controlArray:Array<Bool> = [];
			var controlHoldArray:Array<Bool> = [];
			var controlReleaseArray:Array<Bool> = [];

			// HOLDING
			var up = controls.UP;
			var right = controls.RIGHT;
			var down = controls.DOWN;
			var left = controls.LEFT;
			
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
			
			var upR = controls.UP_R;
			var rightR = controls.RIGHT_R;
			var downR = controls.DOWN_R;
			var leftR = controls.LEFT_R;

			if (!isReplaying) {
				controlArray = [leftP, downP, upP, rightP];
				controlHoldArray = [left, down, up, right];
				controlReleaseArray = [leftR, downR, upR, rightR];
			}
			else if (isReplaying) {
				controlArray = [false, false, false, false];
				controlHoldArray = [false, false, false, false];
				controlReleaseArray = [false, false, false, false];
			}

			if (isReplaying) {
				if (isReplaying) {
					for (i in 0...replayparser.inputs.length) {
						if (replayparser.inputs[i].strumTime == Math.floor(songPercent * replayAccuracy)) {
							controlArray[replayparser.inputs[i].noteData] = true;
							controlHoldArray[replayparser.inputs[i].noteData] = true;
							trace("Simulating press at: " + replayparser.inputs[i].noteData + ", " + replayparser.inputs[i].strumTime);
							new FlxTimer().start(replayparser.inputs[i].holdTime, function(timer:FlxTimer) {
								controlArray[replayparser.inputs[i].noteData] = false;
								controlHoldArray[replayparser.inputs[i].noteData] = false;
								trace("Simulating release at: " + replayparser.inputs[i].noteData + ", " + replayparser.inputs[i].strumTime);
							});
						}
					}
					/**/
				}
			}

			var possibleNotes:Array<Note> = [];
	
			if (!isReplaying) {
				if (controlArray.contains(true)) {
					replay.inputs.push(new ReplayInput(controlArray.indexOf(true), songPercent * replayAccuracy, 0.25));
					trace("Recording press: " + controlArray.indexOf(true) + ", " + songPercent * replayAccuracy + ", " + 0.25);
				}
			}

			if (!boyfriend.stunned && generatedMusic)
			{
				boyfriend.holdTimer = 0;
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress) {
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					}
					if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress)
					{
						goodNoteHit(daNote);
					}
				});
				if (possibleNotes.length > 0)
					{
						var daNote = possibleNotes[0];
		
						if (perfectMode)
							noteCheck(true, daNote);
		
						// Jump notes
						if (possibleNotes.length >= 2)
						{
							if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
							{
								for (coolNote in possibleNotes)
								{
									if (controlArray[coolNote.noteData])
										goodNoteHit(coolNote);
								}
							}
							else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
							{
								noteCheck(controlArray[daNote.noteData], daNote);
							}
							else
							{
								for (coolNote in possibleNotes)
								{
									noteCheck(controlArray[coolNote.noteData], coolNote);
								}
							}
						}
						else // regular notes?
						{
							noteCheck(controlArray[daNote.noteData], daNote);
						}
						/* 
							if (controlArray[daNote.noteData])
								goodNoteHit(daNote);
						 */
						// trace(daNote.noteData);
						/* 
							switch (daNote.noteData)
							{
								case 2: // NOTES YOU JUST PRESSED
									if (upP || rightP || downP || leftP)
										noteCheck(upP, daNote);
								case 3:
									if (upP || rightP || downP || leftP)
										noteCheck(rightP, daNote);
								case 1:
									if (upP || rightP || downP || leftP)
										noteCheck(downP, daNote);
								case 0:
									if (upP || rightP || downP || leftP)
										noteCheck(leftP, daNote);
							}
						 */
						if (daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
			playerStrums.forEach(function(spr:FlxSprite)
			{
				switch (spr.ID)
				{
					case 0:
						if (controlHoldArray[0] && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (controlReleaseArray[0])
							spr.animation.play('static');
					case 1:
						if (controlHoldArray[1] && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (controlReleaseArray[1])
							spr.animation.play('static');
					case 2:
						if (controlHoldArray[2] && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (controlReleaseArray[2])
							spr.animation.play('static');
					case 3:
						if (controlHoldArray[3] && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (controlReleaseArray[3])
							spr.animation.play('static');
				}
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
			});
		}
	
		function noteMiss(direction:Int = 1):Void
		{

		}

		public function GetLastRating():Rating {
			return ratingsData[ratingsData.length-1];
		}
	
		function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (downP)
				noteMiss(1);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);

		}
	
		function noteCheck(keyP:Bool, note:Note):Void
		{
			if (keyP)
				goodNoteHit(note);
			else
			{
				badNoteCheck();
			}
		}
	
		function goodNoteHit(note:Note):Void
		{
			if (!note.wasGoodHit)
			{			
				if (!note.isSustainNote)
				{
					popUpScore(note.strumTime);
					combo += 1;
					totalPlayed++;
					health += GetLastRating().health;
				}
				else {
					health += GetLastRating().health / 2;
				}

				switch (note.noteType) {
					case "":
					case "instakill":
						health -= 3;
				}
	
				switch (note.noteData)
				{
					case 0:
						boyfriend.playAnim('singLEFT', true);
							
					case 1:
						boyfriend.playAnim('singDOWN', true);
						
					case 2:
						boyfriend.playAnim('singUP', true);
						
					case 3:
						boyfriend.playAnim('singRIGHT', true);
						
				}
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
						if(botplay) {
							var time:Float = 0.15;
							if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
								time += 0.15;
							}	
							new FlxTimer().start(time, function(tmr:FlxTimer)
							{
								// boyfriend.dance();
								spr.animation.play('static', false);
								spr.centerOffsets();
								if (!curStage.startsWith('school'))
								{
									//spr.offset.x += 13;
									//spr.offset.y += 13;
								}
							});
						}
					}
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
				});
	
				note.wasGoodHit = true;
				vocals.volume = 1;
	
				if (!note.isSustainNote)
				{
					if (ratingsData[ratingsData.length-1].splashes) {
						/*switch (note.noteData)
						{
							case 0:
							case 1:
								var NoteSplash = new NoteSplash(strumLineNotes.members[note.noteData].x, strumLine.y, false);
								NoteSplash.cameras = [camHUD];
								add(NoteSplash);
								//NoteSplash.offset.x = -114;
								NoteSplash.animation.play('blue');
							case 2:
								var NoteSplash = new NoteSplash(strumLineNotes.members[note.noteData].x, strumLine.y, false);
								NoteSplash.cameras = [camHUD];
								add(NoteSplash);
								//NoteSplash.offset.x = -241;
								NoteSplash.animation.play('green');
							case 3:
								var NoteSplash = new NoteSplash(strumLineNotes.members[note.noteData].x, strumLine.y, false);
								NoteSplash.cameras = [camHUD];
								add(NoteSplash);
								//NoteSplash.offset.x = -353;
								NoteSplash.animation.play('red');
						}*/
						var splash = new NoteSplash(playerStrums.members[note.noteData].x, strumLine.y, false);
						// grpNoteSplash.add(splash);
						splash.cameras = [camHUD];
						add(splash);
						splash.animation.play(splash.anims[note.noteData]);
					}				
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				recalculateAccuracy();
			}
		}
	
		var fastCarCanDrive:Bool = true;
	
		function resetFastCar():Void
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	
		function fastCarDrive()
		{
			FlxG.sound.play('assets/sounds/carPass' + FlxG.random.int(0, 1) + TitleState.soundExt, 0.7);
	
			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	
		var trainMoving:Bool = false;
		var trainFrameTiming:Float = 0;
	
		var trainCars:Int = 8;
		var trainFinishing:Bool = false;
		var trainCooldown:Int = 0;
	
		function trainStart():Void
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	
		var startedMoving:Bool = false;
	
		function updateTrainPos():Void
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}
	
			if (startedMoving)
			{
				phillyTrain.x -= 400;
	
				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;
	
					if (trainCars <= 0)
						trainFinishing = true;
				}
	
				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	
		function trainReset():Void
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	
		function lightningStrikeShit():Void
		{
			FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
			halloweenBG.animation.play('lightning');
	
			lightningStrikeBeat = curBeat;
			lightningOffset = FlxG.random.int(8, 24);
	
			boyfriend.playAnim('scared', true);
			gf.playAnim('scared', true);
		}
	
		override function stepHit()
		{
			super.stepHit();
			if (SONG.needsVoices)
			{
				if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
				{
					resyncVocals();
				}
			}
	
			if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
			{
				// dad.dance();
			}
		}
	
		var lightningStrikeBeat:Int = 0;
		var lightningOffset:Int = 8;
	
		override function beatHit()
		{
			super.beatHit();
	
			if (generatedMusic)
			{
				notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			}
	
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				{
					Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
					FlxG.log.add('CHANGED BPM!');
				}
				// else
				// Conductor.changeBPM(SONG.bpm);
	
				// Dad doesnt interupt his own notes
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
					dad.dance();
				if (!SONG.notes[Math.floor(curStep / 16)].mustHitSection && botplay)
					boyfriend.dance();
			}
			// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
			wiggleShit.update(Conductor.crochet);
	
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));
	
			iconP1.updateHitbox();
			iconP2.updateHitbox();
	
			if (curBeat % gfSpeed == 0)
			{
				gf.dance();
			}
	
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.playAnim('idle');
			}
	
			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
	
				if (SONG.song == 'Tutorial' && dad.curCharacter == 'gf')
				{
					dad.playAnim('cheer', true);
				}
			}
	
			switch (curStage)
			{
				case 'school':
					bgGirls.dance();
	
				case 'mall':
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
	
				case 'limo':
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
	
					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				case "philly":
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}
	
					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
			}
	
			if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			{
				lightningStrikeShit();
			}
		}
	
		var curLight:Int = 0;

	}