package cgs.edmodo.data;


class EdmodoUserGroupData
{
    public var groupID(get, set) : Int;
    public var isOwner(get, set) : Bool;

    private var _groupID : Int;
    private var _isOwner : Bool;
    
    public function new()
    {
    }
    
    private function get_groupID() : Int
    {
        return _groupID;
    }
    
    private function set_groupID(value : Int) : Int
    {
        _groupID = value;
        return value;
    }
    
    private function get_isOwner() : Bool
    {
        return _isOwner;
    }
    
    private function set_isOwner(value : Bool) : Bool
    {
        _isOwner = value;
        return value;
    }
    
    public function parseJsonData(data : Dynamic) : Void
    {
        _groupID = data.group_id;
        _isOwner = data.is_owner == 1;
    }
}
