package scenes.game.display;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.display.StageDisplayState;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import starling.animation.Juggler;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.textures.Texture;
import assets.AssetInterface;
import assets.AssetsAudio;
import audio.AudioManager;
import constraints.ConstraintGraph;
import constraints.events.ErrorEvent;
import dialogs.InGameMenuDialog;
import dialogs.SaveDialog;

import display.SoundButton;
import display.TextBubble;

import events.GameComponentEvent;
import events.MenuEvent;
import events.MiniMapEvent;
import events.NavigationEvent;
import events.UndoEvent;
import events.WidgetChangeEvent;

import networking.Achievements;

import networking.TutorialController;
import scenes.BaseComponent;
import scenes.game.components.GameControlPanel;
import scenes.game.components.GridViewPanel;
import scenes.game.components.MiniMap;
import scenes.game.PipeJamGameScene;
import starling.display.BlendMode;
import starling.display.Sprite;
import system.VerigameServerConstants;

/**
	 * World that contains levels that each contain boards that each contain pipes
	 */
class WorldCopy extends BaseComponent
{
    private var edgeSetGraphViewPanel : GridViewPanel;
    public var gameControlPanel : GameControlPanel;
    private var miniMap : MiniMap;
    private var inGameMenuBox : InGameMenuDialog;
    private var m_backgroundLayer : Sprite;
    private var m_foregroundLayer : Sprite;
    
    private var shareDialog : SaveDialog;
    
    /** All the levels in this world */
    public var levels : Array<Level> = new Array<Level>();
    
    /** Current level being played by the user */
    public var active_level : Level = null;
    
    //shim to make it start with a level until we get servers up
    private var firstLevel : Level = null;
    
    private var m_currentLevelNumber : Int;
    
    private var undoStack : Array<UndoEvent>;
    private var redoStack : Array<UndoEvent>;
    
    private var m_worldGraphDict : Dynamic;
    /** Original JSON used for this world */
    private var m_worldObj : Dynamic;
    private var m_layoutObj : Dynamic;
    private var m_assignmentsObj : Dynamic;
    
    public static var changingFullScreenState : Bool = false;
    
    public static var m_world : WorldCopy;
    private var m_activeToolTip : TextBubble;
    
    private static var m_numWidgetsClicked : Int = 0;
    
