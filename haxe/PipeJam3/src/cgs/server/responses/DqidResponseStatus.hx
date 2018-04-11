package cgs.server.responses;

import cgs.server.logging.IGameServerData;

class DqidResponseStatus extends CgsResponseStatus
{
    public var dqidRequestFailed(get, never) : Bool;
    public var dqid(get, never) : String;

    private var _dqid : String;
    private var _dqidFailed : Bool;
    
    public function new(serverData : IGameServerData = null)
    {
        super(serverData);
    }
    
    private function get_dqidRequestFailed() : Bool
    {
        return _dqidFailed || failed;
    }
    
    private function get_dqid() : String
    {
        return _dqid;
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        if (localError == null)
        {
            if (Reflect.hasField(data, "dqid"))
            {
                _dqid = this.data.dqid;
                _success = true;
            }
            else
            {
                _success = false;
                _dqidFailed = true;
            }
        }
    }
}
