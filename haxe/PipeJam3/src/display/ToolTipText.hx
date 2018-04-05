package display;

import haxe.Constraints.Function;
import scenes.game.display.Level;
import starling.display.DisplayObject;
import starling.display.Sprite;

class ToolTipText extends TextBubbleFollowComponent
{
    private static inline var ACTIVE_FONT_SZ : Float = 8;
    private static inline var PERSISTENT_FONT_SZ : Float = 10;
    private static inline var INSET : Float = 1.5;
    private static inline var OUTLINE_CLR : Int = 0x0;
    private static inline var OUTLINE_WEIGHT : Float = 2;
    
    public function new(text : String, level : Level, persistent : Bool, pointAtFunction : Function, pointFrom : String = Constants.TOP_LEFT, pointTo : String = Constants.CENTER)
    {
        var fontSz : Int = (persistent) ? PERSISTENT_FONT_SZ : ACTIVE_FONT_SZ;
        var textColor : Int = (persistent) ? 0x0 : 0xFFFFFF;
        var inset : Float = fontSz / 6.0;
        
        super(pointAtFunction, level, text, fontSz, textColor, pointFrom, pointTo, null, fontSz / 1.5, 0, 0, INSET, false, textColor, OUTLINE_WEIGHT, OUTLINE_CLR);
    }
}

