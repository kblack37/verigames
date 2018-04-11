package cgs.server.logging.messages;

import cgs.server.logging.IGameServerData;
import cgs.server.utils.INtpTime;

class ScoreMessage extends BaseQuestMessage implements IQuestMessage
{
    public function new(score : Int,
            serverData : IGameServerData = null, serverTime : INtpTime = null)
    {
        super(serverData, serverTime);
        
        addProperty("score", score);
    }
    
    override private function get_isStart() : Bool
    {
        return false;
    }
    
    //
    // Message property injection.
    //
    
    override public function injectParams() : Void
    {
        super.injectParams();
        
        injectUserName();
    }
}