    public function new(_worldGraphDict : Dynamic, _worldObj : Dynamic, _layout : Dynamic, _assignments : Dynamic)
    {
        super();
        m_worldGraphDict = _worldGraphDict;
        m_worldObj = _worldObj;
        m_layoutObj = _layout;
        m_assignmentsObj = _assignments;
        
        m_world = this;
        undoStack = new Array<UndoEvent>();
        redoStack = new Array<UndoEvent>();
        
        var allLevels : Array<Dynamic> = Reflect.field(m_worldObj, "levels");
        if (allLevels == null)
        {
            allLevels = [m_worldObj];
        }
        trace("Creating World...");
        // create World
        for (level_index in 0...allLevels.length)
        {
            var levelObj : Dynamic = allLevels[level_index];
            var levelName : String = Reflect.field(levelObj, "id");
            var levelLayoutObj : Dynamic = findLevelFile(levelName, m_layoutObj);
            var levelAssignmentsObj : Dynamic = findLevelFile(levelName, m_assignmentsObj);
            // if we didn't find the level, assume this is a global constraints file
            if (levelAssignmentsObj == null)
            {
                levelAssignmentsObj = m_assignmentsObj;
            }
            
            var levelNameFound : String = levelName;
            if (!PipeJamGameScene.inTutorial && PipeJamGame.levelInfo && PipeJamGame.levelInfo.name)
            {
                levelNameFound = PipeJamGame.levelInfo.name;
            }
            if (!Reflect.hasField(m_worldGraphDict, levelName))
            {
                throw new Error("World level found without constraint graph:" + levelName);
            }
            var levelGraph : ConstraintGraph = try cast(Reflect.field(m_worldGraphDict, levelName), ConstraintGraph) catch(e:Dynamic) null;
            var my_level : Level = new Level(levelName, levelGraph, levelObj, levelLayoutObj, levelAssignmentsObj, levelNameFound);
            levels.push(my_level);
            
            if (firstLevel == null)
            {
                firstLevel = my_level;
            }
        }
        trace("Done creating World...");
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
	public function getInGameMenuBox(Void) : InGameMenuDialog {
		return inGameMenuBox;
	}
    public function getActiveLevel( Void) : Level {
		return active_level
	}
	public function getRedoStack(Void): Array<UndoEvent>{
		return redoStack;
	}
	public function getUndoStack(Void): Array<UndoEvent>{
		return undoStack;
	}
    private var m_initQueue : Array<Function> = new Array<Function>();
    private function onAddedToStage(event : Event) : Void
    {
        m_initQueue = new Array<Function>();
        m_initQueue.push(initBackground);
        m_initQueue.push(initGridViewPanel);
        m_initQueue.push(initForeground);
        m_initQueue.push(initGameControlPanel);
        m_initQueue.push(initMiniMap);
        m_initQueue.push(initTutorial);
        m_initQueue.push(initLevel);
        m_initQueue.push(initScoring);
        m_initQueue.push(initEventListeners);
        m_initQueue.push(initMusic);
        addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
    }
    
    private function onEnterFrame(evt : EnterFrameEvent) : Void
    {
        if (m_initQueue.length > 0)
        {
            var func : Function = m_initQueue.shift();
            func();
        }
    }
    
    private function initGridViewPanel() : Void
    {
        trace("Initializing GridViewPanel...");
        edgeSetGraphViewPanel = new GridViewPanel(this);
        addChild(edgeSetGraphViewPanel);
        trace("Done initializing GridViewPanel.");
    }
    
    private function initGameControlPanel() : Void
    {
        trace("Initializing GameControlPanel...");
        gameControlPanel = new GameControlPanel();
        gameControlPanel.y = GridViewPanel.HEIGHT - GameControlPanel.HEIGHT;
        if (edgeSetGraphViewPanel.atMaxZoom())
        {
            gameControlPanel.onMaxZoomReached();
        }
        else if (edgeSetGraphViewPanel.atMinZoom())
        {
            gameControlPanel.onMinZoomReached();
        }
        else
        {
            gameControlPanel.onZoomReset();
        }
        addChild(gameControlPanel);
        setHighScores();
        gameControlPanel.adjustSize(Starling.current.nativeStage.stageWidth, Starling.current.nativeStage.stageHeight);
        
        PipeJamGame.resetSoundButtonParent();
        
        trace("Done initializing GameControlPanel.");
    }
    
    private function initMiniMap() : Void
    {
        trace("Initializing Minimap....");
        miniMap = new MiniMap();
        miniMap.x = Constants.GameWidth - MiniMap.WIDTH;
        miniMap.y = MiniMap.HIDDEN_Y;
        edgeSetGraphViewPanel.addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, miniMap.onViewspaceChanged);
        miniMap.visible = false;
        addChild(miniMap);
        trace("Done initializing Minimap.");
    }
    
    private function initScoring() : Void
    {
        trace("Initializing score...");
        onWidgetChange();  //update score  
        trace("Done initializing score.");
    }
    
    private function initTutorial() : Void
    {
        trace("Initializing TutorialController...");
        if (PipeJamGameScene.inTutorial && levels != null && levels.length > 0)
        {
            var obj : Dynamic = PipeJamGame.levelInfo;
            var tutorialController : TutorialController = TutorialController.getTutorialController();
            var nextLevelQID : Int;
            if (obj == null)
            {
                obj = {};
                PipeJamGame.levelInfo = obj;
                obj.tutorialLevelID = Std.string(tutorialController.getFirstTutorialLevel());
                if (!tutorialController.isTutorialLevelCompleted(obj.tutorialLevelID))
                {
                    nextLevelQID = Std.int(obj.tutorialLevelID);
                }
                else
                {
                    nextLevelQID = tutorialController.getNextUnplayedTutorial();
                }
            }
            else
            {
                nextLevelQID = Std.int(obj.tutorialLevelID);
            }
            
            for (level in levels)
            {
                if (level.m_levelQID == Std.string(nextLevelQID))
                {
                    firstLevel = level;
                    obj.tutorialLevelID = Std.string(nextLevelQID);
                    break;
                }
            }
        }
        trace("Done initializing TutorialController.");
    }
    
