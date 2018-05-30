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
	private var gridView : GridViewPanel;
	
	public function new(gameEngine: IGameEngine,id:String=null) 
	{
		super(id);
		gridView = try cast(gameEngine.getUIComponent("gridViewPanel"), GridViewPanel) catch (e : Dynamic) null;
		gameEngine.addEventListener(GameComponentEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
	}
	
	private function onCenterOnComponentEvent(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            .centerOnComponent(component);
        }
    }
	
	public function override dispose(){
		super.dispose();
		gameEngine.removeEventListener(GameComponentEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
	}
}