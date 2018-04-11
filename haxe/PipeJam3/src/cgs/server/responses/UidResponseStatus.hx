package cgs.server.responses;

import cgs.server.logging.IGameServerData;

/**
	 * Response class to handle server response for a uid request.
	 */
class UidResponseStatus extends CgsResponseStatus
{
    public var uid(get, never) : String;
    public var cacheUid(never, set) : String;

    private var _uid : String;
    private var _uidFailed : Bool;
    
    public function new(serverData : IGameServerData = null)
    {
        super(serverData);
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    private function set_cacheUid(value : String) : String
    {
        localResponse();
        
        _uid = value;
        _success = true;
        return value;
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        if (localError == null)
        {
            if (data != null && Reflect.hasField(data, "uid"))
            {
                _uid = this.data.uid;
                _success = true;
            }
            else
            {
                _success = false;
                _uidFailed = true;
            }
        }
    }
}
