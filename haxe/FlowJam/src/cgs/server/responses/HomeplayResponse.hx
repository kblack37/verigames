package cgs.server.responses;

import cgs.homeplays.data.HomeplayData;
import cgs.homeplays.data.UserAssignment;
import cgs.homeplays.data.UserHomeplaysData;

class HomeplayResponse extends CgsResponseStatus
{
    public var homeplays(get, never) : UserHomeplaysData;

    private var _homesplays : UserHomeplaysData;
    
    public function new()
    {
        super();
    }
    
    private function get_homeplays() : UserHomeplaysData
    {
        return _homesplays;
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        //Parse the homeplays data.
        if (success)
        {
            //TODO - Parse the homeplays data.
            _homesplays = new UserHomeplaysData();
            
            var tempAssignment : HomeplayData;
            var tempUserAssignment : UserAssignment;
            var assignments : Array<Dynamic> = _data.r_data;
            var components:Array<Dynamic>;
			var results:Array<Dynamic>;
			
            var currTime : Float = Date.now().getTime() / 1000;
            
            for (assignment in assignments)
            {
                tempAssignment = new HomeplayData();
                tempAssignment.id = assignment.assignment_instance_id;
                tempAssignment.name = assignment.name;
                
				components = assignment.components;
				
                for (component in components)
                {
                    var _sw0_ = (component.type);                    

                    switch (_sw0_)
                    {
                        case 1:  //level  
                        tempAssignment.addQuestId(component.component_id);
                        case 2:  //concept  
                        tempAssignment.addConceptKey(component.component_id);
                        case 4:  //level count  
                        tempAssignment.levelCount = component.component_id;
                    }
                }
                
                
                tempUserAssignment = new UserAssignment();
                tempUserAssignment.homeplayData = tempAssignment;
                tempUserAssignment.replayAllowed = (assignment.allow_replay == 1);
                tempUserAssignment.name = tempAssignment.name;
                tempUserAssignment.startDate = assignment.start_date;
                tempUserAssignment.dueDate = assignment.due_date;
                
				results = assignment.results;
				
                for (result in results)
                {
                    tempUserAssignment.questCompleted(result.dynamic_quest_id);
                }
                
                _homesplays.addAssignment(tempUserAssignment);
            }
        }
    }
}
