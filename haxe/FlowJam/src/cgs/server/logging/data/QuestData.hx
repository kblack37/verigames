package cgs.server.logging.data;

//import haxe.Constraints.Function;
import cgs.server.logging.actions.QuestAction;
//import flash.sampler.NewObjectSample;

/**
 * Contains all data relevant to quests.
 */
class QuestData
{
    public var isSessionIdValid(get, never) : Bool;
    public var sessionId(get, never) : String;
    public var questId(get, never) : Int;
    public var uid(get, never) : String;
    public var versionId(get, never) : Int;
    public var categoryId(get, never) : Int;
    public var dqid(get, never) : String;
    public var gameId(get, never) : Int;
    public var conditionId(get, never) : Int;
    public var startData(get, never) : QuestStartEndData;
    public var endData(get, never) : QuestStartEndData;
    public var actions(get, never) : Array<Dynamic>;

    //Start and end data for the quest.
    private var _startData : QuestStartEndData;
    private var _endData : QuestStartEndData;
    
    //Array of action data.
    private var _actions : Array<QuestAction>;
    
    public function new()
    {
    }
    
    private function get_isSessionIdValid() : Bool
    {
        return (_startData != null) ? _startData.isSessionIdValid : (_endData != null) ? _endData.isSessionIdValid : false;
    }
    
    private function get_sessionId() : String
    {
        return (_startData != null) ? _startData.sessionId : (_endData != null) ? _endData.sessionId : "";
    }
    
    /**
     * Get the id for the quest.
     */
    private function get_questId() : Int
    {
        return (_startData != null) ? _startData.qid : (_endData != null) ? _endData.qid : 0;
    }
    
    private function get_uid() : String
    {
        return (_startData != null) ? _startData.uid : (_endData != null) ? _endData.uid : "";
    }
    
    /**
     * Get the version id for the quest. This assumes that the start and end data have
     * the same version id.
     */
    private function get_versionId() : Int
    {
        return (_startData != null) ? _startData.versionId : (_endData != null) ? _endData.versionId : 0;
    }
    
    /**
     * Get the category id for the quest. This assumes that the quest start and end have
     * the same category id.
     */
    private function get_categoryId() : Int
    {
        return (_startData != null) ? startData.categoryId : (_endData != null) ? _endData.categoryId : 0;
    }
    
    /**
     * Get the dynamic quest id for the quest. This assumes that the start and end data have
     * the same dqid.
     */
    private function get_dqid() : String
    {
        return (_startData != null) ? startData.dqid : (_endData != null) ? _endData.dqid : "";
    }
    
    /**
     * Get the game if for the quest. This assumes that the start and end data have
     * the dame game id.
     */
    private function get_gameId() : Int
    {
        return (_startData != null) ? startData.gameId : (_endData != null) ? _endData.gameId : 0;
    }
    
    private function get_conditionId() : Int
    {
        return (_startData != null) ? startData.conditionId : (_endData != null) ? _endData.conditionId : 0;
    }
    
    private function get_startData() : QuestStartEndData
    {
        return _startData;
    }
    
    private function get_endData() : QuestStartEndData
    {
        return _endData;
    }
    
    /**
     * Get the actions for the quest. These actions will be sorted by sequence id if present
     * or by the starting timestamp for the action.
     *
     * @return an array of ClientAction objects.
     */
    private function get_actions() : Array<Dynamic>
    {
        return _actions;
    }
    
    public function parseQuestData(data : Dynamic) : Void
    {
        if (Std.is(data, Array))
        {
            var questArray : Array<Dynamic> = try cast(data, Array<Dynamic>) catch(e:Dynamic) null;
            if (questArray.length == 0)
            {
                return;
            }
            
            var questData1 : QuestStartEndData = new QuestStartEndData();
            questData1.parseJsonData(questArray[0]);
            
            var questData2 : QuestStartEndData = null;
            if (questArray.length > 1)
            {
                questData2 = new QuestStartEndData();
                questData2.parseJsonData(questArray[1]);
                
                if (questData2.start)
                {
                    _startData = questData2;
                    _endData = questData1;
                }
                else
                {
                    _startData = questData1;
                    _endData = questData2;
                }
            }
            else
            {
                _startData = questData1;
                _endData = null;
            }
        }
    }
    
    public function parseActionsData(data : Dynamic) : Void
    {
        var containsSeqId : Bool = false;
        _actions = new Array<QuestAction>();
        if (Std.is(data, Array))
        {
            var actions : Array<Dynamic> = try cast(data, Array<Dynamic>) catch(e:Dynamic) null;
            var currAction : QuestAction;
            for (action in actions)
            {
                currAction = new QuestAction();
                currAction.parseJsonData(action);
                containsSeqId = (containsSeqId) ? containsSeqId : currAction.sequenceId > 0;
                
                _actions.push(currAction);
            }
        }
        
        //Sort the actions.
        var sortFunction : QuestAction -> QuestAction -> Int = containsSeqId ? sortActionsBySeqId : sortActionsByTs;
        _actions.sort(sortFunction);
    }
    
    private function sortActionsByTs(action : QuestAction, action2 : QuestAction) : Int
    {
	var stamp1:Int = action.startTimestamp;
	var stamp2:Int = action2.startTimestamp;
		
	if (stamp1 < stamp2)
	{
		return -1;
	}
	else if (stamp1 > stamp2)
	{
		return 1;
	}
	return 0;
    }
    
    private function sortActionsBySeqId(action : QuestAction, action2 : QuestAction) : Int
    {
	var seq1:Int = action.sequenceId;
	var seq2:Int = action.sequenceId;
		
	if (seq1 < seq2)
	{
		return -1;
	}
	else if (seq1 > seq2)
	{
		return 1;
	}
	return 0;
        
    }
}
