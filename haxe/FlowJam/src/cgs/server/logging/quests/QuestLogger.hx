package cgs.server.logging.quests;

import cgs.utils.Error;
import haxe.Constraints.Function;
import flash.net.URLLoaderDataFormat;
import flash.net.URLVariables;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.IGameServerData;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.ISequenceIdGenerator;
import cgs.server.logging.QuestActionLogContext;
import cgs.server.logging.UserLoggingHandler;
import cgs.server.logging.actions.IActionBufferHandler;
import cgs.server.logging.actions.IActionBufferListener;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.messages.BufferedMessage;
import cgs.server.logging.messages.QuestMessage;
import cgs.server.logging.messages.ScoreMessage;
import cgs.server.logging.requests.DQIDRequest;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.logging.requests.QuestRequest;
import cgs.server.logging.requests.ServerRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.DqidResponseStatus;
import cgs.server.responses.QuestLogResponseStatus;
import cgs.server.utils.INtpTime;
import cgs.utils.Guid;
import haxe.Json;

/**
 * Class which ecapsulates the logging of a single quest.
 */
class QuestLogger implements IActionBufferListener
{
    public var hasEnded(get, never) : Bool;
    public var startTimeMs(get, never) : Float;
    public var endTimeMs(get, never) : Float;
    public var loggingComplete(get, never) : Bool;
    public var sequenceIdGenerator(never, set) : ISequenceIdGenerator;
    public var nextSessionSequenceId(get, never) : Int;
    public var nextQuestSequenceId(get, never) : Int;
    public var serverTime(get, never) : INtpTime;
    private var currentServerData(get, never) : IGameServerData;
    public var lastLocalDQID(get, never) : Int;
    private var currentQuestID(get, never) : Int;
    private var currentDQID(get, never) : String;

    private var _requestHandler : IUrlRequestHandler;
    private var _server : ICgsServerApi;
    
    private var _loggingHandler : UserLoggingHandler;
    
    //Callbacks registered to be notified of dqid after it is set.
    private var _dqidCallbacks : Array<Dynamic>;
    
    //Callbacks registered to be notified when the quest has ended.
    private var _endedCallbacks : Array<Dynamic>;
    
    private var _dqidRequestId : Int = -1;
    private var _dqid : String;
    private var _questId : Int;
    
    private var _seqIdGenerator : ISequenceIdGenerator;
    
    private var _currBufferedMessage : BufferedMessage;
    
    //Handles flushing of the action buffer.
    private var _actionBufferHandlerClass : Class<Dynamic>;
    private var _actionBufferHandler : IActionBufferHandler;
    
    //Starting and end time for the quest.
    private var _startTimeMs : Float;
    private var _endTimeMs : Float;
    
    //Indicates if the quest has ended.
    private var _ended : Bool;
    
    public function new(
            bufferClass : Class<Dynamic>, server : ICgsServerApi,
            logHandler : IUrlRequestHandler, loggingHandler : UserLoggingHandler)
    {
        _actionBufferHandlerClass = bufferClass;
        _server = server;
        
        _requestHandler = logHandler;
        _loggingHandler = loggingHandler;
        
        _dqidCallbacks = new Array<Function>();
        _endedCallbacks = new Array<Function>();
    }
    
    private function get_hasEnded() : Bool
    {
        return _ended;
    }
    
    private function get_startTimeMs() : Float
    {
        return _startTimeMs;
    }
    
    private function get_endTimeMs() : Float
    {
        return _endTimeMs;
    }
    
    /**
     * Indicates if the logging for the quest has successfully completed for the game.
     */
    private function get_loggingComplete() : Bool
    {
        return false;
    }
    
    private function set_sequenceIdGenerator(value : ISequenceIdGenerator) : ISequenceIdGenerator
    {
        _seqIdGenerator = value;
        return value;
    }
    
    private function get_nextSessionSequenceId() : Int
    {
        return _seqIdGenerator.nextSessionSequenceId;
    }
    
    private function get_nextQuestSequenceId() : Int
    {
        return _seqIdGenerator.nextQuestSequenceId;
    }
    
    private function get_serverTime() : INtpTime
    {
        return _server.serverTime;
    }
    
    private function get_currentServerData() : IGameServerData
    {
        return _server.getCurrentGameServerData();
    }
    
    //
    // Quest log handling.
    //
    
