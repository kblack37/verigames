package cgs.server.data;


class GroupData
{
    public var id(get, set) : Int;
    public var userUids(get, set) : Array<Dynamic>;

    //Id for the group.
    private var _id : Int;
    
    //Uids for all users that belong to the group.
    private var _userUids : Array<Dynamic>;
    
    public function new()
    {
        _userUids = [];
    }
    
    private function set_id(value : Int) : Int
    {
        _id = value;
        return value;
    }
    
    private function get_id() : Int
    {
        return _id;
    }
    
    public function addUserUid(uid : String) : Void
    {
        var uidIndex : Int = Lambda.indexOf(_userUids, uid);
        if (uidIndex < 0)
        {
            _userUids.push(uid);
        }
    }
    
    private function set_userUids(value : Array<Dynamic>) : Array<Dynamic>
    {
        _userUids = value.copy();
        return value;
    }
    
    private function get_userUids() : Array<Dynamic>
    {
        return _userUids.copy();
    }
}
