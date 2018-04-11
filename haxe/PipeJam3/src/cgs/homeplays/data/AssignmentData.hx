package cgs.homeplays.data;


class AssignmentData
{
    public var homeplayData(never, set) : HomeplayData;
    public var classroomUserData(get, set) : Array<ClassroomAssignmentData>;
    public var name(get, set) : String;
    public var startDate(get, set) : Float;
    public var isStartDateValid(get, never) : Bool;
    public var isDueDateValid(get, never) : Bool;
    public var dueDate(get, set) : Float;

    //Name of the assignment.
    private var _name : String;
    
    //Contains all of the data for users who are to complete the assignment.
    private var _assignData : Array<ClassroomAssignmentData>;
    
    //Id of the homeplay which defines the quests to be played.
    private var _homeplayId : String;
    private var _homeplay : HomeplayData;
    
    //Starting and ending date for the assignment. Optional parameters.
    private var _startDate : Float;
    private var _dueDate : Float;
    
    //Indicates if the assignment can be replayed.
    private var _replayAllowed : Bool;
    
    public function new()
    {
        _assignData = new Array<ClassroomAssignmentData>();
    }
    
    private function set_homeplayData(data : HomeplayData) : HomeplayData
    {
        _homeplay = data;
        return data;
    }
    
    public function getClassroomAssignmentData(classroom : ClassroomData) : ClassroomAssignmentData
    {
        var classIdx : Int = getClassroomAssignmentIdx(classroom);
        return (classIdx >= 0) ? _assignData[classIdx] : null;
    }
    
    public function getClassroomAssignmentIdx(classroom : ClassroomData) : Int
    {
        var classIdx : Int = -1;
        var currIdx : Int = 0;
        for (classAssign in _assignData)
        {
            if (classAssign.classroom == classroom)
            {
                classIdx = currIdx;
                break;
            }
            currIdx++;
        }
        
        return classIdx;
    }
    
    public function containsClassroom(classroom : ClassroomData) : Bool
    {
        return getClassroomAssignmentIdx(classroom) >= 0;
    }
    
    private function set_classroomUserData(data : Array<ClassroomAssignmentData>) : Array<ClassroomAssignmentData>
    {
        _assignData = data;
        return data;
    }
    
    private function get_classroomUserData() : Array<ClassroomAssignmentData>
    {
        return _assignData;
    }
    
    public function removeClassroomAssignment(classroom : ClassroomData) : Void
    {
        var removeIdx : Int = getClassroomAssignmentIdx(classroom);
        if (removeIdx >= 0)
        {
            _assignData.splice(removeIdx, 1);
        }
    }
    
    public function updateClassroomStudents(classroom : ClassroomData, students : Array<Dynamic>) : Void
    {
        var classAssign : ClassroomAssignmentData = getClassroomAssignmentData(classroom);
        if (classAssign == null)
        {
            classAssign = new ClassroomAssignmentData();
            classAssign.classroom = classroom;
            _assignData.push(classAssign);
        }
        
        classAssign.students = students;
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
    
    private function set_startDate(value : Float) : Float
    {
        _startDate = value;
        return value;
    }
    
    private function get_startDate() : Float
    {
        return _startDate;
    }
    
    private function get_isStartDateValid() : Bool
    {
        return Math.isNaN(_startDate) && _startDate >= 0;
    }
    
    private function get_isDueDateValid() : Bool
    {
        return Math.isNaN(_dueDate) && _dueDate >= 0;
    }
    
    private function set_dueDate(value : Float) : Float
    {
        _dueDate = value;
        return value;
    }
    
    private function get_dueDate() : Float
    {
        return _dueDate;
    }
}
