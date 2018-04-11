package cgs.server.requests;

interface IUrlRequestHandler
{
    
    var urlLoader(never, set) : IUrlLoader;    
    
    //Get a request id to be assigned manually.
    var nextRequestId(get, never) : Int;    
    
    var failureHandler(never, set) : IRequestFailureHandler;    
    
    var delayRequestListener(never, set) : Void->Bool;    
    
    //
    // Serialization handling.
    //
    
    var objectData(get, never) : Dynamic;

    
    function sendUrlRequest(request : IUrlRequest) : Int
    ;
    
    /**
     * Used to set a request as complete. Only used to handle resending requests
     * from a previous application session. This function should not be used
     * to mark requests, which have been sent during the current session, as complete.
     */
    function setRequestCompleted(id : Int) : Void
    ;
}
