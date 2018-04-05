package events;

import flash.geom.Point;
import starling.events.Event;
import scenes.game.display.GameComponent;

class MoveEvent extends GameComponentEvent
{
    public var delta(get, never) : Point;

    public static inline var MOVE_EVENT : String = "move_event";
    public static inline var FINISHED_MOVING : String = "FINISHED_MOVING";
    public static inline var MOUSE_DRAG : String = "mouse_drag";
    public static inline var MOVE_TO_POINT : String = "move_to_point";
    
    public var startLoc : Point;
    public var endLoc : Point;
    private var m_delta : Point;
    
    public function new(_type : String, _component : GameComponent, _startLoc : Point = null, _endLoc : Point = null)
    {
        super(_type, _component);
        
        startLoc = _startLoc;
        endLoc = _endLoc;
    }
    
    private function get_delta() : Point
    {
        if (m_delta == null && startLoc != null && endLoc != null)
        {
            m_delta = endLoc.subtract(startLoc);
        }
        return m_delta;
    }
}
