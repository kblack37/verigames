package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.dependencies.IRequestDependency;
import cgs.server.logging.messages.IQuestMessage;
import cgs.server.logging.messages.Message;

class QuestRequest extends CallbackRequest
{
    public var dependencies(get, never) : Array<IRequestDependency>;
    public var apiMethod(get, never) : String;
    public var isStart(get, never) : Bool;
    public var requestCallback(get, never) : Function;
    public var dqid(get, never) : String;
    public var questMessage(get, never) : IQuestMessage;
    public var message(get, never) : Message;
    public var questMessageObject(get, never) : Dynamic;

    private static var QUEST_START : String = CGSServerConstants.QUEST_START;
    
    private var _apiMethod : String;
    
    private var _questMessage : IQuestMessage;
    
    private var _questGameID : Int = 0;
    
    //Function which should be called when the request can be sent to the server.
    private var _requestCallback : Function;
    
    public function new(
            callback : Function, questMessage : IQuestMessage,
            requestCallback : Function, questGameID : Int = 0, apiMethod : String = CGSServerConstants.QUEST_START)
    {
        super(callback, null);
        
        _questMessage = questMessage;
        _requestCallback = requestCallback;
        _questGameID = questGameID;
        _apiMethod = apiMethod;
    }
    
    private function get_dependencies() : Array<IRequestDependency>
    {
        return (_questMessage != null) ? 
        _questMessage.dependencies : new Array<IRequestDependency>();
    }
    
    private function get_apiMethod() : String
    {
        return _apiMethod;
    }
    
    private function get_isStart() : Bool
    {
        return (_questMessage != null) ? _questMessage.isStart : false;
    }
    
    private function get_requestCallback() : Function
    {
        return _requestCallback;
    }
    
    public function setDqid(value : String) : Void
    {
        if (_questMessage != null)
        {
            _questMessage.setDqid(value);
        }
    }
    
    public function getDQID() : String
    {
        return (_questMessage != null) ? _questMessage.dqid : null;
    }
    
    private function get_dqid() : String
    {
        return getDQID();
    }
    
    private function get_questMessage() : IQuestMessage
    {
        return _questMessage;
    }
    
    private function get_message() : Message
    {
        addParams();
        return try cast(_questMessage, Message) catch(e:Dynamic) null;
    }
    
    private function get_questMessageObject() : Dynamic
    {
        addParams();
        return _questMessage.messageObject;
    }
    
    private function addParams() : Void
    {
        _questMessage.injectParams();
        if (_questGameID > 0)
        {
            _questMessage.addProperty("g_s_id", _questGameID);
        }
    }
}
