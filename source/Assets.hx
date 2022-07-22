import flixel.graphics.frames.FlxAtlasFrames;

class FNFAssets {
    public static function GetSparrowAtlas(atlasPath:String) {
        return FlxAtlasFrames.fromSparrow(atlasPath + ".png", atlasPath + ".xml");
    }
    public static function GetSpriteSheetPacker(atlasPath:String) {
        return FlxAtlasFrames.fromSpriteSheetPacker(atlasPath + ".png", atlasPath + ".txt");
    }
    public static function ImagePath(subfolder:String) {
        return "assets/images/" + subfolder;
    }
    public static function SongPath(subfolder:String) {
        return "assets/songs/" + subfolder;
    }
    public static function JSONPath(subfolder:String) {
        return "assets/data/" + subfolder;
    }
    public static function ReplayPath(subfolder:String) {
        return "assets/replays/" + subfolder;
    }
    public static function CharacterPath(subfolder:String) {
        return "assets/chracters/" + subfolder;
    }
    public static function WeekPath(file:String) {
        return "assets/weeks/" + file;
    }
}