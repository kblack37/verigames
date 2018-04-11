package cgs.server.requests;
import cgs.logger.Logger;
import cgs.utils.Error;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

//import cgs.logger.Logger;
import cgs.server.responses.Response;

class UrlLoader implements IUrlLoader
{
    public var completeCallback(get, set) : Dynamic;
    public var errorCallback(get, set) : Dynamic;

    //Requests awaiting a response. Mapped by URLLoader used to send request.
    private var _pendingRequestsMap : Map<URLLoader, IUrlRequest>;
    private var _pendingLoaderMap : Map<IUrlRequest, URLLoader>;
    private var _pendingRequestCount : Int;
    
    private var _completeCallback : Dynamic;
    private var _errorCallback : Dynamic;
    
    //Map of urlloaders to response.
    private var _responseMap : Map<URLLoader, Response>;
    
    /**
     * @param completeCallback function called when the response is completed.
     * Function should have the following
     * signature: (request:IUrlRequest, response:Response):void
     * @param errorCallback function called if the response fails. Function
     * should have the following signature:
     * (request:IUrlRequest, response:Response):void
     */
    public function new(completeCallback : Dynamic = null, errorCallback : Dynamic = null)
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;
        
        _pendingRequestsMap = new Map<URLLoader, IUrlRequest>();
        _pendingLoaderMap = new Map<IUrlRequest, URLLoader>();
        
        _responseMap = new Map<URLLoader, Response>();
    }
    
    public function closeRequest(request : IUrlRequest) : Response
    {
        var loader : URLLoader = _pendingLoaderMap.get(request);
        if (loader != null)
        {
            var response : Response = getResponse(loader);
            response.cancel();
            response.completeTime = Math.round(haxe.Timer.stamp() * 1000);
            
            loader.close();
            removePendingRequest(loader);
            
            return response;
        }
        
        return null;
    }
    
    //TODO - When porting to Haxe, this function will
    //need to be implemented per platform.
    public function loadRequest(request : IUrlRequest) : Void
    {
        var urlRequest : URLRequest = request.urlRequest;
        
        var urlLoader : URLLoader = new URLLoader();
        urlLoader.dataFormat = request.dataFormat;
        
        var response : Response = getResponse(urlLoader);
        response.sendTime = Math.round(haxe.Timer.stamp() * 1000);
        
        //Add event listeners for the request.
        urlLoader.addEventListener(
                Event.COMPLETE, handleRequestCompleteEvent
        );
        urlLoader.addEventListener(
                IOErrorEvent.IO_ERROR, handleRequestIOError
        );
        urlLoader.addEventListener(
                HTTPStatusEvent.HTTP_STATUS, handleRequestHTTPStatus
        );
        urlLoader.addEventListener(
                SecurityErrorEvent.SECURITY_ERROR, handleRequestSecurityError
        );
        
        addPendingRequest(request, urlLoader);
        
        try
        {
            urlLoader.load(urlRequest);
        }
        catch (e : Error)
        {
            response.localError = e;
            handleRequestError(response, urlLoader);
        }
    }
    
    private function addPendingRequest(request : IUrlRequest, loader : URLLoader) : Void
    {
        _pendingLoaderMap.set(request, loader);
        _pendingRequestsMap.set(loader, request);
        
        ++_pendingRequestCount;
    }
    
    private function removePendingRequest(urlLoader : URLLoader) : IUrlRequest
    {
        if (urlLoader != null)
        {
            var request : IUrlRequest = _pendingRequestsMap.get(urlLoader);
            
            _pendingRequestsMap.remove(urlLoader);
            _pendingLoaderMap.remove(request);
            _responseMap.remove(urlLoader);
			
			--_pendingRequestCount;
            
            return request;
        }
        
        return null;
    }
    
    private function handleRequestCompleteEvent(evt : Event) : Void
    {
        var urlLoader : URLLoader = try cast(evt.target, URLLoader) catch(e:Dynamic) null;
        
        var response : Response = getResponse(urlLoader);
        response.data = urlLoader.data;
        response.completeTime = Math.round(haxe.Timer.stamp() * 1000);
        
        handleRequestComplete(response, urlLoader);
    }
    
    private function handleRequestComplete(response : Response, urlLoader : URLLoader) : Void
    {
        var request : IUrlRequest = removePendingRequest(urlLoader);
        
        if (request.isFailure(response))
        {
            if (_errorCallback != null)
            {
                _errorCallback(request, response);
            }
        }
        else
        {
            if (_completeCallback != null)
            {
                _completeCallback(request, response);
            }
        }
    }
    
    private function handleRequestIOError(evt : IOErrorEvent) : Void
    {
        Logger.log("Flash: " + Std.string(evt));
        
        var loader : URLLoader = try cast(evt.target, URLLoader) catch(e:Dynamic) null;
        var response : Response = getResponse(loader);
        response.ioError = evt;
        
        handleRequestError(response, loader);
    }
    
    private function handleRequestHTTPStatus(evt : HTTPStatusEvent) : Void
    {
        var response : Response = getResponse(try cast(evt.target, URLLoader) catch(e:Dynamic) null);
        response.statusCode = evt.status;
    }
    
    private function handleRequestSecurityError(evt : SecurityErrorEvent) : Void
    {
        Logger.log("Flash: " + Std.string(evt));
        
        var loader : URLLoader = try cast(evt.target, URLLoader) catch(e:Dynamic) null;
        var response : Response = getResponse(loader);
        response.securityError = evt;
        
        handleRequestError(response, loader);
    }
    
    private function handleRequestError(
            response : Response, urlLoader : URLLoader) : Void
    {
        var request : IUrlRequest = removePendingRequest(urlLoader);
        if (_errorCallback != null)
        {
            _errorCallback(request, response);
        }
    }
    
    private function getResponse(loader : URLLoader) : Response
    {
        var response : Response = _responseMap.get(loader);
        if (response == null)
        {
            response = new Response();
            _responseMap.set(loader, response);
        }
        
        return response;
    }
    
    //
    // Properties.
    //
    
    private function set_completeCallback(callback : Dynamic) : Dynamic
    {
        _completeCallback = callback;
        return callback;
    }
    
    private function get_completeCallback() : Dynamic
    {
        return _completeCallback;
    }
    
    private function set_errorCallback(callback : Dynamic) : Dynamic
    {
        _errorCallback = callback;
        return callback;
    }
    
    private function get_errorCallback() : Dynamic
    {
        return _errorCallback;
    }
}
