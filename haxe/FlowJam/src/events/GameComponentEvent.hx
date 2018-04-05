package events;

import scenes.game.display.GameComponent;
import starling.events.Event;

class GameComponentEvent extends Event
{
    public static var COMPONENT_SELECTED : String = "component_selected";
    public static var COMPONENT_UNSELECTED : String = "component_unselected";
    public static var CENTER_ON_COMPONENT : String = "center_on_component";
    
    public var component : GameComponent;
    
    public function new(_type : String, _component : GameComponent)
    {
        component = _component;
        super(_type, true);
    }
}

