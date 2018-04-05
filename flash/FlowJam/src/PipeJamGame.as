package
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import assets.AssetsAudio;
	
	import audio.AudioManager;
	
	import buildInfo.BuildInfo;
	
	import cgs.Cache.Cache;
	
	import dialogs.SimpleAlertDialog;
	
	import display.GameObjectBatch;
	import display.MusicButton;
	import display.NineSliceBatch;
	import display.PipeJamTheme;
	import display.SoundButton;
	
	import events.MenuEvent;
	import events.NavigationEvent;
	
	import networking.GameFileHandler;
	import networking.PlayerValidation;
	import networking.TutorialController;
	
	import scenes.game.PipeJamGameScene;
	import scenes.game.display.World;
	import scenes.levelselectscene.LevelSelectScene;
	import scenes.loadingscreen.LoadingScreenScene;
	import scenes.splashscreen.SplashScreenScene;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	import utils.XSprite;
	
	public class PipeJamGame extends Game
	{
		/** Set by flashVars */
		public static var DEBUG_MODE:Boolean = false;
		
		/** Set to true to print trace statements identifying the type of objects that are clicked on */
		public static var DEBUG_IDENTIFY_CLICKED_ELEMENTS_MODE:Boolean = false;
				
		public static var SEPARATE_FILES:int = 1;
		public static var ALL_IN_ONE:int = 2;
		
		public static var theme:PipeJamTheme;
		
		private var m_musicButton:MusicButton;
		private static var m_sfxButton:SoundButton;
		
		private var m_gameObjectBatch:GameObjectBatch;
		
		/** this is the main holder of information about the level. */
		public static var levelInfo:Object;

		public static var m_pipeJamGame:PipeJamGame;
		
		public var m_fileName:String;

		
		public function PipeJamGame()
		{
			super();
			m_pipeJamGame = this;
			
			// load general assets
			prepareAssets();
			
			scenesToCreate["LoadingScene"] = LoadingScreenScene;
			scenesToCreate["SplashScreen"] = SplashScreenScene;
			scenesToCreate["LevelSelectScene"] = LevelSelectScene;
			scenesToCreate["PipeJamGame"] = PipeJamGameScene;
			
			AudioManager.getInstance().reset();
			//AudioManager.getInstance().audioDriver().musicOn = !Boolean(Cache.getSave(Constants.CACHE_MUTE_MUSIC));
			AudioManager.getInstance().audioDriver().sfxOn = AudioManager.getInstance().audioDriver().musicOn = !Boolean(Cache.getSave(Constants.CACHE_MUTE_SFX));
			
			/*
			m_musicButton = new MusicButton();
			XSprite.setupDisplayObject(m_musicButton, 16.5, Constants.GameHeight - 14.5, 12.5);
			AudioManager.getInstance().setMusicButton(m_musicButton, updateMusicState);
			*/
			m_sfxButton = new SoundButton();
			XSprite.setupDisplayObject(m_sfxButton, 20, Constants.GameHeight - 20, 12.5);
			AudioManager.getInstance().setAllAudioButton(m_sfxButton, updateSfxState);
			
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
			
			this.addEventListener(MenuEvent.TOGGLE_SOUND_CONTROL, toggleSoundControl);
			addEventListener(NavigationEvent.GET_RANDOM_LEVEL, onGetRandomLevel);
			addEventListener(NavigationEvent.GET_SAVED_LEVEL, onGetSavedLevel);

		}	
		
		//override to get your scene initialized for viewing
		protected function addedToStage(event:starling.events.Event):void
		{			
			theme = new PipeJamTheme( this.stage );
			//	theme1 = new AeonDesktopTheme( this.stage );
			
			m_gameObjectBatch = new GameObjectBatch;
			NineSliceBatch.gameObjectBatch = m_gameObjectBatch;
			
			var obj:Object = Starling.current.nativeStage.loaderInfo.parameters;
			if(obj.hasOwnProperty("localfile"))
			{
				m_fileName = obj["localfile"];
				PipeJamGame.levelInfo = new Object;
			}
			else if(obj.hasOwnProperty("dbfile"))
			{
				m_fileName = obj["dbfile"];
			}
			if(obj.hasOwnProperty("tutorial"))
			{
				m_fileName = "tutorial";
				PipeJamGame.levelInfo = new Object;
				PipeJamGame.levelInfo.name = "foo";
				PipeJamGame.levelInfo.id = obj["tutorial"];
				PipeJamGame.levelInfo.tutorialLevelID = obj["tutorial"];
				TutorialController.getTutorialController().getTutorialsCompletedFromCookieString();
			}
			else if (ExternalInterface.available) {
				var url:String = ExternalInterface.call("window.location.href.toString");
				var paramsStart:int = url.indexOf('?');
				if(paramsStart != -1)
				{
					var params:String = url.substring(paramsStart+1);
					var vars:URLVariables = new URLVariables(params);
					if(vars.localfile)
					{
						m_fileName = vars.localfile;
						//create this here so we know this is a local file
						PipeJamGame.levelInfo = new Object;
					}
					else if(vars.dbfile)
					{
						m_fileName = vars.dbfile;
					}
					else if(vars.tutorial)
					{
						m_fileName = "tutorial";
						PipeJamGame.levelInfo = new Object;
						PipeJamGame.levelInfo.name = "foo";
						PipeJamGame.levelInfo.id = vars.tutorial; 
						PipeJamGame.levelInfo.tutorialLevelID = vars.tutorial; 
						TutorialController.getTutorialController().getTutorialsCompletedFromCookieString();
					}
				}
			}
			
			// use file if set in url, else create and show menu screen
			if(m_fileName)
			{ 
				if(PipeJamGame.levelInfo) //local file
					showScene("PipeJamGame");
				else
					loadLevelFromName(m_fileName);
			}
			else if(PipeJam3.RELEASE_BUILD && !PipeJam3.LOCAL_DEPLOYMENT)
				showScene("LoadingScene");
			else
			{
				PlayerValidation.playerID = PlayerValidation.playerIDForTesting;
				TutorialController.getTutorialController().getTutorialsCompletedByPlayer();
				showScene("SplashScreen");				
			}
			
			addChild(m_sfxButton);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		//load file from db based on level name i.e. L120_V60
		public function loadLevelFromName(levelName:String):void
		{
			GameFileHandler.loadLevelInfoFromName(levelName, loadLevel);
		}
		
		protected function loadLevel(result:int, objVector:Vector.<Object>):void
		{
			PipeJamGame.levelInfo = new objVector[0];		
			PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
		}
		
		protected function removedFromStage(event:starling.events.Event):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			removeEventListener(NavigationEvent.GET_RANDOM_LEVEL, onGetRandomLevel);
			removeEventListener(NavigationEvent.GET_SAVED_LEVEL, onGetSavedLevel);
		}
		
		private function onGetSavedLevel(event:NavigationEvent):void
		{
			PipeJamGameScene.inTutorial = false;
			PipeJamGame.levelInfo = GameFileHandler.findLevelObject(PipeJam3.m_savedCurrentLevel.data.levelInfoID);
			
			if(levelInfo)
			{
				//update assignmentsID if needed
				PipeJamGameScene.levelContinued = true;
				PipeJamGame.levelInfo.assignmentsID = PipeJam3.m_savedCurrentLevel.data.assignmentsID;
				dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
				GameFileHandler.getHighScoresForLevel(handleHighScoreList, PipeJamGame.levelInfo.levelID);
			}
			else //just alert user, and then get random level
			{
				var dialogText:String = "Previous level doesn't exist any\n more. Serving a random level.";
				var alert:SimpleAlertDialog = new SimpleAlertDialog(dialogText, 160, 80, "", onGetRandomLevel, 2);
				addChild(alert);
			}			
		}	
		
		protected function onGetRandomLevel(event:NavigationEvent = null):void
		{
			PipeJamGameScene.inTutorial = false;
			PipeJamGame.levelInfo = GameFileHandler.getRandomLevelObject();
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
				GameFileHandler.getHighScoresForLevel(handleHighScoreList, PipeJamGame.levelInfo.levelID);
				//save info locally so we can retrieve next run
				PipeJam3.m_savedCurrentLevel.data.levelInfoID = PipeJamGame.levelInfo.id;
				PipeJam3.m_savedCurrentLevel.data.levelID = PipeJamGame.levelInfo.levelID;
				PipeJam3.m_savedCurrentLevel.data.assignmentsID = PipeJamGame.levelInfo.assignmentsID;
				PipeJam3.m_savedCurrentLevel.data.layoutID = PipeJamGame.levelInfo.layoutID;
				PipeJam3.m_savedCurrentLevel.data.assignmentUpdates = new Object();
				dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
			}
		}
		
		public function getRandomLevelCallback(e:TimerEvent = null):void
		{
			onGetRandomLevel();
		}
		
		protected function handleHighScoreList(result:int, list:Vector.<Object>):void
		{
			var highScoreArray:Array = new Array;
			for each(var level:Object in list)
			{
				level.numericScore = int(level.current_score);
				highScoreArray.push(level);
			}
			
			if(highScoreArray.length > 0)
				highScoreArray.sortOn("numericScore", Array.DESCENDING | Array.NUMERIC);
			
			PipeJamGame.levelInfo.highScores = highScoreArray;

			if(World.m_world)
				World.m_world.setHighScores();
		}
		
		protected function toggleSoundControl(event:starling.events.Event):void
		{
			m_sfxButton.visible = event.data;
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
		
		private function updateMusicState(musicOn:Boolean):void
		{
			m_musicButton.musicOn = musicOn;
			var result:Boolean = Cache.setSave(Constants.CACHE_MUTE_MUSIC, !musicOn)
			trace("Cache updateMusicState: " + result);
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
		
		static public function resetSoundButtonParent():void
		{
			if(World.m_world)
				World.m_world.addSoundButton(m_sfxButton);
		}
		
		public function changeFullScreen(newWidth:int, newHeight:int):void
		{
			if(World.m_world)
				World.m_world.changeFullScreen(newWidth, newHeight);
		}
	}
}