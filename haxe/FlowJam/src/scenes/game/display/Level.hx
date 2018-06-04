package scenes.game.display;

import assets.AssetInterface;
import constraints.Constraint;
import constraints.ConstraintGraph;
import constraints.ConstraintValue;
import constraints.ConstraintVar;
import constraints.events.ErrorEvent;
import constraints.events.VarChangeEvent;
import engine.IGameEngine;
import events.EdgeContainerEvent;
import events.GameComponentEvent;
import events.GroupSelectionEvent;
import events.MenuEvent;
import events.MiniMapEvent;
import events.MoveEvent;
import events.PropertyModeChangeEvent;
import events.UndoEvent;
import events.WidgetChangeEvent;
import flash.errors.Error;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import graph.PropDictionary;
import haxe.Constraints.Function;
import networking.GameFileHandler;
import openfl.Vector;
import scenes.BaseComponent;
import scenes.game.PipeJamGameScene;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import system.MaxSatSolver;
import utils.XObject;
import utils.XString;
//import deng.fzip.FZip;
//import utils.Base64Encoder;

/**
	 * Level all game components - widgets and links
	 */
class Level extends BaseComponent
{
    public var currentScore(get, never) : Int;
    public var bestScore(get, never) : Int;
    public var startingScore(get, never) : Int;
    public var prevScore(get, never) : Int;
    public var oldScore(get, never) : Int;

    
    /** True to allow user to navigate to any level regardless of whether levels below it are solved for debugging */
    public static var UNLOCK_ALL_LEVELS_FOR_DEBUG : Bool = false;
    
    /** Name of this level */
    public var level_name : String;
    
    /** Node collection used to create this level, including name obfuscater */
    public var levelGraph : ConstraintGraph;
    
	// TODO: made public for now for ease of use but selection should be moved out to the domain of scripts
    public var selectedComponents : Array<GameComponent>;
    /** used by solver to keep track of which nodes map to which constraint values, and visa versa */
    private var nodeIDToConstraintsTwoWayMap : Dynamic;
    
    private var marqueeRect : Sprite = new Sprite();
    
    //the level node and decendents
    private var m_levelLayoutObj : Dynamic;
    public var levelObj : Dynamic;
    public var m_levelLayoutName : String;
    public var m_levelQID : String;
    private var m_levelOriginalLayoutObj : Dynamic;  //used for restarting the level  
    //used when saving, as we need a parent graph element for the above level node
    public var m_levelLayoutObjWrapper : Dynamic;
    public var m_levelAssignmentsObj : Dynamic;
    private var m_levelOriginalAssignmentsObj : Dynamic;  //used for restarting the level  
    private var m_levelBestScoreAssignmentsObj : Dynamic;  //best configuration so far  
    public var m_tutorialTag : String;
    public var tutorialManager : TutorialLevelManager;
    private var m_layoutFixed : Bool = false;
    public var m_targetScore : Int;
    
    public var nodeLayoutObjs : Dynamic = {};
    public var edgeLayoutObjs : Dynamic = {};
    
    private var m_gameNodeDict : Dynamic = {};
    private var m_gameEdgeDict : Dynamic = {};
    
    private var m_hidingErrorText : Bool = false;
    private var m_segmentHovered : GameEdgeSegment;
    public var errorConstraintDict : Dynamic = {};
    
    private var m_nodesInactiveContainer : Sprite = new Sprite();
    private var m_errorInactiveContainer : Sprite = new Sprite();
    private var m_edgesInactiveContainer : Sprite = new Sprite();
    private var m_plugsInactiveContainer : Sprite = new Sprite();
    public var inactiveLayer : Sprite = new Sprite();
    
    private var m_nodesContainer : Sprite = new Sprite();
    private var m_errorContainer : Sprite = new Sprite();
    private var m_edgesContainer : Sprite = new Sprite();
    private var m_plugsContainer : Sprite = new Sprite();
    
    public var m_boundingBox : Rectangle = new Rectangle(0, 0, 1, 1);
    private var m_backgroundImage : Image;
    private var m_levelStartTime : Float;
    
    private var initialized : Bool = false;
    
    /** Current Score of the player */
    private var m_bestScore : Int = 0;
    
    /** Set to true when the target score is reached. */
    public var targetScoreReached : Bool;
    public var original_level_name : String;
    
    /** Tracks total distance components have been dragged since last visibile calculation */
    public var totalMoveDist : Point = new Point();
    
    // The following are used for conflict scrolling purposes: (tracking list of current conflicts)
    private var m_currentConflictIndex : Int = -1;
    private var m_levelConflictEdges : Array<GameEdgeContainer> = new Array<GameEdgeContainer>();
    private var m_levelConflictEdgeDict : Dynamic = {};
    private var m_conflictEdgesDirty : Bool = true;
    
    public var m_inSolver : Bool = false;
    
    private static inline var BG_WIDTH : Float = 256;
    private static inline var MIN_BORDER : Float = 1000;
    private static var USE_TILED_BACKGROUND : Bool = false;  // true to include a background that scrolls with the view  
	
	private var m_gameEngine : IGameEngine;
    
