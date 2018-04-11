package cgs.server.logging.data;


/**
 * Contains all data related to a user pageload.
 */
class PageLoadData implements ISessionSequenceData
{
    public var uid(get, never) : String;
    public var isSessionIdValid(get, never) : Bool;
    public var sessionId(get, never) : String;
    public var sessionSequenceId(get, never) : Int;

    private var _logId : Int;
    
    private var _sessionId : String;
    private var _uid : String;
    
    private var _gameId : Int;
    private var _versionId : Int;
    private var _categoryId : Int;
    private var _conditionId : Int;
    private var _eventId : Int;
    
    private var _clientIp : String;
    private var _hostDomain : String;
    private var _referrerHost : String;
    private var _referrerPath : String;
    
    private var _detail : Dynamic;
    
    private var _logTs : Float;
    private var _clientTs : Float;
    
    public function new()
    {
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    private function get_isSessionIdValid() : Bool
    {
        return _sessionId != null;
    }
    
    private function get_sessionId() : String
    {
        return _sessionId;
    }
    
    private function get_sessionSequenceId() : Int
    {
        return 0;
    }
    
    public function parseObjectData(data : Dynamic) : Void
    {
        if (Reflect.hasField(data, "sessionid"))
        {
            _sessionId = data.sessionid;
        }
        if (Reflect.hasField(data, "uid"))
        {
            _uid = data.uid;
        }
        if (Reflect.hasField(data, "eid"))
        {
            _eventId = data.eid;
        }
        
        _gameId = data.gid;
        _versionId = data.vid;
        _categoryId = data.cid;
        _conditionId = data.cd_id;
        
        _clientIp = data.client_ip;
        _hostDomain = data.host_domain;
        _referrerHost = data.referrer_host;
        _referrerPath = data.referrer_path;
        
        _detail = data.pl_detail;
        
        _logTs = data.log_ts;
        _clientTs = data.client_ts;
    }
}
