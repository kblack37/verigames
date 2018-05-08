package server;

import cgs.server.logging.actions.QuestAction;
import haxe.Constraints.Function;
import cgs.server.logging.CgsServerApi;
import cgs.server.logging.actions.IClientAction;
import cgs.server.logging.data.QuestData;
import cgs.server.logging.data.QuestStartEndData;
import haxe.Json;
import scenes.game.display.ReplayWorld;
import system.VerigameServerConstants;

class ReplayController
{
    private static var m_instance : ReplayController;
    public var questData : QuestData;
    private var m_questDataLoadedCallback : Function;
    private var m_currentActionIndex : Int = -1;
    private var m_nextActionIndex : Int = -1;
    //private var m_previewingAction:Boolean = false;
    private var m_lastDir : Int = 1;
    
    public static function getInstance() : ReplayController
    {
        if (m_instance == null)
        {
            m_instance = new ReplayController(new SingletonLock());
        }
        return m_instance;
    }
    
    public function advance(world : ReplayWorld) : Void
    {
        trace("advance");
        if (questData == null)
        {
            return;
        }
        if (questData.actions == null)
        {
            return;
        }
        var numActions : Int = questData.actions.length;
        if (numActions == 0)
        {
            return;
        }
        if ((m_currentActionIndex == -1) && (m_nextActionIndex == -1))
        {
            attemptPreviewAction(questData.actions, 0, world, 1);
        }
		 // Perform previewed action
        else if ((m_currentActionIndex == m_nextActionIndex) && (m_lastDir == 1))
		{
            attemptPerformAction(questData.actions, m_currentActionIndex, world, 1);
        }
        // Otherwise preview next action
        else
        {
            
            attemptPreviewAction(questData.actions, ((m_lastDir == 1)) ? (m_currentActionIndex + 1) : m_currentActionIndex, world, 1);
        }
    }
    
    public function backup(world : ReplayWorld) : Void
    {
        trace("backup");
        if ((m_currentActionIndex == -1) && (m_nextActionIndex == -1))
        {
            return;
        }
        if (questData == null)
        {
            return;
        }
        if (questData.actions == null)
        {
            return;
        }
        var numActions : Int = questData.actions.length;
        if (numActions == 0)
        {
            return;
        }
        if ((m_currentActionIndex == m_nextActionIndex) && (m_lastDir == -1))
        {
        // Perform previewed action
            
            attemptPerformAction(questData.actions, m_currentActionIndex, world, -1);
        }
        // Otherwise preview prev action
        else
        {
            
            attemptPreviewAction(questData.actions, ((m_lastDir == -1)) ? (m_currentActionIndex - 1) : m_currentActionIndex, world, -1);
        }
    }
    
    private function attemptPerformAction(actions : Array<Dynamic>, attemptIndex : Int, world : ReplayWorld, dir : Int) : Void
    {
        var numActions : Int = actions.length;
        if (attemptIndex < 0)
        {
            return;
        }
        if (attemptIndex > numActions - 1)
        {
            return;
        }
        if (!(Std.is(actions[attemptIndex], IClientAction)))
        {
            return;
        }
        var action : QuestAction = try cast(actions[attemptIndex], QuestAction) catch(e:Dynamic) null;
        // perform the action now
        world.performAction(action, dir == -1);
        m_currentActionIndex = attemptIndex;
        m_nextActionIndex = m_currentActionIndex + dir;
        m_lastDir = dir;
    }
    
    private function attemptPreviewAction(actions : Array<Dynamic>, attemptIndex : Int, world : ReplayWorld, dir : Int) : Void
    {
        var numActions : Int = actions.length;
        if (attemptIndex < 0)
        {
            return;
        }
        if (attemptIndex > numActions - 1)
        {
            return;
        }
        if (!(Std.is(actions[attemptIndex], IClientAction)))
        {
            return;
        }
        var action : QuestAction = try cast(actions[attemptIndex], QuestAction) catch(e:Dynamic) null;
        // preview the action now
        world.previewAction(action, dir == -1);
        m_currentActionIndex = attemptIndex;
        m_nextActionIndex = m_currentActionIndex;
        m_lastDir = dir;
    }
    
