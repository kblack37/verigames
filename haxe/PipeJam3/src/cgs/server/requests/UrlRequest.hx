package cgs.server.requests;

import cgs.server.logging.RequestDependencyManager;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.responses.Response;
import cgs.server.responses.ResponseStatus;
import haxe.ds.IntMap;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.utils.ByteArray;

/**
 * Base class for url requests.
 */
class UrlRequest implements IUrlRequest
{
    public var urlRequest(get, never) : URLRequest;
    private var requestData(get, never) : Dynamic;
    public var method(never, set) : String;
    public var id(get, set) : Int;
    public var data(get, set) : Dynamic;
    public var url(get, set) : String;
    public var dataFormat(get, set) : String;
    public var callback(get, set) : Dynamic;
    public var timeout(get, set) : Int;
    public var timeoutSeconds(never, set) : Int;
    public var submitTime(get, set) : Int;
    public var sendTime(never, set) : Int;
    public var completeTime(never, set) : Int;
    public var fullDuration(get, never) : Int;
    public var duration(get, never) : Int;
    public var failureCount(get, never) : Int;
    public var maxFailures(never, set) : Int;
    public var maxFailuresExceeded(get, never) : Bool;
    public var responseStatus(get, set) : ResponseStatus;
    public var dependencyFailure(get, never) : Bool;
    public var cancelHandler(never, set) : Dynamic;
    public var objectData(get, never) : Dynamic;

    //Unique local id for the request.
    private var _id : Int;
    
    //Url for the request. This should only include domain and path.
    private var _url : String;
    
    //Raw data for the request.
    private var _rawData : Dynamic;
    private var _data : Dynamic;
    
    //Url request method.
    private var _method : URLRequestMethod;
    
    //Timeout for the request.
    private var _timeoutMs : Int;
    
    //Time variables used to track timeouts and stats.
    private var _submitTime : Int;
    private var _sendTime : Int;
    private var _completeTime : Int;
    
    //Failure handling variables.
    private var _maxFailures : Int;
    private var _failureCount : Int;
    
    //Format of the response data.
    private var _dataFormat : String = URLLoaderDataFormat.TEXT;
    
    //Object to handle the response. Default class will be created
    //if no specific class is provided.
    private var _responseStatus : ResponseStatus;
    
    //Callback to be called when the request has completed.
    private var _callback : Dynamic;
    
    private var _dependencyManager : RequestDependencyManager;
    
    private var _readyHandlers : Array<Dynamic>;
    
    private var _changeCallbacks : Array<Dynamic>;
    
    private var _cancelHandler : Dynamic;
    
    private var _queryParams : Dynamic;
    
    /**
     * Create a new url request instance.
     *
     * @param url the url for the request. Can include query params, but no data
     * should be set on the request if the params are already on the url.
     * @param method the url request method. (Use values found in URLRequestMethod, like GET or POST)
     * @param timeoutSecs the time to wait for the server to respond
     * before returning. If the request times out, the response will
     * indicate failure. Time of 0 means that timeout is up to the server.
     */
    public function new(url : String,
            data : Dynamic = null, callback : Dynamic = null,
            method : URLRequestMethod = URLRequestMethod.GET, timeoutMs : Int = 0)
    {
        _url = url;
        _method = method;
        _callback = callback;
        _timeoutMs = timeoutMs;
        _dependencyManager = new RequestDependencyManager();
        _readyHandlers = new Array<Dynamic>();
        
        _changeCallbacks = new Array<Dynamic>();
        
        this.data = data;
    }
    
    public function addQueryParameter(key : String, value : Dynamic) : Void
    {
        if (_queryParams == null)
        {
            _queryParams = { };
        }
        
        Reflect.setField(_queryParams, key, value);
    }
    
    public function isFailure(response : Response) : Bool
    {
        return false;
    }
    
    /**
     * Get the flash based url request which can be used with a URLLoader.
     */
    private function get_urlRequest() : URLRequest
    {
        var request : URLRequest = new URLRequest(url);
        request.method = _method;
        
        var reqData : Dynamic = requestData;
        if (reqData != null)
        {
            request.data = reqData;
        }
        
        return request;
    }
    
