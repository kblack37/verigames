package scripts;

import engine.scripting.ScriptNode;
import events.GameComponentEvent;
import engine.IGameEngine;
/**
 * ...
 * @author ...
 */
class WorldCenterComponentScript extends ScriptNode 
{

	public function new(gameEngine: IGameEngine,id:String=null) 
	{
		super(id);
		gameEngine.addEventListener(GameComponentEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
	}
	private function onCenterOnComponentEvent(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            edgeSetGraphViewPanel.centerOnComponent(component);
        }
    }
}