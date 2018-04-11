package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.messages.Message;
import cgs.server.requests.DataRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.ResponseStatus;

class QuestActionsRequest extends DataRequest
{
    private var _server : ICgsServerApi;
    
    private var _dqid : String;
    
    public function new(
            server : ICgsServerApi, dqid : String, callback : Function)
    {
        super(callback);
        
        _server = server;
        _dqid = dqid;
    }
    
    override public function makeRequests(handler : IUrlRequestHandler) : Void
    {
        var message : Message = _server.getServerMessage();
        message.injectGameParams();
        
        message.addProperty("dqid", _dqid);
        
        _server.request(
                CGSServerConstants.GET_ACTIONS_BY_DQID, handleActionsRetrieved, message
        );
    }
    
    //protected function handleActionsRetrieved(response:String, failed:Boolean):void
    private function handleActionsRetrieved(response : CgsResponseStatus) : Void
    {
        _rawData = parseResponseData(response.rawData);
        _rawData = response.data;
        
        makeCompleteCallback();
    }
}
