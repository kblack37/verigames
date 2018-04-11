package cgs.server.requests;

import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.responses.Response;
import cgs.server.responses.ResponseStatus;
import flash.net.URLRequest;
import haxe.ds.IntMap;

class FailedUrlRequest implements IUrlRequest
{
    public var request(get, never) : IUrlRequest;
    public var retrying(get, set) : Bool;
    public var failCount(get, never) : Int;
    public var nextRetryTime(never, set) : Float;
    public var retryRequired(get, never) : Bool;
    public var callback(get, set) : Dynamic;
    public var responseStatus(get, set) : ResponseStatus;
    public var submitTime(get, set) : Int;
    public var sendTime(never, set) : Int;
    public var completeTime(never, set) : Int;
    public var duration(get, never) : Int;
    public var fullDuration(get, never) : Int;
    public var objectData(get, never) : Dynamic;
    public var id(get, set) : Int;
    public var urlRequest(get, never) : URLRequest;
    public var dataFormat(get, never) : String;
    public var method(never, set) : String;
    public var timeout(get, set) : Int;
    public var timeoutSeconds(never, set) : Int;
    public var failureCount(get, never) : Int;
    public var maxFailures(never, set) : Int;
    public var maxFailuresExceeded(get, never) : Bool;
    public var dependencyFailure(get, never) : Bool;
    public var cancelHandler(never, set) : Dynamic;

    private var _request : IUrlRequest;
    
    //TODO - Do these need to be tracked?
    //private var _prevFailedRequests:Vector.<FailedUrlRequest>;
    
    //Times for the failure request.
    private var _submitTime : Int;
    private var _sendTime : Int;
    private var _completeTime : Int;
    
    //Indicates that the request is complete.
    private var _complete : Bool;
    
    //Failure count used to determine next send time.
    private var _failures : Int;
    
    private var _remainingTime : Float;
    
    //Indicates if the request is currently being retried.
    private var _retrying : Bool;
    
    private var _response : ResponseStatus;
    
    public function new(request : IUrlRequest)
    {
        _request = request;
    }
    
    public function addQueryParameter(key : String, value : Dynamic) : Void
    {
        if (_request == null)
        {
            return;
        }
        
        _request.addQueryParameter(key, value);
    }
    
    public function isFailure(response : Response) : Bool
    {
        if (_request == null)
        {
            return false;
        }
        
        return _request.isFailure(response);
    }
    
    //
    // Failure request functions.
    //
    
    public function complete() : Void
    {
        _complete = true;
    }
    
    private function get_request() : IUrlRequest
    {
        return _request;
    }
    
    private function get_retrying() : Bool
    {
        return _retrying;
    }
    
    private function set_retrying(value : Bool) : Bool
    {
        _retrying = value;
        return value;
    }
    
    /**
     * Request failed again.

    public function retryFailed():void
    {
    ++_failures;
    _retrying = false;
    }*/
    
    private function get_failCount() : Int
    {
        return _failures;
    }
    
    /**
     * Set the time until this request will be sent again.
     */
    private function set_nextRetryTime(time : Float) : Float
    {
        _remainingTime = time;
        return time;
    }
    
    /**
     * Update the remain time until the failed request should be sent to server again.
     * Will return true of the request is ready to be retried.
     */
    public function updateTimeRemaining(delta : Float) : Bool
    {
        _remainingTime -= delta;
        return _remainingTime <= 0;
    }
    
    private function get_retryRequired() : Bool
    {
        return !_retrying && _remainingTime <= 0;
    }
    
    //
    // IUrlRequest functions needed for failure request and not original request.
    //
    
    private function get_callback() : Dynamic
    {
        return handleFailedRequestComplete;
    }
    
    private function handleFailedRequestComplete(response : ResponseStatus) : Void
    {
        var origCallback : Dynamic = _request.callback;
        if (origCallback != null)
        {
            origCallback(_request.responseStatus);
        }
    }
    