    private function get_requestData() : Dynamic
    {
        if (_queryParams == null)
        {
            return _data;
        }
        
        var requestData : Dynamic = _data;
        
        if (Std.is(_data, URLVariables))
        {
            for (key in Reflect.fields(_queryParams))
            {
                Reflect.setField(_data, key, Reflect.field(_queryParams, key));
            }
        }
        else
        {
            if (_data == null)
            {
                requestData = _queryParams;
            }
        }
        
        return requestData;
    }
    
    private function set_method(value : String) : String
    {
        _method = value;
        return value;
    }
    
    /**
     * Get the id for the request.
     */
    private function get_id() : Int
    {
        return _id;
    }
    
    /**
     * Set the id for the request. Used by the request handler.
     */
    private function set_id(value : Int) : Int
    {
        _id = value;
        return value;
    }
    
    /**
     * Set the data for the request.
     */
    private function set_data(value : Dynamic) : Dynamic
    {
        _rawData = value;
        
        if (Std.is(_rawData, ByteArray) || Std.is(_rawData, String) || Std.is(_rawData, URLVariables))
        {
            _data = _rawData;
        }
        else
        {
            var urlVars : URLVariables = new URLVariables();
            for (key in Reflect.fields(_rawData))
            {
				Reflect.setProperty(urlVars, key, Reflect.field(_rawData, key));
            }
            
            _data = urlVars;
        }
        return value;
    }
    
    /**
     * Set the url for the request.
     */
    private function set_url(value : String) : String
    {
        _url = value;
        return value;
    }
    
    private function get_url() : String
    {
        return _url;
    }
    
    private function get_data() : Dynamic
    {
        return _data;
    }
    
    private function set_dataFormat(value : String) : String
    {
        _dataFormat = value;
        return value;
    }
    
    private function get_dataFormat() : String
    {
        return _dataFormat;
    }
    
    private function set_callback(value : Dynamic) : Dynamic
    {
        _callback = value;
        return value;
    }
    
    private function get_callback() : Dynamic
    {
        return _callback;
    }
    
    //
    // Failure handling.
    //
    
    /**
     * @inheritDoc
     */
    private function set_timeout(milliseconds : Int) : Int
    {
        _timeoutMs = milliseconds;
        return milliseconds;
    }
    
    /**
     * @inheritDoc
     */
    private function get_timeout() : Int
    {
        return _timeoutMs;
    }
    
    private function set_timeoutSeconds(seconds : Int) : Int
    {
        _timeoutMs = seconds * 1000;
        return seconds;
    }
    
    /**
     * @inheritDoc
     */
    private function set_submitTime(timeMs : Int) : Int
    {
        _submitTime = timeMs;
        return timeMs;
    }
    
    /**
     * @inheritDoc
     */
    private function get_submitTime() : Int
    {
        return _submitTime;
    }
    
    /**
     * @inheritDoc
     */
    private function set_sendTime(timeMs : Int) : Int
    {
        _sendTime = timeMs;
        return timeMs;
    }
    
    /**
     * @inheritDoc
     */
    private function set_completeTime(timeMs : Int) : Int
    {
        _completeTime = timeMs;
        return timeMs;
    }
    
    /**
     * @inheritDoc
     */
    private function get_fullDuration() : Int
    {
        if (_completeTime == 0)
        {
            return 0;
        }
        
        return _completeTime - _submitTime;
    }
    
    /**
     * @inheritDoc
     */
    private function get_duration() : Int
    {
        if (_completeTime == 0)
        {
            return 0;
        }
        
        return _completeTime - _sendTime;
    }
    
    /**
     * @inheritDoc
     */
    private function get_failureCount() : Int
    {
        return _failureCount;
    }
    
    /**
     * @inheritDoc
     */
    public function failed() : Void
    {
        ++_failureCount;
    }
    
    /**
     * @inheritDoc
     */
    private function set_maxFailures(value : Int) : Int
    {
        _maxFailures = value;
        return value;
    }
    
