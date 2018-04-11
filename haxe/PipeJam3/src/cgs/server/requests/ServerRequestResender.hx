package cgs.server.requests;

import openfl.utils.Dictionary;
import cgs.server.logging.requests.RequestDependency;

/**
 * Resender that will handle generic url requests and cgs api requests that have
 * dependencies.
 */
//TODO - More state information is required. Need to serialize each cgs user and
//resend through a new cgsServer instance that has been setup.
//Should all of the requests be saved at the per user level as well?
class ServerRequestResender
{
    private var _requestHandler : IUrlRequestHandler;
    
    private var _resendRequests : Array<IUrlRequest>;
    
    //Ids of requests that have already been completed.
    private var _completedRequestIds : Array<Int>;
    
    private var _remappedRequestIds : Dictionary<String, Dynamic>;
    
    public function new(requestHandler : IUrlRequestHandler)
    {
        _requestHandler = requestHandler;
    }
    
    /**
     * Resend all of the requests.
     */
    public function resendRequests() : Void
    {  //Handle resending requests to urlRequestHandler.  
        
        //TODO - Need to replace dependency ids with new request ids.
        
    }
    
    public function parseObjectData(data : Dynamic) : Void
    {
        _remappedRequestIds = new Dictionary<String, Dynamic>();
        
        //Parse all of the server requests that need to be resent.
        _completedRequestIds = new Array<Int>();
        var prevRequestIds : Int = data.completed_request_ids;
        var newRequestId : Int;
        for (prevRequestId in prevRequestIds)
        {
            newRequestId = getNewRequestId(prevRequestId);
            _completedRequestIds.push(newRequestId);
            
            _requestHandler.setRequestCompleted(newRequestId);
        }
        
        _resendRequests = new Array<IUrlRequest>();
        
        createUrlRequests(_resendRequests, data.pending_requests);
        createUrlRequests(_resendRequests, data.failed_requests);
        createUrlRequests(_resendRequests, data.delayed_requests);
        createUrlRequests(_resendRequests, data.waiting_requests);
    }
    
    private function getNewRequestId(prevRequestId : Int) : Int
    {
        var newRequestId : Int;
        if (_remappedRequestIds.exists(prevRequestId))
        {
            newRequestId = _remappedRequestIds[prevRequestId];
        }
        else
        {
            newRequestId = _requestHandler.nextRequestId;
            _remappedRequestIds[prevRequestId] = newRequestId;
        }
        
        return newRequestId;
    }
    
    private function createUrlRequests(
            requests : Array<IUrlRequest>, requestData : Array<Dynamic>) : Void
    {
        if (requestData == null)
        {
            return;
        }
        
        var newRequestId : Int;
        var currRequestClass : Class<Dynamic>;
        var currRequest : IUrlRequest;
        var className : String;
        var currRequestData : Dynamic;
        for (dataObj in requestData)
        {
            className = dataObj.class_name;
            currRequestData = dataObj.data;
            
            currRequestClass = Type.getClass(Type.resolveClass(className));
            if (currRequestClass == null)
            {
                continue;
            }
            
            currRequest = Type.createInstance(currRequestClass, []);
            
            currRequest.parseDataObject(currRequestData);
            requests.push(currRequest);
            
            newRequestId = getNewRequestId(currRequest.id);
            currRequest.id = newRequestId;
        }
    }
}
