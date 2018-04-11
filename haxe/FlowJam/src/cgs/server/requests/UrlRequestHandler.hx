package cgs.server.requests;
import cgs.server.responses.Response;
import cgs.server.responses.ResponseStatus;
import haxe.ds.IntMap;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

class UrlRequestHandler implements IUrlRequestHandler
{
    public var delayRequestListener(never, set) : Dynamic;
    public var urlLoader(never, set) : IUrlLoader;
    public var failureHandler(never, set) : IRequestFailureHandler;
    private var delayRequests(get, never) : Bool;
    public var nextRequestId(get, never) : Int;
    public var objectData(get, never) : Dynamic;

    //Class that handles loading a url request.
    private var _loader : IUrlLoader;
    private var _loaderCompleteCallback : Dynamic;
    private var _loaderErrorCallback : Dynamic;
    
    //Id generator for requests.
    private var _requestId : Int;
    
    //Set of completed request ids. Used to determine of queued requests can
    //be sent.
    private var _completeRequestIdsSet : IntMap<Bool>;
    
    private var _failedRequestHandler : IRequestFailureHandler;
    
    //Function called to determine if request sending should wait to be sent.
    private var _delayRequestListener : Dynamic;
    
    //Timer to handle timeouts.
    private var _timer : Timer;
    private var _timerResolution : Int = 250;
    
    //Requests that have timeouts associated. Mapped to urlloader so that loader
    //can be canceled on timeout.
    private var _timeoutRequests : Map<IUrlRequest, Bool>;
    private var _timeoutRequestCount : Int;
    
    //Requests delayed by the delayRequestListener.
    private var _delayedRequests : Array<IUrlRequest>;
    
    //Requests delayed due to all dependencies not being met.
    private var _waitingRequests : Array<IUrlRequest>;
    private var _handlingWaitingRequests : Bool;
    
    //Requests that have not yet timed out or recieved response.
    private var _pendingRequests : Map<IUrlRequest, Int>;
    
    //Requests that failed when being sent to the server. Kept to potentially
    //be resent later. Not all failed requests will be resent.
    private var _failedRequests : Array<IUrlRequest>;
    
    //Requests that should be cancelled.
    private var _cancelRequests : Array<IUrlRequest>;
    
    private var _terminateRequest : Bool;
    
    /**
     *
     * @param loader a custom UrlLoader class to be used with this request handler.
     * NOTE: any callbacks that have been set on the loader will not be called as
     * they are overridden by this class.
     */
    public function new(
            loader : IUrlLoader = null, failedRequestHandler : IRequestFailureHandler = null)
    {
        _timeoutRequests = new Map<IUrlRequest, Bool>();
        _waitingRequests = new Array<IUrlRequest>();
        _cancelRequests = new Array<IUrlRequest>();
        _completeRequestIdsSet = new IntMap<Bool>();
        _delayedRequests = new Array<IUrlRequest>();
        _failedRequests = new Array<IUrlRequest>();
        
        _pendingRequests = new Map<IUrlRequest, Int>();
        
        _failedRequestHandler = failedRequestHandler;
        if (_failedRequestHandler != null)
        {
            _failedRequestHandler.urlRequestHandler = this;
        }
        
        urlLoader = loader;
    }
    
    public function setRequestCompleted(id : Int) : Void
    {
        _completeRequestIdsSet.set(id, true);
    }
    
    /**
     * Causes the next url request to include the exit parameter in request to server.
     * This parameter causes the server to terminate request without a response.
     * Used to simulate high server load and will only affect dev server requests.
     */
    public function terminateNextRequest() : Void
    {
        _terminateRequest = true;
    }
    
    private function set_delayRequestListener(listener : Void -> Bool) : Void->Bool
    {
        _delayRequestListener = listener;
        return listener;
    }
    
    private function set_urlLoader(loader : IUrlLoader) : IUrlLoader
    {
        if (loader == null)
        {
            _loader = new UrlLoader(handleRequestComplete, handleRequestError);
        }
        else
        {
            _loader = loader;
            
            _loaderCompleteCallback = _loader.completeCallback;
            _loaderErrorCallback = _loader.errorCallback;
            _loader.completeCallback = handleRequestComplete;
            _loader.errorCallback = handleRequestError;
        }
        return loader;
    }
    
