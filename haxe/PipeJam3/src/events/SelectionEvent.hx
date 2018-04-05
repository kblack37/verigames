package events;

import starling.events.Event;

class SelectionEvent extends Event
{
    public static var COMPONENT_SELECTED : String = "component_selected";
    public static var COMPONENT_UNSELECTED : String = "component_unselected";
    
    public static var NUM_SELECTED_NODES_CHANGED : String = "num_sel_nodes_changed";
    
    public static var BRUSH_CHANGED : String = "brush_changed";
    
    public static var ITEM_CLICKED : String = "item_clicked";
    
    public var selection : Array<Dynamic>;
    public var component : Dynamic;
    
    public function new(_type : String, _component : Dynamic, _selection : Array<Dynamic> = null)
    {
        super(_type, true);
        component = _component;
        if (_selection == null)
        {
            _selection = new Array<Dynamic>();
        }
        selection = _selection;
    }
}