    public function new(lock : SingletonLock)
    {
        m_currentActionIndex = m_nextActionIndex = -1;
    }
    
    /**
		 * Load quest data from server, callback should have signature:
		 * function onQuestDataLoaded(questData:QuestData, errMessage:String = null):void {}
		 */
    public function loadQuestData(dqid : String, cgsServer : CgsServerApi, callback : Function) : Void
    {
        cgsServer.requestQuestData(dqid, onLoadQuestData);
        m_questDataLoadedCallback = callback;
    }
    
    private function onLoadQuestData(_questData : QuestData, failed : Bool) : Void
    {
        questData = _questData;
        m_currentActionIndex = m_nextActionIndex = -1;
        //m_previewingAction = false;
        
        if (m_questDataLoadedCallback == null)
        {
            return;
        }
        
        if (failed)
        {
            m_questDataLoadedCallback(questData, "Quest data not loaded.");
            return;
        }
        
        if (questData == null)
        {
            m_questDataLoadedCallback(questData, "Quest data empty.");
            return;
        }
        
        if (questData.startData == null)
        {
            m_questDataLoadedCallback(questData, "Quest startData empty.");
            return;
        }
        
        if (questData.actions == null || questData.actions.length == 0)
        {
            m_questDataLoadedCallback(questData, "No actions for this quest.");
            return;
        }
        
        if (questData.versionId != VerigameServerConstants.VERIGAME_VERSION_GRID_WORLD_BETA)
        {
            m_questDataLoadedCallback(questData, "Version mismatch: expected " + VerigameServerConstants.VERIGAME_VERSION_GRID_WORLD_BETA + " got " + questData.versionId);
            return;
        }
        
        if (!ReplayController.validateReplay(questData.actions))
        {
            m_questDataLoadedCallback(questData, "Replay invalid.");
            return;
        }
        
        m_questDataLoadedCallback(questData);
        m_questDataLoadedCallback = null;
    }
    
    private static function getQuestStart(questString : String) : QuestStartEndData
    {
        var questObj : Array<Dynamic> = Json.parse(questString);
        
        var questStart : QuestStartEndData = new QuestStartEndData();
        questStart.parseJsonData(questObj[0]);
        return questStart;
    }
    
    private static function getQuestEnd(questString : String) : QuestStartEndData
    {
        var questObj : Array<Dynamic> = Json.parse(questString);
        
        if (questObj[1] != null)
        {
            var questEnd : QuestStartEndData = new QuestStartEndData();
            questEnd.parseJsonData(questObj[1]);
            return questEnd;
        }
        else
        {
            return null;
        }
    }
    
    private static function getActionsArray(actionsString : String) : Array<Dynamic>
    {
        var actionsObj : Dynamic = Json.parse(actionsString);
        
        var actionsDetail : Array<Dynamic> = new Array<Dynamic>();
        for (actionObjName in Reflect.fields(actionsObj))
        {
			var actionObj = Reflect.field(actionsObj, actionObjName);
            var clientAction : QuestAction = new QuestAction();
            clientAction.parseJsonData(actionObj);
            actionsDetail.push(clientAction);
        }
        
        return actionsDetail;
    }
    
    private static function orderActions(actionsArray : Array<Dynamic>) : Array<Dynamic>
    {
        var sortedActions : Array<Dynamic> = actionsArray.copy();
        sortedActions.sort(compareActions);
        return sortedActions;
    }
    
    private static function compareActions(aa : Dynamic, bb : Dynamic) : Int
    {
        var SEQ : String = "questActionSequenceId";
        if (!aa.questActionSequenceId || !bb.questActionSequenceId)
        {
            return 0;
        }
        if (aa.questActionSequenceId < bb.questActionSequenceId)
        {
            return -1;
        }
        else if (aa.questActionSequenceId > bb.questActionSequenceId)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    
    private static function validateReplay(actionsArray : Array<Dynamic>) : Bool
    {
        trace("Validating replay.");
        
        var orderedActions : Array<Dynamic> = orderActions(actionsArray);
        // TODO
        trace("SUCCESS: replay valid.");
        return true;
    }
}


class SingletonLock
{

    @:allow(server)
    private function new()
    {
    }
}  // to prevent outside construction of singleton  