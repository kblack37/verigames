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
	
	private var m_gameEngine : IGameEngine;
	
	public function new(gameEngine: IGameEngine,id:String=null) 
	{
		super(id);
		gridView = try cast(gameEngine.getUIComponent("gridViewPanel"), GridViewPanel) catch (e : Dynamic) null;
		gameEngine.addEventListener(GameComponentEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
		
		m_gameEngine = gameEngine;
	}
	
	private function onCenterOnComponentEvent(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            gridView.centerOnComponent(component);
        }
    }
	
	override public function dispose(){
		super.dispose();
		m_gameEngine.removeEventListener(GameComponentEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
	}
}