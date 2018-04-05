package GameScenes
{
	//put switching scene logic here
	
	import NetworkGraph.Network;
	
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	
	public class TrafficJamSceneController extends SceneController
	{
		//load next scene actions
		static public var LOAD_NOTHING:uint = 0;
		static public var LOAD_SPLASH_SCREEN:uint = 1;
		static public var LOAD_TUTORIAL:uint = 2;
		static public var LOAD_GAME:uint = 3;
		static public var LOAD_END_SCREEN:uint = 4;
		static public var LOAD_REPLAY:uint = 5;
		
		//game types
		static public var TUTORIAL_ID:String = "tutorial";
		static public var REPLAY_ID:String = "replay";
		static public var GAME_ID:String = "game";
		
		
		public var m_worldXMLDictionary:Dictionary =  new Dictionary;
		
		/** true if the game is ready to switch. Switch will happen when xml file is loaded. */
		protected var m_switchToNextScene:Boolean = false;
		protected var m_nextScene:GameScene = null;
		protected var m_currentSceneType:uint;
		public var nextWorldIsFullView:Boolean = false;
		
		public function TrafficJamSceneController(_x:uint, _y:uint, _width:uint, _height:uint)
		{
			super(_x, _y, _width, _height);
		}
		
		override public function loadNextScene(nextScene:uint):void
		{
			m_switchToNextScene = true;
			
			switch(nextScene)
			{
				case TrafficJamSceneController.LOAD_SPLASH_SCREEN:
					unloadCurrentScene();
					loadSplashScreen();
					break;
				case TrafficJamSceneController.LOAD_TUTORIAL:
					loadGameIfReady(TrafficJamSceneController.TUTORIAL_ID);
					break;
				case TrafficJamSceneController.LOAD_GAME:
					loadGameIfReady(TrafficJamSceneController.GAME_ID);
					break;
				case TrafficJamSceneController.LOAD_REPLAY:
					loadGameIfReady(TrafficJamSceneController.REPLAY_ID);
					break;
				case TrafficJamSceneController.LOAD_END_SCREEN:
					unloadCurrentScene();
					loadEndScreen();
					break;
			}
		}

		public function loadSplashScreen():void
		{
			var newScene:TrafficJamSplashScreenScene = new TrafficJamSplashScreenScene(this);
			loadScene(newScene);
			m_switchToNextScene = false;
			newScene.draw();
		}
		
		/* 
			Before the game is ready to load, we need to have both:
				- loaded the xml
				- parsed the xml
			so do the next thing in line that is needed
		
			when done, actually switch the game in
		*/
		public function loadGameIfReady(nextGameType:String):void
		{			
			//if xml is ready, start the parsing of it. setNetwork is called when we are done.
			if(m_worldXMLDictionary[nextGameType] != null)
			{
				if(nextGameType == TrafficJamSceneController.TUTORIAL_ID)
				{
 					m_nextScene = new TutorialGameScene(this);
				}
				else if(nextGameType == TrafficJamSceneController.REPLAY_ID)
					m_nextScene = new VerigameSystemGameScene(this);
				else
					m_nextScene = new VerigameSystemGameScene(this);
				
				var xml:XML = m_worldXMLDictionary[nextGameType];
				m_worldXMLDictionary[nextGameType] = null;
				(m_nextScene as VerigameSystemGameScene).parseXML(xml);
			}
			else
				getNextWorld(nextGameType);
		}
		
		public function loadGame():void
		{
			unloadCurrentScene();
			m_currentSceneType = TrafficJamSceneController.LOAD_GAME;
			loadScene(m_nextScene);
			m_switchToNextScene = false;
		}
		
		public function loadEndScreen():void
		{
		}
		
		//This starts the loading process. setNextWorld is called when the file is loaded
		public function getNextWorld(nextGameType:String):void
		{
			FlexGlobals.topLevelApplication.loadGameFile(nextGameType);
		}
		
		//we've got the file, so load the game if we are ready to switch scenes
		public function setNextWorld(world_xml:XML, nextGameType:String):void
		{
			m_worldXMLDictionary[nextGameType] = world_xml;
			if(m_switchToNextScene)
				loadGameIfReady(nextGameType);
		}
		
		public function setNetwork(network:Network):void
		{
			if(m_nextScene is VerigameSystemGameScene)
			{
				(m_nextScene as VerigameSystemGameScene).setNetwork(network);
			
				loadGame();
			}
		}
		
		

	}
}