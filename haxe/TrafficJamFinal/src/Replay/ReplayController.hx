package replay;

import cgs.server.logging.actions.ClientAction;
import cgs.server.logging.CGSServer;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.GameServerData;
import cgs.server.logging.data.QuestData;
import flash.display.Sprite;

class ReplayController extends Sprite
{
    private static inline var SKEY : String = "";  // TODO: fill in  
    private static inline var GAME_NAME : String = "PipeJam";  // TODO: fill in  
    private static inline var GAME_ID : Int = 1234;  // TODO: fill in  
    private static inline var VERSION : Int = 1;  // TODO: fill in whatever the current version of the game is, replays probably won't work for older versions being loaded from server  
    private static inline var CATEGORY : Int = 1;  // this actually doesn't matter for replays, it will grab the data regardless  
    private static var CGS_SERVER_TAG : String = CGSServerProps.PRODUCTION_SERVER;  //or CGSServerProps.DEVELOPMENT_SERVER  
    
    private var m_replayActionObjects : Array<ClientAction>;
    private var m_replayActionIndex : Int = -1;
    
    public function new(new_dqid : String = null)
    {
        super();
        var dqidToReplay : String;
        if (root && root.loaderInfo && root.loaderInfo.parameters["dqid"] != null)
        {
            dqidToReplay = root.loaderInfo.parameters["dqid"];
        }
        else
        {
            dqidToReplay = new_dqid;
        }
        trace("dqid = " + dqidToReplay);
        loadReplay(dqidToReplay);
    }
    
    private function loadReplay(dqid : String) : Void
    {
        var props : CGSServerProps = new CGSServerProps(
        SKEY, 
        GameServerData.NO_SKEY_HASH, 
        GAME_NAME, 
        GAME_ID, 
        VERSION, 
        CATEGORY, 
        CGS_SERVER_TAG);
        CGSServer.instance.setup(props);
        CGSServer.instance.requestQuestData(dqid, onLoadQuestData);
    }
    
    private function onLoadQuestData(questData : QuestData, failed : Bool) : Void
    {
        if (failed)
        {
            trace("Quest data not loaded.");
            return;
        }
        
        if (questData == null)
        {
            trace("Quest data empty.");
            return;
        }
        
        if (questData.startData == null)
        {
            trace("Quest startData empty.");
            return;
        }
        
        if (questData.actions == null || questData.actions.length == 0)
        {
            trace("No actions for this quest.");
            return;
        }
        
        if (VERSION != questData.versionId)
        {
            trace("Version mismatch: expected " + VERSION + " got " + questData.versionId);
            return;
        }
        
        m_replayActionObjects = questData.actions.concat();
        // TODO: make sure these are sorted by qaction_seqid if possible
        
        
        var timeline : ReplayTimeline = new ReplayTimeline(m_replayActionObjects, skipAction, stepToIndex, 600, 300);
        addChild(timeline);
    }
    
    private function skipAction(obj : ClientAction) : Bool
    // TODO: If any actions can be skipped in replay, define the logic here and return true
    {
        
        return false;
    }
    
    private function stepToIndex(index : Int) : Void
    {
        index = clampInt(index, -1, m_replayActionObjects.length - 1);
        
        if (index == m_replayActionIndex)
        {
            return;
        }
        
        // For previous actions, replay all from beginning (TODO: may need to reset the level first)
        if (index < m_replayActionIndex)
        {
            m_replayActionIndex = -1;
        }
        
        // Replay all actions from the current action to the index = action to be replayed up to
        while (index > m_replayActionIndex)
        {
            ++m_replayActionIndex;
            
            var obj : ClientAction = m_replayActionObjects[m_replayActionIndex];
        }
    }
    
    
    
    public static function clampInt(x : Int, lo : Int, hi : Int) : Int
    {
        return ((x < lo) ? lo : ((x > hi) ? hi : x));
    }
}
