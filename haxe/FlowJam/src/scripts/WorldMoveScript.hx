package scripts;

import engine.scripting.ScriptNode;
import engine.IGameEngine;
import events.MoveEvent;
/**
 * ...
 * @author ...
 */
class WorldMoveScript extends ScriptNode 
{

	//will get edgesSetGraphViewPanel from some state
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		gameEngine.addEventListener(MoveEvent.MOVE_TO_POINT, onMoveToPointEvent);
		
	}
	
	private function onMoveToPointEvent(evt : MoveEvent) : Void
    {
        edgeSetGraphViewPanel.moveToPoint(evt.startLoc);
    }
	
}