package cgs.server.requests;

import openfl.net.URLRequest;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.responses.Response;
import cgs.server.responses.ResponseStatus;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

interface IUrlRequest
{
    
    /**
     * Set the local unique id for the request.
     */
    
    
    var id(get, set) : Int;    
    
    var urlRequest(get, never) : URLRequest;    
    
    var dataFormat(get, never) : String;    
    
    /**
     * Set the callback to be called when the request is finished.
     * Function should have the signature: (response:ResponseStatus):void.
     *
     * @param value the function to be called when the request completes or fails.
     */
    
    
    var callback(get, set) : Dynamic;    
    
    /**
     * The method type for the request @see URLRequestMethod for valid types.
     */
    var method(never, set) : String;    
    
    
    
    /**
     * Get the response status object used for this request. If this
     * value is null it will not be used.
     */
    var responseStatus(get, set) : ResponseStatus;    
    
    /**
     * Set the request timeout in milliseconds. Resending of requests with timeouts
     * is not supported.
     *
     * @param milliseconds the number of milliseconds to wait before timing
     * out the request.
     */
    
    
    /**
     * Get the timeout for the request in milliseconds.
     */
    var timeout(get, set) : Int;    
    
    /**
     * Set the request timeout in seconds. Resending of requests with timeouts
     * is not supported.
     *
     * @param seconds the number of milliseconds to wait before timing
     * out the request.
     */
    var timeoutSeconds(never, set) : Int;    
    
    /**
     * Set the time at which the request was submitted. Used for tracking timeouts.
     *
     * @param timeMs the time at which the request was submitted in milliseconds.
     */
    
    
    var submitTime(get, set) : Int;    
    
    /**
     * Set the time at which the request was actually sent to server.
     *
     * @param timeMs the time at which the request was sent to server.
     */
    var sendTime(never, set) : Int;    
    
    /**
     * Set the time at which the request was completed. This is set even if the
     * request failed.
     *
     * @param timeMs the time at which the request was completed in milliseconds.
     */
    var completeTime(never, set) : Int;    
    
    /**
     * Get the duration of the request from send to completion.
     * Will return 0 until complete time is not set.
     *
     * @return the time in millisends from send to server to response.
     */
    var duration(get, never) : Int;    
    
    /**
     * Get the full duration of the request, from submission to completion.
     * Will return 0 until complete time is not set.
     *
     * @return the time in millisends from submission to response.
     */
    var fullDuration(get, never) : Int;    
    
    /**
     * Get the failure count for the request.
     */
    var failureCount(get, never) : Int;    
    
    /**
     * Set the maximum number of times a request can fail before its
     * callback is called with failure.
     */
    var maxFailures(never, set) : Int;    
    
    /**
     * Indicates if the failure count is equal to or greater than the maximum failure count.
     */
    var maxFailuresExceeded(get, never) : Bool;    
    
    /**
     * Indicates if dependencies
     */
    var dependencyFailure(get, never) : Bool;    
    
    /**
     * Set the function to be used as the handler when request has been
     * canceled due to one of its dependencies failing.
     *
     * @param handler function called when request is cancelled. Function
     * should have the following signature: (request:IServerRequest):void.
     */
    var cancelHandler(never, set) : Dynamic;    
    
    //
    // Serialization functions.
    //
    
    /**
     * Get data in dynamic object that can be converted to XML or json.
     */
    var objectData(get, never) : Dynamic;

    
    /**
     * Increment the failure count for the request.
     */
    function failed() : Void
    ;
    
    /**
     * Test to see if the response from the server indicates a failure that
     * neccessitates a resend.
     */
    function isFailure(response : Response) : Bool
    ;
    
    function addQueryParameter(key : String, value : Dynamic) : Void
    ;
    
    //
    // Dependency handling.
    //
    
    /**
     * Add a dependency of another request. This request will be queued until
     * all dependencies are handled.
     */
    function addDependencyById(id : Int, requireSuccess : Bool = false) : Void
    ;
    
    function addRequestDependency(context : RequestDependency) : Void
    ;
    
    function addDependency(depen : IRequestDependency) : Void
    ;
    
    /**
     * Add a function that will be called when any generic request
     * dependencies change state.
     */
    function addDependencyChangeListener(listener : Dynamic) : Void
    ;
    
    /**
     * Called if the request has any dependencies and is ready to be sent
     * to the server. Any logic initiated by this call should be synchronous.
     */
    function handleReady() : Void
    ;
    
    /**
     * Set the function to be used as the handler when request is ready
     * to be sent to the server.
     *
     * @param handler function called prior to request being sent. Function
     * should have the following signature: (request:IServerRequest):void.
     */
    function addReadyHandler(handler : Dynamic) : Void
    ;
    
    /**
     * Indicates if all dependencies have been handled.
     */
    function isReady(completedRequestIds : IntMap<Bool>) : Bool
    ;
    
    /**
     * Called if one of the request dependencies fails and the dependency
     * stipulated success was required. If the request was canceled the callback
     * will also be called and will have a canceled and failed status of true.
     */
    function handleCancel() : Void
    ;
    
    /**
     * Set properties on the request from the given object.
     */
    function parseDataObject(data : Dynamic) : Void
    ;
}
