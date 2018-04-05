package events;

import networkGraph.Edge;
import networkGraph.StampRef;
import flash.events.Event;

class StampChangeEvent extends Event
{
    public var stamp_ref : StampRef;
    public var associated_edge : Edge;
    
    public static inline var STAMP_ACTIVATION : String = "STAMP_ACTIVATION";
    public static inline var STAMP_SET_CHANGE : String = "STAMP_SET_CHANGE";
    
    public function new(type : String, _stamp_ref : StampRef = null, e : Edge = null)
    {
        super(type, false, false);
        stamp_ref = _stamp_ref;
        associated_edge = e;
    }
    
    override public function clone() : Event
    {
        return new StampChangeEvent(type, stamp_ref, associated_edge);
    }
}

