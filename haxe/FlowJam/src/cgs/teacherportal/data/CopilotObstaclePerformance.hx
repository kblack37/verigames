package cgs.teacherportal.data;

import cgs.server.logging.messages.Message;
import cgs.server.logging.quests.QuestLogger;
import cgs.user.CgsUser;

/**
 * Contains data for individual obstacles during a quest
 */
class CopilotObstaclePerformance extends CopilotPerformance
{
    public var obstacleNumberWithinLevel(get, set) : Int;
    public var won(get, set) : Float;

    
    //details that will change as game progresses
    private var _obstacleNumberWithinLevel : Int;  //***  Card # played (1st, 2nd...) or numberline hit  
    private var _won : Float;  //Should be 1 or 0.  Eventually may be a fractional value to show partial completion.  
    //questLogger takes care of level
    //parent takes care of start and end time
    
    
    /**
		 * Contains data for users performance on an individual obstacle (card played, numberline attempted)
		 */
    public function new(cgsUser : CgsUser, questLogger : QuestLogger)
    {
        super(cgsUser, questLogger);
    }
    
    
    
    private function get_obstacleNumberWithinLevel() : Int
    {
        return _obstacleNumberWithinLevel;
    }
    
    private function set_obstacleNumberWithinLevel(value : Int) : Int
    {
        _obstacleNumberWithinLevel = value;
        return value;
    }
    
    /**
		 * value should be 1 or 0.
		 * A number to allow fraction values in future.
		 * Will not all values outside of 1 or 0.
		 **/
    private function set_won(value : Float) : Float
    {
        if (value > 1)
        {
            value = 1;
        }
        if (value < 0)
        {
            value = 0;
        }
        _won = value;
        return value;
    }
    
    
    private function get_won() : Float
    {
        return _won;
    }
    
    
    /**
		 * Creates message and adds local properties to the message
		 **/
    override public function createMessage() : Message
    {
        var message : Message = super.createMessage();
        
        message.addProperty("won", this.won);
        //TODO:  The obstacle number needs to get set somehow.
        message.addProperty("obstacleNumberWithinLevel", this.obstacleNumberWithinLevel);
        
        return message;
    }
}
