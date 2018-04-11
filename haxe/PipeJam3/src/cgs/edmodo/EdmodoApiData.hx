package cgs.edmodo;


class EdmodoApiData
{
    public var apiURL(get, never) : String;
    public var cgsSkeyParam(get, never) : String;
    public var apiKey(get, set) : String;
    public var version(never, set) : String;
    public var baseURL(never, set) : String;

    //Version of edmodo api to be used.
    private var _version : String;
    
    //Key for the app that is running.
    private var _apiKey : String;
    
    private var _apiBaseURL : String;
    
    private var _cgsSkey : String;
    
    private var _extAppID : Int;
    
    public function new(url : String, key : String, version : String)
    {
        _apiBaseURL = url;
        //_apiKey = key;
        _version = version;
        _cgsSkey = key;
    }
    
    /**
		 * Get the base URL that will have method and data appended to it.
		 */
    private function get_apiURL() : String
    {
        return _apiBaseURL;
    }
    
    /*public function get apiKeyParam():String
		{
			return "api_key=" + _apiKey;
		}*/
    
    private function get_cgsSkeyParam() : String
    {
        return "cgs_skey=" + _cgsSkey;
    }
    
    private function get_apiKey() : String
    {
        return _apiKey;
    }
    
    private function set_version(value : String) : String
    {
        _version = value;
        return value;
    }
    
    private function set_apiKey(value : String) : String
    {
        _apiKey = value;
        return value;
    }
    
    private function set_baseURL(value : String) : String
    {
        _apiBaseURL = value;
        return value;
    }
}
