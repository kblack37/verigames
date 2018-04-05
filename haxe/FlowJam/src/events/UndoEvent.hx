package events;

import scenes.BaseComponent;
import starling.events.Event;

class UndoEvent extends Event
{
    public static var UNDO_EVENT : String = "undo_event";
    
    public var component : BaseComponent;
    public var eventsToUndo : Array<Event>;
    
    public var levelEvent : Bool = false;
    public var addToLast : Bool = false;
    public var addToSimilar : Bool = false;
    
    public function new(_eventToUndo : Event, _component : BaseComponent)
    {
        super(UNDO_EVENT, true);
        component = _component;
        eventsToUndo = new Array<Event>();
        eventsToUndo.push(_eventToUndo);
    }
}
