package cgs.server.logging.requests;


class RequestDependency
{
    public var requestId(get, set) : Int;
    public var successRequired(get, never) : Bool;
    public var objectData(get, never) : Dynamic;

    private var _requestId : Int;
    private var _successRequired : Bool;
    
    /**
     * Create a new dependency context for a request.
     *
     * @param id the id of the request for the dependency.
     * @param requireSuccess indicates if the request must successfully be
     * completed for the dependency to be satisfied.
     */
    public function new(id : Int = 0, requireSuccess : Bool = false)
    {
        _requestId = id;
        _successRequired = requireSuccess;
    }
    
    private function set_requestId(value : Int) : Int
    {
        _requestId = value;
        return value;
    }
    
    private function get_requestId() : Int
    {
        return _requestId;
    }
    
    private function get_successRequired() : Bool
    {
        return _successRequired;
    }
    
    /**
     * Update the id of the request being depended on. Used for retries of
     * request.
     */
    public function updateRequestId(id : Int) : Void
    {
        _requestId = id;
    }
    
    private function get_objectData() : Dynamic
    {
        return {
            id : _requestId,
            success : _successRequired
        };
    }
    
    public function parseObjectData(data : Dynamic) : Void
    {
        _requestId = data.id;
        _successRequired = data.success;
    }
}
