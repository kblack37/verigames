package cgs.edmodo.data;


import openfl.utils.Dictionary;
class EdmodoUserData
{
    public var uid(get, never) : String;
    public var isStudent(get, never) : Bool;
    public var isTeacher(get, never) : Bool;
    public var isParent(get, never) : Bool;
    public var classmates(get, set) : Array<Dynamic>;
    public var parents(get, set) : Array<Dynamic>;
    public var teachers(get, set) : Array<Dynamic>;
    public var userType(get, never) : String;
    public var userToken(get, never) : String;
    public var firstName(get, never) : String;
    public var lastName(get, never) : String;
    public var avatarURL(get, never) : String;
    public var thumbURL(get, never) : String;
    public var groupCount(get, never) : Int;
    public var groups(get, never) : Array<EdmodoUserGroupData>;
    public var groupIDs(get, never) : Array<Dynamic>;

    public static inline var STUDENT : String = "STUDENT";
    public static inline var TEACHER : String = "TEACHER";
    public static inline var PARENT : String = "PARENT";
    
    private var _cgsUid : String;
    
    private var _userType : String;
    
    private var _userToken : String;
    
    private var _firstName : String;
    
    private var _lastName : String;
    
    private var _avatarURL : String;
    
    private var _thumbURL : String;
    
    //List of classmates for the user.
    private var _classmates : Array<Dynamic>;
    
    //List of parents for the user.
    private var _parents : Array<Dynamic>;
    
    //List of teachers for the user.
    private var _teachers : Array<Dynamic>;
    
    private var _groups : Array<EdmodoUserGroupData>;
    
    //Contains all of the shared groups for the user mapped to other users.
    private var _sharedGroups : Dictionary<String, Dynamic>;
    
    public function new()
    {
        _groups = new Array<EdmodoUserGroupData>();
        _sharedGroups = new Dictionary<String, Dynamic>();
    }
    
    private function get_uid() : String
    {
        return _cgsUid;
    }
    
    private function get_isStudent() : Bool
    {
        return _userType == STUDENT;
    }
    
    private function get_isTeacher() : Bool
    {
        return _userType == TEACHER;
    }
    
    private function get_isParent() : Bool
    {
        return _userType == PARENT;
    }
    
    public function setSharedGroups(userToken : String, shared : Array<Dynamic>) : Void
    {
        _sharedGroups[userToken] = shared;
    }
    
    public function getSharedGroups(userToken : String) : Array<Dynamic>
    {
        return _sharedGroups[userToken];
    }
    
    private function get_classmates() : Array<Dynamic>
    {
        return _classmates.copy();
    }
    
    private function set_classmates(value : Array<Dynamic>) : Array<Dynamic>
    {
        _classmates = value;
        return value;
    }
    
    private function get_parents() : Array<Dynamic>
    {
        return _parents.copy();
    }
    
    private function set_parents(value : Array<Dynamic>) : Array<Dynamic>
    {
        _parents = value;
        return value;
    }
    
    private function get_teachers() : Array<Dynamic>
    {
        return _teachers.copy();
    }
    
    private function set_teachers(value : Array<Dynamic>) : Array<Dynamic>
    {
        _teachers = value;
        return value;
    }
    
    private function get_userType() : String
    {
        return _userType;
    }
    
    private function get_userToken() : String
    {
        return _userToken;
    }
    
    private function get_firstName() : String
    {
        return _firstName;
    }
    
    private function get_lastName() : String
    {
        return _lastName;
    }
    
    private function get_avatarURL() : String
    {
        return _avatarURL;
    }
    
    private function get_thumbURL() : String
    {
        return _thumbURL;
    }
    
    public function hasGroup(id : Int) : Bool
    {
        for (group in _groups)
        {
            if (group.groupID == id)
            {
                return true;
            }
        }
        
        return false;
    }
    
    private function get_groupCount() : Int
    {
        return _groups.length;
    }
    
    private function get_groups() : Array<EdmodoUserGroupData>
    {
        return _groups.copy();
    }
    
    private function get_groupIDs() : Array<Dynamic>
    {
        var groupIDs : Array<Dynamic> = [];
        for (group in _groups)
        {
            groupIDs.push(group.groupID);
        }
        
        return groupIDs;
    }
    
    /**
		 * Add a group for the user.
		 */
    public function addGroup(id : Int, owner : Bool) : Void
    {
        if (!hasGroup(id))
        {
            var group : EdmodoUserGroupData = new EdmodoUserGroupData();
            group.groupID = id;
            group.isOwner = owner;
            _groups.push(group);
        }
    }
    
    /**
		 * Set the data for the user with possible shared connections to the user with the given token.
		 * 
		 * @return an array of shared connections.
		 */
    public function parseJsonUserConnectionData(userToken : String, data : Dynamic) : Array<Dynamic>
    {
        parseJsonData(data);
        
        var shared : Array<Dynamic> = [];
        if (Reflect.hasField(data, "shared_groups"))
        {
            for (groupID/* AS3HX WARNING could not determine type for var: groupID exp: EField(EIdent(data),shared_groups) type: null */ in data.shared_groups)
            {
                shared.push(groupID);
            }
        }
        
        _sharedGroups[userToken] = shared;
        
        return shared;
    }
    
    /**
		 * Set the data for the user from JSON returned from the server.
		 */
    public function parseJsonData(data : Dynamic) : Void
    {
        if (Reflect.hasField(data, "user_type"))
        {
            _userType = data.user_type;
        }
        if (Reflect.hasField(data, "user_token"))
        {
            _userToken = data.user_token;
        }
        if (Reflect.hasField(data, "first_name"))
        {
            _firstName = data.first_name;
        }
        if (Reflect.hasField(data, "last_name"))
        {
            _lastName = data.last_name;
        }
        if (Reflect.hasField(data, "avatar_url"))
        {
            _avatarURL = data.avatar_url;
        }
        if (Reflect.hasField(data, "thumb_url"))
        {
            _thumbURL = data.thumb_url;
        }
        
        if (Reflect.hasField(data, "groups"))
        {
            _groups = new Array<EdmodoUserGroupData>();
            var groupData : EdmodoUserGroupData;
            for (groupDataObj/* AS3HX WARNING could not determine type for var: groupDataObj exp: EField(EIdent(data),groups) type: null */ in data.groups)
            {
                groupData = new EdmodoUserGroupData();
                groupData.parseJsonData(groupDataObj);
                _groups.push(groupData);
            }
        }
    }
    
    public function parseCgsJsonData(data : Dynamic) : Void
    {
        _cgsUid = data.uid;
    }
}
