package cgs.server.requests;

import haxe.Constraints.Function;

/**
	 * Handles loading a set of data in succession and will only
 * call the callback when all data has been loaded.
	 */
class BatchedDataRequest extends DataRequest
{
    public var userCallback(get, never) : Function;

    private var _requestGroups : Array<Dynamic>;
    private var _currRequestGroup : Int;
    
    private var _requestHandler : IUrlRequestHandler;
    
    //Requests which are currently waiting for a response from the server.
    private var _currentRequests : Array<Dynamic>;
    
    private var _completeRequests : Array<Dynamic>;
    
    private var _userCallback : Function;
    
    public function new(callback : Function, userCallback : Function)
    {
        super(callback);
        _requestGroups = [];
        _currentRequests = [];
        
        _userCallback = userCallback;
    }
    
    private function get_userCallback() : Function
    {
        return _userCallback;
    }
    
    public function addRequestGroup(requests : Array<Dynamic>) : Void
    {
        for (request in requests)
        {
            request.callback = requestCallback;
        }
        _requestGroups.push(requests);
    }
    
    private function requestCallback(request : DataRequest) : Void
    {
        var removeIdx : Int = Lambda.indexOf(_currentRequests, request);
        if (removeIdx >= 0)
        {
            _currentRequests.splice(removeIdx, 1);
        }
        
        //Are all requests complete or does the next group of requests need to be made.
        if (_currentRequests.length == 0)
        {
            if (_currRequestGroup == _requestGroups.length)
            {
                makeCompleteCallback();
            }
            else
            {
                makeRequests(_requestHandler);
            }
        }
    }
    
    override public function makeRequests(handler : IUrlRequestHandler) : Void
    {
        _requestHandler = handler;
        
        if (_currRequestGroup < _requestGroups.length)
        {
            var requests : Array<Dynamic> = _requestGroups[_currRequestGroup];
            _currRequestGroup++;
            for (request in requests)
            {
                _currentRequests.push(request);
                request.makeRequests(_requestHandler);
            }
        }
    }
}
