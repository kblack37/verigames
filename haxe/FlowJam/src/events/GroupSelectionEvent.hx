package events;

import scenes.game.display.GameComponent;
import starling.events.Event;

class GroupSelectionEvent extends GameComponentEvent
{
    public static var GROUP_SELECTED : String = "group_selected";
    public static var GROUP_UNSELECTED : String = "group_unselected";
    
    public var selection : Array<GameComponent>;
    
    public function new(_type : String, _component : GameComponent, _selection : Array<GameComponent> = null)
    {
        super(_type, _component);
        if (_selection == null)
        {
            _selection = new Array<GameComponent>();
        }
        selection = _selection;
    }
}

