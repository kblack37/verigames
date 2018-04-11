package cgs.server.logging;

import haxe.Constraints.Function;
import cgs.user.ICgsUser;

interface IMultiplayerLoggingService
{
    
    var isDqidValid(get, never) : Bool;    
    
    var dqid(get, never) : String;    
    
    var dqidRequestId(get, never) : Int;    
    
    var isRemoteService(get, never) : Bool;

    
    /**
     * Add a callback to pass a dqid back when it becomes valid. It is possible
     * that a dqid may not be valid until another quest starts. This will
     * require tracking which callback belongs to which dqid.
     * 
     * @param callback function used to pass dqid back. function(dqid:String):void.
     */
    function addDqidValidCallback(callback : Function, localDqid : Int = -1) : Void
    ;
    
    /**
     * Get the next multiplayer sequence id. This is incremented anytime a
     * quest start, end or action is logged.
     * 
     * @param callback function used to pass sequence id back. function(seqId:int):void.
     * @return the seqeunce id if it is valid. If there is no valid id, -1 should
     * be returned, e.g. requesting the id from a server.
     */
    function nextMultiplayerSequenceId(callback : Function = null) : Int
    ;
    
    /**
     * Register a user to the multiplayer server. This function should in turn
     * register itself on the user. user.setMultiplayerService(this);
     */
    function registerUser(user : ICgsUser) : Void
    ;
    
    /**
     * Remove the user from the server. This function should remove
     * the service from the user. user.setMultiplayerService(null);
     */
    function removeUser(user : ICgsUser) : Void
    ;
}
