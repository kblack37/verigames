package events;

import haxe.Constraints.Function;
import system.VerigameServerConstants;
import visualWorld.VerigameSystem;
import cgs.server.logging.actions.ClientAction;
import flash.utils.Timer;
import replay.ReplayTimeline;
import flash.display.Sprite;

class CGSServerLocal
{
    private var m_gameSystem : VerigameSystem;
    private var m_replayActionIndex : Int = 0;
    
    public static var m_replayActionObjects : Array<ClientAction>;
    
    public function new(gameSystem : VerigameSystem)
    {
        m_gameSystem = gameSystem;
        
        if (m_replayActionObjects == null)
        {
            m_replayActionObjects = new Array<ClientAction>();
        }
    }
    
    public static function logQuestStart(questID : Int, details : Dynamic, callback : Function = null, aeSeqID : String = null, localDQID : Int = -1) : Int
    {
        if (m_replayActionObjects == null)
        {
            m_replayActionObjects = new Array<ClientAction>();
        }
        
        var startAction : ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_START);
        startAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_START_INFO, details);
        m_replayActionObjects.push(startAction);
        
        return 0;
    }
    
    public static function logQuestAction(action : ClientAction) : Void
    {
        if (m_replayActionObjects == null)
        {
            m_replayActionObjects = new Array<ClientAction>();
        }
        
        m_replayActionObjects.push(action);
    }
    
    public function replayActions(parent : Sprite) : ReplayTimeline
    {
        var timeline : ReplayTimeline = new ReplayTimeline(m_replayActionObjects, skipAction, stepToIndex, parent.width, parent.height - 35);
        
        m_replayActionIndex = 0;
        
        return timeline;
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
            m_gameSystem.replayAction(obj);
        }
    }
    
    public static function clampInt(x : Int, lo : Int, hi : Int) : Int
    {
        return ((x < lo) ? lo : ((x > hi) ? hi : x));
    }
}
