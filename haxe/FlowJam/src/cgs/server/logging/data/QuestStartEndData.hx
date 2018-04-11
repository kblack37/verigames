package cgs.server.logging.data;
import haxe.Json;


class QuestStartEndData implements IQuestSequenceData
{
    public var isSessionIdValid(get, never) : Bool;
    public var sessionId(get, never) : String;
    public var start(get, never) : Bool;
    public var logTimestamp(get, never) : Float;
    public var qid(get, never) : Int;
    public var details(get, never) : Dynamic;
    public var categoryId(get, never) : Int;
    public var dqid(get, never) : String;
    public var gameId(get, never) : Int;
    public var versionId(get, never) : Int;
    public var uid(get, never) : String;
    public var conditionId(get, never) : Int;
    public var sessionSequenceId(get, never) : Int;
    public var questActionSequenceId(get, never) : Int;
    public var questSequenceId(get, never) : Int;

    private var _start : Bool;
    
    private var _qDetail : Dynamic;
    
    private var _logTimestamp : Float;
    
    private var _qid : Int;
    
    private var _cid : Int;
    private var _dqid : String;
    private var _gid : Int;
    private var _uid : String;
    private var _vid : Int;
    
    private var _conditionId : Int;
    
    private var _sessionId : String;
    private var _questActionSeqId : Int;
    private var _questSeqId : Int;
    private var _sessionSeqId : Int;
    
    public function new()
    {
    }
    
    private function get_isSessionIdValid() : Bool
    {
        return _sessionId != null;
    }
    
    private function get_sessionId() : String
    {
        return _sessionId;
    }
    
    private function get_start() : Bool
    {
        return _start;
    }
    
    private function get_logTimestamp() : Float
    {
        return _logTimestamp;
    }
    
    private function get_qid() : Int
    {
        return _qid;
    }
    
    private function get_details() : Dynamic
    {
        return _qDetail;
    }
    
    private function get_categoryId() : Int
    {
        return _cid;
    }
    
    private function get_dqid() : String
    {
        return _dqid;
    }
    
    private function get_gameId() : Int
    {
        return _gid;
    }
    
    private function get_versionId() : Int
    {
        return _vid;
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    private function get_conditionId() : Int
    {
        return _conditionId;
    }
    
    //
    // Sequence ids.
    //
    
    private function get_sessionSequenceId() : Int
    {
        return _sessionSeqId;
    }
    
    private function get_questActionSequenceId() : Int
    {
        return _questActionSeqId;
    }
    
    private function get_questSequenceId() : Int
    {
        return _questSeqId;
    }
    
    public function parseJsonData(data : Dynamic) : Void
    {
        _qid = data.qid;
        _logTimestamp = data.log_q_ts;
        var rawData : Dynamic = data.q_detail;
        if (rawData != null)
        {
            if (Std.is(rawData, String))
            {
                var stringData : String = rawData;
                if (stringData.charAt(0) == "{" || stringData.charAt(0) == "[")
                {
                    _qDetail = Json.parse(stringData);
                }
                else
                {
                    _qDetail = stringData;
                }
            }
            else
            {
                _qDetail = data.a_detail;
            }
        }
        
        if (Reflect.hasField(data, "q_s_id"))
        {
            _start = data.q_s_id == 1;
        }
        if (Reflect.hasField(data, "cd_id"))
        {
            _conditionId = data.cd_id;
        }
        if (Reflect.hasField(data, "sessionid"))
        {
            _sessionId = data.sessionid;
        }
        if (Reflect.hasField(data, "quest_seqid"))
        {
            _questSeqId = data.quest_seqid;
        }
        if (Reflect.hasField(data, "qaction_seqid"))
        {
            _questActionSeqId = data.qaction_seqid;
        }
        if (Reflect.hasField(data, "session_seqid"))
        {
            _sessionSeqId = data.session_seqid;
        }
        
        //Data params.
        _cid = data.cid;
        _dqid = data.dqid;
        _gid = data.gid;
        _uid = data.uid;
        _vid = data.vid;
    }
}
