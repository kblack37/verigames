package cgs.homeplays.data;


class ClassroomData
{
    public var isClassroom(get, never) : Bool;
    public var students(get, set) : Array<Dynamic>;
    public var name(get, set) : String;
    public var startGrade(get, set) : String;
    public var endGrade(get, set) : String;

    public static var GRADE_LEVEL_STRINGS : Array<Dynamic> = ["Prekindergarten", "Kindergarten", 
        "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th", "Higher Education"
    ];
    
    public static inline var GENERIC_GROUP : Int = 0;
    public static inline var CLASSROOM : Int = 1;
    
    //Students in the classroom.
    private var _students : Array<Dynamic>;
    
    //Name of the classroom as defined by the teacher.
    private var _name : String;
    
    //Starting and ending grade for the classroom.
    private var _startGrade : String;
    private var _endGrade : String;
    
    //Indicates the type of group.
    private var _typeId : Int;
    
    public function new()
    {
        _students = [];
    }
    
    private function get_isClassroom() : Bool
    {
        return _typeId == CLASSROOM;
    }
    
    public function containsStudent(student : StudentData) : Bool
    {
        return Lambda.indexOf(_students, student) >= 0;
    }
    
    private function get_students() : Array<Dynamic>
    {
        return _students.copy();
    }
    
    private function set_students(value : Array<Dynamic>) : Array<Dynamic>
    {
        _students = value;
        return value;
    }
    
    private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }
    
    private function get_name() : String
    {
        return _name;
    }
    
    private function set_startGrade(value : String) : String
    {
        _startGrade = value;
        return value;
    }
    
    private function get_startGrade() : String
    {
        return _startGrade;
    }
    
    private function set_endGrade(value : String) : String
    {
        _endGrade = value;
        return value;
    }
    
    private function get_endGrade() : String
    {
        return _endGrade;
    }
    
    public function addStudent(data : StudentData) : Void
    {
        _students.push(data);
    }
    
    public function removeStudent(data : StudentData) : Void
    {
        var removeIdx : Int = Lambda.indexOf(_students, data);
        if (removeIdx >= 0)
        {
            _students.splice(removeIdx, 1);
        }
    }
    
    public function parseJsonData(data : Dynamic) : Void
    {
        _startGrade = data.start_grade;
        _endGrade = data.end_grade;
    }
    
    public function createJsonData() : Dynamic
    {
        return {
            group_name : _name,
            start_level : _startGrade,
            end_level : _endGrade
        };
    }
}
