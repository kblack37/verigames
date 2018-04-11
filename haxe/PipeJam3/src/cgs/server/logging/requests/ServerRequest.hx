package cgs.server.logging.requests;

import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.IGameServerData;
import cgs.server.logging.messages.Message;
import cgs.server.requests.UrlRequest;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.Response;
import cgs.server.responses.ResponseStatus;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.Bytes;

class ServerRequest extends UrlRequest implements IServerRequest
{
    public var generalUrl(never, set) : String;
    public var requestType(never, set) : URLRequestMethod;
    public var message(never, set) : Message;
    public var hasData(get, never) : Bool;
    public var hasUid(get, never) : Bool;
    public var uidRequired(get, set) : Bool;
    public var hasClientTimestamp(get, never) : Bool;
    public var hasSessionId(get, never) : Bool;
    public var apiMethod(get, never) : String;
    public var urlType(never, set) : Int;
    public var isPOST(get, never) : Bool;
    public var isGET(get, never) : Bool;
    public var extraData(get, set) : Dynamic;
    public var baseURL(get, never) : String;
    public var baseUrl(get, never) : String;
    public var urlVariables(get, never) : URLVariables;
    public var gameServerData(get, set) : IGameServerData;
    public var serverFailureCount(never, set) : Int;

    public static inline var LOGGING_URL : Int = 1;
    public static inline var AB_TESTING_URL : Int = 2;
    public static inline var GENERAL_URL : Int = 3;
    public static inline var INTEGRATION_URL : Int = 4;
    
    public static inline var GET : String = "GET";
    public static inline var POST : String = "POST";
    
    private var _gameServerData : IGameServerData;
    
    public var _generalURL : String;
    
    //Method called on the server.
    public var _serverMethod : String;
    
    //Class used to create a response object when the server responds.
    //public var _responseClass:Class;
    
    //Data payload added to the server request.
    private var _serverResestData : Dynamic;
    
    private var _message : Message;
    
    //URL variables added to the request.
    public var params : Dynamic;
    
    //Extra data which can be stored as part of the request. Not serialized.
    private var _extraData : Dynamic;  //Should not be relied upon.  
    
    private var _uidRequired : Bool;
    
    private var _serverFailureCount : Int;
    
    private var _urlType : Int = LOGGING_URL;
    
    public function new(
            serverMethod : String = null, callback : Dynamic = null,
            data : Dynamic = null, params : Dynamic = null,
            extraData : Dynamic = null,
            url : String = null, serverData : IGameServerData = null)
    {
        super(null, null, callback);
        
        _gameServerData = serverData;
        _serverMethod = (serverMethod != null) ? serverMethod : "";
        _serverResestData = data;
        this.params = params;
        _extraData = extraData;
        _generalURL = url;
    }
    
    public function addParameter(key : String, value : String) : Void
    {
        if (params == null)
        {
            params = { };
        }
        
        Reflect.setField(params, key, value);
    }
    
    public function setMessageProptery(key : String, value : Dynamic) : Void
    {
        if (_message != null)
        {
            _message.addProperty(key, value);
        }
        else
        {
            if (_serverResestData != null)
            {
                Reflect.setField(_serverResestData, key, value);
            }
        }
    }
    
    override public function isFailure(response : Response) : Bool
    {
        if (response.data == "" || response.data == null)
        {
            return true;
        }
        
        return false;
    }
    
    private function set_generalUrl(value : String) : String
    {
        _generalURL = value;
        return value;
    }
    
    /**
     * Set the type of request to be sent to the server.
     */
    private function set_requestType(value : URLRequestMethod) : URLRequestMethod
    {
        _method = value;
        return value;
    }
    
    private function set_message(value : Message) : Message
    {
        _message = value;
        return value;
    }
    
    private function get_hasData() : Bool
    {
        return _serverResestData != null || _message != null;
    }
    
    override private function get_data() : Dynamic
    {
        return (_message != null) ? _message.messageObject : _serverResestData;
    }
    
