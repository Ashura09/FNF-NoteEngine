import Assets.FNFAssets;
import openfl.Assets;
import FreeplayState.SongMetadata;
import haxe.format.JsonParser;
import haxe.Json;

typedef Week = {
    public var songs:Array<SongMetadata>;
    public var weekCharacters:Array<String>;
    public var storyName:String;
}

class WeekLoader {
    public static var weeks:Array<Week> = [];

    public static function loadWeeks() {
        var weekList:Array<String> = [];
        weekList = CoolUtil.coolTextFile(FNFAssets.WeekPath('weekList.txt'));
        var weekSongs:Array<SongMetadata> = [];
        for (i in 0...weekList.length) {
            weeks.push(Json.parse(Assets.getText(FNFAssets.WeekPath(weekList[i] + '.json'))));
            for (j in 0...weeks[i].songs.length) {
                weekSongs.push(weeks[i].songs[j]);
            }
        }
        trace("Weeks loaded!");
        return weekSongs;
    }
}
