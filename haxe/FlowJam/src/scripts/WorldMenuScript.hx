package scripts;

import engine.IGameEngine;
import engine.scripting.ScriptNode;
import lime.graphics.opengl.ext.IMG_multisampled_render_to_texture;
import scenes.game.components.GridViewPanel;

import events.MenuEvent;

import dialogs.SaveDialog;
import dialogs.SimpleAlertDialog;
import dialogs.SubmitLevelDialog;
import scenes.game.display.Level;
import flash.utils.ByteArray;
import state.FlowJamGameState;
import networking.GameFileHandler;
import networking.Achievements;
import scenes.game.components.GameControlPanel;

import system.VerigameServerConstants;
/**
 * ...
 * @author Alex Davis
 */
class WorldMenuScript extends ScriptNode 
{
	private var gameEngine : IGameEngine;
	private var shareDialog : SaveDialog;
	private var active_level : Level;
	private var gameControlPanel : GameControlPanel;
	private var edgeSetGraphViewPanel : GridViewPanel
	//world menu events taht are not dialogs
	public function new(gameEngine: IGameEngine,id:String=null) 
	{
		super(id);
		this.gameEngine = gameEngine;
		active_level = cast (gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().getActiveLevel();
		gameControlPanel = cast (gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().gameControlPanel;
		edgeSetGraphViewPanel = try cast(gameEngine.getUIComponent("gridViewPanel"), GridViewPanel) catch (e : Dynamic) null;
		gameEngine.addEventListener(MenuEvent.SAVE_LEVEL, onPutLevelInDatabase);
        gameEngine.addEventListener(MenuEvent.SUBMIT_LEVEL, onPutLevelInDatabase);

        gameEngine.addEventListener(MenuEvent.SAVE_LAYOUT, onSaveLayoutFile);
  
        gameEngine.addEventListener(MenuEvent.LOAD_BEST_SCORE, loadBestScore);
        gameEngine.addEventListener(MenuEvent.LOAD_HIGH_SCORE, loadHighScore);
        
        gameEngine.addEventListener(MenuEvent.SET_NEW_LAYOUT, setNewLayout);
        gameEngine.addEventListener(MenuEvent.ZOOM_IN, onZoomIn);
        gameEngine.addEventListener(MenuEvent.ZOOM_OUT, onZoomOut);
        gameEngine.addEventListener(MenuEvent.RECENTER, onRecenter);
        
        gameEngine.addEventListener(MenuEvent.MAX_ZOOM_REACHED, onMaxZoomReached);
        gameEngine.addEventListener(MenuEvent.MIN_ZOOM_REACHED, onMinZoomReached);
        gameEngine.addEventListener(MenuEvent.RESET_ZOOM, onZoomReset);
        gameEngine.addEventListener(MenuEvent.SOLVE_SELECTION, onSolveSelection);
	}
	
	private function postSaveDialog(event : MenuEvent) : Void
    {
        if (shareDialog == null)
        {
            shareDialog = new SaveDialog(150, 100);
        }
        
        addChild(shareDialog);
    }
	
	private function onPutLevelInDatabase(event : MenuEvent) : Void
    //type:String, currentScore:int = event.type, currentScore
    {
        
        if (active_level != null)
        {
        //update and collect all xml, and then bundle, zip, and upload
            //probably updateAssignments will be in worldstate.
            var outputObj : Dynamic = cast (gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld().updateAssignments();
            active_level.updateLevelObj();
            
            var newAssignments : Dynamic = active_level.m_levelAssignmentsObj;
            
            var zip : ByteArray = active_level.zipJsonFile(newAssignments, "assignments");
            var zipEncodedString : String = active_level.encodeBytes(zip);
            
            GameFileHandler.submitLevel(zipEncodedString, event.type, PipeJamGame.SEPARATE_FILES);
            
            if (PipeJam3.logging != null)
            {
                var details : Dynamic = {};
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), active_level.original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), active_level.currentScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_START_SCORE), active_level.startingScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), active_level.m_targetScore);
                PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_SUBMIT_SCORE, details, active_level.getTimeMs());
            }
        }
        
        if (PipeJamGame.levelInfo.shareWithGroup == 1)
        {
            Achievements.checkAchievements(Achievements.SHARED_WITH_GROUP_ID, 0);
        }
    }

	
	private function onSaveLayoutFile(event : MenuEvent) : Void
    {
        if (active_level != null)
        {
            active_level.onSaveLayoutFile(event);
            if (PipeJam3.logging != null)
            {
                var details : Dynamic = {};
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), active_level.original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LAYOUT_NAME), event.data.name);
                PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_SAVE_LAYOUT, details, active_level.getTimeMs());
            }
        }
    }
	
	private function loadBestScore(event : MenuEvent) : Void
    {
        if (active_level != null)
        {
            active_level.loadBestScoringConfiguration();
        }
    }
	
	private function loadHighScore(event : MenuEvent) : Void
    {
        var highScoreAssignmentsID : String = PipeJamGame.levelInfo.highScores[0].assignmentsID;
        GameFileHandler.getFileByID(highScoreAssignmentsID, loadAssignmentsFile);
    }
	
	private function loadAssignmentsFile(assignmentsObject : Dynamic) : Void
    {
        if (active_level != null)
        {
            active_level.loadAssignmentsConfiguration(assignmentsObject);
        }
    }

	private function setNewLayout(event : MenuEvent) : Void
    {
        if (active_level != null && event.data.layoutFile)
        {
            active_level.setNewLayout(event.data.name, event.data.layoutFile, true);
            if (PipeJam3.logging != null)
            {
                var details : Dynamic = {};
                Reflect.setField(details, VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME, active_level.original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
                Reflect.setField(details, VerigameServerConstants.ACTION_PARAMETER_LAYOUT_NAME, Reflect.field(event.data.layoutFile, "id"));
                PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_LOAD_LAYOUT, details, active_level.getTimeMs());
            }
            PipeJamGame.levelInfo.layoutUpdated = true;
        }
    }
	
	private function onZoomIn(event : MenuEvent) : Void
    {
        edgeSetGraphViewPanel.zoomInDiscrete();
    }
    
    private function onZoomOut(event : MenuEvent) : Void
    {
        edgeSetGraphViewPanel.zoomOutDiscrete();
    }
    
    private function onRecenter(event : MenuEvent) : Void
    {
        edgeSetGraphViewPanel.recenter();
    }
    
    private function onMaxZoomReached(event : MenuEvent) : Void
    {
        if (gameControlPanel != null)
        {
            gameControlPanel.onMaxZoomReached();
        }
    }
    
    private function onMinZoomReached(event : MenuEvent) : Void
    {
        if (gameControlPanel != null)
        {
            gameControlPanel.onMinZoomReached();
        }
    }
    
    private function onZoomReset(event : MenuEvent) : Void
    {
        if (gameControlPanel != null)
        {
            gameControlPanel.onZoomReset();
        }
    }
	private function onSolveSelection() : Void
    {
        if (active_level != null)
        {
            active_level.solveSelection(solverUpdateCallback, solverDoneCallback);
        }
    }
	
	private function solverDoneCallback(errMsg : String) : Void
    {
        if (active_level != null)
        {
            active_level.solverDone(errMsg);
        }
        
        gameControlPanel.stopSolveAnimation();
    }
    
    private function solverUpdateCallback(vars : Array<Dynamic>, unsat_weight : Int) : Void
    //start on first update to make sure we are actually solving
    {
        
        if (active_level.m_inSolver)
        {
            gameControlPanel.startSolveAnimation();
            if (active_level != null)
            {
                active_level.solverUpdate(vars, unsat_weight);
            }
        }
    }
	
	public function override dispose(){
		super.dispose();
		gameEngine.removeEventListener(MenuEvent.SAVE_LEVEL, onPutLevelInDatabase);
        gameEngine.removeEventListener(MenuEvent.SUBMIT_LEVEL, onPutLevelInDatabase);

        gameEngine.removeEventListener(MenuEvent.SAVE_LAYOUT, onSaveLayoutFile);
  
        gameEngine.removeEventListener(MenuEvent.LOAD_BEST_SCORE, loadBestScore);
        gameEngine.removeEventListener(MenuEvent.LOAD_HIGH_SCORE, loadHighScore);
        
        gameEngine.removeEventListener(MenuEvent.SET_NEW_LAYOUT, setNewLayout);
        gameEngine.removeEventListener(MenuEvent.ZOOM_IN, onZoomIn);
        gameEngine.removeEventListener(MenuEvent.ZOOM_OUT, onZoomOut);
        gameEngine.removeEventListener(MenuEvent.RECENTER, onRecenter);
        
        gameEngine.removeEventListener(MenuEvent.MAX_ZOOM_REACHED, onMaxZoomReached);
        gameEngine.removeEventListener(MenuEvent.MIN_ZOOM_REACHED, onMinZoomReached);
        gameEngine.removeEventListener(MenuEvent.RESET_ZOOM, onZoomReset);
        gameEngine.removeEventListener(MenuEvent.SOLVE_SELECTION, onSolveSelection);
	}
}