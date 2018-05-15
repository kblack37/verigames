package engine.systems;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import engine.scripting.ScriptStatus;

/**
 * Base system doesn't do much for now besides always return that it's running
 * 
 * @author kristen autumn blackburn
 */
class BaseSystem extends ScriptNode {
	
	private var m_gameEngine : IGameEngine;
	
	public function new(gameEngine : IGameEngine, id : String = null) {
		super(id);
		
		m_gameEngine = gameEngine;
	}
	
	override public function visit() : Int {
		return ScriptStatus.RUNNING;
	}
}