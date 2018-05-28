package state;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import engine.scripting.selectors.AllSelector;
import openfl.events.Event;
import starling.display.Sprite;

/**
 * The base state that all states should subclass
 * 
 * @author kristen autumn blackburn
 */
class BaseState extends Sprite implements IState {
	
	private var m_gameEngine : IGameEngine;
	
	private var m_scriptRoot : ScriptNode;

	public function new(gameEngine : IGameEngine) {
		super();
		
		m_gameEngine = gameEngine;
		
		m_scriptRoot = new AllSelector();
	}
	
	/**
	 * @return	This as a sprite; used to add display objects to as a base
	 */
	public function getSprite() : Sprite {
		return this;
	}
	
	public function enter(from : IState, params : Dynamic) {
		
	}
	
	public function exit(to : IState) : Dynamic {
		return null;
	}
	
	public function update() {
		m_scriptRoot.visit();
	}
}