    /**
     * Injects the valid uid into the request data.
     */
    public function injectUid() : Void
    {
        if (_gameServerData != null && this.data != null)
        {
            data.uid = _gameServerData.uid;
        }
    }
    
    public function injectParameter(key : String, value : Dynamic) : Void
    {
        var dataObj : Dynamic = data;
        if (data != null)
        {
            Reflect.setField(data, key, value);
        }
    }
    
    private function get_hasUid() : Bool
    {
        if (data == null)
        {
            return false;
        }
        
        return Reflect.hasField(data, "uid");
    }
    
    /**
     * @inheritDoc
     */
    private function set_uidRequired(value : Bool) : Bool
    {
        _uidRequired = value;
        return value;
    }
    
    /**
     * @inheritDoc
     */
    private function get_uidRequired() : Bool
    {
        return _uidRequired;
    }
    
    public function injectClientTimestamp(value : Float) : Void
    {
        if (_message != null)
        {
            _message.updateClientTimeStamp();
        }
        else
        {
            if (data != null)
            {
                Reflect.setField(data, "client_ts", value);
            }
        }
    }
    
    private function get_hasClientTimestamp() : Bool
    {
        if (_message != null)
        {
            return _message.hasClientTimeStamp();
        }
        else
        {
            if (data != null)
            {
                return Reflect.hasField(data, "client_ts");
            }
        }
        
        return false;
    }
    
    private function get_hasSessionId() : Bool
    {
        if (_message != null)
        {
            return _message.hasSessionId();
        }
        else
        {
            if (data != null)
            {
                return Reflect.hasField(data, "sessionid");
            }
        }
        
        return false;
    }
    
    public function injectSessionId(value : String = "") : Void
    {
        if (_message != null)
        {
            _message.injectSessionId();
        }
        else
        {
            if (data != null)
            {
                Reflect.setField(data, "sessionid", value);
            }
        }
    }
    
    /*public function get responseClass():Class
    {
    return _responseClass;
    }*/
    
    private function get_apiMethod() : String
    {
        return _serverMethod;
    }
    
    private function set_urlType(value : Int) : Int
    {
        _urlType = value;
        return value;
    }
    
    private function get_isPOST() : Bool
    {
        return _method == POST;
    }
    
    private function get_isGET() : Bool
    {
        return (_method == null) ? true : _method == GET;
    }
    
    private function get_extraData() : Dynamic
    {
        return _extraData;
    }
    
    private function set_extraData(value : Dynamic) : Dynamic
    {
        _extraData = value;
        return value;
    }
    
    private function get_baseURL() : String
    {
        var baseURL : String = "";
        if (_urlType == LOGGING_URL)
        {
            baseURL = _gameServerData.serverURL;
        }
        else
        {
            if (_urlType == AB_TESTING_URL)
            {
                baseURL = _gameServerData.abTestingURL;
            }
            else
            {
                if (_urlType == GENERAL_URL)
                {
                    baseURL = _generalURL;
                }
                else
                {
                    if (_urlType == INTEGRATION_URL)
                    {
                        baseURL = _gameServerData.integrationURL;
                    }
                }
            }
        }
        
        return baseURL + _serverMethod;
    }
    
    private function get_baseUrl() : String
    {
        return baseURL;
    }
    
