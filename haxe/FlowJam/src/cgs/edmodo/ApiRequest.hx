package cgs.edmodo;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.requests.UrlRequest;
import cgs.server.responses.ResponseStatus;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import haxe.Json;

class ApiRequest extends UrlRequest implements IServerRequest
{
    public var generalUrl(never, set) : String;
    public var urlType(never, set) : Int;
    public var gameServerData(get, set) : IGameServerData;
    public var responseClass(get, never) : Class<Dynamic>;
    public var apiMethod(get, never) : String;
    public var baseURL(get, never) : String;
    public var urlVariables(get, never) : URLVariables;
    public var extraData(get, set) : Dynamic;
    public var isPOST(get, never) : Bool;
    public var isGET(get, never) : Bool;
    public var hasUid(get, never) : Bool;
    public var uidRequired(get, set) : Bool;
    public var hasClientTimestamp(get, never) : Bool;
    public var hasSessionId(get, never) : Bool;

    private var _apiData : EdmodoApiData;
    
    private var _apiMethod : String;
    
    private var _extraData : Dynamic;
    
    private var _dataFormat : String;
    
    private var _cgsData : Dynamic;
    
    //Array of URL params to be appended to the request.
    private var _params : Dynamic;
    
    private var _isPOST : Bool;
    
    public function new(apiData : EdmodoApiData, method : String, callback : Dynamic, cgsData : Dynamic,
            params : Dynamic = null, extraData : Dynamic = null, isPOST : Bool = false, dataFormat : String = "text"  /*URLLoaderDataFormat.TEXT*/  ,  /*URLLoaderDataFormat.TEXT*/  )
    {
        super(null, null, callback);
        
        _apiData = apiData;
        _apiMethod = method;
        _cgsData = cgsData;
        _params = params;
        _extraData = extraData;
        _dataFormat = dataFormat;
        _isPOST = isPOST;
    }
    
    public function setMessageProptery(key : String, value : Dynamic) : Void
    {
    }
    
    //Not used.
    private function set_generalUrl(value : String) : String
    {
        return value;
    }
    
    private function set_urlType(value : Int) : Int
    {
        return value;
    }
    
    private function get_gameServerData() : IGameServerData
    {
        return null;
    }
    
    private function set_gameServerData(value : IGameServerData) : IGameServerData
    {
        return value;
    }
    
    private function get_responseClass() : Class<Dynamic>
    {
        return null;
    }
    
    private function get_apiMethod() : String
    {
        return _apiMethod;
    }
    
    override private function get_url() : String
    {
        var baseURL : String = _apiData.apiURL;
        
        var postString : String = (_isPOST) ? "POST" : "GET";
        var paramString : String = "?&r_url_api_action_type=" + postString + "&r_url_api=" + _apiMethod + "?";
        if (_params != null)
        {
            for (paramKey in Reflect.fields(_params))
            {
                paramString += "&" + paramKey + "=" + Reflect.field(_params, paramKey);
            }
        }
        
        //Add cgs data and skey.
        if (_cgsData != null)
        {
            var jsonDataString : String = Json.stringify(_cgsData);
            
            paramString += "&cgs_data=" + jsonDataString;
        }
        
        paramString += "&" + _apiData.cgsSkeyParam;
        
        return baseURL + paramString;
    }
    
    private function get_baseURL() : String
    {
        return _apiData.apiURL + _apiMethod;
    }
    
    private function get_urlVariables() : URLVariables
    {
        var variables : URLVariables = new URLVariables();
        variables.api_key = _apiData.apiKey;
        if (_params != null)
        {
            for (paramKey in Reflect.fields(_params))
            {
                variables[paramKey] = Reflect.field(_params, paramKey);
            }
        }
        
        return variables;
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
    
    private function get_isPOST() : Bool
    {
        return false;
    }
    
    private function get_isGET() : Bool
    {
        return true;
    }
    
    private function get_hasUid() : Bool
    {
        return false;
    }
    
    private function set_uidRequired(value : Bool) : Bool
    {
        return value;
    }
    
    private function get_uidRequired() : Bool
    {
        return false;
    }
    
    public function injectParameter(key : String, value : Dynamic) : Void
    {
    }
    
    public function injectUid() : Void
    {
    }
    
    public function injectClientTimestamp(value : Float) : Void
    {
    }
    
    private function get_hasClientTimestamp() : Bool
    {
        return false;
    }
    
    private function get_hasSessionId() : Bool
    {
        return false;
    }
    
    public function injectSessionId(value : String = "") : Void
    {
    }
    
    override private function get_urlRequest() : URLRequest
    {
        var request : URLRequest = new URLRequest(url);
        
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
}
