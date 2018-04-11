package cgs.user;

import cgs.cache.ICgsUserCache;
import cgs.achievement.ICgsAchievementManager;
import cgs.server.responses.CgsUserResponse;
import cgs.homeplays.data.UserHomeplaysData;
import cgs.server.abtesting.ICgsUserAbTester;
import cgs.server.data.IUserTosStatus;
import cgs.server.logging.IMultiplayerLoggingService;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.actions.UserAction;
import cgs.server.logging.messages.UserFeedbackMessage;
import cgs.server.logging.requests.RequestDependency;
import cgs.teacherportal.ICopilotLogger;
import cgs.teacherportal.data.QuestPerformance;

typedef AuthenticationCallback = CgsUserResponse -> Void;

interface ICgsUser extends ICgsUserCache extends ICgsUserAbTester extends ICgsAchievementManager extends ICopilotLogger
{
    
    
    /**
		 * Indicates if the user is valid for full user. This will be true
		 * after the complete callback is called with success.
		 */
    var isValid(get, never) : Bool;    
    
    /**
		 * Get the unique identifier for the user.
		 */
    var userId(get, never) : String;    
    
    var isUidValid(get, never) : Bool;    
    
    /**
     * Update the lesson id used when logging.
     */
    var lessonId(never, set) : String;    
    
    /**
		 * Get the username for the user.
		 */
    var username(get, never) : String;    
    
    /**
		 * Get the session identifier for the user.
		 */
    var sessionId(get, never) : String;    
    
    /**
		 * Set the condition the user is in.
		 */
    
    
    /**
		 * Get the condition the user is in.
		 */
    var conditionId(get, set) : Int;    
    
    /**
     * Get the number of times the user has played the game based on pageloads.
     * Includes the current pageload of session.
     */
    var userPlayCount(get, never) : Int;    
    
    /**
     * Get the number of times the user has played the game based on pageloads.
     * Does not include the pageload of the current session.
     */
    var userPreviousPlayCount(get, never) : Int;    
    
    var languageCode(get, never) : String;    
    
    var uidRequestDependency(get, never) : RequestDependency;    
    
    //
    // Tos handling.
    //
    
    var tosRequired(get, never) : Bool;    
    
    var tosStatus(get, never) : IUserTosStatus;    
    
    //
    // Logging properties handling.
    //
    
    var gameQuestId(never, set) : Int;

    function retryAuthentication(
            username : String, password : String, callback : AuthenticationCallback = null) : Void
    ;
    
    //
    // Logging related functions.
    //
    
    /**
		 * Log the start of a quest. This assumes that there is no
     * valid dqid for the quest and one will be requested from the server.
     * This function should only be used in a multiplayer game. The parentDqid
     * value should be the dqid value of the quest being logged on the server.
		 *
		 * @param questID the id of the quest as defined on the server.
		 * @param details properties to be logged with the quest start.
		 * @param parentDqid dqid of the quest being logged on the server.
		 * @param callback function to be called when the dqid
     * is returned from the server.
		 * Function should have the signature of (dqid:String, failed:Boolean).
		 * @param aeSeqID used in conjection with the Assessment engine.
		 * @param localDQID optional parameter for a local unique quest id.
		 *
		 * @return localDQID which can be used to log actions for the quest.
     * If your game only has one active quest at a time, you do not
     * need to pass the localDQID to log actions.
		 */
    function logMultiplayerQuestStart(
            questId : Int, questHash : String, details : Dynamic,
            callback : Dynamic = null, localDqid : Int = -1) : Int
    ;
    
    function logQuestStartWithDqid(
            questID : Int, questHash : String, dqid : String,
            details : Dynamic, localDQID : Int = -1) : Int
    ;
    
    function logQuestStart(
            questId : Int, questHash : String, details : Dynamic,
            callback : Dynamic = null, localDqid : Int = -1) : Int
    ;
    
