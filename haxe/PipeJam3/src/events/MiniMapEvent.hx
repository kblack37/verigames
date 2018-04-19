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
    
    public function new(_type : String,
		_contentX : Float = -1,
		_contentY : Float = -1,
		_contentScale : Float = -1,
		_level : Level = null)
    {
        super(_type, true);
        contentX = _contentX < 0 ? Math.NaN : _contentX;
        contentY = _contentY < 0 ? Math.NaN : _contentY;
        contentScale = _contentScale < 0 ? Math.NaN : _contentScale;
        level = _level;
    }
}

