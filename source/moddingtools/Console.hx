package moddingtools;

import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxInputText;
import flixel.input.keyboard.FlxKeyboard;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class Console extends FlxState {
    public var log:FlxText;
    var inputText:FlxInputText;
    var acceptsInput:Bool = true;

    public function new() {
        super();
        log = new FlxText(4, 4, FlxG.width, "", 24, true);
        inputText = new FlxInputText(0, FlxG.height - 8 - 24, FlxG.width, "", 24, true);
        add(log);
        add(inputText);
        inputText.hasFocus = true;
        addLog("Starting console...\n");
        addLog("NoteEngine-ModdingTools, v0.1\n");
        addLog("Welcome! Type 'help' for list of commands\n");
        addLog("\n");
        addLog("mods:/>");
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ENTER && acceptsInput) {
            passCommand();
        }
        super.update(elapsed);
    }

    function addLog(text:String) {
        if (log.height > FlxG.height - 32) log.y -= 32;
        log.text += text;
    }

    function passCommand() {
        acceptsInput = false;
        var commandString:String = inputText.text;
        addLog(inputText.text);
        addLog("\n");
        switch (commandString) {
            case 'help':
                addLog("help, mod (new/open/save), lua (new/open/save), chart, exit\n");
                addLog("\n");
                addLog("mods:/>");
                
            case 'mod new':
            case 'mod open':
            case 'mod save':
            case 'lua new':
            case 'lua open':
            case 'lua save':
            case 'chart':
            case 'exit':
                FlxG.switchState(new MainMenuState());
            default:
                addLog("\n");
                addLog("Unrecognized command: " + commandString);
                addLog("\n\n");
                addLog("mods:/>");
        }
        acceptsInput = true;
    }
}