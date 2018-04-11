package cgs.server.data;


/**
	 * Contains authentication data returned from the server when
	 * a user logs in.
	 */
class UserAuthData
{
    public var userData(get, set) : UserData;
    public var uid(get, never) : String;
    public var externalId(get, never) : String;
    public var externalSourceId(get, never) : Int;
    public var groupId(get, never) : Int;

    private var _uid : String;
    
    private var _externalId : String;
    
    //Required to request data from the server.
    private var _sessionId : String;
    
    private var _memId : Int;
    
    private var _roleId : Int;
    
    private var _email : String;
    
    private var _extSourceId : Int;
    
    private var _groupId : Int;
    
    private var _userData : UserData;
    
    public function new()
    {
    }
    
    private function set_userData(data : UserData) : UserData
    {
        _userData = data;
        return data;
    }
    
    /**
		 * Get the user data that is associated to the auth data.
		 */
    private function get_userData() : UserData
    {
        return _userData;
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    private function get_externalId() : String
    {
        return _externalId;
    }
    
    private function get_externalSourceId() : Int
    {
        return _extSourceId;
    }
    
    private function get_groupId() : Int
    {
        return _groupId;
    }
    
    public function parseJsonData(data : Dynamic) : Void
    {
        if (Reflect.hasField(data, "mem_id"))
        {
            _memId = data.mem_id;
        }
        if (Reflect.hasField(data, "uid"))
        {
            _uid = data.uid;
        }
        else
        {
            if (Reflect.hasField(data, "member_uid"))
            {
                _uid = data.member_uid;
            }
        }
        if (Reflect.hasField(data, "ext_id"))
        {
            _externalId = data.ext_id;
        }
        if (Reflect.hasField(data, "role_id"))
        {
            _roleId = data.role_id;
        }
        if (Reflect.hasField(data, "mem_email"))
        {
            _email = data.mem_email;
        }
        if (Reflect.hasField(data, "group_id"))
        {
            _groupId = data.group_id;
        }
        if (Reflect.hasField(data, "ext_s_id"))
        {
            _extSourceId = data.ext_s_id;
        }
    }
}
