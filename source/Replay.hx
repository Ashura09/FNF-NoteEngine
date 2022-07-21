import Assets.FNFAssets;

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
                inputStrings.push(inputs[i].noteData + "," + inputs[i].strumTime + "," + inputs[i].holdTime + ":");
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