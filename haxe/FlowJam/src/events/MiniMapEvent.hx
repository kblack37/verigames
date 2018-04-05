package events;

import flash.geom.Rectangle;
import scenes.game.display.Level;
import starling.events.Event;

class MiniMapEvent extends Event
{
    public static inline var VIEWSPACE_CHANGED : String = "VIEWSPACE_CHANGED";
    public static inline var ERRORS_MOVED : String = "ERRORS_MOVED";
    public static inline var LEVEL_RESIZED : String = "LEVEL_RESIZED";
    
    public var contentX : Float;
    public var contentY : Float;
    public var contentScale : Float;
    public var level : Level;
    
    public function new(_type : String, _contentX : Float = Math.NaN, _contentY : Float = Math.NaN, _contentScale : Float = Math.NaN, _level : Level = null)
    {
        super(_type, true);
        contentX = _contentX;
        contentY = _contentY;
        contentScale = _contentScale;
        level = _level;
    }
}

