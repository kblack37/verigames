package scripts;

import cgs.server.logging.IGameServerData;
import dialogs.InGameMenuDialog;
import engine.scripting.ScriptNode;
import engine.IGameEngine;
import events.NavigationEvent;
import flash.geom.Rectangle;
import haxe.Constraints.Function;
import networking.Achievements;
import networking.PlayerValidation;
import scenes.game.PipeJamGameScene;
import networking.TutorialController;
import scenes.game.components.GridViewPanel;
import scenes.game.display.Level;
import scenes.game.display.WorldCopy;
import starling.animation.Transitions;
import starling.display.Sprite;
import starling.animation.Juggler;
import scenes.game.components.GameControlPanel;
import state.FlowJamGameState;
import starling.core.Starling;
import state.LevelSelectState;
/**
 * ...
 * @author ...
 */
class WorldNavigationScript extends ScriptNode 
{
	private var edgeSetViewPanel : GridViewPanel;
	private var gameEngine : IGameEngine;
	private var active_level : Level;
	private var inGameMenuBox : InGameMenuDialog;
	private var world : WorldCopy;
	private var childToAdd : Sprite;
	
	private var m_currentLevelNumber : Int;
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		this.gameEngine = gameEngine;
		childToAdd = new Sprite();
		gameEngine.getSprite().addChild(childToAdd);
		world = cast (gameEngine.getStateMachine().getCurrentState(), FlowJamGameState).getWorld();
		
		inGameMenuBox = world.getInGameMenuBox();
		
		active_level = world.getActiveLevel();
		
