package cgs.server.responses;

import cgs.utils.Error;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;

class Response
{
    public var canceled(get, never) : Bool;
    public var sendTime(get, set) : Int;
    public var completeTime(get, set) : Int;
    public var data(get, set) : String;
    public var success(get, never) : Bool;
    public var statusCode(get, set) : Int;
    public var localError(get, set) : Error;
    public var ioError(get, set) : IOErrorEvent;
    public var securityError(get, set) : SecurityErrorEvent;

    private var _sendTime : Int;
    private var _endTime : Int;
    
    private var _canceled : Bool;
    
    //Indicates that data was set on the response.
    private var _serverSuccess : Bool;
    
    private var _data : String;
    private var _statusCode : Int;
    
    private var _localError : Error;
    private var _ioError : IOErrorEvent;
    private var _securityError : SecurityErrorEvent;
    
    public function new()
    {
    }
    
    public function cancel() : Void
    {
        _canceled = true;
    }
    
    private function get_canceled() : Bool
    {
        return _canceled;
    }
    
    private function set_sendTime(timeMs : Int) : Int
    {
        _sendTime = timeMs;
        return timeMs;
    }
    
    private function get_sendTime() : Int
    {
        return _sendTime;
    }
    
    private function set_completeTime(timeMs : Int) : Int
    {
        _endTime = timeMs;
        return timeMs;
    }
    
    private function get_completeTime() : Int
    {
        return _endTime;
    }
    
    private function set_data(value : String) : String
    {
        _serverSuccess = true;
        _data = value;
        return value;
    }
    
    private function get_data() : String
    {
        return _data;
    }
    
    private function get_success() : Bool
    {
        return _serverSuccess;
    }
    
    /**
     * Get the status code returned for the url request. This value may not be
     * set properly as flash can sometimes not access this value within the browser.
     */
    private function get_statusCode() : Int
    {
        return _statusCode;
    }
    
    private function set_statusCode(value : Int) : Int
    {
        _statusCode = value;
        return value;
    }
    
    private function set_localError(err : Error) : Error
    {
        _localError = err;
        _serverSuccess = false;
        return err;
    }
    
    private function get_localError() : Error
    {
        return _localError;
    }
    
    private function set_ioError(evt : IOErrorEvent) : IOErrorEvent
    {
        _ioError = evt;
        _serverSuccess = false;
        return evt;
    }
    
    private function get_ioError() : IOErrorEvent
    {
        return _ioError;
    }
    
    private function set_securityError(evt : SecurityErrorEvent) : SecurityErrorEvent
    {
        _securityError = evt;
        _serverSuccess = false;
        return evt;
    }
    
    private function get_securityError() : SecurityErrorEvent
    {
        return _securityError;
    }
}
