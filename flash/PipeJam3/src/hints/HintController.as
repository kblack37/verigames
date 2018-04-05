package hints 
{
	import display.TextBubble;
	import scenes.game.display.ClauseNode;
	import scenes.game.display.Edge;
	import scenes.game.display.Level;
	import scenes.game.display.Node;
	import starling.core.Starling;
	import starling.display.Sprite;
	import system.VerigameServerConstants;
	
	public class HintController extends Sprite 
	{
		private static const FADE_SEC:Number = 0.3;
		private static const SMALL_NODE_CHECK_VAL:int = 9;
		
		private static var m_instance:HintController;
		
		private var m_hintBubble:TextBubble;
		private var m_playerStatus:PlayerHintStatus = new PlayerHintStatus();
		public var hintLayer:Sprite;
		
		public static function getInstance():HintController
		{
			if (m_instance == null) {
				m_instance = new HintController(new SingletonLock());
			}
			return m_instance;
		}
		
		public function HintController(lock:SingletonLock):void
		{
		}
		
		/**
		 * Checks the selected nodes to see whether hints should be given
		 * @param	level
		 * @return true if autosolve should continue, false if autosolve should halt (to display hint, for example)
		 */
		public function checkAutosolveSelection(level:Level):Boolean
		{
			var performSmallSelectionCheck:Boolean = (level.tutorialManager != null) ? level.tutorialManager.getPerformSmallAutosolveGroupCheck() : true;
			var atLeastOneConflictFound:Boolean = false;
			for each(var selectedNode:Node in level.selectedNodes)
			{
				if (selectedNode is ClauseNode)
				{
					var clauseNode:ClauseNode = selectedNode as ClauseNode;
					if (clauseNode.hasError())
					{
						atLeastOneConflictFound = true;
						break;
					}
				}
				else
				{
					for each(var gameEdgeId:String in selectedNode.connectedEdgeIds)
					{
						var edge:Edge = level.edgeLayoutObjs[gameEdgeId] as Edge;
						if (edge != null)
						{
							var clause:ClauseNode;
							if (edge.fromNode is ClauseNode)
							{
								clause = edge.fromNode as ClauseNode;
								if (clause.hasError())
								{
									atLeastOneConflictFound = true;
									break;
								}
							}
							if (edge.toNode is ClauseNode)
							{
								clause = edge.toNode as ClauseNode;
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
				var smallGroupAttempts:int = m_playerStatus.getSmallGroupAttempts(level);
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
		
		public function incrementSmallGroupAttempts(level:Level):void
		{
			var smallGroupAttempts:int = m_playerStatus.getSmallGroupAttempts(level);
			m_playerStatus.setSmallGroupAttempts(level, smallGroupAttempts + 1);
		}
		
		public function resetSmallGroupAttempts(level:Level):void
		{
			m_playerStatus.setSmallGroupAttempts(level, 0);
		}
		
		public function popHint(text:String, level:Level, secToShow:Number = 3.0):void
		{
			if (PipeJam3.logging)
			{
				var details:Object = new Object();
				details[VerigameServerConstants.ACTION_PARAMETER_TEXT] = text;
				PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_DISPLAY_HINT, details, level.getTimeMs());
			}
			if (m_hintBubble != null) Starling.juggler.removeTweens(m_hintBubble);
			removeHint(); // any existing hints
			m_hintBubble = new TextBubble("Hint: " + text, 10, (PipeJam3.ASSET_SUFFIX == "Turk") ? Constants.NARROW_GRAY : Constants.NARROW_BLUE, null, level, Constants.HINT_LOC, null, null, false);
			fadeInHint();
			Starling.juggler.delayCall(fadeOutHint, secToShow + FADE_SEC);
		}
		
		public function fadeInHint():void
		{
			if (m_hintBubble != null)
			{
				m_hintBubble.alpha = 0;
				hintLayer.addChild(m_hintBubble);
				Starling.juggler.tween(m_hintBubble, FADE_SEC, { alpha:1.0 } );
			}
		}
		
		public function fadeOutHint():void
		{
			if (m_hintBubble != null)
			{
				Starling.juggler.tween(m_hintBubble, FADE_SEC, { alpha:0, onComplete:removeHint } );
			}
		}
		
		public function removeHint():void
		{
			if (m_hintBubble != null) m_hintBubble.removeFromParent(true);
		}
	}

}

internal class SingletonLock { } // to prevent outside construction of singleton

import flash.utils.Dictionary;
import scenes.game.display.Level;
internal class PlayerHintStatus
{
	private var m_levelStatusDict:Dictionary = new Dictionary();
	public function PlayerHintStatus():void
	{
	}
	
	public function getSmallGroupAttempts(level:Level):int
	{
		var levelStatus:LevelHintStatus = getLevelStatus(level.name);
		return levelStatus.smallGroupSelectionAttempts;
	}
	
	public function setSmallGroupAttempts(level:Level, val:int):void
	{
		var levelStatus:LevelHintStatus = getLevelStatus(level.name);
		levelStatus.smallGroupSelectionAttempts = val;
	}
	
	private function getLevelStatus(levelName:String):LevelHintStatus
	{
		if (!m_levelStatusDict.hasOwnProperty(levelName)) m_levelStatusDict[levelName] = new LevelHintStatus();
		return (m_levelStatusDict[levelName] as LevelHintStatus);
	}
}

internal class LevelHintStatus
{
	public var smallGroupSelectionAttempts:int = 0;
	
	public function LevelHintStatus():void
	{
	}
}