package gameScenes;

import networkGraph.Network;
import flash.utils.Dictionary;
import mx.core.FlexGlobals;

//put switching scene logic here
class TrafficJamSceneController extends SceneController
{
    //load next scene actions
    public static var LOAD_NOTHING : Int = 0;
    public static var LOAD_SPLASH_SCREEN : Int = 1;
    public static var LOAD_TUTORIAL : Int = 2;
    public static var LOAD_GAME : Int = 3;
    public static var LOAD_END_SCREEN : Int = 4;
    public static var LOAD_REPLAY : Int = 5;
    
    //game types
    public static var TUTORIAL_ID : String = "tutorial";
    public static var REPLAY_ID : String = "replay";
    public static var GAME_ID : String = "game";
    
    
    public var m_worldXMLDictionary : Dictionary = new Dictionary();
    
    /** true if the game is ready to switch. Switch will happen when xml file is loaded. */
    private var m_switchToNextScene : Bool = false;
    private var m_nextScene : GameScene = null;
    private var m_currentSceneType : Int;
    public var nextWorldIsFullView : Bool = false;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int)
    {
        super(_x, _y, _width, _height);
    }
    
    override public function loadNextScene(nextScene : Int) : Void
    {
        m_switchToNextScene = true;
        
        switch (nextScene)
        {
            case TrafficJamSceneController.LOAD_SPLASH_SCREEN:
                unloadCurrentScene();
                loadSplashScreen();
            case TrafficJamSceneController.LOAD_TUTORIAL:
                loadGameIfReady(TrafficJamSceneController.TUTORIAL_ID);
            case TrafficJamSceneController.LOAD_GAME:
                loadGameIfReady(TrafficJamSceneController.GAME_ID);
            case TrafficJamSceneController.LOAD_REPLAY:
                loadGameIfReady(TrafficJamSceneController.REPLAY_ID);
            case TrafficJamSceneController.LOAD_END_SCREEN:
                unloadCurrentScene();
                loadEndScreen();
        }
    }
    
    public function loadSplashScreen() : Void
    {
        var newScene : TrafficJamSplashScreenScene = new TrafficJamSplashScreenScene(this);
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
    public function loadGameIfReady(nextGameType : String) : Void
    //if xml is ready, start the parsing of it. setNetwork is called when we are done.
    {
        
        if (Reflect.field(m_worldXMLDictionary, nextGameType) != null)
        {
            if (nextGameType == TrafficJamSceneController.TUTORIAL_ID)
            {
                m_nextScene = new TutorialGameScene(this);
            }
            else if (nextGameType == TrafficJamSceneController.REPLAY_ID)
            {
                m_nextScene = new VerigameSystemGameScene(this);
            }
            else
            {
                m_nextScene = new VerigameSystemGameScene(this);
            }
            
            var xml : FastXML = Reflect.field(m_worldXMLDictionary, nextGameType);
            Reflect.setField(m_worldXMLDictionary, nextGameType, null);
            (try cast(m_nextScene, VerigameSystemGameScene) catch(e:Dynamic) null).parseXML(xml);
        }
        else
        {
            getNextWorld(nextGameType);
        }
    }
    
    public function loadGame() : Void
    {
        unloadCurrentScene();
        m_currentSceneType = TrafficJamSceneController.LOAD_GAME;
        loadScene(m_nextScene);
        m_switchToNextScene = false;
    }
    
    public function loadEndScreen() : Void
    {
    }
    
    //This starts the loading process. setNextWorld is called when the file is loaded
    public function getNextWorld(nextGameType : String) : Void
    {
        FlexGlobals.topLevelApplication.loadGameFile(nextGameType);
    }
    
    //we've got the file, so load the game if we are ready to switch scenes
    public function setNextWorld(world_xml : FastXML, nextGameType : String) : Void
    {
        Reflect.setField(m_worldXMLDictionary, nextGameType, world_xml);
        if (m_switchToNextScene)
        {
            loadGameIfReady(nextGameType);
        }
    }
    
    public function setNetwork(network : Network) : Void
    {
        if (Std.is(m_nextScene, VerigameSystemGameScene))
        {
            (try cast(m_nextScene, VerigameSystemGameScene) catch(e:Dynamic) null).setNetwork(network);
            
            loadGame();
        }
    }
}
