package cgs.edmodo.data;


class EdmodoGroupData
{
    public var groupID(get, never) : Int;
    public var title(get, never) : String;
    public var memberCount(get, never) : Int;
    public var owners(get, never) : Array<Dynamic>;
    public var members(get, set) : Array<Dynamic>;
    public var startLevel(get, never) : String;
    public var endLevel(get, never) : String;

    private var _groupID : Int;
    private var _title : String;
    private var _memberCount : Int;
    private var _owners : Array<Dynamic>;
    
    //Contains an array of user tokens for users which belong to group.
    private var _members : Array<Dynamic>;
    
    private var _startLevel : String;
    private var _endLevel : String;
    
    public function new()
    {
        _owners = new Array<Dynamic>();
        _members = new Array<Dynamic>();
    }
    
    private function get_groupID() : Int
    {
        return _groupID;
    }
    
    private function get_title() : String
    {
        return _title;
    }
    
    private function get_memberCount() : Int
    {
        return _memberCount;
    }
    
    private function get_owners() : Array<Dynamic>
    {
        return _owners;
    }
    
    public function isOwner(userToken : String) : Bool
    {
        return Lambda.indexOf(_owners, userToken) >= 0;
    }
    
    private function set_members(value : Array<Dynamic>) : Array<Dynamic>
    {
        _members = value;
        return value;
    }
    
    private function get_members() : Array<Dynamic>
    {
        return (_members != null) ? _members.copy() : _members;
    }
    
    public function addMembers(newMembers : Array<Dynamic>) : Void
    {
        _members = _members.concat(newMembers);
    }
    
    private function get_startLevel() : String
    {
        return _startLevel;
    }
    
    private function get_endLevel() : String
    {
        return _endLevel;
    }
    
    public function parseJsonData(data : Dynamic) : Void
    {
        _groupID = data.group_id;
        _title = data.title;
        _memberCount = data.member_count;
        
        if (Reflect.hasField(data, "owners"))
        {
            for (ownerObj/* AS3HX WARNING could not determine type for var: ownerObj exp: EField(EIdent(data),owners) type: null */ in data.owners)
            {
                _owners.push(ownerObj);
            }
        }
        
        if (Reflect.hasField(data, "start_level"))
        {
            _startLevel = data.start_level;
        }
        if (Reflect.hasField(data, "end_level"))
        {
            _endLevel = data.end_level;
        }
    }
}
