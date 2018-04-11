package cgs.server.logging;

import haxe.Constraints.Function;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.requests.IUrlRequestHandler;

/**
 * Contains information regarding information for a quest log.
 */
class QuestLogContext extends LogData
{
    public var localDqid(get, never) : Int;

    public static inline var PARENT_DQID_KEY : String = "parent_dqid";
    public static inline var MULTIPLAYER_SEQUENCE_ID_KEY : String = "multi_seqid";
    
    private var _requestHandler : IUrlRequestHandler;
    
    private var _request : IServerRequest;
    
    private var _localDqid : Int;
    
    public function new(
            request : IServerRequest, requestHandler : IUrlRequestHandler, localDqid : Int)
    {
        super();
        _request = request;
        _requestHandler = requestHandler;
        _localDqid = localDqid;
    }
    
    override public function setPropertyValue(key : String, value : Dynamic) : Void
    {
        _request.setMessageProptery(key, value);
        
        super.setPropertyValue(key, value);
    }
    
    public function addReadyHandler(handler : Function) : Void
    {
        _request.addReadyHandler(handler);
    }
    
    public function addRequestDependencyById(
            requestId : Int, requiresSuccess : Bool = false) : Void
    {
        _request.addDependencyById(requestId, requiresSuccess);
    }
    
    private function get_localDqid() : Int
    {
        return _localDqid;
    }
    
    public function sendRequest() : Void
    {
        _requestHandler.sendUrlRequest(_request);
    }
    
    override public function addPropertyDependcy(propertyKey : String) : IRequestDependency
    {
        var depen : IRequestDependency = super.addPropertyDependcy(propertyKey);
        _request.addDependency(depen);
        
        return depen;
    }
}
