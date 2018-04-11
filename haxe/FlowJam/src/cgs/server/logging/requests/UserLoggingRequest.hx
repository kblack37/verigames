package cgs.server.logging.requests;

import openfl.utils.Dictionary;
import haxe.Constraints.Function;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.actions.GameAction;
import cgs.server.logging.data.PageLoadData;
import cgs.server.logging.data.UserLoggingData;
import cgs.server.logging.messages.Message;
import cgs.server.requests.DataRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.ResponseStatus;

class UserLoggingRequest extends DataRequest
{
    private var _server : ICgsServerApi;
    
    //User ids for which all logging data should be loaded.
    private var _uids : Array<String>;
    
    private var _cid : Int;
    
    private var _startTime : Float;
    private var _endTime : Float;
    
    private var _loadQuests : Bool;
    private var _loadQuestActions : Bool;
    
    //Mapping of uids to UserLoggingData instances.
    private var _userLoggingData : Dictionary<String, Dynamic>;
    
    private var _userLoadedCallback : Function;
    
    public function new(
            server : ICgsServerApi, uids : Array<String>,
            cid : Int = -1, startTime : Float = -1, endTime : Float = -1,
            loadQuests : Bool = true, loadQuestActions : Bool = false,
            completeCallback : Function = null)
    {
        super(completeCallback);
        
        _server = server;
        _uids = uids;
        _cid = cid;
        _startTime = startTime;
        _endTime = endTime;
        _loadQuests = loadQuests;
        _loadQuestActions = loadQuestActions;
        
        _userLoggingData = new Dictionary<String, Dynamic>();
    }
    
    /**
     * Set a callback that will be called when logging data is loaded for a single user.
     * @param callback function should have the following signature: (logData:UserLoggingData):void
     */
    public function setUserLoggingDataCallback(callback : Function) : Void
    {
        _userLoadedCallback = callback;
    }
    
    override public function makeRequests(handler : IUrlRequestHandler) : Void
    {
        if (_uids == null)
        {
            loadPageLoads();
        }
        else
        {
            loadUserLoggingData(true);
        }
    }
    
    private function loadPageLoads() : Void
    {
        var message : Message = _server.getServerMessage();
        message.injectGameParams();
        message.addProperty("cid", _cid);
        
        _server.request(CGSServerConstants.GET_PAGELOADS_BY_CID, handlePageLoads, message);
    }
    
    private function handlePageLoads(response : CgsResponseStatus) : Void
    {
        var userPageloads : Array<PageLoadData>;
        var userPageloadsMap : Dictionary = new Dictionary();
        var pageloads : Array<Dynamic> = response.data;
        
        var currPageload : PageLoadData;
        var currUid : String;
        var userCount : Int = 0;
        for (pageloadObj in pageloads)
        {
            currPageload = new PageLoadData();
            currPageload.parseObjectData(pageloadObj);
            currUid = currPageload.uid;
            if (currUid != null)
            {
                userPageloads = userPageloadsMap[currUid];
                if (userPageloads == null)
                {
                    userPageloads = new Array<PageLoadData>();
                    userPageloadsMap[currUid] = userPageloads;
                    userCount++;
                }
                
                userPageloads.push(currPageload);
                
                if (userCount > 500)
                {  //break;  
                    
                }
            }
        }
        
        var uids : Array<String> = new Array<String>();
        for (uidKey in Reflect.fields(userPageloadsMap))
        {
            uids.push(uidKey);
            userPageloads = userPageloadsMap[uidKey];
            setUserPageloads(uidKey, userPageloads);
        }
        
        _uids = uids;
        
        loadUserLoggingData();
    }
    
    private function loadUserLoggingData(loadPageLoads : Bool = false) : Void
    {
        var questRequest : UserQuestDataRequest;
        for (uid in _uids)
        {
            if (loadPageLoads)
            {
                loadUserPageLoads(uid, _server);
            }
            
            loadUserGameActions(uid, _server);
            
            questRequest = new UserQuestDataRequest(
                    _server, uid, _loadQuestActions, handleQuestDataLoaded);
            questRequest.makeRequests(null);
        }
    }
    
    private function loadUserPageLoads(uid : String, server : ICgsServerApi) : Void
    {
        var message : Message = server.getServerMessage();
        message.injectGameParams();
        message.addProperty("uid", uid);
        
        server.request(
                CGSServerConstants.GET_PAGELOADS_BY_UID, 
                handleUserPageLoads, message, null, null, uid
        );
    }
    
    private function handleUserPageLoads(response : ResponseStatus) : Void
    {
    }
    
    private function setUserPageloads(uid : String, pageloads : Array<PageLoadData>) : Void
    {
        var logData : UserLoggingData = getUserLoggingData(uid);
        logData.setPageLoadData(pageloads);
        
        testUserDataLoaded(uid);
    }
    
    private function loadUserGameActions(uid : String, server : ICgsServerApi) : Void
    {
        var message : Message = server.getServerMessage();
        message.injectGameParams();
        message.addProperty("uid", uid);
        
        server.request(
                CGSServerConstants.GET_NO_QUEST_ACTIONS_BY_UID, 
                handleGameActionsLoaded, message, null, null, uid
        );
    }
    
    private function handleGameActionsLoaded(response : CgsResponseStatus) : Void
    {
        var currAction : GameAction;
        var actions : Array<GameAction> = new Array<GameAction>();
        
        var data : Array<Dynamic> = response.data;
        var uid : String = response.passThroughData;
        for (actionObj in data)
        {
            currAction = new GameAction();
            currAction.parseObjectData(actionObj);
            actions.push(currAction);
        }
        
        var logData : UserLoggingData = getUserLoggingData(uid);
        logData.setGameAction(actions);
        
        testUserDataLoaded(uid);
        testAllUserDataLoaded();
    }
    
    private function handleQuestDataLoaded(request : UserQuestDataRequest) : Void
    {
        var logData : UserLoggingData = getUserLoggingData(request.uid);
        logData.setQuestData(request.userQuestData);
        testUserDataLoaded(request.uid);
        testAllUserDataLoaded();
    }
    
    //Get the user logging data for user with the given uid.
    private function getUserLoggingData(uid : String) : UserLoggingData
    {
        var logData : UserLoggingData = _userLoggingData[uid];
        if (logData == null)
        {
            logData = new UserLoggingData(uid);
            _userLoggingData[uid] = logData;
        }
        
        return logData;
    }
    
    //Test if logging data is loaded for user. Handle callback if data is loaded.
    private function testUserDataLoaded(uid : String) : Void
    {
        var logData : UserLoggingData = _userLoggingData[uid];
        if (testUserLogDataLoaded(logData))
        {
            if (_userLoadedCallback != null)
            {
                _userLoadedCallback(logData);
            }
        }
    }
    
    private function testUserLogDataLoaded(logData : UserLoggingData) : Bool
    {
        if (logData == null)
        {
            return false;
        }
        
        if (!logData.arePageLoadsValid || !logData.areActionsValid)
        {
            return false;
        }
        if (_loadQuests && !logData.areQuestsValid)
        {
            return false;
        }
        
        return true;
    }
    
    private function testAllUserDataLoaded() : Void
    {
        var currLogData : UserLoggingData;
        for (uid in _uids)
        {
            currLogData = _userLoggingData[uid];
            if (currLogData == null)
            {
                return;
            }
            if (!testUserLogDataLoaded(currLogData))
            {
                return;
            }
        }
        
        makeCompleteCallback();
    }
}
