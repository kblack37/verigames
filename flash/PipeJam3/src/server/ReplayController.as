package server
{
	import cgs.server.logging.CGSServer;
	import cgs.server.logging.actions.ClientAction;
	import cgs.server.logging.data.QuestData;
	import cgs.server.logging.data.QuestStartEndData;
	
	import com.adobe.serialization.json.JSON;
	
	import scenes.game.display.ReplayWorld;
	
	import system.VerigameServerConstants;
	
	public class ReplayController
	{
		private static var m_instance:ReplayController;
		public var questData:QuestData;
		private var m_questDataLoadedCallback:Function;
		private var m_currentActionIndex:int = -1;
		private var m_nextActionIndex:int = -1;
		//private var m_previewingAction:Boolean = false;
		private var m_lastDir:int = 1;
		
		public static function getInstance():ReplayController
		{
			if (m_instance == null) {
				m_instance = new ReplayController(new SingletonLock());
			}
			return m_instance;
		}
		
		public function advance(world:ReplayWorld):void
		{
			trace("advance");
			if (questData == null) return;
			if (questData.actions == null) return;
			var numActions:int = questData.actions.length;
			if (numActions == 0) return;
			if ((m_currentActionIndex == -1) && (m_nextActionIndex == -1)) {
				attemptPreviewAction(questData.actions, 0, world, 1);
			} else if ((m_currentActionIndex == m_nextActionIndex) && (m_lastDir == 1)) {
				// Perform previewed action
				attemptPerformAction(questData.actions, m_currentActionIndex, world, 1);
			} else {
				// Otherwise preview next action
				attemptPreviewAction(questData.actions, (m_lastDir == 1) ? (m_currentActionIndex + 1) : m_currentActionIndex, world, 1);
			}
		}
		
		public function backup(world:ReplayWorld):void
		{
			trace("backup");
			if ((m_currentActionIndex == -1) && (m_nextActionIndex == -1)) return;
			if (questData == null) return;
			if (questData.actions == null) return;
			var numActions:int = questData.actions.length;
			if (numActions == 0) return;
			if ((m_currentActionIndex == m_nextActionIndex) && (m_lastDir == -1)) {
				// Perform previewed action
				attemptPerformAction(questData.actions, m_currentActionIndex, world, -1);
			} else {
				// Otherwise preview prev action
				attemptPreviewAction(questData.actions, (m_lastDir == -1) ? (m_currentActionIndex - 1) : m_currentActionIndex, world, -1);
			}
		}
		
		private function attemptPerformAction(actions:Array, attemptIndex:int, world:ReplayWorld, dir:int):void
		{
			var numActions:int = actions.length;
			if (attemptIndex < 0) return;
			if (attemptIndex > numActions - 1) return;
			if (!(actions[attemptIndex] is ClientAction)) return;
			var action:ClientAction = actions[attemptIndex] as ClientAction;
			// perform the action now
			world.performAction(action, dir == -1);
			m_currentActionIndex = attemptIndex;
			m_nextActionIndex = m_currentActionIndex + dir;
			m_lastDir = dir;
			//m_previewingAction = false;
		}
		
		private function attemptPreviewAction(actions:Array, attemptIndex:int, world:ReplayWorld, dir:int):void
		{
			var numActions:int = actions.length;
			if (attemptIndex < 0) return;
			if (attemptIndex > numActions - 1) return;
			if (!(actions[attemptIndex] is ClientAction)) return;
			var action:ClientAction = actions[attemptIndex] as ClientAction;
			// preview the action now
			world.previewAction(action, dir == -1);
			m_currentActionIndex = attemptIndex;
			m_nextActionIndex = m_currentActionIndex;
			m_lastDir = dir;
			//m_previewingAction = true;
		}
		
		public function ReplayController(lock:SingletonLock):void
		{
			m_currentActionIndex = m_nextActionIndex = -1;
			//m_previewingAction = false;
		}
		
		/**
		 * Load quest data from server, callback should have signature:
		 * function onQuestDataLoaded(questData:QuestData, errMessage:String = null):void {}
		 */
		public function loadQuestData(dqid:String, cgsServer:CGSServer, callback:Function):void
		{
			cgsServer.requestQuestData(dqid, onLoadQuestData);
			m_questDataLoadedCallback = callback;
		}
		
		private function onLoadQuestData(_questData:QuestData, failed:Boolean):void
		{
			questData = _questData;
			m_currentActionIndex = m_nextActionIndex = -1;
			//m_previewingAction = false;
			
			if (m_questDataLoadedCallback == null) return;
			
			if (failed) {
				m_questDataLoadedCallback(questData, "Quest data not loaded.");
				return;
			}
			
			if (questData == null) {
				m_questDataLoadedCallback(questData, "Quest data empty.");
				return;
			}
			
			if (questData.startData == null) {
				m_questDataLoadedCallback(questData, "Quest startData empty.");
				return;
			}
			
			if (questData.actions == null || questData.actions.length == 0) {
				m_questDataLoadedCallback(questData, "No actions for this quest.");
				return;
			}
			
			if (questData.versionId != VerigameServerConstants.VERIGAME_VERSION_GRID_WORLD_BETA) {
				m_questDataLoadedCallback(questData, "Version mismatch: expected " + VerigameServerConstants.VERIGAME_VERSION_GRID_WORLD_BETA + " got " + questData.versionId);
				return;
			}
			
			if (!ReplayController.validateReplay(questData.actions)) {
				m_questDataLoadedCallback(questData, "Replay invalid.");
				return;
			}
			
			m_questDataLoadedCallback(questData);
			m_questDataLoadedCallback = null;
		}
		
		private static function getQuestStart(questString:String):QuestStartEndData
		{
			var questObj:Array = com.adobe.serialization.json.JSON.decode(questString);
			
			var questStart:QuestStartEndData = new QuestStartEndData();
			questStart.parseJsonData(questObj[0]);
			return questStart;
		}
		
		private static function getQuestEnd(questString:String):QuestStartEndData
		{
			var questObj:Array = com.adobe.serialization.json.JSON.decode(questString);
			
			if (questObj[1]) {
				var questEnd:QuestStartEndData = new QuestStartEndData();
				questEnd.parseJsonData(questObj[1]);
				return questEnd;
			} else {
				return null;
			}
		}
		
		private static function getActionsArray(actionsString:String):Array
		{
			var actionsObj:Object = com.adobe.serialization.json.JSON.decode(actionsString);
			
			var actionsDetail:Array = new Array();
			for each (var actionObj:Object in actionsObj) {
				var clientAction:ClientAction = new ClientAction();
				clientAction.parseJsonData(actionObj);
				actionsDetail.push(clientAction);
			}
			
			return actionsDetail;
		}
		
		private static function orderActions(actionsArray:Array):Array
		{
			var sortedActions:Array = actionsArray.concat();
			sortedActions.sort(compareActions);
			return sortedActions;
		}
		
		private static function compareActions(aa:Object, bb:Object):int
		{
			const SEQ:String = "questActionSequenceId";
			if (!aa.questActionSequenceId || !bb.questActionSequenceId) return 0;
			if (aa.questActionSequenceId < bb.questActionSequenceId) {
				return -1;
			} else if (aa.questActionSequenceId > bb.questActionSequenceId) {
				return 1;
			} else {
				return 0;
			}
		}
		
		private static function validateReplay(actionsArray:Array):Boolean
		{
			trace();
			trace("Validating replay.");
			
			var orderedActions:Array = orderActions(actionsArray);
			// TODO
			trace("SUCCESS: replay valid.");
			return true;
		}
		
	}
}

internal class SingletonLock {} // to prevent outside construction of singleton