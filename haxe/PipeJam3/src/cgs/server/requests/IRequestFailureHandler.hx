package cgs.server.requests;

import cgs.server.responses.ResponseStatus;

interface IRequestFailureHandler
{
    
    
    var failedRequestCount(get, never) : Int;    
    
    var urlRequestHandler(never, set) : IUrlRequestHandler;

    function handleFailedRequest(request : IUrlRequest) : Void
    ;
    
    function handleRequestComplete(request : IUrlRequest) : Void
    ;
    
    function setRetryParameters(backOffStartTime : Float, backOffFactor : Float) : Void
    ;
}
