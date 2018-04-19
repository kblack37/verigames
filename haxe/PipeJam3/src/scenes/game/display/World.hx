package scenes.game.display;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;
import hints.HintController;
import server.MTurkAPI;
import assets.AssetInterface;
import assets.AssetsAudio;
import assets.AssetsFont;
import audio.AudioManager;
import constraints.ConstraintGraph;
import constraints.events.ErrorEvent;
import dialogs.SimpleAlertDialog;
import display.SoundButton;
import display.TextBubble;
import display.ToolTipText;
import events.MenuEvent;
import events.MiniMapEvent;
import events.MoveEvent;
import events.NavigationEvent;
import events.SelectionEvent;
import events.ToolTipEvent;
import events.UndoEvent;
import events.WidgetChangeEvent;
import networking.Achievements;
import networking.GameFileHandler;
import networking.PlayerValidation;
import networking.TutorialController;
import scenes.BaseComponent;
import scenes.game.PipeJamGameScene;
import scenes.game.components.GridViewPanel;
import scenes.game.components.MiniMap;
import scenes.game.components.SideControlPanel;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import system.VerigameServerConstants;

/**
	 * World that contains levels that each contain boards that each contain pipes
	 */
class World extends BaseComponent
{
    public var edgeSetGraphViewPanel : GridViewPanel;
    public var sideControlPanel : SideControlPanel;
    private var miniMap : MiniMap;
    private var m_backgroundLayer : Sprite;
    private var m_foregroundLayer : Sprite;
    private var m_splashLayer : Sprite;
    
    /** All the levels in this world */
    public var levels : Array<Level> = new Array<Level>();
    
    /** Current level being played by the user */
    public var active_level : Level = null;
    
    //shim to make it start with a level until we get servers up
    private var firstLevel : Level = null;
    
    private var m_currentLevelNumber : Int;
    public var currentPercent : Float;
    public var targetPercent : Float;
    
    private var undoStack : Array<UndoEvent>;
    private var redoStack : Array<UndoEvent>;
    
    private var m_worldGraphDict : Dictionary;
    /** Original JSON used for this world */
    private var m_worldObj : Dynamic;
    private var m_layoutObj : Dynamic;
    private var m_assignmentsObj : Dynamic;
    
    private var solvingImage : Image;
    
    public static var changingFullScreenState : Bool = false;
    
    // TODO: Circular dependency - remove this reference, children should send events to parents not depend on World
    public static var m_world : World;
    private var m_activeToolTip : TextBubble;
    private var m_confirmationCodeGiven : String = "";
    
    private var m_backgroundImage : Image;
    private var m_backgroundImageSolving : Image;
    
    private static var m_numWidgetsClicked : Int = 0;
    
    public static var altKeyDown : Bool;
    
    public var updateTimer1 : Timer;
    public var updateTimer2 : Timer;
    
    public function new(_worldGraphDict : Dictionary, _worldObj : Dynamic, _layout : Dynamic, _assignments : Dynamic)
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
        // create World
        for (level_index in 0...allLevels.length)
        {
            var levelObj : Dynamic = allLevels[level_index];
            var levelId : String = Reflect.field(levelObj, "id");
            var levelDisplayName : String = levelId;
            if (levelObj.exists("display_name") && !(PipeJam3.ASSET_SUFFIX == "Turk"))
            {
                levelDisplayName = Reflect.field(levelObj, "display_name");
            }
            var levelLayoutObj : Dynamic = findLevelFile(levelId, m_layoutObj);
            var levelAssignmentsObj : Dynamic = findLevelFile(levelId, m_assignmentsObj);
            // if we didn't find the level, assume this is a global constraints file
            if (levelAssignmentsObj == null)
            {
                levelAssignmentsObj = m_assignmentsObj;
            }
            
            var levelNameFound : String = levelId;
            if (!PipeJamGameScene.inTutorial && PipeJamGame.levelInfo && PipeJamGame.levelInfo.name)
            {
                levelNameFound = PipeJamGame.levelInfo.name;
            }
            if (!m_worldGraphDict.exists(Reflect.field(levelObj, "id")))
            {
                throw new Error("World level found without constraint graph:" + Reflect.field(levelObj, "id"));
            }
            var levelGraph : ConstraintGraph = try cast(Reflect.field(m_worldGraphDict, Std.string(Reflect.field(levelObj, "id"))), ConstraintGraph) catch(e:Dynamic) null;
            var my_level : Level = new Level(levelDisplayName, levelGraph, levelObj, levelLayoutObj, levelAssignmentsObj, levelNameFound);
            levels.push(my_level);
            
            if (firstLevel == null)
            {
                firstLevel = my_level;
            }
        }
        //trace("Done creating World...");
        addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(flash.events.Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    
    
    
    private var m_initQueue : Array<Function> = new Array<Function>();
    private function onAddedToStage(event : starling.events.Event) : Void
    //trace("Start Init Time", new Date().getTime() - PipeJamGameScene.startLoadTime);
    {
        
        m_initQueue = new Array<Function>();
        m_initQueue.push(initBackground);
        m_initQueue.push(initGridViewPanel);
        m_initQueue.push(initForeground);
        //m_initQueue.push(initGameControlPanel);
        m_initQueue.push(initSideControlPanel);
        m_initQueue.push(initMiniMap);
        m_initQueue.push(initTutorial);
        m_initQueue.push(initHintController);
        m_initQueue.push(initLevel);
        m_initQueue.push(initScoring);
        m_initQueue.push(initEventListeners);
        m_initQueue.push(initMusic);
        initUpdateTimers();
        addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
    }
    
    //used by stats, so leave public
    public static var loadTime : Float;
    private function onEnterFrame(evt : EnterFrameEvent) : Void
    {
        if (m_initQueue.length == 0)
        {
            removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
            loadTime = Date.now().getTime() - PipeJamGameScene.startLoadTime;
            //trace("Complete Time", loadTime);
            if (miniMap != null && !active_level.tutorialManager)
            {
                miniMap.centerMap();
            }
        }
        else if (m_initQueue.length > 0)
        {
            var time1 : Float = Date.now().getTime();
            var func : Function = m_initQueue.shift();
            
            Reflect.callMethod(null, func, []);
        }
    }
    
    private function initGridViewPanel() : Void
    //trace("Initializing GridViewPanel...");
    {
        
        edgeSetGraphViewPanel = new GridViewPanel(this);
        addChild(edgeSetGraphViewPanel);
    }
    
    public function showSolverState(running : Bool) : Void
    {
        if (running)
        {  //			edgeSetGraphViewPanel.filter = new ColorMatrixFilter;  
            //			(edgeSetGraphViewPanel.filter as ColorMatrixFilter).adjustHue(.22);
            //			gameControlPanel.startSolveAnimation();
            
        }
        else
        {  //			edgeSetGraphViewPanel.filter = null;  
            //			gameControlPanel.stopSolveAnimation();
            
        }
    }
    
    private function initSideControlPanel() : Void
    //trace("Initializing SideControlPanel...");
    {
        
        
        sideControlPanel = new SideControlPanel(Constants.RightPanelWidth, Starling.current.nativeStage.stageHeight);
        sideControlPanel.x = 480 - Constants.RightPanelWidth;
        addChild(sideControlPanel);
        dispatchEvent(new starling.events.Event(PipeJamGame.SET_SOUNDBUTTON_PARENT, true, sideControlPanel));
        
        addEventListener(SelectionEvent.BRUSH_CHANGED, changeBrush);
    }
    
    private function changeBrush(event : SelectionEvent) : Void
    {
        edgeSetGraphViewPanel.changeBrush(event.component.name);
    }
    
    private function initMiniMap() : Void
    //trace("Initializing Minimap....");
    {
        
        miniMap = new MiniMap();
        miniMap.x = Constants.GameWidth - MiniMap.WIDTH - 3;
        miniMap.y = MiniMap.TOP_Y;
        edgeSetGraphViewPanel.addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, miniMap.onViewspaceChanged);
        //	miniMap.visible = false;
        addChild(miniMap);
    }
    
