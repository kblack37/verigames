package cgs.homeplays.data;


class HomeplayData
{
    public var id(get, set) : String;
    public var levelCount(get, set) : Int;
    public var name(get, set) : String;
    public var questIds(get, set) : Array<Int>;
    public var conceptKeys(get, set) : Array<String>;
    public var requiredQuestCount(get, never) : Int;
    public var questCount(get, never) : Int;

    private var _name : String;
    
    //Set by the server.
    private var _id : String;
    
    private var _questIds : Array<Int>;
    
    private var _conceptKeys : Array<String>;
    
    private var _levelCount : Int;
    
    //TODO - Have a sequence that defines how levels are to be played?
    
    public function new()
    {
        _questIds = new Array<Int>();
        _conceptKeys = new Array<String>();
        _levelCount = 0;
    }
    
    private function get_id() : String
    {
        return _id;
    }
    
    private function set_id(value : String) : String
    {
        _id = value;
        return value;
    }
    
    private function get_levelCount() : Int
    {
        return _levelCount;
    }
    
    private function set_levelCount(value : Int) : Int
    {
        _levelCount = value;
        return value;
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
    
    public function addQuestId(id : Int) : Void
    {
        _questIds.push(id);
    }
    
    private function set_questIds(ids : Array<Int>) : Array<Int>
    {
        _questIds = ids;
        return ids;
    }
    
    private function get_questIds() : Array<Int>
    {
        return _questIds.copy();
    }
    
    public function addConceptKey(key : String) : Void
    {
        _conceptKeys.push(key);
    }
    
    private function set_conceptKeys(keys : Array<String>) : Array<String>
    {
        _conceptKeys = keys;
        return keys;
    }
    
    private function get_conceptKeys() : Array<String>
    {
        return _conceptKeys.copy();
    }
    
    private function get_requiredQuestCount() : Int
    {
        var returnInt : Int;
        
        if (_levelCount > 0)
        {
            returnInt = _levelCount;
        }
        else
        {
            returnInt = _questIds.length;
        }
        
        return returnInt;
    }
    
    private function get_questCount() : Int
    {
        return _questIds.length;
    }
}
