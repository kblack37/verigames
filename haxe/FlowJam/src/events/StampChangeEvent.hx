package events;

import flash.events.Event;
import graph.EdgeSetRef;

class StampChangeEvent extends Event
{
    public var edgeSetChanged : EdgeSetRef;
    
    public static inline var STAMP_ACTIVATION : String = "STAMP_ACTIVATION";
    
    public function new(type : String, _edgeSetChanged : EdgeSetRef)
    {
        super(type, false, false);
        edgeSetChanged = _edgeSetChanged;
    }
}
