package networking;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Dictionary;
import flash.net.URLRequestHeader;

//one NetworkConnection object created for each connection and used only once
class NetworkConnection
{
    public var done : Bool = false;
    public var m_callback : Function = null;
    
    public static var postAlerts : Bool = false;
    public static var productionInterop : String;
    
    public static var EVENT_COMPLETE : Int = 1;
    public static var EVENT_ERROR : Int = 2;
    
    public var globalURL : String;
    
    public static var baseURL : String;
    
    public function new()
    {
    }
    
    /**
		 * args:
		 * callback - completion callback
		 * data - any data to send with message
		 * url - Specific URL to send message to. Defaults to proxy URL if null
		 * method - type of message (GET, POST, etc)
		 * request - request to pass to host
		 * */
    
    public static function sendMessage(callback : Function, data : Dynamic = null, url : String = null, method : String = URLRequestMethod.GET, request : String = null) : Void
    {
        var connection : NetworkConnection = new NetworkConnection();
        connection.m_callback = callback;
        connection.sendURL(request, data, method, url);
    }
    
    private function sendURL(request : String, data : Dynamic, method : String, url : String) : Void
    {
        globalURL = url;
        var urlRequest : URLRequest;
        var rand : String = "";
        var contentType : String = URLLoaderDataFormat.TEXT;
        if (request == "authorize")
        {
            if (PlayerValidation.accessGranted())
            {
                rand = "&rand=" + Std.string(Math.round(Math.random() * 1000));
                urlRequest = new URLRequest(url + rand);
                var header : URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + PlayerValidation.accessToken);
                urlRequest.requestHeaders.push(header);
            }
            //reset request
            request == "";
        }
        else if (request == "JSON")
        {
            urlRequest = new URLRequest(url);
            var jsonHeader : URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
        }
        else
        {
            if (request != null && request.indexOf("&") != -1) 
			{
				//IE caches all requests, so things don't update properly without this
                rand = "&rand=" + Std.string(Math.round(Math.random() * 1000));
            }
            
            urlRequest = new URLRequest(url + request + rand);
        }
        var loader : URLLoader = new URLLoader();
        
        if (method == URLRequestMethod.GET)
        {
            urlRequest.method = method;
        }
        else
        {
            urlRequest.method = URLRequestMethod.POST;
            if (data != null)
            {
                if (contentType != null)
                {
                    urlRequest.contentType = contentType;
                }
                urlRequest.data = data;
            }
            else
            {
                urlRequest.data = null;
            }
        }
        configureListeners(loader);
        
        try
        {
            trace(urlRequest.url);
            loader.load(urlRequest);
        }
        catch (error : Error)
        {
            trace("Unable to load requested document.");
        }
    }
    
    private function configureListeners(dispatcher : flash.events.IEventDispatcher) : Void
    {
        dispatcher.addEventListener(flash.events.Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }
    
    private function securityErrorHandler(e : flash.events.SecurityErrorEvent) : Void
    {
        trace(e.text);
        if (postAlerts)
        {
            HTTPCookies.displayAlert(e.text);
        }
    }
    
    private function httpStatusHandler(e : flash.events.HTTPStatusEvent) : Void
    {
        trace(e.status);
        if (postAlerts)
        {
            HTTPCookies.displayAlert(Std.string(e.status));
        }
    }
    
    private function ioErrorHandler(e : flash.events.IOErrorEvent) : Void
    {
        trace(e.text);
        if (postAlerts)
        {
            HTTPCookies.displayAlert(e.text);
        }
        if (m_callback != null)
        {
            m_callback(EVENT_ERROR, null);
        }
    }
    
    private function completeHandler(e : flash.events.Event) : Void
    {
        try
        {
            trace("in complete " + e.target.data);
            if (m_callback != null)
            {
                m_callback(EVENT_COMPLETE, e);
            }
        }
        catch (err : Error)
        {
            trace("ERROR: failure in complete handler " + err);
        }
    }
    
    public function getObjectsFromJSON(json : String) : Array<Dynamic>
    {
        return null;
    }
    
    //when passed an array of JSON objects, or a single object, will
    //find the end of the first JSON object starting at startIndex
    //returns index of end character, or -1 if end not found
    public function findJSONObjectEnd(str : String, startIndex : Int = 0) : Int
    {
        var currentIndex : Int = startIndex;
        var strLength : Int = str.length;
        
        //if we don't have a long enough string, return
        if (startIndex > strLength - 2)
        {
            return -1;
        }
        
        var braceCount : Int = 0;
        do
        {
            var currChar : String = str.charAt(currentIndex);
            if (currChar == "{")
            {
                braceCount++;
            }
            else if (currChar == "}")
            {
                braceCount--;
            }
            currentIndex++;
        }
        while ((braceCount != 0 && currentIndex < strLength));
        
        if (braceCount == 0)
        {
            return as3hx.Compat.parseInt(currentIndex - 1);
        }
        else
        {
            return -1;
        }
    }
}
