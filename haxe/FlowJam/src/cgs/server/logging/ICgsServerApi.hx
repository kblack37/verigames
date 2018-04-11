package cgs.server.logging;

import cgs.server.logging.IGameServerData.SkeyHashVersion;
import haxe.Constraints.Function;
import flash.display.Stage;
import flash.net.URLLoaderDataFormat;
import cgs.server.abtesting.IAbTestingServerApi;
import cgs.server.data.TosItemData;
import cgs.server.data.UserData;
import cgs.server.data.IUserTosStatus;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.actions.UserAction;
import cgs.server.logging.messages.Message;
import cgs.server.logging.messages.UserFeedbackMessage;
import cgs.server.logging.quests.QuestLogger;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.ResponseStatus;
import cgs.server.utils.INtpTime;
import cgs.user.ICgsUserProperties;
import cgs.user.ICgsCacheServerApi;
import cgs.user.ICgsUser;

interface ICgsServerApi extends IAbTestingServerApi extends ICgsCacheServerApi
{
    
    var isProductionRelease(get, never) : Bool;    
    
    var urlRequestHandler(get, never) : IUrlRequestHandler;    
    
    var ntpTime(never, set) : INtpTime;    
    
    var serverTime(get, never) : INtpTime;    
    
    //
    // Request ids.
    //
    
    var uidRequestDependency(get, never) : RequestDependency;    
    
    var sessionRequestDependency(get, never) : RequestDependency;    
    
    var uid(get, never) : String;    
    
    var isUidValid(get, never) : Bool;    
    
    var username(get, never) : String;    
    
    var skeyHashVersion(never, set) : SkeyHashVersion;    
    
    var versionID(never, set) : Int;    
    
    
    
    //function set legacyMode(value:Boolean):void;
    
    var conditionId(get, set) : Int;    
    
    var sessionId(get, never) : String;    
    
    var skey(never, set) : String;    
    
    var userPlayCount(get, never) : Int;    
    
    var actionBufferHandlerClass(never, set) : Class<Dynamic>;    
    
    var useDevelopmentServer(never, set) : Bool;    
    
    var tosResponseExists(get, never) : Bool;    
    
    var userTosStatus(get, never) : IUserTosStatus;    
    
    /**
		 * Get the user data for the currently logged in user.
		 *
		 * @return the user data. Will return null if no user is logged in.
		 */
    var userData(get, never) : UserData;    
    
    var message(get, never) : Message;    
    
    var lessonId(never, set) : String;    
    
    /**
     * Indicates if there are any buffered logs that need to be sent to the server.
     */
    var hasPendingLogs(get, never) : Bool;

    
    function setUserDomain(stage : Stage) : Void
    ;
    
    function isServerTimeValid(callback : Function) : Void
    ;
    
    function sendRequest(request : IServerRequest) : Int
    ;
    
    function requestUid(
            callback : Function, cacheUUID : Bool = false, forceName : String = null) : Int
    ;
    
    function logPageLoad(
            details : Dynamic = null, callback : Function = null, multiSeqId : Int = -1) : Int
    ;
    
    function getOffsetClientTimestamp(localTime : Float) : Float
    ;
    
    function getCurrentGameServerData() : IGameServerData
    ;
    
    function getServerMessage() : Message
    ;
    
    function requestDqid(callback : Function, localDQID : Int = -1) : Int
    ;
    
    /**
     * Create a server request which can be sent to the server
     * at a later time via the sendRequest method.
     */
    function createRequest(
            method : String, message : Message, data : Dynamic = null,
            passThroughData : Dynamic = null, type : Int = -1, requestType : String = "GET",
            callback : Function = null) : IServerRequest
    ;
    
