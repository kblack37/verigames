package cgs.teacherportal.data;

import cgs.server.logging.messages.Message;
import cgs.server.logging.quests.QuestLogger;
import cgs.user.CgsUser;

/**
 * Contains data for individual obstacles during a quest
 */
class CopilotLevelPerformance extends CopilotPerformance
{
    public var numberMoves(get, set) : Int;
    public var score(get, set) : Float;
    public var won(get, set) : Float;

    
    //details that will change as game progresses
    //		private var _level:int;  //in questLogger already
    private var _score : Float;  //This is probably a fraction.  Score over Possible score.  
    private var _numberMoves : Int;  //this may have no context at all until dragonbox or refraction //Maybe just parameters on a function call at start.  
    private var _won : Float;  //Level won.  In TF this will always be yes  
    //questLogger takes care of level
    //parent takes care of start and end time
    
    //TODO:  Efficiency
    // perhaps both score and efficiency should record both parts
    // actual_score, ideal_score, ideal_moves, actual_moves
    
    
    /**
		 * Contains data for level performance
		 * NOT YET FINISHED
		 */
    public function new(cgsUser : CgsUser, questLogger : QuestLogger)
    {
        super(cgsUser, questLogger);
        _additionalDetails = [];
    }
    
    private function get_numberMoves() : Int
    {
        return _numberMoves;
    }
    
    private function set_numberMoves(value : Int) : Int
    {
        _numberMoves = value;
        return value;
    }
    
    private function get_score() : Float
    {
        return _score;
    }
    
    private function set_score(value : Float) : Float
    {
        _score = value;
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
        
        message.addProperty("won", (this.won) ? 1 : 0);
        message.addProperty("score", this.score);
        message.addProperty("numberMoves", this.numberMoves);  //efficiency  
        
        return message;
    }
}
