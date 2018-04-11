package cgs.server.logging.actions;

import cgs.server.logging.data.ISessionSequenceData;

/**
 * Data for an action that does not relate to a quest.
 */
class GameAction implements ISessionSequenceData
{
    public var id(get, never) : Int;
    public var uid(get, never) : String;
    public var sessionSequenceId(get, never) : Int;
    public var isSessionIdValid(get, never) : Bool;
    public var sessionId(get, never) : String;

    private var _logId : Int;
    
    private var _sessionId : String;
    private var _sessionSeqId : Int;
    
    private var _uid : String;
    
    private var _gameId : Int;
    private var _versionId : Int;
    private var _categoryId : Int;
    
    private var _logTs : Float;
    private var _clientTs : Float;
    
    private var _actionId : Int;
    private var _detail : Dynamic;
    
    public function new()
    {
    }
    
    private function get_id() : Int
    {
        return _logId;
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    private function get_sessionSequenceId() : Int
    {
        return _sessionSeqId;
    }
    
    private function get_isSessionIdValid() : Bool
    {
        return _sessionId != null;
    }
    
    private function get_sessionId() : String
    {
        return _sessionId;
    }
    
    public function parseObjectData(data : Dynamic) : Void
    {
        if (Reflect.hasField(data, "sessionid"))
        {
            _sessionId = data.sessionid;
        }
        if (Reflect.hasField(data, "session_seqid"))
        {
            _sessionSeqId = data.session_seqid;
        }
        
        _logId = data.log_no_quest_id;
        _uid = data.uid;
        _gameId = data.gid;
        _versionId = data.vid;
        _categoryId = data.cid;
        
        _actionId = data.aid;
        _detail = data.a_detail;
        
        _logTs = data.log_ts;
        if (Reflect.hasField(data, "client_ts"))
        {
            _clientTs = data.client_ts;
        }
    }
}
