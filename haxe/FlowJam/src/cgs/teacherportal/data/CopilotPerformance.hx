package cgs.teacherportal.data;

import haxe.Constraints.Function;
import cgs.server.logging.IGameServerData;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.messages.Message;
import cgs.server.logging.quests.QuestLogger;
import cgs.user.CgsUser;

/**
 * Contains methods needed to pass performance data to server.
	 * 
	 * Ideally this should be abstract but AS3 doesn't do abstract
 */
class CopilotPerformance
{
    public var additionalDetails(get, set) : Array<Dynamic>;
    public var gameServerData(get, never) : IGameServerData;
    public var questLogger(get, never) : QuestLogger;
    public var hasQuestEnded(get, never) : Bool;
    public var startTime(get, never) : Int;
    public var endTime(get, never) : Int;
    public var dqid(get, never) : String;
    public var questId(get, never) : Int;
    public var dqidRequestId(get, never) : Int;

    private var _cgsUser : CgsUser;  //protected because subclasses access in create message  
    
    private var _questLogger : QuestLogger;
    private var _additionalDetails : Array<Dynamic>;
    //details that will change as game progresses
    
    
    /**
		 * Contains data for users performance
		 */
    public function new(cgsUser : CgsUser, questLogger : QuestLogger)
    {
        _questLogger = questLogger;
        
        _cgsUser = cgsUser;
        _additionalDetails = [];
    }
    
    
    private function get_additionalDetails() : Array<Dynamic>
    {
        return _additionalDetails;
    }
    
    private function set_additionalDetails(value : Array<Dynamic>) : Array<Dynamic>
    {
        _additionalDetails = value;
        return value;
    }
    
    
    /**
		 * This should be called by child and then
		 * properties added within the overriden method
		 **/
    public function createMessage() : Message
    {
        var server : ICgsServerApi = _cgsUser.server;
        server.message.addProperty("additionalDetails", this.additionalDetails);
        server.message.addProperty("start_time", this.startTime);
        server.message.addProperty("end_time", this.endTime);
        server.message.addProperty("qid", this.questId);
        return server.message;
    }
    
    private function get_gameServerData() : IGameServerData
    {
        var server : ICgsServerApi = _cgsUser.server;
        return server.getCurrentGameServerData();
    }
    
    private function get_questLogger() : QuestLogger
    {
        return _questLogger;
    }
    
    private function get_hasQuestEnded() : Bool
    {
        return _questLogger.hasEnded;
    }
    
    
    private function get_startTime() : Int
    {
        var startTimeMs : Float = _questLogger.startTimeMs;
        var time : Float = startTimeMs / 1000;
        return as3hx.Compat.parseInt(time);
    }
    
    private function get_endTime() : Int
    {
        var endTimeMs : Float = _questLogger.endTimeMs;
        var time : Float = endTimeMs / 1000;
        return as3hx.Compat.parseInt(time);
    }
    
    public function isDqidValid() : Bool
    {
        return _questLogger.isDqidValid();
    }
    
    private function get_dqid() : String
    {
        return _questLogger.getDqid();
    }
    
    private function get_questId() : Int
    {
        return _questLogger.getQuestId();
    }
    
    private function get_dqidRequestId() : Int
    {
        return _questLogger.getDqidRequestId();
    }
    
    public function addDqidCallback(callback : Function) : Void
    {
        _questLogger.addDqidCallback(callback);
    }
    
    public function addEndedCallback(callback : Function) : Void
    {
        _questLogger.addEndedCallback(callback);
    }
}
