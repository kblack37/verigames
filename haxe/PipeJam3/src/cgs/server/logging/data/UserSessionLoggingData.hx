package cgs.server.logging.data;

import openfl.utils.Dictionary;
import cgs.server.logging.actions.GameAction;
import cgs.server.logging.actions.IClientAction;

/**
 * Contains all of the logging data for a users session.
 */
class UserSessionLoggingData
{
    public var totalSessionItemCount(get, never) : Int;
    public var invalidSessionSequenceIds(get, never) : Array<Dynamic>;
    public var sessionId(get, never) : String;
    public var duplicatedSessionItemCount(get, never) : Int;
    public var missingSessionItemCount(get, never) : Int;
    public var duplicatedQuestCount(get, never) : Int;
    public var missingQuestCount(get, never) : Int;
    public var duplicatedQuestActionCount(get, never) : Int;
    public var missingQuestActionCount(get, never) : Int;
    public var missingLogItemCount(get, never) : Int;

    private var _sessionId : String;
    private var _validated : Bool;
    
    private var _pageloads : Array<PageLoadData>;
    private var _quests : Array<QuestData>;
    private var _actions : Array<GameAction>;
    
    private var _orderedSessionLogs : Array<ISessionSequenceData>;
    private var _orderedQuests : Array<IQuestSequenceData>;
    private var _orderedQuestActionsMap : Dictionary<String, Dynamic>;
    
    private var _invalidSessionSeqIds : Array<Dynamic>;
    
    //Counts of duplicated items.
    private var _duplicatedSessionItems : Int;
    private var _duplicatedQuests : Int;
    private var _duplicatedQuestActions : Int;
    
    //Counts of missing items.
    private var _missingSessionItemCount : Int;
    private var _missingQuestCount : Int;
    private var _missingQuestActionCount : Int;
    
    public function new(sessionId : String)
    {
        _sessionId = sessionId;
        _invalidSessionSeqIds = [];
    }
    
    //
    // Properties of the session.
    //
    
    private function get_totalSessionItemCount() : Int
    {
        return _orderedSessionLogs.length;
    }
    
    private function get_invalidSessionSequenceIds() : Array<Dynamic>
    {
        return _invalidSessionSeqIds;
    }
    
    private function get_sessionId() : String
    {
        return _sessionId;
    }
    
    private function get_duplicatedSessionItemCount() : Int
    {
        return _duplicatedSessionItems;
    }
    
    private function get_missingSessionItemCount() : Int
    {
        return _missingSessionItemCount;
    }
    
    private function get_duplicatedQuestCount() : Int
    {
        return _duplicatedQuests;
    }
    
    private function get_missingQuestCount() : Int
    {
        return _missingQuestCount;
    }
    
    private function get_duplicatedQuestActionCount() : Int
    {
        return _duplicatedQuestActions;
    }
    
    private function get_missingQuestActionCount() : Int
    {
        return _missingQuestActionCount;
    }
    
    //
    // Validation functions.
    //
    
    public function validate() : Void
    {
        if (_validated)
        {
            return;
        }
        
        _orderedSessionLogs = new Array<ISessionSequenceData>();
        _orderedQuests = new Array<IQuestSequenceData>();
        _orderedQuestActionsMap = new Dictionary<String, Dynamic>();
        
        //Create all of the ordered arrays.
        for (pageload in _pageloads)
        {
            _orderedSessionLogs.push(pageload);
        }
        for (action in _actions)
        {
            _orderedSessionLogs.push(action);
        }
        
        var orderedQuestActions : Array<Dynamic>;
        var startData : QuestStartEndData;
        for (quest in _quests)
        {
            startData = quest.startData;
            if (startData != null)
            {
                _orderedSessionLogs.push(startData);
                _orderedQuests.push(startData);
            }
            orderedQuestActions = [];
            for (currAction/* AS3HX WARNING could not determine type for var: currAction exp: EField(EIdent(quest),actions) type: null */ in quest.actions)
            {
                orderedQuestActions.push(currAction);
                _orderedSessionLogs.push(currAction);
            }
            _orderedQuestActionsMap[quest] = orderedQuestActions;
            startData = quest.endData;
            if (startData != null)
            {
                _orderedSessionLogs.push(startData);
            }
        }
        
        sortLogItems();
        
        //Figure out which log items are missing.
        validateSessionLogItems();
    }
    
