package dialogs;

import haxe.Constraints.Function;
import flash.geom.Point;
import scenes.game.display.TutorialManagerTextInfo;

class RankProgressDialogInfo extends TutorialManagerTextInfo
{
    public var fadeTimeSeconds : Float;
    public var button1String : String;
    public var button1Callback : Function;
    
    public function new(_text : String, _fadeTimeSeconds : Float, _size : Point, _button1String : String = "", _button1Callback : Function = null)
    {
        super(_text, _size, null, null, null);
        
        fadeTimeSeconds = _fadeTimeSeconds;
        button1String = _button1String;
        button1Callback = _button1Callback;
    }
}
