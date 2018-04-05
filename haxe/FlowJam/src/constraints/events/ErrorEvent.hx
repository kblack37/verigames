package constraints.events;

import constraints.Constraint;
import starling.events.Event;

class ErrorEvent extends Event
{
    public static inline var ERROR_ADDED : String = "error_added";
    public static inline var ERROR_REMOVED : String = "error_removed";
    
    public var constraintError : Constraint;
    
    public function new(type : String, _constraintError : Constraint)
    {
        super(type);
        constraintError = _constraintError;
    }
}