		edgeSetViewPanel =  try cast(gameEngine.getUIComponent("gridViewPanel"), GridViewPanel) catch (e : Dynamic) null;
		gameEngine.addEventListener(NavigationEvent.SHOW_GAME_MENU, onShowGameMenuEvent);
        gameEngine.addEventListener(NavigationEvent.START_OVER, onLevelStartOver);
        gameEngine.addEventListener(NavigationEvent.SWITCH_TO_NEXT_LEVEL, onNextLevel);
	}
	private function onShowGameMenuEvent(evt : NavigationEvent) : Void
    {
        gameEngine.getSprite().dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, LevelSelectState));
        return;
		
        var gameControlPanel = try cast(gameEngine.getUIComponent("gameControlPanel"), GameControlPanel) catch (e : Dynamic) null;
        if (gameControlPanel == null)
        {
            return;
        }
        var bottomMenuY : Float = gameControlPanel.y + GameControlPanel.OVERLAP + 5;
        var juggler : Juggler = Starling.current.juggler;
        var animateUp : Bool = false;
        if (inGameMenuBox == null)
        {
            inGameMenuBox = new InGameMenuDialog();
            inGameMenuBox.x = 0;
            inGameMenuBox.y = bottomMenuY;
            var childIndex : Int = world.numChildren - 1;
            if (gameControlPanel != null && gameControlPanel.parent == world)
            {
                childIndex = world.getChildIndex(gameControlPanel);
                trace("childindex:" + childIndex);
            }
            else
            {
                trace("not");
            }
            childToAdd.addChildAt(inGameMenuBox, childIndex);
            //add clip rect so box seems to slide up out of the gameControlPanel
            inGameMenuBox.clipRect = new Rectangle(0, gameControlPanel.y + GameControlPanel.OVERLAP - inGameMenuBox.height, inGameMenuBox.width, inGameMenuBox.height);
            animateUp = true;
        }
        else if (inGameMenuBox.visible && !inGameMenuBox.animatingDown)
        {
            inGameMenuBox.onBackToGameButtonTriggered();
        }
        // animate up
        else
        {
            
            {
                animateUp = true;
            }
        }
        if (animateUp)
        {
            if (!inGameMenuBox.visible)
            {
                inGameMenuBox.y = bottomMenuY;
                inGameMenuBox.visible = true;
            }
            juggler.removeTweens(inGameMenuBox);
            inGameMenuBox.animatingDown = false;
            inGameMenuBox.animatingUp = true;
            juggler.tween(inGameMenuBox, 1.0, {
                        transition : Transitions.EASE_IN_OUT,
                        y : bottomMenuY - inGameMenuBox.height,
                        onComplete : function() : Void
                        {
                            if (inGameMenuBox != null)
                            {
                                inGameMenuBox.animatingUp = false;
                            }
                        }
                    });
        }
        if (active_level != null)
        {
            inGameMenuBox.setActiveLevelName(active_level.original_level_name);
        }
    }
	
    private function onLevelStartOver(evt : NavigationEvent) : Void
    {
        var level : Level = active_level;
        //forget that which we knew
        PipeJamGameScene.levelContinued = false;
        PipeJam3.m_savedCurrentLevel.data.assignmentUpdates = {};
        var callback : Function = 
        function() : Void
        {
			var edgeSetGraphViewPanel = try cast(gameEngine.getUIComponent("gridViewPanel"), GridViewPanel) catch (e : Dynamic) null;
            if (edgeSetGraphViewPanel != null)
            {
                edgeSetGraphViewPanel.removeFanfare();
                edgeSetGraphViewPanel.hideContinueButton(true);
            }
            level.restart();
        };
        
        gameEngine.getSprite().dispatchEvent(new NavigationEvent(NavigationEvent.FADE_SCREEN, null, false, callback));
    }
	
	private function onNextLevel(evt : NavigationEvent) : Void
    {
        var prevLevelNumber : Float = PipeJamGame.levelInfo.RaLevelID;
        if (PipeJamGameScene.inTutorial)
        {
            var tutorialController : TutorialController = TutorialController.getTutorialController();
            if (evt.menuShowing && active_level != null)
            {
            // If using in-menu "Next Level" debug button, mark the current level as complete in order to move on. Don't mark as completed
                
                tutorialController.addCompletedTutorial(active_level.m_tutorialTag, false);
            }
            
            //should check if we are from the level select screen...
            var tutorialsDone : Bool = tutorialController.isTutorialDone();
            //if there are no more unplayed levels, check next if we are in levelselect screen choice
            if (tutorialsDone == true && tutorialController.fromLevelSelectList)
            {
            //and if so, set to false, unless at the end of the tutorials
                
                var currentLevelId : Int = tutorialController.getNextUnplayedTutorial();
                if (currentLevelId != 0)
                {
                    tutorialsDone = false;
                }
            }
            
            //if this is the first time we've completed these, post the achievement, else just move on
            if (tutorialsDone)
            {
                if (Achievements.isAchievementNew(Achievements.TUTORIAL_FINISHED_ID) && PlayerValidation.playerLoggedIn)
                {
                    Achievements.addAchievement(Achievements.TUTORIAL_FINISHED_ID, Achievements.TUTORIAL_FINISHED_STRING);
                }
                else
                {
                    gameEngine.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, LevelSelectState));
                }
                return;
            }
            //get the next level to show, set the levelID, and currentLevelNumber
            else
            {
                
                var obj : Dynamic = PipeJamGame.levelInfo;
                obj.tutorialLevelID = Std.string(tutorialController.getNextUnplayedTutorial());
                
                m_currentLevelNumber = 0;
                for (level in world.levels)
                {
                    if (level.m_levelQID == obj.tutorialLevelID)
                    {
                        break;
                    }
                    
                    m_currentLevelNumber++;
                }
                m_currentLevelNumber = m_currentLevelNumber % world.levels.length;
            }
        }
        else
        {
            m_currentLevelNumber = (m_currentLevelNumber + 1) % world.levels.length;
            world.updateAssignments();
        }
        var callback : Function = 
        function() : Void
        {
            world.selectLevel(world.levels[m_currentLevelNumber], m_currentLevelNumber == prevLevelNumber);
        };
        gameEngine.dispatchEvent(new NavigationEvent(NavigationEvent.FADE_SCREEN, null, false, callback));
    }
	override public function dispose(){
		super.dispose();
		gameEngine.removeEventListener(NavigationEvent.SHOW_GAME_MENU, onShowGameMenuEvent);
        gameEngine.removeEventListener(NavigationEvent.START_OVER, onLevelStartOver);
        gameEngine.removeEventListener(NavigationEvent.SWITCH_TO_NEXT_LEVEL, onNextLevel);
	}
	
}