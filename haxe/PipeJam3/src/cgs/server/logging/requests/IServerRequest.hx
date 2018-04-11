package cgs.server.logging.requests;

import cgs.server.logging.GameServerData;
import cgs.server.requests.IUrlRequest;
import flash.net.URLVariables;

interface IServerRequest extends IUrlRequest
{
    
    /**
     * Set the url to be used for a general request.
     */
    var generalUrl(never, set) : String;    
    
    /**
     * Get the URL for the server request. With all parameters.
     */
    var url(get, never) : String;    
    
    var urlType(never, set) : Int;    
    
    /**
     * Get the URL without any URL variables added.
     */
    var baseURL(get, never) : String;    
    
    var urlVariables(get, never) : URLVariables;    
    
    
    
    var extraData(get, set) : Dynamic;    
    
    var isPOST(get, never) : Bool;    
    
    var isGET(get, never) : Bool;    
    
    var apiMethod(get, never) : String;    
    
    //
    // Functions related to testing if all required data is set.
    //
    
    
    
    var uidRequired(get, set) : Bool;    
    
    var hasUid(get, never) : Bool;    
    
    var hasClientTimestamp(get, never) : Bool;    
    
    var hasSessionId(get, never) : Bool;    
    
    
    
    var gameServerData(get, set) : IGameServerData;

    
    function setMessageProptery(key : String, value : Dynamic) : Void
    ;
    
    function injectUid() : Void
    ;
    
    function injectClientTimestamp(value : Float) : Void
    ;
    
    function injectSessionId(value : String = "") : Void
    ;
    
    function injectParameter(key : String, value : Dynamic) : Void
    ;
}