    /**
     * @inheritDoc
     */
    private function set_failureHandler(handler : IRequestFailureHandler) : IRequestFailureHandler
    {
        _failedRequestHandler = handler;
        return handler;
    }
    
    /**
     * @inheritDoc
     */
    public function sendUrlRequest(request : IUrlRequest) : Int
    {
        request.submitTime = Math.round(haxe.Timer.stamp() * 1000);
        
        var id : Int = request.id;
        if (id <= 0)
        {
            id = nextRequestId;
            request.id = id;
        }
        
        if (_terminateRequest)
        {
            request.addQueryParameter("exit", 1);
            _terminateRequest = false;
        }
        
        if (delayRequests)
        {
            _delayedRequests.push(request);
        }
        else
        {
            if (!isRequestReady(request))
            {
                request.addDependencyChangeListener(handleRequestDependencyChange);
                _waitingRequests.push(request);
            }
            else
            {
                handleSendRequest(request);
            }
        }
        
        return id;
    }
    
    private function handleRequestDependencyChange(request : IUrlRequest) : Void
    {
        handleWaitingRequests();
    }
    
    //Send the request to the server.
    private function handleSendRequest(request : IUrlRequest) : Void
    {
        if (request.timeout > 0)
        {
            startTimer();
            _timeoutRequests.set(request, true);
        }
        
        if (!(Std.is(request, FailedUrlRequest)))
        {
            _pendingRequests.set(request, 1);
        }
        
        _loader.loadRequest(request);
    }
    
    private function isRequestReady(request : IUrlRequest) : Bool
    {
        var requestReady : Bool = request.isReady(_completeRequestIdsSet);
        if (!requestReady && request.dependencyFailure)
        {
            _cancelRequests.push(request);
        }
        
        return requestReady;
    }
    
    private function isRequestCanceled(request : IUrlRequest) : Bool
    {
        var idx : Int = _cancelRequests.length;
        while (idx > 0)
        {
			idx--;
            if (request == _cancelRequests[idx])
            {
                return true;
            }
        }
        
        return false;
    }
    
    private function handleWaitingRequests() : Void
    {
        if (_waitingRequests.length == 0 || _handlingWaitingRequests)
        {
            return;
        }
        
        _handlingWaitingRequests = true;
        
        //Check dependencies of all waiting requests.
        var remainingRequests : Array<IUrlRequest> = new Array<IUrlRequest>();
        for (request in _waitingRequests)
        {
            if (isRequestReady(request))
            {
                request.handleReady();
                sendUrlRequest(request);
            }
            else
            {
                if (!isRequestCanceled(request))
                {
                    remainingRequests.push(request);
                }
            }
        }
        
        _waitingRequests = remainingRequests;
        
        handleCanceledRequests();
        
        _handlingWaitingRequests = false;
    }
    
    private function handleCanceledRequests() : Void
    {
        for (request in _cancelRequests)
        {
            handleRequestCanceled(request);
        }
        
        _cancelRequests = new Array<IUrlRequest>();
    }
    
    //Send all of the requests that have been delayed.
    private function handleDelayedRequests() : Void
    {
        if (delayRequests)
        {
            return;
        }
        
        for (request in _delayedRequests)
        {
            sendUrlRequest(request);
        }
        
		
        //Clear the waitingRequests array.
		_delayedRequests = new Array<IUrlRequest>();
    }
    
    /**
     * Inidicates if requests should be delayed
     */
    private function get_delayRequests() : Bool
    {
        if (_delayRequestListener == null)
        {
            return false;
        }
        
        return _delayRequestListener();
    }
    
    private function get_nextRequestId() : Int
    {
        return ++_requestId;
    }
    
    private function handleRequestCanceled(request : IUrlRequest) : Void
    {
        var response : Response = _loader.closeRequest(request);
        
        request.handleCancel();
        
        handleRequestComplete(request, response);
    }
    
    //Handles cleanup of request when it is complete.
    private function handleRequestComplete(
            request : IUrlRequest, response : Response) : Void
    {
        if (request.failureCount > 0)
        {
            if (_failedRequestHandler != null)
            {
                _failedRequestHandler.handleRequestComplete(request);
            }
            
            _failedRequests.push(request);
        }
        
        //Remove the request from the pending list.
        _pendingRequests.remove(request);
        
        var responseStatus : ResponseStatus = request.responseStatus;
        responseStatus.response = response;
        
        _completeRequestIdsSet.set(request.id, (responseStatus != null) ? responseStatus.success : false);
        
        var callback : Dynamic = request.callback;
        if (callback != null)
        {
            callback(responseStatus);
        }
        
        //Handle all of the waiting requests.
        handleWaitingRequests();
    }
    
