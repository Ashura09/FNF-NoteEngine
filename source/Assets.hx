import flixel.graphics.frames.FlxAtlasFrames;

class FNFAssets {
    public static function GetSparrowAtlas(atlasPath:String) {
        return FlxAtlasFrames.fromSparrow(atlasPath + ".png", atlasPath + ".xml");
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
}