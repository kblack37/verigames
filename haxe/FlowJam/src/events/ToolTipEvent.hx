package events;

import flash.geom.Point;
import scenes.game.display.GameComponent;
import starling.display.Sprite;
import starling.events.Event;

class ToolTipEvent extends Event
{
    public static inline var ADD_TOOL_TIP : String = "ADD_TOOL_TIP";
    public static inline var CLEAR_TOOL_TIP : String = "CLEAR_TOOL_TIP";
    public var component : Sprite;
    public var text : String;
    public var fontSize : Float;
    public var persistent : Bool;
    public var point : Point;
    
    public function new(type : String, _component : Sprite, _text : String = "", _fontSize : Float = 8, _persistent : Bool = false, _pt : Point = null)
    {
        super(type, true);
        component = _component;
        text = _text;
        fontSize = _fontSize;
        persistent = _persistent;
        point = _pt;
    }
}