    private function initLevel() : Void
    {
        trace("Initializing Level...");
        selectLevel(firstLevel);
        trace("Done initializing Level.");
    }
    
    public function initBackground(isWide : Bool = false, newWidth : Float = 0, newHeight : Float = 0) : Void
    {
        if (m_backgroundLayer == null)
        {
            m_backgroundLayer = new Sprite();
            addChildAt(m_backgroundLayer, 0);
        }
        
        m_backgroundLayer.removeChildren();
        var seed : Int = 0;
        if (active_level != null)
        {
            seed = active_level.levelGraph.qid;
            if (seed < 0)
            {
                seed = 0;
                for (c in 0...active_level.level_name.length)
                {
                    var code : Float = active_level.level_name.charCodeAt(c);
                    if (Math.isNaN(code))
                    {
                        seed += c;
                    }
                    else
                    {
                        seed += Std.int(Math.max(Math.round(code), 1));
                    }
                }
            }
        }
        var backMod : Int = seed % Constants.NUM_BACKGROUNDS;
        var background : Texture = null;
        var m_backgroundImage : Image = null;
        //if (Starling.current.nativeStage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
        //{
            background = AssetInterface.getTexture("img/Backgrounds", "FlowJamBackground" + backMod + ".jpg");
            m_backgroundImage = new Image(background);
            m_backgroundImage.width = 480;
            m_backgroundImage.height = 320;
        //}
        //else
        //{
            //background = AssetInterface.getTexture("img/Backgrounds", "FlowJamBackground" + backMod + ".jpg");
            //m_backgroundImage = new Image(background);
            //if (newWidth != 0)
            //{
                //m_backgroundImage.width = newWidth;
            //}
            //if (newHeight != 0)
            //{
                //m_backgroundImage.height = newHeight;
            //}
        //}
        
        //m_backgroundImage.blendMode = BlendMode.NONE;
        if (m_backgroundLayer != null)
        {
            m_backgroundLayer.addChild(m_backgroundImage);
        }
    }
    
    public function initForeground(seed : Int = 0, isWide : Bool = false) : Void
    {  //add border  
        
        
    }
    
    private function initEventListeners() : Void
    {
        trace("Initializing event listeners...");
        addEventListener(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, onWidgetChange);
        trace("Done initializing event listeners.");
    }
   
    private function initMusic() : Void
    {
        AudioManager.getInstance().reset();
        AudioManager.getInstance().playMusic(AssetsAudio.MUSIC_FIELD_SONG);
        trace("Playing music...");
    }
    
    public function changeFullScreen(newWidth : Float, newHeight : Float) : Void
    //backgrounds get scaled by the AssetInterface content scale factor, so change scale before setting a new background
    {
        
        if (Starling.current.nativeStage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
        {
            initBackground(true, newWidth, newHeight);
            m_backgroundLayer.scaleX /= newWidth / 480;
            m_backgroundLayer.scaleY /= newHeight / 320;
        }
        else
        {
            initBackground(false, newWidth, newHeight);
            m_backgroundLayer.scaleX = 1;
            m_backgroundLayer.scaleY = 1;
        }
        edgeSetGraphViewPanel.adjustSize(newWidth, newHeight);
        gameControlPanel.adjustSize(newWidth, newHeight);
    }
    
    private function switchToLevelSelect() : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
    }
    
    public function updateAssignments(currentLevelOnly : Bool = false) : Dynamic
    // TODO: think about this more, when do we update WORLD assignments? Real-time or in this method?
    {
        
        if (currentLevelOnly)
        {
            if (active_level != null)
            {
                return Reflect.field(Reflect.field(Reflect.field(m_worldObj, "levels"), Std.string(active_level.name)), "assignments");
            }
            return { };
        }
        return m_assignmentsObj;
    }