    /**
		 * Level contains widgets, links for entire input level constraint graph
		 * @param	_name Name to display
		 * @param	_levelGraph Constraint Graph
		 * @param	_levelObj JSON parsed representation of constraint graph input from PL group
		 * @param	_levelLayoutObj Layout of graph elements
		 * @param	_levelAssignmentsObj Assignment of var values
		 * @param	_targetScore Score needed to complete level
		 * @param	_originalLevelName Level name from PL group
		 */
    public function new(gameEngine : IGameEngine, _name : String, _levelGraph : ConstraintGraph, _levelObj : Dynamic, _levelLayoutObj : Dynamic, _levelAssignmentsObj : Dynamic, _originalLevelName : String)
    {
        super();
		m_gameEngine = gameEngine;
        UNLOCK_ALL_LEVELS_FOR_DEBUG = PipeJamGame.DEBUG_MODE;
        level_name = _name;
        original_level_name = _originalLevelName;
        levelGraph = _levelGraph;
        levelObj = _levelObj;
        m_levelLayoutObj = XObject.clone(_levelLayoutObj);
        m_levelOriginalLayoutObj = XObject.clone(_levelLayoutObj);
        m_levelLayoutName = Reflect.field(_levelLayoutObj, "id");
        m_levelQID = Reflect.field(_levelLayoutObj, "qid");
        m_levelBestScoreAssignmentsObj = _levelAssignmentsObj;  // XObject.clone(_levelAssignmentsObj);  
        m_levelOriginalAssignmentsObj = XObject.clone(_levelAssignmentsObj);
        m_levelAssignmentsObj = _levelAssignmentsObj;  // XObject.clone(_levelAssignmentsObj);  
        
        m_tutorialTag = Reflect.field(m_levelLayoutObj, "tutorial");
        if (m_tutorialTag != null && (m_tutorialTag.length > 0))
        {
            tutorialManager = new TutorialLevelManager(m_tutorialTag);
            m_layoutFixed = tutorialManager.getLayoutFixed();
        }
        
        m_targetScore = Std.int(Math.POSITIVE_INFINITY);
        if (Reflect.hasField(m_levelAssignmentsObj, "target_score") && !Math.isNaN(Reflect.field(m_levelAssignmentsObj, "target_score")))
        {
            m_targetScore = Reflect.field(m_levelAssignmentsObj, "target_score");
        }
        targetScoreReached = false;
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    
    public function loadBestScoringConfiguration() : Void
    {
        loadAssignments(m_levelBestScoreAssignmentsObj, true);
    }
    
    public function loadInitialConfiguration() : Void
    {
        loadAssignments(m_levelOriginalAssignmentsObj, true);
    }
    
    public function loadAssignmentsConfiguration(assignmentsObj : Dynamic) : Void
    {
        loadAssignments(assignmentsObj);
    }
    
    private function loadAssignments(assignmentsObj : Dynamic, updateTutorialManager : Bool = false) : Void
    {
		var saveData : Dynamic = m_gameEngine.getSaveData();
        Reflect.setField(saveData, "assignmentUpdates", null);
        var graphVar : ConstraintVar = null;
        for (varId in Reflect.fields(levelGraph.variableDict))
        {
            graphVar = try cast(Reflect.field(levelGraph.variableDict, varId), ConstraintVar) catch(e:Dynamic) null;
            setGraphVarFromAssignments(graphVar, assignmentsObj, updateTutorialManager);
        }
        if (graphVar != null)
        {
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, graphVar, PropDictionary.PROP_NARROW, graphVar.getProps().hasProp(PropDictionary.PROP_NARROW), this, null));
        }
        refreshTroublePoints();
        onScoreChange();
    }
    
    private function setGraphVarFromAssignments(graphVar : ConstraintVar, assignmentsObj : Dynamic, updateTutorialManager : Bool = false) : Void
    //save object and restore at after initial assignments since I don't want these assignments saved
    {
        
        var savedAssignmentObj : Dynamic = Reflect.field(m_gameEngine.getSaveData(), "assignmentUpdates");
        // By default, reset gameNode to default value, then if contained in "assignments" obj, use that value instead
        var assignmentIsWide : Bool = (graphVar.defaultVal.verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
        if (Reflect.hasField(Reflect.field(assignmentsObj, "assignments"), graphVar.formattedId)
            && Reflect.hasField(Reflect.field(Reflect.field(assignmentsObj, "assignments"), graphVar.formattedId), ConstraintGraph.TYPE_VALUE))
        {
            assignmentIsWide = (Reflect.field(Reflect.field(Reflect.field(assignmentsObj, "assignments"), graphVar.formattedId), ConstraintGraph.TYPE_VALUE) == ConstraintValue.VERBOSE_TYPE_1);
        }
        if (graphVar.getProps().hasProp(PropDictionary.PROP_NARROW) == assignmentIsWide)
        {
            levelGraph.updateScore(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide);
            //graphVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
            //levelGraph.updateScore();
            if (updateTutorialManager && tutorialManager != null)
            {
                tutorialManager.onWidgetChange(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide);
            }
        }
        
        //and then set from local storage, if there (but only if we really want it)
        if (PipeJamGameScene.levelContinued && !updateTutorialManager && savedAssignmentObj != null && Reflect.field(savedAssignmentObj, Std.string(graphVar.id)) != null)
        {
            var newWidth : String = Reflect.field(savedAssignmentObj, graphVar.id);
            var savedAssignmentIsWide : Bool = (newWidth == ConstraintValue.VERBOSE_TYPE_1);
            if (graphVar.getProps().hasProp(PropDictionary.PROP_NARROW) == savedAssignmentIsWide)
            {
                graphVar.setProp(PropDictionary.PROP_NARROW, !savedAssignmentIsWide);
            }
        }
    }
    
    private function onAddedToStage(event : Event) : Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        if (m_disposed)
        {
            restart();
        }
        else
        {
            start();
        }
        
        //for (var varId:String in levelGraph.variableDict) {
        //var graphVar:ConstraintVar = levelGraph.variableDict[varId] as ConstraintVar;
        //graphVar.addEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onWidgetChange);
        //}
        addEventListener(VarChangeEvent.VAR_CHANGE_USER, onWidgetChange);
        
        refreshTroublePoints();
        
        dispatchEvent(new starling.events.Event(Game.STOP_BUSY_ANIMATION, true));
    }
    
    public function initialize() : Void
    {
        if (initialized)
        {
            return;
        }
        trace("Level.initialize()...");
        refreshLevelErrors();
        if (USE_TILED_BACKGROUND && m_backgroundImage == null)
        {
        // TODO: may need to refine GridViewPanel .onTouch method as well to get this to work: if(this.m_currentLevel && event.target == m_backgroundImage)
            
           // var background : Texture = AssetInterface.getTexture("Game", "BoxesGamePanelBackgroundImageClass");TODO couldnt find this image references so used other backgrounf
            var background : Texture = AssetInterface.getTexture("img/Backgrounds", "FlowJamBackground2.jpg");
            m_backgroundImage = new Image(background);
			m_backgroundImage.textureRepeat = true;
            m_backgroundImage.width = m_backgroundImage.height = 2 * MIN_BORDER;
            m_backgroundImage.x = m_backgroundImage.y = -MIN_BORDER;
            m_backgroundImage.blendMode = BlendMode.NONE;
            addChild(m_backgroundImage);
        }
        
        if (inactiveLayer == null)
        {
            inactiveLayer = new Sprite();
        }
        if (m_nodesInactiveContainer == null)
        {
            m_nodesInactiveContainer = new Sprite();
        }
        if (m_errorInactiveContainer == null)
        {
            m_errorInactiveContainer = new Sprite();
        }
        if (m_edgesInactiveContainer == null)
        {
            m_edgesInactiveContainer = new Sprite();
        }
        if (m_plugsInactiveContainer == null)
        {
            m_plugsInactiveContainer = new Sprite();
        }
        inactiveLayer.addChild(m_nodesInactiveContainer);
        inactiveLayer.addChild(m_errorInactiveContainer);
        inactiveLayer.addChild(m_edgesInactiveContainer);
        inactiveLayer.addChild(m_plugsInactiveContainer);
        
        if (m_nodesContainer == null)
        {
            m_nodesContainer = new Sprite();
        }
        if (m_errorContainer == null)
        {
            m_errorContainer = new Sprite();
        }
        if (m_edgesContainer == null)
        {
            m_edgesContainer = new Sprite();
        }
        if (m_plugsContainer == null)
        {
            m_plugsContainer = new Sprite();
        }
        //m_nodesContainer.filter = BlurFilter.createDropShadow(4.0, 0.78, 0x0, 0.85, 2, 1); //only works up to 2048px
        addChild(m_nodesContainer);
        addChild(m_errorContainer);
        addChild(m_edgesContainer);
        addChild(m_plugsContainer);
        
        this.alpha = .999;
        
        selectedComponents = new Array<GameComponent>();
        totalMoveDist = new Point();
        
        loadLayout();
        trace("Level " + Reflect.field(m_levelLayoutObj, "id") + " m_boundingBox = " + m_boundingBox);
        
        addEventListener(EdgeContainerEvent.CREATE_JOINT, onCreateJoint);
        addEventListener(EdgeContainerEvent.SEGMENT_MOVED, onSegmentMoved);
        addEventListener(EdgeContainerEvent.SEGMENT_DELETED, onSegmentDeleted);
        addEventListener(EdgeContainerEvent.HOVER_EVENT_OVER, onHoverOver);
        addEventListener(EdgeContainerEvent.HOVER_EVENT_OUT, onHoverOut);
        //addEventListener(WidgetChangeEvent.WIDGET_CHANGED, onEdgeSetChange); // do these per-box
        addEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
        addEventListener(GameComponentEvent.COMPONENT_SELECTED, onComponentSelection);
        addEventListener(GameComponentEvent.COMPONENT_UNSELECTED, onComponentUnselection);
        addEventListener(GroupSelectionEvent.GROUP_SELECTED, onGroupSelection);
        addEventListener(GroupSelectionEvent.GROUP_UNSELECTED, onGroupUnselection);
        addEventListener(MoveEvent.MOVE_EVENT, onMoveEvent);
        addEventListener(MoveEvent.FINISHED_MOVING, onFinishedMoving);
        levelGraph.addEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
        levelGraph.addEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
        
        //addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
        //setNodesFromAssignments(m_levelAssignmentsObj);
        //force update of conflict count dictionary, ignore return value
        //getNextConflict(true);
        initialized = true;
        trace("Level edges and nodes all created.");
        // When level loaded, don't need this event listener anymore
        dispatchEvent(new MenuEvent(MenuEvent.LEVEL_LOADED));
    }
    
    public function refreshLevelErrors() : Void
    {
        errorConstraintDict = {};
        for (constraintId in Reflect.fields(levelGraph.constraintsDict))
        {
            var constraint : Constraint = try cast(Reflect.field(levelGraph.constraintsDict, constraintId), Constraint) catch(e:Dynamic) null;
            if (!constraint.isSatisfied())
            {
                Reflect.setField(errorConstraintDict, constraintId, constraint);
            }
        }
    }
    
    private function onEnterFrame(evt : EnterFrameEvent) : Void
    // For initialization
    {
        
        var CALLS_PER_FRAME : Int = 200;
        var i : Int = 0;
		var nodeLayoutIds : Array<String> = Reflect.fields(nodeLayoutObjs);
		var edgeLayoutIds : Array<String> = Reflect.fields(edgeLayoutObjs);
		if (nodeLayoutIds.length > 0)
		{
			for (nodeLayoutId in nodeLayoutIds)
			{
				var nodeLayout : Dynamic = Reflect.field(nodeLayoutObjs, nodeLayoutId);
				createNodeFromJsonObj(nodeLayout);
			}
		}
        else if (edgeLayoutIds.length > 0)
        {
			for (edgeLayoutId in nodeLayoutIds) 
			{
				var edgeLayout : Dynamic = Reflect.field(edgeLayoutObjs, edgeLayoutId);
				createEdgeFromJsonObj(edgeLayout);
			}
        }
        else
        {
            loadAssignments(m_levelAssignmentsObj);
            //force update of conflict count dictionary, ignore return value
            getNextConflict(true);
            initialized = true;
            trace("Level edges and nodes all created.");
            // When level loaded, don't need this event listener anymore
            removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
            dispatchEvent(new MenuEvent(MenuEvent.LEVEL_LOADED));
        }
    }
    
    public function createNodeFromJsonObj(boxLayoutObj : Dynamic) : Void
    {
        var varId : String = Reflect.field(boxLayoutObj, "id");
        if (levelGraph.variableDict.get(varId) == null)
        {
            throw new Error("Couldn't find edge set for var id: " + varId);
        }
        destroyGameNode(varId);
        var constraintVar : ConstraintVar = Reflect.field(levelGraph.variableDict, varId);
        var gameNode : GameNode = new GameNode(boxLayoutObj, constraintVar, !m_layoutFixed);
        setGraphVarFromAssignments(constraintVar, m_levelAssignmentsObj, true);
        
        var boxVisible : Bool = true;
        if (Reflect.hasField(boxLayoutObj, "visible") && (Reflect.field(boxLayoutObj, "visible") == "false"))
        {
            boxVisible = false;
        }
        if (!boxVisible)
        {
            gameNode.hideComponent(true);
            Reflect.setField(boxLayoutObj, "visible", "false");
        }
        Reflect.setField(m_gameNodeDict, varId, gameNode);
    }
    
    public function destroyGameNode(nodeId : String) : Void
    {
        var gameNode : GameNode = Reflect.field(m_gameNodeDict, nodeId);
        if (gameNode != null)
        {
            gameNode.removeFromParent(true);
        }
		Reflect.deleteField(m_gameNodeDict, nodeId);
    }
    
    public function createEdgeFromJsonObj(edgeLayoutObj : Dynamic) : Void
    {
        var constraintId : String = Reflect.field(edgeLayoutObj, "id");
        destroyGameEdge(constraintId);
        var newGameEdge : GameEdgeContainer = createLine(constraintId, edgeLayoutObj);
        Reflect.setField(m_gameEdgeDict, constraintId, newGameEdge);
    }
    
    private function createLine(edgeId : String, edgeLayoutObj : Dynamic) : GameEdgeContainer
    {
        var edgeFromVarId : String = Reflect.field(edgeLayoutObj, "from_var_id");
        var edgeToVarId : String = Reflect.field(edgeLayoutObj, "to_var_id");
        if (!Reflect.hasField(m_gameNodeDict, edgeFromVarId))
        {
            var fromNodeLayout : Dynamic = Reflect.field(nodeLayoutObjs, edgeFromVarId);
            if (fromNodeLayout == null)
            {
                throw new Error("Edge layout found with no from node layout, edge: " + edgeId + " node:" + edgeFromVarId);
            }
            createNodeFromJsonObj(fromNodeLayout);
        }
        if (!Reflect.hasField(m_gameNodeDict, edgeToVarId))
        {
            var toNodeLayout : Dynamic = Reflect.field(nodeLayoutObjs, edgeToVarId);
            if (toNodeLayout == null)
            {
                throw new Error("Edge layout found with no to node layout, edge: " + edgeId + " node:" + edgeToVarId);
            }
            createNodeFromJsonObj(toNodeLayout);
        }
        var fromNode : GameNode = try cast(Reflect.field(m_gameNodeDict, edgeFromVarId), GameNode) catch(e:Dynamic) null;
        var toNode : GameNode = try cast(Reflect.field(m_gameNodeDict, edgeToVarId), GameNode) catch(e:Dynamic) null;
        if (!Reflect.hasField(levelGraph.constraintsDict, edgeId))
        {
            throw new Error("Edge not found in levelGraph.constraintsDict:" + edgeId);
        }
        var constraint : Constraint = Reflect.field(levelGraph.constraintsDict, edgeId);
        var edgeArray : Array<Dynamic> = Reflect.field(edgeLayoutObj, "edge_array");
        
        var newGameEdge : GameEdgeContainer = new GameEdgeContainer(edgeId, edgeArray, fromNode, toNode, constraint, !m_layoutFixed);
        if (!getVisible(edgeLayoutObj))
        {
            newGameEdge.hideComponent(true);
        }
        
        return newGameEdge;
    }
    
    public function destroyGameEdge(edgeId : String) : Void
    {
        var gameEdge : GameEdgeContainer = Reflect.field(m_gameEdgeDict, edgeId);
        if (gameEdge != null)
        {
            gameEdge.removeFromParent(true);
        }
		Reflect.deleteField(m_gameEdgeDict, edgeId);
    }
    
    private function loadLayout() : Void
    {
        nodeLayoutObjs = {};
        edgeLayoutObjs = {};
        
        var minX : Float = 0;
        var minY : Float = 0;
        var maxX : Float = 0;
        var maxY : Float = 0;
        minX = minY = Math.POSITIVE_INFINITY;
        maxX = maxY = Math.NEGATIVE_INFINITY;
        
        // Process layout nodes (vars)
        var visibleNodes : Int = 0;
        var n : Int = 0;
        for (varId in Reflect.fields(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars")))
        {
            var boxLayoutObj : Dynamic = Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars"), varId);
            var graphVar : ConstraintVar = try cast(Reflect.field(levelGraph.variableDict, varId), ConstraintVar) catch(e:Dynamic) null;
            if (graphVar == null)
            {
                trace("Warning: layout var found with no corresponding contraints var:" + varId);
                continue;
            }
            Reflect.setField(boxLayoutObj, "id", varId);
            Reflect.setField(boxLayoutObj, "var", graphVar);
            var nodeX : Float = Reflect.field(boxLayoutObj, "x") * Constants.GAME_SCALE;
            var nodeY : Float = Reflect.field(boxLayoutObj, "y") * Constants.GAME_SCALE;
            var nodeWidth : Float = Reflect.field(boxLayoutObj, "w") * Constants.GAME_SCALE;
            var nodeHeight : Float = Reflect.field(boxLayoutObj, "h") * Constants.GAME_SCALE;
            var nodeBoundingBox : Rectangle = new Rectangle(nodeX - 0.5 * nodeWidth, nodeY - 0.5 * nodeHeight, nodeWidth, nodeHeight);
            minX = Math.min(minX, nodeBoundingBox.left);
            minY = Math.min(minY, nodeBoundingBox.top);
            maxX = Math.max(maxX, nodeBoundingBox.right);
            maxY = Math.max(maxY, nodeBoundingBox.bottom);
            Reflect.setField(boxLayoutObj, "bb", nodeBoundingBox);
            Reflect.setField(nodeLayoutObjs, varId, boxLayoutObj);
            if (Reflect.hasField(m_gameNodeDict, varId))
            {
            // If node exists, update its position
                
                (try cast(Reflect.field(m_gameNodeDict, varId), GameNode) catch(e:Dynamic) null).updateLayout(boxLayoutObj);
            }
            n++;
        }
        trace("node count = " + n);
        
        // Process layout edges (constraints)
        var visibleLines : Int = 0;
        n = 0;
        var pattern : as3hx.Compat.Regex = new as3hx.Compat.Regex('(.*) -> (.*)', "i");
        for (constraintId in Reflect.fields(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "constraints")))
        {
            var edgeLayoutObj : Dynamic = Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "constraints"), constraintId);
            Reflect.setField(edgeLayoutObj, "id", constraintId);
            var result : Dynamic = pattern.exec(constraintId);
            if (result == null)
            {
                throw new Error("Invalid constraint layout string found: " + constraintId);
            }
            if (result.length != 3)
            {
                throw new Error("Invalid constraint layout string found: " + constraintId);
            }
            var graphConstraint : Constraint = try cast(Reflect.field(levelGraph.constraintsDict, constraintId), Constraint) catch(e:Dynamic) null;
            if (graphConstraint == null)
            {
                throw new Error("No graph constraint found for constraint layout: " + constraintId);
            }
            Reflect.setField(edgeLayoutObj, "constraint", graphConstraint);
            Reflect.setField(edgeLayoutObj, "from_var_id", Reflect.field(result, Std.string(1)));
            Reflect.setField(edgeLayoutObj, "to_var_id", Reflect.field(result, Std.string(2)));
            //create edge array
            var edgeArray : Array<Dynamic> = new Array<Dynamic>();
            var ptsArr : Array<Dynamic> = try cast(Reflect.field(edgeLayoutObj, "pts"), Array<Dynamic>) catch (e:Dynamic) null;
            if (ptsArr == null)
            {
                throw new Error("No layout pts found for edge:" + constraintId);
            }
            if (ptsArr.length < 4)
            {
                throw new Error("Not enough points found in layout for edge:" + constraintId);
            }
            var edgeXMin : Float;
            var edgeXMax : Float;
            var edgeYMin : Float;
            var edgeYMax : Float;
            edgeXMin = edgeYMin = Math.POSITIVE_INFINITY;
            edgeXMax = edgeYMax = Math.NEGATIVE_INFINITY;
            for (i in 0...ptsArr.length)
            {
                var ptx : Float = Reflect.field(ptsArr[i], "x") * Constants.GAME_SCALE;
                var pty : Float = Reflect.field(ptsArr[i], "y") * Constants.GAME_SCALE;
                edgeXMin = Math.min(edgeXMin, ptx);
                edgeYMin = Math.min(edgeYMin, pty);
                edgeXMax = Math.max(edgeXMax, ptx);
                edgeYMax = Math.max(edgeYMax, pty);
                var pt : Point = new Point(ptx, pty);
                edgeArray.push(pt);
            }
            minX = Math.min(minX, edgeXMin);
            minY = Math.min(minY, edgeYMin);
            maxX = Math.max(maxX, edgeXMax);
            maxY = Math.max(maxY, edgeYMax);
            Reflect.setField(edgeLayoutObj, "edge_array", edgeArray);
            Reflect.setField(edgeLayoutObj, "bb", new Rectangle(edgeXMin, edgeYMin, edgeXMax - edgeXMin, edgeYMax - edgeYMin));
            Reflect.setField(edgeLayoutObjs, constraintId, edgeLayoutObj);
            if (Reflect.hasField(m_gameEdgeDict, constraintId))
            {
                createEdgeFromJsonObj(edgeLayoutObj);
            }
            n++;
        }
        trace("edge count = " + n);
        m_boundingBox = new Rectangle(minX, minY, maxX - minX, maxY - minY);
    }
    
    public function start() : Void
    {
        m_segmentHovered = null;
        initialize();
        
        m_disposed = false;
        m_levelStartTime = Date.now().getTime();
        if (tutorialManager != null)
        {
            tutorialManager.startLevel();
        }
        draw();
        
        //now that everything is attached and added to parents, update port position indexes, for both nodes and joints
        for (nodeId in Reflect.fields(m_gameNodeDict))
        {
            var gameNode : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
            gameNode.updatePortIndexes();
        }
        levelGraph.resetScoring();
        m_bestScore = levelGraph.currentScore;
        levelGraph.startingScore = levelGraph.currentScore;
        trace("Loaded: " + Reflect.field(m_levelLayoutObj, "id") + " for display.");
    }
    
    public function restart() : Void
    {
        m_segmentHovered = null;
        if (!initialized)
        {
            start();
        }
        else
        {
            if (tutorialManager != null)
            {
                tutorialManager.startLevel();
            }
            m_levelStartTime = Date.now().getTime();
        }
        //var propChangeEvt:PropertyModeChangeEvent = new PropertyModeChangeEvent(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, PropDictionary.PROP_NARROW);
        //onPropertyModeChange(propChangeEvt);
        //dispatchEvent(propChangeEvt);
        setNewLayout(null, m_levelOriginalLayoutObj);
        //m_levelAssignmentsObj = XObject.clone(m_levelOriginalAssignmentsObj);
        //loadAssignments(m_levelAssignmentsObj);
        loadInitialConfiguration();
        targetScoreReached = false;
        trace("Restarted: " + Reflect.field(m_levelLayoutObj, "id"));
    }
    
    public function onSaveLayoutFile(event : MenuEvent) : Void
    {
        updateLevelObj();
        
        var levelObject : Dynamic = PipeJamGame.levelInfo;
        if (levelObject != null)
        {
            Reflect.setField(m_levelLayoutObjWrapper, "id", event.data.name);
            levelObject.m_layoutName = event.data.name;
            levelObject.m_layoutDescription = event.data.description;
            var layoutZip : ByteArray = zipJsonFile(m_levelLayoutObjWrapper, "layout");
            var layoutZipEncodedString : String = encodeBytes(layoutZip);
            GameFileHandler.saveLayoutFile(layoutSaved, layoutZipEncodedString);
        }
    }
    
    private function layoutSaved(result : Int, e : flash.events.Event) : Void
    {
        dispatchEvent(new MenuEvent(MenuEvent.LAYOUT_SAVED));
    }
    
    public function zipJsonFile(jsonFile : Dynamic, name : String) : ByteArray
    {
        //var newZip : FZip = new FZip();
        //var zipByteArray : ByteArray = new ByteArray();
        //zipByteArray.writeUTFBytes(haxe.Json.stringify(jsonFile));
        //newZip.addFile(name, zipByteArray);
        //var byteArray : ByteArray = new ByteArray();
        //newZip.serialize(byteArray);
        //return byteArray;
		return null;
    }
    
    public function encodeBytes(bytes : ByteArray) : String
    {
        //var encoder : Base64Encoder = new Base64Encoder();
        //encoder.encodeBytes(bytes);
        //var encodedString : String = Std.string(encoder);
        //
        //return encodedString;
		return null;
    }
    
    public function updateLevelObj() : Void
    {
        var worldParent : DisplayObject = parent;
        while (worldParent != null && !(Std.is(worldParent, WorldCopy)))
        {
            worldParent = worldParent.parent;
        }
        
        updateLayoutObj(try cast(worldParent, WorldCopy) catch(e:Dynamic) null, true);
        updateAssignmentsObj();
    }
    
    private function onRemovedFromStage(event : Event) : Void
    {  //disposeChildren();  
        
    }
    
    public function setNewLayout(name : String, newLayoutObj : Dynamic, useExistingLines : Bool = false) : Void
    {
        m_levelLayoutObj = XObject.clone(newLayoutObj);
        m_levelLayoutName = name;
        //we might have ended up with a 'world', just grab the first level
        if (Reflect.field(m_levelLayoutObj, "levels") != null)
        {
            m_levelLayoutObj = Reflect.field(Reflect.field(m_levelLayoutObj, "levels"), Std.string(0));
        }
        loadLayout();
        trace("Level " + Reflect.field(m_levelLayoutObj, "id") + " m_boundingBox = " + m_boundingBox);
        draw();
    }
    
    //update current layout info based on node/edge position
    // TODO: We don't want Level to depend on WorldCopy, let's avoid circular
    // class dependency and have WorldCopy -> Level, not WorldCopy <-> Level
    public function updateLayoutObj(world : WorldCopy, includeThumbnail : Bool = false) : Void
    {
        m_levelLayoutObjWrapper = {};
        Reflect.setField(m_levelLayoutObjWrapper, "layout", {});
        Reflect.setField(Reflect.field(m_levelLayoutObjWrapper, "layout"), "vars", {});
        for (varId in Reflect.fields(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars")))
        {
            Reflect.setField(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "vars"), varId, {});
            if (!Reflect.hasField(m_gameNodeDict, varId))
            {
                trace("Warning! Layout varid where no gameNode exists in boxDictionary varId:" + varId);
                continue;
            }
            var gameNode : GameNode = try cast(Reflect.field(m_gameNodeDict, varId), GameNode) catch(e:Dynamic) null;
            var currentLayoutX : Float = (gameNode.x /*+ m_boundingBox.x*/ + gameNode.boundingBox.width / 2) / Constants.GAME_SCALE;
            Reflect.setField(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "vars"), varId), "x", XString.floatFixedDigits(currentLayoutX, 2));
            var currentLayoutY : Float = (gameNode.y /*+ m_boundingBox.y*/ + gameNode.boundingBox.height / 2) / Constants.GAME_SCALE;
            Reflect.setField(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "vars"), varId), "y", XString.floatFixedDigits(currentLayoutY, 2));
            if (gameNode.hidden)
            {
                Reflect.setField(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "vars"), varId), "visible", "false");
            }
            else
            {
                Reflect.deleteField(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "vars"), varId), "visible");
            }
        }
        Reflect.setField(Reflect.field(m_levelLayoutObjWrapper, "layout"), "constraints", {});
        for (constraintId in Reflect.fields(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "constraints")))
        {
            Reflect.setField(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "constraints"), constraintId, {});
            if (!Reflect.hasField(m_gameEdgeDict, constraintId))
            {
                trace("Warning! Layout constraint found with no corresponding game edgeContainer found: " + constraintId);
                continue;
            }
            var edgeContainer : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, constraintId), GameEdgeContainer) catch(e:Dynamic) null;
            Reflect.setField(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "constraints"), constraintId), "visible", Std.string(!edgeContainer.hidden));
            Reflect.setField(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "constraints"), constraintId), "pts", new Array<Dynamic>());
            
            if (edgeContainer.m_jointPoints.length != GameEdgeContainer.NUM_JOINTS)
            {
                trace("Wrong number of joint points " + constraintId);
            }
            for (i in 0...edgeContainer.m_jointPoints.length)
            {
                var pt : Point = edgeContainer.m_jointPoints[i];
                var currentLayoutX = (pt.x + edgeContainer.x) / Constants.GAME_SCALE;
                var currentLayoutY = (pt.y + edgeContainer.y) / Constants.GAME_SCALE;
				var currentLayoutXSplit = Std.string(currentLayoutX).split(".");
				var currentLayoutYSplit = Std.string(currentLayoutY).split(".");
                (try cast(Reflect.field(Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObjWrapper, "layout"), "constraints"), constraintId), "pts"), Array<Dynamic>) catch(e:Dynamic) null).push({
                            x : currentLayoutXSplit[0] + currentLayoutXSplit[1].substr(0, 2),
                            y : currentLayoutYSplit[0] + currentLayoutYSplit[1].substr(0, 2)
                        });
            }
        }
        
        if (includeThumbnail)
        {
            var byteArray : ByteArray = world.getThumbnail(300, 300);
            //var enc : Base64Encoder = new Base64Encoder();
            //enc.encodeBytes(byteArray);
            //Reflect.setField(m_levelLayoutObjWrapper, "thumb", Std.string(enc));
        }
    }
    
    //update current constraint info based on node constraints
    public function updateAssignmentsObj() : Void
    {
        m_levelAssignmentsObj = createAssignmentsObj();
    }
    
    private function createAssignmentsObj() : Dynamic
    {
        var hashSize : Int = 0;
        var nodeId : String;
        for (nodeId in Reflect.fields(m_gameNodeDict))
        {
            hashSize++;
        }
        
        var assignmentsObj : Dynamic = {
            id : original_level_name,
            hash : [],
            target_score : this.m_targetScore,
            starting_score : this.levelGraph.currentScore,
            starting_jams : this.m_levelConflictEdges.length,
            assignments : { }
        };
        var count : Int = 0;
        var numWide : Int = 0;
        for (nodeId in Reflect.fields(m_gameNodeDict))
        {
            var node : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
            if (node.constraintVar.constant)
            {
                continue;
            }
            if (!Reflect.hasField(Reflect.field(assignmentsObj, "assignments"), node.constraintVar.formattedId))
            {
                Reflect.setField(Reflect.field(assignmentsObj, "assignments"), Std.string(node.constraintVar.formattedId), { });
            }
            Reflect.setField(Reflect.field(Reflect.field(assignmentsObj, "assignments"), Std.string(node.constraintVar.formattedId)), Std.string(ConstraintGraph.TYPE_VALUE), node.constraintVar.getValue().verboseStrVal);
            var keyfors : Array<Dynamic> = new Array<Dynamic>();
            for (i in 0...node.constraintVar.keyforVals.length)
            {
                keyfors.push(node.constraintVar.keyforVals[i]);
            }
            if (keyfors.length > 0)
            {
                Reflect.setField(Reflect.field(Reflect.field(assignmentsObj, "assignments"), Std.string(node.constraintVar.formattedId)), Std.string(ConstraintGraph.KEYFOR_VALUES), keyfors);
            }
            
            var isWide : Bool = (node.constraintVar.getValue().verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
            if (isWide)
            {
                numWide++;
            }
            
            count++;
            
            if (count == hashSize)
            {
                count = 0;
                //store both in the file and externally
                Reflect.field(assignmentsObj, "hash").push(numWide);
                numWide = 0;
            }
        }
        return assignmentsObj;
    }
    
    override public function dispose() : Void
    {
        initialized = false;
        trace("Disposed of : " + Reflect.field(m_levelLayoutObj, "id"));
        if (m_disposed)
        {
            return;
        }
        
        if (tutorialManager != null)
        {
            tutorialManager.endLevel();
        }
        
        for (nodeId in Reflect.fields(m_gameNodeDict))
        {
            var gameNodeSet : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
            gameNodeSet.removeFromParent(true);
        }
        m_gameNodeDict = {};
        for (edgeId in Reflect.fields(m_gameEdgeDict))
        {
            var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
            gameEdge.removeFromParent(true);
        }
        m_gameEdgeDict = {};
        
        if (m_nodesContainer != null)
        {
            while (m_nodesContainer.numChildren > 0)
            {
                m_nodesContainer.getChildAt(0).removeFromParent(true);
            }
            m_nodesContainer.removeFromParent(true);
        }
        if (m_errorContainer != null)
        {
            while (m_errorContainer.numChildren > 0)
            {
                m_errorContainer.getChildAt(0).removeFromParent(true);
            }
            m_errorContainer.removeFromParent(true);
        }
        if (m_edgesContainer != null)
        {
            while (m_edgesContainer.numChildren > 0)
            {
                m_edgesContainer.getChildAt(0).removeFromParent(true);
            }
            m_edgesContainer.removeFromParent(true);
        }
        if (m_plugsContainer != null)
        {
            while (m_plugsContainer.numChildren > 0)
            {
                m_plugsContainer.getChildAt(0).removeFromParent(true);
            }
            m_plugsContainer.removeFromParent(true);
        }
        
        disposeChildren();
        
        removeEventListener(EdgeContainerEvent.CREATE_JOINT, onCreateJoint);
        removeEventListener(EdgeContainerEvent.SEGMENT_MOVED, onSegmentMoved);
        removeEventListener(EdgeContainerEvent.SEGMENT_DELETED, onSegmentDeleted);
        removeEventListener(EdgeContainerEvent.HOVER_EVENT_OVER, onHoverOver);
        removeEventListener(EdgeContainerEvent.HOVER_EVENT_OUT, onHoverOut);
        removeEventListener(VarChangeEvent.VAR_CHANGE_USER, onWidgetChange);
        removeEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
        removeEventListener(GameComponentEvent.COMPONENT_SELECTED, onComponentSelection);
        removeEventListener(GameComponentEvent.COMPONENT_UNSELECTED, onComponentSelection);
        removeEventListener(GroupSelectionEvent.GROUP_SELECTED, onGroupSelection);
        removeEventListener(GroupSelectionEvent.GROUP_UNSELECTED, onGroupUnselection);
        removeEventListener(MoveEvent.MOVE_EVENT, onMoveEvent);
        removeEventListener(MoveEvent.FINISHED_MOVING, onFinishedMoving);
        if (levelGraph != null)
        {
            levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
        }
        if (levelGraph != null)
        {
            levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
        }
        super.dispose();
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    override private function onTouch(event : TouchEvent) : Void
    {
        var touches : Vector<Touch> = event.touches;
        if (event.getTouches(this, TouchPhase.MOVED).length > 0)
        {
            if (touches.length == 1)
            {
            // one finger touching -> move
                
                var x : Int = 3;
            }
        }
    }
    
    private function onSegmentMoved(event : EdgeContainerEvent) : Void
    {
        var newLeft : Float = m_boundingBox.left;
        var newRight : Float = m_boundingBox.right;
        var newTop : Float = m_boundingBox.top;
        var newBottom : Float = m_boundingBox.bottom;
        if (event.container != null)
        {
            newLeft = Math.min(newLeft, event.container.boundingBox.left);
            newRight = Math.max(newRight, event.container.boundingBox.right);
            newTop = Math.min(newTop, event.container.boundingBox.top);
            newBottom = Math.max(newBottom, event.container.boundingBox.bottom);
            m_boundingBox = new Rectangle(newLeft, newTop, newRight - newLeft, newBottom - newTop);
        }
        if (tutorialManager != null)
        {
            var pointingAt : Bool = false;
            if ((tutorialManager.getTextInfo() != null) && (tutorialManager.getTextInfo().pointAtFn != null))
            {
                var pointAtObject : DisplayObject = tutorialManager.getTextInfo().pointAtFn(this);
                if (pointAtObject == event.segment)
                {
                    pointingAt = true;
                }
            }
            tutorialManager.onSegmentMoved(event, pointingAt);
        }
    }
    
    private function onSegmentDeleted(event : EdgeContainerEvent) : Void
    {  // TODO: notify tutorial manager  
        
    }
    
    private function onHoverOver(event : EdgeContainerEvent) : Void
    {
        m_segmentHovered = event.segment;
    }
    
    private function onHoverOut(event : EdgeContainerEvent) : Void
    {
        m_segmentHovered = null;
    }
    
    //called when a segment is double-clicked on
    private function onCreateJoint(event : EdgeContainerEvent) : Void
    {
        if (tutorialManager != null && (event.container != null))
        {
            tutorialManager.onJointCreated(event);
        }
    }
    
    //assume this only generates on toggle width events
    private function onWidgetChange(evt : VarChangeEvent = null) : Void
    //trace("Level: onWidgetChange");
    {
        
        if (evt != null)
        {
            levelGraph.updateScore(evt.graphVar.id, evt.prop, evt.newValue);
            //evt.graphVar.setProp(evt.prop, evt.newValue);
            //levelGraph.updateScore();
            if (tutorialManager != null)
            {
                tutorialManager.onWidgetChange(evt.graphVar.id, evt.prop, evt.newValue);
            }
            m_gameEngine.dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, evt.graphVar, evt.prop, evt.newValue, this, evt.pt));
            //save incremental changes so we can update if user quits and restarts
			var saveData : Dynamic = m_gameEngine.getSaveData();
            if (Reflect.hasField(saveData, "assignmentUpdates"))
            {
            //should only be null when doing assignments from assignments file
                
                {
                    var constraintType : String = (evt.newValue) ? ConstraintValue.VERBOSE_TYPE_0 : ConstraintValue.VERBOSE_TYPE_1;
                    Reflect.setField(Reflect.field(saveData, "assignmentUpdates"), evt.graphVar.id, constraintType);
                }
            }
        }
        else
        {
            levelGraph.updateScore();
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
        }
        onScoreChange(true, false);
    }
    
    private var m_propertyMode : String = PropDictionary.PROP_NARROW;
    public function onPropertyModeChange(evt : PropertyModeChangeEvent) : Void
    {
        var i : Int;
        var nodeId : String;
        var gameNode : GameNode;
        var edgeId : String;
        var gameEdge : GameEdgeContainer;
        if (evt.prop == PropDictionary.PROP_NARROW)
        {
            m_propertyMode = PropDictionary.PROP_NARROW;
            for (edgeId in Reflect.fields(m_gameEdgeDict))
            {
                gameEdge = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
                gameEdge.setPropertyMode(m_propertyMode);
                activate(gameEdge);
            }
            for (nodeId in Reflect.fields(m_gameNodeDict))
            {
                gameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
                gameNode.setPropertyMode(m_propertyMode);
                activate(gameNode);
            }
        }
        else
        {
            m_propertyMode = evt.prop;
            var edgesToActivate : Array<GameEdgeContainer> = new Array<GameEdgeContainer>();
            for (nodeId in Reflect.fields(m_gameNodeDict))
            {
                gameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
                // TODO: broken
                //if (m_nodeList[i] is GameMapGetJoint) {
                //var mapget:GameMapGetJoint = m_nodeList[i] as GameMapGetJoint;
                //if (mapget.getNode.getMapProperty() == evt.prop) {
                //m_nodeList[i].setPropertyMode(m_propertyMode);
                //edgesToActivate = edgesToActivate.concat(mapget.getUpstreamEdgeContainers());
                //continue;
                //}
                //}
                gameNode.setPropertyMode(m_propertyMode);
                deactivate(gameNode);
            }
            var gameNodesToActivate : Array<GameNode> = new Array<GameNode>();
            for (edgeId in Reflect.fields(m_gameEdgeDict))
            {
                gameEdge = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
                gameEdge.setPropertyMode(m_propertyMode);
                if (Lambda.indexOf(edgesToActivate, gameEdge) > -1)
                {
                    gameNodesToActivate.push(gameEdge.m_fromNode);
                }
                else
                {
                    deactivate(gameEdge);
                }
            }
            for (nodeId in Reflect.fields(m_gameNodeDict))
            {
                gameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
                gameNode.setPropertyMode(m_propertyMode);
                if (Lambda.indexOf(gameNodesToActivate, gameNode) == -1)
                {
                    deactivate(gameNode);
                }
            }
        }
    }
    
    private function activate(comp : GameComponent) : Void
    {
        if (Std.is(comp, GameEdgeContainer))
        {
            var edge : GameEdgeContainer = try cast(comp, GameEdgeContainer) catch(e:Dynamic) null;
            m_edgesContainer.addChild(edge);
            if (edge.socket != null)
            {
                m_plugsContainer.addChild(edge.socket);
            }
            if (edge.plug != null)
            {
                m_plugsContainer.addChild(edge.plug);
            }
        }
        else if (Std.is(comp, GameNode))
        {
            m_nodesContainer.addChild(comp);
        }
    }
    
    private function deactivate(comp : GameComponent) : Void
    {
        if (Std.is(comp, GameEdgeContainer))
        {
            var edge : GameEdgeContainer = try cast(comp, GameEdgeContainer) catch(e:Dynamic) null;
            m_edgesInactiveContainer.addChild(edge);
            if (edge.socket != null)
            {
                m_plugsInactiveContainer.addChild(edge.socket);
            }
            if (edge.plug != null)
            {
                m_plugsInactiveContainer.addChild(edge.plug);
            }
        }
        else if (Std.is(comp, GameNode))
        {
            m_nodesInactiveContainer.addChild(comp);
        }
    }
    
    private function refreshTroublePoints() : Void
    {
        for (edgeId in Reflect.fields(m_gameEdgeDict))
        {
            var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
            gameEdge.refreshConflicts();
        }
    }
    
    //data object should be in final selected/unselected state
    private function componentSelectionChanged(component : GameComponent, selected : Bool) : Void
    {
        if (selected)
        {
            if (Lambda.indexOf(selectedComponents, component) == -1)
            {
                selectedComponents.push(component);
            }
            //push any connecting edges that have both connected nodes selected
            if (Std.is(component, GameNodeBase))
            {
                for (edge in (try cast(component, GameNodeBase) catch(e:Dynamic) null).orderedIncomingEdges)
                {
                    var fromComponent : GameNodeBase = edge.m_fromNode;
                    if (Lambda.indexOf(selectedComponents, fromComponent) != -1)
                    {
                        if (Lambda.indexOf(selectedComponents, edge) == -1)
                        {
                            selectedComponents.push(edge);
                        }
                        edge.componentSelected(true);
                    }
                }
                for (edge1 in (try cast(component, GameNodeBase) catch(e:Dynamic) null).orderedOutgoingEdges)
                {
                    var toComponent : GameNodeBase = edge1.m_toNode;
                    if (Lambda.indexOf(selectedComponents, toComponent) != -1)
                    {
                        if (Lambda.indexOf(selectedComponents, edge1) == -1)
                        {
                            selectedComponents.push(edge1);
                        }
                        edge1.componentSelected(true);
                    }
                }
            }
        }
        else
        {
            var index : Int = Lambda.indexOf(selectedComponents, component);
            if (index != -1)
            {
                selectedComponents.splice(index, 1);
            }
            if (Std.is(component, GameNodeBase))
            {
                for (edge2 in (try cast(component, GameNodeBase) catch(e:Dynamic) null).orderedIncomingEdges)
                {
                    if (Lambda.indexOf(selectedComponents, edge2) != -1)
                    {
                        var edgeIndex : Int = Lambda.indexOf(selectedComponents, edge2);
                        selectedComponents.splice(edgeIndex, 1);
                        edge2.componentSelected(false);
                    }
                }
                for (edge3 in (try cast(component, GameNodeBase) catch(e:Dynamic) null).orderedOutgoingEdges)
                {
                    if (Lambda.indexOf(selectedComponents, edge3) != -1)
                    {
                        var edgeIndex1 : Int = Lambda.indexOf(selectedComponents, edge3);
                        selectedComponents.splice(edgeIndex1, 1);
                        edge3.componentSelected(false);
                    }
                }
            }
        }
    }
    
    private function onComponentSelection(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            componentSelectionChanged(component, true);
        }
        
        var selectionChangedComponents : Array<GameComponent> = new Array<GameComponent>();
        selectionChangedComponents.push(component);
        addSelectionUndoEvent(selectionChangedComponents, true);
    }
    
    private function onComponentUnselection(evt : GameComponentEvent) : Void
    {
        var component : GameComponent = evt.component;
        if (component != null)
        {
            componentSelectionChanged(component, false);
        }
        
        var selectionChangedComponents : Array<GameComponent> = new Array<GameComponent>();
        selectionChangedComponents.push(component);
        addSelectionUndoEvent(selectionChangedComponents, false);
    }
    
    private function onGroupSelection(evt : GroupSelectionEvent) : Void
    {
        var selectionChangedComponents : Array<GameComponent> = evt.selection.copy();
        for (comp in selectionChangedComponents)
        {
            comp.componentSelected(true);
            componentSelectionChanged(comp, true);
        }
        addSelectionUndoEvent(evt.selection.copy(), true, true);
    }
    
    private function onGroupUnselection(evt : GroupSelectionEvent) : Void
    {
        var selectionChangedComponents : Array<GameComponent> = evt.selection.copy();
        for (comp in selectionChangedComponents)
        {
            comp.componentSelected(false);
            componentSelectionChanged(comp, false);
        }
        addSelectionUndoEvent(evt.selection.copy(), false);
    }
    
    private function onFinishedMoving(evt : MoveEvent) : Void
    // Recalc bounds
    {
        
        var minX : Float;
        var minY : Float;
        var maxX : Float;
        var maxY : Float;
        minX = minY = Math.POSITIVE_INFINITY;
        maxX = maxY = Math.NEGATIVE_INFINITY;
        var i : Int;
        if (Std.is(evt.component, GameNodeBase))
        {
        // If moved node, check those bounds - otherwise assume they're unchanged
            
            for (nodeId in Reflect.fields(m_gameNodeDict))
            {
                var gameNode : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
                minX = Math.min(minX, gameNode.boundingBox.left);
                minY = Math.min(minY, gameNode.boundingBox.top);
                maxX = Math.max(maxX, gameNode.boundingBox.right);
                maxY = Math.max(maxY, gameNode.boundingBox.bottom);
            }
        }
        for (edgeId in Reflect.fields(m_gameEdgeDict))
        {
            var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
            minX = Math.min(minX, gameEdge.boundingBox.left);
            minY = Math.min(minY, gameEdge.boundingBox.top);
            maxX = Math.max(maxX, gameEdge.boundingBox.right);
            maxY = Math.max(maxY, gameEdge.boundingBox.bottom);
        }
        var oldBB : Rectangle = m_boundingBox.clone();
        m_boundingBox = new Rectangle(minX, minY, maxX - minX, maxY - minY);
        if (oldBB.x != m_boundingBox.x ||
            oldBB.y != m_boundingBox.y ||
            oldBB.width != m_boundingBox.width ||
            oldBB.height != m_boundingBox.height)
        {
            dispatchEvent(new MiniMapEvent(MiniMapEvent.LEVEL_RESIZED));
        }
    }
    
    private function onErrorAdded(evt : ErrorEvent) : Void
    {
        Reflect.setField(errorConstraintDict, evt.constraintError.id, evt.constraintError);
    }
    
    private function onErrorRemoved(evt : ErrorEvent) : Void
    {
		Reflect.deleteField(errorConstraintDict, evt.constraintError.id);
    }
    
    private function addSelectionUndoEvent(selection : Array<GameComponent>, selected : Bool, addToLast : Bool = false) : Void
    {
        if (selection.length == 0)
        {
            return;
        }
        var component : GameComponent = selection[0];
        var eventToUndo : Event;
        if (selected)
        {
            eventToUndo = new GroupSelectionEvent(GroupSelectionEvent.GROUP_SELECTED, component, selection);
        }
        else
        {
            eventToUndo = new GroupSelectionEvent(GroupSelectionEvent.GROUP_UNSELECTED, component, selection);
        }
        var eventToDispatch : UndoEvent = new UndoEvent(eventToUndo, this);
        eventToDispatch.addToLast = addToLast;
        dispatchEvent(eventToDispatch);
    }
    
    public function unselectAll(addEventToLast : Bool = false) : Void
    //make a copy of the selected list for the undo event
    {
        
        var currentSelection : Array<GameComponent> = selectedComponents.copy();
        totalMoveDist = new Point();
        selectedComponents = new Array<GameComponent>();
        
        for (comp in currentSelection)
        {
            comp.componentSelected(false);
            componentSelectionChanged(comp, false);
        }
        
        if (currentSelection.length > 0)
        {
            addSelectionUndoEvent(currentSelection, false, addEventToLast);
        }
    }
    
    private function onMoveEvent(evt : MoveEvent) : Void
    {
        var delta : Point = evt.delta;
        var newLeft : Float = m_boundingBox.left;
        var newRight : Float = m_boundingBox.right;
        var newTop : Float = m_boundingBox.top;
        var newBottom : Float = m_boundingBox.bottom;
        var movedNodes : Array<GameNode> = new Array<GameNode>();
        //if component isn't in the currently selected group, unselect everything, and then move component
        if (Lambda.indexOf(selectedComponents, evt.component) == -1)
        {
            unselectAll();
            evt.component.componentMoved(delta);
            newLeft = Math.min(newLeft, evt.component.boundingBox.left);
            newRight = Math.max(newRight, evt.component.boundingBox.left);
            newTop = Math.min(newTop, evt.component.boundingBox.top);
            newBottom = Math.max(newBottom, evt.component.boundingBox.bottom);
            if (tutorialManager != null && (Std.is(evt.component, GameNode)))
            {
                movedNodes.push(try cast(evt.component, GameNode) catch(e:Dynamic) null);
                tutorialManager.onGameNodeMoved(movedNodes);
            }
        }
        //if (selectedComponents.length == 0) {
        else
        {
            
            //	totalMoveDist = new Point();
            //	return;
            //}
            var movedGameNode : Bool = false;
            for (component in selectedComponents)
            {
                component.componentMoved(delta);
                newLeft = Math.min(newLeft, component.boundingBox.left);
                newRight = Math.max(newRight, component.boundingBox.left);
                newTop = Math.min(newTop, component.boundingBox.top);
                newBottom = Math.max(newBottom, component.boundingBox.bottom);
                
                if (Std.is(component, GameNode))
                {
                    movedNodes.push(try cast(component, GameNode) catch(e:Dynamic) null);
                    movedGameNode = true;
                }
            }
            if (tutorialManager != null && movedGameNode)
            {
                tutorialManager.onGameNodeMoved(movedNodes);
            }
        }
        totalMoveDist.x += delta.x;
        totalMoveDist.y += delta.y;
        //trace(totalMoveDist);
        dispatchEvent(new MiniMapEvent(MiniMapEvent.ERRORS_MOVED));
        m_boundingBox = new Rectangle(newLeft, newTop, newRight - newLeft, newBottom - newTop);
    }
    
    override public function handleUndoEvent(undoEvent : Event, isUndo : Bool = true) : Void
    {
        if (Std.is(undoEvent, GroupSelectionEvent))
        {
        //individual selections come through here also
            
            {
                var groupEvt : GroupSelectionEvent = try cast(undoEvent, GroupSelectionEvent) catch(e:Dynamic) null;
                if (groupEvt.selection != null)
                {
                    for (selectedComp in groupEvt.selection)
                    {
                        if (Std.is(selectedComp, GameNodeBase))
                        {
                            var performSelection : Bool;
                            if (undoEvent.type == GroupSelectionEvent.GROUP_SELECTED)
                            {
                                performSelection = !isUndo;
                            }
                            else
                            {
                                performSelection = isUndo;
                            }
                            selectedComp.componentSelected(performSelection);
                            componentSelectionChanged(try cast(selectedComp, GameNodeBase) catch(e:Dynamic) null, performSelection);
                        }
                    }
                }
            }
        }
        else if (Std.is(undoEvent, MoveEvent))
        {
            var moveEvt : MoveEvent = try cast(undoEvent, MoveEvent) catch(e:Dynamic) null;
            var delta : Point;
            if (!isUndo)
            {
                delta = moveEvt.delta.clone();
            }
            else
            {
                delta = new Point(-moveEvt.delta.x, -moveEvt.delta.y);
            }
            //trace("isUndo:" + isUndo + " delta:" + delta);
            //not added as a temp selection, so move separately
            if (moveEvt.component != null)
            {
                moveEvt.component.componentMoved(delta);
            }
            for (selectedComponent in selectedComponents)
            {
                if (moveEvt.component != selectedComponent)
                {
                    selectedComponent.componentMoved(delta);
                }
            }
        }
    }
    
    //to be called once to set everything up
    //to move/update objects use update events
    public function draw() : Void
    //trace("Bounding Box " + m_boundingBox);
    {
        
        var maxX : Float = Math.NEGATIVE_INFINITY;
        var maxY : Float = Math.NEGATIVE_INFINITY;
        
        var nodeCount : Int = 0;
        for (nodeId in Reflect.fields(m_gameNodeDict))
        {
            var gameNode : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
            gameNode.x = gameNode.boundingBox.x;
            gameNode.y = gameNode.boundingBox.y;
            gameNode.m_isDirty = true;
            m_nodesContainer.addChild(gameNode);
            nodeCount++;
        }
        
        var edgeCount : Int = 0;
        for (edgeId in Reflect.fields(m_gameEdgeDict))
        {
            var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
            gameEdge.m_isDirty = true;
            m_edgesContainer.addChild(gameEdge);
            m_errorContainer.addChild(gameEdge.errorContainer);
            if (gameEdge.socket != null)
            {
                m_plugsContainer.addChild(gameEdge.socket);
            }
            if (gameEdge.plug != null)
            {
                m_plugsContainer.addChild(gameEdge.plug);
            }
            edgeCount++;
        }
        
        trace("Nodes " + nodeCount + " Edges " + edgeCount);
        if (m_backgroundImage != null)
        {
            m_backgroundImage.width = m_backgroundImage.height = 2 * MIN_BORDER + Math.max(m_boundingBox.width, m_boundingBox.height);
            m_backgroundImage.x = m_backgroundImage.y = -MIN_BORDER - 0.5 * Math.max(m_boundingBox.x, m_boundingBox.y);
            var texturesToRepeat : Float = (50.0 / Constants.GAME_SCALE) * (m_backgroundImage.width / BG_WIDTH);
            m_backgroundImage.setTexCoords(1, texturesToRepeat, 0.0);
            m_backgroundImage.setTexCoords(2, 0.0, texturesToRepeat);
            m_backgroundImage.setTexCoords(3, texturesToRepeat, texturesToRepeat);
        }
    }
    
    private static function getVisible(_layoutObj : Dynamic, _defaultValue : Bool = true) : Bool
    {
        var value : String = Reflect.field(_layoutObj, "visible");
        if (value == null)
        {
            return _defaultValue;
        }
        return XString.stringToBool(value);
    }
    
    public function handleMarquee(startingPoint : Point, currentPoint : Point) : Void
    {
        if (m_layoutFixed)
        {
            return;
        }
        
        if (startingPoint != null)
        {
			// TODO: refactor this to be drawable
            marqueeRect.removeChildren();
            //scale line size
            //var lineSize : Float = 1 / (Math.max(parent.scaleX, parent.scaleY));
            //marqueeRect.graphics.lineStyle(lineSize, 0xffffff);
            //marqueeRect.graphics.moveTo(0, 0);
            //var pt1 : Point = globalToLocal(startingPoint);
            //var pt2 : Point = globalToLocal(currentPoint);
            //marqueeRect.graphics.lineTo(pt2.x - pt1.x, 0);
            //marqueeRect.graphics.lineTo(pt2.x - pt1.x, pt2.y - pt1.y);
            //marqueeRect.graphics.lineTo(0, pt2.y - pt1.y);
            //marqueeRect.graphics.lineTo(0, 0);
            //marqueeRect.x = pt1.x;
            //marqueeRect.y = pt1.y;
            //do here to make sure we are on top
            addChild(marqueeRect);
        }
        else
        {
            var newSelectedComponents : Array<GameComponent> = new Array<GameComponent>();
            var newUnselectedComponents : Array<GameComponent> = new Array<GameComponent>();
            
            for (nodeId in Reflect.fields(m_gameNodeDict))
            {
                var gameNode : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
                handleSelection(gameNode, newSelectedComponents, newUnselectedComponents);
            }
            removeChild(marqueeRect);
            
            addSelectionUndoEvent(newSelectedComponents, true);
            addSelectionUndoEvent(newUnselectedComponents, false, true);
        }
    }
    
    private function handleSelection(node : GameNodeBase, newSelectedComponents : Array<GameComponent>, newUnselectedComponents : Array<GameComponent>) : Void
    {
        var bottomRight : Point = globalToLocal(node.bounds.bottomRight);
        var topLeft : Point = globalToLocal(node.bounds.topLeft);
        var topRight : Point = globalToLocal(new Point(node.bounds.right, node.bounds.top));
        var bottomLeft : Point = globalToLocal(new Point(node.bounds.left, node.bounds.bottom));
        var mbottomLeft : Point = globalToLocal(new Point(marqueeRect.x, marqueeRect.y));
        
        if ((marqueeRect.bounds.left < node.bounds.left && marqueeRect.bounds.right > node.bounds.left) ||
            (marqueeRect.bounds.left < node.bounds.right && marqueeRect.bounds.right > node.bounds.right))
        {
            if ((marqueeRect.bounds.top < node.bounds.bottom && marqueeRect.bounds.bottom > node.bounds.bottom) ||
                (marqueeRect.bounds.top < node.bounds.top && marqueeRect.bounds.bottom > node.bounds.top))
            {
                node.componentSelected(!node.isSelected);
                if (node.isSelected)
                {
                    if ((Lambda.indexOf(selectedComponents, node) == -1) && (Lambda.indexOf(newSelectedComponents, node) == -1))
                    {
                        newSelectedComponents.push(node);
                    }
                }
                else if ((Lambda.indexOf(selectedComponents, node) > -1) && (Lambda.indexOf(newUnselectedComponents, node) == -1))
                {
                    newUnselectedComponents.push(node);
                }
                componentSelectionChanged(node, node.isSelected);
            }
        }
    }
    
    public function toggleUneditableStrings() : Void
    {
        var visitedNodes : Map<String, GameNode> = new Map<String, GameNode>();
        for (nodeId in Reflect.fields(m_gameNodeDict))
        {
            var node : GameNode = try cast(Reflect.field(m_gameNodeDict, nodeId), GameNode) catch(e:Dynamic) null;
            if (visitedNodes[node.m_id] == null)
            {
                visitedNodes.set(node.m_id, node);
                var groupDictionary : Dynamic = {};
                node.findGroup(groupDictionary);
                //check for an editable node
                var uneditable : Bool = true;
				var comp = null;
                for (id in Reflect.fields(groupDictionary))
                {
					comp = Reflect.field(groupDictionary, id);
                    if (comp.m_isEditable)
                    {
                        uneditable = false;
                        break;
                    }
                }
                if (uneditable)
                {
                    for (id in Reflect.fields(groupDictionary))
                    {
						var comp1 : GameNode = try cast(Reflect.field(groupDictionary, id), GameNode) catch (e : Dynamic) null;
                        comp1.hideComponent(comp.visible);
						visitedNodes.set(comp1.m_id, comp1);
                    }
                }
            }
        }
    }
    
    public function getNode(_id : String) : GameNode
    {
        if (Reflect.hasField(m_gameNodeDict, _id) && (Std.is(Reflect.field(m_gameNodeDict, _id), GameNode)))
        {
            return (try cast(Reflect.field(m_gameNodeDict, _id), GameNode) catch(e:Dynamic) null);
        }
        return null;
    }
    
    public function getEdges() : Dynamic
    {
        return m_gameEdgeDict;
    }
    
    public function getEdgeContainer(_id : String) : GameEdgeContainer
    {
        if (Reflect.hasField(m_gameEdgeDict, _id) && (Std.is(Reflect.field(m_gameEdgeDict, _id), GameEdgeContainer)))
        {
            return (try cast(Reflect.field(m_gameEdgeDict, _id), GameEdgeContainer) catch(e:Dynamic) null);
        }
        return null;
    }
    
    public function getNodes() : Dynamic
    {
        return m_gameNodeDict;
    }
    
    public function getLevelTextInfo() : TutorialManagerTextInfo
    {
        return (tutorialManager != null) ? tutorialManager.getTextInfo() : null;
    }
    
    public function getLevelToolTipsInfo() : Array<TutorialManagerTextInfo>
    {
        return (tutorialManager != null) ? tutorialManager.getPersistentToolTipsInfo() : (new Array<TutorialManagerTextInfo>());
    }
    
    public function getTargetScore() : Int
    {
        return m_targetScore;
    }
    
    public function setTargetScore(score : Int) : Void
    {
        m_targetScore = score;
    }
    
    public function getTimeMs() : Float
    {
        return Date.now().getTime() - m_levelStartTime;
    }
    
    public function hideErrorText() : Void
    {
        if (!m_hidingErrorText)
        {
            for (edgeId in Reflect.fields(m_gameEdgeDict))
            {
                var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
                gameEdge.hideErrorText();
            }
            m_hidingErrorText = true;
        }
    }
    
    public function showErrorText() : Void
    {
        if (m_hidingErrorText)
        {
            for (edgeId in Reflect.fields(m_gameEdgeDict))
            {
                var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
                gameEdge.showErrorText();
            }
            m_hidingErrorText = false;
        }
    }
    
    /**
		 * Get next conflict: used for conflict scrolling
		 * @param	forward True to scroll forward, false to scroll backwards
		 * @return Conflict DisplayObject (if any exist)
		 */
    public function getNextConflict(forward : Bool) : DisplayObject
    {
        if (m_conflictEdgesDirty)
        {
            for (edgeId in Reflect.fields(m_gameEdgeDict))
            {
                var gameEdge : GameEdgeContainer = try cast(Reflect.field(m_gameEdgeDict, edgeId), GameEdgeContainer) catch(e:Dynamic) null;
                if (gameEdge.hasError())
                {
                    if (!Reflect.hasField(m_levelConflictEdgeDict, gameEdge.m_id))
                    {
                    // Add to list/dict if not on there already
                        
                        if (Lambda.indexOf(m_levelConflictEdges, gameEdge) == -1)
                        {
                            m_levelConflictEdges.push(gameEdge);
                        }
                        Reflect.setField(m_levelConflictEdgeDict, gameEdge.m_id, true);
                    }
                }
                else if (Reflect.hasField(m_levelConflictEdgeDict, gameEdge.m_id))
                {
                // Remove from edge conflict list/dict if on it
                    
                    var delindx : Int = Lambda.indexOf(m_levelConflictEdges, gameEdge);
                    if (delindx > -1)
                    {
                        m_levelConflictEdges.splice(delindx, 1);
                    }
					Reflect.deleteField(m_levelConflictEdgeDict, gameEdge.m_id);
                }
            }
            m_conflictEdgesDirty = false;
        }
        //keep track of number of conflicts
        PipeJamGame.levelInfo.conflicts = m_levelConflictEdges.length;
        
        if (m_levelConflictEdges.length == 0)
        {
            return null;
        }
        if (forward)
        {
            m_currentConflictIndex++;
        }
        else
        {
            m_currentConflictIndex--;
        }
        if (m_currentConflictIndex >= m_levelConflictEdges.length)
        {
            m_currentConflictIndex = 0;
        }
        else if (m_currentConflictIndex < 0)
        {
            m_currentConflictIndex = m_levelConflictEdges.length - 1;
        }
        return m_levelConflictEdges[m_currentConflictIndex].errorContainer;
    }
 
    public function getPanZoomAllowed() : Bool
    {
        if (tutorialManager != null)
        {
            return tutorialManager.getPanZoomAllowed();
        }
        return true;
    }
    
    public function getSolveButtonsAllowed() : Bool
    {
        if (tutorialManager != null)
        {
            return tutorialManager.getSolveButtonsAllowed();
        }
        return true;
    }
    
    public static var SEGMENT_DELETION_ENABLED : Bool = false;
    public function onDeletePressed() : Void
    // Only delete if layout moves are allowed
    {
        
        if (tutorialManager != null && tutorialManager.getLayoutFixed())
        {
            return;
        }
        if (!SEGMENT_DELETION_ENABLED)
        {
            return;
        }
        if (m_segmentHovered != null)
        {
            m_segmentHovered.onDeleted();
        }
    }
    
    public function onUseSelectionPressed(choice : String) : Void
    {
        var assignmentIsWide : Bool = false;
        if (choice == MenuEvent.MAKE_SELECTION_WIDE)
        {
            assignmentIsWide = true;
        }
        else if (choice == MenuEvent.MAKE_SELECTION_NARROW)
        {
            assignmentIsWide = false;
        }
        
        var gameNode : GameNode;
        for (i in 0...selectedComponents.length)
        {
            var component : GameComponent = selectedComponents[i];
            if (Std.is(component, GameNode))
            {
                gameNode = try cast(component, GameNode) catch(e:Dynamic) null;
                if (gameNode.m_isEditable)
                {
                    gameNode.constraintVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
                }
            }
        }
        //update score
        onWidgetChange();
    }
    
    private function get_currentScore() : Int
    {
        return levelGraph.currentScore;
    }
    private function get_bestScore() : Int
    {
        return m_bestScore;
    }
    private function get_startingScore() : Int
    {
        return Std.int(levelGraph.startingScore);
    }
    private function get_prevScore() : Int
    {
        return levelGraph.prevScore;
    }
    private function get_oldScore() : Int
    {
        return levelGraph.oldScore;
    }
    
    public function resetBestScore() : Void
    {
        m_bestScore = levelGraph.currentScore;
        m_levelBestScoreAssignmentsObj = XObject.clone(m_levelAssignmentsObj);
    }
    
    public function onScoreChange(recordBestScore : Bool = false, logChange : Bool = true) : Void
    {
        if (recordBestScore && (levelGraph.currentScore > m_bestScore))
        {
            m_bestScore = levelGraph.currentScore;
            trace("New best score: " + m_bestScore);
            m_levelBestScoreAssignmentsObj = createAssignmentsObj();
            //don't update on loading
            if (m_tutorialTag == null && levelGraph.oldScore != 0)
            {
                dispatchEvent(new MenuEvent(MenuEvent.SUBMIT_LEVEL));
            }
        }
        if (logChange && levelGraph.prevScore != levelGraph.currentScore)
        {
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
        }
        m_conflictEdgesDirty = true;
    }
    
    public function solveSelection(updateCallback : Function, doneCallback : Function) : Void
    //figure out which edges have both start and end components selected (all included edges have both ends selected?)
    {
        
        //assign connected components to component to edge constraint number dict
        //create three constraints for conflicts and weights
        //run the solver, passing in the callback function
        nodeIDToConstraintsTwoWayMap = {};
        var counter : Int = 1;
        var constraintArray : Array<Dynamic> = new Array<Dynamic>();
        var initvarsArray : Array<Dynamic> = new Array<Dynamic>();
        for (i in 0...selectedComponents.length)
        {
            var constraint1Value : Int = -1;
            var constraint2Value : Int = -1;
            var component : GameComponent = selectedComponents[i];
            if (Std.is(component, GameEdgeContainer))
            {
                var edge : GameEdgeContainer = try cast(component, GameEdgeContainer) catch(e:Dynamic) null;
                var fromNode : GameNodeBase = edge.m_fromNode;
                var toNode : GameNodeBase = edge.m_toNode;
                
                if (fromNode.m_isEditable)
                {
                    if (!Reflect.hasField(nodeIDToConstraintsTwoWayMap, fromNode.m_id))
                    {
                        Reflect.setField(nodeIDToConstraintsTwoWayMap, fromNode.m_id, counter);
                        Reflect.setField(nodeIDToConstraintsTwoWayMap, Std.string(counter), fromNode.constraintVar);
                        constraint1Value = counter;
                        counter++;
                    }
                    else
                    {
                        constraint1Value = Reflect.field(nodeIDToConstraintsTwoWayMap, fromNode.m_id);
                    }
                }
                
                if (toNode.m_isEditable)
                {
                    if (!Reflect.hasField(nodeIDToConstraintsTwoWayMap, toNode.m_id))
                    {
                        Reflect.setField(nodeIDToConstraintsTwoWayMap, toNode.m_id, counter);
                        Reflect.setField(nodeIDToConstraintsTwoWayMap, Std.string(counter), toNode.constraintVar);
                        constraint2Value = counter;
                        counter++;
                    }
                    else
                    {
                        constraint2Value = Reflect.field(nodeIDToConstraintsTwoWayMap, toNode.m_id);
                    }
                }
                
                if (fromNode.m_isEditable && toNode.m_isEditable)
                {
					var arr = new Array<Dynamic>();
					arr.push(100);
					arr.push(-constraint1Value);
					arr.push(constraint2Value);
                    constraintArray.push(arr);
                }
                else if (fromNode.m_isEditable && !toNode.m_isEditable)
                {
                    if (!toNode.m_isWide)
                    {
						var arr = new Array<Dynamic>();
						arr.push(100);
						arr.push(-constraint1Value);
                        constraintArray.push(arr);
                    }
                }
                if (!fromNode.m_isEditable && toNode.m_isEditable)
                {
                    if (fromNode.m_isWide)
                    {
						var arr = new Array<Dynamic>();
						arr.push(100);
						arr.push(constraint2Value);
                        constraintArray.push(arr);
                    }
                }
            }
            else if (Std.is(component, GameNode))
            {
                var node : GameNode = try cast(component, GameNode) catch(e:Dynamic) null;
                if (node.m_isEditable)
                {
                    if (!Reflect.hasField(nodeIDToConstraintsTwoWayMap, node.m_id))
                    {
                        Reflect.setField(nodeIDToConstraintsTwoWayMap, node.m_id, counter);
                        Reflect.setField(nodeIDToConstraintsTwoWayMap, Std.string(counter), node.constraintVar);
                        constraint1Value = counter;
                        counter++;
                    }
                    else
                    {
                        constraint1Value = Reflect.field(nodeIDToConstraintsTwoWayMap, node.m_id);
                    }
                    
					var arr = new Array<Dynamic>();
					arr.push(1);
					arr.push(constraint1Value);
                    constraintArray.push(arr);
                }
            }
        }
        
        if (constraintArray.length > 0)
        {
        //generate initvars array
            
            for (ii in 1...counter)
            {
                var constraintVar : ConstraintVar = try cast(nodeIDToConstraintsTwoWayMap[ii], ConstraintVar) catch(e:Dynamic) null;
                if (!constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW))
                {
                    initvarsArray.push(1);
                }
                else
                {
                    initvarsArray.push(0);
                }
            }
            m_inSolver = true;
            MaxSatSolver.run_solver(constraintArray, initvarsArray, updateCallback, doneCallback);
        }
    }
    
    public function solverUpdate(vars : Array<Dynamic>, unsat_weight : Int) : Void
    {
        var constraintVar : ConstraintVar;
        var assignmentIsWide : Bool = false;
        
        if (m_inSolver == false)
        {
        //got marked done early
            
            return;
        }
        
        for (ii in 0...vars.length)
        {
            constraintVar = try cast(nodeIDToConstraintsTwoWayMap[ii + 1], ConstraintVar) catch(e:Dynamic) null;
            assignmentIsWide = false;
            if (vars[ii] == 1)
            {
                assignmentIsWide = true;
            }
            if (constraintVar != null)
            {
                constraintVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
            }
        }
        onWidgetChange();
    }
    
    public function solverDone(errMsg : String) : Void
    {
        m_inSolver = false;
        MaxSatSolver.stop_solver();
        levelGraph.updateScore();
        onScoreChange(true);
    }
}