    function createServerRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, requestType : String = "GET",
            dataFormat : String = URLLoaderDataFormat.TEXT,
            uidRequired : Bool = false, responseStatus : ResponseStatus = null,
            callback : Function = null) : IServerRequest
    ;
    
    function createUserRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, requestType : String = "GET",
            extraData : Dynamic = null, callback : Function = null) : IServerRequest
    ;
    
    function request(
            method : String, callback : Function = null, message : Message = null,
            data : Dynamic = null, params : Dynamic = null, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, dataFormat : String = URLLoaderDataFormat.TEXT,
            uidRequired : Bool = false) : Int
    ;
    
    function userRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, requestType : String = "GET",
            extraData : Dynamic = null, callback : Function = null) : Int
    ;
    
    function serverRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, requestType : String = "GET",
            dataFormat : String = URLLoaderDataFormat.TEXT, uidRequired : Bool = false,
            responseStatus : ResponseStatus = null, callback : Function = null) : Int
    ;
    
    function clearCachedUid() : Void
    ;
    
    function endLoggingQuestActions(localDqid : Int = -1) : Void
    ;
    
    function startLoggingQuestActions(
            questId : Int, dqid : String, localDqid : Int = -1) : Int
    ;
    
    /**
		 * Disables all logging to the logging server and the ab testing engine.
		 */
    function disableLogging() : Void
    ;
    
    function enableLogging() : Void
    ;
    
    /** Indicates if the quest identified by the localDqid is active. The localDqid
     * only needs to be provided if multiple quests are logged at the same time.
     * 
     * @param localDqid the local id that identifies quest being logged. Does not
     * need to be included if only one quest is being logged.
     */
    function isQuestActive(localDqid : Int = -1) : Bool
    ;
    
    /**
		 * Log the start of a quest. This assumes that there is no valid dqid
     * for the quest and one will be requested from the server.
     * This function should only be used in a multiplayer game. The parentDqid
     * value should be the dqid value of the quest being logged on the server.
		 *
		 * @param questID the id of the quest as defined on the server.
		 * @param details properties to be logged with the quest start.
		 * @param parentDqid dqid of the quest being logged on the server.
		 * @param multiSeqId the sequence id, dictated by the server,
     * that is used to interleave multiple client quests and actions.
		 * @param callback function to be called when the dqid
     * is returned from the server. Function should have
     * the signature: (dqid:String, failed:Boolean):void.
		 * @param aeSeqID used in conjection with the Assessment engine.
		 * @param localDQID optional parameter for a local unique quest id.
		 *
		 * @return localDQID which can be used to log actions for the quest.
     * If your game only has one active quest at a time, you do not need
     * to pass the localDQID to log actions.
		 */
    function logMultiplayerQuestStart(
            questId : Int, questHash : String, details : Dynamic, parentDqid : String,
            multiSeqId : Int, callback : Function = null, aeSeqId : String = null,
            localDqid : Int = -1) : Int
    ;
    
    function createMultiplayerQuestStartRequest(
            questId : Int, questHash : String, details : Dynamic, parentDqid : String,
            multiSeqId : Int, callback : Function = null, aeSeqId : String = null,
            localDqid : Int = -1) : QuestLogContext
    ;
    
    function logQuestStartWithDQID(
            questID : Int, questHash : String, dqid : String, details : Dynamic,
            aeSeqID : String = null, localDQID : Int = -1) : Int
    ;
    
    function logQuestStart(
            questId : Int, questHash : String, details : Dynamic, callback : Function = null,
            aeSeqId : String = null, localDqid : Int = -1) : Int
    ;
    
    function logHomeplayQuestStart(
            questId : Int, questHash : String, questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic, localDqid : Int = -1, callback : Function = null) : Int
    ;
    
    function logHomeplayQuestComplete(
            questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false,
            localDqid : Int = -1, callback : Function = null) : Void
    ;
    
    function retrieveUserAssignments(callback : Function = null) : Void
    ;
    
    /**
		 * Log a quest action that is related to a multiplayer quest.
     * This function should be used if the action is being logged on the client.
		 *
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param multiSeqId the sequence id, dictated by the server,
     * that is used to interleave multiple client actions.
		 * @param localDqid the localDQID for the quest that this action
     * should be logged under. Only needed if there is more than one active quest
     * for which actions are being logged.
		 * @param forceFlush indicates if the actions buffer should be
     * flushed after the passed action is added to the actions buffer.
		 */
    function logMultiplayerQuestAction(
            action : QuestAction, multiSeqId : Int,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    function logQuestActionData(
            action : QuestActionLogContext,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    /**
		 * Log a quest action that is related to a multiplayer quest.
     * This function should be used if the action is being logged
     * on the server for a specific user.
		 *
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param multiSeqId the sequence id, dictated by the server,
     * that is used to interleave multiple client actions.
		 * @param multiUid the uid for the user that action relates to.
		 * @param localDqid the localDQID for the quest that this action
     * should be logged under. Only needed if there is more than one active
     * quest for which actions are being logged.
		 * @param forceFlush indicates if the actions buffer should be flushed
     * after the passed action is added to the actions buffer.
		 */
    function logServerMultiplayerQuestAction(
            action : QuestAction, multiSeqId : Int, multiUid : String,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    function logQuestAction(
            action : QuestAction, localDqid : Int = -1, forceFlush : Bool = false) : Void
    ;
    
    function flushActions(localDqid : Int = -1, callback : Function = null) : Void
    ;
    
    function logQuestScore(
            score : Int, callback : Function = null, localDqid : Int = -1) : Void
    ;
    
    function logMultiplayerQuestEnd(
            details : Dynamic, parentDqid : String, multiSeqId : Int,
            callback : Function = null, localDqid : Int = -1) : Void
    ;
    
    function createMultiplayerQuestEndRequest(
            details : Dynamic, parentDqid : String, multiSeqId : Int,
            callback : Function = null, localDqid : Int = -1) : QuestLogContext
    ;
    
    
    function logQuestEnd(
            details : Dynamic, callback : Function = null, localDQID : Int = -1) : Void
    ;
    
    function logForeignQuestStart(
            dqid : String, foreignGameId : Int, foreignCategoryId : Int,
            foreignVersionId : Int, foreignConditionId : Int = 0,
            details : Dynamic = null, callback : Function = null) : Void
    ;
    
    /**
     * Log a quest that is linked to another game. In addition to logging the quest
     * start this will create an entry in table with game id details.
     *
     */
    function logLinkedQuestStart(
            questId : Int, questHash : String, linkGameId : Int, linkCategoryId : Int,
            linkVersionId : Int, linkConditionId : Int = 0,
            details : Dynamic = null, callback : Function = null,
            aeSeqId : String = null, localDqid : Int = -1) : Int
    ;
    
    function submitUserFeedback(
            feedback : UserFeedbackMessage, callback : Function = null) : Void
    ;
    
    function logScore(score : Int, questId : Int, callback : Function = null) : Void
    ;
    
    /*function legacyLogQuestStart(
    questID:int, details:Object, callback:Function = null,
    aeSeqID:String = null, localDQID:int = -1):int;*/
    
    /**
		 * @param action
		 * @param multiSeqId
		 * @param callback
		 */
    function logMultiplayerAction(
            action : UserAction, multiSeqId : Int, callback : Function = null) : Void
    ;
    
    function logServerMultiplayerAction(
            action : UserAction, multiSeqId : Int,
            multiUid : String, callback : Function = null) : Void
    ;
    
    function logActionNoQuest(
            action : UserAction, callback : Function = null) : Void
    ;
    
    function initializeUser(
            user : ICgsUser, props : ICgsUserProperties,
            completeCallback : Function = null) : Void
    ;
    
    function setup(props : CGSServerProps, stage : Stage = null) : Void
    ;
    
    function setupUserProperties(user : ICgsUser, props : ICgsUserProperties) : Void
    ;
    
    //
    // User authentication functions.
    //
    
    function isAuthenticated(
            callback : Function, saveCacheDataToServer : Bool = true) : Void
    ;
    
    function authenticateUser(
            userName : String, password : String, authKey : String = null,
            callback : Function = null, saveCacheDataToServer : Bool = true) : Void
    ;
    
    function reset() : Void
    ;
    
    /**
     * Check if the given username is available for use on the server.
     *
     * @param name
     * @param userCallback listener that is called when the server responds.
     * Will be true if the name is available and false if server
     * failed or name is not available.
     */
    function checkUserNameAvailable(name : String, userCallback : Function) : Void
    ;
    
    /**
     * Check if the given username is available for a student that is assigned to a particular teacher
     * 
     * @param name
     *      The student name to check
     * @param teacherUid
     *      The uid of the teacher to check student names from.
     *      Can be null, but make sure the teacher code is set if that is the case.
     * @param teacherCode
     *      The teacher code that will indirectly bind the student to a teacher.
     *      Can be null, but make sure the teacher uid is set if that is the case.
     * @param userCallback
     *      Listener that is called when the server responds, accepts single parameter which is ResponseStatus,
     *      success is true if the name is available for that teacher and false if the server fails or name is already taken.
     */
    function checkStudentNameAvailable(name : String, teacherUid : String, teacherCode : String, userCallback : Function) : Void
    ;
    
    /**
     * Create a new user (including a new uid) with given credentails
     */
    function registerUser(name : String, password : String, email : String, userCallback : Function) : Void
    ;
    
    /**
     * Register a new user with a given uid. The normal case for this usage is if a user
     * plays anonymously, at which point they are assigned a uid but no other credentials, and
     * then wants to bind the id to a member account.
     * 
     * @param name
     * @param password
     * @param email
     * @param grade
     * @param gender
     * @param teacherCode
     *      Optional code if the registered user should be treated as a student
     * @param userCallback
     *      Callback when registration finishes, Signature callback(status:ResponseStatus)
     * @param externalId
     *      If the player is authenticated through an external login, then that organization must provide
     *      us a token so we can link the player to our servers. (null means not part of external organization)
     * @param externalSourceId
     *      Look in the cgs_external_sources table to see what organizations we have recorded (-1 is none)
     */
    function registerUserWithUid(name : String,
            password : String,
            email : String,
            grade : Int,
            gender : Int,
            teacherCode : String,
            userCallback : Function,
            externalId : String = null,
            externalSourceId : Int = -1) : Void
    ;
    
    //
    // Tos handling.
    //
    
    function saveTosStatus(
            accepted : Bool, tosVersion : Int, tosHash : String,
            languageCode : String, callback : Function = null) : Void
    ;
    
    //
    // Logging data retrieval.
    //
    /**
     * Request all of the quest data associated with the given dqid.
     *
     * @param dqid the dynamic quest id for which all quest
     * data should be retrieved from the server.
     * @param callback the callback to be called when quest data has been loaded.
     * the callback should have the following
     * signature: (questData:QuestData, failed:Boolean):void.
     */
    function requestQuestData(dqid : String, callback : Function = null) : Void
    ;
    
    //
    // TODO - New features that need to be ported to CgsApi.
    //
    
    /**
		 * Check whether given user credentials matches those bound to a
     * teacher registration code.
     * 
     * @param username
     * @param password
     * @param teacherCode
     *      A special identifier that links users to a teacher account
     * @param gradeLevel
     *      ? Why is this necessary, never sent or used
     * @param callback
     *      Callback when response received, signature callback(response:CgsUserResponse)
     * @param saveCacheDataToServer
     *      ? Why is this necessary, never sent or used
		 */
    function authenticateStudent(
            username : String, password : String, teacherCode : String, gradeLevel : Int = -1,
            callback : Function = null, saveCacheDataToServer : Bool = true) : Void
    ;
    
    /**
		 * Create a new account with a given username and bind it to a teacher account
     * 
     * @param username
     *      Name that needs to be unique amongst all other tied to the teacherCode
     * @param teacherCode
     *      A special identifier that links users to a teacher account
     * @param gradeLevel
     *      0 is unset
     * @param userCallback
     *      Callback when registration complete, signature callback(response:CgsUserResponse)
     * @param gender
     *      1 for female, 2 for male, 0 is unset
		 */
    function registerStudent(username : String, teacherCode : String,
            gradeLevel : Int = 0, userCallback : Function = null, gender : Int = 0) : Void
    ;
    
    /**
     * Function to update the grade and gender of a student assigned to a teacher account.
     * In the case of standalone games we will want to create a dummy account for all students.
     * 
     * NOTE: Due to how server is set up, it does not update a field if it had previously
     * been set to a valid value (i.e. updates only if zero or null)
     * 
     * @param useranme
     *      Id of the user to change grade and/or gender for
     * @param teacherCode
     *      The 'teacher' member that the student is bound to
     * @param gradeLevel
     *      0 is unset
     * @param gender
     *      1 for female, 2 for male, 0 is unset
     * @param userCallback
     *      Callback when update has completed, signature callback()
     */
    function updateStudent(username : String, teacherCode : String, gradeLevel : Int, gender : Int, userCallback : Function) : Void
    ;
    
    /**
		 * Indicates if the user is required to accept or decline the tos.
		 * This will only be valid if userTosStatus has been loaded.
		 */
    function userTosRequired() : Bool
    ;
    
    /**
		 * Load tos status for the user. Terms of service will be returned if
		 * user needs to accept terms.
		 */
    function loadUserTosStatus(
            tosKey : String, callback : Function = null,
            languageCode : String = "en", gradeLevel : Int = 0) : Void
    ;
    
    function getTosItemData(tosKey : String,
            languageCode : String = "en", version : Int = -1) : TosItemData
    ;
    
    function containsTos(tosKey : String,
            languageCode : String = "en", version : Int = -1) : Bool
    ;
    
    function updateUserTosStatus(
            userStatus : IUserTosStatus, callback : Function = null) : Void
    ;
    
    function exemptUserFromTos(callback : Function = null) : Void
    ;
    
    function loadTos(tosKey : String, languageCode : String = "en",
            version : Int = -1, callback : Function = null) : Void
    ;
    
    function getDqid(localDqid : Int = -1) : String
    ;
    
    function addDqidCallback(callback : Function, localDqid : Int = -1) : Void
    ;
    
    function isDqidValid(localDqid : Int = -1) : Bool
    ;
    
    function getDqidRequestId(localDqid : Int = -1) : Int
    ;
    
    function getQuestLogger(localDqid : Int = -1) : QuestLogger
    ;
}
