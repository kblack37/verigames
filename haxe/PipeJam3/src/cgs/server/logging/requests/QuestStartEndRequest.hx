package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.messages.Message;
import cgs.server.requests.DataRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.responses.ResponseStatus;

class QuestStartEndRequest extends DataRequest
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
                CGSServerConstants.GET_QUESTS_BY_DQID, handleDataRetrieved, message
        );
    }
    
    //protected function handleDataRetrieved(response:String, failed:Boolean):void
    private function handleDataRetrieved(response : ResponseStatus) : Void
    {
        //_rawData = parseResponseData(response);
        _rawData = parseResponseData(response.rawData);
        
        makeCompleteCallback();
    }
}
