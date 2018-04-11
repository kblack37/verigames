package cgs.server.requests;

import haxe.Constraints.Function;
import cgs.server.logging.messages.IQuestMessage;
import cgs.server.logging.requests.QuestRequest;

class HomeplayQuestRequest extends QuestRequest
{
    public var hasHomeplayDetails(get, never) : Bool;
    public var homeplayDetails(get, never) : Dynamic;
    public var homeplayCompleted(get, set) : Bool;
    public var homeplayId(get, never) : String;

    private var _homeplayId : String;
    
    //Indicates if the homeplay was completed.
    private var _completed : Bool;
    
    //Details for the homeplay quest.
    private var _details : Dynamic;
    
    public function new(callback : Function, questMessage : IQuestMessage, requestCallback : Function, homeplayId : String, details : Dynamic = null, questGameID : Int = 0)
    {
        super(callback, questMessage, requestCallback, questGameID);
        
        _homeplayId = homeplayId;
        _details = details;
    }
    
    private function get_hasHomeplayDetails() : Bool
    {
        return _details != null;
    }
    
    private function get_homeplayDetails() : Dynamic
    {
        return _details;
    }
    
    private function set_homeplayCompleted(value : Bool) : Bool
    {
        _completed = value;
        return value;
    }
    
    private function get_homeplayCompleted() : Bool
    {
        return _completed;
    }
    
    private function get_homeplayId() : String
    {
        return _homeplayId;
    }
}
