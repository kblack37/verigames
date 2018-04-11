package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.utils.INtpTime;

class QuestMessage extends BaseQuestMessage implements IQuestMessage
{
    public var foreignQuest(never, set) : Bool;
    public var isDQIDValid(get, never) : Bool;
    public var qid(get, never) : String;
    public var q_detail(get, never) : Dynamic;

    private var _start : Bool;
    
    //Details logged at the start of a quest.
    private var _questDetail : Dynamic;
    
    public function new(
            questID : Int, details : Dynamic, questStart : Bool,
            aeSeqID : String = null, dqid : String = null,
            serverData : IGameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        
        if (serverTime == null)
        {
        }
        
        setQuestId(questID);
        
        _questDetail = details;
        addProperty("q_detail", _questDetail);
        
        _start = questStart;
        addProperty("q_s_id", (questStart) ? 1 : 0);
        
        //Only add the ae sequence id if it is valid.
        if (aeSeqID != null)
        {
            addProperty("ae_seq_id", aeSeqID);
        }
        if (dqid != null)
        {
            setDqid(dqid);
        }
        
        _requireSessionId = true;
    }
    
    override private function get_isStart() : Bool
    {
        return _start;
    }
    
    private function set_foreignQuest(value : Bool) : Bool
    {
        if (value)
        {
            addProperty("q_s_id", 2);
        }
        return value;
    }
    
    private function get_isDQIDValid() : Bool
    {
        return dqid != null;
    }
    
    private function get_qid() : String
    {
        return _questId;
    }
    
    private function get_q_detail() : Dynamic
    {
        return _questDetail;
    }
    
    override public function injectParams() : Void
    {
        super.injectParams();
        
        injectLevelID(true);
        injectTypeID(true);
        injectSessionID(false);
        injectConditionId();
    }
}
