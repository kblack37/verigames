package
{
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import server.MTurkAPI;
	
	import assets.AssetsAudio;
	
	import audio.AudioManager;
	
	import buildInfo.BuildInfo;
	
	import cgs.Cache.Cache;
	
	import display.GameObjectBatch;
	import display.NineSliceBatch;
	import display.SoundButton;
	
	import events.MenuEvent;
	import events.NavigationEvent;
	
	import networking.GameFileHandler;
	import networking.HTTPCookies;
	import networking.PlayerValidation;
	import networking.TutorialController;
	
	import scenes.game.PipeJamGameScene;
	import scenes.game.display.World;
	import scenes.levelselectscene.LevelSelectScene;
	import scenes.splashscreen.SplashScreenScene;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	import utils.XSprite;
	
	public class PipeJamGame extends Game
	{
		/** Set by flashVars */
		public static var DEBUG_MODE:Boolean = false;
		
		/** Set to true to print trace statements identifying the type of objects that are clicked on */
		public static var DEBUG_IDENTIFY_CLICKED_ELEMENTS_MODE:Boolean = false;
				
		public static var SET_SOUNDBUTTON_PARENT:String = "set_soundbutton_parent";

		public static var SEPARATE_FILES:int = 1;
		public static var ALL_IN_ONE:int = 2;
		
		private static var m_sfxButton:SoundButton;
		public static var soundButtonGlobalCoords:Point = new Point(400.5, 294);
		private var m_gameObjectBatch:GameObjectBatch;
		
		/** this is the main holder of information about the level. */
		// TODO: Pass this information to children as needed (not as static public var), create a well defined class for properties contained rather than a generic Object
		public static var levelInfo:Object;

		public static var m_pipeJamGame:PipeJamGame;
		
		public var m_fileName:String;
		public var m_levelID:String;
		
		public function PipeJamGame()
		{
			super();
			m_pipeJamGame = this;
			
			// load general assets
			prepareAssets();
			
			scenesToCreate["SplashScreen"] = SplashScreenScene;
			scenesToCreate["LevelSelectScene"] = LevelSelectScene;
			scenesToCreate["PipeJamGame"] = PipeJamGameScene;
			
			AudioManager.getInstance().reset();
			//AudioManager.getInstance().audioDriver().musicOn = !Boolean(Cache.getSave(Constants.CACHE_MUTE_MUSIC));
			AudioManager.getInstance().audioDriver().sfxOn = AudioManager.getInstance().audioDriver().musicOn = !Boolean(Cache.getSave(Constants.CACHE_MUTE_SFX));
			
			
			m_sfxButton = new SoundButton();
			XSprite.setupDisplayObject(m_sfxButton, 8, Constants.GameHeight - 20, 12.5);
			AudioManager.getInstance().setAllAudioButton(m_sfxButton, updateSfxState);
			
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
			
			this.addEventListener(MenuEvent.TOGGLE_SOUND_CONTROL, toggleSoundControl);
			addEventListener(NavigationEvent.GET_RANDOM_LEVEL, onGetRandomLevel);
			addEventListener(NavigationEvent.UPDATE_HIGH_SCORES, updateHighScoreList);
			addEventListener(SET_SOUNDBUTTON_PARENT, handleSoundButtonParentEvent);
		}	
		
		private function handleSoundButtonParentEvent(event:starling.events.Event):void
		{
			var _parent:Sprite = event.data as Sprite;
			
			//have we been disposed? recreate if needed
			if(!m_sfxButton.hasEventListener(TouchEvent.TOUCH))
			{
				m_sfxButton = new SoundButton();
				XSprite.setupDisplayObject(m_sfxButton, 8, Constants.GameHeight - 20, 12.5);
				AudioManager.getInstance().setAllAudioButton(m_sfxButton, updateSfxState);
			}
			var localPoint:Point = _parent.globalToLocal(soundButtonGlobalCoords);
			m_sfxButton.x = localPoint.x;
			m_sfxButton.y = localPoint.y;
			
			if (PipeJam3.ASSET_SUFFIX == "Turk") m_sfxButton.visible = false;
			
			_parent.addChild(m_sfxButton);
		}
		
		protected function addedToStage(event:starling.events.Event):void
		{						
			m_gameObjectBatch = new GameObjectBatch;
			NineSliceBatch.gameObjectBatch = m_gameObjectBatch;
			
			if (ExternalInterface.available)
			{
				TutorialController.getTutorialController().getTutorialsCompletedByPlayer();
				
				var url:String = ExternalInterface.call("window.location.href.toString");
				var paramsStart:int = url.indexOf('?');
				if(paramsStart != -1)
				{
					var params:String = url.substring(paramsStart+1);
					var vars:URLVariables = new URLVariables(params);
					if (PipeJam3.ASSET_SUFFIX == "Turk" && vars.token)
					{
						MTurkAPI.getInstance().workerToken = vars.token;
						if (vars.name)
						{
							MTurkAPI.getInstance().taskId = String(vars.name);
							m_fileName = String(vars.name);
						}
						MTurkAPI.getInstance().onTaskBegin();
						ExternalInterface.call("console.log", "[Flash game]: workerToken found from queryString: " + vars.token + " task:" + MTurkAPI.getInstance().taskId);
					}
					else if(vars.localfile)
					{
						m_fileName = vars.localfile;
						//create this here so we know this is a local file
						PipeJamGame.levelInfo = new Object;
					}
					else if(vars.dbfile)
					{
						m_fileName = vars.dbfile;
					}
					else if(vars.levelID)
					{
						m_levelID = vars.levelID;

					}
					else if(vars.name)
					{
						m_fileName = vars.name;
					}
					else if(vars.tutorial)
					{
						m_fileName = "tutorial";
						PipeJamGame.levelInfo = new Object;
						PipeJamGame.levelInfo.name = "foo";
						PipeJamGame.levelInfo.id = vars.tutorial; 
						PipeJamGame.levelInfo.tutorialLevelID = vars.tutorial; 
					}
					
					if(vars.code)
					{
						var accessCode:String = vars.code;
						PlayerValidation.initiateAccessTokenAccess(accessCode);
					}
					else if(vars.error)
					{
						PlayerValidation.accessToken = "denied";
					}
				}
			}
			else if (PipeJam3.ASSET_SUFFIX == "Turk")
			{
				// Use test token
				MTurkAPI.getInstance().workerToken = "4G9OGQuO9X";
				m_fileName = "p_001011_00054778";
				MTurkAPI.getInstance().onTaskBegin();
			}
			
			// use file if set in url, else create and show menu screen
			if(m_fileName || m_levelID || PlayerValidation.AuthorizationAttempted)
			{ 
				if(PipeJamGame.levelInfo) //local file
					showScene("PipeJamGame");
				else if(m_levelID)
					loadLevelFromID(m_levelID);
				else if(m_fileName)
					loadLevelFromName(m_fileName);
				else
					onGetRandomLevel();
					
			}
			else if (PipeJam3.ASSET_SUFFIX == "Turk")
			{
				if (MTurkAPI.getInstance().taskId == "101")
					PipeJamGameScene.inTutorial = true;
				PipeJamGameScene.inDemo = false;
				showScene("PipeJamGame");
			}
			else
			{
				PlayerValidation.playerID = PlayerValidation.playerIDForTesting;

				showScene("SplashScreen");				
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		//load file from db based on level id
		public function loadLevelFromID(levelName:String):void
		{
			GameFileHandler.loadLevelInfoFromID(levelName, loadLevel);
		}
		
		//load file from db based on level name i.e. L120_V60
		public function loadLevelFromName(levelName:String):void
		{
			GameFileHandler.loadLevelInfoFromName(levelName, loadLevel);
		}
		
		protected function loadLevel(result:int, objVector:Vector.<Object>):void
		{
			levelInfo = new objVector[0];		
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
		}
		
		protected function removedFromStage(event:starling.events.Event):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			removeEventListener(NavigationEvent.GET_RANDOM_LEVEL, onGetRandomLevel);
			removeEventListener(NavigationEvent.UPDATE_HIGH_SCORES, updateHighScoreList);
		}
		
		public function onGetRandomLevel(event:NavigationEvent = null):void
		{
			PipeJamGameScene.inTutorial = false;
			levelInfo = GameFileHandler.getRandomLevelObject();
			if(PipeJamGame.levelInfo == null)
			{
				//assume level file is slow loading, and cycle back around after a while.
				//maybe only happens when debugging locally...
				var timer:Timer = new Timer(250, 1);
				timer.addEventListener(TimerEvent.TIMER, getRandomLevelCallback);
				timer.start();
			}
			else
			{
				updateHighScoreList();
				dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
			}
		}
		
		public function getRandomLevelCallback(e:TimerEvent = null):void
		{
			onGetRandomLevel();
		}
		
		public function updateHighScoreList(event:starling.events.Event = null):void
		{
			if(!PipeJamGameScene.inTutorial && !(PipeJam3.ASSET_SUFFIX == "Turk"))
				GameFileHandler.getHighScoresForLevel(handleHighScoreList, PipeJamGame.levelInfo.levelID);
		}
		
		protected function handleHighScoreList(result:int, list:Vector.<Object>):void
		{
			var highScoreArray:Array = new Array; 
			for each(var level:Object in list)
			{
				level.numericScore = int(level[0]);
				level.playerID = level[1];
				level.assignmentsID = level[2];
				level.difference = int(level[3]);
				highScoreArray.push(level);
				PlayerValidation.playerInfoQueue.push(level.playerID);
			}
			PlayerValidation.validationObject.getPlayerInfo();

			PipeJamGame.levelInfo.highScores = highScoreArray;

			if(World.m_world)
				World.m_world.setHighScores();
		}
		
		protected function toggleSoundControl(event:starling.events.Event):void
		{
			m_sfxButton.visible = (PipeJam3.ASSET_SUFFIX == "Turk") ? false : event.data;
			if(m_sfxButton.visible)
			{
				AudioManager.getInstance().reset();
				AudioManager.getInstance().playMusic(AssetsAudio.MUSIC_FIELD_SONG);
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.ctrlKey && event.altKey && event.shiftKey && event.keyCode == Keyboard.V) {
				var buildId:String = BuildInfo.DATE + "-" + BuildInfo.VERSION;
				trace(buildId);
				System.setClipboard(buildId);
			}
		}
		
		private function updateSfxState(sfxOn:Boolean):void
		{
			m_sfxButton.sfxOn = sfxOn;
			var result:Boolean = Cache.setSave(Constants.CACHE_MUTE_SFX, !sfxOn)
			trace("Cache updateSfxState: " + result);
		}
		
		/**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)"
		 * @param	_msg Text to print
		 */
		public static function printDebug(_msg:String):void {
			//			if (!SUPPRESS_TRACE_STATEMENTS) {
			//				trace(_msg);
			//				if (ExternalInterface.available) {
			//					//var reply:String = ExternalInterface.call("navTo", URLBASE + "browsing/card.php?id=" + quiz_card_asked + "&topic=" + TOPIC_NUM);
			//					var reply:String = ExternalInterface.call("printDebug", _msg);
			//				}
			//			}
		}
		
		/**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)" - Specifically warnings that may be wanted even if other debug messages are not
		 * @param	_msg Warning text to print
		 */
		public static function printWarning(_msg:String):void {
			if (!SUPPRESS_TRACE_STATEMENTS) {
				trace(_msg);
				if (ExternalInterface.available) {
					//var reply:String = ExternalInterface.call("navTo", URLBASE + "browsing/card.php?id=" + quiz_card_asked + "&topic=" + TOPIC_NUM);
					var reply:String = ExternalInterface.call("printDebug", _msg);
				}
			}
		}
		
		public function changeFullScreen(newWidth:int, newHeight:int):void
		{
			if(World.m_world)
				World.m_world.changeFullScreen(newWidth, newHeight);
		}
	}
}