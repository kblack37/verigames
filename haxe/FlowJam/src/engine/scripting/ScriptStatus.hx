package engine.scripting;

/**
 * @author kristen autumn blackburn
 */
class ScriptStatus {
	/**
	 * Returned when a script can't complete its function
	 */
	public static inline var FAIL : Int = 0;
	
	/**
	 * Returned when a script's functionality fires during a frame
	 */
	public static inline var SUCCESS : Int = 1;
	
	/**
	 * Returned when a script's functionality doesn't fire during a frame
	 */
	public static inline var RUNNING : Int = 2;
	
	/**
	 * Returned when a script wants to interrupt other scripts in certain selectors
	 */
	public static inline var INTERRUPT : Int = 3;
	
	/**
	 * Returned when something goes awfully wrong during a script's execution
	 */
	public static inline var ERROR : Int = 4;
}