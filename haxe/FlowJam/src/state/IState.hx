package state;

/**
 * States are the largest groupings of game logic. They are swapped between
 * by the state machine and can pass parameters between each other
 * 
 * @author kristen autumn blackburn
 */
interface IState {
	/**
	 * Initializes and begins running this state
	 * @param	from	The state transitioning into this one
	 * @param	params	Any parameters that need to be passed into this state
	 */
	public function enter(from : IState, params : Dynamic) : Void;
	
	/**
	 * Disposes this state and returns any params to be passed to the next state
	 * @param	to	The state being transitioned to
	 * @return	Any parameters the next state may need as an anonymouse structure
	 */
	public function exit(to : IState) : Dynamic;
	
	/**
	 * Called every frame
	 */
	public function update() : Void;
}