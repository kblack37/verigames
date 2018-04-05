package events;

import flash.geom.Point;
import starling.events.Event;

class MouseWheelEvent extends Event
{
    public static inline var MOUSE_WHEEL : String = "mouse_wheel";
    
    public var mousePoint : Point;
    public var delta : Float;
    public var time : Float;
    
    public function new(_mousePoint : Point, _delta : Float, _time : Float)
    {
        super(MOUSE_WHEEL, true);
        
        mousePoint = _mousePoint;
        delta = _delta;
        time = _time;
    }
}