    private function get_responseStatus() : ResponseStatus
    {
        if (_complete)
        {
            return _request.responseStatus;
        }
        else
        {
            if (_response == null)
            {
                _response = new ResponseStatus();
            }
            
            _response.request = this;
            return _response;
        }
    }
    
    private function get_submitTime() : Int
    {
        return _submitTime;
    }
    
    private function set_submitTime(timeMs : Int) : Int
    {
        if (_submitTime > 0)
        {
            return timeMs;
        }
        
        _submitTime = timeMs;
        return timeMs;
    }
    
    private function set_sendTime(timeMs : Int) : Int
    {
        if (_sendTime > 0)
        {
            return timeMs;
        }
        
        _sendTime = timeMs;
        return timeMs;
    }
    
    private function set_completeTime(timeMs : Int) : Int
    {
        _completeTime = timeMs;
        _request.completeTime = timeMs;
        return timeMs;
    }
    
    private function get_duration() : Int
    {
        return 0;
    }
    
    private function get_fullDuration() : Int
    {
        return 0;
    }
    
    private function get_objectData() : Dynamic
    {
        return null;
    }
    
    public function parseDataObject(data : Dynamic) : Void
    {
    }
    
    //
    // Functions to access data for original request.
    //
    
    private function set_id(value : Int) : Int
    {  //Does nothing.  
        
        return value;
    }
    
    private function get_id() : Int
    {
        return _request.id;
    }
    
    private function get_urlRequest() : URLRequest
    {
        return _request.urlRequest;
    }
    
    private function get_dataFormat() : String
    {
        return _request.dataFormat;
    }
    
    //Not Used.
    private function set_callback(value : Dynamic) : Dynamic
    {
        return value;
    }
    
    //Not Used.
    private function set_method(value : String) : String
    {
        return value;
    }
    
    //Not Used.
    private function set_responseStatus(value : ResponseStatus) : ResponseStatus
    {
        return value;
    }
    
    private function get_timeout() : Int
    {
        return _request.timeout;
    }
    
    private function set_timeout(millseconds : Int) : Int
    {
        return millseconds;
    }
    
    private function set_timeoutSeconds(seconds : Int) : Int
    {
        return seconds;
    }
    
    private function get_failureCount() : Int
    {
        return _request.failureCount;
    }
    
    public function failed() : Void
    {
        _request.failed();
        
        ++_failures;
        _retrying = false;
    }
    
    private function set_maxFailures(value : Int) : Int
    {
        return value;
    }
    
    private function get_maxFailuresExceeded() : Bool
    {
        return _request.maxFailuresExceeded;
    }
    
    //
    // Dependency handling.
    //
    
    /**
     * @inheritDoc
     
    public function get dependencies():Vector.<RequestDependency>
    {
    return _request.dependencies;
    }*/
    
    public function addDependencyChangeListener(listener : Dynamic) : Void
    {  //Not used.  
        
    }
    
    public function isReady(completedRequestIds : IntMap<Bool>) : Bool
    {
        return _request.isReady(completedRequestIds);
    }
    
    private function get_dependencyFailure() : Bool
    {
        return _request.dependencyFailure;
    }
    
    //Not Used.
    public function addDependencyById(id : Int, requireSuccess : Bool = false) : Void
    {
    }
    
    //Not Used.
    public function addRequestDependency(context : RequestDependency) : Void
    {
    }
    
    public function addDependency(depen : IRequestDependency) : Void
    {
    }
    
    //Not Used.
    public function handleReady() : Void
    {
    }
    
    //Not Used.
    public function addReadyHandler(handler : Dynamic) : Void
    {
    }
    
    //Not Used.
    public function handleCancel() : Void
    {
    }
    
    //Not Used.
    private function set_cancelHandler(handler : Dynamic) : Dynamic
    {
        return handler;
    }
}