    public function logQuestScore(score : Int, callback : Function = null) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        
        var scoreMessage : ScoreMessage = new ScoreMessage(score, serverData);
        scoreMessage.setQuestId(currentQuestID);
        
        var scoreRequest : QuestRequest = 
        new QuestRequest(callback, scoreMessage, 
        sendScoreMessage, serverData.gid);
        
        scoreMessage.setDqid(_dqid);
        sendScoreMessage(scoreRequest);
    }
    
    private function sendScoreMessage(qRequest : QuestRequest) : Void
    {
        _server.userRequest(CGSServerConstants.SAVE_SCORE, 
                qRequest.message, null, null, ServerRequest.LOGGING_URL, 
                ServerRequest.POST, qRequest, handleSaveScoreResponse
        );
    }
    
    private function handleSaveScoreResponse(response : CgsResponseStatus) : Void
    {
        var qRequest : QuestRequest = response.passThroughData;
        var callback : Function = null;
        if (qRequest != null)
        {
            callback = qRequest.callback;
        }
        if (callback != null)
        {
            callback(response);
        }
    }
    
    public function startLoggingQuestActions(questId : Int, dqid : String) : Void
    {
        _questId = questId;
        _dqid = dqid;
        
        createQuestMessageBuffer();
    }
    
    public function endLoggingQuestActions() : Void
    {
        flushActions();
        stopActionBufferHandler();
    }
    
    public function logQuestStart(
            questId : Int, questHash : String, details : Dynamic,
            callback : Function = null, aeSeqId : String = null,
            parentDqid : String = null, multiSeqId : Int = -1,
            linkGameId : Int = -1, linkCategoryId : Int = -1,
            linkVersionId : Int = -1, linkConditionId : Int = -1) : Void
    {
        localLogQuestStart(
                questId, questHash, details, callback, aeSeqId, false, parentDqid, 
                multiSeqId, linkGameId, linkCategoryId, linkVersionId, linkConditionId
        );
    }
    
    public function logHomeplayQuestStart(
            questId : Int, questHash : String, questDetails : Dynamic,
            homeplayId : String, homeplayDetails : Dynamic,
            linkGameId : Int = -1, linkCategoryId : Int = -1, linkVersionId : Int = -1,
            linkConditionId : Int = -1, callback : Function = null) : Void
    {
        localLogQuestStart(
                questId, questHash, questDetails, callback, 
                null, false, null, -1, linkGameId, linkCategoryId, 
                linkVersionId, linkConditionId, homeplayId, homeplayDetails
        );
    }
    
    public function logHomeplayQuestComplete(
            questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false,
            callback : Function = null) : Void
    {
        localLogQuestEnd(
                questDetails, callback, null, -1, 
                homeplayId, homeplayDetails, homeplayCompleted
        );
    }
    
    public function logQuestEnd(
            details : Dynamic, callback : Function = null,
            parentDqid : String = null, multiSeqId : Int = -1) : Void
    {
        localLogQuestEnd(details, callback, parentDqid, multiSeqId);
    }
    
    private function localLogQuestEnd(
            details : Dynamic, callback : Function = null,
            parentDqid : String = null, multiSeqId : Int = -1, homeplayId : String = null,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false) : Void
    {
        var request : IServerRequest = createLogQuestEndRequest(
                details, callback, parentDqid, multiSeqId, 
                homeplayId, homeplayDetails, homeplayCompleted
        );
        
        _ended = true;
        
        _requestHandler.sendUrlRequest(request);
        
        for (callback in _endedCallbacks)
        {
            callback(this);
        }
        // remove all callbacks
        _endedCallbacks = new Array<Function>();
    }
    
    public function createLogQuestEndRequest(
            details : Dynamic, callback : Function = null,
            parentDqid : String = null, multiSeqId : Int = -1, homeplayId : String = null,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false) : IServerRequest
    {
        //Temp. until sequence id is handled in the message field.
        if (details == null)
        {
            details = { };
        }
        
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        
        var apiMethod : String = (homeplayId == null) ? 
        CGSServerConstants.QUEST_END : CGSServerConstants.HOMEPLAY_QUEST_END;
        
        //Send the quest end message.
        var questMessage : QuestMessage = new QuestMessage(
        _questId, details, false, null, null, serverData, serverTime);
        var message : QuestRequest = new QuestRequest(
        callback, questMessage, sendQuestMessage, serverData.gid, apiMethod);
        questMessage.setDqid(_dqid);
        
        var actionSeqId : Int = _currBufferedMessage.nextSequenceId;
        var sessionSeqId : Int = nextSessionSequenceId;
        if (serverData.atLeastVersion2)
        {
            questMessage.addProperty("qaction_seqid", actionSeqId);
            questMessage.addProperty("session_seqid", sessionSeqId);
            questMessage.injectClientTimeStamp();
            questMessage.addProperty("sessionid", serverData.sessionId);
        }
        if (serverData.isVersion1)
        {
            Reflect.setField(details, "qaction_seqid", actionSeqId);
            Reflect.setField(details, "session_seqid", sessionSeqId);
        }
        
        _endTimeMs = questMessage.clientTimestamp;
        
        //Add multiplayer properties if they are valid.
        if (parentDqid != null)
        {
            questMessage.addProperty("parent_dqid", parentDqid);
        }
        if (multiSeqId >= 0)
        {
            questMessage.addProperty("multi_seqid", multiSeqId);
        }
        if (homeplayId != null)
        {
            questMessage.addProperty("assign_id", homeplayId);
            questMessage.addProperty("assign_complete", (homeplayCompleted) ? 1 : 0);
            
            if (homeplayDetails != null)
            {
                questMessage.addProperty("assign_details", homeplayDetails);
            }
        }
        
        //Flush the last actions in the buffer.
        flushActions();
        stopActionBufferHandler();
        
        _ended = true;
        
        for (callback in _endedCallbacks)
        {
            callback(this);
        }
        
        return createQuestRequest(message);
    }
    
    private function localLogQuestStart(
            questId : Int, questHash : String, details : Dynamic, callback : Function = null,
            aeSeqId : String = null, legacy : Bool = false,
            parentDqid : String = null, multiSeqId : Int = -1,
            linkGameId : Int = -1, linkCategoryId : Int = -1,
            linkVersionId : Int = -1, linkConditionId : Int = -1,
            homeplayId : String = null, homeplayDetails : Dynamic = null) : Void
    {
        var request : IServerRequest = createLogQuestStartRequest(
                questId, questHash, details, callback, aeSeqId, legacy, 
                parentDqid, multiSeqId, linkGameId, linkCategoryId, 
                linkVersionId, linkConditionId, homeplayId, homeplayDetails
        );
        
        //Store the quest message to be sent once the dqid is returned.
        _dqidRequestId = _requestHandler.sendUrlRequest(request);
    }
    
    public function createLogQuestStartRequest(
            questID : Int, questHash : String, details : Dynamic, callback : Function = null,
            aeSeqID : String = null, legacy : Bool = false,
            parentDqid : String = null, multiSeqId : Int = -1,
            linkGameId : Int = -1, linkCategoryId : Int = -1,
            linkVersionId : Int = -1, linkConditionId : Int = -1,
            homeplayId : String = null, homeplayDetails : Dynamic = null) : IServerRequest
    {
        //Temp. until sequence id is handled in the message field.
        if (details == null)
        {
            details = { };
        }
        
        _questId = questID;
        
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        
        var apiMethod : String = (homeplayId == null) ? 
        CGSServerConstants.QUEST_START : CGSServerConstants.HOMEPLAY_QUEST_START;
        
        //Create a start quest message.
        var questMessage : QuestMessage = new QuestMessage(
        questID, details, true, aeSeqID, null, serverData, serverTime);
        var message : QuestRequest = 
        new QuestRequest(callback, questMessage, 
        ((legacy) ? sendLegacyQuestMessage : sendQuestMessage), 
        serverData.gid, apiMethod);
        
        var sessionSeqId : Int = nextSessionSequenceId;
        var questSeqId : Int = nextQuestSequenceId;
        if (serverData.atLeastVersion2)
        {
            questMessage.addProperty("quest_hash", questHash);
            questMessage.addProperty("sessionid", serverData.sessionId);
            questMessage.addProperty("session_seqid", sessionSeqId);
            questMessage.addProperty("quest_seqid", questSeqId);
            questMessage.addProperty("qaction_seqid", 0);
            questMessage.injectClientTimeStamp();
        }
        if (serverData.isVersion1)
        {
            Reflect.setField(details, "sessionid", serverData.sessionId);
            Reflect.setField(details, "session_seqid", sessionSeqId);
            Reflect.setField(details, "quest_seqid", questSeqId);
            Reflect.setField(details, "qaction_seqid", 0);
        }
        
        _startTimeMs = questMessage.clientTimestamp;
        
        //Add multiplayer properties if they are valid.
        if (parentDqid != null)
        {
            questMessage.addProperty("parent_dqid", parentDqid);
        }
        if (multiSeqId >= 0)
        {
            questMessage.addProperty("multi_seqid", multiSeqId);
        }
        if (homeplayId != null)
        {
            questMessage.addProperty("assign_id", homeplayId);
            questMessage.addProperty("assign_seqid", 0);
            
            if (homeplayDetails != null)
            {
                questMessage.addProperty("assign_details", homeplayDetails);
            }
        }
        
        //Add link quest data.
        if (linkGameId > 0)
        {
            questMessage.addProperty("link_gid", linkGameId);
        }
        if (linkCategoryId > 0)
        {
            questMessage.addProperty("link_cid", linkCategoryId);
        }
        if (linkVersionId > 0)
        {
            questMessage.addProperty("link_vid", linkVersionId);
        }
        if (linkConditionId > 0)
        {
            questMessage.addProperty("link_cdid", linkConditionId);
        }
        
        createQuestMessageBuffer();
        startActionBufferHandler();
        
        return createQuestRequest(message);
    }
    
    private function handleDqidLoaded(response : DqidResponseStatus) : Void
    {
        var dqidRequest : DQIDRequest = response.passThroughData;
        var callback : Function = dqidRequest.callback;
        _dqid = response.dqid;
        var dqidFailed : Bool = response.dqidRequestFailed;
        
        //Handle sending any messages which required the dqid.
        if (dqidFailed || response.failed)
        {
            //Generate a local dqid.
            _dqid = Guid.create();
        }
        
        for (currCallback in _dqidCallbacks)
        {
            currCallback(_dqid);
        }

        // clear all callbacks
		_dqidCallbacks = new Array<Dynamic>();
        
        var localID : Int = dqidRequest.localLevelID;
        if (_currBufferedMessage != null)
        {
            _currBufferedMessage.setDqid(_dqid);
        }
    }
    
    //
    // Dqid dependency handling.
    //
    
    public function isDqidValid() : Bool
    {
        return _dqid != null;
    }
    
    public function getDqidRequestId() : Int
    {
        return _dqidRequestId;
    }
    
    public function getDqid() : String
    {
        return _dqid;
    }
    
    public function getQuestId() : Int
    {
        return _questId;
    }
    
    public function addDqidCallback(callback : Function) : Void
    {
        if (callback == null)
        {
            return;
        }
        
        if (isDqidValid())
        {
            callback(_dqid);
        }
        else
        {
            _dqidCallbacks.push(callback);
        }
    }
    
    public function addEndedCallback(callback : Function) : Void
    {
        if (callback == null)
        {
            return;
        }
        
        if (hasEnded)
        {
            callback(this);
        }
        else
        {
            _endedCallbacks.push(callback);
        }
    }
    
    private function sendQuestMessage(message : QuestRequest) : Int
    {
        return _requestHandler.sendUrlRequest(createQuestRequest(message));
    }
    
    private function createQuestRequest(message : QuestRequest) : IServerRequest
    {
        var request : IServerRequest = _server.createServerRequest(
                message.apiMethod, message.message, null, null, 
                ServerRequest.LOGGING_URL, message, null, ServerRequest.POST, 
                URLLoaderDataFormat.TEXT, true, 
                new QuestLogResponseStatus(), handleQuestStartResponse
        );
        
        if (!message.isStart)
        {
            request.addDependencyById(_dqidRequestId);
        }
        else
        {
            if (request.id <= 0 && message.isStart)
            {
                request.id = _requestHandler.nextRequestId;
                _dqidRequestId = request.id;
            }
        }
        
        request.addRequestDependency(_loggingHandler.uidRequestDependency);
        request.addRequestDependency(_loggingHandler.sessionRequestDependency);
        
        request.addReadyHandler(handleQuestRequestReady);
        
        return request;
    }
    
    private function handleQuestRequestReady(request : IServerRequest) : Void
    {
        request.injectParameter("dqid", _dqid);
        request.injectUid();
        request.injectSessionId(_server.getCurrentGameServerData().sessionId);
    }
    
    private function sendLegacyQuestMessage(message : QuestRequest) : Void
    {
        var request : IServerRequest = _server.createServerRequest(
                CGSServerConstants.LEGACY_QUEST_START, message.message, null, null, 
                ServerRequest.LOGGING_URL, message, null, ServerRequest.POST, 
                URLLoaderDataFormat.TEXT, true, 
                new QuestLogResponseStatus(), handleQuestStartResponse
        );
        
        if (!message.isStart)
        {
            request.addDependencyById(_dqidRequestId);
        }
        
        request.addRequestDependency(_loggingHandler.uidRequestDependency);
        request.addRequestDependency(_loggingHandler.sessionRequestDependency);
        
        _requestHandler.sendUrlRequest(request);
    }
    
    private function handleQuestStartResponse(response : QuestLogResponseStatus) : Void
    {
        _dqid = response.dqid;
        var dqidFailed : Bool = response.dqidRequestFailed;
        
        //Handle sending any messages which required the dqid.
        if (dqidFailed || response.failed)
        {
            //Generate a local dqid.
            _dqid = Guid.create();
        }
        
        for (currCallback in _dqidCallbacks)
        {
            currCallback(_dqid);
        }
        
        if (_currBufferedMessage != null)
        {
            _currBufferedMessage.setDqid(_dqid);
        }
        
        //Handle the user callback.
        var questRequest : QuestRequest = response.passThroughData;
        var callback : Function = questRequest.callback;
        
        if (callback != null)
        {
            callback(response);
        }
    }
    
    //
    // DQID handling.
    //
    
    private function get_lastLocalDQID() : Int
    {
        return (_currBufferedMessage != null) ? 
        _currBufferedMessage.getLocalDQID() : -1;
    }
    
    private function get_currentQuestID() : Int
    {
        return (_currBufferedMessage != null) ? _currBufferedMessage.getQuestId() : 0;
    }
    
    private function get_currentDQID() : String
    {
        return (_currBufferedMessage != null) ? _currBufferedMessage.dqid : "";
    }
    
    //
    // Quest action handling.
    //
    
    /**
     * Log a quest action. If the action is not bufferable, it will be sent
     * as it own message to the server. This will also cause all
     * previosly buffered actions to be flushed to the server regardless
     * of the forceFlush parameter.
     *
     * @param action the client action to be logged on the server. Can not be null.
     * @param localDQID the localDQID for the quest that this
     * action should be logged under. Only needed if there is more than one
     * active quest for which actions are being logged.
     * @param forceFlush indicates if the actions buffer should be
     * flushed after the passed action is added to the actions buffer.
     */
    public function logQuestAction(
            action : QuestAction, forceFlush : Bool = false) : Void
    {
        localLogQuestActions(action, null, forceFlush);
    }
    
    public function logQuestActionData(
            action : QuestActionLogContext, forceFlush : Bool = false) : Void
    {
        //Add the dependencies.
        localLogQuestActions(action.action, action.dependencies, forceFlush);
    }
    
    private function localLogQuestActions(
            action : QuestAction,
            dependencies : Array<IRequestDependency>,
            forceFlush : Bool = false) : Void
    {
        var serverData : IGameServerData = _server.getCurrentGameServerData();
        var sessionSeqId : Int = nextSessionSequenceId;
        if (serverData.atLeastVersion2)
        {
            action.addProperty("session_seqid", sessionSeqId);
        }
        if (serverData.isVersion1)
        {
            action.addDetailProperty("session_seqid", sessionSeqId);
        }
        
        //Flush the current actions.
        if (!action.isBufferable())
        {
            flushActions();
            forceFlush = true;
        }
        
        var bufferMessage : BufferedMessage = _currBufferedMessage;
        bufferMessage.addAction(action);
        
        if ((bufferMessage != null) && (dependencies != null))
        {
            for (depen in dependencies)
            {
                bufferMessage.addDependency(depen);
            }
        }
        
        if (forceFlush)
        {
            flushActions();
        }
    }
    
    //
    // Action buffer handling.
    //
    
    //Create a new buffered message with the given quest parameters.
    private function createQuestMessageBuffer() : BufferedMessage
    {
        var prevMessage : BufferedMessage = _currBufferedMessage;
        _currBufferedMessage = new BufferedMessage(currentServerData, serverTime);
        _currBufferedMessage.setQuestId(_questId);
        _currBufferedMessage.setDqid(_dqid);
        
        if (prevMessage != null)
        {
            _currBufferedMessage.sequenceId = prevMessage.currentSequenceId;
        }
        
        return _currBufferedMessage;
    }
    
    /**
     * Pause the automatic flushing of actions to the server.
     */
    public function pauseActionBufferHandler() : Void
    {
        if (_actionBufferHandler == null)
        {
            return;
        }
        
        _actionBufferHandler.stop();
    }
    
    /**
     * Resume the automatic flushing of actions to the server.
     */
    public function resumeActionBufferHandler() : Void
    {
        if (_actionBufferHandler == null)
        {
            return;
        }
        
        _actionBufferHandler.start();
    }
    
    private function startActionBufferHandler() : Void
    {
        if (_actionBufferHandler == null)
        {
            _actionBufferHandler = Type.createInstance(_actionBufferHandlerClass, []);
            _actionBufferHandler.listener = this;
            _actionBufferHandler.setProperties(
                    CGSServerConstants.bufferFlushIntervalStart, 
                    CGSServerConstants.bufferFlushIntervalEnd, 
                    CGSServerConstants.bufferFlushRampTime
            );
        }
        
        _actionBufferHandler.start();
    }
    
    private function stopActionBufferHandler() : Void
    {
        if (_actionBufferHandler == null)
        {
            return;
        }
        
        _actionBufferHandler.stop();
    }
    
    /**
     * Sends all buffered actions to the server.
     *
     * @param localDQID the localDQID for which actions should be flushed. If
     * -1 is passed, actions for all quests are flushed to the server.
     * @param callback function to be called when response
     * is recieved from the server.
     */
    public function flushActions(localDqid : Int = -1, callback : Function = null) : Void
    {
        var flushBuffer : BufferedMessage = _currBufferedMessage;
        
        if (flushBuffer == null)
        {
            return;
        }
        
        if (!flushBuffer.isDQIDValid())
        {
            flushBuffer.setDqid(_dqid);
        }
        
        //Do not send actions if there are none to send.
        if (flushBuffer.getActionCount() == 0)
        {
            return;
        }
        else
        {
            createQuestMessageBuffer();
        }
        
        var serverData : IGameServerData = flushBuffer.serverData;
        var request : QuestRequest = new QuestRequest(
        callback, flushBuffer, sendActionsToServer, serverData.gid);
        
        sendActionsToServer(request);
    }
    
    //Send buffered actions to the server. The passed message should not be reused as
    //this can lead to duplicate or dropped actions.
    private function sendActionsToServer(qRequest : QuestRequest) : Void
    {
        //Create the request.
        var request : IServerRequest = _server.createUserRequest(
                CGSServerConstants.QUEST_ACTIONS, qRequest.message, 
                null, null, ServerRequest.LOGGING_URL, 
                ServerRequest.POST, qRequest, handleActionResponse
        );
        
        request.addDependencyById(_dqidRequestId);
        request.addRequestDependency(_loggingHandler.uidRequestDependency);
        
        request.addReadyHandler(function() : Void
                {
                    request.injectParameter("dqid", _dqid);
                    request.injectUid();
                });
        
        //Add the dependencies.
        for (depen/* AS3HX WARNING could not determine type for var: depen exp: EField(EIdent(qRequest),dependencies) type: null */ in qRequest.dependencies)
        {
            request.addDependency(depen);
        }
        
        _server.sendRequest(request);
    }
    
    //Does not track loader for any context on response.
    private function handleActionResponse(response : CgsResponseStatus) : Void
    {
        var qRequest : QuestRequest = response.passThroughData;
        var message : BufferedMessage = try cast(qRequest.questMessage, BufferedMessage) catch(e:Dynamic) null;
        
        var callback : Function = qRequest.callback;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    //
    // Helper request functions.
    //
    
    //Parse the data returned from the server will return null if parsing fails.
    private function parseResponseData(rawData : String) : Dynamic
    {
        var data : Dynamic = null;
        try
        {
            var urlVars : URLVariables = new URLVariables(rawData);
            data = Json.parse(urlVars.data);
        }
        catch (e : Error)
        {  //Unable to parse the returned data from the server.  
            //Server must have failed.
            //_parsingFailed = true;
            
        }
        
        return data;
    }
    
    private function didRequestFail(dataObject : Dynamic) : Bool
    {
        if (dataObject == null)
        {
            return true;
        }
        
        var failed : Bool = true;
        if (Reflect.hasField(dataObject, "tstatus"))
        {
            failed = dataObject.tstatus != "t";
        }
        
        return failed;
    }
}

