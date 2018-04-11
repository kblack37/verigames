package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.QuestActionLogContext;
import cgs.server.logging.actions.IClientAction;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.utils.INtpTime;

class BufferedMessage extends BaseQuestMessage implements IQuestMessage
{
    public var sequenceId(never, set) : Int;
    public var currentSequenceId(get, never) : Int;
    public var nextSequenceId(get, never) : Int;
    public var actions(get, never) : Array<Dynamic>;

    //Buffered actions.
    //private var _actions:Array;
    private var _questActions : Array<IClientAction>;
    private var _localTimeStamps : Array<Float>;
    
    //DQID retrieved from the server.
    //private var _dqid:String;
    
    //Unique local id for the level.
    private var _localDQID : Int;
    
    private var _questID : Int;
    
    //Unique sequence id added to each action as they are logged.
    private var _seqId : Int;
    
    public function new(
            serverData : IGameServerData = null, time : INtpTime = null)
    {
        super(serverData, time);
        
        _questActions = new Array<IClientAction>();
        _localTimeStamps = new Array<Float>();
        
        _requireSessionId = true;
    }
    
    override private function get_isStart() : Bool
    {
        return false;
    }
    
    private function set_sequenceId(value : Int) : Int
    {
        _seqId = value;
        return value;
    }
    
    private function get_currentSequenceId() : Int
    {
        return _seqId;
    }
    
    private function get_nextSequenceId() : Int
    {
        return ++_seqId;
    }
    
    //
    // Dqid handling.
    //
    
    public function isDQIDValid() : Bool
    {
        return dqid != null;
    }
    
    public function setLocalDQID(value : Int) : Void
    {
        _localDQID = value;
    }
    
    public function getLocalDQID() : Int
    {
        return _localDQID;
    }
    
    //
    // Timestamp handling.
    //
    
    override public function updateClientTimeStamp() : Void
    {
        var currAction : IClientAction;
        var currTimeStamp : Float;
        for (idx in 0..._questActions.length)
        {
            currAction = _questActions[idx];
            currTimeStamp = _localTimeStamps[idx];
            
            if (currTimeStamp >= 0)
            {
                currAction.addProperty(
                        "client_ts", _serverTime.getOffsetClientTimeStamp(currTimeStamp)
            );
            }
        }
    }
    
    //
    // Action buffer handling.
    //
    
    public function getActionCount() : Int
    {
        return _questActions.length;
    }
    
    public function addAction(action : IClientAction) : Void
    {
        var seqId : Int = nextSequenceId;
        if (_gameServerData.atLeastVersion2)
        {
            action.addProperty("qaction_seqid", seqId);
            
            _requiresTimeStamp = true;
            if (_serverTime != null)
            {
                if (_serverTime.isTimeValid)
                {
                    _localTimeStamps.push(-1);
                    action.addProperty("client_ts", getClientTimestamp());
                }
                else
                {
                    _localTimeStamps.push(_serverTime.clientTimeStamp);
                }
            }
            else
            {
                _localTimeStamps.push(-1);
            }
        }
        if (_gameServerData.isVersion1)
        {
            action.addDetailProperty("qaction_seqid", seqId);
        }
        
        //var actionObj:Object = action.actionObject;
        
        _questActions.push(action);
    }
    
    public function addActionData(action : QuestActionLogContext) : Void
    {
        addAction(action.action);
    }
    
    private function get_actions() : Array<Dynamic>
    {
        var actions : Array<Dynamic> = [];
        for (action in _questActions)
        {
            actions.push(action.actionObject);
        }
        return actions;
    }
    
    //
    // Message object handling.
    //
    
    override public function injectParams() : Void
    {
        super.injectParams();
        
        injectLevelID(true);
        injectTypeID(true);
        //injectSessionID(true);
        
        addProperty("actions", actions);
        addProperty("dqid", dqid);
        addProperty("qid", "" + getQuestId());
    }
}
