package cgs.server;

import cgs.server.requests.IUrlRequest;
import cgs.server.requests.IUrlRequestHandler;

/**
	 * Abstract base class that will be used for all services used to communicate
	 * with server code. This class can handle queuing requests that require additional
	 * data and also handles retries.
	 */
class RemoteService
{
    private var requestHandler(get, never) : IUrlRequestHandler;
    public var url(get, set) : String;

    private var _requestHandler : IUrlRequestHandler;
    
    private var _serviceUrl : String;
    
    public function new(
            requestHandler : IUrlRequestHandler, serviceUrl : String = null)
    {
        _requestHandler = requestHandler;
        _serviceUrl = serviceUrl;
    }
    
    private function get_requestHandler() : IUrlRequestHandler
    {
        return _requestHandler;
    }
    
    private function get_url() : String
    {
        return _serviceUrl;
    }
    
    private function set_url(value : String) : String
    {
        _serviceUrl = value;
        return value;
    }
    
    public function sendRequest(request : IUrlRequest) : Int
    {
        return _requestHandler.sendUrlRequest(request);
    }
    
    /**
     * Get timestamp to prevent URL caching.
     */
    public static function getTimeStamp() : String
    {
        var timeStamp : Float = Date.now().getTime();
        return Std.string(timeStamp);
    }
}
