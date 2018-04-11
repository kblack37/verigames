package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.data.QuestData;
import cgs.server.requests.BatchedDataRequest;

class QuestDataRequest extends BatchedDataRequest
{
    private var _dqid : String;
    
    private var _actionRequest : QuestActionsRequest;
    private var _startEndRequest : QuestStartEndRequest;
    
    public function new(
            server : ICgsServerApi, dqid : String, userCallback : Function)
    {
        super(null, userCallback);
        
        _dqid = dqid;
        
        _actionRequest = new QuestActionsRequest(server, _dqid, null);
        _startEndRequest = new QuestStartEndRequest(server, _dqid, null);
        
        addRequestGroup([_startEndRequest, _actionRequest]);
    }
    
    override private function makeCompleteCallback() : Void
    {
        handleRequestsComplete();
    }
    
    private function handleRequestsComplete() : Void
    {
        //Create the quest data that will be returned via the userCallback.
        var questData : QuestData = new QuestData();
        
        questData.parseActionsData(_actionRequest.data);
        questData.parseQuestData(_startEndRequest.data);
        
        if (_userCallback != null)
        {
            _userCallback(questData, _failed);
        }
    }
}
