package cgs.server.logging;

import cgs.server.responses.ResponseStatus;
import cgs.server.abtesting.ABTesterConstants;
import cgs.utils.Error;
import cgs.server.abtesting.messages.ConditionVariableMessage;
import cgs.server.abtesting.messages.TestStatusMessage;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.actions.UserAction;
import cgs.server.logging.messages.Message;
import cgs.server.logging.messages.QuestMessage;
import cgs.server.logging.messages.ScoreMessage;
import cgs.server.logging.messages.UserFeedbackMessage;
import cgs.server.logging.quests.QuestLogger;
import haxe.ds.IntMap;
import cgs.server.logging.requests.CallbackRequest;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.logging.requests.RequestDependency;
import haxe.ds.StringMap;
import cgs.server.logging.requests.ServerRequest;
//import cgs.server.requests.IUrlRequest;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.CgsUserResponse;
import cgs.server.utils.INtpTime;
import cgs.user.ICgsUserProperties;
import cgs.user.ICgsUser;
//import cgs.server.logging.ICgsServerApi;
//

/**
 * Class responsible for handling all logging
 * for a user including failure and retries.
 */
class UserLoggingHandler implements ISequenceIdGenerator implements ILogRequestHandler
{
    private var isProductionRelease(get, never) : Bool;
    public var sessionRequestDependency(get, never) : RequestDependency;
    public var uidRequestId(never, set) : Int;
    public var uidRequestDependency(get, never) : RequestDependency;
    public var isUserLoggingDisabled(get, never) : Bool;
    public var serverTime(get, never) : INtpTime;
    public var nextSessionSequenceId(get, never) : Int;
    public var nextQuestSequenceId(get, never) : Int;
    private var isServerTimeValid(get, never) : Bool;
    private var uidValid(get, never) : Bool;
    public var nextLocalDqid(get, never) : Int;

    public static var MULTIPLAYER_SEQUENCEID_KEY : String = "multi_seqid";
    public static var MULTIPLAYER_UID_KEY : String = "multi_uid";
    
    private var _server : ICgsServerApi;
    
    private var _serverTimeLoaded : Bool;
    
    //Handles action messages for multiple quests.
    //Key = localDQID, value = BufferedMessage
    private var _openQuests : Int = 0;
    
    //Local quest id generator. Used to handle the case where the server
    //take a while to respond and two quests are played consecutively with
    //the same qid.
    private var _localQuestId : Int = 0;
    
    //Optional parameter which is used to override game id for quest messages.
    private var _questGameID : Int = -1;
    
    //Class used to create new
    private var _actionBufferHandlerClass : Class<Dynamic>;
    
    //TODO - Move user initialization handling to this class.
    private var _initHandler : IUserInitializationHandler;
    
    //TODO - Move non-consenting user handling to this class.
    
    //Save requests made for logging.
    //private var _requestCache:RequestCache;
    
    //Sequence ids.
    private var _sessionSequenceId : Int;
    private var _questSequenceId : Int;
    
    //Quest logs mapped by local dqid
    private var _questLogMap : IntMap<QuestLogger>;
    private var _lastQuestLog : QuestLogger;
    
    //Quest logs which have finished logging but may have not
    //been verified as logged on the server.
    private var _completeQuestLogs : Array<QuestLogger>;
    
    //Requests which are waiting on a valid uid to be returned.
    //private var _pendingUidRequests:Vector.<PendingRequest>;
    
    //Cache user callbacks for intialization to be called
    //after pending requests are sent.
    private var _initCompleteCallback : Dynamic;
    private var _uidCallback : Dynamic;
    private var _pageloadCallback : Dynamic;
    
    private var _uidRequestId : Int = -1;
    private var _sessionRequestId : Int = -1;
    
    private var _uidDependency : RequestDependency;
    private var _sessionDependency : RequestDependency;
    
    /**
     *
     * @param server object used to make data posts and gets to the server.
     * @param props properties object used to initialize properties
     * of this class and initHandler.
     * @param bufferedHandlerClass
     * @param initHandler
     */
    public function new(
            server : ICgsServerApi, user : ICgsUser,
            props : ICgsUserProperties, bufferedHandlerClass : Class<Dynamic>)
    {
        _server = server;
        _actionBufferHandlerClass = bufferedHandlerClass;
        
        _sessionSequenceId = 0;
        _questSequenceId = 0;
        _questLogMap = new IntMap<QuestLogger>();
        
        _completeQuestLogs = new Array<QuestLogger>();
        
        if (user != null)
        {
            createUserInitHandler(user, props);
        }
    }
    