    private function initScoring() : Void
    //trace("Initializing score...");
    {
        
        var time1 : Float = Date.now().getTime();
        onWidgetChange();
    }
    
    private function initTutorial() : Void
    //trace("Initializing TutorialController...");
    {
        
        var time1 : Float = Date.now().getTime();
        if (PipeJamGameScene.inTutorial && levels != null && levels.length > 0)
        {
            var obj : Dynamic;
            if (PipeJam3.TUTORIAL_DEMO)
            {
                obj = PipeJamGame.levelInfo;
            }
            var tutorialController : TutorialController = TutorialController.getTutorialController();
            var nextLevelQID : Int;
            if (obj == null)
            {
                obj = {};
                PipeJamGame.levelInfo = obj;
                obj.tutorialLevelID = Std.string(tutorialController.getFirstTutorialLevel());
                if (!tutorialController.isTutorialLevelCompleted(obj.tutorialLevelID))
                {
                    nextLevelQID = as3hx.Compat.parseInt(obj.tutorialLevelID);
                }
                else
                {
                    nextLevelQID = tutorialController.getNextUnplayedTutorial();
                }
            }
            else
            {
                nextLevelQID = as3hx.Compat.parseInt(obj.tutorialLevelID);
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
    }
    
    private function initHintController() : Void
    {
        if (edgeSetGraphViewPanel == null)
        {
            throw new Error("GridViewPanel hint layer has not been initialized! Make sure that initGridViewPanel is called before initHintController.");
        }
        HintController.getInstance().hintLayer = edgeSetGraphViewPanel.hintLayer;
    }
    
    private function initLevel() : Void
    //trace("Initializing Level...");
    {
        
        var time1 : Float = Date.now().getTime();
        selectLevel(firstLevel);
    }
    
    public function initBackground(isWide : Bool = false, newWidth : Float = 0, newHeight : Float = 0) : Void
    {
        if (m_backgroundLayer == null)
        {
            m_backgroundLayer = new starling.display.Sprite();
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
                        seed += Math.max(Math.round(code), 1);
                    }
                }
            }
        }
        var backMod : Int = as3hx.Compat.parseInt(seed % Constants.NUM_BACKGROUNDS);
        var background : Texture = AssetInterface.getTexture("Game", "ParadoxBackgroundClass");
        m_backgroundImage = new Image(background);
        var backgroundDark : Texture = AssetInterface.getTexture("Game", "ParadoxBackgroundDarkClass");
        m_backgroundImageSolving = new Image(backgroundDark);
        
        if (Starling.current.nativeStage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE)
        {
            m_backgroundImage.width = m_backgroundImageSolving.width = 480;
            m_backgroundImage.height = m_backgroundImageSolving.height = 320;
        }
        else
        {
            if (newWidth != 0)
            {
                m_backgroundImage.width = m_backgroundImageSolving.width = newWidth;
            }
            if (newHeight != 0)
            {
                m_backgroundImage.height = m_backgroundImageSolving.height = newHeight;
            }
        }
        
