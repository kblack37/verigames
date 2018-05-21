package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import events.MiniMapEvent;
/**
 * ...
 * @author ...
 */
class WorldMiniMapScript extends ScriptNode 
{
	private var gameEngine : IGameEngine;
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		this.gameEngine = gameEngine;
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
}