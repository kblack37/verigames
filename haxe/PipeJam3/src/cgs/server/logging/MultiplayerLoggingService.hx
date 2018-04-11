package cgs.server.logging;

import haxe.Constraints.Function;
import cgs.server.CgsService;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.actions.UserAction;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.QuestLogResponseStatus;
import cgs.user.ICgsUser;
import openfl.utils.Dictionary;

/**
 * Service that can be used to log multiplayer quests
 */
class MultiplayerLoggingService extends CgsService implements IMultiplayerLoggingService
{
    public var isDqidValid(get, never) : Bool;
    public var isRemoteService(get, never) : Bool;
    public var dqid(get, never) : String;
    public var dqidRequestId(get, never) : Int;

    private var _mlsServer : ICgsServerApi;
    
    private var _users : Array<ICgsUser>;
    
    //Used to set dependencies on CgsUser for multiplayer logging.
    private var _dqidRequestId : Int;
    private var _currentLocalDqid : Int;
    private var _currentDqid : String;
    private var _loadingDqid : Bool;
    
    //Multiplayer sequence id is handle here when multiplayer is logged locally.
    private var _multiplayerSeqId : Int;
    
    public function new(
            cgsServer : ICgsServerApi, requestHandler : IUrlRequestHandler,
            serverTag : String, version : Int = CgsService.CURRENT_VERSION, useHttps : Bool = false)
    {
        super(requestHandler, serverTag, version, useHttps);
        
        _mlsServer = cgsServer;
        
        _users = new Array<ICgsUser>();
    }
    
    public function addDqidValidCallback(callback : Function, localDqid : Int = -1) : Void
    {
        _mlsServer.addDqidCallback(callback, _currentLocalDqid);
    }
    
    /**
     * Test to see if the current dqid is valid.
     */
    private function get_isDqidValid() : Bool
    {
        return _currentDqid != null;
    }
    
    private function get_isRemoteService() : Bool
    {
        return false;
    }
    
    private function get_dqid() : String
    {
        return _currentDqid;
    }
    
    private function get_dqidRequestId() : Int
    {
        return _dqidRequestId;
    }
    
    public function nextMultiplayerSequenceId(callback : Function = null) : Int
    {
        return ++_multiplayerSeqId;
    }
    
    public function registerUser(user : ICgsUser) : Void
    {
        _users.push(user);
        
        user.setMultiplayerService(this);
    }
    
    public function removeUser(user : ICgsUser) : Void
    {
        var removeIdx : Int = Lambda.indexOf(_users, user);
        if (removeIdx >= 0)
        {
            _users.splice(removeIdx, 1);
            user.setMultiplayerService(null);
        }
    }
    
    //
    // Logging functions.
    //
    
    public function logAction(
            action : UserAction, multiUid : String, callback : Function = null) : Void
    {
        _mlsServer.logServerMultiplayerAction(
                action, nextMultiplayerSequenceId(), multiUid, callback
        );
    }
    
    public function logQuestAction(
            action : QuestAction, multiUid : String,
            forceFlush : Bool = false, localDqid : Int = -1) : Void
    {
        action.addProperty("multi_seqid", nextMultiplayerSequenceId());
        action.addProperty("multi_uid", multiUid);
        
        _mlsServer.logQuestAction(action, localDqid, forceFlush);
    }
    
    public function logQuestStart(
            questId : Int, questHash : String, details : Dynamic,
            callback : Function = null, aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        _loadingDqid = true;
        _currentDqid = null;
        
        _currentLocalDqid = _mlsServer.logMultiplayerQuestStart(
                        questId, questHash, details, null, nextMultiplayerSequenceId(), 
                        function(response : QuestLogResponseStatus) : Void
                        {
                            //Make sure that the returned dqid is the current dqid.
                            var currDqid : String = _mlsServer.getDqid(_currentLocalDqid);
                            if (currDqid == response.dqid)
                            {
                                _currentDqid = currDqid;
                                _loadingDqid = false;
                            }
                        }, 
                        aeSeqId, localDqid
            );
        
        _dqidRequestId = _mlsServer.getDqidRequestId(_currentLocalDqid);
        
        return _currentLocalDqid;
    }
    
    public function logQuestEnd(
            details : Dynamic, callback : Function = null, localDqid : Int = -1) : Void
    {
        _mlsServer.logMultiplayerQuestEnd(
                details, null, nextMultiplayerSequenceId(), callback, localDqid
        );
    }
}