    public function onWidgetChange(evt : WidgetChangeEvent = null) : Void
    {
        var level_changed : Level = (evt != null) ? evt.level : active_level;
        if (level_changed == null)
        {
            return;
        }
        if (evt != null && evt.varChanged != null)
        {
            var nodeLayout : Dynamic = Reflect.field(active_level.nodeLayoutObjs, evt.varChanged.id);
            if (miniMap != null && nodeLayout != null)
            {
                miniMap.addWidget(nodeLayout);
            }
        }
        else if (miniMap != null)
        {
            miniMap.isDirty = true;
        }
        gameControlPanel.updateScore(level_changed, false);
        var oldScore : Int = level_changed.prevScore;
        var newScore : Int = level_changed.currentScore;
        if (evt != null)
        {
        // TODO: Fanfare for non-tutorial levels? We may want to encourage the players to keep optimizing
            
            if (newScore >= level_changed.getTargetScore())
            {
                edgeSetGraphViewPanel.displayContinueButton(true);
            }
            else
            {
                edgeSetGraphViewPanel.hideContinueButton();
            }
            if (oldScore != newScore && evt.pt != null)
            {
                var thisPt : Point = globalToLocal(evt.pt);
                TextPopup.popupText(this, thisPt, ((newScore > oldScore) ? "+" : "") + Std.string(newScore - oldScore), (newScore > oldScore) ? 0x99FF99 : 0xFF9999);
            }
            if (PipeJam3.logging != null)
            {
                var details : Dynamic = {};
                if (evt.varChanged != null)
                {
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_VAR_ID), evt.varChanged.id);
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_PROP_CHANGED), evt.prop);
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_PROP_VALUE), Std.string(evt.propValue));
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE_CHANGE), newScore - oldScore);
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), active_level.currentScore);
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_START_SCORE), active_level.startingScore);
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), active_level.m_targetScore);
                }
                PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_CHANGE_EDGESET_WIDTH, details, level_changed.getTimeMs());
            }
        }
        
        if (!PipeJamGameScene.inTutorial && evt != null)
        {
            m_numWidgetsClicked++;
            if (m_numWidgetsClicked == 1 || m_numWidgetsClicked == 50)
            {
                Achievements.checkAchievements(evt.type, m_numWidgetsClicked);
            }
            
            //beat the target score?
            if (newScore > level_changed.getTargetScore())
            {
                Achievements.checkAchievements(Achievements.BEAT_THE_TARGET_ID, 0);
            }
        }
    }
  
    public function getThumbnail(_maxwidth : Float, _maxheight : Float) : ByteArray
    {
        return edgeSetGraphViewPanel.getThumbnail(_maxwidth, _maxheight);
    }
	
	public function onErrorAdded(event : ErrorEvent) : Void
    {
        if (active_level != null)
        {
            var edgeLayout : Dynamic = Reflect.field(active_level.edgeLayoutObjs, event.constraintError.id);
            if (edgeLayout == null)
            {
                throw new Error("No layout found for constraint with error:" + event.constraintError.id);
            }
            if (miniMap != null)
            {
                miniMap.errorConstraintAdded(edgeLayout);
            }
        }
    }
    
    public function onErrorRemoved(event : ErrorEvent) : Void
    {
        if (active_level != null)
        {
            var edgeLayout : Dynamic = Reflect.field(active_level.edgeLayoutObjs, event.constraintError.id);
            if (edgeLayout == null)
            {
                throw new Error("No layout found for constraint with error:" + event.constraintError.id);
            }
            if (miniMap != null)
            {
                miniMap.errorRemoved(edgeLayout);
            }
        }
    }
    private function selectLevel(newLevel : Level, restart : Bool = false) : Void
    {
        if (newLevel == null)
        {
            return;
        }
        if (PipeJam3.logging != null)
        {
            var details : Dynamic;
            var qid : Int;
            if (active_level != null)
            {
                details = {};
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), active_level.original_level_name);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), active_level.currentScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_START_SCORE), active_level.startingScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), active_level.m_targetScore);
                qid = ((active_level.levelGraph.qid == -1)) ? VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD : active_level.levelGraph.qid;
                //if (PipeJamGame.levelInfo) {
                //	details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO] = PipeJamGame.levelInfo.createLevelObject();
                //}
                PipeJam3.logging.logQuestEnd(qid, details);
                active_level.removeEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
            }
            details = {};
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), newLevel.original_level_name);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), newLevel.currentScore);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_START_SCORE), newLevel.startingScore);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), newLevel.m_targetScore);
            if (PipeJamGame.levelInfo)
            {
                var jsonString : String = haxe.Json.stringify(PipeJamGame.levelInfo);
                var newObject : Dynamic = haxe.Json.parse(jsonString);
                Reflect.setField(details, Std.string(VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO), newObject);
            }
            qid = ((newLevel.levelGraph.qid == -1)) ? VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD : newLevel.levelGraph.qid;
            PipeJam3.logging.logQuestStart(qid, details);
        }
        if (restart)
        {
            if (edgeSetGraphViewPanel != null)
            {
                edgeSetGraphViewPanel.hideContinueButton();
            }
            newLevel.restart();
        }
        else if (active_level != null)
        {
            active_level.levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
            active_level.levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
            active_level.dispose();
        }
        
        if (m_activeToolTip != null)
        {
            m_activeToolTip.removeFromParent(true);
            m_activeToolTip = null;
        }
        
        active_level = newLevel;
        active_level.levelGraph.addEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
        active_level.levelGraph.addEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
        
        if (active_level.tutorialManager != null)
        {
            miniMap.visible = active_level.tutorialManager.getMiniMapShown();
        }
        else
        {
            miniMap.visible = true;
        }
        if (miniMap != null)
        {
            miniMap.setLevel(active_level);
        }
        
        if (inGameMenuBox != null)
        {
            inGameMenuBox.setActiveLevelName(active_level.original_level_name);
        }
        
        active_level.addEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
        active_level.initialize();
    }
    
    private function onLevelLoaded(evt : MenuEvent) : Void
    {
        active_level.removeEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
        trace("onWidgetChange()");
        onWidgetChange();
        trace("edgeSetGraphViewPanel.loadLevel()");
        edgeSetGraphViewPanel.setupLevel(active_level);
        edgeSetGraphViewPanel.loadLevel();
        if (edgeSetGraphViewPanel.atMaxZoom())
        {
            gameControlPanel.onMaxZoomReached();
        }
        else if (edgeSetGraphViewPanel.atMinZoom())
        {
            gameControlPanel.onMinZoomReached();
        }
        else
        {
            gameControlPanel.onZoomReset();
        }
        trace("Level.start()");
        active_level.start();
        trace("onScoreChange()");
        active_level.onScoreChange();
        active_level.resetBestScore();
        setHighScores();
        
        trace("gameControlPanel.newLevelSelected");
        gameControlPanel.newLevelSelected(active_level);
        miniMap.isDirty = true;
        trace("World.onLevelLoaded complete");
    }
    
    private function onRemovedFromStage() : Void
    {
        removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
        AudioManager.getInstance().reset();
        
        if (m_activeToolTip != null)
        {
            m_activeToolTip.removeFromParent(true);
            m_activeToolTip = null;
        }
       
        if (active_level != null)
        {
            removeChild(active_level, true);
        }
        m_worldObj = null;
        m_layoutObj = null;
    }
    
    public function findLevelFile(name : String, fileObj : Dynamic) : Dynamic
    {
        var levels : Array<Dynamic> = Reflect.field(fileObj, "levels");
        if (levels == null)
        {
            return fileObj;
        }  // if no levels, assume global file  
        for (i in 0...levels.length)
        {
            var levelName : String = Reflect.field(levels[i], "id");
            if (levelName == name)
            {
                return levels[i];
            }
        }
        return null;
    }
    
    public function hasDialogOpen() : Bool
    {
        if (inGameMenuBox != null && inGameMenuBox.visible)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function setHighScores() : Void
    {
        if (PipeJamGame.levelInfo != null && Reflect.hasField(PipeJamGame.levelInfo, "highScores"))
        {
            gameControlPanel.setHighScores(PipeJamGame.levelInfo.highScores);
        }
    }
    
    public function addSoundButton(m_sfxButton : SoundButton) : Void
    {
        gameControlPanel.addSoundButton(m_sfxButton);
    }
}