        m_backgroundImage.blendMode = m_backgroundImageSolving.blendMode = BlendMode.NONE;
        if (m_backgroundLayer != null)
        {
            m_backgroundLayer.addChild(m_backgroundImage);
        }
    }
    
    public function initForeground(seed : Int = 0, isWide : Bool = false) : Void
    {  //add border  
        
        
    }
    
    private function initEventListeners() : Void
    //trace("Initializing event listeners...");
    {
        
        addEventListener(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, onWidgetChange);
        addEventListener(MoveEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
        addEventListener(NavigationEvent.SHOW_GAME_MENU, onShowGameMenuEvent);
        addEventListener(NavigationEvent.SWITCH_TO_NEXT_LEVEL, onNextLevel);
        
        addEventListener(MenuEvent.SAVE_LEVEL, onPutLevelInDatabase);
        
        addEventListener(MenuEvent.POST_DIALOG, postDialog);
        addEventListener(MenuEvent.ACHIEVEMENT_ADDED, achievementAdded);
        addEventListener(MenuEvent.LOAD_BEST_SCORE, loadBestScore);
        addEventListener(MenuEvent.LOAD_HIGH_SCORE, loadHighScore);
        
        addEventListener(MenuEvent.ZOOM_IN, onZoomIn);
        addEventListener(MenuEvent.ZOOM_OUT, onZoomOut);
        
        addEventListener(MenuEvent.MAX_ZOOM_REACHED, onMaxZoomReached);
        addEventListener(MenuEvent.MIN_ZOOM_REACHED, onMinZoomReached);
        addEventListener(MenuEvent.RESET_ZOOM, onZoomReset);
        addEventListener(MenuEvent.SOLVE_SELECTION, onSolveSelection);
        addEventListener(MenuEvent.STOP_SOLVER, onStopSolving);
        
        addEventListener(MenuEvent.MOUSE_OVER_CONTROL_PANEL, overControlPanelHandler);
        
        addEventListener(MenuEvent.TURK_FINISH, onTurkFinishButtonPressed);
        
        addEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
        addEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
        addEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
        
        stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        addEventListener(UndoEvent.UNDO_EVENT, saveEvent);
        
        addEventListener(MoveEvent.MOVE_TO_POINT, onMoveToPointEvent);
        
        addEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
        addEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);
        
        addEventListener(SelectionEvent.NUM_SELECTED_NODES_CHANGED, onNumSelectedNodesChanged);
    }
    
    private function onTurkFinishButtonPressed(event : starling.events.Event) : Void
    {
        if (m_confirmationCodeGiven == null)
        {
            MTurkAPI.getInstance().onTaskComplete(displayConfirmationCodeScreen);
        }
        else
        {
            displayConfirmationCodeScreen(m_confirmationCodeGiven);
        }
    }
    
    private function overControlPanelHandler(event : starling.events.Event) : Void
    {
        edgeSetGraphViewPanel.mouseOverControlPanel();
    }
    
    public function loadAssignmentFile(assignmentID : String) : Void
    {
        GameFileHandler.loadFile(assignmentsFileLoadedCallback, GameFileHandler.USE_DATABASE, GameFileHandler.getFileURL + "&data_id=\"" + assignmentID + "\"");
    }
    
    public function assignmentsFileLoadedCallback(obj : Dynamic) : Void
    {
        this.active_level.loadAssignmentsConfiguration(obj);
        active_level.levelGraph.startingScore = active_level.currentScore;
    }
    
    private function onSolveSelection(event : MenuEvent) : Void
    //do this first as they might be removed by solveSelection if nothing relevant selected
    {
        
        
        if (active_level != null && active_level.selectedNodes)
        {
            if (event.data == GridViewPanel.SOLVER1_BRUSH || event.data == GridViewPanel.SOLVER2_BRUSH)
            {
            // Only allow autosolve if conflicts are selected, give user feedback if not
                
                var continueWithAutosolve : Bool = HintController.getInstance().checkAutosolveSelection(active_level);
                if (Level.debugSolver)
                {
                    continueWithAutosolve = true;
                }
                if (continueWithAutosolve)
                {
                    if (m_backgroundLayer != null)
                    {
                        m_backgroundLayer.addChild(m_backgroundImageSolving);
                    }
                    if (m_backgroundImage != null)
                    {
                        m_backgroundImage.removeFromParent();
                    }
                    
                    waitIconDisplayed = false;
                    
                    if (PipeJam3.logging)
                    {
                        var details : Dynamic = {};
                        //details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = newLevel.original_level_name;
                        if (PipeJamGame.levelInfo)
                        {
                            var jsonString : String = haxe.Json.stringify(PipeJamGame.levelInfo);
                            var newObject : Dynamic = haxe.Json.parse(jsonString);
                            Reflect.setField(details, Std.string(VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO), newObject);
                        }
                        var qid : Int = ((active_level.levelGraph.qid == -1)) ? VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD : active_level.levelGraph.qid;
                    }
                    
                    active_level.solveSelection(solverUpdateCallback, solverDoneCallback, Std.string(event.data));
                }
                else
                {
                    active_level.unselectAll();
                }
            }
            else if (event.data == GridViewPanel.NARROW_BRUSH)
            {
                active_level.onUseSelectionPressed(MenuEvent.MAKE_SELECTION_NARROW);
            }
            else if (event.data == GridViewPanel.WIDEN_BRUSH)
            {
                active_level.onUseSelectionPressed(MenuEvent.MAKE_SELECTION_WIDE);
            }
        }
    }
    
    private var waitIconDisplayed : Bool;
    private function solverUpdateCallback(vars : Array<Dynamic>, unsat_weight : Int) : Void
    //start on first update to make sure we are actually solving
    {
        
        if (active_level.m_inSolver)
        {
            if (waitIconDisplayed == false)
            {
            //busyAnimationMovieClip = new MovieClip(waitAnimationImages, 4);
                
                //addChild(busyAnimationMovieClip);
                //Starling.current.juggler.add(this.busyAnimationMovieClip);
                waitIconDisplayed = true;
            }
            if (active_level != null)
            {
                active_level.solverUpdate(vars, unsat_weight);
            }
        }
    }
    
    private function onStopSolving() : Void
    {
        solverDoneCallback("");
    }
    
    public function solverDoneCallback(errMsg : String) : Void
    {
        if (active_level != null)
        {
            active_level.solverDone(errMsg);
        }
        if (waitIconDisplayed)
        {
            removeChild(solvingImage);
        }
        if (busyAnimationMovieClip)
        {
            removeChild(busyAnimationMovieClip);
            Starling.current.juggler.remove(this.busyAnimationMovieClip);
            
            busyAnimationMovieClip.dispose();
            busyAnimationMovieClip = null;
        }
        if (m_backgroundLayer != null)
        {
            m_backgroundLayer.addChild(m_backgroundImage);
        }
        if (m_backgroundImageSolving != null)
        {
            m_backgroundImageSolving.removeFromParent();
        }
        showSolverState(false);
    }
    
    private function initMusic() : Void
    {
        AudioManager.getInstance().reset();
        AudioManager.getInstance().playMusic(AssetsAudio.MUSIC_FIELD_SONG);
    }
    
    private function initUpdateTimers() : Void
    //once every ten seconds, maybe?
    {
        
        if (PipeJam3.RELEASE_BUILD)
        {
			//don't annoy tim by having this update every 10 seconds
            
            {
                //start at 1 second to get quick initial info update into panel, then switch to 10 seconds afterwards
                updateTimer1 = new Timer(1000, 9);
                updateTimer1.addEventListener(TimerEvent.TIMER, updateHighScores);
                updateTimer1.start();
                
                updateTimer2 = new Timer(10000, 0);
                updateTimer2.addEventListener(TimerEvent.TIMER, updateHighScores);
                updateTimer2.start();
            }
        }
    }
    
    private function updateHighScores(event : TimerEvent) : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.UPDATE_HIGH_SCORES, null));
    }
    
    private function removeUpdateTimers() : Void
    {
        if (PipeJam3.RELEASE_BUILD)
        {
            if (updateTimer1 != null)
            {
                updateTimer1.stop();
            }
            if (updateTimer2 != null)
            {
                updateTimer2.stop();
            }
        }
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
    }
    
    public function onPutLevelInDatabase(event : MenuEvent) : Void
    //type:String, currentScore:int = event.type, currentScore
    {
        
        if (active_level != null)
        {
        //update and collect all xml, and then bundle, zip, and upload
            
            var outputObj : Dynamic = updateAssignments();
            active_level.updateLevelObj();
            
            var newAssignments : Dynamic = active_level.m_levelAssignmentsObj;
            
            var zip : ByteArray = active_level.zipJsonFile(newAssignments, "assignments");
            var zipEncodedString : String = active_level.encodeBytes(zip);
            
            GameFileHandler.submitLevel(zipEncodedString, event.type, PipeJamGame.SEPARATE_FILES);
            
            if (PipeJam3.logging)
            {
                var details : Dynamic = {};
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), active_level.original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), active_level.currentScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_START_SCORE), active_level.startingScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), active_level.m_targetScore);
                PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_SUBMIT_SCORE, details, active_level.getTimeMs());
            }
        }
    }
    
    public function postDialog(event : MenuEvent) : Void
    {
        var dialogText : String = Std.string(event.data);
        var dialogWidth : Float = 160;
        var dialogHeight : Float = 60;
        
        var dialog : SimpleAlertDialog = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, null, null);
        addChild(dialog);
    }
    
    public function achievementAdded(event : MenuEvent) : Void
    {
        var achievement : Achievements = try cast(event.data, Achievements) catch(e:Dynamic) null;
        var dialogText : String = achievement.m_message;
        var achievementID : String = achievement.m_id;
        var dialogWidth : Float = 160;
        var dialogHeight : Float = 60;
        var socialText : String = "";
        
        var alert : SimpleAlertDialog;
        if (achievementID == Achievements.TUTORIAL_FINISHED_ID)
        {
            alert = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, onShowGameMenuEvent);
        }
        else
        {
            alert = new SimpleAlertDialog(dialogText, dialogWidth, dialogHeight, socialText, null);
        }
        addChild(alert);
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
    
    private function switchToLevelSelect() : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "LevelSelectScene"));
    }
    
    private function onShowGameMenuEvent(evt : NavigationEvent = null) : Void
    {
        dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
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
    
    public function onZoomIn(event : MenuEvent) : Void
    {
        edgeSetGraphViewPanel.zoomInDiscrete();
    }
    
    public function onZoomOut(event : MenuEvent) : Void
    {
        edgeSetGraphViewPanel.zoomOutDiscrete();
    }
    
    public function onMaxZoomReached(event : events.MenuEvent) : Void
    {
        if (sideControlPanel != null)
        {
            sideControlPanel.onMaxZoomReached();
        }
    }
    
    public function onMinZoomReached(event : events.MenuEvent) : Void
    {
        if (sideControlPanel != null)
        {
            sideControlPanel.onMinZoomReached();
        }
    }
    
    public function onZoomReset(event : events.MenuEvent) : Void
    {
        if (sideControlPanel != null)
        {
            sideControlPanel.onZoomReset();
        }
    }
    
    public function onErrorsMoved(event : MiniMapEvent) : Void
    {
        if (miniMap != null)
        {
            miniMap.isDirty = true;
        }
    }
    
    public function onLevelResized(event : MiniMapEvent) : Void
    {
        if (miniMap != null)
        {
            miniMap.isDirty = true;
        }
    }
    
    public function onViewspaceChanged(event : MiniMapEvent) : Void
    {
        miniMap.onViewspaceChanged(event);
    }
    
    private function displayConfirmationCodeScreen(confCode : String) : Void
    {
        var nativeText : TextField = new TextField();
        nativeText.backgroundColor = 0xFFFFFF;
        nativeText.background = true;
        nativeText.selectable = true;
        nativeText.width = Constants.GameWidth;
        nativeText.height = Constants.GameHeight;
        if (confCode == "0")
        {
            active_level.targetScoreReached = false;
            nativeText.text = "This task was expected to take at least 2 minutes.\n\nThis page will update automatically in 30 seconds to retry the confirmation code.";
            Starling.current.juggler.delayCall(onWidgetChange, 30, new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, active_level, null));
        }
        else
        {
            m_confirmationCodeGiven = confCode;
            nativeText.text = "Thanks for playing!\n\nTask complete.\nYour confirmation code is:\n\n" + confCode;
        }
        nativeText.wordWrap = true;
        nativeText.setTextFormat(new TextFormat(null, 32, 0x0, null, null, null, null, null, TextFormatAlign.CENTER));
        Starling.current.nativeOverlay.addChild(nativeText);
    }
    
    public function onWidgetChange(evt : WidgetChangeEvent = null) : Void
    {
        var level_changed : Level = (evt != null) ? ((evt.level) ? evt.level : active_level) : active_level;
        if (level_changed != active_level)
        {
            return;
        }
        
        if (miniMap != null)
        {
            miniMap.isDirty = true;
            miniMap.imageIsDirty = true;
        }
        
        var oldScore : Int = active_level.prevScore;
        var newScore : Int = active_level.currentScore;
        if (evt != null)
        {
        // TODO: Fanfare for non-tutorial levels? We may want to encourage the players to keep optimizing
            
            if (newScore >= active_level.getTargetScore())
            {
                if (!active_level.targetScoreReached)
                {
                    active_level.targetScoreReached = true;
                    //if(active_level.m_inSolver)
                    //	solverDoneCallback("");
                    if (PipeJam3.ASSET_SUFFIX == "Turk" && active_level != null && (!PipeJamGameScene.inTutorial || (active_level.m_levelQID == "2006")))
                    {
                        if (m_confirmationCodeGiven == null)
                        {
                            MTurkAPI.getInstance().onTaskComplete(displayConfirmationCodeScreen);
                        }
                        else
                        {
                            displayConfirmationCodeScreen(m_confirmationCodeGiven);
                        }
                    }
                    else
                    {
                        var continueDelay : Float = 0;
                        var showFanfare : Bool = true;
                        if (active_level != null && active_level.tutorialManager)
                        {
                            continueDelay = active_level.tutorialManager.continueButtonDelay();
                            showFanfare = active_level.tutorialManager.showFanfare();
                        }
                        Starling.current.juggler.delayCall(edgeSetGraphViewPanel.displayContinueButton, continueDelay, true, showFanfare);
                    }
                }
            }
            else
            {
                edgeSetGraphViewPanel.hideContinueButton();
            }
            if (oldScore != newScore && evt.pt != null)
            {
                var thisPt : Point = globalToLocal(evt.pt);
                TextPopup.popupText(try cast(evt.target, DisplayObjectContainer) catch(e:Dynamic) null, thisPt, ((newScore > oldScore) ? "+" : "") + Std.string(newScore - oldScore), (newScore > oldScore) ? 0x008000 : 0x800000);
            }
            if (PipeJam3.logging)
            {
                var details : Dynamic = {};
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE_CHANGE), newScore - oldScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), active_level.currentScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_START_SCORE), active_level.startingScore);
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), active_level.m_targetScore);
            }
        }
        currentPercent = sideControlPanel.updateScore(active_level, false);
        targetPercent = sideControlPanel.targetPercent(active_level);
        
        if (currentPercent >= 100)
        {
            if (!PipeJamGameScene.inTutorial && PlayerValidation.playerActivity != null)
            {
                if (PipeJam3.RELEASE_BUILD)
                {
                    GameFileHandler.reportScore();
                    var levelPlayedArray : Array<Dynamic> = PlayerValidation.playerActivity["completed_boards"];
                    edgeSetGraphViewPanel.showProgressDialog(levelPlayedArray.length);
                }
            }
        }
        if (!PipeJamGameScene.inTutorial && evt != null)
        {
        //beat the target score?
            
            if (newScore > active_level.getTargetScore())
            {
                Achievements.checkAchievements(Achievements.BEAT_THE_TARGET_ID, 0);
            }
            
            Achievements.checkAchievements(Achievements.CHECK_SCORE, newScore - active_level.startingScore);
        }
    }
    
    private function onCenterOnComponentEvent(evt : MoveEvent) : Void
    {
        var component : Dynamic = evt.component;
        if (component != null)
        {
            edgeSetGraphViewPanel.centerOnComponent(component);
        }
    }
    
    private function onNextLevel(evt : NavigationEvent) : Void
    {
        var prevLevelNumber : Float = as3hx.Compat.parseInt(PipeJamGame.levelInfo.RaLevelID);
        if (PipeJamGameScene.inTutorial)
        {
            var tutorialController : TutorialController = TutorialController.getTutorialController();
            if (active_level != null)
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
                if (!Achievements.checkAchievements(Achievements.TUTORIAL_FINISHED_ID))
                {
                    if (PipeJam3.TUTORIAL_DEMO)
                    {
                        switchToLevelSelect();
                    }
                    else
                    {
                        onShowGameMenuEvent();
                    }
                }
                return;
            }
            else if (tutorialController.isLastTutorialLevel())
            {
                if (PipeJam3.TUTORIAL_DEMO)
                {
                    switchToLevelSelect();
                }
                else
                {
                    onShowGameMenuEvent();
                }
                return;
            }
            //get the next level to show, set the levelID, and currentLevelNumber
            else
            {
                
                var obj : Dynamic = PipeJamGame.levelInfo;
                obj.tutorialLevelID = Std.string(tutorialController.getNextUnplayedTutorial());
                
                m_currentLevelNumber = 0;
                for (level in levels)
                {
                    if (level.m_levelQID == obj.tutorialLevelID)
                    {
                        break;
                    }
                    
                    m_currentLevelNumber++;
                }
                m_currentLevelNumber = as3hx.Compat.parseInt(m_currentLevelNumber % levels.length);
            }
        }
        else
        {
            m_currentLevelNumber = as3hx.Compat.parseInt((m_currentLevelNumber + 1) % levels.length);
            updateAssignments();
        }
        var callback : Function = 
        function() : Void
        {
            selectLevel(levels[m_currentLevelNumber]);
        };
        dispatchEvent(new NavigationEvent(NavigationEvent.FADE_SCREEN, "", null, callback));
    }
    
    public function onErrorAdded(event : ErrorEvent) : Void
    {
        if (active_level != null)
        {  //if (miniMap) miniMap.errorConstraintAdded(edgeLayout);  
            
        }
    }
    
    public function onErrorRemoved(event : ErrorEvent) : Void
    {
        if (active_level != null)
        {  //if (miniMap) miniMap.errorRemoved(edgeLayout);  
            
        }
    }
    
    private function onMoveToPointEvent(evt : MoveEvent) : Void
    {
        edgeSetGraphViewPanel.moveToPoint(evt.startLoc);
    }
    
    private function saveEvent(evt : UndoEvent) : Void
    {
        if (evt.eventsToUndo.length == 0)
        {
            return;
        }
        //sometimes we need to remove the last event to add a complex event that includes that one
        //addToLastSimilar adds to the last event if they are of the same type (i.e. successive mouse wheel events should all undo at the same time)
        //addToLast adds to last event in any case (undo move node event also should put edges back where they were)
        var lastEvent : UndoEvent;
        if (evt.addToSimilar)
        {
            lastEvent = undoStack.pop();
            if (lastEvent != null && (lastEvent.eventsToUndo.length > 0))
            {
                if (lastEvent.eventsToUndo[0].type == evt.eventsToUndo[0].type)
                {
                // Add these to end of lastEvent's list of events to undo
                    
                    lastEvent.eventsToUndo = lastEvent.eventsToUndo.concat(evt.eventsToUndo);
                }
                //no match, just push, adding back lastEvent also
                else
                {
                    
                    {
                        undoStack.push(lastEvent);
                        undoStack.push(evt);
                    }
                }
            }
            else
            {
                undoStack.push(evt);
            }
        }
        else if (evt.addToLast)
        {
            lastEvent = undoStack.pop();
            if (lastEvent != null)
            {
            // Add these to end of lastEvent's list of events to undo
                
                lastEvent.eventsToUndo = lastEvent.eventsToUndo.concat(evt.eventsToUndo);
            }
            else
            {
                undoStack.push(evt);
            }
        }
        else
        {
            undoStack.push(evt);
        }
        //when we build on the undoStack, clear out the redoStack
        redoStack = new Array<UndoEvent>();
    }
    public function handleKeyDown(event : starling.events.KeyboardEvent) : Void
    {
        if (event.keyCode == Keyboard.S)
        {
            altKeyDown = true;
        }
    }
    
    public function handleKeyUp(event : starling.events.KeyboardEvent) : Void
    {
        if (event.keyCode == Keyboard.S)
        {
            altKeyDown = false;
        }
        
        if (event.ctrlKey)
        {
            var _sw2_ = (event.keyCode);            

            switch (_sw2_)
            {
                case 90, 82, 89, 76:

                    switch (_sw2_)
                    {case 90:  //'z'  
                        {
                            if ((undoStack.length > 0) && !PipeJam3.RELEASE_BUILD)
                            {
                            //high risk item, don't allow undo/redo until well tested
                                
                                {
                                    var undoDataEvent : UndoEvent = undoStack.pop();
                                    handleUndoRedoEvent(undoDataEvent, true);
                                }
                            }
                            break;
                        }
                    }

                    switch (_sw2_)
                    {case 89:  //'y'  
                        {
                            if ((redoStack.length > 0) && !PipeJam3.RELEASE_BUILD)
                            {
                            //high risk item, don't allow undo/redo until well tested
                                
                                {
                                    var redoDataEvent : UndoEvent = redoStack.pop();
                                    handleUndoRedoEvent(redoDataEvent, false);
                                }
                            }
                            break;
                        }
                    }  //'l' for copy layout  
                    if (this.active_level != null)
                    {
                    // && !PipeJam3.RELEASE_BUILD)
                        
                        {
                            System.setClipboard(haxe.Json.stringify(active_level.m_levelLayoutObjWrapper));
                        }
                    }
                case 66:  //'b' for load Best scoring config  
                if (this.active_level != null)
                {
                // && !PipeJam3.RELEASE_BUILD)
                    
                    {
                        active_level.loadBestScoringConfiguration();
                    }
                }
                case 67:  //'c' for copy constraints  
                if (this.active_level != null && !PipeJam3.RELEASE_BUILD)
                {
                    active_level.updateAssignmentsObj();
                    System.setClipboard(haxe.Json.stringify(active_level.m_levelAssignmentsObj));
                }
                case 65:  //'a' for copy of ALL (world)  
                if (this.active_level != null && !PipeJam3.RELEASE_BUILD)
                {
                    var worldObj : Dynamic = updateAssignments();
                    System.setClipboard(haxe.Json.stringify(worldObj));
                }
                case 88:  //'x' for copy of level  
                if (this.active_level != null && !PipeJam3.RELEASE_BUILD)
                {
                    var levelObj : Dynamic = updateAssignments(true);
                    System.setClipboard(haxe.Json.stringify(levelObj));
                }
            }
        }
    }
    
    private function handleUndoRedoEvent(event : UndoEvent, isUndo : Bool) : Void
    //added newest at the end, so start at the end
    {
        
        var i : Int = as3hx.Compat.parseInt(event.eventsToUndo.length - 1);
        while (i >= 0)
        {
            var eventObj : starling.events.Event = event.eventsToUndo[i];
            handleUndoRedoEventObject(eventObj, isUndo, event.levelEvent, event.component);
            i--;
        }
        if (isUndo)
        {
            redoStack.push(event);
        }
        else
        {
            undoStack.push(event);
        }
    }
    
    private function handleUndoRedoEventObject(evt : starling.events.Event, isUndo : Bool, levelEvent : Bool, component : BaseComponent) : Void
    {
        if (active_level != null && levelEvent)
        {
            active_level.handleUndoEvent(evt, isUndo);
        }
        else if (component != null)
        {
            component.handleUndoEvent(evt, isUndo);
        }
    }
    
    private function selectLevel(newLevel : Level) : Void
    {
        if (newLevel == null)
        {
            return;
        }
        if (PipeJam3.logging)
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
        if (active_level != null)
        {
            active_level.levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
            active_level.levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
            active_level.dispose();
        }
        if (m_splashLayer != null)
        {
            m_splashLayer.removeChildren(0, -1, true);
            m_splashLayer.removeFromParent();
        }
        
        if (m_activeToolTip != null)
        {
            m_activeToolTip.removeFromParent(true);
            m_activeToolTip = null;
        }
        
        active_level = newLevel;
        
        if (miniMap != null)
        {
            miniMap.imageIsDirty = true;
        }
        
        if (active_level.tutorialManager)
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
        
        active_level.addEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
        active_level.initialize();
        showVisibleBrushes();
        showCurrentBrush();
        var brushesToEmphasize : Int = active_level.emphasizeBrushes();
        sideControlPanel.emphasizeBrushes(brushesToEmphasize);
    }
    
    private function onLevelLoaded(evt : MenuEvent) : Void
    {
        active_level.removeEventListener(MenuEvent.LEVEL_LOADED, onLevelLoaded);
        //called later by initScoring
        //onWidgetChange();
        var levelSplash : Image;
        if (active_level.tutorialManager)
        {
            levelSplash = active_level.tutorialManager.getSplashScreen();
        }
        if (levelSplash != null)
        {
            if (m_splashLayer == null)
            {
                m_splashLayer = new Sprite();
                m_splashLayer.addEventListener(TouchEvent.TOUCH, onTouchSplashScreen);
            }
            else
            {
                m_splashLayer.removeChildren(0, -1, true);
            }
            var backQ : Quad = new Quad(Constants.GameWidth, Constants.GameHeight, 0x0);
            backQ.alpha = 0.9;
            m_splashLayer.addChild(backQ);
            levelSplash.x = 0.5 * (Constants.GameWidth - levelSplash.width);
            levelSplash.y = 0.5 * (Constants.GameHeight - levelSplash.height);
            m_splashLayer.addChild(levelSplash);
            var splashText : TextFieldWrapper = TextFactory.getInstance().createDefaultTextField("Click anywhere to continue...", Constants.GameWidth, 12, 8, Constants.GOLD);
            splashText.y = Constants.GameHeight - 12;
            m_splashLayer.addChild(splashText);
            addChild(m_splashLayer);
        }
        
        //trace("edgeSetGraphViewPanel.loadLevel()");
        edgeSetGraphViewPanel.setupLevel(active_level);
        if (edgeSetGraphViewPanel.atMaxZoom())
        {
            sideControlPanel.onMaxZoomReached();
        }
        else if (edgeSetGraphViewPanel.atMinZoom())
        {
            sideControlPanel.onMinZoomReached();
        }
        else
        {
            sideControlPanel.onZoomReset();
        }
        
        //trace("onScoreChange()");
        active_level.onScoreChange();
        active_level.resetBestScore();
        setHighScores();
        
        //trace("sideControlPanel.newLevelSelected");
        sideControlPanel.newLevelSelected(active_level);
        miniMap.isDirty = true;
    }
    
    private function onTouchSplashScreen(evt : TouchEvent) : Void
    {
        if (evt.getTouches(this, TouchPhase.BEGAN).length && m_splashLayer != null)
        {
        // Touch screen pressed, remove it
            
            m_splashLayer.removeChildren(0, -1, true);
            m_splashLayer.removeFromParent();
        }
    }
    
    private function onRemovedFromStage() : Void
    {
        AudioManager.getInstance().reset();
        
        if (m_activeToolTip != null)
        {
            m_activeToolTip.removeFromParent(true);
            m_activeToolTip = null;
        }
        
        removeEventListener(MoveEvent.CENTER_ON_COMPONENT, onCenterOnComponentEvent);
        removeEventListener(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, onWidgetChange);
        removeEventListener(NavigationEvent.SWITCH_TO_NEXT_LEVEL, onNextLevel);
        
        removeEventListener(MenuEvent.SAVE_LEVEL, onPutLevelInDatabase);
        
        removeEventListener(MenuEvent.POST_DIALOG, postDialog);
        removeEventListener(MenuEvent.ACHIEVEMENT_ADDED, achievementAdded);
        removeEventListener(MenuEvent.LOAD_BEST_SCORE, loadBestScore);
        removeEventListener(MenuEvent.LOAD_HIGH_SCORE, loadHighScore);
        removeEventListener(MenuEvent.SOLVE_SELECTION, onSolveSelection);
        removeEventListener(MenuEvent.TURK_FINISH, onTurkFinishButtonPressed);
        
        removeEventListener(UndoEvent.UNDO_EVENT, saveEvent);
        removeEventListener(MenuEvent.ZOOM_IN, onZoomIn);
        removeEventListener(MenuEvent.ZOOM_OUT, onZoomOut);
        removeEventListener(MenuEvent.MAX_ZOOM_REACHED, onMaxZoomReached);
        removeEventListener(MenuEvent.MIN_ZOOM_REACHED, onMinZoomReached);
        removeEventListener(MenuEvent.RESET_ZOOM, onZoomReset);
        removeEventListener(MiniMapEvent.ERRORS_MOVED, onErrorsMoved);
        removeEventListener(MiniMapEvent.VIEWSPACE_CHANGED, onViewspaceChanged);
        removeEventListener(MiniMapEvent.LEVEL_RESIZED, onLevelResized);
        removeEventListener(ToolTipEvent.ADD_TOOL_TIP, onToolTipAdded);
        removeEventListener(ToolTipEvent.CLEAR_TOOL_TIP, onToolTipCleared);
        
        stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        
        removeUpdateTimers();
        
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
    
    
    private function onToolTipAdded(evt : ToolTipEvent) : Void
    {
        if (evt.text && evt.text.length && evt.component && active_level != null && m_activeToolTip == null)
        {
            function pointAt(lev : Level) : DisplayObject
            {
                return evt.component;
            };
            var pointFrom : String = Constants.TOP_LEFT;
            var onTop : Bool = evt.point.y < 80;
            var onLeft : Bool = evt.point.x < 80;
            if (onTop && onLeft)
            {
            // If in top left corner, move to bottom right
                
                pointFrom = Constants.BOTTOM_RIGHT;
            }
            else if (onLeft)
            {
            // If on left, move to top right
                
                pointFrom = Constants.TOP_RIGHT;
            }
            else if (onTop)
            {
            // If on top, move to bottom left
                
                pointFrom = Constants.BOTTOM_LEFT;
            }
            m_activeToolTip = new ToolTipText(evt.text, active_level, false, pointAt, pointFrom);
            if (evt.point)
            {
                m_activeToolTip.setGlobalToPoint(evt.point.clone());
            }
            addChild(m_activeToolTip);
        }
    }
    
    private function onToolTipCleared(evt : ToolTipEvent) : Void
    {
        if (m_activeToolTip != null)
        {
            m_activeToolTip.removeFromParent(true);
        }
        m_activeToolTip = null;
    }
    
    private function onNumSelectedNodesChanged(evt : SelectionEvent) : Void
    {
        if (edgeSetGraphViewPanel != null)
        {
            edgeSetGraphViewPanel.updateNumNodesSelectedDisplay();
        }
    }
    
    public function setHighScores() : Void
    {
        if (PipeJamGame.levelInfo && PipeJamGame.levelInfo.highScores)
        {
            sideControlPanel.setHighScores(PipeJamGame.levelInfo.highScores);
        }
    }
    
    public function showVisibleBrushes() : Void
    {
        if (active_level != null && active_level.tutorialManager)
        {
            var visibleBrushes : Int = active_level.tutorialManager.getVisibleBrushes();
            sideControlPanel.showVisibleBrushes(visibleBrushes);
        }
        else
        {
            sideControlPanel.showVisibleBrushes(active_level.brushesToActivate);
        }
    }
    
    public function showCurrentBrush() : Void
    {
        if (active_level != null && active_level.tutorialManager)
        {
            var visibleBrushes : Int = active_level.tutorialManager.getVisibleBrushes();
            setFirstBrush(visibleBrushes);
        }
        else
        {
            setFirstBrush(active_level.brushesToActivate);
        }
    }
    
    public function setFirstBrush(visibleBrushes : Int) : Void
    {
        var brushInt2Str : Dictionary = new Dictionary();
        brushInt2Str[TutorialLevelManager.SOLVER_BRUSH] = GridViewPanel.FIRST_SOLVER_BRUSH;
        brushInt2Str[TutorialLevelManager.WIDEN_BRUSH] = GridViewPanel.WIDEN_BRUSH;
        brushInt2Str[TutorialLevelManager.NARROW_BRUSH] = GridViewPanel.NARROW_BRUSH;
        
        // This determines the default for which brush is activated first (if visible)
        var brushOrder : Array<Dynamic> = [
        TutorialLevelManager.SOLVER_BRUSH, 
        TutorialLevelManager.WIDEN_BRUSH, 
        TutorialLevelManager.NARROW_BRUSH
    ];
        // If a tutorial specifically wants one brush to be selected to start, put
        // this at the beginning of the list of brushes to check for visibility
        if (active_level.tutorialManager != null)
        {
            var firstBrush : Float = active_level.tutorialManager.getStartingBrush();
            if (!Math.isNaN(firstBrush))
            {
                brushOrder.unshift(firstBrush);
            }
        }
        
        // Activate the first brush that's visible in the brushOrder array
        for (i in 0...brushOrder.length)
        {
            if ((visibleBrushes & brushOrder[i]) != 0)
            {
                edgeSetGraphViewPanel.changeBrush(Reflect.field(brushInt2Str, Std.string(brushOrder[i])));
                sideControlPanel.changeSelectedBrush(Reflect.field(brushInt2Str, Std.string(brushOrder[i])));
                return;
            }
        }
    }
}

