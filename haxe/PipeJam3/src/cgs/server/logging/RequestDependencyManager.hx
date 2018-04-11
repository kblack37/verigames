package cgs.server.logging;

import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.requests.IUrlRequest;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

class RequestDependencyManager
{
    public var cancelRequest(get, never) : Bool;
    public var objectData(get, never) : Dynamic;

    private var _requestDependencies : Array<RequestDependency>;
    
    private var _dependencies : Array<IRequestDependency>;
    
    private var _cancelRequest : Bool;
    
    public function new()
    {
        _requestDependencies = new Array<RequestDependency>();
        _dependencies = new Array<IRequestDependency>();
    }
    
    private function get_cancelRequest() : Bool
    {
        return _cancelRequest;
    }
    
    public function isReady(completeRequestIds : IntMap<Bool>) : Bool
    {
        var requestSuccess : Bool;
        for (context in _requestDependencies)
        {
            if (!completeRequestIds.exists(context.requestId))
            {
                return false;
            }
            else
            {
                if (context.successRequired)
                {
                    requestSuccess = completeRequestIds.get(context.requestId);
                    if (!requestSuccess)
                    {
                        //Request should be cancelled.
                        _cancelRequest = true;
                        
                        return false;
                    }
                }
            }
        }
        
        //Test all of the other dependencies.
        for (depen in _dependencies)
        {
            if (!depen.ready)
            {
                return false;
            }
        }
        
        return true;
    }
    
    public function addDependency(depen : IRequestDependency) : Void
    {
        _dependencies.push(depen);
    }
    
    /**
     * @inheritDoc
     */
    public function addRequestDependencyById(id : Int, requireSuccess : Bool = false) : Void
    {
        if (id <= 0)
        {
            return;
        }
        
        addRequestDependency(new RequestDependency(id, requireSuccess));
    }
    
    /**
     * @inheritDoc
     */
    public function addRequestDependency(context : RequestDependency) : Void
    {
        if (context == null)
        {
            return;
        }
        
        _requestDependencies.push(context);
    }
    
    //
    // Serialization handler.
    //
    
    private function get_objectData() : Dynamic
    {
        return { };
    }
    
    public function parseObjectData(data : Dynamic) : Void
    {  //TODO - Implement.  
        
    }
}
