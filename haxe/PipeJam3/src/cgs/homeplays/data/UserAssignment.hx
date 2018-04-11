package cgs.homeplays.data;


/**
	 * Data for an single assignment relative to a specific user.
	 */
class UserAssignment
{
    public var label(get, never) : String;
    public var name(get, set) : String;
    public var startDate(get, set) : Float;
    public var validDueDate(get, never) : Bool;
    public var dueDate(get, set) : Float;
    public var replayAllowed(get, set) : Bool;
    public var homeplayData(get, set) : HomeplayData;
    public var completedQuestIds(get, never) : Array<Dynamic>;
    public var completedQuestCount(get, never) : Int;
    public var requiredQuestCount(get, never) : Int;
    public var assignmentQuests(get, never) : Array<Int>;
    public var assignmentConcepts(get, never) : Array<String>;

    private var _name : String;
    
    private var _startDate : Float;
    private var _dueDate : Float;
    
    //Indicates if the assignment is active.
    private var _active : Bool;
    
    private var _replayAllowed : Bool;
    
    //Homeplay data which defines the quests to be played as part of the assignment.
    private var _homeplayId : String;
    private var _homeplayData : HomeplayData;
    
    //Contains the quests of the assignment that have been completed by the user.
    private var _completedQuestIds : Array<Dynamic>;
    
    public function new()
    {
        _completedQuestIds = [];
    }
    
    //
    // Assignment updates.
    //
    
    public function questCompleted(questId : String) : Void
    {
        var itemIdx : Int = Lambda.indexOf(_completedQuestIds, questId);
        if (itemIdx < 0)
        {
            _completedQuestIds.push(questId);
        }
    }
    
    //
    // Assignment properties.
    //
    
    private function get_label() : String
    {
        return _name;
    }
    
    private function get_name() : String
    {
        return _name;
    }
    
    private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }
    
    private function get_startDate() : Float
    {
        return _startDate;
    }
    
    private function set_startDate(value : Float) : Float
    {
        _startDate = value;
        return value;
    }
    
    private function get_validDueDate() : Bool
    {
        return !Math.isNaN(_dueDate) && _dueDate >= 0;
    }
    
    private function get_dueDate() : Float
    {
        return _dueDate;
    }
    
    private function set_dueDate(value : Float) : Float
    {
        _dueDate = value;
        return value;
    }
    
    private function set_replayAllowed(value : Bool) : Bool
    {
        _replayAllowed = value;
        return value;
    }
    
    private function get_replayAllowed() : Bool
    {
        return _replayAllowed;
    }
    
    private function get_homeplayData() : HomeplayData
    {
        return _homeplayData;
    }
    
    private function set_homeplayData(value : HomeplayData) : HomeplayData
    {
        _homeplayData = value;
        return value;
    }
    
    private function get_completedQuestIds() : Array<Dynamic>
    {
        return _completedQuestIds.copy();
    }
    
    private function get_completedQuestCount() : Int
    {
        return _completedQuestIds.length;
    }
    
    private function get_requiredQuestCount() : Int
    {
        return _homeplayData.requiredQuestCount;
    }
    
    public function isQuestCompleted(questId : Int) : Bool
    {
        return Lambda.indexOf(_completedQuestIds, questId) >= 0;
    }
    
    private function get_assignmentQuests() : Array<Int>
    {
        return _homeplayData.questIds;
    }
    
    private function get_assignmentConcepts() : Array<String>
    {
        return _homeplayData.conceptKeys;
    }
    
    //
    // Data loading and saving.
    //
    
    public function parseJsonData(data : Dynamic) : Void
    {
    }
}
