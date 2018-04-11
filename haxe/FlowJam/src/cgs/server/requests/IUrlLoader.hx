package cgs.server.requests;

import cgs.server.responses.Response;

interface IUrlLoader
{
    
    
    
    
    var completeCallback(get, set) : Dynamic;    
    
    
    
    var errorCallback(get, set) : Dynamic;

    /**
     * Load a url request.
     */
    function loadRequest(request : IUrlRequest) : Void
    ;
    
    /**
     * Closes a url request. No callback will be called when this
     * function is used to cancel a request.
     */
    function closeRequest(request : IUrlRequest) : Response
    ;
}
