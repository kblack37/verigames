package scenes.game.display;

import constraints.Constraint;
import constraints.ConstraintClause;
import constraints.ConstraintEdge;
import constraints.ConstraintGraph;
import constraints.ConstraintScoringConfig;
import constraints.ConstraintValue;
import constraints.ConstraintVar;
import constraints.events.ErrorEvent;
import constraints.events.VarChangeEvent;
import events.MenuEvent;
import events.MiniMapEvent;
import events.PropertyModeChangeEvent;
import events.SelectionEvent;
import events.WidgetChangeEvent;
import flash.errors.Error;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;
import haxe.Constraints.Function;
import networking.PlayerValidation;
import scenes.BaseComponent;
import scenes.game.PipeJamGameScene;
import scenes.game.components.GridViewPanel;
import scenes.game.components.MiniMap;
import scenes.game.display.Node;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.TouchEvent;
import system.MaxSatSolver;
import system.VerigameServerConstants;
import utils.PropDictionary;
import utils.XObject;
import utils.XString;
//import deng.fzip.FZip;




/**
	 * Level all game components - widgets and links
	 */
class Level extends BaseComponent
{
    public var currentScore(get, never) : Int;
    public var bestScore(get, never) : Int;
    public var maxScore(get, never) : Int;
    public var startingScore(get, never) : Int;
    public var prevScore(get, never) : Int;
    public var oldScore(get, never) : Int;

    /** True to allow user to navigate to any level regardless of whether levels below it are solved for debugging */
    public static var UNLOCK_ALL_LEVELS_FOR_DEBUG : Bool = false;
    private static var MIN_NODE_SCALE : Float = 4.0 / Constants.GAME_SCALE;
    
    /** Name of this level */
    public var level_name : String;
    
    /** Node collection used to create this level, including name obfuscater */
    public var levelGraph : ConstraintGraph;
    
    public var selectedNodes : Array<Node> = new Array<Node>();
    /** used by solver to keep track of which nodes map to which constraint values, and visa versa */
    private var nodeIDToConstraintsTwoWayMap : Map<Int, Node>;
    
    //the level node and decendents
    private var m_levelLayoutObj : Dynamic;
    public var levelObj : Dynamic;
    public var m_levelLayoutName : String;
    public var m_levelQID : String;
    //used when saving, as we need a parent graph element for the above level node
    public var m_levelLayoutObjWrapper : Dynamic;
    public var m_levelAssignmentsObj : Dynamic;
    private var m_levelOriginalAssignmentsObj : Dynamic;  //used for restarting the level  
    private var m_levelBestScoreAssignmentsObj : Dynamic;  //best configuration so far  
    public var m_tutorialTag : String;
    public var tutorialManager : TutorialLevelManager;
    private var m_layoutFixed : Bool = false;
    public var m_targetScore : Int;
    
    public var m_numNodes : Int = 0;
    public var nodeLayoutObjs : Dynamic = {};
    public var edgeLayoutObjs : Dynamic = {};
    
    private var m_hidingErrorText : Bool = false;
    
    public var m_boundingBox : Rectangle = new Rectangle(0, 0, 1, 1);
    private var m_backgroundImage : Image;
    private var m_levelStartTime : Float;
    
    private var initialized : Bool = false;
    
    /** Current Score of the player */
    private var m_bestScore : Int = 0;
    
    /** Set to true when the target score is reached. */
    public var targetScoreReached : Bool;
    public var original_level_name : String;
    
    public var brushesToActivate : Int;
    public var currentGroupDepth : Int = -1;
    public var levelLayoutScale : Float = 1.0;
    private var m_nodeAnimationLayer : Sprite;
    private var m_nodeLayer : Sprite;
    private var m_nodeClauseSubLayer : Sprite;
    private var m_nodeVarSubLayer : Sprite;
    private var m_edgesLayer : Sprite;
    private var m_conflictAnimationLayer : Sprite;
    private var m_conflictsLayer : Sprite;
    private var m_offscreenEdgesLayer : Sprite;
    private var m_nodesToRemove : Map<String, Node> = new Map<String, Node>();
    private var m_nodesToDraw : Map<String, Node> = new Map<String, Node>();
    private var m_solvingNodesToAnimate : Map<String, Node> = new Map<String, Node>();
    private var m_solvedConflictsToAnimate : Map<String, Node> = new Map<String, Node>();
    private var m_createdConflictsToAnimate : Array<ClauseNode> = new Array<ClauseNode>();
    private var m_nodeOnScreenDict : Map<String, Node> = new Map<String, Node>();
    private var m_groupGrids : Array<GroupGrid>;
    private static inline var ITEMS_PER_FRAME : Int = 300;  // limit on nodes/edges to remove/add per frame  
    
    public static var CONFLICT_CONSTRAINT_VALUE : Float = 10.0;
    public static var FIXED_CONSTRAINT_VALUE : Float = 1000.0;
    public static var WIDE_NODE_SIZE_CONSTRAINT_VALUE : Float = 1.0;
    public static var NARROW_NODE_SIZE_CONSTRAINT_VALUE : Float = 0.0;
    
    /** Tracks total distance components have been dragged since last visibile calculation */
    public var totalMoveDist : Point = new Point();
    
    public var m_inSolver : Bool = false;
    private var m_unsat_weight : Int = -1;
    private var m_recentlySolved : Bool;
    public var solverSelected : Array<Node> = new Array<Node>();
    
    public static var debugSolver : Bool = false;
    public var extendSolver : Bool = true;
    
    public static var numNodesOnScreen : Int = 0;
    
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
    public function new(_name : String, _levelGraph : ConstraintGraph, _levelObj : Dynamic, _levelLayoutObj : Dynamic, _levelAssignmentsObj : Dynamic, _originalLevelName : String)
    {
        super();
        UNLOCK_ALL_LEVELS_FOR_DEBUG = PipeJamGame.DEBUG_MODE;
        level_name = _name;
        original_level_name = _originalLevelName;
        levelGraph = _levelGraph;
        levelObj = _levelObj;
        m_levelLayoutObj = _levelLayoutObj;
        m_levelLayoutName = Reflect.field(_levelLayoutObj, "id");
        m_levelQID = Reflect.field(_levelObj, "qid");
        m_levelBestScoreAssignmentsObj = _levelAssignmentsObj;  // XObject.clone(_levelAssignmentsObj);  
        m_levelOriginalAssignmentsObj = _levelAssignmentsObj;  // XObject.clone(_levelAssignmentsObj);  
        m_levelAssignmentsObj = _levelAssignmentsObj;  // XObject.clone(_levelAssignmentsObj);  
        
        m_tutorialTag = Reflect.field(m_levelLayoutObj, "tutorial");
        if (m_tutorialTag != null)
        {
            tutorialManager = new TutorialLevelManager(m_tutorialTag);
            m_layoutFixed = tutorialManager.getLayoutFixed();
        }
        
        if (levelGraph.graphScoringConfig && levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY))
        {
            CONFLICT_CONSTRAINT_VALUE = levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
        }
        
