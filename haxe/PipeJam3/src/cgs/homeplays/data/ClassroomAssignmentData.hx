package cgs.homeplays.data;


/**
	 * Contains the users within a classroom that are to be assigned to an assignment.
	 */
class ClassroomAssignmentData
{
    public var classroom(get, set) : ClassroomData;
    public var students(get, set) : Array<Dynamic>;
    public var unassignedStudents(get, never) : Array<Dynamic>;

    //Indicates if assignment was assigned to the entire class.
    private var _classroomAssignment : Bool;
    
    //Reference to the classroom.
    private var _classroom : ClassroomData;
    
    //Subset of users within class that have been assigned to assignment.
    private var _students : Array<Dynamic>;
    
    public function new()
    {
        _students = [];
    }
    
    public function containsStudent(student : StudentData) : Bool
    {
        return Lambda.indexOf(_students, student) >= 0;
    }
    
    /**
		 * Adds all of the students in the classroom to the assignment.
		 */
    public function addAllStudents() : Void
    {
        _students = _classroom.students;
        _classroomAssignment = true;
    }
    
    public function addStudents(students : Array<Dynamic>) : Void
    {
        for (studentData in students)
        {
            addStudent(studentData);
        }
    }
    
    public function addStudent(studentData : StudentData) : Void
    {
        if (!containsStudent(studentData))
        {
            _students.push(studentData);
        }
    }
    
    private function set_classroom(value : ClassroomData) : ClassroomData
    {
        _classroom = value;
        return value;
    }
    
    private function get_classroom() : ClassroomData
    {
        return _classroom;
    }
    
    private function set_students(value : Array<Dynamic>) : Array<Dynamic>
    {
        _students = value.copy();
        return value;
    }
    
    private function get_students() : Array<Dynamic>
    {
        return _students.copy();
    }
    
    /**
		 * Get the students in the classroom which have not been assigned.
		 */
    private function get_unassignedStudents() : Array<Dynamic>
    {
        var unassignStudents : Array<Dynamic> = [];
        var studentIdx : Int;
        for (student/* AS3HX WARNING could not determine type for var: student exp: EField(EIdent(_classroom),students) type: null */ in _classroom.students)
        {
            studentIdx = Lambda.indexOf(_students, student);
            if (studentIdx < 0)
            {
                unassignStudents.push(student);
            }
        }
        
        return unassignStudents;
    }
}
