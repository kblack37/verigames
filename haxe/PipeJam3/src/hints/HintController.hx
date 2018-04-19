package hints;

import display.TextBubble;
import scenes.game.display.ClauseNode;
import scenes.game.display.Edge;
import scenes.game.display.Level;
import scenes.game.display.Node;
import starling.core.Starling;
import starling.display.Sprite;
import system.VerigameServerConstants;
import flash.utils.Dictionary;


class HintController extends Sprite
{
    private static inline var FADE_SEC : Float = 0.3;
    private static inline var SMALL_NODE_CHECK_VAL : Int = 9;
    
    private static var m_instance : HintController;
    
    private var m_hintBubble : TextBubble;
    private var m_playerStatus : PlayerHintStatus = new PlayerHintStatus();
    public var hintLayer : Sprite;
    
    public static function getInstance() : HintController
    {
        if (m_instance == null)
        {
            m_instance = new HintController();
        }
        return m_instance;
    }
    
    private function new()
    {
        super();
    }
    
    /**
		 * Checks the selected nodes to see whether hints should be given
		 * @param	level
		 * @return true if autosolve should continue, false if autosolve should halt (to display hint, for example)
		 */
    public function checkAutosolveSelection(level : Level) : Bool
    {
        var performSmallSelectionCheck : Bool = ((level.tutorialManager != null)) ? level.tutorialManager.getPerformSmallAutosolveGroupCheck() : true;
        var atLeastOneConflictFound : Bool = false;
        for (selectedNode in level.selectedNodes)
        {
            if (Std.is(selectedNode, ClauseNode))
            {
                var clauseNode : ClauseNode = try cast(selectedNode, ClauseNode) catch(e:Dynamic) null;
                if (clauseNode.hasError())
                {
                    atLeastOneConflictFound = true;
                    break;
                }
            }
            else
            {
                for (gameEdgeId in selectedNode.connectedEdgeIds)
                {
                    var edge : Edge = try cast(level.edgeLayoutObjs[gameEdgeId], Edge) catch(e:Dynamic) null;
                    if (edge != null)
                    {
                        var clause : ClauseNode;
                        if (Std.is(edge.fromNode, ClauseNode))
                        {
                            clause = try cast(edge.fromNode, ClauseNode) catch(e:Dynamic) null;
                            if (clause.hasError())
                            {
                                atLeastOneConflictFound = true;
                                break;
                            }
                        }
                        if (Std.is(edge.toNode, ClauseNode))
                        {
                            clause = try cast(edge.toNode, ClauseNode) catch(e:Dynamic) null;
                            if (clause.hasError())
                            {
                                atLeastOneConflictFound = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
        if (!atLeastOneConflictFound)
        {
            popHint("Paint at least one\nconflict before optimizing", level);
            return false;
        }
        else if (performSmallSelectionCheck)
        {
            var smallGroupAttempts : Int = m_playerStatus.getSmallGroupAttempts(level);
            if (level.selectedNodes.length <= SMALL_NODE_CHECK_VAL)
            {
                incrementSmallGroupAttempts(level);
            }
            else
            {
                resetSmallGroupAttempts(level);
            }
            
            if (smallGroupAttempts + 1 == 3)
            {
            // After three consecutive small attempts, assume the user is not click+dragging properly and prompt them to do so
                
                popHint("Try holding the left mouse button and\ndragging to select many variables at once.", level);
                m_playerStatus.setSmallGroupAttempts(level, 0);
                return false;
            }
        }
        return true;
    }
    
    public function incrementSmallGroupAttempts(level : Level) : Void
    {
        var smallGroupAttempts : Int = m_playerStatus.getSmallGroupAttempts(level);
        m_playerStatus.setSmallGroupAttempts(level, smallGroupAttempts + 1);
    }
    
    public function resetSmallGroupAttempts(level : Level) : Void
    {
        m_playerStatus.setSmallGroupAttempts(level, 0);
    }
    
    public function popHint(text : String, level : Level, secToShow : Float = 3.0) : Void
    {
        if (PipeJam3.logging)
        {
            var details : Dynamic = {};
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TEXT), text);
            PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_DISPLAY_HINT, details, level.getTimeMs());
        }
        if (m_hintBubble != null)
        {
            Starling.current.juggler.removeTweens(m_hintBubble);
        }
        removeHint();  // any existing hints  
        m_hintBubble = new TextBubble("Hint: " + text, 10, ((PipeJam3.ASSET_SUFFIX == "Turk")) ? Constants.NARROW_GRAY : Constants.NARROW_BLUE, null, level, Constants.HINT_LOC, null, null, false);
        fadeInHint();
        Starling.current.juggler.delayCall(fadeOutHint, secToShow + FADE_SEC);
    }
    
    public function fadeInHint() : Void
    {
        if (m_hintBubble != null)
        {
            m_hintBubble.alpha = 0;
            hintLayer.addChild(m_hintBubble);
            Starling.current.juggler.tween(m_hintBubble, FADE_SEC, {
                        alpha : 1.0
                    });
        }
    }
    
    public function fadeOutHint() : Void
    {
        if (m_hintBubble != null)
        {
            Starling.current.juggler.tween(m_hintBubble, FADE_SEC, {
                        alpha : 0,
                        onComplete : removeHint
                    });
        }
    }
    
    public function removeHint() : Void
    {
        if (m_hintBubble != null)
        {
            m_hintBubble.removeFromParent(true);
        }
    }
}



class SingletonLock
{

    @:allow(hints)
    private function new()
    {
    }
}  // to prevent outside construction of singleton  

class PlayerHintStatus
{
    private var m_levelStatusDict : Dynamic = {};
	
    @:allow(hints)
    private function new()
    {
    }
    
    public function getSmallGroupAttempts(level : Level) : Int
    {
        var levelStatus : LevelHintStatus = getLevelStatus(level.name);
        return levelStatus.smallGroupSelectionAttempts;
    }
    
    public function setSmallGroupAttempts(level : Level, val : Int) : Void
    {
        var levelStatus : LevelHintStatus = getLevelStatus(level.name);
        levelStatus.smallGroupSelectionAttempts = val;
    }
    
    private function getLevelStatus(levelName : String) : LevelHintStatus
    {
        if (!Reflect.hasField(m_levelStatusDict, levelName))
        {
            Reflect.setField(m_levelStatusDict, levelName, new LevelHintStatus());
        }
        return (try cast(Reflect.field(m_levelStatusDict, levelName), LevelHintStatus) catch(e:Dynamic) null);
    }
}

class LevelHintStatus
{
    public var smallGroupSelectionAttempts : Int = 0;
    
    @:allow(hints)
    private function new()
    {
    }
}