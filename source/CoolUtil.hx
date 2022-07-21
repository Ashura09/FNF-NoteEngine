package;

import FreeplayState.SongMetadata;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function loadFreeplaySongs(path:String):Array<SongMetadata>
	{
		var daList:Array<String> = Assets.getText(path).trim().split(':');
		var curElement:Int = 0;

		var nameList:Array<String> = [];
		var charList:Array<String> = [];
		var colorList:Array<Int> = [];

		var metadataArray:Array<SongMetadata> = [];
		
		for (i in 0...daList.length)
		{
			switch (curElement) {
				case 0:
					nameList.push(daList[i]);
				case 1:
					charList.push(daList[i]);
				case 2:
					colorList.push(Std.parseInt(daList[i]));
			}	
			if (curElement >= 2) {
				curElement = 0;
			}
			else {
				curElement++;
			}
		}

		for (i in 0...nameList.length) {
			nameList[i] = nameList[i].replace('\n', '');
		}

		for (i in 0...charList.length) {
			charList[i] = charList[i].replace('\n', '');
		}

		for (i in 0...nameList.length) {
			metadataArray.push(new SongMetadata(nameList[i], charList[i], colorList[i]));
		}

		return metadataArray;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	public static function fancyDifficulty()
	{
		var diff:String = "Null";
		switch (PlayState.storyDifficulty)
		{
			case 0:
				diff = "Easy";
			case 1:
				diff = "Normal";
			case 2:
				diff = "Hard";
		}
		return diff;
	}
}
