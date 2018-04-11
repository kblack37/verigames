package cgs.server.responses;

//import cgs.server.logging.requests.IServerRequest;
//import flash.events.IOErrorEvent;
//import flash.events.SecurityErrorEvent;
import cgs.server.requests.IUrlRequest;
import cgs.utils.Error;

/**
 * Encapsulates data regarding the response from url request.
 */
class ResponseStatus
{
    public var response(never, set) : Response;
    public var timedOut(get, never) : Bool;
    public var maxFailuresExceeded(get, never) : Bool;
    public var failureCount(get, never) : Int;
    public var request(get, set) : IUrlRequest;
    public var rawData(get, never) : String;
    public var success(get, never) : Bool;
    public var failed(get, never) : Bool;
    public var requestFailed(get, never) : Bool;
    public var serverSuccess(get, never) : Bool;
    public var statusCode(get, never) : Int;
    public var ioError(get, never) : Dynamic; // IOErrorEvent;
    public var securityError(get, never) : Dynamic; // SecurityErrorEvent;
    public var canceled(get, never) : Bool;
	public var localError(get, never) : Error;

    public static inline var USER_REGISTRATION_ERROR_MESSAGE : String = "add error";
    public static inline var USER_AUTHENTICATION_ERROR_MESSAGE : String = "auth error";
    public static inline var STUDENT_SIGNUP_LOCKED : String = "signup locked";
    
    public static inline var SERVER_RESPONSE_PREFIX : String = "data=";
    public static inline var SERVER_RESPONSE_DATA_PREFIX : String = "&server_data=";
    
    private var _request : IUrlRequest;
    
    private var _timedOut : Bool;
    
    //Status code returned from http request.
    //private var _statusCode:int;
    
    //Raw data string returned from the server.
    //protected var _rawData:String;
    //private var _localError:Error;
    //private var _ioError:IOErrorEvent;
    //private var _securityError:SecurityErrorEvent;
    
    private var _response : Response;
    
    //protected var _serverSuccess:Boolean;
    //protected var _canceled:Boolean;
    
    public function new()
    {
    }
    
    /**
     * Set the response instance. This sets all of the data and error
     * properties.
     */
    @:final private function set_response(value : Response) : Response
    {
        _response = value;
        handleResponse();
        return value;
    }
    
    /**
     * Override this method to parse response data, etc.
     */
    private function handleResponse() : Void
    {
    }
    
    public function requestTimedOut() : Void
    {
        _timedOut = true;
    }
    
    private function get_timedOut() : Bool
    {
        return _timedOut;
    }
    
    private function get_maxFailuresExceeded() : Bool
    {
        return (_request != null) ? _request.maxFailuresExceeded : false;
    }
    
    private function get_failureCount() : Int
    {
        return (_request != null) ? _request.failureCount : 0;
    }
    
    private function set_request(value : IUrlRequest) : IUrlRequest
    {
        _request = value;
        return value;
    }
    
    private function get_request() : IUrlRequest
    {
        return _request;
    }
    
    /**
     * Set the response string returned from the server.
     *
    public function set responseData(data:String):void
    {
    _serverSuccess = true;
    _success = true;

    _rawData = data;
    }*/
    
    private function get_rawData() : String
    {
        return (_response != null) ? _response.data : null;
    }
    
    /**
     * Indicates if the request to the server suceeded.
     */
    private function get_success() : Bool
    {
        return serverSuccess && !canceled;
    }
    
    /**
     * Indicates if the request failed for whatever reason. requestFailed indicates
     * if the request failed to even make it to server.
     */
    private function get_failed() : Bool
    {
        return !success;
    }
    
    /**
     * Indicates if the actual request to the server failed.
     */
    private function get_requestFailed() : Bool
    {
        return !serverSuccess;
    }
    
    private function get_serverSuccess() : Bool
    {
        return (_response != null) ? _response.success : false;
    }
    
    /**
     * Get the status code returned for the url request. This value may not
     * be set properly as flash can sometimes not access this value within the browser.
     */
    private function get_statusCode() : Int
    {
        return (_response != null) ? _response.statusCode : 0;
    }
    
    /*public function set statusCode(value:int):void
    {
    _statusCode = value;
    }

    public function set localError(err:Error):void
    {
    _localError = err;
    _serverSuccess = false;
    }*/
    
    private function get_localError() : Dynamic
    {
        return (_response != null) ? _response.localError : null;
    }
    
    /*public function set ioError(evt:IOErrorEvent):void
    {
    _ioError = evt;
    _serverSuccess = false;
    }*/
    
    private function get_ioError() : Dynamic // IOErrorEvent
    {
        return (_response != null) ? _response.ioError : null;
    }
    
    /*public function set securityError(evt:SecurityErrorEvent):void
    {
    _securityError = evt;
    _serverSuccess = false;
    }*/
    
    private function get_securityError() : Dynamic // SecurityErrorEvent
    {
        return (_response != null) ? _response.securityError : null;
    }
    
    /*public function requestCanceled():void
    {
    _canceled = true;
    }*/
    
    private function get_canceled() : Bool
    {
        return (_response != null) ? _response.canceled : false;
    }
}
