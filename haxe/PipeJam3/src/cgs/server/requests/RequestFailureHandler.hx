package cgs.server.requests;

import cgs.server.logging.requests.IServerRequest;
import cgs.server.requests.IRequestFailureHandler;
import cgs.server.requests.IUrlRequest;
import cgs.server.requests.UrlRequestHandler;
import cgs.server.responses.ResponseStatus;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

class RequestFailureHandler implements IRequestFailureHandler
{
    public var urlRequestHandler(never, set) : IUrlRequestHandler;
    public var failedRequestCount(get, never) : Int;

    //Reference to the server to handle resending.
    private var _requestHandler : IUrlRequestHandler;
    
    //Starting backoff time in seconds.
    private var _startBackoffTime : Float = 1000;
    private var _jitter : Float = 0.5;
    
    //Constant used to calculate the next backoff time.
    private var _backoffFactor : Float = 2;
    
    private var _requests : Array<IServerRequest>;
    
    private var _failedRequests : Array<FailedUrlRequest>;
    
    //Requests which are currently being resent to the server.
    private var _resendingRequests : Map<IUrlRequest, FailedUrlRequest>;
    
    //Timer used to handle request retries.
    private var _retryTimer : Timer;
    private var _prevTime : Float;
    
    public function new()
    {
        _requests = new Array<IServerRequest>();
        
        _failedRequests = new Array<FailedUrlRequest>();
        _resendingRequests = new Map<IUrlRequest, FailedUrlRequest>();
    }
    
    private function set_urlRequestHandler(value : IUrlRequestHandler) : IUrlRequestHandler
    {
        _requestHandler = value;
        return value;
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
     * Cache request that failed being saved on the server. Only requests that
     * are logging data on the server should be cached.
     */
    public function handleFailedRequest(request : IUrlRequest) : Void
    {
        startRetryTimer();
        
        var failedRequest : FailedUrlRequest = _resendingRequests.get(request);
        if (failedRequest != null)
        {
            failedRequest = _resendingRequests.get(request);
            _resendingRequests.remove(request);
            _resendingRequests.remove(failedRequest.request);
        }
        else
        {
            //First failure for the request.
            failedRequest = new FailedUrlRequest(request);
            _failedRequests.push(failedRequest);
        }
        
        //failedRequest.failed();
        failedRequest.nextRetryTime = getRetryTime(failedRequest.failureCount);
    }
    
    public function handleRequestComplete(request : IUrlRequest) : Void
    {
        var failedRequest : FailedUrlRequest = _resendingRequests.get(request);
        
        if (failedRequest == null)
        {
            return;
        }
        
        failedRequest.complete();
        
        _resendingRequests.remove(request);
        _resendingRequests.remove(failedRequest.request);
        
        var removeIdx : Int = Lambda.indexOf(_failedRequests, failedRequest);
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
        
        //Add jitter to try and avoid having lots of clients resending at
        //the same time. Not sure this will do anything to avoid that.
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
        for (failRequest in _failedRequests)
        {
            if (failRequest.retrying)
            {
                continue;
            }
            
            if (failRequest.updateTimeRemaining(timeDiff))
            {
                failRequest.retrying = true;
                _resendingRequests.set(failRequest, failRequest);
                _resendingRequests.set(failRequest.request, failRequest);
                
                _requestHandler.sendUrlRequest(failRequest);
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
}
