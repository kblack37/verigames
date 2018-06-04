package scripts;

import constraints.events.ErrorEvent;
import engine.IGameEngine;
import engine.scripting.ScriptNode;
import scenes.game.components.MiniMap;

/**
 * ...
 * @author kristen autumn blackburn
 */
class ErrorScript extends ScriptNode {
	
	private var errorConstraintDict : Dynamic;
	
	private var m_minimap : MiniMap;
	
	private var m_gameEngine : IGameEngine;

	public function new(gameEngine : IGameEngine, id:String=null) {
		super(id);
		
		errorConstraintDict = {};
		
		gameEngine.addEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
		gameEngine.addEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
		
		m_gameEngine = gameEngine;
	}
	
	private function onErrorAdded(evt : ErrorEvent) : Void
    {
        Reflect.setField(errorConstraintDict, evt.constraintError.id, evt.constraintError);
    }
    
    private function onErrorRemoved(evt : ErrorEvent) : Void
    {
		Reflect.deleteField(errorConstraintDict, evt.constraintError.id);
    }
	override public function dispose(){
		super.dispose();
		
		m_gameEngine.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
		m_gameEngine.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
	}
}