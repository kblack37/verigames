package cgs.server.logging.data;

import openfl.utils.Dictionary;
import cgs.server.logging.actions.GameAction;

/**
 * Contains logging data for a user. May not contain all data for the user.
 */
class UserLoggingData
{
    public var uid(get, never) : String;
    public var validatedSessions(get, never) : Array<UserSessionLoggingData>;
    public var arePageLoadsValid(get, never) : Bool;
    public var areQuestsValid(get, never) : Bool;
    public var areActionsValid(get, never) : Bool;

    private var _uid : String;
    
    private var _pageloadsValid : Bool;
    private var _questsValid : Bool;
    private var _actionsValid : Bool;
    
    //Arrays of logging data.
    private var _pageloads : Array<PageLoadData>;
    private var _quests : Array<QuestData>;
    private var _actions : Array<GameAction>;
    
    //Mapping of logging data to sessions.
    private var _pageloadMap : Dictionary<String, Dynamic>;
    private var _questSessionMap : Dictionary<String, Dynamic>;
    private var _actionsSessionMap : Dictionary<String, Dynamic>;
    
    public function new(uid : String)
    {
        _uid = uid;
        
        _pageloads = new Array<PageLoadData>();
        _quests = new Array<QuestData>();
        _actions = new Array<GameAction>();
        
        _pageloadMap = new Dictionary<String, Dynamic>();
        _questSessionMap = new Dictionary<String, Dynamic>();
        _actionsSessionMap = new Dictionary<String, Dynamic>();
    }
    
    private function get_uid() : String
    {
        return _uid;
    }
    
    //
    // Validation functions.
    //
    
    private function get_validatedSessions() : Array<UserSessionLoggingData>
    {
        var sessions : Array<UserSessionLoggingData> = new Array<UserSessionLoggingData>();
        var sessionLogging : UserSessionLoggingData;
        for (currSessionId in Reflect.fields(_pageloadMap))
        {
            sessionLogging = new UserSessionLoggingData(currSessionId);
            sessionLogging.setPageloads(_pageloadMap[currSessionId]);
            sessionLogging.setActions(_actionsSessionMap[currSessionId]);
            sessionLogging.setQuests(_questSessionMap[currSessionId]);
            sessionLogging.validate();
            sessions.push(sessionLogging);
        }
        
        return sessions;
    }
    
    private function get_arePageLoadsValid() : Bool
    {
        return _pageloadsValid;
    }
    
    private function get_areQuestsValid() : Bool
    {
        return _questsValid;
    }
    
    private function get_areActionsValid() : Bool
    {
        return _actionsValid;
    }
    
    public function getSessionCount() : Int
    {
        return _pageloads.length;
    }
    
    public function getValidSessionCount() : Int
    {
        return 0;
    }
    
    private function validateSession(sessionId : String) : Void
    {  //TODO - Validate all of the loaded data.  
        
    }
    
    //
    // Data management functions.
    //
    
    public function setPageLoadData(pageloads : Array<PageLoadData>) : Void
    {
        if (pageloads != null)
        {
            var currSessionId : String;
            var sessionPageloads : Array<PageLoadData>;
            for (pageload in pageloads)
            {
                _pageloads.push(pageload);
                if (pageload.isSessionIdValid)
                {
                    currSessionId = pageload.sessionId;
                    sessionPageloads = _pageloadMap[currSessionId];
                    if (sessionPageloads == null)
                    {
                        sessionPageloads = new Array<PageLoadData>();
                        _pageloadMap[currSessionId] = sessionPageloads;
                    }
                    sessionPageloads.push(pageload);
                }
            }
        }
        
        _pageloadsValid = true;
    }
    
    public function setQuestData(data : Array<QuestData>) : Void
    {
        if (data != null)
        {
            var sessionQuests : Array<QuestData>;
            for (questData in data)
            {
                _quests.push(questData);
                if (questData.isSessionIdValid)
                {
                    sessionQuests = _questSessionMap[questData.sessionId];
                    if (sessionQuests == null)
                    {
                        sessionQuests = new Array<QuestData>();
                        _questSessionMap[questData.sessionId] = sessionQuests;
                    }
                    sessionQuests.push(questData);
                }
            }
        }
        
        _questsValid = true;
    }
    
    public function setGameAction(data : Array<GameAction>) : Void
    {
        if (data != null)
        {
            var sessionActions : Array<GameAction>;
            for (gameAction in data)
            {
                _actions.push(gameAction);
                if (gameAction.isSessionIdValid)
                {
                    sessionActions = _actionsSessionMap[gameAction.sessionId];
                    if (sessionActions == null)
                    {
                        sessionActions = new Array<GameAction>();
                        _actionsSessionMap[gameAction.sessionId] = sessionActions;
                    }
                    sessionActions.push(gameAction);
                }
            }
        }
        
        _actionsValid = true;
    }
}