    private function get_isProductionRelease() : Bool
    {
        return (_server != null) ? _server.isProductionRelease : false;
    }
    
    /**
     * Get the session request dependency for the user.
     */
    private function get_sessionRequestDependency() : RequestDependency
    {
        var sessionRequestId : Int = 
        (_initHandler != null) ? _initHandler.sessionRequestId : _sessionRequestId;
        
        if (_sessionDependency == null && sessionRequestId >= 0)
        {
            _sessionDependency = new RequestDependency(sessionRequestId);
        }
        
        return _sessionDependency;
    }
    
    private function set_uidRequestId(value : Int) : Int
    {
        _uidRequestId = value;
        return value;
    }
    
    /**
     * Get the uid request dependency for the user.
     */
    private function get_uidRequestDependency() : RequestDependency
    {
        var uidRequestId : Int = (_initHandler != null) ? _initHandler.uidRequestId : _uidRequestId;
        
        if (_uidDependency == null && uidRequestId >= 0)
        {
            _uidDependency = new RequestDependency(uidRequestId, true);
        }
        
        return _uidDependency;
    }
    
    private function createUserInitHandler(
            user : ICgsUser, props : ICgsUserProperties) : Void
    {
        _initCompleteCallback = props.completeCallback;
        _uidCallback = props.uidValidCallback;
        _pageloadCallback = props.pageLoadCallback;
        
        props.completeCallback = handleUserInitComplete;
        props.uidValidCallback = handleUidValid;
        props.pageLoadCallback = handlePageloadComplete;
        
        //Create the user intialization handling.
        var initHandler : UserInitHandler = new UserInitHandler(user, props, _server);
        initHandler.timeValidCallback = serverTimeValid;
        //initHandler.requestCache = _requestCache;
        _initHandler = initHandler;
        
        //Change the callbacks to orignal
        props.completeCallback = _initCompleteCallback;
        props.uidValidCallback = _uidCallback;
        props.pageLoadCallback = _pageloadCallback;
    }
    
    private function get_isUserLoggingDisabled() : Bool
    {
        return false;
    }
    
    private function get_serverTime() : INtpTime
    {
        return _server.serverTime;
    }
    
    //
    // Sequence id handling.
    //
    
    //Session sequence id starts at zero.
    private function get_nextSessionSequenceId() : Int
    {
        return ++_sessionSequenceId;
    }
    
    //Quest sequence id starts at 1 for the first quest.
    private function get_nextQuestSequenceId() : Int
    {
        return ++_questSequenceId;
    }
    
    //
    // User initialzation handling.
    //
    
    public function initiliazeUserData(server : ICgsServerApi) : Void
    {
        _initHandler.initiliazeUserData(server);
    }
    
    public function isAuthenticated(
            serverAuthFunction : Dynamic, server : ICgsServerApi,
            completeCallback : Dynamic, saveCacheDataToServer : Bool) : Void
    {
        _initHandler.isAuthenticated(
                serverAuthFunction, server, completeCallback, saveCacheDataToServer
        );
    }
    
    public function authenticateUser(
            name : String, password : String, authKey : String,
            gradeLevel : Int, serverAuthFunction : Dynamic,
            server : ICgsServerApi, completeCallback : Dynamic = null,
            saveCacheDataToServer : Bool = true) : Void
    {
        _initHandler.gradeLevel = gradeLevel;
        
        _initHandler.authenticateUser(
                name, password, authKey, serverAuthFunction, server, 
                completeCallback, saveCacheDataToServer
        );
    }
    
    public function authenticateUserName(
            name : String, password : String, authKey : String, serverAuthFunction : Dynamic,
            server : ICgsServerApi, completeCallback : Dynamic = null) : Void
    {
        // TODO: Remove check and else condition once CGSServer is gone
        if (Std.is(_initHandler, UserInitHandler))
        {
            (try cast(_initHandler, UserInitHandler) catch(e:Dynamic) null).authenticateUserName(
                    name, password, authKey, serverAuthFunction, server, completeCallback
            );
        }
        else
        {
            _initHandler.authenticateUser(
                    name, password, authKey, 
                    serverAuthFunction, server, completeCallback, false
            );
        }
    }
    
