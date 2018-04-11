package cgs.homeplays.data;

import cgs.server.data.UserData;

/**
	 * Contains all of the relevant homeplay data for a user.
	 */
class UserHomeplaysData
{
    public var activeAssignmentCount(get, never) : Int;
    public var activeAssignments(get, never) : Array<UserAssignment>;

    //All assignments for the user.
    private var _assignments : Array<UserAssignment>;
    
    public function new()
    {
        _assignments = new Array<UserAssignment>();
    }
    
    private function get_activeAssignmentCount() : Int
    {
        return _assignments.length;
    }
    
    public function getActiveAssignmentAt(idx : Int) : UserAssignment
    {
        return _assignments[idx];
    }
    
    public function getAssignmentById(assignmentId : String) : UserAssignment
    {
        var bFound : Bool = false;
        var i : Int = 0;
        var returnAssignment : UserAssignment = null;
        
        while (i < _assignments.length && !bFound)
        {
            if (_assignments[i].homeplayData.id == assignmentId)
            {
                bFound = true;
            }
            else
            {
                i++;
            }
        }
        
        if (bFound)
        {
            returnAssignment = _assignments[i];
        }
        
        return returnAssignment;
    }
    
    public function assignmentQuestCompleted(assignmentId : String, dqid : String) : Void
    {
        var assignment : UserAssignment = getAssignmentById(assignmentId);
        if (assignment != null)
        {
            assignment.questCompleted(dqid);
        }
    }
    
    public function addAssignment(assignment : UserAssignment) : Void
    {
        _assignments.push(assignment);
    }
    
    private function get_activeAssignments() : Array<UserAssignment>
    {
        return _assignments.copy();
    }
}
