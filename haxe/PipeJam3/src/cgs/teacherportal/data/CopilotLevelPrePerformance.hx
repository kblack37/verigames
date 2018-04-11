package cgs.teacherportal.data;

import cgs.server.logging.messages.Message;
import cgs.server.logging.quests.QuestLogger;
import cgs.user.CgsUser;

/**
 * Contains data for individual obstacles during a quest
 */
class CopilotLevelPrePerformance extends CopilotPerformance
{
    public var obstaclesInLevel(get, set) : Int;

    
    private var _obstaclesInLevel : Int;  //Number of cards to play or number of number lines to attempt  
    //questLogger takes care of level
    //parent takes care of start and end time
    
    
    /**
		 * Contains data for level performance
		 */
    public function new(cgsUser : CgsUser, questLogger : QuestLogger)
    {
        super(cgsUser, questLogger);
    }
    
    private function get_obstaclesInLevel() : Int
    {
        return _obstaclesInLevel;
    }
    
    private function set_obstaclesInLevel(value : Int) : Int
    {
        _obstaclesInLevel = value;
        return value;
    }
    
    
    /**
		 * Creates message and adds local properties to the message
		 **/
    override public function createMessage() : Message
    {
        var message : Message = super.createMessage();
        
        message.addProperty("_obstaclesInLevel", this.obstaclesInLevel);
        
        return message;
    }
}
