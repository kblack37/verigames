package cgs.server.logging.requests;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.messages.Message;
import cgs.server.responses.CgsResponseStatus;

class ServiceRequest extends ServerRequest
{
    //public var baseUrl(never, set) : String;

    public function new(
            method : String, message : Message,
            gameData : IGameServerData = null, callback : Dynamic = null)
    {
        super(method, callback, null);
        
        this.message = message;
        gameServerData = gameData;
        _urlType = ServerRequest.GENERAL_URL;
        
        _responseStatus = new CgsResponseStatus(gameData);
    }
    
    /**
		 * Set the url to be used for the request.
		 */
    //private function set_baseUrl(url : String) : String
    //{
        //_generalURL = url;
        //return url;
    //}
}
