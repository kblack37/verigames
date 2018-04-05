package Events
{
	import System.VerigameServerConstants;
	
	import VisualWorld.VerigameSystem;
	
	import cgs.server.logging.actions.ClientAction;
	import flash.utils.Timer;
	import Replay.ReplayTimeline;
	import flash.display.Sprite;

	public class CGSServerLocal
	{
		protected var m_gameSystem:VerigameSystem;
		protected var m_replayActionIndex:int = 0;
		
		public static var m_replayActionObjects:Vector.<ClientAction>;
		
		public function CGSServerLocal(gameSystem:VerigameSystem)
		{
			m_gameSystem = gameSystem;
			
			if(m_replayActionObjects == null)
				m_replayActionObjects = new Vector.<ClientAction>;
		}
		
		public static function logQuestStart(questID:int, details:Object, callback:Function=null, aeSeqID:String=null, localDQID:int=-1):int
		{
			if(m_replayActionObjects == null)
				m_replayActionObjects = new Vector.<ClientAction>;
			
			var startAction:ClientAction = new ClientAction(VerigameServerConstants.VERIGAME_ACTION_START);
			startAction.addDetailProperty(VerigameServerConstants.ACTION_PARAMETER_START_INFO, details);
			m_replayActionObjects.push(startAction);
			
			return 0;
		}
		
		public static function logQuestAction(action:ClientAction):void
		{
			if(m_replayActionObjects == null)
				m_replayActionObjects = new Vector.<ClientAction>;
			
			m_replayActionObjects.push(action);
		}
		
		public function replayActions(parent:Sprite):ReplayTimeline
		{
			var timeline:ReplayTimeline = new ReplayTimeline(m_replayActionObjects, skipAction, stepToIndex, parent.width, parent.height - 35);

			m_replayActionIndex = 0;
			
			return timeline;
			
		}
		
		private function skipAction(obj:ClientAction):Boolean
		{
			// TODO: If any actions can be skipped in replay, define the logic here and return true
			return false;
		}
		
		private function stepToIndex(index:int):void
		{
			index = clampInt(index, -1, m_replayActionObjects.length - 1);
			
			if (index == m_replayActionIndex) {
				return;
			}
			
			// For previous actions, replay all from beginning (TODO: may need to reset the level first)
			if (index < m_replayActionIndex) {
				m_replayActionIndex = -1;
			}
			
			// Replay all actions from the current action to the index = action to be replayed up to
			while (index > m_replayActionIndex) {
				++ m_replayActionIndex;
				
				var obj:ClientAction = m_replayActionObjects[m_replayActionIndex];
				m_gameSystem.replayAction(obj);
			}
		}
		
		public static function clampInt(x:int, lo:int, hi:int):int
		{
			return (x < lo ? lo : (x > hi ? hi : x));
		}
	}
}