package cgs.teacherportal;

import cgs.teacherportal.IActivityLogger;

/**
 * Interface implemented by the user to facilitate Copilot result reporting
 */
interface ICopilotLogger
{
    
    /**
     * Activity logger getter.
     */
    var activityLogger(get, never) : IActivityLogger;

    /**
     * Registers an activity logger. Used to start copilot logging.
     * @param logger
     */
    function setActivityLogger(logger : IActivityLogger) : Void
    ;
    
    /**
     * Deregisters activity logger. Used to stop copilot logging.
     */
    function clearActivityLogger() : Void
    ;
    
    /**
		 * Begin a Problem Set.  If the log has not been started yet, this will take care of it.
		 * 
     * @param problemSetGuid (required) - unique ID of the problem set
		 * @param problemCount (optional) - the number of problems in the problem set. Negative numbers denote unknown value.
     * @param details (optional) - game specific information about the problem set known at start
		 **/
    function logProblemSetStart(problemSetGuid : String, problemCount : Int = -1, details : Dynamic = null) : Void
    ;
    
    /**
		 * End a Problem Set.  If not called before beginning a new set, then Problem Set not updated.
		 *                     Not critical but poor practice.
     * @param details (optional) - game specific indormation about the problem set known at end
		 **/
    function logProblemSetEnd(details : Dynamic = null) : Void
    ;
    
    /**
     * Logs a problem result
     * @param result - value in range [0, 1] representing the result
     *          0 - complete failure (0%)
     *          1 - complete success (100%)
     * @param problemPartList - optional list of concept strings that this problem tests. Null is converted to [].
     * @param problemData - widget-specific data about problem. Null is converted to {}.
     * @param details - optional data about this problem. Null is converted to {}.
     */
    function logProblemResult(result : Float, problemPartList : Array<Dynamic> = null, problemData : Dynamic = null, details : Dynamic = null) : Void
    ;
}
