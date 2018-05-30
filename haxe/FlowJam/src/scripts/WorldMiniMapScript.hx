package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import events.MiniMapEvent;
import scenes.game.components.MiniMap;
import state.FlowJamGameState;
/**
 * ...
 * @author ...
 */
class WorldMiniMapScript extends ScriptNode 
{
	private var gameEngine : IGameEngine;
	private var miniMap : MiniMap;
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		this.gameEngine = gameEngine;
		miniMap = cast (gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().getMiniMap()
		gameEngine.addEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
        gameEngine.addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
        gameEngine.addEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
	}
	
	private function onErrorsMoved(event : MiniMapEvent) : Void
    {
        if (miniMap != null)
        {
            miniMap.isDirty = true;
        }
    }
	
	private function onViewspaceChanged(event : MiniMapEvent) : Void
    {
        miniMap.onViewspaceChanged(event);
    }
	
	private function onLevelResized(event : MiniMapEvent) : Void
    {
        if (miniMap != null)
        {
            miniMap.isDirty = true;
        }
    }
	
	public function override dispose(){
		super.dispose();
		gameEngine.removeEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
        gameEngine.removeEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
        gameEngine.removeEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
	}
}