package cgs.server.logging.requests;

import openfl.utils.Dictionary;
import haxe.Constraints.Function;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.CgsServerApi;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.data.QuestData;
import cgs.server.logging.messages.Message;
import cgs.server.requests.DataRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.CgsResponseStatus;

/**
 * Loads and parses all data for a single user.
 *
 * @param uid the user id for which data should be loaded.
 * @param loadActions indicates if actions should also be loaded for the quests. Not yet supported.
 * @param callback function to be called when user quests have been loaded.
 */
class UserQuestDataRequest extends DataRequest
{
    public var uid(get, never) : String;
    public var userQuestData(get, never) : Array<QuestData>;

    private var _server : ICgsServerApi;
    
    private var _uid : String;
    private var _loadActions : Bool;
    
    private var _userQuests : Array<QuestData>;
    private var _userQuestsMap : Dictionary<String, Dynamic>;
    
    public function new(
            server : ICgsServerApi, uid : String, loadActions : Bool, callback : Function)
    {
        super(callback);
        
        _server = server;
        _uid = uid;
        _loadActions = loadActions;
        
        _userQuests = new Array<QuestData>();
        _userQuestsMap = new Dictionary<String, Dynamic>();
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    override public function makeRequests(handler : IUrlRequestHandler) : Void
    {
        var message : Message = _server.getServerMessage();
        message.injectGameParams();
        message.addProperty("uid", _uid);
        
        var callback : Function = ((Std.is(_server, CgsServerApi))) ? handleQuestsResponse : handleQuestsRecieved;
        
        _server.request(CGSServerConstants.GET_QUESTS_BY_UID, callback, message);
    }
    
    private function handleQuestsRecieved(data : String, failed : Bool) : Void
    {
        var responseData : Dynamic = parseResponseData(data);
        parseUsersQuestData(responseData);
    }
    
    private function handleQuestsResponse(response : CgsResponseStatus) : Void
    {
        parseUsersQuestData(response.data);
    }
    
    //Parse users quests data for all users.
    private function parseUsersQuestData(questData : Dynamic) : Void
    {
        var currDqid : String;
        var rawQuestDataObjs : Array<Dynamic>;
        var rawQuestData : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
        for (questObj/* AS3HX WARNING could not determine type for var: questObj exp: EIdent(questData) type: Dynamic */ in questData)
        {
            currDqid = questObj["dqid"];
            
            rawQuestDataObjs = rawQuestData[currDqid];
            if (rawQuestDataObjs == null)
            {
                rawQuestDataObjs = [];
                rawQuestData[currDqid] = rawQuestDataObjs;
            }
            rawQuestDataObjs.push(questObj);
        }
        
        //Create user quest data without actions.
        var currQuestData : Array<Dynamic>;
        var newQuestData : QuestData;
        for (dqid in Reflect.fields(rawQuestData))
        {
            currQuestData = rawQuestData[dqid];
            newQuestData = new QuestData();
            newQuestData.parseQuestData(currQuestData);
            
            _userQuests.push(newQuestData);
            _userQuestsMap[dqid] = newQuestData;
        }
        
        if (_loadActions)
        {
            requestUserActions();
        }
        else
        {
            _complete = true;
            makeCompleteCallback();
        }
    }
    
    private function requestUserActions() : Void
    {
        var message : Message = _server.getServerMessage();
        message.injectGameId();
        message.addProperty("uid", _uid);
        
        var callback : Function = ((Std.is(_server, CgsServerApi))) ? handleQuestActionsResponse : handleQuestActionsRecieved;
        _server.request(CGSServerConstants.GET_QUEST_ACTIONS, callback, message);
    }
    
    private function handleQuestActionsResponse(response : CgsResponseStatus) : Void
    {
        parseQuestActions(response.data);
    }
    
    private function handleQuestActionsRecieved(rawData : String, failed : Bool) : Void
    {
        var responseData : Dynamic = parseResponseData(rawData);
        parseQuestActions(responseData);
    }
    
    private function parseQuestActions(data : Dynamic) : Void
    {
        //Mapping of dqids to raw quest actions.
        var actionsMap : Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
        var dqid : String;
        var questActions : Array<Dynamic>;
        
        //Get all of the actions for each dqid.
        for (actionObj/* AS3HX WARNING could not determine type for var: actionObj exp: EIdent(data) type: Dynamic */ in data)
        {
            dqid = actionObj.dqid;
            
            questActions = actionsMap[dqid];
            if (questActions == null)
            {
                questActions = new Array<Dynamic>();
                actionsMap[dqid] = questActions;
            }
            
            questActions.push(actionObj);
        }
        
        var questData : QuestData;
        for (currDqid in Reflect.fields(_userQuestsMap))
        {
            questData = _userQuestsMap[currDqid];
            questData.parseActionsData(actionsMap[currDqid]);
        }
        
        _complete = true;
        makeCompleteCallback();
    }
    
    private function get_userQuestData() : Array<QuestData>
    {
        return _userQuests;
    }
}
