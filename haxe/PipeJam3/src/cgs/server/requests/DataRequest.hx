package cgs.server.requests;

import haxe.Constraints.Function;
import cgs.server.logging.ICgsServerApi;
import flash.net.URLVariables;
import haxe.Json;

/**
	 * Abstract base class used to make data requests to the server.
	 */
class DataRequest
{
    public var callback(never, set) : Dynamic;
    public var failed(get, never) : Bool;
    public var isComplete(get, never) : Bool;
    public var data(get, never) : Dynamic;

    //Function to be called when all data has been loaded.
    private var _completeCallback : Dynamic;
    
    private var _failed : Bool;
    private var _complete : Bool;
    
    //Indicates if parsing the returned data failed.
    private var _parsingFailed : Bool;
    
    private var _rawData : Dynamic;
    
    /**
		 * Complete callback should have the signature: callback(request:DataRequest):void.
		 */
    public function new(completeCallback : Dynamic)
    {
        _completeCallback = completeCallback;
    }
    
    private function set_callback(value : Dynamic) : Dynamic
    {
        _completeCallback = value;
        return value;
    }
    
    private function makeCompleteCallback() : Void
    {
        if (_completeCallback != null)
        {
            _completeCallback(this);
        }
    }
    
    private function get_failed() : Bool
    {
        return _failed;
    }
    
    /**
		 * Indicates if the request has received data from the server.
		 */
    private function get_isComplete() : Bool
    {
        return _complete;
    }
    
    /**
		 * Get the data that was returned from the server.
		 */
    private function get_data() : Dynamic
    {
        return _rawData;
    }
    
    /**
		 * Apply the data returned from the server to data object in request.
		 */
    public function applyData() : Void
    {
    }
    
    /**
		 * Make all of the required requests to the server to get data.
		 */
    public function makeRequests(server : IUrlRequestHandler) : Void
    {
    }
    
    
    //
    // Helper request functions.
    //
    
    //Parse the data returned from the server will return null if parsing fails.
    private function parseResponseData(rawData : String) : Dynamic
    {
        var data : Dynamic = null;
        try
        {
            var urlVars : URLVariables = new URLVariables(rawData);
            data = Json.parse(urlVars.data);
        }
        catch (e:Dynamic)
        {
            //Unable to parse the returned data from the server. Server must have failed.
            _parsingFailed = true;
        }
        
        return data;
    }
    
    private function didRequestFail(dataObject : Dynamic) : Bool
    {
        if (dataObject == null)
        {
            return true;
        }
        
        var failed : Bool = true;
        if (Reflect.hasField(dataObject, "tstatus"))
        {
            failed = dataObject.tstatus != "t";
        }
        
        return failed;
    }
}
