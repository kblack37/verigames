package state;
import display.ISprite;

/**
 * The state machine is responsible for cleanly transitioning between game states
 * 
 * @author kristen autumn blackburn
 */
interface IStateMachine extends ISprite {
	/**
	 * Registers a new state to this state machine to be retrived later 
	 * @param	state	The new state to register
	 */
	public function registerState(state : IState) : Void;
	
	/**
	 * @return	The currently running state
	 */
	public function getCurrentState() : IState;
	
	/**
	 * Returns the state instance with the given class, if it exists
	 * @param	stateClass	The class object of the desired state
	 * @return	The state, if it exists
	 */
	public function getStateInstance(stateClass : Class<Dynamic>) : IState;
	
	/**
	 * Changes the current state to the the one passed in; calls exit on the
	 * current state and passes those parameters to enter of the given state
	 * @param	state	The state to change to
	 */
	public function changeState(state : IState) : Void;
}