    private function validateSessionLogItems() : Void
    {
        var values : Array<Dynamic> = validateSequenceIds(_orderedSessionLogs, "sessionSequenceId");
        _missingSessionItemCount = values[0];
        _duplicatedSessionItems = values[1];
    }
    
    private function validateQuests() : Void
    {
        var values : Array<Dynamic> = validateSequenceIds(_orderedQuests, "questSequenceId");
        _missingQuestCount = values[0];
        _duplicatedQuests = values[1];
    }
    
    private function validateQuestActions() : Void
    {
        var values : Array<Dynamic>;
        for (questActions/* AS3HX WARNING could not determine type for var: questActions exp: EIdent(_orderedQuestActionsMap) type: Dictionary */ in _orderedQuestActionsMap)
        {
            values = validateSequenceIds(questActions, "questActionSequenceId");
            _missingQuestActionCount += values[0];
            _duplicatedQuestActions += values[1];
        }
    }
    
    private function validateSequenceIds(data : Dynamic, propertyName : String) : Array<Dynamic>
    {
        var currMissingItems : Int = 0;
        var prevId : Int = -1;
        var currId : Int = -1;
        var dupItems : Int = 0;
        var missingItems : Int = 0;
        for (item/* AS3HX WARNING could not determine type for var: item exp: EIdent(data) type: Dynamic */ in data)
        {
            currId = item[propertyName];
            if (currId == prevId)
            {
                dupItems++;
            }
            else
            {
                currMissingItems = as3hx.Compat.parseInt(currId - prevId - 1);
                missingItems += currMissingItems;
                
                for (idx in prevId + 1...currId)
                {
                    _invalidSessionSeqIds.push(idx);
                }
            }
            prevId = currId;
        }
        
        return [missingItems, dupItems];
    }
    
    private function sortLogItems() : Void
    {
        _orderedSessionLogs = _orderedSessionLogs.sort(sortSessionLogs);
        _orderedQuests = _orderedQuests.sort(sortQuestLogs);
        
        for (questActions/* AS3HX WARNING could not determine type for var: questActions exp: EIdent(_orderedQuestActionsMap) type: Dictionary */ in _orderedQuestActionsMap)
        {
            questActions.sort(sortQuestActions);
        }
    }
    
    private function sortSessionLogs(itemA : ISessionSequenceData, itemB : ISessionSequenceData) : Int
    {
        return as3hx.Compat.parseInt(itemA.sessionSequenceId - itemB.sessionSequenceId);
    }
    
    private function sortQuestLogs(itemA : IQuestSequenceData, itemB : IQuestSequenceData) : Int
    {
        return as3hx.Compat.parseInt(itemA.questSequenceId - itemB.questSequenceId);
    }
    
    private function sortQuestActions(itemA : IQuestActionSequenceData, itemB : IQuestActionSequenceData) : Int
    {
        return as3hx.Compat.parseInt(itemA.questActionSequenceId - itemB.questActionSequenceId);
    }
    
    private function get_missingLogItemCount() : Int
    {
        return 0;
    }
    
    public function setPageloads(pageloads : Array<PageLoadData>) : Void
    {
        _pageloads = pageloads;
    }
    
    public function setQuests(quests : Array<QuestData>) : Void
    {
        _quests = quests;
    }
    
    public function setActions(actions : Array<GameAction>) : Void
    {
        _actions = actions;
    }
}
