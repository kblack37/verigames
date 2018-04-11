package cgs.server.logging.actions;
import Std;
import haxe.Json;

/**
 * Action performed by the user to be sent to the server to be logged.
 */
class QuestAction implements IClientAction
{
    public var detailObject(get, never) : Dynamic;
    public var actionObject(get, never) : Dynamic;
    public var actionId(get, never) : Int;
    public var sequenceId(get, never) : Int;
    public var startTimestamp(get, never) : Int;
    public var endTimestamp(get, never) : Int;
    public var logId(get, never) : String;
    public var sessionSequenceId(get, never) : Int;
    public var questActionSequenceId(get, never) : Int;

    public static var MULTIPLAYER_UID_KEY : String = "multi_uid";
    public static var MULTIPLAYER_SEQUENCEID_KEY : String = "multi_seqid";
    
    private var _isBufferable : Bool = true;
    
    // 64-int unique (w.r.t. a single game) id for this action.
    private var _logid : String;
    
    private var _aid : Int;
    
    //Starting time stamp for the event.
    private var _startTick : Int;
    private var _endTick : Int;
    
    private var _statusID : Int;
    
    private var _detailObject : Dynamic;
    
    //Object used to send action properties to the server.
    private var _actionObject : Dynamic;
    
    private var _sequenceId : Int;
    private var _sessionSeqId : Int;
    
    private var _multiUid : String;
    private var _multiSeqId : String;
    
    /**
     * Create a new client action to be logged on the server.
     *
     * @param actionID the id of the action as defined by the application.
     * @param startTimeStamp the starting time of the action.
     * @param endTimeStamp the ending time of the action.
     * @param statusID optional id to be included with the action.
     */
    public function new(
            actionID : Int = 0, startTimeStamp : Float = 0, endTimeStamp : Float = 0)
    {
        _aid = actionID;
        
        _startTick = Std.int(startTimeStamp);
        _endTick = Std.int(endTimeStamp);
        
        //_statusID = statusID;
        
        _actionObject = { };
        
        //Add the required properties.
        setActionID(actionID);
        setStartTimeStamp(Std.int(startTimeStamp));
        setEndTimeStamp(Std.int(endTimeStamp));
    }
    
    /**
     * Add a property to the action which will be sent to the server.
     */
    public function addProperty(key : String, value : Dynamic) : Void
    {
        Reflect.setField(_actionObject, key, value);
    }
    
    /**
     * Add a property to the details field of the action message.
     */
    public function addDetailProperty(key : String, value : Dynamic) : Void
    {
        if (_detailObject == null)
        {
            _detailObject = { };
            addProperty("detail", _detailObject);
        }
        
        Reflect.setField(_detailObject, key, value);
    }
    
    private function get_detailObject() : Dynamic
    {
        return _detailObject;
    }
    
    /**
     * Indicates if this action is bufferable, this is true by default.
     * Can be changed by calling setBufferable.
     */
    public function isBufferable() : Bool
    {
        return _isBufferable;
    }
    
    public function setBufferable(value : Bool) : Void
    {
        _isBufferable = value;
    }
    
    /**
     * Set the detail properties for the action. Only dynamic properties of
     * the passed object will be added to the detail field of the message.
     *
     * @param value instance of the Object class which has detail properties to be logged.
     */
    public function setDetail(value : Dynamic) : Void
    {
        if (value != null)
        {
            for (key in Reflect.fields(value))
            {
                addDetailProperty(key, Reflect.field(value, key));
            }
        }
    }
    
    public function setMultiplayerUid(uid : String) : Void
    {
        addProperty(MULTIPLAYER_UID_KEY, uid);
    }
    
    public function setMultiplayerSequenceId(id : Int) : Void
    {
        addProperty(MULTIPLAYER_SEQUENCEID_KEY, id);
    }
    
    /**
     * Set the action id for this action.
     */
    public function setActionID(value : Int) : Void
    {
        addProperty("aid", value);
    }
    
    /**
     * Set the starting time stamp for this action.
     */
    public function setStartTimeStamp(value : Int) : Void
    {
        addProperty("ts", value);
    }
    
    /**
     * Set the ending time stamp for this action. This paramter is optional.
     */
    public function setEndTimeStamp(value : Int) : Void
    {
        addProperty("te", value);
    }
    
    /**
     * Set the status id for this action. This paramter is optional.
     */
    public function setStatusID(value : Int) : Void
    {
        addProperty("stid", value);
    }
    
    /**
     * @inheritDoc
     */
    private function get_actionObject() : Dynamic
    {
        return _actionObject;
    }
    
    private function get_actionId() : Int
    {
        return _aid;
    }
    
    private function get_sequenceId() : Int
    {
        return _sequenceId;
    }
    
    private function get_startTimestamp() : Int
    {
        return _startTick;
    }
    
    private function get_endTimestamp() : Int
    {
        return _endTick;
    }
    
    private function get_logId() : String
    {
        return _logid;
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
        return _sequenceId;
    }
    
    //
    // Data parsing.
    //
    
    public function parseJsonData(data : Dynamic) : Void
    {
        //Data params: a_detail, aid, cid, dqid, gid, lid, log_id, log_ts, qid, sid, stid, te, tid, ts, uid, vid
        _aid = data.aid;
        
        var rawData : Dynamic = data.a_detail;
        if (rawData != null)
        {
            if (Std.is(rawData, String))
            {
                var stringData : String = rawData;
                if (stringData.charAt(0) == "{" || stringData.charAt(0) == "[")
                {
                    _detailObject = Json.parse(stringData);
                }
                else
                {
                    _detailObject = stringData;
                }
            }
            else
            {
                _detailObject = data.a_detail;
            }
        }
        
        _startTick = data.ts;
        _endTick = data.te;
        _logid = data.log_id;
        
        if (Reflect.hasField(data, "qaction_seqid"))
        {
            _sequenceId = data.qaction_seqid;
        }
        if (Reflect.hasField(data, "session_seqid"))
        {
            _sessionSeqId = data.session_seqid;
        }
    }
}
