package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import scenes.game.components.MiniMap;
import constraints.events.ErrorEvent;
import scenes.game.display.Level;
import state.FlowJamGameState;
import openfl.errors.Error;
import scenes.game.components.GridViewPanel;
/**
 * ...
 * @author ...
 */
class WorldErrorScript extends ScriptNode 
{
	private var errorDict : Dynamic;
	private var active_level : Level;
	private var miniMap : MiniMap;
	private var gameEngine : IGameEngine;

	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		this.gameEngine = gameEngine;
		errorDict = {};
		
		active_level = cast (gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().getActiveLevel();
		miniMap = try cast(gameEngine.getUIComponent("minimap"), MiniMap) catch (e : Dynamic) null;
		gameEngine.addEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
		gameEngine.addEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
		
	}
	private function onErrorAdded(event : ErrorEvent) : Void
    {
        if (active_level != null)
        {
            var edgeLayout : Dynamic = Reflect.field(active_level.edgeLayoutObjs, event.constraintError.id);
            if (edgeLayout == null)
            {
                throw new Error("No layout found for constraint with error:" + event.constraintError.id);
            }
            if (miniMap != null)
            {
                miniMap.errorConstraintAdded(edgeLayout);
            }
        }
    }
    
    private function onErrorRemoved(event : ErrorEvent) : Void
    {
        if (active_level != null)
        {
            var edgeLayout : Dynamic = Reflect.field(active_level.edgeLayoutObjs, event.constraintError.id);
            if (edgeLayout == null)
            {
                throw new Error("No layout found for constraint with error:" + event.constraintError.id);
            }
            if (miniMap != null)
            {
                miniMap.errorRemoved(edgeLayout);
            }
        }
    }
	override public function dispose(){
		super.dispose();
		
		gameEngine.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
		gameEngine.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
	}
}