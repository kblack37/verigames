package cgs.teacherportal;


/**
 * Responsible for handling all logging related to an activity started
 * by the copilot.
 */
interface IActivityLogger
{
    
    /**
     * Returns the current activity guid
     */
    var dynamicActivityId(get, never) : String;

    
    /**
     * Logs start of problem set
     * @param uid - User ID of the problem set. Each User may have only one active Problem Set at any given time.
     * @param psid - ID of a problem set.
     * @param problemCount - number of problems in this set (negative value denotes unknown number).
     * @param problemSetData - widget-specific data about problem set. Null is converted to {}.
     * @param details - optional data about this problem set. Null is converted to {}.
     */
    function logProblemSetStart(uid : String, psid : String, problemCount : Int = -1, problemSetData : Dynamic = null, details : Dynamic = null) : Void
    ;
    
    /**
     * Logs end of problem set
     * @param uid - User ID of the problem set.
     * @param problemSetData - widget-specific data about problem set. Null is converted to {}.
     * @param details - optional data about problem set. Null is converted to {}.
     */
    function logProblemSetEnd(uid : String, problemSetData : Dynamic = null, details : Dynamic = null) : Void
    ;
    
    /**
     * Logs a problem result
     * @param uid - User ID of the problem.
     * @param result - value in range [0, 1] representing the result
     *          0 - complete failure (0%)
     *          1 - complete success (100%)
     * @param problemPartList - optional list of concept strings that this problem tests. Null is converted to [].
     * @param problemData - widget-specific data about problem. Null is converted to {}.
     * @param details - optional data about this problem. Null is converted to {}.
     */
    function logProblemResult(uid : String, result : Float, problemPartList : Array<Dynamic> = null, problemData : Dynamic = null, details : Dynamic = null) : Void
    ;
}
