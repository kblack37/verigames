package cgs.server.data;

import flash.system.Capabilities;

class UserData
{
    public var isStudent(get, never) : Bool;
    public var teacherUid(get, never) : String;
    public var uid(get, set) : String;
    public var externalId(get, never) : String;
    public var memberId(get, set) : Int;
    public var name(get, never) : String;
    public var firstName(get, set) : String;
    public var lastName(get, set) : String;
    public var type(get, never) : Int;
    public var typeString(get, never) : String;
    public var groupIds(get, never) : Array<Dynamic>;
    public var loggingType(get, never) : Int;

    public static var NON_CONSENTED_LOGGING : Int = -1;
    public static inline var NORMAL_LOGGING : Int = 0;
    
    public static inline var MEMBER_ID_KEY : String = "mem_id";
    public static inline var ROLE_ID_KEY : String = "role_id";
    public static inline var UID_KEY : String = "uid";
    public static inline var FIRST_NAME_KEY : String = "mem_first_name";
    public static inline var LAST_NAME_KEY : String = "mem_last_name";
    public static inline var EMAIL_KEY : String = "mem_email";
    public static inline var LOGGING_TYPE_KEY : String = "mem_logging_type";
    
    public static inline var TEACHER : Int = 2;
    public static inline var STUDENT : Int = 3;
    public static inline var GROUP_LEAD : Int = 4;
    public static inline var PARENT : Int = 5;
    
    private var _memberId : Int;
    private var _uid : String;
    private var _externalId : String;
    
    //Will be valid if the user has a teacher.
    private var _teacherUid : String;
    
    private var _externalSourceId : Int;
    
    private var _firstName : String = "";
    private var _lastName : String = "";
    
    private var _loggingType : Int;
    
    private var _email : String;
    
    //Type of user. Possible values are: 2 for teacher, 3 for student, 4 for group-lead, 5 for parent
    private var _type : Int;
    
    //Contains the ids of all groups that the user belongs to.
    private var _groupIds : Array<Dynamic>;
    
    public function new()
    {
        _groupIds = [];
    }
    
    private function get_isStudent() : Bool
    {
        return _type == STUDENT;
    }
    
    private function get_teacherUid() : String
    {
        return _teacherUid;
    }
    
    private function set_uid(value : String) : String
    {
        _uid = value;
        return value;
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    private function get_externalId() : String
    {
        return _externalId;
    }
    
    private function set_memberId(value : Int) : Int
    {
        _memberId = value;
        return value;
    }
    
    private function get_memberId() : Int
    {
        return _memberId;
    }
    
    private function get_name() : String
    {
        return _firstName + " " + _lastName;
    }
    
    private function set_firstName(value : String) : String
    {
        _firstName = value;
        return value;
    }
    
    private function get_firstName() : String
    {
        return _firstName;
    }
    
    private function set_lastName(value : String) : String
    {
        _lastName = value;
        return value;
    }
    
    private function get_lastName() : String
    {
        return _lastName;
    }
    
    private function get_type() : Int
    {
        return _type;
    }
    
    private function get_typeString() : String
    {
        return "" + _type;
    }
    
    private function get_groupIds() : Array<Dynamic>
    {
        return _groupIds.copy();
    }
    
    private function get_loggingType() : Int
    {
        return _loggingType;
    }
    
    //
    // Helper functions.
    //
    
    public function testDuplicateName(student : UserData) : Bool
    {
        return compareStrings(student.firstName, _firstName) && compareStrings(student.lastName, _lastName);
    }
    
    private function compareStrings(stringA : String, stringB : String) : Bool
    {
        if (stringA == null && stringB == null)
        {
            return true;
        }
        else
        {
            if (stringA == null || stringB == null)
            {
                return false;
            }
            else
            {
                return stringA.toLowerCase() == stringB.toLowerCase();
            }
        }
    }
    
    //
    // Data parsing.
    //
    
    public function parseGroupData(data : Dynamic) : Void
    {
    }
    
    public function parseJsonData(data : Dynamic) : Void
    {
        if (Reflect.hasField(data, "mem_id"))
        {
            _memberId = data.mem_id;
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
        if (Reflect.hasField(data, "role_id"))
        {
            _type = data.role_id;
        }
        if (Reflect.hasField(data, "ext_id"))
        {
            _externalId = data.ext_id;
        }
        if (Reflect.hasField(data, "ext_s_id"))
        {
            _externalSourceId = data.ext_s_id;
        }
        if (Reflect.hasField(data, "mem_email"))
        {
            _email = data.mem_email;
        }
        if (Reflect.hasField(data, "mem_logging_type"))
        {
            _loggingType = data.mem_logging_type;
        }
        
        if (Reflect.hasField(data, "teacher_uid"))
        {
            _teacherUid = data.teacher_uid;
        }
    }
    
    public function createJsonData() : Dynamic
    {
        var data : Dynamic = { };
        
        return data;
    }
}