    private function get_urlVariables() : URLVariables
    {
        var variables : URLVariables = new URLVariables();
        var jsonDataString : String = "";
        if (data != null)
        {
            jsonDataString = Json.stringify(data);
            var includeData : String = jsonDataString;
            
            //Encode the data string based on the server props.
            if (_gameServerData != null)
            {
                if (_gameServerData.dataEncoding == IGameServerData.EncodingType.BASE_64_ENCODING)
                {
                    includeData = Base64.encode(Bytes.ofString(jsonDataString));
                }
            }
            
            variables.data = includeData;
        }
        
        //Only add the game server data vars if not null.
        if (_gameServerData != null)
        {
            if (_gameServerData.skeyHashVersion == IGameServerData.SkeyHashVersion.DATA_SKEY_HASH)
            {
                variables.skey = _gameServerData.createSkeyHash(jsonDataString);
            }
            
            variables.de = _gameServerData.dataEncoding;
            variables.dl = _gameServerData.dataLevel;
            
            //Add latency variable to the request.
            if (_gameServerData.useDevelopmentServer)
            {
                variables.latency = CGSServerConstants.serverLatency;
            }
            
            variables.gid = _gameServerData.gid;
            variables.cid = _gameServerData.cid;
            
            variables.priority = _gameServerData.logPriority;
        }
        
        //Add the URL variables to the URL.
        if (params != null)
        {
            for (param in Reflect.fields(params))
            {
                Reflect.setProperty(variables, params, Reflect.field(params, param));
            }
        }
        if (_queryParams != null)
        {
            for (key in Reflect.fields(_queryParams))
            {
                Reflect.setProperty(variables, key, Reflect.getProperty(_queryParams, key));
            }
            
            //Hack, but it doesn't really matter since this is just for testing.
            //Remove the exit parameter so it is not set again.
            if (Reflect.hasField(_queryParams, "exit"))
            {
                Reflect.setProperty(_queryParams, "exit", null);
            }
        }
        
        //Add a noCache variable to the URL.
        variables.noCache = getTimeStamp();
        
        return variables;
    }
    
    /**
     * Get url for the server request. This url includes all url variables.
     */
    override private function get_url() : String
    {
        var requestURL : String = baseURL;
        var hasParam : Bool = false;
        
        if (isPOST)
        {
            return requestURL;
        }
        
        //Add the data payload to the url.
        var vars : URLVariables = urlVariables;
        return requestURL + "?" + Std.string(vars);
    }
    
    override private function get_responseStatus() : ResponseStatus
    {
        if (_responseStatus == null)
        {
            _responseStatus = new CgsResponseStatus();
        }
        
        //Set the game server data on the response.
        if (Std.is(_responseStatus, CgsResponseStatus))
        {
            var response : CgsResponseStatus = try cast(_responseStatus, CgsResponseStatus) catch(e:Dynamic) null;
            response.gameServerData = _gameServerData;
            response.passThroughData = _extraData;
        }
        
        return super.responseStatus;
    }
    
    override private function get_urlRequest() : URLRequest
    {
        var request : URLRequest = new URLRequest(url);
        request.method = _method;
        
        if (isPOST)
        {
            request = new URLRequest(baseURL);
            request.method = URLRequestMethod.POST;
            request.data = urlVariables;
        }
        else
        {
            request = new URLRequest(url);
            request.method = URLRequestMethod.GET;
        }
        
        return request;
    }
    
    /**
		 * Get timestamp to prevent URL caching.
		 */
    public static function getTimeStamp() : String
    {
        var timeStamp : Float = Date.now().getTime();
        return Std.string(timeStamp);
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
    
    //
    // Integration testing for failures.
    //
    
    private function set_serverFailureCount(count : Int) : Int
    {
        _serverFailureCount = count;
        return count;
    }
    
    private function shouldServerFail() : Bool
    {
        return failureCount < _serverFailureCount && _serverFailureCount > 0;
    }
    
    //
    // Serialization functions.
    //
    
    override public function writeObjectData(data : Dynamic) : Void
    {
        super.writeObjectData(data);
        
        data.url_type = _urlType;
        data.api_method = _serverMethod;
        
        //TODO - This should be saved by request serializer.
        //No need to save for each request.
        //private var _gameServerData:IGameServerData;
        
        if (_generalURL != null)
        {
            data.general_url = _generalURL;
        }
        
        data.server_request_data = _serverResestData;
        data.server_request_params = params;
        
        data.uid_required = _uidRequired;
        
        data.server_failure_count = _serverFailureCount;
        data.url_type = _urlType;
    }
    
    override public function parseDataObject(data : Dynamic) : Void
    {
        super.parseDataObject(data);
    }
}
