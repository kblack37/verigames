package scenes.splashscreen
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.utils.Timer;
		
	import display.NineSliceButton;
	
	import events.NavigationEvent;
	import events.ToolTipEvent;
	
	import networking.GameFileHandler;
	import networking.PlayerValidation;
	import networking.TutorialController;
	
	import scenes.BaseComponent;
	import scenes.game.PipeJamGameScene;
	import scenes.game.display.Level;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class SplashScreenMenuBox extends BaseComponent
	{
		protected var m_mainMenu:Sprite;
		
		//main screen buttons
		protected var play_button:NineSliceButton;
		protected var continue_tutorial_button:NineSliceButton;
		
		//These are visible in demo mode only (PipeJam3.RELEASE_BUILD == false)
		protected var tutorial_button:NineSliceButton;
		protected var demo_button:NineSliceButton;
		
		protected var loader:URLLoader;

		protected var m_parent:SplashScreenScene;
				
		
		public var inputInfo:flash.text.TextField;

		public function SplashScreenMenuBox(_parent:SplashScreenScene)
		{
			super();
			
			m_parent = _parent;
			buildMainMenu();
			
			addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
		}
		
		protected function addedToStage(event:starling.events.Event):void
		{
			addChild(m_mainMenu);
		}
		
		protected function removedFromStage(event:starling.events.Event):void
		{
			
		}
		
		private static const DEMO_ONLY:Boolean = false; // True to only show demo button
		protected function buildMainMenu():void
		{
			m_mainMenu = new Sprite();
			
			var BUTTON_CENTER_X:Number = m_parent.width/2; // center point to put Play and Log In buttons
			var TOP_BUTTON_Y:int = 205;
			
			play_button = ButtonFactory.getInstance().createDefaultButton("Play", 88, 32);
			play_button.x = BUTTON_CENTER_X - play_button.width / 2;
			play_button.y = TOP_BUTTON_Y + 15; //if only two buttons center them
			
			if(!isTutorialDone())
			{
				continue_tutorial_button = ButtonFactory.getInstance().createDefaultButton("Tutorial", 88, 32);
				continue_tutorial_button.addEventListener(starling.events.Event.TRIGGERED, onContinueTutorialTriggered);
				continue_tutorial_button.x = BUTTON_CENTER_X - continue_tutorial_button.width / 2;
				continue_tutorial_button.y = play_button.y + play_button.height + 5;
			}
			
			if(PipeJam3.RELEASE_BUILD)
			{			
				m_mainMenu.addChild(play_button);
				play_button.addEventListener(starling.events.Event.TRIGGERED, onPlayButtonTriggered);
				if(continue_tutorial_button)
					m_mainMenu.addChild(continue_tutorial_button);
			}
			else if (PipeJam3.TUTORIAL_DEMO)
			{
				if (!DEMO_ONLY) m_mainMenu.addChild(play_button);
				play_button.addEventListener(starling.events.Event.TRIGGERED, getNextPlayerLevelDebug);
			}
			else if (!PipeJam3.TUTORIAL_DEMO) //not release, not tutorial demo
			{
				if (!DEMO_ONLY) m_mainMenu.addChild(play_button);
				play_button.addEventListener(starling.events.Event.TRIGGERED, onPlayButtonTriggered);
			}
			
			if(!PipeJam3.RELEASE_BUILD && !PipeJam3.TUTORIAL_DEMO)
			{
				tutorial_button = ButtonFactory.getInstance().createDefaultButton("Tutorial", 56, 22);
				tutorial_button.addEventListener(starling.events.Event.TRIGGERED, onTutorialButtonTriggered);
				tutorial_button.x = Constants.GameWidth - tutorial_button.width - 4;
				tutorial_button.y = 110;
				if (!DEMO_ONLY) m_mainMenu.addChild(tutorial_button);
				
				if (DEMO_ONLY) {
					demo_button = ButtonFactory.getInstance().createDefaultButton("Demo", play_button.width, play_button.height);
					demo_button.addEventListener(starling.events.Event.TRIGGERED, onDemoButtonTriggered);
					demo_button.x = play_button.x;
					demo_button.y = play_button.y;
				} else {
					demo_button = ButtonFactory.getInstance().createDefaultButton("Demo", 56, 22);
					demo_button.addEventListener(starling.events.Event.TRIGGERED, onDemoButtonTriggered);
					demo_button.x = Constants.GameWidth - demo_button.width - 4;
					demo_button.y = tutorial_button.y + 30;
				}
				m_mainMenu.addChild(demo_button);
			}
		}
		
		protected function onPlayButtonTriggered(e:starling.events.Event):void
		{			
			if(!PlayerValidation.AuthorizationAttempted && PipeJam3.RELEASE_BUILD)
			{
				if(PipeJam3.PRODUCTION_BUILD)
					navigateToURL(new URLRequest("http://oauth.verigames.com/oauth2/authorize?response_type=code&redirect_uri=http://paradox.verigames.com/game/Paradox.html&client_id=" + PlayerValidation.production_client_id), "");
				else
					navigateToURL(new URLRequest("http://oauth.verigames.org/oauth2/authorize?response_type=code&redirect_uri=http://paradox.verigames.org/game/Paradox.html&client_id=" + PlayerValidation.staging_client_id), "");
			}
			else
				getNextRandomLevel(null);
		}
		
		protected function onContinueTutorialTriggered(e:starling.events.Event):void
		{
			loadTutorial();
		}
		
		private function onExitButtonTriggered():void
		{
			m_mainMenu.visible = true;
		}
		
		protected function onActivate(evt:flash.events.Event):void
		{
			Starling.current.nativeStage.removeEventListener(flash.events.Event.ACTIVATE, onActivate);
		}
		
		//serve either the next tutorial level, or give the full level select screen if done
		protected function getNextPlayerLevelDebug(e:starling.events.Event):void
		{
			//load tutorial file just in case
			onTutorialButtonTriggered(null);
		}
		
		protected function getNextRandomLevel(evt:TimerEvent):void
		{
			//check to see if we have the level list yet, if not, stall
			if(GameFileHandler.levelInfoVector == null)
			{
				var timer:Timer = new Timer(200, 1);
				timer.addEventListener(TimerEvent.TIMER, getNextRandomLevel);
				timer.start();
				return;
			}
			
			dispatchEvent(new NavigationEvent(NavigationEvent.GET_RANDOM_LEVEL));
		}
		
		protected function isTutorialDone():Boolean
		{
			//check on next level, returns -1 if 
			var isDone:Boolean = TutorialController.getTutorialController().isTutorialDone();
			
			if(isDone)
				return true;
			else
				return false;
		}
		
		protected function onTutorialButtonTriggered(e:starling.events.Event):void
		{
			//go to the beginning
			TutorialController.getTutorialController().resetTutorialStatus();
			
			loadTutorial();
			
		}
		
		protected function loadTutorial():void
		{
			PipeJamGameScene.inTutorial = true;
			PipeJamGameScene.inDemo = false;
			
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
		}
		
		protected static var fileNumber:int = 0;
		protected function onDemoButtonTriggered(e:starling.events.Event):void
		{
			PipeJamGameScene.inTutorial = false;
			PipeJamGameScene.inDemo = true;
			if(PipeJamGameScene.demoArray.length == fileNumber)
				fileNumber = 0;
			PipeJamGame.levelInfo = new Object;
			PipeJamGame.levelInfo.baseFileName = PipeJamGameScene.demoArray[fileNumber];
			fileNumber++;
			dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
		}
		
		public function showMainMenu(show:Boolean):void
		{
			m_mainMenu.visible = show;
		}
	}
}