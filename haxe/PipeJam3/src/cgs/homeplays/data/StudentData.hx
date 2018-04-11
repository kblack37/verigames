package cgs.homeplays.data;

import cgs.server.data.UserData;

/**
	 * Student data as defined by teacher.
	 */
class StudentData extends UserData
{
    public var gradeLevel(get, set) : String;
    public var active(get, set) : Bool;

    private var _gradeLevel : String;
    
    private var _activeStudent : Bool;
    
    public function new()
    {
        super();
        
        _activeStudent = true;
    }
    
    private function set_gradeLevel(value : String) : String
    {
        _gradeLevel = value;
        return value;
    }
    
    private function get_gradeLevel() : String
    {
        return _gradeLevel;
    }
    
    private function set_active(value : Bool) : Bool
    {
        _activeStudent = value;
        return value;
    }
    
    private function get_active() : Bool
    {
        return _activeStudent;
    }
    
    override public function parseJsonData(data : Dynamic) : Void
    {
        super.parseJsonData(data);
        
        _activeStudent = data.active;
        _gradeLevel = data.grade_level;
    }
    
    override public function createJsonData() : Dynamic
    {
        var data : Dynamic = super.createJsonData();
        
        data.active = _activeStudent;
        data.grade_level = _gradeLevel;
        
        return data;
    }
}
