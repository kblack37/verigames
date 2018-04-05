import events.*;
import gameScenes.*;
import gameScenes.TrafficJamSceneController;
import networkGraph.*;
import state.*;
import system.*;
import visualWorld.*;
import flash.utils.Dictionary;
import mx.core.FlexGlobals;

class PipeJamController
{
    public static var mainController : PipeJamController;
    
    public var sceneController : TrafficJamSceneController;
    public var simulator : Simulator;
    
    /** Version of the world XML input that this game is designed to read, fail any other versions */
    public static inline var WORLD_INPUT_XML_VERSION : String = "1";
    
    
    public function new()
    
    //get splash screen up, and then start loading xml{
        
        sceneController = new TrafficJamSceneController(0, 0, 1024, 768);
        FlexGlobals.topLevelApplication.addElement(sceneController);
        sceneController.loadNextScene(TrafficJamSceneController.LOAD_SPLASH_SCREEN);
    }
    
    //store downloaded xml in array in order and start next scene
    public function setNextWorld(world_xml : FastXML, name : String) : Void
    {
        sceneController.setNextWorld(world_xml, name);
    }
    
    
    public function updateSize(newWidth : Float, newHeight : Float) : Void
    {
        sceneController.updateSize(newWidth, newHeight);
    }
    
    public function tasksComplete(world_nodes : Network) : Void
    {
        sceneController.setNetwork(world_nodes);
    }
    
    /**
		 * Returns the board in this world of the given name
		 * @param	_name Name of the desired board
		 * @return The board with the name input to this function
		 */
    public function getBoardByName(scene : VerigameSystemGameScene, world : World, _name : String) : Board
    {
        if (_name == null)
        {
            return null;
        }
        if (_name.length == 0)
        {
            return null;
        }
        var new_name : String = _name;
        if (scene.m_network.obfuscator)
        {
            if (scene.m_network.obfuscator.boardNameExists(_name))
            {
                new_name = scene.m_network.obfuscator.getBoardName(_name, "");
            }
            else
            {
                return null;
            }
        }
        
        return world.worldBoardNameDictionary[new_name];
    }
    
    public function pipeChanged(e : PipeChangeEvent) : Void
    //change network as needed, resimulate, update visual side
    {
        
        var pipeBoard : Board = e.pipe.board;
        pipeBoard.m_boardNodes.simulated = false;
        pipeBoard.m_boardNodes.changed_since_last_sim = true;
        if (simulator != null)
        
        // Update all attributes within this edgeset{
            
            var edgeSet : EdgeSetRef = e.pipe.associated_edge.linked_edge_set;
            //pipe size hasn't changed yet, will in updateLinkedPipes
            if (e.m_pipeWidthChange)
            {
                (try cast(sceneController.currentScene, VerigameSystemGameScene) catch(e:Dynamic) null).m_network.updateEdgeSetWidth(edgeSet, !e.pipe.is_wide);
            }
            
            e.pipe.associated_edge.updateEdgeHasBuzz(e.pipe.has_buzzsaw);
            e.pipe.draw();  //redraw to get buzzsaw  
            //do the simulation after edges have been updated
            var currentWorld : World = e.pipe.board.level.world;
            var boards_to_update : Array<BoardNodes> = currentWorld.simulateLinkedPipes(e.pipe, simulator);
            currentWorld.simulatorUpdateTroublePointsFS(PipeJamController.mainController.simulator, boards_to_update);
            //pipe widths need to propagate
            if (e.m_pipeWidthChange)
            
            //store new width, as we will change the pipe width sometime in this call, and we want to remember what we are doing{
                
                var isWide : Bool = !e.pipe.is_wide;
                (try cast(sceneController.currentScene, VerigameSystemGameScene) catch(e:Dynamic) null).updateLinkedPipes(e.pipe, isWide);
            }
            
            (try cast(sceneController.currentScene, VerigameSystemGameScene) catch(e:Dynamic) null).gameSystem.game_control_panel.updateScore();
        }
    }
    
    public function resimulatePipe(pipe : Pipe) : Void
    {
        var currentWorld : World = (try cast(sceneController.currentScene, VerigameSystemGameScene) catch(e:Dynamic) null).getActiveWorld();
        var boards_to_update : Array<BoardNodes> = currentWorld.simulateLinkedPipes(pipe, simulator);
        currentWorld.simulatorUpdateTroublePointsFS(PipeJamController.mainController.simulator, boards_to_update);
        
        pipe.board.level.updateLinkedPipes(pipe, pipe.is_wide);
    }
}
