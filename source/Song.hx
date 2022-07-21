package;

import lime.utils.AssetManifest;
import lime.utils.AssetType;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gf:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var isModded = false;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gf:String;

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = "";
		if (openfl.utils.Assets.exists(('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim())) {
			rawJson = lime.utils.Assets.getText('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();
		}
		else if (openfl.utils.Assets.exists(('mods/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim())) {
			rawJson = lime.utils.Assets.getText('mods/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();
		}
		else {
			rawJson = lime.utils.Assets.getText('assets/data/tutorial/tutorial-hard.json').trim();
		}
		
		// trace(rawJson);

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