    private function handleUserInitComplete(response : CgsUserResponse) : Void
    {
        if (_initCompleteCallback != null)
        {
            _initCompleteCallback(response);
        }
        _initCompleteCallback = null;
    }
    
    private function handleAuthenticationComplete(response : ResponseStatus) : Void
    {
        if (_initCompleteCallback != null)
        {
            _initCompleteCallback(response);
        }
        _initCompleteCallback = null;
    }
    
    private function handleUidValid(uid : String, failed : Bool) : Void
    {
        if (_uidCallback != null)
        {
            _uidCallback(uid, failed);
        }
        _uidCallback = null;
    }
    
    private function handlePageloadComplete(response : ResponseStatus) : Void
    {
        if (_pageloadCallback != null)
        {
            _pageloadCallback(response);
        }
        _pageloadCallback = null;
    }
    
    private function serverTimeValid() : Void
    {
        _serverTimeLoaded = true;
    }
    
    private function get_isServerTimeValid() : Bool
    {
        return _serverTimeLoaded;
    }
    
    //
    // AB testing handling.
    //
    
    public function requestUserTestConditions(
            existing : Bool = false, callback : Dynamic = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, serverData);
        
        var message : Message = _server.getServerMessage();
        message.injectParams();
        message.injectExperimentId();
        
        var method : String = (existing) ? 
        ABTesterConstants.GET_EXISTING_USER_CONDITIONS : 
        ABTesterConstants.GET_USER_CONDITIONS;
        
        var request : IServerRequest = 
        _server.createAbRequest(
                method, handleABTestConditions, 
                message.messageObject, null, callbackRequest
        );
        
