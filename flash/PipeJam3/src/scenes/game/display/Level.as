package scenes.game.display
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import assets.AssetInterface;
	
	import constraints.Constraint;
	import constraints.ConstraintClause;
	import constraints.ConstraintEdge;
	import constraints.ConstraintGraph;
	import constraints.ConstraintScoringConfig;
	import constraints.ConstraintValue;
	import constraints.ConstraintVar;
	import constraints.events.ErrorEvent;
	import constraints.events.VarChangeEvent;
	
	import deng.fzip.FZip;
	
	import dialogs.RankProgressDialog;
	import dialogs.RankProgressDialogInfo;
	
	import events.MenuEvent;
	import events.MiniMapEvent;
	import events.PropertyModeChangeEvent;
	import events.SelectionEvent;
	import events.WidgetChangeEvent;
	
	import networking.GameFileHandler;
	import networking.PlayerValidation;
	
	import scenes.BaseComponent;
	import scenes.game.PipeJamGameScene;
	import scenes.game.components.GridViewPanel;
	import scenes.game.components.MiniMap;
	import scenes.game.components.TutorialText;
	import scenes.game.display.Node;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	import system.MaxSatSolver;
	import system.VerigameServerConstants;
	
	import utils.Base64Encoder;
	import utils.PropDictionary;
	import utils.XMath;
	import utils.XObject;
	import utils.XString;
	
	/**
	 * Level all game components - widgets and links
	 */
	public class Level extends BaseComponent
	{
		/** True to allow user to navigate to any level regardless of whether levels below it are solved for debugging */
		public static var UNLOCK_ALL_LEVELS_FOR_DEBUG:Boolean = false;
		private static const MIN_NODE_SCALE:Number = 4.0 / Constants.GAME_SCALE;
		
		/** Name of this level */
		public var level_name:String;
		
		/** Node collection used to create this level, including name obfuscater */
		public var levelGraph:ConstraintGraph;
		
		public var selectedNodes:Vector.<Node> = new Vector.<Node>();
		/** used by solver to keep track of which nodes map to which constraint values, and visa versa */
		protected var nodeIDToConstraintsTwoWayMap:Dictionary;
		
		//the level node and decendents
		protected var m_levelLayoutObj:Object;
		public var levelObj:Object;
		public var m_levelLayoutName:String;
		public var m_levelQID:String;
		//used when saving, as we need a parent graph element for the above level node
		public var m_levelLayoutObjWrapper:Object;
		public var m_levelAssignmentsObj:Object;
		protected var m_levelOriginalAssignmentsObj:Object; //used for restarting the level
		protected var m_levelBestScoreAssignmentsObj:Object; //best configuration so far
		public var m_tutorialTag:String;
		public var tutorialManager:TutorialLevelManager;
		protected var m_layoutFixed:Boolean = false;
		public var m_targetScore:int;
		
		public var m_numNodes:uint = 0;
		public var nodeLayoutObjs:Dictionary = new Dictionary();
		public var edgeLayoutObjs:Dictionary = new Dictionary();
		
		protected var m_hidingErrorText:Boolean = false;
		
		public var m_boundingBox:Rectangle = new Rectangle(0, 0, 1, 1);
		protected var m_backgroundImage:Image;
		protected var m_levelStartTime:Number;
		
		protected var initialized:Boolean = false;
		
		/** Current Score of the player */
		protected var m_bestScore:int = 0;
		
		/** Set to true when the target score is reached. */
		public var targetScoreReached:Boolean;
		public var original_level_name:String;
		
		public var brushesToActivate:int;
		public var currentGroupDepth:int = -1;
		public var levelLayoutScale:Number = 1.0;
		private var m_nodeAnimationLayer:Sprite;
		private var m_nodeLayer:Sprite;
		private var m_nodeClauseSubLayer:Sprite;
		private var m_nodeVarSubLayer:Sprite;
		private var m_edgesLayer:Sprite;
		private var m_conflictAnimationLayer:Sprite;
		private var m_conflictsLayer:Sprite;
		private var m_offscreenEdgesLayer:Sprite;
		private var m_nodesToRemove:Dictionary = new Dictionary();
		private var m_nodesToDraw:Dictionary = new Dictionary();
		private var m_solvingNodesToAnimate:Dictionary = new Dictionary();
		private var m_solvedConflictsToAnimate:Dictionary = new Dictionary();
		private var m_createdConflictsToAnimate:Vector.<ClauseNode> = new Vector.<ClauseNode>();
		private var m_nodeOnScreenDict:Dictionary = new Dictionary();
		private var m_groupGrids:Vector.<GroupGrid>
		private static const ITEMS_PER_FRAME:uint = 300; // limit on nodes/edges to remove/add per frame
		
		static public var CONFLICT_CONSTRAINT_VALUE:Number = 10.0;
		static public var FIXED_CONSTRAINT_VALUE:Number = 1000.0;
		static public var WIDE_NODE_SIZE_CONSTRAINT_VALUE:Number = 1.0;
		static public var NARROW_NODE_SIZE_CONSTRAINT_VALUE:Number = 0.0;
		
		/** Tracks total distance components have been dragged since last visibile calculation */
		public var totalMoveDist:Point = new Point();
		
		public var m_inSolver:Boolean = false;
		private var m_unsat_weight:int = -1;
		private var m_recentlySolved:Boolean;
		public var solverSelected:Vector.<Node> = new Vector.<Node>();
		
		static public var debugSolver:Boolean = false;
		public var extendSolver:Boolean = true;
		
		public static var numNodesOnScreen:int = 0;
		
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
		public function Level(_name:String, _levelGraph:ConstraintGraph, _levelObj:Object, _levelLayoutObj:Object, _levelAssignmentsObj:Object, _originalLevelName:String)
		{
			UNLOCK_ALL_LEVELS_FOR_DEBUG = PipeJamGame.DEBUG_MODE;
			level_name = _name;
			original_level_name = _originalLevelName;
			levelGraph = _levelGraph;
			levelObj = _levelObj;
			m_levelLayoutObj = _levelLayoutObj;
			m_levelLayoutName = _levelLayoutObj["id"];
			m_levelQID = _levelObj["qid"];
			m_levelBestScoreAssignmentsObj = _levelAssignmentsObj;// XObject.clone(_levelAssignmentsObj);
			m_levelOriginalAssignmentsObj = _levelAssignmentsObj;// XObject.clone(_levelAssignmentsObj);
			m_levelAssignmentsObj = _levelAssignmentsObj;// XObject.clone(_levelAssignmentsObj);
			
			m_tutorialTag = m_levelLayoutObj["tutorial"];
			if (m_tutorialTag != null) {
				tutorialManager = new TutorialLevelManager(m_tutorialTag);
				m_layoutFixed = tutorialManager.getLayoutFixed();
			}
			
			if(levelGraph.graphScoringConfig && levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY))
				CONFLICT_CONSTRAINT_VALUE = levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.CONSTRAINT_VALUE_KEY);
			
			if(levelGraph.graphScoringConfig && levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY))
				WIDE_NODE_SIZE_CONSTRAINT_VALUE = levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_1_VALUE_KEY);
			
			if(levelGraph.graphScoringConfig && levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY))
				NARROW_NODE_SIZE_CONSTRAINT_VALUE = levelGraph.graphScoringConfig.getScoringValue(ConstraintScoringConfig.TYPE_0_VALUE_KEY);
			
			m_targetScore = int.MAX_VALUE;
			if (PipeJam3.ASSET_SUFFIX == "Turk")
			{
				m_targetScore = 0;
				for (var key:String in nodeLayoutObjs)
				{
					if (nodeLayoutObjs[key] is ClauseNode) m_targetScore++;
				}
			}
			else
			{
				if ((m_levelAssignmentsObj["target_score"] != undefined) && !isNaN(int(m_levelAssignmentsObj["target_score"]))) {
					m_targetScore = int(m_levelAssignmentsObj["target_score"]);
					//now check to see if we have a higher target if not in tutorial
					if(!PipeJamGameScene.inTutorial)
					{
						if(PipeJamGame.levelInfo && PipeJamGame.levelInfo.target_score && m_targetScore < PipeJamGame.levelInfo.target_score)
							m_targetScore = PipeJamGame.levelInfo.target_score;
					}
				}
				else
				{
					m_targetScore = PipeJamGame.levelInfo.target_score;
				}
			}
			targetScoreReached = false;
			addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage); 
			
			NodeSkin.InitializeSkins();
			m_recentlySolved = false;
		}
		
		public function loadBestScoringConfiguration():void
		{
			loadAssignments(m_levelBestScoreAssignmentsObj, true, true);
		}
		
		public function loadInitialConfiguration():void
		{
			loadAssignments(m_levelOriginalAssignmentsObj, true);
		}
		
		public function loadAssignmentsConfiguration(assignmentsObj:Object):void
		{
			loadAssignments(assignmentsObj);
		}
		
		protected function loadAssignments(assignmentsObj:Object, updateTutorialManager:Boolean = false, isBest:Boolean = false):void
		{
			var graphVar:ConstraintVar;
			var narrowIds:String = "";
			var wideIds:String = "";
			for (var varId:String in levelGraph.variableDict) {
				graphVar = levelGraph.variableDict[varId] as ConstraintVar;
				var wasSetWide:Boolean = setGraphVarFromAssignments(graphVar, assignmentsObj, updateTutorialManager);
				if (PipeJam3.logging)
				{
					var simpleId:String = varId;
					var idArr:Array = varId.split("var_");
					if (idArr.length == 2) simpleId = idArr[1] as String;
					if (wasSetWide)
					{
						wideIds += (wideIds.length == 0) ? simpleId : ("," + simpleId);
					}
					else
					{
						narrowIds += (narrowIds.length == 0) ? simpleId : ("," + simpleId);
					}
				}
			}
			if(graphVar != null) dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, graphVar, PropDictionary.PROP_NARROW, graphVar.getProps().hasProp(PropDictionary.PROP_NARROW), this, null));
			refreshTroublePoints();
			onScoreChange();
			if (PipeJam3.logging)
			{
				var details:Object = new Object();
				if (wideIds.length < narrowIds.length) // log whichever is less burdensome
				{
					details[VerigameServerConstants.ACTION_PARAMETER_WIDE_VAR_IDS] = wideIds;
				}
				else
				{
					details[VerigameServerConstants.ACTION_PARAMETER_NARROW_VAR_IDS] = narrowIds;
				}
				details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = original_level_name; // yes, we can get this from the quest data but include it here for convenience
				details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = currentScore;
				details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = m_targetScore;
				PipeJam3.logging.logQuestAction(isBest ? VerigameServerConstants.VERIGAME_ACTION_LOAD_BEST_ASSIGNMENTS : VerigameServerConstants.VERIGAME_ACTION_LOAD_ASSIGNMENTS, details, getTimeMs());
			}
		}
		
		protected function setGraphVarFromAssignments(graphVar:ConstraintVar, assignmentsObj:Object, updateTutorialManager:Boolean = false):Boolean
		{
			// By default, reset gameNode to default value, then if contained in "assignments" obj, use that value instead
			var assignmentIsWide:Boolean = (graphVar.defaultVal.verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
			if (assignmentsObj["assignments"].hasOwnProperty(graphVar.formattedId)
				&& assignmentsObj["assignments"][graphVar.formattedId].hasOwnProperty(ConstraintGraph.TYPE_VALUE)) {
				assignmentIsWide = (assignmentsObj["assignments"][graphVar.formattedId][ConstraintGraph.TYPE_VALUE] == ConstraintValue.VERBOSE_TYPE_1);
			}
			if (graphVar.getProps().hasProp(PropDictionary.PROP_NARROW) == assignmentIsWide) {
				levelGraph.updateScore(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide);
				//graphVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
				//levelGraph.updateScore();
				if (updateTutorialManager && tutorialManager) {
					tutorialManager.onWidgetChange(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide, levelGraph);
				}
			}
			var gameNode:Node = nodeLayoutObjs[graphVar.id] as Node;
			if (gameNode && gameNode.isNarrow == assignmentIsWide) {
				gameNode.isNarrow = !assignmentIsWide;
			}
			return assignmentIsWide;
		}
		
		protected function onAddedToStage(event:starling.events.Event):void
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
			
			dispatchEvent(new starling.events.Event(Constants.STOP_BUSY_ANIMATION,true));
		}
		
		protected function onEnterFrame(evt:EnterFrameEvent):void
		{
			draw();
		}
		
		protected function countDictItems(dict:Dictionary):int
		{
			var count:int = 0;
			for each(var i:Object in dict)
				count++;
				
			return count;
		}
		
		//called on when GridViewPanel content is moving
		public function updateLevelDisplay(viewRect:Rectangle = null, content:DisplayObject = null):int
		{
			var nGroups:int = (levelGraph.groupsArr ? levelGraph.groupsArr.length : 0);
			var newGroupDepth:int = 0;
			var i:int;
			var j:int;
			var groupGrid:GroupGrid;
			
			if (nGroups > 0)
			{
				for (i = 2; i < nGroups; i++)
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
			
			var candidatesToRemove:Dictionary = new Dictionary();
			for (var nodeOnScreenId:String in m_nodeOnScreenDict) { candidatesToRemove[nodeOnScreenId] = true; numNodesOnScreen--; }
			
			groupGrid = m_groupGrids[newGroupDepth];
			var scaledDimensions:Point= groupGrid.gridDimensions.clone();
		//	if(content)
		//		scaledDimensions.normalize(content.scaleX);
			
			var minX:int = (viewRect == null) ? 0 : GroupGrid.getGridX(viewRect.left, scaledDimensions);
			var maxX:int = GroupGrid.getGridXRight((viewRect == null) ? m_boundingBox.right : viewRect.right, scaledDimensions);
			var minY:int = (viewRect == null) ? 0 : GroupGrid.getGridY(viewRect.top, scaledDimensions) -1;
			var maxY:int = GroupGrid.getGridYBottom((viewRect == null) ? m_boundingBox.bottom : viewRect.bottom, scaledDimensions);
			var count:int = 0;

			for (i = minX; i <= maxX; i++)
			{
				for (j = minY; j <= maxY; j++)
				{
					var gridKey:String = i + "_" + j;
					if (!groupGrid.grid.hasOwnProperty(gridKey)) continue; // no nodes in grid
					// TODO groups: check for existing on screen grids m_gridsOnScreen[gridKey] = groupGrid;
					var gridNodeDict:Dictionary = groupGrid.grid[gridKey] as Dictionary;
					//trace(gridKey, countDictItems(gridNodeDict));
					for (var nodeId:String in gridNodeDict)
					{
						var node:Node = nodeLayoutObjs[nodeId] as Node;
						count++;
						if (node != null)
						{
							//if (!m_nodeOnScreenDict.hasOwnProperty(nodeId)) 
							m_nodesToDraw[node.id] = node;
							if (candidatesToRemove.hasOwnProperty(nodeId)) delete candidatesToRemove[node.graphConstraintSide.id];
						}
					}
				}
				//trace("count", count);
			}
			for (var nodeToRemoveId:String in candidatesToRemove)
			{
				var nodeToRemove:Node = nodeLayoutObjs[nodeToRemoveId] as Node;
				if (nodeToRemove != null)
				{
					m_nodesToRemove[nodeToRemove.id] = nodeToRemove;
				}
			}
			
			if (count >= 2000)
			{
				trace("WARNING! ADDED: " + count + " nodes at this group level");
			}
			if (count < ITEMS_PER_FRAME && m_tutorialTag)
			{
				draw(); // for relatively small tutorials, add items right away
			}
			currentGroupDepth = newGroupDepth;
			
			return newGroupDepth;
		}
		
		private var m_initLayers:Boolean = false;
		public function draw():void
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
			var nodesProcessed:uint = 0;
			var edge:Edge, gameEdgeId:String;
			var touchedEdgeLayer:Boolean = false;
			var touchedNodeLayer:Boolean = false;
			var touchedConflictLayer:Boolean = false;
			
			var nodeToRemove:Node;
			//remove node now, edges later
			for each (nodeToRemove in m_nodesToRemove)
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
				if (m_nodeOnScreenDict.hasOwnProperty(nodeToRemove.id)) {delete m_nodeOnScreenDict[nodeToRemove.id]; numNodesOnScreen--; }
				nodesProcessed++;
				if (nodesProcessed > ITEMS_PER_FRAME && !m_tutorialTag) break;
			}
			
			var nodeToDraw:Node = popNode(m_nodesToDraw);
			while (nodeToDraw != null)	
			{
				var alreadyOnScreen:Boolean = m_nodeOnScreenDict.hasOwnProperty(nodeToDraw.id);
				if (nodeToDraw.animating)
				{
					nodeToDraw = popNode(m_nodesToDraw);
					continue;
				}
				// This breaks initial drawing
			//	if (!nodeToDraw.isClause)
				{
					for each(gameEdgeId in nodeToDraw.connectedEdgeIds)
					{
						edge = edgeLayoutObjs[gameEdgeId];
						if (!alreadyOnScreen)
						{
							if(edge.skin && edge.skin.parent)
							{
								edge.skin.removeFromParent(true);
								edge.skin = null;
							}
							edge.createSkin(currentGroupDepth);
						}
						if (edge.skin)
						{
							if (alreadyOnScreen) edge.updateEdge();
							adjustEdgeContainer(edge, true);
							touchedEdgeLayer = true;
						}
						
					}
				}
				
				var desiredLayer:Sprite = nodeToDraw.isClause ? m_nodeClauseSubLayer : m_nodeVarSubLayer;
				if (nodeToDraw.skin != null && nodeToDraw.skin.parent != desiredLayer)
				{
					nodeToDraw.skin.removeFromParent();
				}
				nodeToDraw.createSkin();
				for each(var gameEdgeID:String in nodeToDraw.connectedEdgeIds)
				{
					var edgeObj:Edge = edgeLayoutObjs[gameEdgeID];
					if (edgeObj) edgeObj.isDirty = true;
				}
				
				if (nodeToDraw.skin != null)
				{
					m_nodeOnScreenDict[nodeToDraw.id] = true;
					numNodesOnScreen++;
					if (parent)
					{
						nodeToDraw.skin.scale(0.5 / parent.scaleX);
					}
					if (nodeToDraw.skin.parent != desiredLayer)
					{
						desiredLayer.addChild(nodeToDraw.skin);
					}
					touchedNodeLayer = true;
					if (nodeToDraw.backgroundSkin)
					{
						if (nodeToDraw.backgroundSkin.parent != m_conflictsLayer) m_conflictsLayer.addChild(nodeToDraw.backgroundSkin);
						if (parent)
						{
							nodeToDraw.backgroundSkin.scale(0.5 / parent.scaleX);
						}
						touchedConflictLayer = true;
					}
				}
				nodesProcessed++;
				if (nodesProcessed > ITEMS_PER_FRAME && !m_tutorialTag) break;
				nodeToDraw = popNode(m_nodesToDraw);
			}
			
			//remove old edges last, since we need node out of nodesToDraw and m_nodeOnScreenDict arrays
			var nodeToRemove1:Node = popNode(m_nodesToRemove);
			while (nodeToRemove1 != null)
			{
				for each(gameEdgeId in nodeToRemove1.connectedEdgeIds)
				{
					edge = edgeLayoutObjs[gameEdgeId];
					adjustEdgeContainer(edge);
					touchedEdgeLayer = true;
				}
				nodeToRemove1 = popNode(m_nodesToRemove);
			}
			
			if (nodesProcessed <= ITEMS_PER_FRAME) // enqueue animations only once all other nodes have been drawn/removed
			{
				var tween:Tween;
				var n:int = 0;
				var solvingNodeToAnimate:VariableNode = popNode(m_solvingNodesToAnimate) as VariableNode;
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
						Starling.juggler.add(tween);
					}
					n++; // do all at once, don't increment nodesProcessed
					solvingNodeToAnimate = popNode(m_solvingNodesToAnimate) as VariableNode;
				}
				n = 0;
				var solvedClauseToAnimate:ClauseNode = popNode(m_solvedConflictsToAnimate) as ClauseNode;
				while (solvedClauseToAnimate != null)	
				{
					if (solvedClauseToAnimate.backgroundSkin == null)
					{
						solvedClauseToAnimate = popNode(m_solvedConflictsToAnimate) as ClauseNode;
						continue; // only animate onscreen clauses
					}
					var animateSkin:NodeSkin = NodeSkin.getNextSkin();
					animateSkin.setNodeProps(true, false, false, false, true, true);
					animateSkin.draw();
					animateSkin.x = solvedClauseToAnimate.centerPoint.x;
					animateSkin.y = solvedClauseToAnimate.centerPoint.y;
					animateSkin.scale(0.5 / parent.scaleX);
					m_conflictAnimationLayer.addChild(animateSkin);
					tween = new Tween(animateSkin, 0.4, Transitions.EASE_IN_BACK);
					tween.scaleTo(0);
					tween.delay = (n * 0.05) % 0.5;
					solvedClauseToAnimate.backgroundSkin.removeFromParent(true);
					solvedClauseToAnimate.backgroundSkin.disableSkin();
					solvedClauseToAnimate.backgroundSkin = null;
					tween.onComplete = conflictRemovedTweenComplete;
					tween.onCompleteArgs = new Array(solvedClauseToAnimate, animateSkin);
					Starling.juggler.add(tween);
					n++; // do all at once, don't increment nodesProcessed just stagger delay times
					solvedClauseToAnimate = popNode(m_solvedConflictsToAnimate) as ClauseNode;
				}
			}
			m_recentlySolved = false;
			if (touchedEdgeLayer)
			{
				m_edgesLayer.flatten();
				m_offscreenEdgesLayer.flatten();
			}
			if (touchedNodeLayer) m_nodeLayer.flatten();
			if (touchedConflictLayer) m_conflictsLayer.flatten();
		}
		
		private function adjustEdgeContainer(edge:Edge, forceDrawing:Boolean = false):void
		{
			if (edge.skin == null) return;
			var fromOnscreen:Boolean = (m_nodeOnScreenDict.hasOwnProperty(edge.fromNode.id) || m_nodesToDraw.hasOwnProperty(edge.fromNode.id));
			var toOnscreen:Boolean = (m_nodeOnScreenDict.hasOwnProperty(edge.toNode.id) || m_nodesToDraw.hasOwnProperty(edge.toNode.id));
			if (fromOnscreen && toOnscreen || forceDrawing)
			{
				if (edge.skin.parent != m_edgesLayer) m_edgesLayer.addChildAt(edge.skin, 0);
			}
			else if (fromOnscreen || toOnscreen)
			{
				if (edge.skin.parent != m_offscreenEdgesLayer) m_offscreenEdgesLayer.addChildAt(edge.skin, 0);
			}
			else
			{
				edge.skin.removeFromParent(true);
				edge.skin = null;
			}
		}
		
		private function conflictRemovedTweenComplete(clauseNode:ClauseNode, skin:NodeSkin):void
		{
			clauseNode.animating = false;
			m_nodesToDraw[clauseNode.id] = clauseNode;
			skin.removeFromParent(true);
			skin.disableSkin();
		}
		
		private function createGridChildFromLayoutObj(gridChildId:String, gridChildLayout:Object, isGroup:Boolean):GridChild
		{
			var layoutX:Number = Number(gridChildLayout["x"]) * Constants.GAME_SCALE * levelLayoutScale;
			var layoutY:Number = Number(gridChildLayout["y"]) * Constants.GAME_SCALE * levelLayoutScale;
			
			var gridChild:GridChild;
			
			if (nodeLayoutObjs.hasOwnProperty(gridChildId)) {
				var prevNode:Node = nodeLayoutObjs[gridChildId] as Node;
				if (prevNode.skin) {
					prevNode.skin.disableSkin();
					prevNode.skin = null;
				}
			}
			
			var nodeBB:Rectangle = new Rectangle(layoutX - Constants.SKIN_DIAMETER * .5, layoutY - Constants.SKIN_DIAMETER * .5, Constants.SKIN_DIAMETER, Constants.SKIN_DIAMETER);
			if (gridChildId.substr(0, 3) == "var") {
				var graphVar:ConstraintVar = levelGraph.variableDict[gridChildId] as ConstraintVar;
				gridChild = new VariableNode(gridChildId, nodeBB, graphVar);
			} else {
				var graphClause:ConstraintClause = levelGraph.clauseDict[gridChildId] as ConstraintClause;
				gridChild = new ClauseNode(gridChildId, nodeBB, graphClause);
			}
			
			nodeLayoutObjs[gridChildId] = gridChild;
			return gridChild;
		}
		
		protected function loadLayout():void
		{
			nodeLayoutObjs = new Dictionary();
			edgeLayoutObjs = new Dictionary();
			
			var minX:Number, minY:Number, maxX:Number, maxY:Number;
			minX = minY = Number.POSITIVE_INFINITY;
			maxX = maxY = Number.NEGATIVE_INFINITY;
			
			// Process layout nodes (vars)
			var gridChild:GridChild;
			var boundsArr:Array = m_levelLayoutObj["layout"]["bounds"] as Array;
			if (boundsArr)
			{
				minX = boundsArr[0] * Constants.GAME_SCALE;
				minY = boundsArr[1] * Constants.GAME_SCALE;
				maxX = boundsArr[2] * Constants.GAME_SCALE;
				maxY = boundsArr[3] * Constants.GAME_SCALE;
			}
			else
			{
				for (var layoutId:String in m_levelLayoutObj["layout"]["vars"])
				{
					var thisNodeLayout:Object = m_levelLayoutObj["layout"]["vars"][layoutId];
					var layoutX:Number = Number(thisNodeLayout["x"]) * Constants.GAME_SCALE;
					var layoutY:Number = Number(thisNodeLayout["y"]) * Constants.GAME_SCALE;
					minX = Math.min(minX, layoutX);
					minY = Math.min(minY, layoutY);
					maxX = Math.max(maxX, layoutX);
					maxY = Math.max(maxY, layoutY);
				}
			}
			
			//check on brush specifications
			var brushArr:Array = m_levelLayoutObj["layout"]["brushes"] as Array;
			brushesToActivate = 0xffffff;
			if (brushArr)
			{
				brushesToActivate = 0;
				for each(var brush:String in brushArr)
				{
					switch(brush)
					{
						case 'wide':
							brushesToActivate += TutorialLevelManager.WIDEN_BRUSH;
							break;
						case 'narrow':
							brushesToActivate += TutorialLevelManager.NARROW_BRUSH;
							break;
						case 'auto':
							brushesToActivate += TutorialLevelManager.SOLVER_BRUSH;
							break;
					}
				}
			}
			
			var bbWidth:Number = maxX - minX + Constants.SKIN_DIAMETER;
			var bbHeight:Number = maxY - minY + Constants.SKIN_DIAMETER;
			
			// Limit content to 2048x2048
			levelLayoutScale = Math.min(
				Math.min(bbWidth, 2048.0) / bbWidth,
				Math.min(bbHeight, 2048.0) / bbHeight
			);
			
			m_boundingBox = new Rectangle(	levelLayoutScale * (minX - Constants.SKIN_DIAMETER * .5), 
											levelLayoutScale * (minY - Constants.SKIN_DIAMETER * .5),
											levelLayoutScale * (maxX - minX + Constants.SKIN_DIAMETER),
											levelLayoutScale * (maxY - minY + Constants.SKIN_DIAMETER)	);
			
			m_groupGrids = new Vector.<GroupGrid>();
			const MAX_GROUP_DEPTH:int = levelGraph.groupsArr.length;
			for (var groupDepth:int = 0; groupDepth <= MAX_GROUP_DEPTH; groupDepth++)
			{
				var nodeDict:Object,
					groupSize:uint;
				if (groupDepth == 0) {
					nodeDict = m_levelLayoutObj["layout"]["vars"];
					groupSize = levelGraph.nVars + levelGraph.nClauses;
				} else {
					nodeDict = levelGraph.groupsArr[groupDepth - 1];
					groupSize = levelGraph.groupSizes[groupDepth - 1];
				}
				var groupGrid:GroupGrid = new GroupGrid(m_boundingBox, levelLayoutScale, nodeDict, m_levelLayoutObj["layout"]["vars"], groupSize);
				m_groupGrids.push(groupGrid);
			}
			
			for (var varId:String in m_levelLayoutObj["layout"]["vars"])
			{
				var nodeLayout:Object = m_levelLayoutObj["layout"]["vars"][varId];
				gridChild = createGridChildFromLayoutObj(varId, nodeLayout, false);
				if (gridChild == null) continue;
				m_numNodes++;
			}
			//quick fix to make large level actually playable
			if(m_numNodes > 50000)
				PipeJam3.SELECTION_STYLE = PipeJam3.SELECTION_STYLE_CLASSIC;
			else
				PipeJam3.SELECTION_STYLE = PipeJam3.SELECTION_STYLE_VAR_BY_VAR_AND_CNSTR;
			
			//trace("node count = " + n);
			
			// Process layout edges (constraints)
			var visibleLines:int = 0;
			m_numNodes = 0;
			
			for (var constraintId:String in levelGraph.constraintsDict)
			{
				var result:Object = constraintId.split(" ");
				if (result == null) throw new Error("Invalid constraint layout string found: " + constraintId);
				if (result.length != 3) throw new Error("Invalid constraint layout string found: " + constraintId);
				var graphConstraint:Constraint = levelGraph.constraintsDict[constraintId] as Constraint;
				if (graphConstraint == null) throw new Error("No graph constraint found for constraint layout: " + constraintId);
				var startNode:Node = nodeLayoutObjs[result[0]];
				var endNode:Node = nodeLayoutObjs[result[2]];
				//switch end points if needed)
				if(result[0].indexOf('c') != -1)
				{
					startNode = nodeLayoutObjs[result[2]];
					endNode = nodeLayoutObjs[result[0]];
				}
				var edge:Edge = new Edge(constraintId, graphConstraint,startNode, endNode);
				startNode.connectedEdgeIds.push(constraintId);
				startNode.outgoingEdgeIds.push(constraintId);
				endNode.connectedEdgeIds.push(constraintId);
				edgeLayoutObjs[constraintId] = edge;
				
				m_numNodes++;
			}
			if (PipeJam3.ASSET_SUFFIX == "Turk")
			{
				m_targetScore = 0;
				for (var key:String in nodeLayoutObjs)
				{
					if (nodeLayoutObjs[key] is ClauseNode) m_targetScore++;
				}
			}
		}
		
		public function initialize():void
		{
			// create all nodes, edges for tutorials so that the tutorial indicators/arrows have something to point at
			if (initialized) return;
			
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
			
			m_levelStartTime = new Date().time;
			
			levelGraph.resetScoring();
			m_bestScore = levelGraph.currentScore;
			levelGraph.startingScore = levelGraph.currentScore;
			dispatchEvent(new MenuEvent(MenuEvent.LEVEL_LOADED));			
			if (tutorialManager) tutorialManager.startLevel();
			initialized = true;
			
	//		flatten();
			

		}
		
		public function zipJsonFile(jsonFile:Object, name:String):ByteArray
		{
			var newZip:FZip = new FZip();
			var zipByteArray:ByteArray = new ByteArray();
			zipByteArray.writeUTFBytes(JSON.stringify(jsonFile));
			newZip.addFile(name,  zipByteArray);
			var byteArray:ByteArray = new ByteArray;
			newZip.serialize(byteArray);
			return byteArray;
		}
		
		public function encodeBytes(bytes:ByteArray):String
		{
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encodeBytes(bytes);
			var encodedString:String = encoder.toString();

			return encodedString;
		}
		
		public function updateLevelObj():void
		{
			updateAssignmentsObj();
		}
		
		protected function onRemovedFromStage(event:starling.events.Event):void
		{
			removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
			addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage); 
			removeEventListener(starling.events.Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			//disposeChildren();
		}
		
		//update current constraint info based on node constraints
		public function updateAssignmentsObj():void
		{
			m_levelAssignmentsObj = createAssignmentsObj();
		}
		
		protected function createAssignmentsObj():Object
		{
			var hashSize:int = 0;
			var nodeId:String;
			for (nodeId in nodeLayoutObjs) hashSize++;
			
			PipeJamGame.levelInfo.hash = new Array();
			
			var assignmentsObj:Object = { "id": original_level_name, 
									"hash": [], 
									"target_score": this.m_targetScore,
									"starting_score": this.levelGraph.currentScore,
		//							"starting_jams": this.m_levelConflictEdges.length,
									"assignments": { } };
			var count:int = 0;
			var numWide:int = 0;
			for (nodeId in nodeLayoutObjs) {
				if (nodeId.substr(0, 1) == "c") continue;
				var constraintVar:ConstraintVar = levelGraph.variableDict[nodeId];
				if (!assignmentsObj["assignments"].hasOwnProperty(constraintVar.formattedId)) assignmentsObj["assignments"][constraintVar.formattedId] = { };
				assignmentsObj["assignments"][constraintVar.formattedId][ConstraintGraph.TYPE_VALUE] = constraintVar.getValue().verboseStrVal;
				
				var isWide:Boolean = (constraintVar.getValue().verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
				if(isWide)
					numWide++;
				
				count++;
				
				if(count == hashSize)
				{
					count = 0;
					//store both in the file and externally
					assignmentsObj["hash"].push(numWide);
					PipeJamGame.levelInfo.hash.push(numWide);
					numWide = 0;
				}
			}
			return assignmentsObj;
		}
		
		override public function dispose():void
		{
			initialized = false;
			//trace("Disposed of : " + m_levelLayoutObj["id"]);
			
			if (tutorialManager) tutorialManager.endLevel();
			
			nodeLayoutObjs = new Dictionary();
			// TODO groups - dispose layers
			disposeChildren();
			
			removeEventListener(VarChangeEvent.VAR_CHANGE_USER, onWidgetChange);
			removeEventListener(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, onPropertyModeChange);
			removeEventListener(SelectionEvent.COMPONENT_SELECTED, onComponentSelection);
			removeEventListener(SelectionEvent.COMPONENT_UNSELECTED, onComponentSelection);
			if (levelGraph) levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
			if (levelGraph) levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
			super.dispose();		
		}
		

		
		//assume this only generates on toggle width events
		public function onWidgetChange(evt:VarChangeEvent = null, reportScore:Boolean = false):void
		{
			//trace("Level: onWidgetChange");
			if (evt && evt.graphVar) {
				levelGraph.updateScore(evt.graphVar.id, evt.prop, evt.newValue);
				//evt.graphVar.setProp(evt.prop, evt.newValue);
				if (tutorialManager) tutorialManager.onWidgetChange(evt.graphVar.id, evt.prop, evt.newValue, levelGraph);
				dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, evt.graphVar, evt.prop, evt.newValue, this, evt.pt));
				dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
			} else {
				levelGraph.updateScore();
				if (tutorialManager) tutorialManager.afterScoreUpdate(levelGraph);
				dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
			}
			onScoreChange(reportScore);
		}
		
		protected var m_propertyMode:String = PropDictionary.PROP_NARROW;
		public function onPropertyModeChange(evt:PropertyModeChangeEvent):void
		{
			if (evt.prop != PropDictionary.PROP_NARROW)
			{
				throw new Error("Unsupported property: " + evt.prop);
			}
		}
		
		protected function refreshTroublePoints():void
		{
	//		for (var edgeId:String in m_gameEdgeDict) {
	//			var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
	//			gameEdge.refreshConflicts();
	//		}
		}
		
		//data object should be in final selected/unselected state
		protected function componentSelectionChanged(component:Object, selected:Boolean):void
		{
			
		}
		
		protected function onComponentSelection(evt:SelectionEvent):void
		{
			var component:Object = evt.component;
			if(component != null)
				componentSelectionChanged(component, true);
			
			var selectionChangedComponents:Vector.<Object> = new Vector.<Object>();
			selectionChangedComponents.push(component);
		}
		
		protected function onComponentUnselection(evt:SelectionEvent):void
		{
			var component:Object = evt.component;
			if(component != null)
				componentSelectionChanged(component, false);
			
			var selectionChangedComponents:Vector.<Object> = new Vector.<Object>();
			selectionChangedComponents.push(component);
		}
		
		public function selectSurroundingNodes(node:Node, nextToVisitArray:Array, previouslyCheckedNodes:Dictionary):void
		{
			if (!node.isSelected) {
				//trace("select direct " + node.id);
				node.select();
				selectedNodes.push(node);
				m_nodesToDraw[node.id] = node;
			}
			
			for each(var gameEdgeId:String in node.connectedEdgeIds)
			{
				var edge:Edge = edgeLayoutObjs[gameEdgeId];
				var toNode:Node = edge.toNode;
				var fromNode:Node = edge.fromNode;
				
				var otherNode:Node = toNode;
				if(toNode == node)
					otherNode = fromNode;
				if(!otherNode.isSelected)
				{
					if(previouslyCheckedNodes[otherNode.id] == null)
					{
						nextToVisitArray.push(otherNode);
						previouslyCheckedNodes[otherNode.id] = otherNode;
					}
				}
			}
		}
		
		protected function onErrorAdded(evt:ErrorEvent):void
		{
			for (var errorEdgeId:String in evt.constraintChangeDict) // new conflicts
			{
				var clauseConstraint:ConstraintEdge = evt.constraintChangeDict[errorEdgeId] as ConstraintEdge;
				if(clauseConstraint != null)
				{
					var clauseNode:ClauseNode;
					if(clauseConstraint.lhs.id.indexOf('c') != -1)
					{
						clauseNode = nodeLayoutObjs[clauseConstraint.lhs.id];
					}
					else if(clauseConstraint.rhs.id.indexOf('c') != -1)
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
		
		protected function onErrorRemoved(evt:ErrorEvent):void
		{
			for (var errorEdgeId:String in evt.constraintChangeDict) // solved clauses
			{
				var clauseConstraint:ConstraintEdge = evt.constraintChangeDict[errorEdgeId] as ConstraintEdge;
				if(clauseConstraint != null)
				{
					var clauseNode:ClauseNode;
					if(clauseConstraint.lhs.id.indexOf('c') != -1)
					{
						clauseNode = nodeLayoutObjs[clauseConstraint.lhs.id];
					}
					else if(clauseConstraint.rhs.id.indexOf('c') != -1)
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
		
		protected static function getVisible(_layoutObj:Object, _defaultValue:Boolean = true):Boolean
		{
			var value:String = _layoutObj["visible"];
			if (!value) return _defaultValue;
			return XString.stringToBool(value);
		}

		public function getNodes():Dictionary
		{
			return nodeLayoutObjs;
		}
		
		public function getLevelTextInfo():TutorialManagerTextInfo
		{
			return tutorialManager ? tutorialManager.getTextInfo() : null;
		}
		
		public function getLevelToolTipsInfo():Vector.<TutorialManagerTextInfo>
		{
			return tutorialManager ? tutorialManager.getPersistentToolTipsInfo() : (new Vector.<TutorialManagerTextInfo>());
		}
		
		public function getMaxSelectableWidgets():int
		{
			if (tutorialManager != null)
			{
				return tutorialManager.getMaxSelectableWidgets();
			}
			else
			{
				if (PipeJam3.ASSET_SUFFIX == "Turk")
					return 500;
				if (PipeJam3.SELECTION_STYLE != PipeJam3.SELECTION_STYLE_CLASSIC)
				{
					switch(PlayerValidation.currentActivityLevel)
					{
						case 2: return 250;
						case 3: return 500;
						default: return 100;
					}
				}
				else
				{
					return 1000;
				}
			}
		}
		
		public function getTargetScore():int
		{
			return m_targetScore;
		}
		

		public function setTargetScore(score:int):void
		{
			m_targetScore = score;
		}
			
		public function getTimeMs():Number
		{
			return new Date().time - m_levelStartTime;
		}
		
		public function hideErrorText():void
		{
//			if (!m_hidingErrorText) {
//				for (var edgeId:String in m_gameEdgeDict) {
//					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
//					gameEdge.hideErrorText();
//				}
//				m_hidingErrorText = true;
//			}
		}
		
		public function showErrorText():void
		{
//			if (m_hidingErrorText) {
//				for (var edgeId:String in m_gameEdgeDict) {
//					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
//					gameEdge.showErrorText();
//				}
//				m_hidingErrorText = false;
//			}
		}
		
		public override function unflatten():void
		{
			super.unflatten();
		}
		
		public function getPanZoomAllowed():Boolean
		{ 
			if (tutorialManager != null) return tutorialManager.getPanZoomAllowed();
			return true;
		}
		
		public function getVisibleBrushes():int
		{ 
			if (tutorialManager != null) 
				return tutorialManager.getVisibleBrushes();
			//all visible
			return 0xFFFFFF;
		}
		
		public function getAutoSolveAllowed():Boolean
		{ 
			if (tutorialManager != null) return tutorialManager.getAutoSolveAllowed();
			return true;
		}
		
		public static const SEGMENT_DELETION_ENABLED:Boolean = false;
		public function onDeletePressed():void
		{

		}
		
		
		public function get currentScore():int { return levelGraph.currentScore; }
		public function get bestScore():int { return m_bestScore; }
		public function get maxScore():int { return MiniMap.maxNumConflicts; }
		public function get startingScore():int { return levelGraph.startingScore; }
		public function get prevScore():int { return levelGraph.prevScore; }
		public function get oldScore():int { return levelGraph.oldScore; }
		
		public function resetBestScore():void
		{
			m_bestScore = levelGraph.currentScore;
			m_levelBestScoreAssignmentsObj = XObject.clone(m_levelAssignmentsObj);
		}
		
		public function onScoreChange(recordBestScore:Boolean = false):void
		{
			if (recordBestScore && (levelGraph.currentScore > m_bestScore)) {
				m_bestScore = levelGraph.currentScore;
				//trace("New best score: " + m_bestScore);
				m_levelBestScoreAssignmentsObj = createAssignmentsObj();
				//don't update on loading
				if(levelGraph.oldScore != 0  && (PlayerValidation.accessGranted() || (PipeJam3.ASSET_SUFFIX == "Turk")))
					dispatchEvent(new MenuEvent(MenuEvent.SAVE_LEVEL));
			}
			//if (levelGraph.prevScore != levelGraph.currentScore)
			dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
		}
		
		public function unselectAll():void
		{
			for each(var node:Node in selectedNodes)
			{
				node.animating = false;
				node.unselect();
				if (node.skin != null)
				{
					m_nodesToDraw[node.id] = node;
				}
			}
			selectedNodes = new Vector.<Node>();
			dispatchEvent(new SelectionEvent(SelectionEvent.NUM_SELECTED_NODES_CHANGED, null, null));
		}
		
		public function onUseSelectionPressed(choice:String):void
		{
			//save selection for undo
			nodeIDToConstraintsTwoWayMap = new Dictionary;
			var count:int = 1;
			var newAssignmentValue:int;
			m_previousVarValues = new Array;
			m_lastVarValues = new Array;
			var assignmentIsWide:Boolean = false;
			if(choice == MenuEvent.MAKE_SELECTION_WIDE)
			{
				assignmentIsWide = true;
				newAssignmentValue = 1;
			}
			else if(choice == MenuEvent.MAKE_SELECTION_NARROW)
			{
				assignmentIsWide = false;
				newAssignmentValue = 1;
			}
			var selectedVarIds:String = "";
			for each(var node:Node in selectedNodes)
			{
				node.solved = true;
				node.animating = false;
				node.unselect();
				if (!node.isClause)
				{
					nodeIDToConstraintsTwoWayMap[count] = node;
					count++;
					if(node.isNarrow)
						m_previousVarValues.push(0);
					else
						m_previousVarValues.push(1);
					m_lastVarValues.push(newAssignmentValue);
					node.updateSelectionAssignment(assignmentIsWide, levelGraph);
					m_nodesToDraw[node.id] = node;
					if (PipeJam3.logging)
					{
						var simpleId:String = node.id;
						var idArr:Array = node.id.split("var_");
						if (idArr.length == 2) simpleId = idArr[1] as String;
						selectedVarIds += (selectedVarIds.length == 0) ? simpleId : ("," + simpleId);
					}
				}
			}
			//update score
			onWidgetChange(null, true);
			if (PipeJam3.logging && selectedNodes.length > 0)
			{
				var details:Object = new Object();
				details[VerigameServerConstants.ACTION_PARAMETER_VAR_IDS] = selectedVarIds;
				details[VerigameServerConstants.ACTION_PARAMETER_TYPE] = m_solverType;
				details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = original_level_name; // yes, we can get this from the quest data but include it here for convenience
				details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = currentScore;
				details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = m_targetScore;
				PipeJam3.logging.logQuestAction(assignmentIsWide ? VerigameServerConstants.VERIGAME_ACTION_PAINT_WIDE : VerigameServerConstants.VERIGAME_ACTION_PAINT_NARROW, details, getTimeMs());
			}
			unselectAll();
		}
		
		public function getEdgeContainer(edgeId:String):DisplayObject
		{
			var edge:Edge = edgeLayoutObjs[edgeId];
			return edge ? edge.skin : null;
		}
		
		public function getNode(nodeId:String):Node
		{
			var node:Node = nodeLayoutObjs[nodeId];
			return node;
		}
		
		protected var solverRunningTime:Number;
		public function solverTimerCallback(evt:TimerEvent):void
		{
			solveSelection(solverUpdate, solverDone);
		}
		
		public function solverLoopTimerCallback(evt:TimerEvent):void
		{
			for each(var node:Node in nodeLayoutObjs)
			{
				node.unused = true;
			}
			solveSelection(solverUpdate, solverDone);
		}

		//used when ctrl-shift clicking a node, selects x whole group or nearest neighbors if no group
		protected var currentSelectionProcessCount:int;
		public var NUM_NODES_TO_SELECT:int = 20;

		protected function onGroupSelection(evt:SelectionEvent):void
		{
			if (evt.component is Node) {
				var node:Node = evt.component as Node;
				currentSelectionProcessCount = 1;
				var nextToVisitArray:Array = new Array;
				var previouslyCheckedNodes:Dictionary = new Dictionary;
				selectSurroundingNodes(node, nextToVisitArray, previouslyCheckedNodes);
				for each(var nextNode:Node in nextToVisitArray)
				{
					selectSurroundingNodes(nextNode, nextToVisitArray, previouslyCheckedNodes);
					if(currentSelectionProcessCount > NUM_NODES_TO_SELECT)
						break;
					currentSelectionProcessCount++;
				}
			}
		}

		public var loopcount:int = 0;
		public var looptimer:Timer;
		public var runContinualSolver:Boolean = true;
		//this is a test robot. It will find a conflict, select neighboring nodes, solve that area, and repeat
		public function solveSelection(updateCallback:Function, doneCallback:Function, firstRun:Boolean = false):void
		{
			if(firstRun)
			{
				solverRunningTime = new Date().getTime();
			}
			//if caps lock is down, start repeated solving using 'random' selection
			if(runContinualSolver)
			{
				//loop through all nodes, finding ones with conflicts
				for each(var node:Node in nodeLayoutObjs)
				{
					if(node is ClauseNode)
					{
						var clauseNode:ClauseNode = node as ClauseNode;
						if(clauseNode.hasError() && node.unused)
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
		

	
		public var updateCallback:Function;
		public var doneCallback:Function;
		private var constraintArray:Array;
		private var initvarsArray:Array;
		private var newSelectedVars:Vector.<Node>;
		private var newSelectedClauses:Dictionary;
		private var storedDirectEdgesDict:Dictionary;
		private var directNodeDict:Dictionary;
		private var counter:int;
		private var m_solverType:int;
		private var selectedConstraintValue:int;
		public var startingSelectedNodeCount:int;
		public function solveSelection1(_updateCallback:Function, _doneCallback:Function, brushType:String):void
		{
			//figure out which edges have both start and end components selected (all included edges have both ends selected?)
			//assign connected components to component to edge constraint number dict
			//create three constraints for conflicts and weights
			//run the solver, passing in the callback function		
			updateCallback = _updateCallback;
			doneCallback = _doneCallback;
			startingSelectedNodeCount = selectedNodes.length;
			selectedConstraintValue = 0;
			m_solverType = 1;
			if(brushType != GridViewPanel.SOLVER1_BRUSH)
				m_solverType = 2;
			
			nodeIDToConstraintsTwoWayMap = new Dictionary;
			var storedConstraints:Dictionary = new Dictionary;
			counter = 1;
			constraintArray = new Array;
			initvarsArray = new Array;
			directNodeDict = new Dictionary;
			storedDirectEdgesDict = new Dictionary;
			m_unsat_weight = int.MAX_VALUE;

			newSelectedVars = new Vector.<Node>;
			newSelectedClauses = new Dictionary;
			m_inSolver = true;
			
			if (PipeJam3.logging)
			{
				var details:Object = new Object();
				var selectedVarIds:String = "";
				for each(var node:Node in selectedNodes)
				{
					if (node.isClause) continue;
					var simpleId:String = node.id;
					var idArr:Array = node.id.split("var_");
					if (idArr.length == 2) simpleId = idArr[1] as String;
					selectedVarIds += (selectedVarIds.length == 0) ? simpleId : ("," + simpleId);
				}
				details[VerigameServerConstants.ACTION_PARAMETER_VAR_IDS] = selectedVarIds;
				details[VerigameServerConstants.ACTION_PARAMETER_TYPE] = m_solverType;
				details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = original_level_name; // yes, we can get this from the quest data but include it here for convenience
				details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = currentScore;
				details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = m_targetScore;
				PipeJam3.logging.logQuestAction(VerigameServerConstants.VERIGAME_ACTION_PAINT_AUTOSOLVE, details, getTimeMs());
			}
			
			if (PipeJam3.SELECTION_STYLE != PipeJam3.SELECTION_STYLE_CLASSIC) {
				createConstraintsBasedOnVariables();
			} else {
				createConstraintsForClauses();

				findIsolatedSelectedVars(); //handle one-offs so something gets done in minimal cases
			
				if(extendSolver)
					fixEdgeVarValues(); //find nodes just off selection map, and fix their values so they don't change
			}

			if(constraintArray.length > 0)
			{
				//generate initvars array
				for(var ii:int = 1;ii<counter;ii++)
				{
					var gameNode:VariableNode = nodeIDToConstraintsTwoWayMap[ii];
					if(gameNode.isNarrow)
						initvarsArray.push(0);
					else
						initvarsArray.push(1);
				}

				//build in a delay to allow UI to change
				World.m_world.showSolverState(true);
				timer = new Timer(500,1);
				timer.addEventListener(TimerEvent.TIMER, solverStartCallback);
				timer.start();
			}
			else //just end
			{
				doneCallback("");
			}
		}

		private function createConstraintsBasedOnVariables():void
		{
			var node:Node, edge:Edge, toNode:Node, fromNode:Node;
			
			// start variable nodes animating
			for each(node in selectedNodes)
			{
				if (node.isClause) {
					continue;
				}
				
				node.animating = true;
				m_solvingNodesToAnimate[node.id] = node;
			}
			
			// find all the possibly relevant clauses
			var selectedNodesDict:Dictionary = new Dictionary;
			var connectedClausesDict:Dictionary = new Dictionary;
			var gameEdgeId:String;
			for each(node in selectedNodes)
			{
				if (node.isClause) {
					continue;
				}
				
				// remember that this node was selected
				selectedNodesDict[node.id] = node;
				
				// remember all the clauses connected to this node
				for each(gameEdgeId in node.connectedEdgeIds)
				{
					edge = edgeLayoutObjs[gameEdgeId];
					toNode = edge.toNode;
					
					connectedClausesDict[toNode.id] = toNode;
				}
			}
			
			// now go through all those clauses
			for each (node in connectedClausesDict)
			{
				// check if this clause is satisfied by some variable that is not being optimized
				var clauseConstSat:Boolean = false;
				for each(gameEdgeId in node.connectedEdgeIds)
				{
					edge = edgeLayoutObjs[gameEdgeId];
					fromNode = edge.fromNode;
				
					// is this variable a constant?
					if (selectedNodesDict[fromNode.id] == null)
					{
						// does it satisfy the clause?
						var wantValue:Boolean = (gameEdgeId.indexOf('c') == 0);
						var hasValue:Boolean = (!nodeLayoutObjs[edge.fromNode.id].isNarrow);
						if (wantValue == hasValue)
						{
							clauseConstSat = true;
						}
					}
				}
				
				// this clause is always satisfied so we don't need to optimize it
				if (clauseConstSat) {
					continue;
				}
				
				
				// now make the clause array
				var clauseArray:Array = new Array();
				clauseArray.push(CONFLICT_CONSTRAINT_VALUE);
				selectedConstraintValue += CONFLICT_CONSTRAINT_VALUE;

				// find all variables connected to the constraint, and add them to the array
				for each(gameEdgeId in node.connectedEdgeIds)
				{
					edge = edgeLayoutObjs[gameEdgeId];
					fromNode = edge.fromNode;
					
					// is this variable a constant?
					if (selectedNodesDict[fromNode.id] == null)
					{
						// then skip
						continue;
					}

					// get the solver id for this variable
					var constraintID:int;
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
					if(gameEdgeId.indexOf('c') == 0)
						clauseArray.push(constraintID);
					else
						clauseArray.push(-constraintID);
					
				}
				
				constraintArray.push(clauseArray);
			}
		}	
				

		private function createConstraintsForClauses():void
		{
			for each(var node:Node in selectedNodes)
			{
				if(debugSolver)
				{
					node.solverSelected = true;
					node.solverSelectedColor = 0xff00ff;
					solverSelected.push(node);
				}
				if(node.isClause)
				{
					newSelectedClauses[node.id] = node;
					var clauseArray:Array = new Array();
					clauseArray.push(CONFLICT_CONSTRAINT_VALUE);
					selectedConstraintValue += CONFLICT_CONSTRAINT_VALUE;
					//find all variables connected to the constraint, and add them to the array
					for each(var gameEdgeId:String in node.connectedEdgeIds)
					{
						var edge:Edge = edgeLayoutObjs[gameEdgeId];
						var fromNode:Node = edge.fromNode;
						
						storedDirectEdgesDict[gameEdgeId] = edge;
						
						var constraintID:int;
						if(nodeIDToConstraintsTwoWayMap[fromNode.id] == null)
						{
							nodeIDToConstraintsTwoWayMap[fromNode.id] = counter;
							nodeIDToConstraintsTwoWayMap[counter] = fromNode;
							constraintID = counter;
							counter++;
						}
						else
							constraintID = nodeIDToConstraintsTwoWayMap[fromNode.id];
						
						//if the constraint starts from the clause, it's a positive var, else it's negative.
						if(gameEdgeId.indexOf('c') == 0)
							clauseArray.push(constraintID);
						else
							clauseArray.push(-constraintID);
						
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
		
		private function findIsolatedSelectedVars():void
		{
			//check for variables that have no selected attached clauses. If found, create a clause for each attached constraint
			//and clauses for the far ends to suggest they don't change
			for each(var selectedVar:Node in newSelectedVars)
			{
				var attachedSelected:Boolean = false;
				
				for each(var edgeID:String in selectedVar.connectedEdgeIds)
				{
					var edgeToCheck:Edge = edgeLayoutObjs[edgeID];
					var toNodeToCheck:Node = edgeToCheck.toNode;
					if(newSelectedClauses[toNodeToCheck.id])
					{
						attachedSelected = true;
						continue;
					}
				}
				
				if(attachedSelected == false)
				{
					for each(var unattachedEdgeID:String in selectedVar.connectedEdgeIds)
					{
						var unattachedEdge:Edge = edgeLayoutObjs[unattachedEdgeID];
						var toClause:ClauseNode = unattachedEdge.toNode as ClauseNode;
						
						if(debugSolver)
						{
							toClause.solverSelected = true;
							toClause.solverSelectedColor = 0x00ffff;
							solverSelected.push(toClause);
						}
						
						var clauseArray:Array = new Array();
						clauseArray.push(CONFLICT_CONSTRAINT_VALUE);
						selectedConstraintValue += CONFLICT_CONSTRAINT_VALUE;
						for each(var gameEdgeId:String in toClause.connectedEdgeIds)
						{
							var constraintEdge:Edge = edgeLayoutObjs[gameEdgeId];
							var fromNode:Node = constraintEdge.fromNode;
							//directNodeArray.push(fromNode1);
							//directEdgeDict[gameEdgeId1] = edge3;
							
							var constraintID:int;
							if(nodeIDToConstraintsTwoWayMap[fromNode.id] == null)
							{
								nodeIDToConstraintsTwoWayMap[fromNode.id] = counter;
								nodeIDToConstraintsTwoWayMap[counter] = fromNode;
								constraintID = counter;
								counter++;
							}
							else
								constraintID = nodeIDToConstraintsTwoWayMap[fromNode.id];
							
							//if the constraint starts from the clause, it's a positive var, else it's negative.
							if(gameEdgeId.indexOf('c') == 0)
								clauseArray.push(constraintID);
							else
								clauseArray.push(-constraintID);
							
							if(fromNode != selectedVar)
							{
								//create a separate clause here for this one node, based on it's current size
								var nodeClauseArray:Array = new Array();
								nodeClauseArray.push(CONFLICT_CONSTRAINT_VALUE);
								selectedConstraintValue += CONFLICT_CONSTRAINT_VALUE;
								
								if(fromNode.isNarrow)
									nodeClauseArray.push(-constraintID);
								else
									nodeClauseArray.push(constraintID);
								constraintArray.push(nodeClauseArray);
							}	
						}
						constraintArray.push(clauseArray);
					}
				}
			}
		}
		
		private function fixEdgeVarValues():void
		{
			//now, find all the other constraints associated with the directly connected variables,
			//add the nodes connected to those constraints as fixed values,
			//so the score doesn't go down.
			for each(var directNode:Node in directNodeDict)
			{
				for each(var conEdgeID:String in directNode.connectedEdgeIds)
				{
					//have we already dealt with this edge?
					if(storedDirectEdgesDict[conEdgeID])
						continue;
					
					var conEdge:Edge = edgeLayoutObjs[conEdgeID];
					storedDirectEdgesDict[conEdgeID] = conEdge;
					
					var nextLayerClause:ClauseNode = conEdge.toNode as ClauseNode;
					
					if(nextLayerClause.hasError()) //ignore if I don't care if the value changes
						continue;
					
					if(newSelectedClauses[nextLayerClause.id] == null)
					{
						//add to redraw if needed
						selectedNodes.push(nextLayerClause);
						newSelectedClauses[nextLayerClause.id] = nextLayerClause;					
						
						if(debugSolver)
						{
							nextLayerClause.solverSelected = true;
							nextLayerClause.solverSelectedColor = 0x00ff00;
							solverSelected.push(nextLayerClause);
						}		
								
						var clauseArray:Array = new Array();
						clauseArray.push(CONFLICT_CONSTRAINT_VALUE*2); //multiply just so this is slightly higher value
						selectedConstraintValue += CONFLICT_CONSTRAINT_VALUE*2;
						for each(var edgeID:String in nextLayerClause.connectedEdgeIds)
						{
							//create constraint for clause connected to edge node
							var cEdge:Edge = edgeLayoutObjs[edgeID];						
							var connectedNode:Node = cEdge.fromNode;
							selectedNodes.push(connectedNode);
							var nextLevelConstraintID:int;
							if(nodeIDToConstraintsTwoWayMap[connectedNode.id] == null)
							{
								nodeIDToConstraintsTwoWayMap[connectedNode.id] = counter;
								nodeIDToConstraintsTwoWayMap[counter] = connectedNode;
								nextLevelConstraintID = counter;
								counter++;
							}
							else
								nextLevelConstraintID = nodeIDToConstraintsTwoWayMap[connectedNode.id];
							
							if(edgeID.indexOf('c') == 0)
							//if(connectedNode.isNarrow)
								clauseArray.push(nextLevelConstraintID);
							else
								clauseArray.push(-nextLevelConstraintID);
							
							
							
							if(debugSolver)
							{
								connectedNode.solverSelected = true;
								connectedNode.solverSelectedColor = 0xff0000;
								solverSelected.push(connectedNode);
							}
							
							if(storedDirectEdgesDict[edgeID])
								continue;
							
							var varArray:Array = new Array();
							selectedConstraintValue += FIXED_CONSTRAINT_VALUE;
							varArray.push(FIXED_CONSTRAINT_VALUE); //FIXED value cause we really don't want this to change, it might add conflicts
							//set constraint with current value of connectedNode, not constraint direction
							if(connectedNode.isNarrow)
								varArray.push(-nextLevelConstraintID);
							else
								varArray.push(nextLevelConstraintID);						
							constraintArray.push(varArray);
						}
						constraintArray.push(clauseArray);
					}
				}
			}
		}
		
		public function solverStartCallback(evt:TimerEvent):void
		{
			MaxSatSolver.run_solver(1, constraintArray, initvarsArray, updateCallback, doneCallback);
			dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_STARTED, true));
		}
		
		protected var m_lastVarValues:Array;
		protected var m_previousVarValues:Array;
		public function solverUpdate(vars:Array, unsat_weight:int):void
		{
			trace("update", unsat_weight);
			if(	m_inSolver == false || unsat_weight > m_unsat_weight) //got marked done early
				return;
			m_unsat_weight = unsat_weight;
			m_lastVarValues = vars;
			var percentDone:Number = ((selectedConstraintValue - unsat_weight) / selectedConstraintValue) * 100;
			
			dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_UPDATED, true, percentDone));
		}
		
		protected function updateNodes(undo:Boolean = false):void
		{
			if(!m_lastVarValues)
				return;
			
			m_previousVarValues = new Array;
			var someNodeUpdated:Boolean = false;
			//trace(levelGraph.currentScore);
			var updatedVarIds:String = "";
			var updatedValues:String = "";
			for (var ii:int = 0; ii < m_lastVarValues.length; ++ ii) 
			{
				var node:Node = nodeIDToConstraintsTwoWayMap[ii + 1];
				if(node && !(node is ClauseNode))
				{
					node.solved = true;
					var constraintVar:ConstraintVar = node["graphVar"];
					var currentVal:Boolean = node.isNarrow;
					var currentNumValue:int = (currentVal == true) ? 0 : 1;
					m_previousVarValues.push(currentNumValue);
					
					if(m_lastVarValues[ii] == 1)
						node.isNarrow = false;
					else
						node.isNarrow = true;
					
					someNodeUpdated = someNodeUpdated || (currentVal != node.isNarrow);
					if(currentVal != node.isNarrow)
					{
						if (PipeJam3.logging)
						{
							var simpleId:String = node.id;
							var idArr:Array = node.id.split("var_");
							if (idArr.length == 2) simpleId = idArr[1] as String;
							updatedVarIds += (updatedVarIds.length == 0) ? simpleId : ("," + simpleId);
							updatedValues += (updatedValues.length == 0) ? String(currentNumValue) : ("," + currentNumValue);
						}
						if (node.skin != null)
						{
							m_nodesToDraw[node.id] = node;
						}
						if(constraintVar != null) 
							constraintVar.setProp(PropDictionary.PROP_NARROW, node.isNarrow);
						if (tutorialManager != null) tutorialManager.onWidgetChange(constraintVar.id, PropDictionary.PROP_NARROW, node.isNarrow, levelGraph);
					}
				}
			}
			
			if(someNodeUpdated)
				onWidgetChange();
			
			if (PipeJam3.logging)
			{
				var details:Object = new Object();
				details[VerigameServerConstants.ACTION_PARAMETER_VAR_IDS] = updatedVarIds;
				details[VerigameServerConstants.ACTION_PARAMETER_VAR_VALUES] = updatedValues;
				details[VerigameServerConstants.ACTION_PARAMETER_LEVEL_NAME] = original_level_name; // yes, we can get this from the quest data but include it here for convenience
				details[VerigameServerConstants.ACTION_PARAMETER_SCORE] = currentScore;
				details[VerigameServerConstants.ACTION_PARAMETER_TARGET_SCORE] = m_targetScore;
				PipeJam3.logging.logQuestAction(undo ? VerigameServerConstants.VERIGAME_ACTION_UNDO : VerigameServerConstants.VERIGAME_ACTION_AUTOSOLVE_COMPLETE, details, getTimeMs());
			}
		}
		
		public var solverRunCount:int = 0;
		public var timer:Timer;
		
		public function solverDone(errMsg:String):void
		{
			//trace("solver done " + errMsg);
			unselectAll();
			updateNodes();
			
			MaxSatSolver.stop_solver();
			levelGraph.updateScore();
			onScoreChange(true);
			drawNodesAfterSolving();
			System.gc();
			var scoreWentDown:Boolean = true;
			if(levelGraph.oldScore <= levelGraph.currentScore)
				scoreWentDown = false;
			//do this twice, once to reset solver color, again after setting inSolver to false to reset selection color
			dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_STOPPED, true, scoreWentDown));
			m_inSolver = false;
			dispatchEvent(new starling.events.Event(MaxSatSolver.SOLVER_STOPPED, true));
			
			if(runContinualSolver && solverRunCount < 250)
			{
				solverRunCount++;
				//trace("count", count);
				timer = new Timer(1000, 1);
				timer.addEventListener(TimerEvent.TIMER, solverTimerCallback);
				timer.start();
			}

		}
		
		//draw nodes in a different color to indicate solver is done
		public function drawNodesAfterSolving():void
		{
			m_recentlySolved = true;
			for each(var node:Node in selectedNodes)
			{
				node.solved = true;
				node.unselect();
				if (node.isClause) continue;
				node.animating = false;
				if (node.skin)
				{
					Starling.juggler.removeTweens(node.skin);
					m_nodesToDraw[node.id] = node;
				}
			}
		}
		
		public function onViewSpaceChanged(event:MiniMapEvent):void
		{
			
		}
		
		public function selectNodes(localPt:Point, dX:Number, dY:Number):void
		{
			if (currentGroupDepth < 0) currentGroupDepth = 0;
			var groupGrid:GroupGrid = m_groupGrids[currentGroupDepth];
			const GRID_DIM:Point = groupGrid.gridDimensions.clone();
			const MAX_SEL:int = getMaxSelectableWidgets();
			const RAD_SQUARED:Number = dX * dX;
			
			var leftGridNumber:int = GroupGrid.getGridX(localPt.x - dX, GRID_DIM);
			var rightGridNumber:int = GroupGrid.getGridX(localPt.x + dX, GRID_DIM);
			var topGridNumber:int = GroupGrid.getGridX(localPt.y - dY, GRID_DIM);
			var bottomGridNumber:int = GroupGrid.getGridX(localPt.y + dY, GRID_DIM);
			var selectionChanged:Boolean = false;
			//trace("localPt: ", localPt, " dX/Y: ", dX);
			for (var i:int = leftGridNumber; i <= rightGridNumber; i++)
			{
				for(var j:int = topGridNumber; j <= bottomGridNumber; j++)
				{
					var gridName:String = i + "_" + j;
					if (!groupGrid.grid.hasOwnProperty(gridName)) continue; // no nodes in this grid
					var gridNodeDict:Dictionary = groupGrid.grid[gridName] as Dictionary;
					for (var nodeId:String in gridNodeDict)
					{
						var node:Node = nodeLayoutObjs[nodeId] as Node;
						if (node == null)
						{
							trace("WARNING! Node id not found: " + nodeId);
							continue;
						}
						
						// early out if we're not going to select clause nodes
						if (PipeJam3.SELECTION_STYLE == PipeJam3.SELECTION_STYLE_VAR_BY_VAR && node.isClause) {
							continue;
						}
						
						var diffX:Number = localPt.x - node.centerPoint.x;
						//trace("node.centerPoint: ", node.centerPoint);
						if (diffX > dX || -diffX > dX) continue;
						var diffY:Number = localPt.y - node.centerPoint.y;
						if (diffY > dY || -diffY > dY) continue;
						var diffXSq:Number = diffX * diffX;
						var diffYSq:Number = diffY * diffY;
						if (diffXSq + diffYSq <= RAD_SQUARED && !node.isSelected) {
							if (false) { // use this branch for actively unselecting when max is reached 
								while (selectedNodes.length >= MAX_SEL) {
									var unselNode:Node = selectedNodes.shift();
									unselNode.animating = false;
									unselNode.unselect();
								}
							} else if (selectedNodes.length >= MAX_SEL) {
								break; // done selecting
							}
							
							if (PipeJam3.SELECTION_STYLE == PipeJam3.SELECTION_STYLE_CLASSIC || !node.isClause) {
								if (!node.isSelected) {
									//trace("select direct " + node.id);
									node.select();
									selectedNodes.push(node);
									m_nodesToDraw[node.id] = node;
									selectionChanged = true;
								}
							}
							
							//select attached nodes?
							if(node is ClauseNode)
							{
								for each(var edgeID:String in node.connectedEdgeIds)
								{
									var edge:Edge = this.edgeLayoutObjs[edgeID];
									var connectedNode:Node = edge.fromNode;
									if(!connectedNode.isSelected && connectedNode.id in m_nodeOnScreenDict)
									{
										//trace("select connect " + connectedNode.id);
										connectedNode.select();
										selectedNodes.push(connectedNode);
										m_nodesToDraw[connectedNode.id] = connectedNode;
										selectionChanged = true;
									}
									if (selectedNodes.length >= MAX_SEL) break;
								}
							}
						}
					}
					if (selectedNodes.length >= MAX_SEL) break;
				}
			}
			//trace("Paint select changed:" + selectionChanged);
			if (selectionChanged) {
				dispatchEvent(new SelectionEvent(SelectionEvent.NUM_SELECTED_NODES_CHANGED, null, null));
			}
		}
		
		public function unselectLast():void
		{
			if(debugSolver && selectedNodes.length == 0)
			{
				//reset flashing on previously solved nodes
				if(solverSelected)
					for each(var node:Node in solverSelected)
						node.solverSelected = false;
					
				solverSelected = new Vector.<Node>;
			}
			
		}
		
		public function emphasizeBrushes():int
		{
			if (tutorialManager) return tutorialManager.emphasizeBrushes();
			return 0x0;
		}
		
		private static function popNode(d:Dictionary):Node
		{
			for (var id:String in d)
			{
				var node:Node = d[id] as Node;
				delete d[id];
				return node;
			}
			return null;
		}
		
		public function undo():void
		{
			//switch last with previous settings, and then update from Last
			var temp:Array = m_lastVarValues;
			m_lastVarValues = m_previousVarValues;
			m_previousVarValues = temp;
			updateNodes(true);
		}
	}
	
}


import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

internal class GroupGrid
{
	private static const NODE_PER_GRID_ESTIMATE:uint = 300;
	
	public var grid:Dictionary = new Dictionary();
	public var gridDimensions:Point = new Point(); // in pixels
	
	public function GroupGrid(m_boundingBox:Rectangle, levelScale:Number, nodeDict:Object, layoutDict:Object, nodeSize:uint)
	{
		// Note: this assumes a uniform distribution of nodes, which is not a good estimate, but it will do for now
		var gridsTotal:int = Math.ceil(nodeSize / NODE_PER_GRID_ESTIMATE);
		// use right, bottom instead of width, height to ignore (presumably) negligible x or y value that would need to be subtracted from each node.x,y
		var totalDim:Number = 2048;//Math.max(1, m_boundingBox.right + m_boundingBox.bottom);
		var gridsWide:int = Math.ceil(gridsTotal * m_boundingBox.right / totalDim);
		var gridsHigh:int = Math.ceil(gridsTotal * m_boundingBox.bottom / totalDim);
		gridDimensions = new Point(m_boundingBox.right / gridsWide, m_boundingBox.bottom / gridsHigh);
		
		// Put all node ids in the grid
		var nodeKey:String;
		for (nodeKey in nodeDict)
		{
			nodeKey = nodeKey.replace("clause:", "c_").replace(":", "_");
			if (!layoutDict.hasOwnProperty(nodeKey))
			{
				trace("Warning! Node id from group dict not found: ", nodeKey);
				continue;
			}
			var nodeX:Number = Number(layoutDict[nodeKey]["x"]) * Constants.GAME_SCALE * levelScale;
			var nodeY:Number = Number(layoutDict[nodeKey]["y"]) * Constants.GAME_SCALE * levelScale;
			var gridKey:String = _getGridKey(nodeX, nodeY, gridDimensions);
			if (!grid.hasOwnProperty(gridKey))
			{
				grid[gridKey] = new Dictionary();
			}
			grid[gridKey][nodeKey] = true;
		}
	}
	
	public static function getGridX(_x:Number,  gridDimensions:Point):int
	{
		return Math.max(0, Math.floor(_x / gridDimensions.x));
	}
	
	public static function getGridY(_y:Number,  gridDimensions:Point):int
	{
		return Math.max(0, Math.floor(_y / gridDimensions.y));
	}
	
	public static function getGridXRight(_x:Number,  gridDimensions:Point):int
	{
		return Math.max(0, Math.ceil(_x / gridDimensions.x));
	}
	
	public static function getGridYBottom(_y:Number,  gridDimensions:Point):int
	{
		return Math.max(0, Math.ceil(_y / gridDimensions.y));
	}
	
	private static function _getGridKey(_x:Number, _y:Number, gridDimensions:Point):String
	{
		const GRID_X:int = getGridX(_x, gridDimensions);
		const GRID_Y:int = getGridX(_y, gridDimensions);
		return String(GRID_X + "_" + GRID_Y);
	}
	
}