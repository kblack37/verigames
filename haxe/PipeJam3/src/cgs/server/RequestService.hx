package cgs.server;

import haxe.Constraints.Function;
import flash.net.URLRequestMethod;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.requests.UrlRequest;

/**
 * Service to handle generic requests.
 */
class RequestService extends RemoteService
{
    public function new(
            requestHandler : IUrlRequestHandler, serviceUrl : String = null)
    {
        super(requestHandler, serviceUrl);
    }
    
    /**
     * Send a generic server request.
     * 
     * @param url the url for the request.
     * @param params the data for the request. If the request is a get request this
     * should be an Object or URLVariables object. If this is a post request
     * the data can also be a byte array or string.
     * @param callback function that will be called when the request is completed.
     * Function should have this signature: function(response:ResponseStatus):void.
     */
    public function genericRequest(
            url : String, requestData : Dynamic,
            callback : Function, method : URLRequestMethod = URLRequestMethod.GET) : Void
    {
        var request : UrlRequest = new UrlRequest(url, requestData, callback, method);
        
        sendRequest(request);
    }
}