        sendLogRequest(request);
    }
    
    private function handleABTestConditions(response : CgsResponseStatus) : Void
    {
        if (response.failed)
        {  //TODO - Request conditions again?  
            
        }
        
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    /**
     * Set the user as having no conditions. If the user already has test conditions,
     * this will have no effect.
     */
    public function noUserConditions() : Void
    {
        var message : Message = _server.getServerMessage();
        message.injectParams();
        message.injectExperimentId();
        
        var request : IServerRequest = 
        _server.createAbRequest(
                ABTesterConstants.NO_CONDITION_USER, 
                handleNoConditionsResponse, message.messageObject
        );
        sendLogRequest(request);
    }
    
    private function handleNoConditionsResponse(response : ResponseStatus) : Void
    {  //Does anything need to be done?  
        
    }
    
    /**
     * Log the start of ab testing.
     */
    public function logTestStart(
            testID : Int, conditionID : Int,
            detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var message : TestStatusMessage = 
        new TestStatusMessage(testID, conditionID, true, detail, serverData);
        message.injectParams();
        message.injectExperimentId();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, serverData);
        
        var request : IServerRequest = 
        _server.createAbRequest(ABTesterConstants.LOG_TEST_START_END, 
                testStartLogged, message.messageObject, null, callbackRequest
        );
        sendLogRequest(request);
    }
    
    private function testStartLogged(response : CgsResponseStatus) : Void
    {
        if (response.failed)
        {
        }
        
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    /**
     *
     */
    public function logTestEnd(
            testID : Int, conditionID : Int,
            detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var message : TestStatusMessage = 
        new TestStatusMessage(testID, conditionID, false, detail, serverData);
        message.injectParams();
        message.injectExperimentId();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, serverData);
        
        var request : IServerRequest = 
        _server.createAbRequest(ABTesterConstants.LOG_TEST_START_END, 
                testEndLogged, message.messageObject, null, callbackRequest
        );
        sendLogRequest(request);
    }
    
    private function testEndLogged(response : CgsResponseStatus) : Void
    {
        if (response.failed)
        {
        }
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    /**
     * Log the start of testing on a variable.
     */
    public function logConditionVariableStart(
            testID : Int, conditionID : Int, varID : Int, resultID : Int,
            time : Float = -1, detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var message : ConditionVariableMessage = 
        new ConditionVariableMessage(
        testID, conditionID, varID, resultID, 
        true, time, detail, serverData);
        message.injectParams();
        message.injectExperimentId();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, serverData);
        
        var request : IServerRequest = 
        _server.createAbRequest(
                ABTesterConstants.LOG_CONDITION_RESULTS, conditionResultsLogged, 
                message.messageObject, null, callbackRequest
        );
        sendLogRequest(request);
    }
    
    /**
     * Log the results for a single variable in a test. Use the log test end to log
     * results for test as a whole.
     *
     * @param testID the id of the test for which to log results.
     * @param conditionID the id of the condition for which to log results.
     * @param variableID the id of the condition variable for which to log results.
     * @param time an optional time parameter for the results. Pass -1
     * if there is not a time value associated with the results.
     * @param detail optional detail information to be logged.
     */
    public function logConditionVariableResults(
            testID : Int, conditionID : Int, variableID : Int, resultID : Int,
            time : Float = -1, detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var message : ConditionVariableMessage = 
        new ConditionVariableMessage(
        testID, conditionID, variableID, resultID, 
        false, time, detail, serverData);
        
        message.injectParams();
        message.injectExperimentId();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, serverData);
        
        var request : IServerRequest = 
        _server.createAbRequest(
                ABTesterConstants.LOG_CONDITION_RESULTS, conditionResultsLogged, 
                message.messageObject, null, callbackRequest
        );
        sendLogRequest(request);
    }
    
    private function conditionResultsLogged(response : CgsResponseStatus) : Void
    {
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        if (response.failed)
        {
        }
        
        if (callback != null)
        {
            callback(response);
        }
    }
    
    //
    // Generic log handling.
    //
    
    /**
     * Submit user feedback to the server.
     */
    public function submitUserFeedback(
            feedback : UserFeedbackMessage, callback : Dynamic = null) : Void
    {
        if (isUserLoggingDisabled)
        {
            return;
        }
        
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        
        //Inject required data into the feedback message.
        feedback.serverData = serverData;
        feedback.injectParams();
        
        var req : CallbackRequest = new CallbackRequest(callback, serverData);
        
        var request : IServerRequest = 
        _server.createUserRequest(
                CGSServerConstants.USER_FEEDBACK, feedback, 
                null, null, ServerRequest.LOGGING_URL, 
                ServerRequest.GET, req, handleUserInfoSentMessage
        );
        
        sendLogRequest(request);
    }
    
    private function handleUserInfoSentMessage(response : CgsResponseStatus) : Void
    {
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    /**
     * Log an action that is not associated with a quest.
     *
     * @param action the action data to be logged on the server.
     * @param callback the function to be called when the action is
     * successfully logged on the server. Function should have the
     * following signature: (response:ResponseStatus):void.
     */
    public function logAction(
            action : UserAction, callback : ResponseStatus -> Void = null,
            multiSeqId : Int = -1, multiUid : String = null) : Void
    {
        if (isUserLoggingDisabled)
        {
            return;
        }
        
        var message : Message = _server.getServerMessage();
        
        //Add the action properties.
        message.addProperty("aid", action.actionId);
        message.addProperty("a_detail", action.details);
        
        if (multiUid != null)
        {
            message.addProperty(MULTIPLAYER_UID_KEY, multiUid);
        }
        if (multiSeqId >= 0)
        {
            message.addProperty(MULTIPLAYER_SEQUENCEID_KEY, multiSeqId);
        }
        
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        message.serverData = serverData;
        message.serverTime = _server.serverTime;
        
        var sessionSeqId : Int = nextSessionSequenceId;
        if (serverData.atLeastVersion2)
        {
            message.injectSessionId();
            message.addProperty("session_seqid", sessionSeqId);
            message.injectClientTimeStamp();
        }
        if (serverData.isVersion1)
        {
            message.addProperty("sessionid", serverData.sessionId);
            message.addProperty("session_seqid", sessionSeqId);
        }
        
        message.injectParams();
        
        var request : IServerRequest = _server.createUserRequest(
                CGSServerConstants.ACTION_NO_QUEST, message, null, null, 
                ServerRequest.LOGGING_URL, ServerRequest.POST, null, 
                function(response : ResponseStatus) : Void
                {
                    if (callback != null)
                    {
                        callback(response);
                    }
                }
        );
        
        request.addRequestDependency(_server.uidRequestDependency);
        request.addRequestDependency(_server.sessionRequestDependency);
        request.addReadyHandler(function(request : IServerRequest) : Void
                {
                    request.injectUid();
                    request.injectSessionId(_server.getCurrentGameServerData().sessionId);
                });
        
        sendLogRequest(request);
    }
    
    private function addQuestLog(localDqid : Int, questLog : QuestLogger) : Void
    {
        _questLogMap.set(localDqid, questLog);
        _lastQuestLog = questLog;
    }
    
    public function getQuestLog(localDqid : Int) : QuestLogger
    {
        if (localDqid < 0)
        {
            return _lastQuestLog;
        }
        
        return _questLogMap.get(localDqid);
    }
    
    //Moves the quest log to completed list and removes it from the logging map.
    private function questLogCompleted(localDqid : Int) : QuestLogger
    {
        var returnQuestLog : QuestLogger = null;
        if (localDqid < 0)
        {
            returnQuestLog = _lastQuestLog;
            _lastQuestLog = null;
        }
        else
        {
            returnQuestLog = _questLogMap.get(localDqid);
            _questLogMap.remove(localDqid);
        }
        
        if (returnQuestLog != null)
        {
            _completeQuestLogs.push(returnQuestLog);
        }
        
        return returnQuestLog;
    }
    
    //
    // Quest log handling.
    //
    
    private function getNewQuestLog() : QuestLogger
    {
        var questLog : QuestLogger = new QuestLogger(
        _actionBufferHandlerClass, _server, _server.urlRequestHandler, this);
        questLog.sequenceIdGenerator = this;
        return questLog;
    }
    
    /**
     * Start logging quest actions for a quest with the given dqid.
     * This function does NOT send a quest start message to the server.
     */
    public function startLoggingQuestActions(
            questId : Int, dqid : String, localDqid : Int = -1) : Int
    {
        if (isUserLoggingDisabled)
        {
            return -1;
        }
        
        var newLocalDqid : Int = (localDqid < 0) ? nextLocalDqid : localDqid;
        
        var questLog : QuestLogger = getNewQuestLog();
        addQuestLog(localDqid, questLog);
        
        questLog.startLoggingQuestActions(questId, dqid);
        
        return newLocalDqid;
    }
    
    /**
     * Flush out all actions for the active quest.
     */
    public function endLoggingQuestActions(localDqid : Int = -1) : Void
    {
        if (isUserLoggingDisabled)
        {
            return;
        }
        
        var questLog : QuestLogger = questLogCompleted(localDqid);
        if (questLog == null && !isProductionRelease)
        {
            throw new Error("startLoggingQuestActions must be called prior to ending logging.");
        }
        
        questLog.endLoggingQuestActions();
    }
    
    public function logQuestStartWithDQID(
            questId : Int, questHash : String, dqid : String, details : Dynamic,
            callback : Dynamic = null, aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        return localQuestStart(
                questId, questHash, details, callback, aeSeqId, localDqid, dqid
        );
    }
    
    public function logQuestStart(
            questId : Int, questHash : String, details : Dynamic, callback : Dynamic = null,
            aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        return localQuestStart(questId, questHash, details, callback, aeSeqId, localDqid);
    }
    
    public function logLinkedQuestStart(
            questId : Int, questHash : String, linkGameId : Int, linkCategoryId : Int,
            linkVersionId : Int, linkConditionId : Int = 0, details : Dynamic = null,
            callback : Dynamic = null, aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        return localQuestStart(questId, questHash, details, callback, aeSeqId, localDqid, 
                null, null, linkGameId, linkCategoryId, linkVersionId
        );
    }
    
    public function logMultiplayerQuestStart(
            questId : Int, questHash : String, details : Dynamic, parentDqid : String, multiSeqId : Int,
            callback : Dynamic = null, aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        return localQuestStart(
                questId, questHash, details, callback, aeSeqId, localDqid, 
                null, parentDqid, -1, -1, -1, -1, multiSeqId
        );
    }
    
    /*public function legacyLogQuestStart(
    questId:int, questHash:String, details:Object, callback:Dynamic = null,
    aeSeqId:String = null, localDqid:int = -1):int
    {
    return localQuestStart(questId,, details, callback, aeSeqId, localDqid, true);
    }*/
    
    private function localQuestStart(
            questId : Int, questHash : String, details : Dynamic, callback : Dynamic = null,
            aeSeqId : String = null, localDqid : Int = -1,
            dqid : String = null, parentDqid : String = null, linkGameId : Int = -1,
            linkCategoryId : Int = -1, linkVersionId : Int = -1,
            linkConditionId : Int = -1, multiSeqId : Int = -1,
            homeplayId : String = null, homeplayDetails : Dynamic = null) : Int
    {
        var context : QuestLogContext = createQuestStartRequest(
                questId, questHash, details, callback, aeSeqId, localDqid, 
                dqid, parentDqid, linkGameId, linkCategoryId, linkVersionId, 
                linkConditionId, multiSeqId, homeplayId, homeplayDetails
        );
        
        if (context != null)
        {
            context.sendRequest();
            return context.localDqid;
        }
        
        return -1;
    }
    
    public function createQuestStartRequest(
            questId : Int, questHash : String, details : Dynamic, callback : Dynamic = null,
            aeSeqId : String = null, localDqid : Int = -1,
            dqid : String = null, parentDqid : String = null, linkGameId : Int = -1,
            linkCategoryId : Int = -1, linkVersionId : Int = -1,
            linkConditionId : Int = -1, multiSeqId : Int = -1,
            homeplayId : String = null, homeplayDetails : Dynamic = null) : QuestLogContext
    {
        //TODO - Do everything but send the request.
        if (isUserLoggingDisabled)
        {
            return null;
        }
        
        if (localDqid < 0)
        {
            localDqid = nextLocalDqid;
        }
        
        var questLog : QuestLogger = getNewQuestLog();
        addQuestLog(localDqid, questLog);
        
        var request : IServerRequest = 
        questLog.createLogQuestStartRequest(
                questId, questHash, details, callback, aeSeqId, false, 
                parentDqid, multiSeqId, linkGameId, linkCategoryId, linkVersionId, 
                linkConditionId, homeplayId, homeplayDetails
        );
        /*if(homeplayId != null)
        {
        questLog.logHomeplayQuestStart(
        questId, questHash, details, homeplayId, homeplayDetails,
        linkGameId, linkCategoryId, linkVersionId, linkConditionId, callback);
        }
        else
        {
        questLog.logQuestStart(
        questId, questHash, details, callback, aeSeqId, parentDqid,
        multiSeqId, linkGameId, linkCategoryId, linkVersionId, linkConditionId);
        }*/
        
        var context : QuestLogContext = 
        new QuestLogContext(request, _server.urlRequestHandler, localDqid);
        
        return context;
    }
    
    /**
     * Log a foreign quest start for the user. This quest will only have a quest
     * start and no other logged information.
     */
    public function logForeignQuestStart(
            dqid : String, foreignGameId : Int, foreignCategoryId : Int,
            foreignVersionId : Int, foreignConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null) : Void
    {
        if (isUserLoggingDisabled)
        {
            return;
        }
        
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        
        var message : QuestMessage = new QuestMessage(
        0, details, true, null, null, serverData, _server.serverTime);
        message.addProperty("foreign_gid", foreignGameId);
        message.addProperty("foreign_cid", foreignCategoryId);
        message.addProperty("foreign_vid", foreignVersionId);
        
        message.setDqid(dqid);
        message.injectParams();
        message.foreignQuest = true;
        
        var sessionSeqId : Int = nextSessionSequenceId;
        var questSeqId : Int = nextQuestSequenceId;
        if (serverData.atLeastVersion2)
        {
            message.addProperty("sessionid", serverData.sessionId);
            message.addProperty("session_seqid", sessionSeqId);
            message.addProperty("quest_seqid", questSeqId);
            message.addProperty("qaction_seqid", 0);
            message.injectClientTimeStamp();
        }
        
        var request : IServerRequest = 
        _server.createUserRequest(
                CGSServerConstants.QUEST_START, message, null, null, 
                ServerRequest.LOGGING_URL, ServerRequest.POST, 
                callback, handleForeignQuestStartResponse
        );
        
        sendLogRequest(request);
    }
    
    private function handleForeignQuestStartResponse(response : CgsResponseStatus) : Void
    {
        var callback : Dynamic = response.passThroughData;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    public function logMultiplayerQuestEnd(
            details : Dynamic, parentDqid : String,
            multiSeqId : Int, localDqid : Int = -1, callback : Dynamic = null) : Void
    {
        localLogQuestEnd(
                details, localDqid, callback, parentDqid, multiSeqId
        );
    }
    
    public function logQuestEnd(
            details : Dynamic, localDqid : Int = -1, callback : Dynamic = null) : Void
    {
        localLogQuestEnd(details, localDqid, callback);
    }
    
    private function localLogQuestEnd(
            details : Dynamic, localDqid : Int = -1, callback : Dynamic = null,
            parentDqid : String = null, multiSeqId : Int = -1, homeplayId : String = null,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false) : Void
    {
        var context : QuestLogContext = createQuestEndRequest(
                details, localDqid, callback, parentDqid, 
                multiSeqId, homeplayId, homeplayDetails, homeplayCompleted
        );
        
        if (context != null)
        {
            context.sendRequest();
        }
    }
    
    public function createQuestEndRequest(
            details : Dynamic, localDqid : Int = -1, callback : Dynamic = null,
            parentDqid : String = null, multiSeqId : Int = -1, homeplayId : String = null,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false) : QuestLogContext
    {
        if (isUserLoggingDisabled)
        {
            return null;
        }
        
        var questLog : QuestLogger = questLogCompleted(localDqid);
        if (questLog == null && !isProductionRelease)
        {
            throw new Error("Log quest start must be called before logging quest end.");
        }
        
        var request : IServerRequest = questLog.createLogQuestEndRequest(
                details, callback, parentDqid, multiSeqId, 
                homeplayId, homeplayDetails, homeplayCompleted
        );
        
        return new QuestLogContext(
        request, _server.urlRequestHandler, localDqid);
    }
    
    public function hasQuestLoggingStarted(localDqid : Int = -1) : Bool
    {
        return getQuestLog(localDqid) != null;
    }
    
    //
    // Dqid dependency handling.
    //
    
    public function isDqidValid(localDqid : Int = -1) : Bool
    {
        var questLog : QuestLogger = getQuestLog(localDqid);
        
        return (questLog != null) ? questLog.isDqidValid() : false;
    }
    
    public function getDqidRequestId(localDqid : Int = -1) : Int
    {
        var questLog : QuestLogger = getQuestLog(localDqid);
        
        return (questLog != null) ? questLog.getDqidRequestId() : -1;
    }
    
    public function getDqid(localDqid : Int = -1) : String
    {
        var questLog : QuestLogger = getQuestLog(localDqid);
        
        return (questLog != null) ? questLog.getDqid() : null;
    }
    
    public function addDqidCallback(callback : Dynamic, localDqid : Int = -1) : Void
    {
        var questLog : QuestLogger = getQuestLog(localDqid);
        
        if (questLog != null)
        {
            questLog.addDqidCallback(callback);
        }
    }
    
    //
    // Quest action handling.
    //
    
    /**
     * Log a quest action. If the action is not bufferable, it will be sent
     * as it own message to the server. This will also cause all previosly buffered
     * actions to be flushed to the server regardless of the forceFlush parameter.
     *
     * @param action the client action to be logged on the server. Can not be null.
     * @param localDQID the localDQID for the quest that this action
     * should be logged under. Only needed if there is more than one active
     * quest for which actions are being logged.
     * @param forceFlush indicates if the actions buffer should be
     * flushed after the passed action is added to the actions buffer.
     */
    public function logQuestAction(
            action : QuestAction, localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        if (isUserLoggingDisabled)
        {
            return;
        }
        
        var questLog : QuestLogger = getQuestLog(localDqid);
        if (questLog == null && !isProductionRelease)
        {
            throw new Error("Log quest start must be called before logging quest actions.");
        }
        
        questLog.logQuestAction(action, forceFlush);
    }
    
    public function logQuestActionData(
            action : QuestActionLogContext,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        if (isUserLoggingDisabled)
        {
            return;
        }
        
        var questLog : QuestLogger = getQuestLog(localDqid);
        if (questLog == null && !isProductionRelease)
        {
            throw new Error("Log quest start must be called before logging quest actions.");
        }
        
        questLog.logQuestActionData(action, forceFlush);
    }
    
    //
    // Action buffer handling.
    //
    
    /**
     * Sends all buffered actions to the server.
     *
     * @param localDQID the localDQID for which actions should be flushed. If
     * -1 is passed, actions for all quests are flushed to the server.
     */
    public function flushActions(
            localDQID : Int = -1, callback : Dynamic = null) : Void
    {
        flushActionsOptions(localDQID, callback);
    }
    
    /**
     * Sends all buffered actions to the server. This create a new empty action buffer.
     */
    private function flushActionsOptions(
            localDQID : Int = -1, callback : Dynamic = null) : Void
    {
        if (localDQID < 0)
        {
            flushAllActions(callback);
        }
        else
        {
            flushQuestActionsByID(localDQID, callback);
        }
    }
    
    //Flush actions for all buffered messages.
    private function flushAllActions(callback : Dynamic = null) : Void
    {
        for (questLog in _questLogMap)
        {
            questLog.flushActions(-1, callback);
        }
    }
    
    private function flushQuestActionsByID(
            localDQID : Int, callback : Dynamic = null) : Void
    {
        var questLog : QuestLogger = _questLogMap.get(localDQID);
        if (questLog != null)
        {
            questLog.flushActions(-1, callback);
        }
    }
    
    /**
     * Save a score for the user. This score is saved with the current
     * quest id and dqid which have been set by the startQuest call.
     *
     * @param score the score for the current quest.
     * @param callback function to be called when the score has been logged on the server.
     * @param localDQID
     */
    public function logQuestScore(
            score : Int, callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        var questLog : QuestLogger = getQuestLog(localDqid);
        if (questLog == null && !isProductionRelease)
        {
            throw new Error("Log quest start must be called before logging quest score.");
        }
        
        questLog.logQuestScore(score, callback);
    }
    
    
    /**
     * Save a user score which is not associated with a single quest. This score
     * could be the total score for several quests or game levels.
     * The passed quest id should be unique and can be used to
     * differentiate this score value from other player scores.
     *
     * @param score the score for the current quest.
     * @param questID the unique id which indentifies the passed score.
     */
    public function logScore(
            score : Int, questID : Int, callback : Dynamic = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var scoreMessage : ScoreMessage = 
        new ScoreMessage(score, serverData, serverTime);
        scoreMessage.setQuestId(questID);
        scoreMessage.injectParams();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, serverData);
        
        var request : IServerRequest = 
        _server.createUserRequest(
                CGSServerConstants.SAVE_SCORE, scoreMessage, null, null, 
                ServerRequest.LOGGING_URL, ServerRequest.GET, 
                callbackRequest, handleSaveScoreResponse
        );
        sendLogRequest(request);
    }
    
    private function handleSaveScoreResponse(response : CgsResponseStatus) : Void
    {
        var qRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = null;
        if (qRequest != null)
        {
            callback = qRequest.callback;
        }
        if (callback != null)
        {
            callback(response);
        }
    }
    
    //
    // Homeplays logging.
    //
    
    public function logHomeplayQuestStart(
            questId : Int, questHash : String, questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic, localDqid : Int = -1, callback : Dynamic = null) : Int
    {
        return localQuestStart(
                questId, questHash, questDetails, callback, null, localDqid, 
                null, null, -1, -1, -1, -1, -1, homeplayId, homeplayDetails
        );
    }
    
    /**
     * Callback should have the following signature: (failed:Boolean):void
     */
    public function logHomeplayQuestComplete(
            questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false,
            localDqid : Int = -1, callback : Dynamic = null) : Void
    {
        localLogQuestEnd(
                questDetails, localDqid, callback, null, -1, 
                homeplayId, homeplayDetails, homeplayCompleted
        );
    }
    
    //
    // User initialization handling.
    //
    
    private function get_uidValid() : Bool
    {
        return _initHandler.uidValid;
    }
    
    //
    // Dqid handling.
    //
    
    private function get_nextLocalDqid() : Int
    {
        return ++_localQuestId;
    }
    
    private function currentLocalDqid() : Int
    {
        return _localQuestId;
    }
    
    //
    // Default request handling.
    //
    
    /**
     * Send a logging request to the server. This function will delay sending
     * the request to the server if all of the required data is not available.
     */
    public function sendLogRequest(request : IServerRequest) : Void
    {
        _server.sendRequest(request);
    }
}





class PendingRequest
{
    public var requiresTimestamp(get, never) : Bool;
    public var request(get, never) : IServerRequest;

    private var _requestTimeStamp : Float;
    
    private var _request : IServerRequest;
    
    @:allow(cgs.server.logging)
    private function new(request : IServerRequest)
    {
        _request = request;
        if (request.hasClientTimestamp)
        {
            _requestTimeStamp = Math.round(haxe.Timer.stamp() * 1000);
        }
    }
    
    private function get_requiresTimestamp() : Bool
    {
        return _request.hasClientTimestamp;
    }
    
    private function get_request() : IServerRequest
    {
        return _request;
    }
    
    public function injectValues(server : ICgsServerApi) : Void
    {
        if (_request.hasClientTimestamp)
        {
            _request.injectClientTimestamp(
                    server.getOffsetClientTimestamp(_requestTimeStamp)
            );
        }
        _request.injectUid();
    }
}