package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.utils.INtpTime;

class BaseQuestMessage extends Message implements IQuestMessage
{
    public var dqid(get, never) : String;
    public var isStart(get, never) : Bool;
    public var dependencies(get, never) : Array<IRequestDependency>;

    private var _questId : String;
    
    private var _dqid : String;
    
    //Dependencies for the request.
    private var _dependencies : Array<IRequestDependency>;
    
    public function new(
            serverData : IGameServerData = null, time : INtpTime = null)
    {
        super(serverData, time);
        
        _dependencies = new Array<IRequestDependency>();
    }
    
    public function setQuestId(value : Int) : Void
    {
        _questId = "" + value;
        addProperty("qid", _questId);
    }
    
    public function getQuestId() : Int
    {
        return _messageObject.qid;
    }
    
    public function setDqid(value : String) : Void
    {
        _dqid = value;
        addProperty("dqid", dqid);
    }
    
    private function get_dqid() : String
    {
        return _dqid;
    }
    
    private function get_isStart() : Bool
    {
        return false;
    }
    
    //
    // Dependency handling.
    //
    
    public function addDependency(depen : IRequestDependency) : Void
    {
        _dependencies.push(depen);
    }
    
    private function get_dependencies() : Array<IRequestDependency>
    {
        return _dependencies.copy();
    }
}
