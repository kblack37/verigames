package cgs.homeplays.data;

import cgs.server.data.UserData;

class TeacherData extends UserData
{
    public var students(get, never) : Array<Dynamic>;
    public var classrooms(get, never) : Array<Dynamic>;
    public var assignments(get, never) : Array<Dynamic>;
    public var homeplays(get, never) : Array<Dynamic>;

    //Students that have been defined by the teacher.
    private var _students : Array<Dynamic>;
    
    //Array of classroom data.
    private var _classrooms : Array<Dynamic>;
    
    //Array of assignments which have been assigned to users.
    private var _assignments : Array<Dynamic>;
    
    //Array of homeplays which have been created by the user.
    private var _homeplays : Array<Dynamic>;
    
    public function new()
    {
        super();
        
        _students = [];
        _classrooms = [];
        _assignments = [];
        _homeplays = [];
    }
    
    /**
		 * Test if there is a student with duplicate first and last name as the given
		 * student.
		 */
    public function testDuplicateStudent(testStudent : StudentData) : Bool
    {
        for (student in _students)
        {
            if (student.testDuplicateName(testStudent))
            {
                return true;
            }
        }
        
        return false;
    }
    
    /**
		 * Add a student to the teacher.
		 */
    public function addStudent(data : UserData) : Void
    {
        _students.push(data);
    }
    
    private function get_students() : Array<Dynamic>
    {
        return _students;
    }
    
    private function get_classrooms() : Array<Dynamic>
    {
        return _classrooms;
    }
    
    public function addClassroom(classroom : ClassroomData) : Void
    {
        _classrooms.push(classroom);
    }
    
    /**
		 * Remove the given classroom from the teacher.
		 * 
		 * @return true if the classroom was removed.
		 */
    public function removeClassroom(classroom : ClassroomData) : Bool
    {
        var removeIdx : Int = Lambda.indexOf(_classrooms, classroom);
        if (removeIdx >= 0)
        {
            _classrooms.splice(removeIdx, 1);
        }
        
        return removeIdx >= 0;
    }
    
    private function get_assignments() : Array<Dynamic>
    {
        return _assignments;
    }
    
    public function addAssignment(assign : AssignmentData) : Void
    {
        _assignments.push(assign);
    }
    
    private function get_homeplays() : Array<Dynamic>
    {
        return _homeplays;
    }
    
    public function addHomeplay(homeplay : HomeplayData) : Void
    {
        _homeplays.push(homeplay);
    }
    
    override public function parseJsonData(data : Dynamic) : Void
    {
        super.parseJsonData(data);
        
        //TODO - Parse any teacher specific data.
        //if (Reflect.hasField(data, "classrooms"))
        //{
        //}
        //if (Reflect.hasField(data, "assignments"))
        //{
        //}
        //if (Reflect.hasField(data, "homeplays"))
        //{
        //}
    }
    
    public function parseClassroomJsonData(data : Dynamic) : Void
    {
    }
    
    public function parseAssignmentsJsonData(data : Dynamic) : Void
    {
    }
    
    public function parseHomeplaysJsonData(data : Dynamic) : Void
    {
    }
}
