package gameScenes;

import networkGraph.*;
import networkGraph.Network;
import state.*;
import system.*;
import visualWorld.*;
import flash.utils.Dictionary;

class VerigameSystemGameScene extends GameScene
{
    public var m_worldXML : FastXML;
    public var m_network : Network;
    
    public var gameSystem : VerigameSystem = null;
    
    
    public function new(controller : SceneController)
    {
        super(controller);
    }
    
    override public function draw() : Void
    {
        gameSystem.draw();
    }
    
    override public function updateSize(newWidth : Float, newHeight : Float) : Void
    {
        scaleX = newWidth;
        scaleY = newHeight;
        gameSystem.scaleX = scaleX;
        gameSystem.scaleY = scaleY;
        
        draw();
    }
    
    public function backToMainMenu() : Void
    {
        loadNextScene(TrafficJamSceneController.LOAD_SPLASH_SCREEN);
    }
    
    override public function unloadScene() : Void
    {
        gameSystem.removeChildren();
        removeChildren();
        gameSystem.cleanUp();
        m_worldXML = null;
        gameSystem = null;
        m_network = null;
    }
    
    override public function loadScene() : Void
    {
        gameSystem.m_shouldCelebrate = true;
        gameSystem.setGameSize(false);
    }
    
    public function parseXML(world_xml : FastXML) : Void
    {
        m_worldXML = world_xml;
        var nextParseState : ParseXMLState = new ParseXMLState(world_xml);
        nextParseState.stateLoad();
    }
    
    public function setNetwork(network : Network) : Void
    {
        m_network = network;
        
        gameSystem = new VerigameSystem(0, 0, 1024, 768, this);
        updateSize(m_controller.scaleX, m_controller.scaleY);
        
        var new_world : World = gameSystem.createWorldFromNodes(network, m_worldXML);
        gameSystem.worlds.push(new_world);
        
        var boards_to_update : Array<BoardNodes> = gameSystem.worlds[0].simulateAllLevels();
        gameSystem.worlds[0].simulatorUpdateTroublePointsFS(PipeJamController.mainController.simulator, boards_to_update);
        
        gameSystem.loadNextWorld(null);
        
        if (gameSystem.worlds.length == 1)
        {
            gameSystem.current_level = gameSystem.current_world.levels[0];
        }
        
        var nextState : VerigameState = new VerigameState(gameSystem);
        nextState.stateLoad();
    }
    
    public function getActiveWorld() : World
    {
        return gameSystem.worlds[0];
    }
    
    public function updateLinkedPipes(p : Pipe, isWide : Bool) : Void
    {
        gameSystem.updateLinkedPipes(p, isWide);
    }
}
