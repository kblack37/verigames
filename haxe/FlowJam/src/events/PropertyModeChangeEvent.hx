package events;

import starling.events.Event;

class PropertyModeChangeEvent extends Event
{
    public static inline var PROPERTY_MODE_CHANGE : String = "PROPERTY_MODE_CHANGE";
    
    public var prop : String;
    public function new(_type : String, _property : String)
    {
        super(_type, true);
        prop = _property;
    }
}

