import flixel.FlxSprite;
import flixel.FlxG;

class StrumNote extends FlxSprite {

    private var player:Int;
    private var noteData:Int = 0;

    public function new(x:Float, y:Float, leData:Int, player:Int) {
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';

		scrollFactor.set();
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

    public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();

        if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
            centerOrigin();
        }
	}
}