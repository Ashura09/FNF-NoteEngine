import Assets.FNFAssets;

class Rating {
    public var name:String = "";
    public var rating:Float = 1.0;
    public var splashes:Bool = false;
    public var score:Int = 350;
    public var image:String = "";
    public var health:Float = 0.024;

    public function new(name:String, rating:Float = 1.0, splashes:Bool = false, score:Int = 150, health:Float = 0.024) {
        this.name = name;
        this.rating = rating;
        this.splashes = splashes;
        this.score = score;
        this.health = health;
        PlayState.totalNotesHit += rating;
    }
}