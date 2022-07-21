import Assets.FNFAssets;
import lime.utils.Assets;

class ReplayFile {
    public var inputs:Array<ReplayInput> = [];
    public var inputStrings:Array<String> = [];

    public function new(dataPath:String = 'replay.rpl') {
        // var replayFile = lime.utils.Assets.getText(FNFAssets.ReplayPath('replay.rpl'));
    }

    public function toString():String {
        var inputsString:String = "";
        for (i in 0...inputs.length) {
            if (i >= inputs.length) {
                inputStrings.push(inputs[i].noteData + "," + inputs[i].strumTime + "," + inputs[i].holdTime);
            }
            else {
                inputStrings.push(inputs[i].noteData + "," + inputs[i].strumTime + "," + inputs[i].holdTime + ",");
            }   
        }
        for (i in 0...inputStrings.length) {
            inputsString += inputStrings[i];
        }
        return inputsString;
    }
}

class ReplayInput {
    public var noteData:Int;
    public var strumTime:Float;
    public var holdTime:Float;

    public function new(data:Int, time:Float, hold:Float) {
        this.noteData = data;
        this.strumTime = time;
        this.holdTime = hold;
    }
}

class ReplayParser {
    public var inputs:Array<ReplayInput> = [];
    var inputsStrings:Array<String> = [];
    var inputFile:String = "";

    var directions:Array<Int> = [];
    var times:Array<Float> = [];
    var holds:Array<Float> = [];

    public function new(dataPath:String = 'replay.rpl') {
        var curElement:Int = 0;
        //if (lime.utils.Assets.exists(FNFAssets.ReplayPath('replay.rpl'))) {
            inputFile = Assets.getText("assets/replays/replay.rpl");
        //}
        inputsStrings = inputFile.split(',');
        for (i in 0...inputsStrings.length) {
            switch (curElement) {
				case 0:
					directions.push(Std.parseInt(inputsStrings[i]));
				case 1:
					times.push(Std.parseInt(inputsStrings[i]));
				case 2:
					holds.push(Std.parseFloat(inputsStrings[i]));
			}	
			if (curElement >= 2) {
				curElement = 0;
			}
			else {
				curElement++;
			}
        }
        for (i in 0...times.length) {
            inputs.push(new ReplayInput(directions[i], times[i], holds[i]));
        }
        for (i in 0...inputs.length) {
            trace("Directions: " + inputs[i].noteData);
            trace("Time: " + inputs[i].strumTime);
            trace("Hold Time: " + inputs[i].holdTime);
        }
    }
}