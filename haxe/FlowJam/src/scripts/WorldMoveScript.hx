package scripts;

import engine.scripting.ScriptNode;
import engine.IGameEngine;
import events.MoveEvent;
import scenes.game.components.GridViewPanel;
/**
 * ...
 * @author ...
 */
class WorldMoveScript extends ScriptNode 
{
	private var m_gameEngine : IGameEngine;
	
	//will get edgesSetGraphViewPanel from some state
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		gameEngine.addEventListener(MoveEvent.MOVE_TO_POINT, onMoveToPointEvent);
		m_gameEngine = gameEngine;
	}
	
	private function onMoveToPointEvent(evt : MoveEvent) : Void
    {
		var edgeSetGraphViewPanel : GridViewPanel = 
			try cast(m_gameEngine.getUIComponent("gridViewPanel"), GridViewPanel) catch (e : Dynamic) null;
        edgeSetGraphViewPanel.moveToPoint(evt.startLoc);
    }
	
}