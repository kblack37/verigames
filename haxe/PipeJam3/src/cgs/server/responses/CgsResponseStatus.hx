package cgs.server.responses;

import cgs.server.logging.IGameServerData;
import cgs.utils.Error;
import flash.net.URLVariables;
import haxe.Json;

class CgsResponseStatus extends ResponseStatus
{
    public var passThroughData(get, set) : Dynamic;
    public var gameServerData(get, set) : IGameServerData;
    public var hasServerMessage(get, never) : Bool;
    public var serverMessage(get, never) : String;
    public var data(get, never) : Dynamic;
    public var userRegistrationError(get, never) : Bool;
    public var userAuthenticationError(get, never) : Bool;
    public var studentSignupLocked(get, never) : Bool;
    public var dataError(get, never) : Error;

    private var _localResponse : Bool;
    
    private var _passThroughData : Dynamic;
    
    //Message returned from the server. May be null.
    private var _serverMessage : String;
    
    private var _gameServerData : IGameServerData;
    
    private var _tLoad : Int;
    private var _currentResponseVersion : Int;
    
    private var _success : Bool;
    
    private var _dataError : Dynamic;
    
    //Transformed data.
    private var _data : Dynamic;
    
    public function new(serverData : IGameServerData = null)
    {
        super();
        
        _gameServerData = serverData;
    }
    
    /**
     * Indicates that the response data was generated locally. Calling
     * this will allow for success without a server response.
     */
    public function localResponse() : Void
    {
        _localResponse = true;
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        _data = parseResponseData(rawData);
        _success = !didRequestFail(_data);
    }
    
    private function set_passThroughData(value : Dynamic) : Dynamic
    {
        _passThroughData = value;
        return value;
    }
    
    private function get_passThroughData() : Dynamic
    {
        return _passThroughData;
    }
    
    private function set_gameServerData(value : IGameServerData) : IGameServerData
    {
        _gameServerData = value;
        return value;
    }
    
    private function get_gameServerData() : IGameServerData
    {
        return _gameServerData;
    }
    
    /**
     * Indicates if a message was returned from the server with the response.
     */
    private function get_hasServerMessage() : Bool
    {
        return _serverMessage != null;
    }
    
    /**
     * Get the message returned from the server if any. Will be null if no message
     * was returned.
     */
    private function get_serverMessage() : String
    {
        return _serverMessage;
    }
    
    private function get_data() : Dynamic
    {
        return _data;
    }
    
    /**
     * Indicates if the request to the server suceeded.
     */
    override private function get_success() : Bool
    {
        if (_localResponse)
        {
            return _success;
        }
        
        return _success && super.success;
    }
    
    //
    // Cgs Server specific error codes.
    //
    
    /**
     * Indicates if the server request failed due to a user registration error.
     */
    private function get_userRegistrationError() : Bool
    {
        return (hasServerMessage) ?	(_serverMessage == ResponseStatus.USER_REGISTRATION_ERROR_MESSAGE) || (_serverMessage == ResponseStatus.STUDENT_SIGNUP_LOCKED) : false;
    }
    
    /**
     * Indicates if the server request to authenticate a user
     * failed due to incorrect username of password.
     */
    private function get_userAuthenticationError() : Bool
    {
        return (hasServerMessage) ? (_serverMessage == ResponseStatus.USER_AUTHENTICATION_ERROR_MESSAGE) || (_serverMessage == ResponseStatus.STUDENT_SIGNUP_LOCKED) : false;
    }
    
    /**
     * Indicates if student signup has been locked by teacher.
     * This is only applicable if student is trying to authenticate via teacher code.
     */
    private function get_studentSignupLocked() : Bool
    {
        return (hasServerMessage) ? (_serverMessage == ResponseStatus.STUDENT_SIGNUP_LOCKED) : false;
    }
    
    //
    // Helper functions.
    //
    
    /**
     * Parse the data returned from the server
     * Will return null if the parse fails.
     */
    private function parseResponseData(rawData : String, returnDataType : String = "JSON") : Dynamic
    {
        var data : Dynamic = null;
        try
        {
            //Get the data string. Server should be updated to no longer return data
            //as query string data. Will not be possible to parse with larger data sets.
            var dataString : String = "";
            var serverDataString : String = null;
            var serverDataIdx : Int = rawData.indexOf(ResponseStatus.SERVER_RESPONSE_DATA_PREFIX);
            var dataIdx : Int = rawData.indexOf(ResponseStatus.SERVER_RESPONSE_PREFIX);
            if (serverDataIdx > 0 && dataIdx == 0)
            {
                dataString = rawData.substring(ResponseStatus.SERVER_RESPONSE_PREFIX.length, serverDataIdx
                );
            }
            else
            {
                if (dataIdx == 0)
                {
                    dataString = rawData.substr(ResponseStatus.SERVER_RESPONSE_PREFIX.length);
                }
                else
                {
                    if (dataIdx < 0)
                    {
                        //Response is just json.
                        dataString = rawData;
                    }
                    else
                    {
                        var urlVars : URLVariables = new URLVariables(rawData);
                        dataString = urlVars.data;
                        
                        if (Reflect.hasField(urlVars, "server_data"))
                        {
                            serverDataString = urlVars.server_data;
                        }
                    }
                }
            }
            
            if (returnDataType == "JSON")
            {
                data = Json.parse(dataString);
                updateLoggingLoad(data);
                if (Reflect.hasField(data, "message"))
                {
                    _serverMessage = data.message;
                }
            }
            else
            {
                data = dataString;
            }
            
            //TODO - Is this even used? //Handle the server data for the response.
            if (serverDataString != null)
            {
                var serverData : Dynamic = Json.parse(serverDataString);
                
                updateLoggingLoad(serverData);
                
                if (Reflect.hasField(serverData, "pvid"))
                {
                    _currentResponseVersion = serverData.pvid;
                }
                else
                {
                    _currentResponseVersion = 0;
                }
            }
            else
            {
                _currentResponseVersion = 0;
            }
        }
        catch (er : Dynamic)
        {
            //Unable to parse the returned data from the server.
            //Server must have failed.
            _dataError = er;
        }
        
        return data;
    }
    
    private function get_dataError() : Error
    {
        return _dataError;
    }
    
    private function didRequestFail(dataObject : Dynamic) : Bool
    {
        if (dataObject == null)
        {
            return true;
        }
        
        var failed : Bool = false;
        if (Reflect.hasField(dataObject, "tstatus"))
        {
            failed = dataObject.tstatus != "t";
        }
        
        return failed;
    }
    
    private function updateLoggingLoad(jsonObj : Dynamic) : Void
    {
        if (jsonObj == null)
        {
            return;
        }
        
        if (Reflect.hasField(jsonObj, "tload"))
        {
            _tLoad = jsonObj.tload;
        }
    }
}
