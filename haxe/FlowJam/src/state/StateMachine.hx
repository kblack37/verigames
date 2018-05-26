package state;
import state.IState;
import starling.display.Sprite;

/**
 * ...
 * @author kristen autumn blackburn
 */
class StateMachine extends Sprite implements IStateMachine {
	
	private var m_currentState : IState;
	
	private var m_states : Array<IState>;

	public function new() {
		super();
		
		m_states = new Array<IState>();
	}
	
	public function getSprite() : Sprite {
		return this;
	}
	
	public function registerState(state : IState) : Void {
		m_states.push(state);
	}
	
	public function getCurrentState() : IState {
		return m_currentState;
	}
	
	public function getStateInstance(stateClass : Class<Dynamic>) : IState {
		var stateInstance : IState = null;
		for (state in m_states) {
			if (Type.getClass(state) == stateClass) {
				stateInstance = state;
				break;
			}
		}
		
		return stateInstance;
	}
	
	public function changeState(state : IState) : Void {
		var exitParams : Dynamic = {};
		if (m_currentState != null) {
			removeChild(m_currentState.getSprite());
			exitParams = m_currentState.exit(state);
		}
		
		addChild(state.getSprite());
		state.enter(m_currentState, exitParams);
		m_currentState = state;
	}
	
}