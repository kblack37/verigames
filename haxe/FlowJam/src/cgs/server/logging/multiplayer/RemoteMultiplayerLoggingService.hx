package cgs.server.logging.multiplayer;

import haxe.Constraints.Function;
import cgs.server.logging.IMultiplayerLoggingService;
import cgs.user.ICgsUser;

class RemoteMultiplayerLoggingService implements IMultiplayerLoggingService
{
    public var isDqidValid(get, never) : Bool;
    public var dqid(get, never) : String;
    public var dqidRequestId(get, never) : Int;
    public var isRemoteService(get, never) : Bool;

    private var _users : Array<ICgsUser>;
    
    public function new()
    {
        _users = new Array<ICgsUser>();
    }
    
    private function get_isDqidValid() : Bool
    {
        return false;
    }
    
    private function get_dqid() : String
    {
        return null;
    }
    
    private function get_dqidRequestId() : Int
    {
        return -1;
    }
    
    public function addDqidValidCallback(callback : Function, localDqid : Int = -1) : Void
    {
    }
    
    private function get_isRemoteService() : Bool
    {
        return true;
    }
    
    public function nextMultiplayerSequenceId(callback : Function = null) : Int
    {
        return -1;
    }
    
    public function registerUser(user : ICgsUser) : Void
    {
        if (user == null)
        {
            return;
        }
        
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
}
