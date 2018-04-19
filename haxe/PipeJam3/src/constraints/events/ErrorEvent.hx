package constraints.events;

import flash.utils.Dictionary;
import starling.events.Event;

class ErrorEvent extends Event
{
    public static inline var ERROR_ADDED : String = "error_added";
    public static inline var ERROR_REMOVED : String = "error_removed";
    
    public var constraintChangeDict : Dynamic;
    
    public function new(type : String, _constraintChangeDict : Dynamic)
    {
        super(type);
        constraintChangeDict = _constraintChangeDict;
    }
}