    /**
     * @inheritDoc
     */
    private function get_maxFailuresExceeded() : Bool
    {
        if (_maxFailures <= 0)
        {
            return false;
        }
        
        return _failureCount >= _maxFailures;
    }
    
    /**
     * @inheritDoc
     */
    private function set_responseStatus(status : ResponseStatus) : ResponseStatus
    {
        _responseStatus = status;
        return status;
    }
    
    /**
     * @inheritDoc
     */
    private function get_responseStatus() : ResponseStatus
    {
        if (_responseStatus == null)
        {
            _responseStatus = new ResponseStatus();
        }
        
        //Set the request on the response.
        _responseStatus.request = this;
        
        return _responseStatus;
    }
    
    //
    // Dependency handling.
    //
    
    public function addDependencyChangeListener(listener : Dynamic) : Void
    {
        if (listener == null)
        {
            return;
        }
        
        _changeCallbacks.push(listener);
    }
    
    public function isReady(completedRequestIds : IntMap<Bool>) : Bool
    {
        return _dependencyManager.isReady(completedRequestIds);
    }
    
    private function get_dependencyFailure() : Bool
    {
        return _dependencyManager.cancelRequest;
    }
    
    /**
     * @inheritDoc
     */
    public function addDependencyById(id : Int, requireSuccess : Bool = false) : Void
    {
        _dependencyManager.addRequestDependencyById(id, requireSuccess);
    }
    
    /**
     * @inheritDoc
     */
    public function addRequestDependency(context : RequestDependency) : Void
    {
        _dependencyManager.addRequestDependency(context);
    }
    
    public function addDependency(depen : IRequestDependency) : Void
    {
        depen.setChangeListener(handleDependencyChange);
        _dependencyManager.addDependency(depen);
    }
    
    private function handleDependencyChange() : Void
    {
        for (callback in _changeCallbacks)
        {
            callback(this);
        }
    }
    
    /**
     * @inheritDoc
     */
    public function handleReady() : Void
    {
        for (handler in _readyHandlers)
        {
            handler(this);
        }
    }
    
    /**
     * @inheritDoc
     */
    public function addReadyHandler(handler : Dynamic) : Void
    {
        _readyHandlers.push(handler);
    }
    
    /**
     * @inheritDoc
     */
    public function handleCancel() : Void
    {
        if (_cancelHandler != null)
        {
            _cancelHandler(this);
        }
    }
    
    /**
     * @inheritDoc
     */
    private function set_cancelHandler(handler : Dynamic) : Dynamic
    {
        _cancelHandler = handler;
        return handler;
    }
    
    //
    // Serialization handling.
    //
    
    @:final private function get_objectData() : Dynamic
    {
        var data : Dynamic = { };
        
        writeObjectData(data);
        
        return data;
    }
    
    public function writeObjectData(data : Dynamic) : Void
    {
        data.id = _id;
        
        data.url = _url;
        data.raw_data = _rawData;
        
        data.method = _method;
        data.format = _dataFormat;
        
        data.timeout_ms = _timeoutMs;
        data.submit_time = _submitTime;
        data.send_time = _sendTime;
        data.complete_time = _completeTime;
        
        data.max_failures = _maxFailures;
        data.failure_count = _failureCount;
        
        data.dependencies = _dependencyManager.objectData;
    }
    
    public function parseDataObject(data : Dynamic) : Void
    {
        _id = data.id;
        
        _url = data.url;
        
        //Set the url data.
        _rawData = data.raw_data;
        this.data = _rawData;
        
        _method = data.method;
        _dataFormat = data.format;
        
        _timeoutMs = data.timeout_ms;
        _submitTime = data.submit_time;
        _sendTime = data.send_time;
        _completeTime = data.complete_time;
        
        _maxFailures = data.max_failures;
        _failureCount = data.failure_count;
        
        if (Reflect.hasField(data, "dependencies"))
        {  /*var depObjs:Array = data.dependencies;
            var dep:RequestDependency;
            for each(var depObj:Object in depObjs)
            {
            dep = new RequestDependency();
            dep.parseObjectData(depObj);
            addDependency(dep);
            }*/  
            
        }
    }
}

