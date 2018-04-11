package cgs.server.requests;

import haxe.Constraints.Function;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.IGameServerData;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.messages.PageloadMessage;
import cgs.server.logging.requests.ServerRequest;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.ResponseStatus;
import cgs.utils.Guid;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequestMethod;

/**
 * Handle logging a pageload.
 */
class PageloadRequest extends DataRequest
{
    public var requestId(get, never) : Int;

    private var _server : ICgsServerApi;
    
    private var _pageloadDetails : Dynamic;
    private var _gameServerData : IGameServerData;
    
    private var _requestId : Int;
    
    public function new(server : ICgsServerApi,
            details : Dynamic = null, completeCallback : Function = null)
    {
        super(completeCallback);
        
        _server = server;
    }
    
    override public function makeRequests(handler : IUrlRequestHandler) : Void
    {
        //Temp until this is implemented on the server side.
        if (_pageloadDetails == null)
        {
            _pageloadDetails = { };
        }
        
        _gameServerData = _server.getCurrentGameServerData();
        var message : PageloadMessage = 
        new PageloadMessage(_pageloadDetails, _gameServerData, _server.serverTime);
        
        if (_gameServerData.isVersion1)
        {
            _gameServerData.sessionId = Guid.create();
            Reflect.setField(_pageloadDetails, "sessionid", _gameServerData.sessionId);
        }
        if (_gameServerData.atLeastVersion2)
        {
            message.injectClientTimeStamp();
        }
        
        //Inject required parameters for page load.
        message.injectParams();
        message.injectEventID(true);
        message.injectConditionId();
        
        _requestId = _server.serverRequest(
                        CGSServerConstants.PAGELOAD, message, null, null, 
                        ServerRequest.LOGGING_URL, null, null, URLRequestMethod.POST, 
                        URLLoaderDataFormat.TEXT, true, null, handlePageLoadResponse
            );
    }
    
    private function get_requestId() : Int
    {
        return _requestId;
    }
    
    private function handlePageLoadResponse(responseStatus : CgsResponseStatus) : Void
    {
        var responseObj : Dynamic = responseStatus.data;
        var gameData : IGameServerData = responseStatus.gameServerData;
        var generateSessionId : Bool = true;
        if (responseStatus.failed)
        {
        }
        else
        {
            if (responseObj != null)
            {
                if (Reflect.hasField(responseObj, "r_data"))
                {
                    var returnData : Dynamic = responseObj.r_data;
                    if (Reflect.hasField(returnData, "play_count"))
                    {
                        gameData.userPlayCount = returnData.play_count;
                    }
                    if (Reflect.hasField(returnData, "sessionid"))
                    {
                        gameData.sessionId = returnData.sessionid;
                        generateSessionId = false;
                    }
                }
                
                if (generateSessionId && !gameData.isSessionIDValid)
                {
                    gameData.sessionId = Guid.create();
                }
            }
        }
        
        if (_completeCallback != null)
        {
            _completeCallback(responseStatus);
        }
    }
}
