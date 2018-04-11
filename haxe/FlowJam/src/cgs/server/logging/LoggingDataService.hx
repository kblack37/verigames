package cgs.server.logging;

import haxe.Constraints.Function;
import cgs.server.CgsService;
import cgs.server.logging.requests.QuestDataRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.logging.ICGSServerProps.LoggingVersion;

/**
 * Service to handle requesting logging data from server.
 */
class LoggingDataService extends CgsService
{
    private var _cgsServerApi : ICgsServerApi;
    
    public function new(
            requestHandler : IUrlRequestHandler, server : ICgsServerApi,
            serverTag : String, version : Int = CURRENT_VERSION, useHttps : Bool = false)
    {
        super(requestHandler, serverTag, version, useHttps);
        
        _cgsServerApi = server;
    }
    
    /**
     * Request all of the quest data associated with the given dqid.
     *
     * @param dqid the dynamic quest id for which all quest data
     * should be retrieved from the server.
     * @param callback the callback to be called when quest data has been loaded.
     * The callback should have the
     * following signatire (questData:QuestData, failed:Boolean):void.
     */
    public function requestQuestData(dqid : String, callback : Function = null) : Void
    {
        //TODO - Need to refactor to remove need for cgs server instance.
        var dataRequest : QuestDataRequest = 
        new QuestDataRequest(_cgsServerApi, dqid, callback);
        
        dataRequest.makeRequests(requestHandler);
    }
    
    /**
     * Make a logging request to cgs logging servers.
     * 
     * @param method the name of the logging controller and action on the logging server.
     * @param data the data query parameters for the request.
     * @param callback the function used to return the response. Should have
     * the following signature: function(response:CgsResponseStatus):void.
     */
    public function request(method : String, data : Dynamic, callback : Function) : Void
    {
        _cgsServerApi.request(method, callback, null, data);
    }
}
