package cgs.server.logging;

import haxe.Constraints.Function;

interface IUserInitializationHandler
{
    
    
    //function authenticateUserName(name:String, password:String, serverAuthFunction:Function, server:ICgsServerApi, completeCallback:Function = null):void;
    
    var gradeLevel(never, set) : Int;    
    
    var uidValid(get, never) : Bool;    
    
    var sessionRequestId(get, never) : Int;    
    
    var uidRequestId(get, never) : Int;

    function isAuthenticated(
            serverAuthFunction : Function, server : ICgsServerApi,
            completeCallback : Function, saveCacheDataToServer : Bool = true) : Void
    ;
    function initiliazeUserData(server : ICgsServerApi) : Void
    ;
    
    function authenticateUser(
            name : String, password : String, authKey : String,
            serverAuthFunction : Function, server : ICgsServerApi,
            completeCallback : Function = null,
            saveCacheDataToServer : Bool = true) : Void
    ;
}
