package  
{
	import com.spikything.utils.MouseWheelTrap;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import assets.AssetsFont;
	
	import audio.AudioManager;
	
	import cgs.server.logging.data.QuestData;
	
	import events.NavigationEvent;
	
	import net.hires.debug.Stats;
	
	import networking.GameFileHandler;
	import networking.NetworkConnection;
	
	import scenes.splashscreen.SplashScreenScene;
	
	import server.LoggingServerInterface;
	import server.ReplayController;
	
	import starling.core.Starling;
	import starling.events.Event;
	import scenes.game.display.World;
	
	import system.VerigameServerConstants;
	
	//import mx.core.FlexGlobals;
	//import spark.components.Application;
	
	[SWF(width = "960", height = "640", frameRate = "30", backgroundColor = "#ffffff")]
	
	public class PipeJam3 extends flash.display.Sprite 
	{
		static public var GAME_ID:int = 1;
		
		private var mStarling:Starling;
		
		/** Set to true if a build for the server */
		public static var RELEASE_BUILD:Boolean = false;
		public static var LOGGING_ON:Boolean = false;
		public static var LOCAL_DEPLOYMENT:Boolean = false;
		public static var TUTORIAL_DEMO:Boolean = true;
		public static var USE_LOCAL_PROXY:Boolean = false;
		public static var SHOW_PERFORMANCE_STATS:Boolean = false;
		
		public static var PRODUCTION:Boolean = false;
		public static var INSTALL_DVD:Boolean = false;
		public static var REPLAY_DQID:String;// = "dqid_5252fd7aa741e8.90134465";
		private static const REPLAY_TEXT_FORMAT:TextFormat = new TextFormat(AssetsFont.FONT_UBUNTU, 6, 0xFFFF00);
		
		public static const DISABLE_FILTERS:Boolean = true;
		
		public static var logging:LoggingServerInterface;
		
		protected var hasBeenAddedToStage:Boolean = false;
		protected var isFullScreen:Boolean = false;
		
		//We store 5 pieces of info, the level record ID, the three file IDs, and a dictionary of widget size changes since last save (or load).
		//This is for restoring game play between sessions.
		static public var m_savedCurrentLevel:SharedObject;

		//used to know if this is the inital launch, and the Play button should load a tutorial level or the level dialog instead
		public static var initialLevelDisplay:Boolean = true; 
		static public var pipeJam3:PipeJam3;
		
		private static var m_replayText:TextField = new TextField();
		
		public function PipeJam3()
		{
			pipeJam3 = this;
			
			addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			if (REPLAY_DQID || LoggingServerInterface.LOGGING_ON) 
			{
				logging = new LoggingServerInterface(LoggingServerInterface.SETUP_KEY_FRIENDS_AND_FAMILY_BETA, stage, "", REPLAY_DQID != null);
				if (REPLAY_DQID) {
					ReplayController.getInstance().loadQuestData(REPLAY_DQID, logging.cgsServer, onReplayQuestDataLoaded);
				}
			}	
		}
		
		public function onAddedToStage(evt:flash.events.Event):void {
			if(hasBeenAddedToStage == false)
			{
				removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);

				initialize();
			}
		}
		
		public function initialize(result:int = 0, e:flash.events.Event = null):void
		{			
			MouseWheelTrap.setup(stage);
			
			//set up the main controller
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			Starling.multitouchEnabled = false; // useful on mobile devices
			Starling.handleLostContext = true; // deactivate on mobile devices (to save memory)
			
			if (SHOW_PERFORMANCE_STATS) {
				var stats:Stats = new Stats;
				stage.addChild(stats);
			}
			
			//	mStarling = new Starling(PipeJamGame, stage, null, null,Context3DRenderMode.SOFTWARE);
			mStarling = new Starling(PipeJamGame, stage);
			//mostly just an annoyance in desktop mode, so turn off...
			mStarling.simulateMultitouch = false;
			mStarling.enableErrorChecking = false;
			mStarling.start();
			
			if (REPLAY_DQID) {
				m_replayText.text = "Loading replay...";
				m_replayText.width = Constants.GameWidth;
				m_replayText.height = 30;
				m_replayText.setTextFormat(REPLAY_TEXT_FORMAT);
				mStarling.nativeOverlay.addChild(m_replayText);
			}
			
			// this event is dispatched when stage3D is set up
			mStarling.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated);
			
			//FlexGlobals.topLevelApplication.stage.addEventListener(Event.RESIZE, updateSize);
			stage.addEventListener(flash.events.Event.RESIZE, updateSize);
			stage.dispatchEvent(new flash.events.Event(flash.events.Event.RESIZE));
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("loadLevelFromObjectID", loadLevelFromObjectID);
			}
			
			var fullURL:String = this.loaderInfo.url;
			var protocolEndIndex:int = fullURL.indexOf('//');
			var baseURLEndIndex:int = fullURL.indexOf('/', protocolEndIndex + 2);
			NetworkConnection.baseURL = fullURL.substring(0, baseURLEndIndex);
			if(NetworkConnection.baseURL.indexOf("http") != -1)
			{
				if(PipeJam3.PRODUCTION == true)
					NetworkConnection.productionInterop = NetworkConnection.baseURL + "/game/interop.php";
				else if(PipeJam3.INSTALL_DVD == true)
					NetworkConnection.productionInterop = NetworkConnection.baseURL + "/flowjam/scripts/interop.php";
			}
			else
			{
				NetworkConnection.productionInterop = "http://flowjam.verigames.com/game/interop.php";
				NetworkConnection.baseURL = "http://flowjam.verigames.com";
			}
			//initialize stuff
			new NetworkConnection();
			m_savedCurrentLevel = SharedObject.getLocal("FlowJamData");
			GameFileHandler.retrieveLevels();
			
			Starling.current.nativeStage.addEventListener(flash.events.Event.FULLSCREEN, changeFullScreen);
		}
				
		protected function changeFullScreen(event:flash.events.Event):void
		{
			//adjust sizes and stuff
			isFullScreen = !isFullScreen;
			
			var newWidth:int = Starling.current.nativeStage.fullScreenWidth;
			var newHeight:int = Starling.current.nativeStage.fullScreenHeight;

			stage.stageWidth = newWidth;
			stage.stageHeight = newHeight;
			Starling.current.viewPort = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
			PipeJamGame.m_pipeJamGame.changeFullScreen(newWidth, newHeight);
		}
		
		private function onContextCreated(event:flash.events.Event):void
		{
			// set framerate to 30 in software mode
			
			if (Starling.context.driverInfo.toLowerCase().indexOf("software") != -1)
				Starling.current.nativeStage.frameRate = 30;
		}
		
		public function updateSize(e:flash.events.Event):void {
			// Compute max view port size
			var fullViewPort:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			const DES_WIDTH:Number = Constants.GameWidth;
			const DES_HEIGHT:Number = Constants.GameHeight;
			var scaleFactor:Number = Math.min(stage.stageWidth / DES_WIDTH, stage.stageHeight / DES_HEIGHT);
			
			// Compute ideal view port
			var viewPort:Rectangle = new Rectangle();
			viewPort.width = scaleFactor * DES_WIDTH;
			viewPort.height = scaleFactor * DES_HEIGHT;
			viewPort.x = 0.5 * (stage.stageWidth - viewPort.width);
			viewPort.y = 0.5 * (stage.stageHeight - viewPort.height);
			
			// Ensure the ideal view port is not larger than the max view port (could cause a crash otherwise)
			viewPort = viewPort.intersection(fullViewPort);
			
			// Set the updated view port
			Starling.current.viewPort = viewPort;
		}
		
		//call from JavaScript to load specific level
		public function loadLevelFromObjectID(levelID:String):void
		{
			GameFileHandler.loadLevelInfoFromObjectID(levelID, loadLevel);
		}
		
		protected function loadLevel(result:int, objVector:Vector.<Object>):void
		{
			PipeJamGame.levelInfo = new objVector[0];		
			PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
		}
		
		private function onReplayQuestDataLoaded(questData:QuestData, err:String = null):void
		{
			trace("Found " + (questData.actions ? questData.actions.length : 0) + " actions");
			if (err) trace("Error: " + err);
			if (questData && questData.startData && questData.startData.details &&
				questData.startData.details.hasOwnProperty(VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO) &&
				questData.startData.details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO] &&
				questData.startData.details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO].m_id) {
				var levelId:String = questData.startData.details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO].m_id as String;
				trace("Replaying levelId: " + levelId);
				loadLevelFromObjectID(levelId);
				return;
			}
			trace("Error: Couldn't find levelId for replay.");
		}
		
		public static function showReplayText(text:String):void
		{
			if (!m_replayText) return;
			m_replayText.text = text;
			m_replayText.setTextFormat(REPLAY_TEXT_FORMAT);
		}
	}
	
}