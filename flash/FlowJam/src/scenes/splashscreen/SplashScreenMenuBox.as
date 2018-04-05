package scenes.splashscreen
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import dialogs.SimpleAlertDialog;
	
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
		protected var return_to_last_level_button:NineSliceButton;
		protected var continue_tutorial_button:NineSliceButton;
		
		//These are visible in demo mode only (PipeJam3.RELEASE_BUILD == false)
		protected var tutorial_button:NineSliceButton;
		protected var demo_button:NineSliceButton;
		
		protected var loader:URLLoader;

		protected var m_parent:SplashScreenScene;
				
		
		public var inputInfo:flash.text.TextField;

		public function SplashScreenMenuBox(parent:SplashScreenScene)
		{
			super();
			
			parent = m_parent;
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
			
			const BUTTON_CENTER_X:Number = 252; // center point to put Play and Log In buttons
			const TOP_BUTTON_Y:int = 205;
			
			if(PipeJam3.m_savedCurrentLevel.data.hasOwnProperty("levelInfoID") && PipeJam3.m_savedCurrentLevel.data.levelInfoID != null)
			{
				return_to_last_level_button = ButtonFactory.getInstance().createDefaultButton("Continue", 88, 32);
				return_to_last_level_button.addEventListener(starling.events.Event.TRIGGERED, onReturnToLastTriggered);
				return_to_last_level_button.x = BUTTON_CENTER_X - return_to_last_level_button.width / 2;
				return_to_last_level_button.y = TOP_BUTTON_Y;
				
				play_button = ButtonFactory.getInstance().createDefaultButton("New", 88, 32);
			}
			else
				play_button = ButtonFactory.getInstance().createDefaultButton("Play", 88, 32);
			play_button.x = BUTTON_CENTER_X - play_button.width / 2;
			if(return_to_last_level_button != null)
				play_button.y = return_to_last_level_button.y + return_to_last_level_button.height + 5;
			else
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
				if(return_to_last_level_button)
					m_mainMenu.addChild(return_to_last_level_button);
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
		

		
		protected function onReturnToLastTriggered(e:starling.events.Event):void
		{
			if(!PlayerValidation.playerLoggedIn)
			{
				var dialogText:String = "You must be logged in to continue play.";
				var dialogWidth:Number = 160;
				var dialogHeight:Number = 60;
				var socialText:String = "";
				var alert:SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
				addChild(alert);
			}
			else
				getSavedLevel(null);
		}
		
		protected function onPlayButtonTriggered(e:starling.events.Event):void
		{			
			if(!PlayerValidation.playerLoggedIn)
			{
				var dialogText:String = "You must be logged in to continue play.";
				var dialogWidth:Number = 160;
				var dialogHeight:Number = 60;
				var socialText:String = "";
				var alert:SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
				addChild(alert);
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
		
		protected function onPlayerActivated(result:int, e:flash.events.Event):void
		{
			m_mainMenu.visible = false;
			getNextPlayerLevel();
		}
		
		//serve either the next tutorial level, or give the full level select screen if done
		protected function getNextPlayerLevelDebug(e:starling.events.Event):void
		{
			//load tutorial file just in case
			onTutorialButtonTriggered(null);
		}
		
		//serve either the next tutorial level, or give the full level select screen if done
		protected function getNextPlayerLevel():void
		{
			if(isTutorialDone() || !PipeJam3.initialLevelDisplay)
			{
				dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
				PipeJamGameScene.inTutorial = false;
			}
			else
				loadTutorial();
		}
		
		protected function getSavedLevel(evt:TimerEvent):void
		{
			dispatchEvent(new NavigationEvent(NavigationEvent.GET_SAVED_LEVEL));
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
			PipeJam3.initialLevelDisplay = false;
			
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