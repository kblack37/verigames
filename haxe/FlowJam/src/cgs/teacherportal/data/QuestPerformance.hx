package cgs.teacherportal.data;

import haxe.Constraints.Function;
import cgs.server.logging.IGameServerData;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.messages.Message;
import cgs.server.logging.quests.QuestLogger;
import cgs.user.CgsUser;

/**
 * Contains data for users performance on a quest.
 */
class QuestPerformance
{
    public var gameServerData(get, never) : IGameServerData;
    public var questLogger(get, never) : QuestLogger;
    public var hasQuestEnded(get, never) : Bool;
    public var won(get, set) : Bool;
    public var activePlaytime(get, set) : Int;
    public var numberMoves(get, set) : Int;
    public var startTime(get, never) : Int;
    public var endTime(get, never) : Int;
    public var performance(get, never) : Array<Dynamic>;
    public var dqid(get, never) : String;
    public var questId(get, never) : Int;
    public var dqidRequestId(get, never) : Int;

    private var _cgsUser : CgsUser;
    
    private var _questLogger : QuestLogger;
    
    private var _conceptPerfValues : Array<Dynamic>;
    
    //Quest details.
    private var _won : Bool;
    private var _numberMoves : Int;
    private var _activePlaytime : Int;
    
    public function new(cgsUser : CgsUser, questLogger : QuestLogger)
    {
        _questLogger = questLogger;
        
        _cgsUser = cgsUser;
        _conceptPerfValues = [];
    }
    
    public function createMessage() : Message
    {
        var server : ICgsServerApi = _cgsUser.server;
        
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
    
    /**
     * Indicates if the user won the quest.
     */
    private function set_won(value : Bool) : Bool
    {
        _won = value;
        return value;
    }
    
    private function get_won() : Bool
    {
        return _won;
    }
    
    private function set_activePlaytime(time : Int) : Int
    {
        _activePlaytime = time;
        return time;
    }
    
    private function get_activePlaytime() : Int
    {
        return _activePlaytime;
    }
    
    private function set_numberMoves(moves : Int) : Int
    {
        _numberMoves = moves;
        return moves;
    }
    
    private function get_numberMoves() : Int
    {
        return _numberMoves;
    }
    
    private function get_startTime() : Int
    {
        var startTimeMs : Float = _questLogger.startTimeMs;
        var time : Float = startTimeMs / 1000;
        return cast(time, Int);
    }
    
    private function get_endTime() : Int
    {
        var endTimeMs : Float = _questLogger.endTimeMs;
        var time : Float = endTimeMs / 1000;
        return cast(time, Int);
    }
    
    public function addConceptPerformance(
            conceptKey : String, performance : Float, confidence : Float) : Void
    {
        _conceptPerfValues.push({
                    key : conceptKey,
                    p : performance,
                    c : confidence
                });
    }
    
    private function get_performance() : Array<Dynamic>
    {
        return _conceptPerfValues;
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
