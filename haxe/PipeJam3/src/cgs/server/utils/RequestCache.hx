package cgs.server.utils;

import haxe.Constraints.Function;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.requests.IUrlRequest;
import cgs.server.responses.ResponseStatus;
import openfl.events.TimerEvent;
import openfl.utils.Dictionary;
import openfl.utils.Timer;



class RequestCache
{
    public var failedRequestCount(get, never) : Int;
    public var cachedRequestCount(get, never) : Int;
    public var cachedRequests(get, never) : Array<IServerRequest>;
    public var saveObject(get, never) : Dynamic;

    //Reference to the server to handle resending.
    private var _server : ICgsServerApi;
    
    //Starting backoff time in seconds.
    private var _startBackoffTime : Float = 1000;
    private var _jitter : Float = 0.5;
    
    //Constant used to calculate the next backoff time.
    private var _backoffFactor : Float = 2;
    
    private var _requests : Array<IServerRequest>;
    private var _failedRequests : Array<FailedRequest>;
    
    //Requests which are currently being resent to the server.
    private var _resendingRequests : Map<IUrlRequest, FailedRequest>;
    
    //Timer used to handle request retries.
    private var _retryTimer : Timer;
    private var _prevTime : Float;
    
    public function new(server : ICgsServerApi)
    {
        _server = server;
        
        _requests = new Array<IServerRequest>();
        
        _failedRequests = new Array<FailedRequest>();
        _resendingRequests = new Map<IUrlRequest, FailedRequest>();
    }
    
    public function setRetryParameters(backOffStartTime : Float, backOffFactor : Float) : Void
    {
        _startBackoffTime = backOffStartTime;
        _backoffFactor = backOffFactor;
    }
    
    private function get_failedRequestCount() : Int
    {
        return _failedRequests.length;
    }
    
    /**
     * Save a server request.
     */
    public function cacheRequest(request : IServerRequest) : Void
    {
        _requests.push(request);
    }
    
    private function get_cachedRequestCount() : Int
    {
        return _requests.length;
    }
    
    private function get_cachedRequests() : Array<IServerRequest>
    {
        return _requests.copy();
    }
    
    /**
     * Cache request that failed being saved on the server. Only requests that
     * are logging data on the server should be cached.
     */
    public function cacheFailedRequest(request : IUrlRequest) : Void
    {
        startRetryTimer();
        
        var failedRequest : FailedRequest = new FailedRequest(request);
        failedRequest.replaceCallback(failureCallback);
        failedRequest.nextRetryTime = getRetryTime(failedRequest.failureCount);
        _failedRequests.push(failedRequest);
    }
    
    //Handle the response for a retried response.
    private function failureCallback(response : ResponseStatus) : Void
    {
        var request : IUrlRequest = response.request;
        var failureRequest : FailedRequest = _resendingRequests.get(request);
        var completeRequest : Bool = true;
        if (response.failed)
        {
            completeRequest = false;
            if (failureRequest != null)
            {
                request.failed();
                
                failureRequest.retryFailed();
                _resendingRequests.remove(request);
                
                failureRequest.nextRetryTime = getRetryTime(failureRequest.failureCount);
            }
            if (request.maxFailuresExceeded)
            {
                completeRequest = true;
            }
        }
        
        if (completeRequest)
        {
            removeFailedRequest(request);
            
            //Pass the returned parameters to the original callback.
            var callback : Function = failureRequest.originalCallback;
            //response.passThroughData = failureRequest.originalExtraData;
            request.callback = callback;
            
            if (callback != null)
            {
                callback(response);
            }
        }
    }
    
    private function removeFailedRequest(request : IUrlRequest) : Void
    {
        //Remove the request from the failed list.
        var removeIdx : Int = -1;
        var currIdx : Int = 0;
        for (failedRequest in _failedRequests)
        {
            if (failedRequest.request == request)
            {
                removeIdx = currIdx;
                break;
            }
            currIdx++;
        }
        
        if (removeIdx >= 0)
        {
            _failedRequests.splice(removeIdx, 1);
        }
    }
    
    private function getRetryTime(failCount : Int) : Float
    {
        //Calculate the next retry time.
        var multiplier : Float = (failCount == 0) ? 1 : Math.pow(failCount, _backoffFactor);
        var retryTime : Float = multiplier * _startBackoffTime;
        
        //Add jitter to try and avoid having lots of clients resending at the same time. Not sure this will do anything to avoid that.
        var max : Float = _jitter * _startBackoffTime;
        var min : Float = -max;
        retryTime += getRandomRange(min, max);
        
        return retryTime;
    }
    
    private function getRandomRange(min : Float, max : Float) : Float
    {
        return min + Math.random() * (max - min);
    }
    
    //
    // Retry time handling.
    //
    
    private function handleRetryTimer(evt : TimerEvent) : Void
    {
        var currTime : Float = Math.round(haxe.Timer.stamp() * 1000);
        var timeDiff : Float = currTime - _prevTime;
        _prevTime = currTime;
        
        //Update the remaining time for all failed requests.
        for (failedRequest in _failedRequests)
        {
            if (failedRequest.retrying)
            {
                continue;
            }
            
            if (failedRequest.updateTimeRemaining(timeDiff))
            {
                failedRequest.retrying = true;
                _resendingRequests.set(failedRequest.request, failedRequest);
                
                _server.sendRequest(try cast(failedRequest.request, IServerRequest) catch(e:Dynamic) null);
            }
        }
    }
    
    private function startRetryTimer() : Void
    {
        if (_retryTimer == null)
        {
            _retryTimer = new Timer(100);
            _retryTimer.addEventListener(TimerEvent.TIMER, handleRetryTimer);
        }
        
        if (!_retryTimer.running)
        {
            _prevTime = Math.round(haxe.Timer.stamp() * 1000);
            _retryTimer.start();
        }
    }
    
    private function stopRetryTimer() : Void
    {
        if (_retryTimer == null)
        {
            return;
        }
        
        _retryTimer.stop();
    }
    
    /**
     * Get a save object which contains all logging requests made by the user.
     */
    private function get_saveObject() : Dynamic
    {
        return { };
    }
}



class FailedRequest
{
    public var originalCallback(get, never) : Function;
    public var originalExtraData(get, never) : Dynamic;
    public var request(get, never) : IUrlRequest;
    public var retrying(get, set) : Bool;
    public var failureCount(get, never) : Int;
    public var nextRetryTime(never, set) : Float;

    private var _request : IUrlRequest;
    
    private var _originalCallback : Function;
    private var _originalExtraData : Dynamic;
    
    //Failure count used to determine next send time.
    private var _failures : Int;
    
    private var _remainingTime : Float;
    
    //Indicates if the request is currently being retried.
    private var _retrying : Bool;
    
    @:allow(cgs.server.utils)
    private function new(request : IUrlRequest)
    {
        _request = request;
        _originalCallback = request.callback;
        //_originalExtraData = request.extraData;
        //_request.extraData = _request;
        
        _failures = 0;
    }
    
    private function get_originalCallback() : Function
    {
        return _originalCallback;
    }
    
    private function get_originalExtraData() : Dynamic
    {
        return _originalExtraData;
    }
    
    public function replaceCallback(callback : Function) : Void
    {
        _request.callback = callback;
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
     * Request failed again. Update
     */
    public function retryFailed() : Void
    {
        ++_failures;
        _retrying = false;
    }
    
    private function get_failureCount() : Int
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
     */
    public function updateTimeRemaining(delta : Float) : Bool
    {
        _remainingTime -= delta;
        return _remainingTime <= 0;
    }
}