    /**
		 * Log a quest action that is related to a multiplayer quest.
     * This function should be used if the action is being logged on the client.
		 *
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param localDqid the localDQID for the quest that this
     * action should be logged under. Only needed if there is more than
     * one active quest for which actions are being logged.
		 * @param forceFlush indicates if the actions buffer should be
     * flushed after the passed action is added to the actions buffer.
		 */
    function logMultiplayerQuestAction(
            action : QuestAction, localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    /**
		 * Log a quest action that is related to a multiplayer quest.
     * This function should be used if the action is being logged on
     * the server for a specific user.
		 *
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param multiSeqId the sequence id, dictated by the server,
     * that is used to interleave multiple client actions.
		 * @param multiUid the uid for the user that action relates to.
		 * @param localDqid the localDQID for the quest that this action
     * should be logged under. Only needed if there is more than one active quest
     * for which actions are being logged.
		 * @param forceFlush indicates if the actions buffer should be flushed
     * after the passed action is added to the actions buffer.
		 */
    function logServerMultiplayerQuestAction(
            action : QuestAction, multiUid : String,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    function logQuestAction(
            action : QuestAction, localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    function flushActions(localDqid : Int = -1, callback : Dynamic = null) : Void
    ;
    
    function logQuestScore(
            score : Int, callback : Dynamic = null, localDqid : Int = -1) : Void
    ;
    
    function logMultiplayerQuestEnd(
            details : Dynamic, callback : Dynamic = null, localDqid : Int = -1) : Void
    ;
    
    function logQuestEnd(
            details : Dynamic, callback : Dynamic = null, localDQID : Int = -1) : Void
    ;
    
    function logForeignQuestStart(
            dqid : String, foreignGameId : Int, foreignCategoryId : Int,
            foreignVersionId : Int, foreignConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null) : Void
    ;
    
    function logLinkedQuestStart(
            questId : Int, questHash : String, linkGameId : Int, linkCategoryId : Int,
            linkVersionId : Int, linkConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null) : Int
    ;
    
    function submitFeedback(
            feedback : UserFeedbackMessage, callback : Dynamic = null) : Void
    ;
    
    function logScore(score : Int, questId : Int, callback : Dynamic = null) : Void
    ;
    
    /**
		 * @param action
		 * @param callback
		 */
    function logMultiplayerAction(
            action : UserAction, callback : Dynamic = null) : Void
    ;
    
    /*function logServerMultiplayerAction(
    action:UserAction, multiUid:String, callback:Dynamic = null):void;*/
    
    function logAction(action : UserAction, callback : Dynamic = null) : Void
    ;
    
    //
    // User releated functions.
    //
    
    /**
     * Check if a username is available for a user. This function will not check
     * if a student username is available.
     */
    function checkUserNameAvailable(name : String, userCallback : Dynamic) : Void
    ;
    
    /**
     * Register this user as a student (which will bind the account to a teacher
     * entity and possibly save additional demographic information about this user)
     * 
     * @param props
     *      Need props to initialize the server
     * @param username
     * @param teacherCode
     *      The teacher that the user should be assigned to
     * @param grade
     *      0 is unset
     * @param gender
     *      1 for female, 2 for male, 0 is unset
     * @param callback
     *      Callback returning whether the register attempt succeeded or failed
     */
    function registerStudent(props : ICgsUserProperties,
            username : String,
            teacherCode : String,
            grade : Int,
            gender : Int,
            callback : Dynamic) : Void
    ;
    
    /**
     * Update the grade and gender information for an existing student
     * 
     * @param grade
     *      0 is unset
     * @param gender
     *      1 for female, 2 for male, 0 is unset
     * @param callback
     *      Callback when the update is finished
     */
    function updateStudent(username : String,
            teacherCode : String,
            gradeLevel : Int,
            gender : Int,
            callback : Dynamic) : Void
    ;
    
    /**
     * Create an account for the current user. This can only be called if the user
     * does not currently have an account.
     * 
     * One usage for this is if a user plays anonymously for a short time and then
     * can optionally create an account when they want to save their progress.
     * 
     * @param callback
     *      Signature callback(response:CgsResponseStatus)
     */
    function createAccount(username : String,
            password : String,
            email : String,
            grade : Int,
            gender : Int,
            teacherCode : String,
            callback : Dynamic,
            externalId : String = null,
            externalSourceId : Int = -1) : Void
    ;
    
    //
    // Multiplayer logging handling.
    //
    
    /**
     * Add parent dqid dependency for the next multiplayer quest log that is logged
     * without a parent dqid.
     */
    function setMultiplayerService(service : IMultiplayerLoggingService) : Void
    ;
    
    //
    // Dqid dependecy handling.
    //
    
    function isDqidValid(localDqid : Int = -1) : Bool
    ;
    
    function getDqid(localDqid : Int = -1) : String
    ;
    
    function getQuestId(localDqid : Int = -1) : Int
    ;
    
    function getDqidRequestId(localDqid : Int = -1) : Int
    ;
    
    function addDqidCallback(callback : Dynamic, localDqid : Int = -1) : Void
    ;
    
    function updateTosStatus(status : IUserTosStatus, callback : Dynamic = null) : Void
    ;
    
    //
    // Homeplays handling.
    //
    
    function logHomeplayQuestStart(
            questId : Int, questHash : String, questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic, callback : Dynamic = null, localDqid : Int = -1) : Int
    ;
    
    function logHomeplayQuestComplete(
            questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false,
            callback : Dynamic = null, localDqid : Int = -1) : Void
    ;
    
    function retrieveUserAssignments() : UserHomeplaysData
    ;
    
    //
    // Copilot handling.
    //
    
    
    function createQuestPerformance(localDqid : Int = -1) : QuestPerformance
    ;
    
    //
    // Server data flush handling.
    //
    
    /**
     * Used by javascript api to force data to be sent to the server.
     * 
     * @return true if there was server data sent to the server. This gives the
     * tab additional time to make sure requests are handled.
     */
    function flushServerRequests() : Bool
    ;
}