        if (levelGraph.graphScoringConfig && levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY))
        {
            WIDE_NODE_SIZE_CONSTRAINT_VALUE = levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY);
        }
        
        if (levelGraph.graphScoringConfig && levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY))
        {
            NARROW_NODE_SIZE_CONSTRAINT_VALUE = levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY);
        }
        
        m_targetScore = as3hx.Compat.INT_MAX;
        if (PipeJam3.ASSET_SUFFIX == "Turk")
        {
            m_targetScore = 0;
            for (key in Reflect.fields(nodeLayoutObjs))
            {
                if (Std.is(Reflect.field(nodeLayoutObjs, key), ClauseNode))
                {
                    m_targetScore++;
                }
            }
        }
        else if ((Reflect.field(m_levelAssignmentsObj, "target_score") != null) && !Math.isNaN(as3hx.Compat.parseInt(Reflect.field(m_levelAssignmentsObj, "target_score"))))
        {
            m_targetScore = as3hx.Compat.parseInt(Reflect.field(m_levelAssignmentsObj, "target_score"));
            //now check to see if we have a higher target if not in tutorial
            if (!PipeJamGameScene.inTutorial)
            {
                if (PipeJamGame.levelInfo && PipeJamGame.levelInfo.target_score && m_targetScore < PipeJamGame.levelInfo.target_score)
                {
                    m_targetScore = PipeJamGame.levelInfo.target_score;
                }
            }
        }
        else
        {
            m_targetScore = PipeJamGame.levelInfo.target_score;
        }
        targetScoreReached = false;
        addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
        
        NodeSkin.InitializeSkins();
        m_recentlySolved = false;
    }
    
    public function loadBestScoringConfiguration() : Void
    {
        loadAssignments(m_levelBestScoreAssignmentsObj, true, true);
    }
    
    public function loadInitialConfiguration() : Void
    {
        loadAssignments(m_levelOriginalAssignmentsObj, true);
    }
    
    public function loadAssignmentsConfiguration(assignmentsObj : Dynamic) : Void
    {
        loadAssignments(assignmentsObj);
    }
    
    private function loadAssignments(assignmentsObj : Dynamic, updateTutorialManager : Bool = false, isBest : Bool = false) : Void
    {
        var graphVar : ConstraintVar;
        var narrowIds : String = "";
        var wideIds : String = "";
        for (varId in Reflect.fields(levelGraph.variableDict))
        {
            graphVar = try cast(levelGraph.variableDict[varId], ConstraintVar) catch(e:Dynamic) null;
            var wasSetWide : Bool = setGraphVarFromAssignments(graphVar, assignmentsObj, updateTutorialManager);
            if (PipeJam3.logging)
            {
                var simpleId : String = varId;
                var idArr : Array<Dynamic> = varId.split("var_");
                if (idArr.length == 2)
                {
                    simpleId = Std.string(idArr[1]);
                }
                if (wasSetWide)
                {
                    wideIds += ((wideIds.length == 0)) ? simpleId : ("," + simpleId);
                }
                else
                {
                    narrowIds += ((narrowIds.length == 0)) ? simpleId : ("," + simpleId);
                }
            }
        }
        if (graphVar != null)
        {
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, graphVar, PropDictionary.PROP_NARROW, graphVar.getProps().hasProp(PropDictionary.PROP_NARROW), this, null));
        }
        refreshTroublePoints();
        onScoreChange();
        if (PipeJam3.logging)
        {
            var details : Dynamic = {};
            if (wideIds.length < narrowIds.length)
            {
            // log whichever is less burdensome
                
                {
                    Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_WIDE_VAR_IDS), wideIds);
                }
            }
            else
            {
                Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_NARROW_VAR_IDS), narrowIds);
            }
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), currentScore);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), m_targetScore);
            PipeJam3.logging.logQuestAction((isBest) ? VerigameServerConstants.VERIGAME_ACTION_LOAD_BEST_ASSIGNMENTS : VerigameServerConstants.VERIGAME_ACTION_LOAD_ASSIGNMENTS, details, getTimeMs());
        }
    }
    
    private function setGraphVarFromAssignments(graphVar : ConstraintVar, assignmentsObj : Dynamic, updateTutorialManager : Bool = false) : Bool
    // By default, reset gameNode to default value, then if contained in "assignments" obj, use that value instead
    {
        
        var assignmentIsWide : Bool = (graphVar.defaultVal.verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
        if (Reflect.field(assignmentsObj, "assignments").exists(graphVar.formattedId)
            && Reflect.field(Reflect.field(assignmentsObj, "assignments"), Std.string(graphVar.formattedId)).exists(ConstraintGraph.TYPE_VALUE))
        {
            assignmentIsWide = (Reflect.field(Reflect.field(Reflect.field(assignmentsObj, "assignments"), Std.string(graphVar.formattedId)), Std.string(ConstraintGraph.TYPE_VALUE)) == ConstraintValue.VERBOSE_TYPE_1);
        }
        if (graphVar.getProps().hasProp(PropDictionary.PROP_NARROW) == assignmentIsWide)
        {
            levelGraph.updateScore(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide);
            //graphVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
            //levelGraph.updateScore();
            if (updateTutorialManager && tutorialManager != null)
            {
                tutorialManager.onWidgetChange(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide, levelGraph);
            }
        }
        var gameNode : Node = try cast(nodeLayoutObjs[graphVar.id], Node) catch(e:Dynamic) null;
        if (gameNode != null && gameNode.isNarrow == assignmentIsWide)
        {
            gameNode.isNarrow = !assignmentIsWide;
        }
        return assignmentIsWide;
    }
    
    private function onAddedToStage(event : starling.events.Event) : Void
    {
        addEventListener(starling.events.Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
        
        //for (var varId:String in levelGraph.variableDict) {
        //var graphVar:ConstraintVar = levelGraph.variableDict[varId] as ConstraintVar;
        //graphVar.addEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onWidgetChange);
        //}
        addEventListener(VarChangeEvent.VAR_CHANGE_USER, onWidgetChange);
        //
        //			refreshTroublePoints();
        //			flatten();
        
        dispatchEvent(new starling.events.Event(Constants.STOP_BUSY_ANIMATION, true));
    }
    
    private function onEnterFrame(evt : EnterFrameEvent) : Void
    {
        draw();
    }
    
    private function countDictItems(dict : Map<Dynamic, Dynamic>) : Int
    {
        var count : Int = 0;
        for (i in dict)
        {
            count++;
        }
        
        return count;
    }
    
    //called on when GridViewPanel content is moving
    public function updateLevelDisplay(viewRect : Rectangle = null, content : DisplayObject = null) : Int
    {
        var nGroups : Int = ((levelGraph.groupsArr) ? levelGraph.groupsArr.length : 0);
        var newGroupDepth : Int = 0;
        var i : Int;
        var j : Int;
        var groupGrid : GroupGrid;
        
        if (nGroups > 0)
        {
            for (i in 2...nGroups)
            {
                groupGrid = m_groupGrids[i];
                newGroupDepth = i;
                if (viewRect.width < groupGrid.gridDimensions.x && viewRect.height < groupGrid.gridDimensions.y)
                {
                    break;
                }
            }
            trace("newGroupDepth: ", newGroupDepth);
        }
        
        var candidatesToRemove : Dictionary = new Dictionary();
        for (nodeOnScreenId in m_nodeOnScreenDict.keys())
        {
            Reflect.setField(candidatesToRemove, nodeOnScreenId, true);
			numNodesOnScreen--;
        }
        
        groupGrid = m_groupGrids[newGroupDepth];
        var scaledDimensions : Point = groupGrid.gridDimensions.clone();
        //	if(content)
        //		scaledDimensions.normalize(content.scaleX);
        
        var minX : Int = ((viewRect == null)) ? 0 : GroupGrid.getGridX(viewRect.left, scaledDimensions);
        var maxX : Int = GroupGrid.getGridXRight(((viewRect == null)) ? m_boundingBox.right : viewRect.right, scaledDimensions);
        var minY : Int = ((viewRect == null)) ? 0 : GroupGrid.getGridY(viewRect.top, scaledDimensions) - 1;
        var maxY : Int = GroupGrid.getGridYBottom(((viewRect == null)) ? m_boundingBox.bottom : viewRect.bottom, scaledDimensions);
        var count : Int = 0;
        
        for (i in minX...maxX + 1)
        {
            for (j in minY...maxY + 1)
            {
                var gridKey : String = i + "_" + j;
                if (!groupGrid.grid.exists(gridKey))
                {
                    continue;
                }  // no nodes in grid  
                // TODO groups: check for existing on screen grids m_gridsOnScreen[gridKey] = groupGrid;
                var gridNodeDict : Dictionary = try cast(groupGrid.grid[gridKey], Dictionary) catch(e:Dynamic) null;
                //trace(gridKey, countDictItems(gridNodeDict));
                for (nodeId in Reflect.fields(gridNodeDict))
                {
                    var node : Node = try cast(Reflect.field(nodeLayoutObjs, nodeId), Node) catch(e:Dynamic) null;
                    count++;
                    if (node != null)
                    {
                    //if (!m_nodeOnScreenDict.hasOwnProperty(nodeId))
                        
                        m_nodesToDraw[node.id] = node;
						candidatesToRemove.remove(nodeId);
                    }
                }
            }
        }
        for (nodeToRemoveId in Reflect.fields(candidatesToRemove))
        {
            var nodeToRemove : Node = try cast(Reflect.field(nodeLayoutObjs, nodeToRemoveId), Node) catch(e:Dynamic) null;
            if (nodeToRemove != null)
            {
                m_nodesToRemove[nodeToRemove.id] = nodeToRemove;
            }
        }
        
        if (count >= 2000)
        {
            trace("WARNING! ADDED: " + count + " nodes at this group level");
        }
        if (count < ITEMS_PER_FRAME && m_tutorialTag != null)
        {
            draw();
        }
        currentGroupDepth = newGroupDepth;
        
        return newGroupDepth;
    }
    
    private var m_initLayers : Bool = false;
    public function draw() : Void
    {
        if (!m_initLayers)
        {
            m_initLayers = true;
            
            m_offscreenEdgesLayer = new Sprite();
            m_offscreenEdgesLayer.flatten();
            addChild(m_offscreenEdgesLayer);
            
            m_conflictsLayer = new Sprite();
            m_conflictsLayer.flatten();
            addChild(m_conflictsLayer);
            
            m_conflictAnimationLayer = new Sprite();
            addChild(m_conflictAnimationLayer);
            
            m_edgesLayer = new Sprite();
            m_edgesLayer.flatten();
            addChild(m_edgesLayer);
            
            m_nodeLayer = new Sprite();
            m_nodeClauseSubLayer = new Sprite();
            m_nodeLayer.addChild(m_nodeClauseSubLayer);
            m_nodeVarSubLayer = new Sprite();
            m_nodeLayer.addChild(m_nodeVarSubLayer);
            m_nodeLayer.flatten();
            addChild(m_nodeLayer);
            
            m_nodeAnimationLayer = new Sprite();
            addChild(m_nodeAnimationLayer);
        }
        var nodesProcessed : Int = 0;
        var edge : Edge;
        var gameEdgeId : String;
        var touchedEdgeLayer : Bool = false;
        var touchedNodeLayer : Bool = false;
        var touchedConflictLayer : Bool = false;
        
        var nodeToRemove : Node;
        //remove node now, edges later
        for (nodeToRemove in m_nodesToRemove)
        {
            if (nodeToRemove.skin != null)
            {
                nodeToRemove.skin.removeFromParent(true);
                nodeToRemove.skin.disableSkin();
                nodeToRemove.skin = null;
                touchedNodeLayer = true;
            }
            if (nodeToRemove.backgroundSkin != null)
            {
                nodeToRemove.backgroundSkin.removeFromParent(true);
                nodeToRemove.backgroundSkin.disableSkin();
                nodeToRemove.backgroundSkin = null;
                touchedConflictLayer = true;
            }
            if (m_nodeOnScreenDict.exists(nodeToRemove.id))
            {
				m_nodeOnScreenDict.remove(nodeToRemove.id);
				numNodesOnScreen--;
            }
            nodesProcessed++;
            if (nodesProcessed > ITEMS_PER_FRAME && m_tutorialTag == null)
            {
                break;
            }
        }
        
        var nodeToDraw : Node = popNode(m_nodesToDraw);
        while (nodeToDraw != null)
        {
            var alreadyOnScreen : Bool = m_nodeOnScreenDict.exists(nodeToDraw.id);
            if (nodeToDraw.animating)
            {
                nodeToDraw = popNode(m_nodesToDraw);
                continue;
            }
            // This breaks initial drawing
            if (!nodeToDraw.isClause)
            {
                for (gameEdgeId in nodeToDraw.connectedEdgeIds)
                {
                    edge = Reflect.field(edgeLayoutObjs, gameEdgeId);
                    if (!alreadyOnScreen)
                    {
                        if (edge.skin && edge.skin.parent)
                        {
                            edge.skin.removeFromParent(true);
                            edge.skin = null;
                        }
                        edge.createSkin(currentGroupDepth);
                    }
                    if (edge.skin)
                    {
                        if (alreadyOnScreen)
                        {
                            edge.updateEdge();
                        }
                        adjustEdgeContainer(edge, true);
                        touchedEdgeLayer = true;
                    }
                }
            }
            
            var desiredLayer : Sprite = (nodeToDraw.isClause) ? m_nodeClauseSubLayer : m_nodeVarSubLayer;
            if (nodeToDraw.skin != null && nodeToDraw.skin.parent != desiredLayer)
            {
                nodeToDraw.skin.removeFromParent();
            }
            nodeToDraw.createSkin();
            for (gameEdgeID in nodeToDraw.connectedEdgeIds)
            {
                var edgeObj : Edge = edgeLayoutObjs[gameEdgeID];
                if (edgeObj != null)
                {
                    edgeObj.isDirty = true;
                }
            }
            
            if (nodeToDraw.skin != null)
            {
                m_nodeOnScreenDict[nodeToDraw.id] = true;
                numNodesOnScreen++;
                if (parent)
                {
                    nodeToDraw.skin.customScale(0.5 / parent.scaleX);
                }
                if (nodeToDraw.skin.parent != desiredLayer)
                {
                    desiredLayer.addChild(nodeToDraw.skin);
                }
                touchedNodeLayer = true;
                if (nodeToDraw.backgroundSkin)
                {
                    if (nodeToDraw.backgroundSkin.parent != m_conflictsLayer)
                    {
                        m_conflictsLayer.addChild(nodeToDraw.backgroundSkin);
                    }
                    if (parent)
                    {
                        nodeToDraw.backgroundSkin.customScale(0.5 / parent.scaleX);
                    }
                    touchedConflictLayer = true;
                }
            }
            nodesProcessed++;
            if (nodesProcessed > ITEMS_PER_FRAME && m_tutorialTag == null)
            {
                break;
            }
            nodeToDraw = popNode(m_nodesToDraw);
        }
        
        //remove old edges last, since we need node out of nodesToDraw and m_nodeOnScreenDict arrays
        var nodeToRemove1 : Node = popNode(m_nodesToRemove);
        while (nodeToRemove1 != null)
        {
            for (gameEdgeId in nodeToRemove1.connectedEdgeIds)
            {
                edge = Reflect.field(edgeLayoutObjs, gameEdgeId);
                adjustEdgeContainer(edge);
                touchedEdgeLayer = true;
            }
            nodeToRemove1 = popNode(m_nodesToRemove);
        }
        
        if (nodesProcessed <= ITEMS_PER_FRAME)
        {
        // enqueue animations only once all other nodes have been drawn/removed
            
            {
                var tween : Tween;
                var n : Int = 0;
                var solvingNodeToAnimate : VariableNode = try cast(popNode(m_solvingNodesToAnimate), VariableNode) catch(e:Dynamic) null;
                while (solvingNodeToAnimate != null)
                {
                    if (solvingNodeToAnimate.skin != null)
                    {
                        solvingNodeToAnimate.skin.removeFromParent();
                        touchedNodeLayer = true;
                        m_nodeAnimationLayer.addChild(solvingNodeToAnimate.skin);
                        tween = new Tween(solvingNodeToAnimate.skin, 0.25, Transitions.EASE_OUT);
                        tween.moveTo(solvingNodeToAnimate.centerPoint.x, solvingNodeToAnimate.centerPoint.y - 12);
                        tween.delay = (n * 0.025) % 0.25;
                        tween.repeatCount = 0;
                        tween.reverse = true;
                        Starling.current.juggler.add(tween);
                    }
                    n++;  // do all at once, don't increment nodesProcessed  
                    solvingNodeToAnimate = try cast(popNode(m_solvingNodesToAnimate), VariableNode) catch(e:Dynamic) null;
                }
                n = 0;
                var solvedClauseToAnimate : ClauseNode = try cast(popNode(m_solvedConflictsToAnimate), ClauseNode) catch(e:Dynamic) null;
                while (solvedClauseToAnimate != null)
                {
                    if (solvedClauseToAnimate.backgroundSkin == null)
                    {
                        solvedClauseToAnimate = try cast(popNode(m_solvedConflictsToAnimate), ClauseNode) catch(e:Dynamic) null;
                        continue;
                    }
                    var animateSkin : NodeSkin = NodeSkin.getNextSkin();
                    animateSkin.setNodeProps(true, false, false, false, true, true);
                    animateSkin.draw();
                    animateSkin.x = solvedClauseToAnimate.centerPoint.x;
                    animateSkin.y = solvedClauseToAnimate.centerPoint.y;
                    animateSkin.customScale(0.5 / parent.scaleX);
                    m_conflictAnimationLayer.addChild(animateSkin);
                    tween = new Tween(animateSkin, 0.4, Transitions.EASE_IN_BACK);
                    tween.scaleTo(0);
                    tween.delay = (n * 0.05) % 0.5;
                    solvedClauseToAnimate.backgroundSkin.removeFromParent(true);
                    solvedClauseToAnimate.backgroundSkin.disableSkin();
                    solvedClauseToAnimate.backgroundSkin = null;
                    tween.onComplete = conflictRemovedTweenComplete;
                    tween.onCompleteArgs = new Array<Dynamic>(solvedClauseToAnimate, animateSkin);
                    Starling.current.juggler.add(tween);
                    n++;  // do all at once, don't increment nodesProcessed just stagger delay times  
                    solvedClauseToAnimate = try cast(popNode(m_solvedConflictsToAnimate), ClauseNode) catch(e:Dynamic) null;
                }
            }
        }
        m_recentlySolved = false;
        if (touchedEdgeLayer)
        {
            m_edgesLayer.flatten();
            m_offscreenEdgesLayer.flatten();
        }
        if (touchedNodeLayer)
        {
            m_nodeLayer.flatten();
        }
        if (touchedConflictLayer)
        {
            m_conflictsLayer.flatten();
        }
    }
    
    private function adjustEdgeContainer(edge : Edge, forceDrawing : Bool = false) : Void
    {
        if (edge.skin == null)
        {
            return;
        }
        var fromOnscreen : Bool = (m_nodeOnScreenDict.exists(edge.fromNode.id) || m_nodesToDraw.exists(edge.fromNode.id));
        var toOnscreen : Bool = (m_nodeOnScreenDict.exists(edge.toNode.id) || m_nodesToDraw.exists(edge.toNode.id));
        if (fromOnscreen && toOnscreen || forceDrawing)
        {
            if (edge.skin.parent != m_edgesLayer)
            {
                m_edgesLayer.addChildAt(edge.skin, 0);
            }
        }
        else if (fromOnscreen || toOnscreen)
        {
            if (edge.skin.parent != m_offscreenEdgesLayer)
            {
                m_offscreenEdgesLayer.addChildAt(edge.skin, 0);
            }
        }
        else
        {
            edge.skin.removeFromParent(true);
            edge.skin = null;
        }
    }
    
    private function conflictRemovedTweenComplete(clauseNode : ClauseNode, skin : NodeSkin) : Void
    {
        clauseNode.animating = false;
        m_nodesToDraw[clauseNode.id] = clauseNode;
        skin.removeFromParent(true);
        skin.disableSkin();
    }
    
    private function createGridChildFromLayoutObj(gridChildId : String, gridChildLayout : Dynamic, isGroup : Bool) : GridChild
    {
        var layoutX : Float = as3hx.Compat.parseFloat(Reflect.field(gridChildLayout, "x")) * Constants.GAME_SCALE * levelLayoutScale;
        var layoutY : Float = as3hx.Compat.parseFloat(Reflect.field(gridChildLayout, "y")) * Constants.GAME_SCALE * levelLayoutScale;
        
        var gridChild : GridChild;
        
        if (nodeLayoutObjs.exists(gridChildId))
        {
            var prevNode : Node = try cast(Reflect.field(nodeLayoutObjs, gridChildId), Node) catch(e:Dynamic) null;
            if (prevNode.skin)
            {
                prevNode.skin.disableSkin();
                prevNode.skin = null;
            }
        }
        
        var nodeBB : Rectangle = new Rectangle(layoutX - Constants.SKIN_DIAMETER * .5, layoutY - Constants.SKIN_DIAMETER * .5, Constants.SKIN_DIAMETER, Constants.SKIN_DIAMETER);
        if (gridChildId.substr(0, 3) == "var")
        {
            var graphVar : ConstraintVar = try cast(levelGraph.variableDict[gridChildId], ConstraintVar) catch(e:Dynamic) null;
            gridChild = new VariableNode(gridChildId, nodeBB, graphVar);
        }
        else
        {
            var graphClause : ConstraintClause = try cast(levelGraph.clauseDict[gridChildId], ConstraintClause) catch(e:Dynamic) null;
            gridChild = new ClauseNode(gridChildId, nodeBB, graphClause);
        }
        
        Reflect.setField(nodeLayoutObjs, gridChildId, gridChild);
        return gridChild;
    }
    
    private function loadLayout() : Void
    {
        nodeLayoutObjs = new Dictionary();
        edgeLayoutObjs = new Dictionary();
        
        var minX : Float;
        var minY : Float;
        var maxX : Float;
        var maxY : Float;
        minX = minY = Math.POSITIVE_INFINITY;
        maxX = maxY = Math.NEGATIVE_INFINITY;
        
        // Process layout nodes (vars)
        var gridChild : GridChild;
        var boundsArr : Array<Dynamic> = try cast(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "bounds"), Array<Dynamic>) catch(e:Dynamic) null;
        if (boundsArr != null)
        {
            minX = boundsArr[0] * Constants.GAME_SCALE;
            minY = boundsArr[1] * Constants.GAME_SCALE;
            maxX = boundsArr[2] * Constants.GAME_SCALE;
            maxY = boundsArr[3] * Constants.GAME_SCALE;
        }
        else
        {
            for (layoutId in Reflect.fields(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars")))
            {
                var thisNodeLayout : Dynamic = Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars"), layoutId);
                var layoutX : Float = as3hx.Compat.parseFloat(Reflect.field(thisNodeLayout, "x")) * Constants.GAME_SCALE;
                var layoutY : Float = as3hx.Compat.parseFloat(Reflect.field(thisNodeLayout, "y")) * Constants.GAME_SCALE;
                minX = Math.min(minX, layoutX);
                minY = Math.min(minY, layoutY);
                maxX = Math.max(maxX, layoutX);
                maxY = Math.max(maxY, layoutY);
            }
        }
        
        //check on brush specifications
        var brushArr : Array<Dynamic> = try cast(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "brushes"), Array<Dynamic>) catch(e:Dynamic) null;
        brushesToActivate = 0xffffff;
        if (brushArr != null)
        {
            brushesToActivate = 0;
            for (brush in brushArr)
            {
                switch (brush)
                {
                    case "wide":
                        brushesToActivate += TutorialLevelManager.WIDEN_BRUSH;
                    case "narrow":
                        brushesToActivate += TutorialLevelManager.NARROW_BRUSH;
                    case "auto":
                        brushesToActivate += TutorialLevelManager.SOLVER_BRUSH;
                }
            }
        }
        
        var bbWidth : Float = maxX - minX + Constants.SKIN_DIAMETER;
        var bbHeight : Float = maxY - minY + Constants.SKIN_DIAMETER;
        
        // Limit content to 2048x2048
        levelLayoutScale = Math.min(
                        Math.min(bbWidth, 2048.0) / bbWidth, 
                        Math.min(bbHeight, 2048.0) / bbHeight
            );
        
        m_boundingBox = new Rectangle(levelLayoutScale * (minX - Constants.SKIN_DIAMETER * .5), 
                levelLayoutScale * (minY - Constants.SKIN_DIAMETER * .5), 
                levelLayoutScale * (maxX - minX + Constants.SKIN_DIAMETER), 
                levelLayoutScale * (maxY - minY + Constants.SKIN_DIAMETER));
        
        m_groupGrids = new Array<GroupGrid>();
        var MAX_GROUP_DEPTH : Int = levelGraph.groupsArr.length;
        for (groupDepth in 0...MAX_GROUP_DEPTH + 1)
        {
            var nodeDict : Dynamic;
            var groupSize : Int;
            if (groupDepth == 0)
            {
                nodeDict = Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars");
                groupSize = as3hx.Compat.parseInt(levelGraph.nVars + levelGraph.nClauses);
            }
            else
            {
                nodeDict = levelGraph.groupsArr[groupDepth - 1];
                groupSize = levelGraph.groupSizes[groupDepth - 1];
            }
            var groupGrid : GroupGrid = new GroupGrid(m_boundingBox, levelLayoutScale, nodeDict, Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars"), groupSize);
            m_groupGrids.push(groupGrid);
        }
        
        for (varId in Reflect.fields(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars")))
        {
            var nodeLayout : Dynamic = Reflect.field(Reflect.field(Reflect.field(m_levelLayoutObj, "layout"), "vars"), varId);
            gridChild = createGridChildFromLayoutObj(varId, nodeLayout, false);
            if (gridChild == null)
            {
                continue;
            }
            m_numNodes++;
        }
        //quick fix to make large level actually playable
        if (m_numNodes > 50000)
        {
            PipeJam3.SELECTION_STYLE = PipeJam3.SELECTION_STYLE_CLASSIC;
        }
        else
        {
            PipeJam3.SELECTION_STYLE = PipeJam3.SELECTION_STYLE_VAR_BY_VAR_AND_CNSTR;
        }
        
        //trace("node count = " + n);
        
        // Process layout edges (constraints)
        var visibleLines : Int = 0;
        m_numNodes = 0;
        
        for (constraintId in Reflect.fields(levelGraph.constraintsDict))
        {
            var result : Dynamic = constraintId.split(" ");
            if (result == null)
            {
                throw new Error("Invalid constraint layout string found: " + constraintId);
            }
            if (result.length != 3)
            {
                throw new Error("Invalid constraint layout string found: " + constraintId);
            }
            var graphConstraint : Constraint = try cast(levelGraph.constraintsDict[constraintId], Constraint) catch(e:Dynamic) null;
            if (graphConstraint == null)
            {
                throw new Error("No graph constraint found for constraint layout: " + constraintId);
            }
            var startNode : Node = Reflect.field(nodeLayoutObjs, Std.string(Reflect.field(result, Std.string(0))));
            var endNode : Node = Reflect.field(nodeLayoutObjs, Std.string(Reflect.field(result, Std.string(2))));
            //switch end points if needed)
            if (Reflect.field(result, Std.string(0)).indexOf("c") != -1)
            {
                startNode = Reflect.field(nodeLayoutObjs, Std.string(Reflect.field(result, Std.string(2))));
                endNode = Reflect.field(nodeLayoutObjs, Std.string(Reflect.field(result, Std.string(0))));
            }
            var edge : Edge = new Edge(constraintId, graphConstraint, startNode, endNode);
            startNode.connectedEdgeIds.push(constraintId);
            startNode.outgoingEdgeIds.push(constraintId);
            endNode.connectedEdgeIds.push(constraintId);
            Reflect.setField(edgeLayoutObjs, constraintId, edge);
            
            m_numNodes++;
        }
        if (PipeJam3.ASSET_SUFFIX == "Turk")
        {
            m_targetScore = 0;
            for (key in Reflect.fields(nodeLayoutObjs))
            {
                if (Std.is(Reflect.field(nodeLayoutObjs, key), ClauseNode))
                {
                    m_targetScore++;
                }
            }
        }
    }
    
    public function initialize() : Void
    // create all nodes, edges for tutorials so that the tutorial indicators/arrows have something to point at
    {
        
        if (initialized)
        {
            return;
        }
        
        //this.alpha = .999;
        
        totalMoveDist = new Point();
        loadLayout();
        loadInitialConfiguration();
        
        addEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
        addEventListener(SelectionEvent.COMPONENT_SELECTED, onComponentSelection);
        addEventListener(SelectionEvent.COMPONENT_UNSELECTED, onComponentUnselection);
        levelGraph.addEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
        levelGraph.addEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
        
        addEventListener(TouchEvent.TOUCH, onTouch);
        
        m_levelStartTime = Date.now().time;
        
        levelGraph.resetScoring();
        m_bestScore = levelGraph.currentScore;
        levelGraph.startingScore = levelGraph.currentScore;
        dispatchEvent(new MenuEvent(MenuEvent.LEVEL_LOADED));
        if (tutorialManager != null)
        {
            tutorialManager.startLevel();
        }
        initialized = true;
    }
    
    public function zipJsonFile(jsonFile : Dynamic, name : String) : ByteArray
    {
        var newZip : FZip = new FZip();
        var zipByteArray : ByteArray = new ByteArray();
        zipByteArray.writeUTFBytes(haxe.Json.stringify(jsonFile));
        newZip.addFile(name, zipByteArray);
        var byteArray : ByteArray = new ByteArray();
        newZip.serialize(byteArray);
        return byteArray;
    }
    
    public function encodeBytes(bytes : ByteArray) : String
    {
        var encoder : Base64Encoder = new Base64Encoder();
        encoder.encodeBytes(bytes);
        var encodedString : String = Std.string(encoder);
        
        return encodedString;
    }
    
    public function updateLevelObj() : Void
    {
        updateAssignmentsObj();
    }
    
    private function onRemovedFromStage(event : starling.events.Event) : Void
    {
        removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
        addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
        removeEventListener(starling.events.Event.REMOVED_FROM_STAGE, onRemovedFromStage);
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
        for (nodeId in Reflect.fields(nodeLayoutObjs))
        {
            hashSize++;
        }
        
        PipeJamGame.levelInfo.hash = new Array<Dynamic>();
        
        var assignmentsObj : Dynamic = {
            id : original_level_name,
            hash : [],
            target_score : this.m_targetScore,
            starting_score : this.levelGraph.currentScore,
            assignments : { }
        };
        var count : Int = 0;
        var numWide : Int = 0;
        for (nodeId in Reflect.fields(nodeLayoutObjs))
        {
            if (nodeId.substr(0, 1) == "c")
            {
                continue;
            }
            var constraintVar : ConstraintVar = levelGraph.variableDict[nodeId];
            if (!Reflect.field(assignmentsObj, "assignments").exists(constraintVar.formattedId))
            {
                Reflect.setField(Reflect.field(assignmentsObj, "assignments"), Std.string(constraintVar.formattedId), { });
            }
            Reflect.setField(Reflect.field(Reflect.field(assignmentsObj, "assignments"), Std.string(constraintVar.formattedId)), Std.string(ConstraintGraph.TYPE_VALUE), constraintVar.getValue().verboseStrVal);
            
            var isWide : Bool = (constraintVar.getValue().verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
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
                PipeJamGame.levelInfo.hash.push(numWide);
                numWide = 0;
            }
        }
        return assignmentsObj;
    }
    
    override public function dispose() : Void
    {
        initialized = false;
        //trace("Disposed of : " + m_levelLayoutObj["id"]);
        
        if (tutorialManager != null)
        {
            tutorialManager.endLevel();
        }
        
        nodeLayoutObjs = new Dictionary();
        // TODO groups - dispose layers
        disposeChildren();
        
        removeEventListener(VarChangeEvent.VAR_CHANGE_USER, onWidgetChange);
        removeEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
        removeEventListener(SelectionEvent.COMPONENT_SELECTED, onComponentSelection);
        removeEventListener(SelectionEvent.COMPONENT_UNSELECTED, onComponentSelection);
        if (levelGraph != null)
        {
            levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
        }
        if (levelGraph != null)
        {
            levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
        }
        super.dispose();
    }
    
    
    
    //assume this only generates on toggle width events
    public function onWidgetChange(evt : VarChangeEvent = null, reportScore : Bool = false) : Void
    //trace("Level: onWidgetChange");
    {
        
        if (evt != null && evt.graphVar)
        {
            levelGraph.updateScore(evt.graphVar.id, evt.prop, evt.newValue);
            //evt.graphVar.setProp(evt.prop, evt.newValue);
            if (tutorialManager != null)
            {
                tutorialManager.onWidgetChange(evt.graphVar.id, evt.prop, evt.newValue, levelGraph);
            }
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, evt.graphVar, evt.prop, evt.newValue, this, evt.pt));
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
        }
        else
        {
            levelGraph.updateScore();
            if (tutorialManager != null)
            {
                tutorialManager.afterScoreUpdate(levelGraph);
            }
            dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
        }
        onScoreChange(reportScore);
    }
    
    private var m_propertyMode : String = PropDictionary.PROP_NARROW;
    public function onPropertyModeChange(evt : PropertyModeChangeEvent) : Void
    {
        if (evt.prop != PropDictionary.PROP_NARROW)
        {
            throw new Error("Unsupported property: " + evt.prop);
        }
    }
    
    private function refreshTroublePoints() : Void
    {  //		for (var edgeId:String in m_gameEdgeDict) {  
        //			var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
        //			gameEdge.refreshConflicts();
        //		}
        
    }
    
    //data object should be in final selected/unselected state
    private function componentSelectionChanged(component : Dynamic, selected : Bool) : Void
    {
    }
    
    private function onComponentSelection(evt : SelectionEvent) : Void
    {
        var component : Dynamic = evt.component;
        if (component != null)
        {
            componentSelectionChanged(component, true);
        }
        
        var selectionChangedComponents : Array<Dynamic> = new Array<Dynamic>();
        selectionChangedComponents.push(component);
    }
    
    private function onComponentUnselection(evt : SelectionEvent) : Void
    {
        var component : Dynamic = evt.component;
        if (component != null)
        {
            componentSelectionChanged(component, false);
        }
        
        var selectionChangedComponents : Array<Dynamic> = new Array<Dynamic>();
        selectionChangedComponents.push(component);
    }
    
    public function selectSurroundingNodes(node : Node, nextToVisitArray : Array<Dynamic>, previouslyCheckedNodes : Map<String, Node>) : Void
    {
        if (!node.isSelected)
        {
        //trace("select direct " + node.id);
            
            node.select();
            selectedNodes.push(node);
            m_nodesToDraw[node.id] = node;
        }
        
        for (gameEdgeId in node.connectedEdgeIds)
        {
            var edge : Edge = edgeLayoutObjs[gameEdgeId];
            var toNode : Node = edge.toNode;
            var fromNode : Node = edge.fromNode;
            
            var otherNode : Node = toNode;
            if (toNode == node)
            {
                otherNode = fromNode;
            }
            if (!otherNode.isSelected)
            {
                if (previouslyCheckedNodes[otherNode.id] == null)
                {
                    nextToVisitArray.push(otherNode);
                    previouslyCheckedNodes[otherNode.id] = otherNode;
                }
            }
        }
    }
    
    private function onErrorAdded(evt : ErrorEvent) : Void
    {
        for (errorEdgeId in Reflect.fields(evt.constraintChangeDict))
        {
        // new conflicts
            
            {
                var clauseConstraint : ConstraintEdge = try cast(evt.constraintChangeDict[errorEdgeId], ConstraintEdge) catch(e:Dynamic) null;
                if (clauseConstraint != null)
                {
                    var clauseNode : ClauseNode;
                    if (clauseConstraint.lhs.id.indexOf("c") != -1)
                    {
                        clauseNode = nodeLayoutObjs[clauseConstraint.lhs.id];
                    }
                    else if (clauseConstraint.rhs.id.indexOf("c") != -1)
                    {
                        clauseNode = nodeLayoutObjs[clauseConstraint.rhs.id];
                    }
                    if (clauseNode != null)
                    {
                        clauseNode.addError(true);
                        if (clauseNode.skin != null)
                        {
                            m_nodesToDraw[clauseNode.id] = clauseNode;
                            m_createdConflictsToAnimate.push(clauseNode);
                        }
                    }
                }
            }
        }
    }
    
    private function onErrorRemoved(evt : ErrorEvent) : Void
    {
        for (errorEdgeId in Reflect.fields(evt.constraintChangeDict))
        {
        // solved clauses
            
            {
                var clauseConstraint : ConstraintEdge = try cast(evt.constraintChangeDict[errorEdgeId], ConstraintEdge) catch(e:Dynamic) null;
                if (clauseConstraint != null)
                {
                    var clauseNode : ClauseNode;
                    if (clauseConstraint.lhs.id.indexOf("c") != -1)
                    {
                        clauseNode = nodeLayoutObjs[clauseConstraint.lhs.id];
                    }
                    else if (clauseConstraint.rhs.id.indexOf("c") != -1)
                    {
                        clauseNode = nodeLayoutObjs[clauseConstraint.rhs.id];
                    }
                    if (clauseNode != null)
                    {
                        clauseNode.addError(false);
                        if (clauseNode.skin != null)
                        {
                            clauseNode.animating = true;
                            m_solvedConflictsToAnimate[clauseNode.id] = clauseNode;
                        }
                    }
                }
            }
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
    
    public function getNodes() : Map<String, Node>
    {
        return nodeLayoutObjs;
    }
    
    public function getLevelTextInfo() : TutorialManagerTextInfo
    {
        return (tutorialManager != null) ? tutorialManager.getTextInfo() : null;
    }
    
    public function getLevelToolTipsInfo() : Array<TutorialManagerTextInfo>
    {
        return (tutorialManager != null) ? tutorialManager.getPersistentToolTipsInfo() : (new Array<TutorialManagerTextInfo>());
    }
    
    public function getMaxSelectableWidgets() : Int
    {
        if (tutorialManager != null)
        {
            return tutorialManager.getMaxSelectableWidgets();
        }
        else
        {
            if (PipeJam3.ASSET_SUFFIX == "Turk")
            {
                return 500;
            }
            if (PipeJam3.SELECTION_STYLE != PipeJam3.SELECTION_STYLE_CLASSIC)
            {
                var _sw0_ = (PlayerValidation.currentActivityLevel);                

                switch (_sw0_)
                {
                    case 2:return 250;
                    case 3:return 500;
                    default:return 100;
                }
            }
            else
            {
                return 1000;
            }
        }
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
        return Date.now().time - m_levelStartTime;
    }
    
    public function hideErrorText() : Void
    {  //			if (!m_hidingErrorText) {  
        //				for (var edgeId:String in m_gameEdgeDict) {
        //					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
        //					gameEdge.hideErrorText();
        //				}
        //				m_hidingErrorText = true;
        //			}
        
    }
    
    public function showErrorText() : Void
    {  //			if (m_hidingErrorText) {  
        //				for (var edgeId:String in m_gameEdgeDict) {
        //					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
        //					gameEdge.showErrorText();
        //				}
        //				m_hidingErrorText = false;
        //			}
        
    }
    
    override public function unflatten() : Void
    {
        super.unflatten();
    }
    
    public function getPanZoomAllowed() : Bool
    {
        if (tutorialManager != null)
        {
            return tutorialManager.getPanZoomAllowed();
        }
        return true;
    }
    
    public function getVisibleBrushes() : Int
    {
        if (tutorialManager != null)
        {
            return tutorialManager.getVisibleBrushes();
        }
        //all visible
        return 0xFFFFFF;
    }
    
    public function getAutoSolveAllowed() : Bool
    {
        if (tutorialManager != null)
        {
            return tutorialManager.getAutoSolveAllowed();
        }
        return true;
    }
    
    public static var SEGMENT_DELETION_ENABLED : Bool = false;
    public function onDeletePressed() : Void
    {
    }
    
    
    private function get_currentScore() : Int
    {
        return levelGraph.currentScore;
    }
    private function get_bestScore() : Int
    {
        return m_bestScore;
    }
    private function get_maxScore() : Int
    {
        return MiniMap.maxNumConflicts;
    }
    private function get_startingScore() : Int
    {
        return levelGraph.startingScore;
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
    
    public function onScoreChange(recordBestScore : Bool = false) : Void
    {
        if (recordBestScore && (levelGraph.currentScore > m_bestScore))
        {
            m_bestScore = levelGraph.currentScore;
            //trace("New best score: " + m_bestScore);
            m_levelBestScoreAssignmentsObj = createAssignmentsObj();
            //don't update on loading
            if (levelGraph.oldScore != 0 && (PlayerValidation.accessGranted() || (PipeJam3.ASSET_SUFFIX == "Turk")))
            {
                dispatchEvent(new MenuEvent(MenuEvent.SAVE_LEVEL));
            }
        }
        //if (levelGraph.prevScore != levelGraph.currentScore)
        dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
    }
    
    public function unselectAll() : Void
    {
        for (node in selectedNodes)
        {
            node.animating = false;
            node.unselect();
            if (node.skin != null)
            {
                m_nodesToDraw[node.id] = node;
            }
        }
        selectedNodes = new Array<Node>();
        dispatchEvent(new SelectionEvent(SelectionEvent.NUM_SELECTED_NODES_CHANGED, null, null));
    }
    
    public function onUseSelectionPressed(choice : String) : Void
    //save selection for undo
    {
        
        nodeIDToConstraintsTwoWayMap = new Dictionary();
        var count : Int = 1;
        var newAssignmentValue : Int;
        m_previousVarValues = new Array<Dynamic>();
        m_lastVarValues = new Array<Dynamic>();
        var assignmentIsWide : Bool = false;
        if (choice == MenuEvent.MAKE_SELECTION_WIDE)
        {
            assignmentIsWide = true;
            newAssignmentValue = 1;
        }
        else if (choice == MenuEvent.MAKE_SELECTION_NARROW)
        {
            assignmentIsWide = false;
            newAssignmentValue = 1;
        }
        var selectedVarIds : String = "";
        for (node in selectedNodes)
        {
            node.solved = true;
            node.animating = false;
            node.unselect();
            if (!node.isClause)
            {
                nodeIDToConstraintsTwoWayMap[count] = node;
                count++;
                if (node.isNarrow)
                {
                    m_previousVarValues.push(0);
                }
                else
                {
                    m_previousVarValues.push(1);
                }
                m_lastVarValues.push(newAssignmentValue);
                node.updateSelectionAssignment(assignmentIsWide, levelGraph);
                m_nodesToDraw[node.id] = node;
                if (PipeJam3.logging)
                {
                    var simpleId : String = node.id;
                    var idArr : Array<Dynamic> = node.id.split("var_");
                    if (idArr.length == 2)
                    {
                        simpleId = Std.string(idArr[1]);
                    }
                    selectedVarIds += ((selectedVarIds.length == 0)) ? simpleId : ("," + simpleId);
                }
            }
        }
        //update score
        onWidgetChange(null, true);
        if (PipeJam3.logging && selectedNodes.length > 0)
        {
            var details : Dynamic = {};
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_VAR_IDS), selectedVarIds);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TYPE), m_solverType);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), currentScore);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), m_targetScore);
            PipeJam3.logging.logQuestAction((assignmentIsWide) ? VerigameServerConstants.VERIGAME_ACTION_PAINT_WIDE : VerigameServerConstants.VERIGAME_ACTION_PAINT_NARROW, details, getTimeMs());
        }
        unselectAll();
    }
    
    public function getEdgeContainer(edgeId : String) : DisplayObject
    {
        var edge : Edge = Reflect.field(edgeLayoutObjs, edgeId);
        return (edge != null) ? edge.skin : null;
    }
    
    public function getNode(nodeId : String) : Node
    {
        var node : Node = Reflect.field(nodeLayoutObjs, nodeId);
        return node;
    }
    
    private var solverRunningTime : Float;
    public function solverTimerCallback(evt : TimerEvent) : Void
    {
        solveSelection(solverUpdate, solverDone);
    }
    
    public function solverLoopTimerCallback(evt : TimerEvent) : Void
    {
        for (node in nodeLayoutObjs)
        {
            node.unused = true;
        }
        solveSelection(solverUpdate, solverDone);
    }
    
    //used when ctrl-shift clicking a node, selects x whole group or nearest neighbors if no group
    private var currentSelectionProcessCount : Int;
    public var NUM_NODES_TO_SELECT : Int = 20;
    
    private function onGroupSelection(evt : SelectionEvent) : Void
    {
        if (Std.is(evt.component, Node))
        {
            var node : Node = try cast(evt.component, Node) catch(e:Dynamic) null;
            currentSelectionProcessCount = 1;
            var nextToVisitArray : Array<Dynamic> = new Array<Dynamic>();
            var previouslyCheckedNodes : Dictionary = new Dictionary();
            selectSurroundingNodes(node, nextToVisitArray, previouslyCheckedNodes);
            for (nextNode in nextToVisitArray)
            {
                selectSurroundingNodes(nextNode, nextToVisitArray, previouslyCheckedNodes);
                if (currentSelectionProcessCount > NUM_NODES_TO_SELECT)
                {
                    break;
                }
                currentSelectionProcessCount++;
            }
        }
    }
    
    public var loopcount : Int = 0;
    public var looptimer : Timer;
    public var runContinualSolver : Bool = true;
    //this is a test robot. It will find a conflict, select neighboring nodes, solve that area, and repeat
    public function solveSelection(updateCallback : Function, doneCallback : Function, firstRun : Bool = false) : Void
    {
        if (firstRun)
        {
            solverRunningTime = Date.now().getTime();
        }
        //if caps lock is down, start repeated solving using 'random' selection
        if (runContinualSolver)
        {
        //loop through all nodes, finding ones with conflicts
            
            for (node in nodeLayoutObjs)
            {
                if (Std.is(node, ClauseNode))
                {
                    var clauseNode : ClauseNode = try cast(node, ClauseNode) catch(e:Dynamic) null;
                    if (clauseNode.hasError() && node.unused)
                    {
                        node.unused = false;
                        //trace(node.id);
                        onGroupSelection(new SelectionEvent("foo", node));
                        solveSelection1(updateCallback, doneCallback, GridViewPanel.SOLVER1_BRUSH);
                        unselectAll();
                        return;
                    }
                }
            }
            
            // if we make it this far start over
            //trace("new loop", loopcount);
            looptimer = new Timer(1000, 1);
            looptimer.addEventListener(TimerEvent.TIMER, solverLoopTimerCallback);
            looptimer.start();
        }
        else
        {
            solveSelection1(updateCallback, doneCallback, GridViewPanel.SOLVER1_BRUSH);
        }
    }
    
    
    
    public var updateCallback : Function;
    public var doneCallback : Function;
    private var constraintArray : Array<Dynamic>;
    private var initvarsArray : Array<Dynamic>;
    private var newSelectedVars : Array<Node>;
    private var newSelectedClauses : Map<String, Node>;
    private var storedDirectEdgesDict : Map<String, Edge>;
    private var directNodeDict : Map<String, Node>;
    private var counter : Int;
    private var m_solverType : Int;
    private var selectedConstraintValue : Int;
    public var startingSelectedNodeCount : Int;
    public function solveSelection1(_updateCallback : Function, _doneCallback : Function, brushType : String) : Void
    //figure out which edges have both start and end components selected (all included edges have both ends selected?)
    {
        
        //assign connected components to component to edge constraint number dict
        //create three constraints for conflicts and weights
        //run the solver, passing in the callback function
        updateCallback = _updateCallback;
        doneCallback = _doneCallback;
        startingSelectedNodeCount = selectedNodes.length;
        selectedConstraintValue = 0;
        m_solverType = 1;
        if (brushType != GridViewPanel.SOLVER1_BRUSH)
        {
            m_solverType = 2;
        }
        
        nodeIDToConstraintsTwoWayMap = new Dictionary();
        var storedConstraints : Dictionary = new Dictionary();
        counter = 1;
        constraintArray = new Array<Dynamic>();
        initvarsArray = new Array<Dynamic>();
        directNodeDict = new Dictionary();
        storedDirectEdgesDict = new Dictionary();
        m_unsat_weight = as3hx.Compat.INT_MAX;
        
        newSelectedVars = new Array<Node>();
        newSelectedClauses = new Map<String, Node>();
        m_inSolver = true;
        
        if (PipeJam3.logging)
        {
            var details : Dynamic = {};
            var selectedVarIds : String = "";
            for (node in selectedNodes)
            {
                if (node.isClause)
                {
                    continue;
                }
                var simpleId : String = node.id;
                var idArr : Array<Dynamic> = node.id.split("var_");
                if (idArr.length == 2)
                {
                    simpleId = Std.string(idArr[1]);
                }
                selectedVarIds += ((selectedVarIds.length == 0)) ? simpleId : ("," + simpleId);
            }
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_VAR_IDS), selectedVarIds);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TYPE), m_solverType);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), currentScore);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), m_targetScore);
            PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_PAINT_AUTOSOLVE, details, getTimeMs());
        }
        
        if (PipeJam3.SELECTION_STYLE != PipeJam3.SELECTION_STYLE_CLASSIC)
        {
            createConstraintsBasedOnVariables();
        }
        else
        {
            createConstraintsForClauses();
            
            findIsolatedSelectedVars();  //handle one-offs so something gets done in minimal cases  
            
            if (extendSolver)
            {
                fixEdgeVarValues();
            }
        }
        
        if (constraintArray.length > 0)
        {
        //generate initvars array
            
            for (ii in 1...counter)
            {
                var gameNode : VariableNode = nodeIDToConstraintsTwoWayMap[ii];
                if (gameNode.isNarrow)
                {
                    initvarsArray.push(0);
                }
                else
                {
                    initvarsArray.push(1);
                }
            }
            
            //build in a delay to allow UI to change
            World.m_world.showSolverState(true);
            timer = new Timer(500, 1);
            timer.addEventListener(TimerEvent.TIMER, solverStartCallback);
            timer.start();
        }
        //just end
        else
        {
            
            {
                doneCallback("");
            }
        }
    }
    
    private function createConstraintsBasedOnVariables() : Void
    {
        var node : Node;
        var edge : Edge;
        var toNode : Node;
        var fromNode : Node;
        
        // start variable nodes animating
        for (node in selectedNodes)
        {
            if (node.isClause)
            {
                continue;
            }
            
            node.animating = true;
            m_solvingNodesToAnimate[node.id] = node;
        }
        
        // find all the possibly relevant clauses
        var selectedNodesDict : Dictionary = new Dictionary();
        var connectedClausesDict : Dictionary = new Dictionary();
        var gameEdgeId : String;
        for (node in selectedNodes)
        {
            if (node.isClause)
            {
                continue;
            }
            
            // remember that this node was selected
            selectedNodesDict[node.id] = node;
            
            // remember all the clauses connected to this node
            for (gameEdgeId in node.connectedEdgeIds)
            {
                edge = Reflect.field(edgeLayoutObjs, gameEdgeId);
                toNode = edge.toNode;
                
                connectedClausesDict[toNode.id] = toNode;
            }
        }
        
        // now go through all those clauses
        for (node in connectedClausesDict)
        {
        // check if this clause is satisfied by some variable that is not being optimized
            
            var clauseConstSat : Bool = false;
            for (gameEdgeId in node.connectedEdgeIds)
            {
                edge = Reflect.field(edgeLayoutObjs, gameEdgeId);
                fromNode = edge.fromNode;
                
                // is this variable a constant?
                if (selectedNodesDict[fromNode.id] == null)
                {
                // does it satisfy the clause?
                    
                    var wantValue : Bool = (gameEdgeId.indexOf("c") == 0);
                    var hasValue : Bool = (!nodeLayoutObjs[edge.fromNode.id].isNarrow);
                    if (wantValue == hasValue)
                    {
                        clauseConstSat = true;
                    }
                }
            }
            
            // this clause is always satisfied so we don't need to optimize it
            if (clauseConstSat)
            {
                continue;
            }
            
            
            // now make the clause array
            var clauseArray : Array<Dynamic> = new Array<Dynamic>();
            clauseArray.push(CONFLICT_CONSTRAINT_VALUE);
            selectedConstraintValue += as3hx.Compat.parseInt(CONFLICT_CONSTRAINT_VALUE);
            
            // find all variables connected to the constraint, and add them to the array
            for (gameEdgeId in node.connectedEdgeIds)
            {
                edge = Reflect.field(edgeLayoutObjs, gameEdgeId);
                fromNode = edge.fromNode;
                
                // is this variable a constant?
                if (selectedNodesDict[fromNode.id] == null)
                {
                // then skip
                    
                    continue;
                }
                
                // get the solver id for this variable
                var constraintID : Int;
                if (nodeIDToConstraintsTwoWayMap[fromNode.id] == null)
                {
                    nodeIDToConstraintsTwoWayMap[fromNode.id] = counter;
                    nodeIDToConstraintsTwoWayMap[counter] = fromNode;
                    constraintID = counter;
                    counter++;
                }
                else
                {
                    constraintID = nodeIDToConstraintsTwoWayMap[fromNode.id];
                }
                
                //if the constraint starts from the clause, it's a positive var, else it's negative.
                if (gameEdgeId.indexOf("c") == 0)
                {
                    clauseArray.push(constraintID);
                }
                else
                {
                    clauseArray.push(-constraintID);
                }
            }
            
            constraintArray.push(clauseArray);
        }
    }
    
    
    private function createConstraintsForClauses() : Void
    {
        for (node in selectedNodes)
        {
            if (debugSolver)
            {
                node.solverSelected = true;
                node.solverSelectedColor = 0xff00ff;
                solverSelected.push(node);
            }
            if (node.isClause)
            {
                newSelectedClauses[node.id] = node;
                var clauseArray : Array<Dynamic> = new Array<Dynamic>();
                clauseArray.push(CONFLICT_CONSTRAINT_VALUE);
                selectedConstraintValue += as3hx.Compat.parseInt(CONFLICT_CONSTRAINT_VALUE);
                //find all variables connected to the constraint, and add them to the array
                for (gameEdgeId in node.connectedEdgeIds)
                {
                    var edge : Edge = edgeLayoutObjs[gameEdgeId];
                    var fromNode : Node = edge.fromNode;
                    
                    storedDirectEdgesDict[gameEdgeId] = edge;
                    
                    var constraintID : Int;
                    if (nodeIDToConstraintsTwoWayMap[fromNode.id] == null)
                    {
                        nodeIDToConstraintsTwoWayMap[fromNode.id] = counter;
                        nodeIDToConstraintsTwoWayMap[counter] = fromNode;
                        constraintID = counter;
                        counter++;
                    }
                    else
                    {
                        constraintID = nodeIDToConstraintsTwoWayMap[fromNode.id];
                    }
                    
                    //if the constraint starts from the clause, it's a positive var, else it's negative.
                    if (gameEdgeId.indexOf("c") == 0)
                    {
                        clauseArray.push(constraintID);
                    }
                    else
                    {
                        clauseArray.push(-constraintID);
                    }
                    
                    directNodeDict[fromNode.id] = fromNode;
                }
                constraintArray.push(clauseArray);
            }
            else
            {
                newSelectedVars.push(node);
                node.animating = true;
                m_solvingNodesToAnimate[node.id] = node;
            }
        }
    }
    
    private function findIsolatedSelectedVars() : Void
    //check for variables that have no selected attached clauses. If found, create a clause for each attached constraint
    {
        
        //and clauses for the far ends to suggest they don't change
        for (selectedVar in newSelectedVars)
        {
            var attachedSelected : Bool = false;
            
            for (edgeID in selectedVar.connectedEdgeIds)
            {
                var edgeToCheck : Edge = edgeLayoutObjs[edgeID];
                var toNodeToCheck : Node = edgeToCheck.toNode;
                if (newSelectedClauses[toNodeToCheck.id] != null)
                {
                    attachedSelected = true;
                    continue;
                }
            }
            
            if (attachedSelected == false)
            {
                for (unattachedEdgeID in selectedVar.connectedEdgeIds)
                {
                    var unattachedEdge : Edge = edgeLayoutObjs[unattachedEdgeID];
                    var toClause : ClauseNode = try cast(unattachedEdge.toNode, ClauseNode) catch(e:Dynamic) null;
                    
                    if (debugSolver)
                    {
                        toClause.solverSelected = true;
                        toClause.solverSelectedColor = 0x00ffff;
                        solverSelected.push(toClause);
                    }
                    
                    var clauseArray : Array<Dynamic> = new Array<Dynamic>();
                    clauseArray.push(CONFLICT_CONSTRAINT_VALUE);
                    selectedConstraintValue += as3hx.Compat.parseInt(CONFLICT_CONSTRAINT_VALUE);
                    for (gameEdgeId in toClause.connectedEdgeIds)
                    {
                        var constraintEdge : Edge = edgeLayoutObjs[gameEdgeId];
                        var fromNode : Node = constraintEdge.fromNode;
                        //directNodeArray.push(fromNode1);
                        //directEdgeDict[gameEdgeId1] = edge3;
                        
                        var constraintID : Int;
                        if (nodeIDToConstraintsTwoWayMap[fromNode.id] == null)
                        {
                            nodeIDToConstraintsTwoWayMap[fromNode.id] = counter;
                            nodeIDToConstraintsTwoWayMap[counter] = fromNode;
                            constraintID = counter;
                            counter++;
                        }
                        else
                        {
                            constraintID = nodeIDToConstraintsTwoWayMap[fromNode.id];
                        }
                        
                        //if the constraint starts from the clause, it's a positive var, else it's negative.
                        if (gameEdgeId.indexOf("c") == 0)
                        {
                            clauseArray.push(constraintID);
                        }
                        else
                        {
                            clauseArray.push(-constraintID);
                        }
                        
                        if (fromNode != selectedVar)
                        {
                        //create a separate clause here for this one node, based on it's current size
                            
                            var nodeClauseArray : Array<Dynamic> = new Array<Dynamic>();
                            nodeClauseArray.push(CONFLICT_CONSTRAINT_VALUE);
                            selectedConstraintValue += as3hx.Compat.parseInt(CONFLICT_CONSTRAINT_VALUE);
                            
                            if (fromNode.isNarrow)
                            {
                                nodeClauseArray.push(-constraintID);
                            }
                            else
                            {
                                nodeClauseArray.push(constraintID);
                            }
                            constraintArray.push(nodeClauseArray);
                        }
                    }
                    constraintArray.push(clauseArray);
                }
            }
        }
    }
    
    private function fixEdgeVarValues() : Void
    //now, find all the other constraints associated with the directly connected variables,
    {
        
        //add the nodes connected to those constraints as fixed values,
        //so the score doesn't go down.
        for (directNode in directNodeDict)
        {
            for (conEdgeID in directNode.connectedEdgeIds)
            {
            //have we already dealt with this edge?
                
                if (storedDirectEdgesDict[conEdgeID] != null)
                {
                    continue;
                }
                
                var conEdge : Edge = edgeLayoutObjs[conEdgeID];
                storedDirectEdgesDict[conEdgeID] = conEdge;
                
                var nextLayerClause : ClauseNode = try cast(conEdge.toNode, ClauseNode) catch(e:Dynamic) null;
                
                if (nextLayerClause.hasError())
                {
                //ignore if I don't care if the value changes
                    
                    continue;
                }
                
                if (newSelectedClauses[nextLayerClause.id] == null)
                {
                //add to redraw if needed
                    
                    selectedNodes.push(nextLayerClause);
                    newSelectedClauses[nextLayerClause.id] = nextLayerClause;
                    
                    if (debugSolver)
                    {
                        nextLayerClause.solverSelected = true;
                        nextLayerClause.solverSelectedColor = 0x00ff00;
                        solverSelected.push(nextLayerClause);
                    }
                    
                    var clauseArray : Array<Dynamic> = new Array<Dynamic>();
                    clauseArray.push(CONFLICT_CONSTRAINT_VALUE * 2);  //multiply just so this is slightly higher value  
                    selectedConstraintValue += as3hx.Compat.parseInt(CONFLICT_CONSTRAINT_VALUE * 2);
                    for (edgeID in nextLayerClause.connectedEdgeIds)
                    {
                    //create constraint for clause connected to edge node
                        
                        var cEdge : Edge = edgeLayoutObjs[edgeID];
                        var connectedNode : Node = cEdge.fromNode;
                        selectedNodes.push(connectedNode);
                        var nextLevelConstraintID : Int;
                        if (nodeIDToConstraintsTwoWayMap[connectedNode.id] == null)
                        {
                            nodeIDToConstraintsTwoWayMap[connectedNode.id] = counter;
                            nodeIDToConstraintsTwoWayMap[counter] = connectedNode;
                            nextLevelConstraintID = counter;
                            counter++;
                        }
                        else
                        {
                            nextLevelConstraintID = nodeIDToConstraintsTwoWayMap[connectedNode.id];
                        }
                        
                        if (edgeID.indexOf("c") == 0)
                        {
                        //if(connectedNode.isNarrow)
                            
                            clauseArray.push(nextLevelConstraintID);
                        }
                        else
                        {
                            clauseArray.push(-nextLevelConstraintID);
                        }
                        
                        
                        
                        if (debugSolver)
                        {
                            connectedNode.solverSelected = true;
                            connectedNode.solverSelectedColor = 0xff0000;
                            solverSelected.push(connectedNode);
                        }
                        
                        if (storedDirectEdgesDict[edgeID] != null)
                        {
                            continue;
                        }
                        
                        var varArray : Array<Dynamic> = new Array<Dynamic>();
                        selectedConstraintValue += as3hx.Compat.parseInt(FIXED_CONSTRAINT_VALUE);
                        varArray.push(FIXED_CONSTRAINT_VALUE);  //FIXED value cause we really don't want this to change, it might add conflicts  
                        //set constraint with current value of connectedNode, not constraint direction
                        if (connectedNode.isNarrow)
                        {
                            varArray.push(-nextLevelConstraintID);
                        }
                        else
                        {
                            varArray.push(nextLevelConstraintID);
                        }
                        constraintArray.push(varArray);
                    }
                    constraintArray.push(clauseArray);
                }
            }
        }
    }
    
    public function solverStartCallback(evt : TimerEvent) : Void
    {
        MaxSatSolver.run_solver(1, constraintArray, initvarsArray, updateCallback, doneCallback);
        dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_STARTED, true));
    }
    
    private var m_lastVarValues : Array<Dynamic>;
    private var m_previousVarValues : Array<Dynamic>;
    public function solverUpdate(vars : Array<Dynamic>, unsat_weight : Int) : Void
    {
        trace("update", unsat_weight);
        if (m_inSolver == false || unsat_weight > m_unsat_weight)
        {
        //got marked done early
            return;
        }
        m_unsat_weight = unsat_weight;
        m_lastVarValues = vars;
        var percentDone : Float = ((selectedConstraintValue - unsat_weight) / selectedConstraintValue) * 100;
        
        dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_UPDATED, true, percentDone));
    }
    
    private function updateNodes(undo : Bool = false) : Void
    {
        if (m_lastVarValues == null)
        {
            return;
        }
        
        m_previousVarValues = new Array<Dynamic>();
        var someNodeUpdated : Bool = false;
        //trace(levelGraph.currentScore);
        var updatedVarIds : String = "";
        var updatedValues : String = "";
        for (ii in 0...m_lastVarValues.length)
        {
            var node : Node = nodeIDToConstraintsTwoWayMap[ii + 1];
            if (node != null && !(Std.is(node, ClauseNode)))
            {
                node.solved = true;
                var constraintVar : ConstraintVar = Reflect.field(node, "graphVar");
                var currentVal : Bool = node.isNarrow;
                var currentNumValue : Int = ((currentVal == true)) ? 0 : 1;
                m_previousVarValues.push(currentNumValue);
                
                if (m_lastVarValues[ii] == 1)
                {
                    node.isNarrow = false;
                }
                else
                {
                    node.isNarrow = true;
                }
                
                someNodeUpdated = someNodeUpdated || (currentVal != node.isNarrow);
                if (currentVal != node.isNarrow)
                {
                    if (PipeJam3.logging)
                    {
                        var simpleId : String = node.id;
                        var idArr : Array<Dynamic> = node.id.split("var_");
                        if (idArr.length == 2)
                        {
                            simpleId = Std.string(idArr[1]);
                        }
                        updatedVarIds += ((updatedVarIds.length == 0)) ? simpleId : ("," + simpleId);
                        updatedValues += ((updatedValues.length == 0)) ? Std.string(currentNumValue) : ("," + currentNumValue);
                    }
                    if (node.skin != null)
                    {
                        m_nodesToDraw[node.id] = node;
                    }
                    if (constraintVar != null)
                    {
                        constraintVar.setProp(PropDictionary.PROP_NARROW, node.isNarrow);
                    }
                    if (tutorialManager != null)
                    {
                        tutorialManager.onWidgetChange(constraintVar.id, PropDictionary.PROP_NARROW, node.isNarrow, levelGraph);
                    }
                }
            }
        }
        
        if (someNodeUpdated)
        {
            onWidgetChange();
        }
        
        if (PipeJam3.logging)
        {
            var details : Dynamic = {};
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_VAR_IDS), updatedVarIds);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_VAR_VALUES), updatedValues);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME), original_level_name);  // yes, we can get this from the quest data but include it here for convenience  
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_SCORE), currentScore);
            Reflect.setField(details, Std.string(VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE), m_targetScore);
            PipeJam3.logging.logQuestAction((undo) ? VerigameServerConstants.VERIGAME_ACTION_UNDO : VerigameServerConstants.VERIGAME_ACTION_AUTOSOLVE_COMPLETE, details, getTimeMs());
        }
    }
    
    public var solverRunCount : Int = 0;
    public var timer : Timer;
    
    public function solverDone(errMsg : String) : Void
    //trace("solver done " + errMsg);
    {
        
        unselectAll();
        updateNodes();
        
        MaxSatSolver.stop_solver();
        levelGraph.updateScore();
        onScoreChange(true);
        drawNodesAfterSolving();
        System.gc();
        var scoreWentDown : Bool = true;
        if (levelGraph.oldScore <= levelGraph.currentScore)
        {
            scoreWentDown = false;
        }
        //do this twice, once to reset solver color, again after setting inSolver to false to reset selection color
        dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_STOPPED, true, scoreWentDown));
        m_inSolver = false;
        dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_STOPPED, true));
        
        if (runContinualSolver && solverRunCount < 250)
        {
            solverRunCount++;
            //trace("count", count);
            timer = new Timer(1000, 1);
            timer.addEventListener(TimerEvent.TIMER, solverTimerCallback);
            timer.start();
        }
    }
    
    //draw nodes in a different color to indicate solver is done
    public function drawNodesAfterSolving() : Void
    {
        m_recentlySolved = true;
        for (node in selectedNodes)
        {
            node.solved = true;
            node.unselect();
            if (node.isClause)
            {
                continue;
            }
            node.animating = false;
            if (node.skin)
            {
                Starling.current.juggler.removeTweens(node.skin);
                m_nodesToDraw[node.id] = node;
            }
        }
    }
    
    public function onViewSpaceChanged(event : MiniMapEvent) : Void
    {
    }
    
    public function selectNodes(localPt : Point, dX : Float, dY : Float) : Void
    {
        if (currentGroupDepth < 0)
        {
            currentGroupDepth = 0;
        }
        var groupGrid : GroupGrid = m_groupGrids[currentGroupDepth];
        var GRID_DIM : Point = groupGrid.gridDimensions.clone();
        var MAX_SEL : Int = getMaxSelectableWidgets();
        var RAD_SQUARED : Float = dX * dX;
        
        var leftGridNumber : Int = GroupGrid.getGridX(localPt.x - dX, GRID_DIM);
        var rightGridNumber : Int = GroupGrid.getGridX(localPt.x + dX, GRID_DIM);
        var topGridNumber : Int = GroupGrid.getGridX(localPt.y - dY, GRID_DIM);
        var bottomGridNumber : Int = GroupGrid.getGridX(localPt.y + dY, GRID_DIM);
        var selectionChanged : Bool = false;
        //trace("localPt: ", localPt, " dX/Y: ", dX);
        for (i in leftGridNumber...rightGridNumber + 1)
        {
            for (j in topGridNumber...bottomGridNumber + 1)
            {
                var gridName : String = i + "_" + j;
                if (!groupGrid.grid.exists(gridName))
                {
                    continue;
                }  // no nodes in this grid  
                var gridNodeDict : Dictionary = try cast(groupGrid.grid[gridName], Dictionary) catch(e:Dynamic) null;
                for (nodeId in Reflect.fields(gridNodeDict))
                {
                    var node : Node = try cast(Reflect.field(nodeLayoutObjs, nodeId), Node) catch(e:Dynamic) null;
                    if (node == null)
                    {
                        trace("WARNING! Node id not found: " + nodeId);
                        continue;
                    }
                    
                    // early out if we're not going to select clause nodes
                    if (PipeJam3.SELECTION_STYLE == PipeJam3.SELECTION_STYLE_VAR_BY_VAR && node.isClause)
                    {
                        continue;
                    }
                    
                    var diffX : Float = localPt.x - node.centerPoint.x;
                    //trace("node.centerPoint: ", node.centerPoint);
                    if (diffX > dX || -diffX > dX)
                    {
                        continue;
                    }
                    var diffY : Float = localPt.y - node.centerPoint.y;
                    if (diffY > dY || -diffY > dY)
                    {
                        continue;
                    }
                    var diffXSq : Float = diffX * diffX;
                    var diffYSq : Float = diffY * diffY;
                    if (diffXSq + diffYSq <= RAD_SQUARED && !node.isSelected)
                    {
                        if (false)
                        {
                        // use this branch for actively unselecting when max is reached
                            
                            while (selectedNodes.length >= MAX_SEL)
                            {
                                var unselNode : Node = selectedNodes.shift();
                                unselNode.animating = false;
                                unselNode.unselect();
                            }
                        }
                        else if (selectedNodes.length >= MAX_SEL)
                        {
                            break;
                        }
                        
                        if (PipeJam3.SELECTION_STYLE == PipeJam3.SELECTION_STYLE_CLASSIC || !node.isClause)
                        {
                            if (!node.isSelected)
                            {
                            //trace("select direct " + node.id);
                                
                                node.select();
                                selectedNodes.push(node);
                                m_nodesToDraw[node.id] = node;
                                selectionChanged = true;
                            }
                        }
                        
                        //select attached nodes?
                        if (Std.is(node, ClauseNode))
                        {
                            for (edgeID in node.connectedEdgeIds)
                            {
                                var edge : Edge = this.edgeLayoutObjs[edgeID];
                                var connectedNode : Node = edge.fromNode;
                                if (!connectedNode.isSelected && Lambda.has(m_nodeOnScreenDict, connectedNode.id))
                                {
                                //trace("select connect " + connectedNode.id);
                                    
                                    connectedNode.select();
                                    selectedNodes.push(connectedNode);
                                    m_nodesToDraw[connectedNode.id] = connectedNode;
                                    selectionChanged = true;
                                }
                                if (selectedNodes.length >= MAX_SEL)
                                {
                                    break;
                                }
                            }
                        }
                    }
                }
                if (selectedNodes.length >= MAX_SEL)
                {
                    break;
                }
            }
        }
        //trace("Paint select changed:" + selectionChanged);
        if (selectionChanged)
        {
            dispatchEvent(new SelectionEvent(SelectionEvent.NUM_SELECTED_NODES_CHANGED, null, null));
        }
    }
    
    public function unselectLast() : Void
    {
        if (debugSolver && selectedNodes.length == 0)
        {
        //reset flashing on previously solved nodes
            
            if (solverSelected != null)
            {
                for (node in solverSelected)
                {
                    node.solverSelected = false;
                }
            }
            
            solverSelected = new Array<Node>();
        }
    }
    
    public function emphasizeBrushes() : Int
    {
        if (tutorialManager != null)
        {
            return tutorialManager.emphasizeBrushes();
        }
        return 0x0;
    }
    
    private static function popNode(d : Map<String, Node>) : Node
    {
        for (id in d.keys())
        {
			return d.remove(id);
        }
        return null;
    }
    
    public function undo() : Void
    //switch last with previous settings, and then update from Last
    {
        
        var temp : Array<Dynamic> = m_lastVarValues;
        m_lastVarValues = m_previousVarValues;
        m_previousVarValues = temp;
        updateNodes(true);
    }
}