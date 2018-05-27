package scripts;

import engine.scripting.ScriptNode;
import events.GameComponentEvent;
import engine.IGameEngine;
import scenes.game.components.GridViewPanel;
import scenes.game.display.GameComponent;
/**
 * ...
 * @author ...
 */
class WorldCenterComponentScript extends ScriptNode 
{
	var gridView : GridViewPanel;
	public function new(gameEngine: IGameEngine,id:String=null) 
	{
		super(id);
		//TODO get gridview from this
		gridView = gameEngine.getStateMachine().getStateInstance(Type.getClass("FlowJamGameState"))
		gameEngine.addEventListener(GameComponentEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
	}
	private function onCenterOnComponentEvent(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            gridView.edgeSetGraphViewPanel.centerOnComponent(component);
        }
    }
}