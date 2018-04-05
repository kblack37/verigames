package server
{
	import cgs.Cache.Cache;
	import cgs.server.logging.CGSServer;
	import cgs.server.logging.CGSServerConstants;
	import cgs.server.logging.CGSServerProps;
	import cgs.server.logging.GameServerData;
	import cgs.server.logging.actions.ClientAction;
	
	import flash.display.Stage;
	
	import system.VerigameServerConstants;
	
	public class LoggingServerInterface
	{
		public static const SETUP_KEY_FRIENDS_AND_FAMILY_BETA:String = "SETUP_KEY_FRIENDS_AND_FAMILY_BETA";
		public static const SETUP_KEY_TURK:String = "SETUP_KEY_TURK";
		public static const CGS_VERIGAMES_PREFIX:String = "cgs_vg_";
		public static const CACHE_PREV_UID:String = "prev_uid"; // used to track play sessions before a player was logged in
		
		private var m_cgsServer:CGSServer;
		private var m_props:CGSServerProps;
		public var uid:String;
		public var prevUid:String;
		public var serverInitialized:Boolean = false;
		public var serverToUse:String = PipeJam3.RELEASE_BUILD ? CGSServerProps.PRODUCTION_SERVER : CGSServerProps.DEVELOPMENT_SERVER
		public var saveCacheToServer:Boolean = false;
		public var provideIp:Boolean = true;
		public var stage:Stage;
		
		public function LoggingServerInterface(_setupKey:String, _stage:Stage = null, _forceUid:String = "", _replay:Boolean = false)
		{
			stage = _stage;
			setupServer(_setupKey, _stage, _forceUid);
			if (!_replay) {
				m_cgsServer.initialize(m_props, saveCacheToServer, onServerInit, null, provideIp ? _stage : null);
			}
		}
		
		public function setupServer(_setupKey:String, _stage:Stage = null, _forceUid:String = ""):void
		{
			//Initialize logging
			m_cgsServer = new CGSServer();
			var cid:int = VerigameServerConstants.VERIGAME_CATEGORY_SEEDLING_BETA;
			switch (_setupKey) {
				case SETUP_KEY_FRIENDS_AND_FAMILY_BETA:
					cid = VerigameServerConstants.VERIGAME_CATEGORY_PARADOX_FRIENDS_FAMILY_BETA_MAY_15_2015;
					saveCacheToServer = true;
					provideIp = false;
					break;
				case SETUP_KEY_TURK:
					cid = VerigameServerConstants.VERIGAME_CATEGORY_PARADOX_MTURK_JUNE_2015;
					saveCacheToServer = true;
					provideIp = false;
					break;
			}
			
			m_props = new CGSServerProps(
				VerigameServerConstants.VERIGAME_SKEY,
				GameServerData.NO_SKEY_HASH,
				VerigameServerConstants.VERIGAME_GAME_NAME,
				VerigameServerConstants.VERIGAME_GAME_ID,
				VerigameServerConstants.VERIGAME_VERSION_GRID_WORLD_BETA,
				cid,
				serverToUse,
				CGSServerProps.VERSION2
			);
			
			m_props.cacheUid = false;
			m_props.uidValidCallback = onUidSet;
			//m_props.loadServerCacheDataByCid = true;
			if (_forceUid.length > 0) m_props.forceUid = _forceUid;
			m_cgsServer.setup(m_props);
		}
		
		public function addPlayerID(playerID:String):void
		{
			//setupServer(PipeJam3.loggingKey, null, playerID);
			
			if (PipeJam3.LOGGING_ON) 
			{
				PipeJam3.logging = new LoggingServerInterface(PipeJam3.loggingKey, stage, CGS_VERIGAMES_PREFIX + playerID, PipeJam3.REPLAY_DQID != null);
			}	
		}
		
		public function get cgsServer():CGSServer { return m_cgsServer; }
		
		private function onServerInit(failed:Boolean):void
		{
			trace("onServerInit() failed=" + failed.toString());
			serverInitialized = !failed;
		}
		
		private function onUidSet(_uid:String, failed:Boolean):void
		{
			trace("onUidSet uid:" + _uid + " failed:" + failed);
			uid = _uid;
			prevUid = Cache.getSave(CACHE_PREV_UID) as String;
			if (!prevUid)
			{
				Cache.setSave(CACHE_PREV_UID, uid);
			}
		}
		
		public function logQuestStart(questId:int = VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, questDetails:Object = null):void
		{
			trace("Logging quest start, qid:" + questId);
			if (prevUid != uid)
			{
				questDetails = add2det(questDetails, CACHE_PREV_UID, prevUid);
			}
			m_cgsServer.logQuestStart(questId, questDetails, onLogQuestStart);
		}
		
		public function logQuestEnd(questId:int = VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, questDetails:Object = null):void
		{
			trace("Logging quest end, qid:" + questId);
			if (prevUid != uid)
			{
				questDetails = add2det(questDetails, CACHE_PREV_UID, prevUid);
			}
			m_cgsServer.logQuestEnd(questId, questDetails);
		}
		
		private function onLogQuestStart(dqid:String, failed:Boolean):void
		{
			trace("onLogQuestStart dqid:" + dqid + " failed:" + failed);
		}
		
		public function logQuestAction(actionId:int, actionDetails:Object, levelTimeMs:Number):void
		{
			var clientAction:ClientAction = new ClientAction(actionId, levelTimeMs);
			if (prevUid != uid)
			{
				actionDetails = add2det(actionDetails, CACHE_PREV_UID, prevUid);
			}
			clientAction.setDetail(actionDetails);
			trace("logQuestAction actionId:" + actionId + " details:" + obj2str(actionDetails) + " levelTimeMs:" + levelTimeMs);
			m_cgsServer.logQuestAction(clientAction);
		}
		
		private static function obj2str(obj:Object):String
		{
			var str:String = "{\n"
			for (var key:String in obj)
			{
				str = str + key + ":" + obj[key] + "\n";
			}
			str = str + "}";
			return str;
		}
		
		private static function add2det(obj:Object, key:String, value:Object):Object
		{
			if (obj == null) obj = new Object();
			obj[key] = value;
			return obj;
		}
	}
}