    private function handleRequestError(request : IUrlRequest, response : Response) : Void
    {
        request.failed();
        
        //Only requests that fail due to an error are resent.
        //TODO - Will and error be thrown if the server times out?
        if (_failedRequestHandler != null && !request.maxFailuresExceeded)
        {
            _failedRequestHandler.handleFailedRequest(request);
        }
        else
        {
            request.completeTime = Math.round(haxe.Timer.stamp() * 1000);
            handleRequestComplete(request, response);
        }
    }
    
    //
    // Timer handling.
    //
    
    private function startTimer() : Void
    {
        if (_timer != null)
        {
            return;
        }
        
        _timer = new Timer(_timerResolution);
        _timer.addEventListener(TimerEvent.TIMER, handleTimer);
        _timer.start();
    }
    
    private function stopTimer() : Void
    {
        if (_timer == null)
        {
            return;
        }
        
        _timer.stop();
        _timer.removeEventListener(TimerEvent.TIMER, handleTimer);
        _timer = null;
    }
    
    private function handleTimer(evt : TimerEvent) : Void
    {
        //Handle sending delayed requests if possible.
        handleDelayedRequests();
        
        //Handle timeouts for requests.
        var remainingRequests : Map<IUrlRequest, Bool> = new Map<IUrlRequest, Bool>();
        var requestCount : Int = 0;
        
        var currTime : Int = Math.round(haxe.Timer.stamp() * 1000);
        var currRequestTime : Int;
        var timeout : Int;
		var request : IUrlRequest; 
        for (request in _timeoutRequests.keys())
        {
            currRequestTime = request.submitTime;
            timeout = request.timeout;
            if (currTime - currRequestTime > timeout)
            {
                handleTimeout(request);
            }
            else
            {
                remainingRequests.set(request, _timeoutRequests.get(request));
                ++requestCount;
            }
        }
        
        _timeoutRequests = remainingRequests;
        _timeoutRequestCount = requestCount;
        
        if (requestCount == 0)
        {
            stopTimer();
        }
    }
    
    private function handleTimeout(request : IUrlRequest) : Void
    {
        var response : Response = _loader.closeRequest(request);
        
        var responseStatus : ResponseStatus = request.responseStatus;
        if (responseStatus != null)
        {
            responseStatus.requestTimedOut();
        }
        
        handleRequestComplete(request, response);
    }
    
    //
    // Serialization functions.
    //
    
    private function get_objectData() : Dynamic
    {
        var logData : Dynamic = { };
        
        logData.version = 1;
        
        var completedRequests : Array<Dynamic> = [];
        for (requestId in _completeRequestIdsSet.keys())
        {
            completedRequests.push(requestId);
        }
        
        var requestData : Dynamic;
        
        //Save pending requests.
        var pendingRequests : Array<IUrlRequest> = [];
        for (pendingRequestObj in _pendingRequests.keys())
        {
            if (Std.is(pendingRequestObj, IUrlRequest))
            {
                var pendRequest : IUrlRequest = try cast(pendingRequestObj, IUrlRequest) catch(e:Dynamic) null;
                
                requestData = { };
                requestData.class_name = Type.getClassName(Type.getClass(pendingRequestObj));
                requestData.data = pendRequest.objectData;
                
                pendingRequests.push(requestData);
            }
        }
        
        logData.completed_request_ids = completedRequests;
        logData.delayed_requests = getRequestsObjectData(_delayedRequests);
        logData.waiting_requests = getRequestsObjectData(_waitingRequests);
        logData.failed_requests = getRequestsObjectData(_failedRequests);
        logData.pending_requests = pendingRequests;
        
        return logData;
    }
    
    private function getRequestsObjectData(requests : Array<IUrlRequest>) : Array<Dynamic>
    {
        var requestData : Dynamic;
        
        //Save delayed requests.
        var requestsArray : Array<Dynamic> = [];
        for (request in requests)
        {
            requestData = { };
            requestData.class_name = Type.getClassName(Type.getClass(request));
            requestData.data = request.objectData;
            requestsArray.push(requestData);
        }
        
        return requestsArray;
    }
}
