package events;

import constraints.ConstraintVar;
import flash.geom.Point;
import scenes.game.display.Level;
import starling.events.Event;

class WidgetChangeEvent extends Event
{
    public static inline var LEVEL_WIDGET_CHANGED : String = "LEVEL_WIDGET_CHANGED";
    
    public var varChanged : ConstraintVar;
    public var prop : String;
    public var propValue : Bool;
    public var level : Level;
    public var pt : Point;
    public var record : Bool;
    
    public function new(type : String, _varChanged : ConstraintVar, _prop : String, _propValue : Bool, _level : Level, _pt : Point, _record : Bool = true)
    {
        super(type, true);
        varChanged = _varChanged;
        prop = _prop;
        propValue = _propValue;
        level = _level;
        pt = _pt;
        record = _record;
    }
}

