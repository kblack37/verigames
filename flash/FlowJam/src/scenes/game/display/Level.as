package scenes.game.display
{
	import constraints.events.VarChangeEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import starling.events.EnterFrameEvent;
	
	import assets.AssetInterface;
	
	import constraints.Constraint;
	import constraints.ConstraintGraph;
	import constraints.ConstraintValue;
	import constraints.ConstraintVar;
	
	import deng.fzip.FZip;
	
	import display.ToolTipText;
	
	import events.EdgeContainerEvent;
	import constraints.events.ErrorEvent;
	import events.GameComponentEvent;
	import events.GroupSelectionEvent;
	import events.MenuEvent;
	import events.MiniMapEvent;
	import events.MoveEvent;
	import events.PropertyModeChangeEvent;
	import events.UndoEvent;
	import events.WidgetChangeEvent;
	
	import graph.BoardNodes;
	import graph.Edge;
	import graph.EdgeSetRef;
	import graph.LevelNodes;
	import graph.Node;
	import graph.NodeTypes;
	import graph.Port;
	import graph.PropDictionary;
	
	import networking.GameFileHandler;
	
	import scenes.BaseComponent;
	import scenes.game.PipeJamGameScene;
	
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	
	import system.MaxSatSolver;
	
	import utils.Base64Encoder;
	import utils.XObject;
	import utils.XString;
	
	/**
	 * Level all game components - widgets and links
	 */
	public class Level extends BaseComponent
	{
		
		/** True to allow user to navigate to any level regardless of whether levels below it are solved for debugging */
		public static var UNLOCK_ALL_LEVELS_FOR_DEBUG:Boolean = false;
		
		/** Name of this level */
		public var level_name:String;
		
		/** Node collection used to create this level, including name obfuscater */
		public var levelGraph:ConstraintGraph;
		
		private var selectedComponents:Vector.<GameComponent>;
		/** used by solver to keep track of which nodes map to which constraint values, and visa versa */
		private var nodeIDToConstraintsTwoWayMap:Dictionary;
		
		private var marqueeRect:Shape = new Shape();
		
		//the level node and decendents
		private var m_levelLayoutObj:Object;
		public var levelObj:Object;
		public var m_levelLayoutName:String;
		public var m_levelQID:String;
		private var m_levelOriginalLayoutObj:Object; //used for restarting the level
		//used when saving, as we need a parent graph element for the above level node
		public var m_levelLayoutObjWrapper:Object;
		public var m_levelAssignmentsObj:Object;
		private var m_levelOriginalAssignmentsObj:Object; //used for restarting the level
		private var m_levelBestScoreAssignmentsObj:Object; //best configuration so far
		public var m_tutorialTag:String;
		public var tutorialManager:TutorialLevelManager;
		private var m_layoutFixed:Boolean = false;
		public var m_targetScore:int;
		
		public var nodeLayoutObjs:Dictionary = new Dictionary();
		public var edgeLayoutObjs:Dictionary = new Dictionary();
		
		private var m_gameNodeDict:Dictionary = new Dictionary();
		private var m_gameEdgeDict:Dictionary = new Dictionary();
		
		private var m_hidingErrorText:Boolean = false;
		private var m_segmentHovered:GameEdgeSegment;
		public var errorConstraintDict:Dictionary = new Dictionary();
		
		private var m_nodesInactiveContainer:Sprite = new Sprite();
		private var m_errorInactiveContainer:Sprite = new Sprite();
		private var m_edgesInactiveContainer:Sprite = new Sprite();
		private var m_plugsInactiveContainer:Sprite = new Sprite();
		public var inactiveLayer:Sprite = new Sprite();
		
		private var m_nodesContainer:Sprite = new Sprite();
		private var m_errorContainer:Sprite = new Sprite();
		private var m_edgesContainer:Sprite = new Sprite();
		private var m_plugsContainer:Sprite = new Sprite();
		
		public var m_boundingBox:Rectangle = new Rectangle(0, 0, 1, 1);
		private var m_backgroundImage:Image;
		private var m_levelStartTime:Number;
		
		private var initialized:Boolean = false;
		
		/** Current Score of the player */
		private var m_bestScore:int = 0;
		
		/** Set to true when the target score is reached. */
		public var targetScoreReached:Boolean;
		public var original_level_name:String;
		
		/** Tracks total distance components have been dragged since last visibile calculation */
		public var totalMoveDist:Point = new Point();
		
		// The following are used for conflict scrolling purposes: (tracking list of current conflicts)
		private var m_currentConflictIndex:int = -1;
		private var m_levelConflictEdges:Vector.<GameEdgeContainer> = new Vector.<GameEdgeContainer>();
		private var m_levelConflictEdgeDict:Dictionary = new Dictionary();
		private var m_conflictEdgesDirty:Boolean = true;
		
		public var m_inSolver:Boolean = false;
		
		private static const BG_WIDTH:Number = 256;
		private static const MIN_BORDER:Number = 1000;
		private static const USE_TILED_BACKGROUND:Boolean = false; // true to include a background that scrolls with the view
		
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
			m_levelLayoutObj = XObject.clone(_levelLayoutObj);
			m_levelOriginalLayoutObj = XObject.clone(_levelLayoutObj);
			m_levelLayoutName = _levelLayoutObj["id"];
			m_levelQID = _levelLayoutObj["qid"];
			m_levelBestScoreAssignmentsObj = _levelAssignmentsObj;// XObject.clone(_levelAssignmentsObj);
			m_levelOriginalAssignmentsObj = XObject.clone(_levelAssignmentsObj);
			m_levelAssignmentsObj = _levelAssignmentsObj;// XObject.clone(_levelAssignmentsObj);
			
			m_tutorialTag = m_levelLayoutObj["tutorial"];
			if (m_tutorialTag && (m_tutorialTag.length > 0)) {
				tutorialManager = new TutorialLevelManager(m_tutorialTag);
				m_layoutFixed = tutorialManager.getLayoutFixed();
			}
			
			m_targetScore = int.MAX_VALUE;
			if ((m_levelAssignmentsObj["target_score"] != undefined) && !isNaN(int(m_levelAssignmentsObj["target_score"]))) {
				m_targetScore = int(m_levelAssignmentsObj["target_score"]);
			}
			targetScoreReached = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);	
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);	
		}
		
		public function loadBestScoringConfiguration():void
		{
			loadAssignments(m_levelBestScoreAssignmentsObj, true);
		}
		
		public function loadInitialConfiguration():void
		{
			loadAssignments(m_levelOriginalAssignmentsObj, true);
		}
		
		public function loadAssignmentsConfiguration(assignmentsObj:Object):void
		{
			loadAssignments(assignmentsObj);
		}
		
		private function loadAssignments(assignmentsObj:Object, updateTutorialManager:Boolean = false):void
		{
			PipeJam3.m_savedCurrentLevel.data.assignmentUpdates = null;
			var graphVar:ConstraintVar;
			for (var varId:String in levelGraph.variableDict) {
				graphVar = levelGraph.variableDict[varId] as ConstraintVar;
				setGraphVarFromAssignments(graphVar, assignmentsObj, updateTutorialManager);
			}
			if(graphVar) dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, graphVar, PropDictionary.PROP_NARROW, graphVar.getProps().hasProp(PropDictionary.PROP_NARROW), this, null));
			refreshTroublePoints();
			onScoreChange();
		}
		
		private function setGraphVarFromAssignments(graphVar:ConstraintVar, assignmentsObj:Object, updateTutorialManager:Boolean = false):void
		{
			//save object and restore at after initial assignments since I don't want these assignments saved
			var savedAssignmentObj:Object = PipeJam3.m_savedCurrentLevel.data.assignmentUpdates;
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
					tutorialManager.onWidgetChange(graphVar.id, PropDictionary.PROP_NARROW, !assignmentIsWide);
				}
			}
			
			//and then set from local storage, if there (but only if we really want it)
			if(PipeJamGameScene.levelContinued && !updateTutorialManager && savedAssignmentObj && savedAssignmentObj[graphVar.id] != null)
			{
				var newWidth:String = savedAssignmentObj[graphVar.id];
				var savedAssignmentIsWide:Boolean = (newWidth == ConstraintValue.VERBOSE_TYPE_1);
				if (graphVar.getProps().hasProp(PropDictionary.PROP_NARROW) == savedAssignmentIsWide) 
				{
					graphVar.setProp(PropDictionary.PROP_NARROW, !savedAssignmentIsWide);
				}
			}
		}
		
		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			if (m_disposed) {
				restart(); // undo progress if left the level and coming back
			} else {
				start();
			}
			
			//for (var varId:String in levelGraph.variableDict) {
				//var graphVar:ConstraintVar = levelGraph.variableDict[varId] as ConstraintVar;
				//graphVar.addEventListener(VarChangeEvent.VAR_CHANGED_IN_GRAPH, onWidgetChange);
			//}
			addEventListener(VarChangeEvent.VAR_CHANGE_USER, onWidgetChange);
			
			refreshTroublePoints();
			flatten();
			
			dispatchEvent(new starling.events.Event(Game.STOP_BUSY_ANIMATION,true));
		}
		
		public function initialize():void
		{
			if (initialized) return;
			trace("Level.initialize()...");
			refreshLevelErrors();
			if (USE_TILED_BACKGROUND && !m_backgroundImage) {
				// TODO: may need to refine GridViewPanel .onTouch method as well to get this to work: if(this.m_currentLevel && event.target == m_backgroundImage)
				var background:Texture = AssetInterface.getTexture("Game", "BoxesGamePanelBackgroundImageClass");
				background.repeat = true;
				m_backgroundImage = new Image(background);
				m_backgroundImage.width = m_backgroundImage.height = 2 * MIN_BORDER;
				m_backgroundImage.x = m_backgroundImage.y = -MIN_BORDER;
				m_backgroundImage.blendMode = BlendMode.NONE;
				addChild(m_backgroundImage);
			}
			
			if (inactiveLayer == null)  inactiveLayer  = new Sprite();
			if (m_nodesInactiveContainer == null)  m_nodesInactiveContainer  = new Sprite();
			if (m_errorInactiveContainer == null)  m_errorInactiveContainer  = new Sprite();
			if (m_edgesInactiveContainer == null)  m_edgesInactiveContainer  = new Sprite();
			if (m_plugsInactiveContainer == null)  m_plugsInactiveContainer  = new Sprite();
			inactiveLayer.addChild(m_nodesInactiveContainer);
			inactiveLayer.addChild(m_errorInactiveContainer);
			inactiveLayer.addChild(m_edgesInactiveContainer);
			inactiveLayer.addChild(m_plugsInactiveContainer);
			
			if (m_nodesContainer == null)  m_nodesContainer  = new Sprite();
			if (m_errorContainer == null)  m_errorContainer  = new Sprite();
			if (m_edgesContainer == null)  m_edgesContainer  = new Sprite();
			if (m_plugsContainer == null)  m_plugsContainer  = new Sprite();
			//m_nodesContainer.filter = BlurFilter.createDropShadow(4.0, 0.78, 0x0, 0.85, 2, 1); //only works up to 2048px
			addChild(m_nodesContainer);
			addChild(m_errorContainer);
			addChild(m_edgesContainer);
			addChild(m_plugsContainer);
			
			this.alpha = .999;

			selectedComponents = new Vector.<GameComponent>;
			totalMoveDist = new Point();
			
			loadLayout();
			trace("Level " + m_levelLayoutObj["id"] + " m_boundingBox = " + m_boundingBox);
			
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
		
		public function refreshLevelErrors():void
		{
			errorConstraintDict = new Dictionary();
			for (var constriantId:String in levelGraph.constraintsDict) {
				var constraint:Constraint = levelGraph.constraintsDict[constriantId] as Constraint;
				if (!constraint.isSatisfied()) errorConstraintDict[constriantId] = constraint;
			}
		}
		
		private function onEnterFrame(evt:EnterFrameEvent):void
		{
			// For initialization
			const CALLS_PER_FRAME:int = 200;
			var i:int = 0;
			if (nodeLayoutObjs.length > 0) {
				while (nodeLayoutObjs.length > 0 && i < CALLS_PER_FRAME) {
					var nodeLayout:Object = nodeLayoutObjs.shift();
					createNodeFromJsonObj(nodeLayout);
					i++;
				}
				//trace("nodes remaining: " + nodeLayoutObjs.length);
			} else if (edgeLayoutObjs.length > 0) {
				while (edgeLayoutObjs.length > 0 && i < CALLS_PER_FRAME) {
					var edgeLayout:Object = edgeLayoutObjs.shift();
					createEdgeFromJsonObj(edgeLayout);
					i++;
				}
				//trace("edges remaining: " + edgeLayoutObjs.length);
			} else {
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
		
		public function createNodeFromJsonObj(boxLayoutObj:Object):void
		{
			var varId:String = boxLayoutObj["id"];
			if (!levelGraph.variableDict.hasOwnProperty(varId)) {
				throw new Error("Couldn't find edge set for var id: " + varId);
			}
			destroyGameNode(varId);
			var constraintVar:ConstraintVar = levelGraph.variableDict[varId];
			var gameNode:GameNode = new GameNode(boxLayoutObj, constraintVar, !m_layoutFixed);
			setGraphVarFromAssignments(constraintVar, m_levelAssignmentsObj, true);
			
			var boxVisible:Boolean = true;
			if (boxLayoutObj.hasOwnProperty("visible") && (boxLayoutObj["visible"] == "false")) boxVisible = false;
			if (!boxVisible) {
				gameNode.hideComponent(true);
				boxLayoutObj["visible"] = "false";
			}
			m_gameNodeDict[varId] = gameNode;
		}
		
		public function destroyGameNode(nodeId:String):void {
			var gameNode:GameNode = m_gameNodeDict[nodeId];
			if (gameNode) gameNode.removeFromParent(true);
			delete m_gameNodeDict[nodeId];
		}
		
		public function createEdgeFromJsonObj(edgeLayoutObj:Object):void
		{
			var constraintId:String = edgeLayoutObj["id"];
			destroyGameEdge(constraintId);
			var newGameEdge:GameEdgeContainer = createLine(constraintId, edgeLayoutObj);
			m_gameEdgeDict[constraintId] = newGameEdge;
		}
		
		private function createLine(edgeId:String, edgeLayoutObj:Object):GameEdgeContainer
		{
			var edgeFromVarId:String = edgeLayoutObj["from_var_id"];
			var edgeToVarId:String = edgeLayoutObj["to_var_id"];
			if (!m_gameNodeDict.hasOwnProperty(edgeFromVarId)) {
				var fromNodeLayout:Object = nodeLayoutObjs[edgeFromVarId];
				if (!fromNodeLayout) throw new Error("Edge layout found with no from node layout, edge: " + edgeId + " node:" + edgeFromVarId);
				createNodeFromJsonObj(fromNodeLayout);
			}
			if (!m_gameNodeDict.hasOwnProperty(edgeToVarId)) {
				var toNodeLayout:Object = nodeLayoutObjs[edgeToVarId];
				if (!toNodeLayout) throw new Error("Edge layout found with no to node layout, edge: " + edgeId + " node:" + edgeToVarId);
				createNodeFromJsonObj(toNodeLayout);
			}
			var fromNode:GameNode = m_gameNodeDict[edgeFromVarId] as GameNode;
			var toNode:GameNode = m_gameNodeDict[edgeToVarId] as GameNode;
			if (!levelGraph.constraintsDict.hasOwnProperty(edgeId)) throw new Error("Edge not found in levelGraph.constraintsDict:" + edgeId);
			var constraint:Constraint = levelGraph.constraintsDict[edgeId];
			var edgeArray:Array = edgeLayoutObj["edge_array"];
			
			var newGameEdge:GameEdgeContainer = new GameEdgeContainer(edgeId, edgeArray, fromNode, toNode, constraint, !m_layoutFixed);
			if (!getVisible(edgeLayoutObj)) newGameEdge.hideComponent(true);
			
			return newGameEdge;
		}
		
		public function destroyGameEdge(edgeId:String):void {
			var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId];
			if (gameEdge) gameEdge.removeFromParent(true);
			delete m_gameEdgeDict[edgeId];
		}
		
		private function loadLayout():void
		{
			nodeLayoutObjs = new Dictionary();
			edgeLayoutObjs = new Dictionary();
			
			var minX:Number, minY:Number, maxX:Number, maxY:Number;
			minX = minY = Number.POSITIVE_INFINITY;
			maxX = maxY = Number.NEGATIVE_INFINITY;
			
			// Process layout nodes (vars)
			var visibleNodes:int = 0;
			var n:uint = 0;
			for (var varId:String in m_levelLayoutObj["layout"]["vars"])
			{
				var boxLayoutObj:Object = m_levelLayoutObj["layout"]["vars"][varId];
				var graphVar:ConstraintVar = levelGraph.variableDict[varId] as ConstraintVar;
				if (graphVar == null) {
					trace("Warning: layout var found with no corresponding contraints var:" + varId);
					continue;
				}
				boxLayoutObj["id"] = varId;
				boxLayoutObj["var"] = graphVar;
				var nodeX:Number = Number(boxLayoutObj["x"]) * Constants.GAME_SCALE;
				var nodeY:Number = Number(boxLayoutObj["y"]) * Constants.GAME_SCALE;
				var nodeWidth:Number = Number(boxLayoutObj["w"]) * Constants.GAME_SCALE;
				var nodeHeight:Number = Number(boxLayoutObj["h"]) * Constants.GAME_SCALE;
				var nodeBoundingBox:Rectangle = new Rectangle(nodeX - 0.5 * nodeWidth, nodeY - 0.5 * nodeHeight, nodeWidth, nodeHeight);
				minX = Math.min(minX, nodeBoundingBox.left);
				minY = Math.min(minY, nodeBoundingBox.top);
				maxX = Math.max(maxX, nodeBoundingBox.right);
				maxY = Math.max(maxY, nodeBoundingBox.bottom);
				boxLayoutObj["bb"] = nodeBoundingBox;
				nodeLayoutObjs[varId] = boxLayoutObj;
				if (m_gameNodeDict.hasOwnProperty(varId)) {
					// If node exists, update its position
					(m_gameNodeDict[varId] as GameNode).updateLayout(boxLayoutObj);
				}
				n++;
			}
			trace("node count = " + n);
			
			// Process layout edges (constraints)
			var visibleLines:int = 0;
			n = 0;
			var pattern:RegExp = /(.*) -> (.*)/i;
			for (var constraintId:String in m_levelLayoutObj["layout"]["constraints"])
			{
				var edgeLayoutObj:Object = m_levelLayoutObj["layout"]["constraints"][constraintId];
				edgeLayoutObj["id"] = constraintId;
				var result:Object = pattern.exec(constraintId);
				if (result == null) throw new Error("Invalid constraint layout string found: " + constraintId);
				if (result.length != 3) throw new Error("Invalid constraint layout string found: " + constraintId);
				var graphConstraint:Constraint = levelGraph.constraintsDict[constraintId] as Constraint;
				if (graphConstraint == null) throw new Error("No graph constraint found for constraint layout: " + constraintId);
				edgeLayoutObj["constraint"] = graphConstraint;
				edgeLayoutObj["from_var_id"] = result[1];
				edgeLayoutObj["to_var_id"] = result[2];
				//create edge array
				var edgeArray:Array = new Array();
				var ptsArr:Array = edgeLayoutObj["pts"] as Array;
				if (!ptsArr) throw new Error("No layout pts found for edge:" + constraintId);
				if (ptsArr.length < 4) throw new Error("Not enough points found in layout for edge:" + constraintId);
				var edgeXMin:Number, edgeXMax:Number, edgeYMin:Number, edgeYMax:Number;
				edgeXMin = edgeYMin = Number.POSITIVE_INFINITY;
				edgeXMax = edgeYMax = Number.NEGATIVE_INFINITY;
				for (var i:int = 0; i < ptsArr.length; i++) {
					var ptx:Number = Number(ptsArr[i]["x"]) * Constants.GAME_SCALE;
					var pty:Number = Number(ptsArr[i]["y"]) * Constants.GAME_SCALE;
					edgeXMin = Math.min(edgeXMin, ptx);
					edgeYMin = Math.min(edgeYMin, pty);
					edgeXMax = Math.max(edgeXMax, ptx);
					edgeYMax = Math.max(edgeYMax, pty);
					var pt:Point = new Point(ptx, pty);
					edgeArray.push(pt);
				}
				minX = Math.min(minX, edgeXMin);
				minY = Math.min(minY, edgeYMin);
				maxX = Math.max(maxX, edgeXMax);
				maxY = Math.max(maxY, edgeYMax);
				edgeLayoutObj["edge_array"] = edgeArray;
				edgeLayoutObj["bb"] = new Rectangle(edgeXMin, edgeYMin, edgeXMax - edgeXMin, edgeYMax - edgeYMin);
				edgeLayoutObjs[constraintId] = edgeLayoutObj;
				if (m_gameEdgeDict.hasOwnProperty(constraintId)) createEdgeFromJsonObj(edgeLayoutObj);
				n++;
			}
			trace("edge count = " + n);
			m_boundingBox = new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		public function start():void
		{
			m_segmentHovered = null;
			initialize();
			
			m_disposed = false;
			m_levelStartTime = new Date().time;
			if (tutorialManager) tutorialManager.startLevel();
			draw();
			
			//now that everything is attached and added to parents, update port position indexes, for both nodes and joints
			for (var nodeId:String in m_gameNodeDict) {
				var gameNode:GameNode = m_gameNodeDict[nodeId] as GameNode;
				gameNode.updatePortIndexes();
			}
			levelGraph.resetScoring();
			m_bestScore = levelGraph.currentScore;
			levelGraph.startingScore = levelGraph.currentScore;
			flatten();
			trace("Loaded: " + m_levelLayoutObj["id"] + " for display.");
		}
		
		public function restart():void
		{
			m_segmentHovered = null;
			if (!initialized) {
				start();
			} else {
				if (tutorialManager) tutorialManager.startLevel();
				m_levelStartTime = new Date().time;
			}
			//var propChangeEvt:PropertyModeChangeEvent = new PropertyModeChangeEvent(PropertyModeChangeEvent.PROPERTY_MODE_CHANGE, PropDictionary.PROP_NARROW);
			//onPropertyModeChange(propChangeEvt);
			//dispatchEvent(propChangeEvt);
			setNewLayout(null, m_levelOriginalLayoutObj);
			//m_levelAssignmentsObj = XObject.clone(m_levelOriginalAssignmentsObj);
			//loadAssignments(m_levelAssignmentsObj);
			loadInitialConfiguration();
			targetScoreReached = false;
			trace("Restarted: " + m_levelLayoutObj["id"]);
		}
		
		public function onSaveLayoutFile(event:MenuEvent):void
		{
			updateLevelObj();
			
			var levelObject:Object = PipeJamGame.levelInfo;
			if(levelObject != null)
			{
				m_levelLayoutObjWrapper["id"] = event.data.name;
				levelObject.m_layoutName = event.data.name;
				levelObject.m_layoutDescription = event.data.description;
				var layoutZip:ByteArray = zipJsonFile(m_levelLayoutObjWrapper, "layout");
				var layoutZipEncodedString:String = encodeBytes(layoutZip);
				GameFileHandler.saveLayoutFile(layoutSaved, layoutZipEncodedString);	
			}
		}
		
		protected function layoutSaved(result:int, e:flash.events.Event):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.LAYOUT_SAVED));
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
			var worldParent:DisplayObject = parent;
			while(worldParent && !(worldParent is World))
				worldParent = worldParent.parent;
			
			updateLayoutObj(worldParent as World, true);
			updateAssignmentsObj();
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			//disposeChildren();
		}
		
		public function setNewLayout(name:String, newLayoutObj:Object, useExistingLines:Boolean = false):void
		{
			m_levelLayoutObj = XObject.clone(newLayoutObj);
			m_levelLayoutName = name;
			//we might have ended up with a 'world', just grab the first level
			if(m_levelLayoutObj["levels"]) m_levelLayoutObj = m_levelLayoutObj["levels"][0];
			loadLayout();
			trace("Level " + m_levelLayoutObj["id"] + " m_boundingBox = " + m_boundingBox);
			draw();
		}
		
		//update current layout info based on node/edge position
		// TODO: We don't want Level to depend on World, let's avoid circular 
		// class dependency and have World -> Level, not World <-> Level
		public function updateLayoutObj(world:World, includeThumbnail:Boolean = false):void
		{
			m_levelLayoutObjWrapper = new Object();
			m_levelLayoutObjWrapper["layout"] = new Object();
			m_levelLayoutObjWrapper["layout"]["vars"] = new Object();
			for (var varId:String in m_levelLayoutObj["layout"]["vars"]) {
				m_levelLayoutObjWrapper["layout"]["vars"][varId] = new Object();
				if (!m_gameNodeDict.hasOwnProperty(varId)) {
					trace("Warning! Layout varid where no gameNode exists in boxDictionary varId:" + varId);
					continue;
				}
				var gameNode:GameNode = m_gameNodeDict[varId] as GameNode;
				var currentLayoutX:Number = (gameNode.x + /*m_boundingBox.x*/ + gameNode.boundingBox.width/2) / Constants.GAME_SCALE;
				m_levelLayoutObjWrapper["layout"]["vars"][varId]["x"] = currentLayoutX.toFixed(2);
				var currentLayoutY:Number = (gameNode.y + /*m_boundingBox.y*/ + gameNode.boundingBox.height/2) / Constants.GAME_SCALE;
				m_levelLayoutObjWrapper["layout"]["vars"][varId]["y"] = currentLayoutY.toFixed(2);
				if (gameNode.hidden) {
					m_levelLayoutObjWrapper["layout"]["vars"][varId]["visible"] = "false";
				} else {
					delete m_levelLayoutObjWrapper["layout"]["vars"][varId]["visible"];
				}
			}
			m_levelLayoutObjWrapper["layout"]["constraints"] = new Object();
			for (var constraintId:String in m_levelLayoutObj["layout"]["constraints"]) {
				m_levelLayoutObjWrapper["layout"]["constraints"][constraintId] = new Object();
				if (!m_gameEdgeDict.hasOwnProperty(constraintId)) {
					trace("Warning! Layout constraint found with no corresponding game edgeContainer found: " + constraintId);
					continue;
				}
				var edgeContainer:GameEdgeContainer = m_gameEdgeDict[constraintId] as GameEdgeContainer;
				m_levelLayoutObjWrapper["layout"]["constraints"][constraintId]["visible"] = (!edgeContainer.hidden).toString();
				m_levelLayoutObjWrapper["layout"]["constraints"][constraintId]["pts"] = new Array();
				
				if(edgeContainer.m_jointPoints.length != GameEdgeContainer.NUM_JOINTS)
					trace("Wrong number of joint points " + constraintId);
				for(var i:int = 0; i< edgeContainer.m_jointPoints.length; i++)
				{
					var pt:Point = edgeContainer.m_jointPoints[i];
					currentLayoutX = (pt.x + edgeContainer.x) / Constants.GAME_SCALE;
					currentLayoutY = (pt.y + edgeContainer.y) / Constants.GAME_SCALE;
					(m_levelLayoutObjWrapper["layout"]["constraints"][constraintId]["pts"] as Array).push( { "x": currentLayoutX.toFixed(2), "y": currentLayoutY.toFixed(2) } );
				}
			}
			
			if(includeThumbnail)
			{
				var byteArray:ByteArray = world.getThumbnail(300, 300);
				var enc:Base64Encoder = new Base64Encoder();
				enc.encodeBytes(byteArray);
				m_levelLayoutObjWrapper["thumb"] = enc.toString();
			}
		}
		
		//update current constraint info based on node constraints
		public function updateAssignmentsObj():void
		{
			m_levelAssignmentsObj = createAssignmentsObj();
		}
		
		private function createAssignmentsObj():Object
		{
			var hashSize:int = 0;
			var nodeId:String;
			for (nodeId in m_gameNodeDict) hashSize++;
			
			PipeJamGame.levelInfo.hash = new Array();
			
			var assignmentsObj:Object = { "id": original_level_name, 
									"hash": [], 
									"target_score": this.m_targetScore,
									"starting_score": this.levelGraph.currentScore,
									"starting_jams": this.m_levelConflictEdges.length,
									"assignments": { } };
			var count:int = 0;
			var numWide:int = 0;
			for (nodeId in m_gameNodeDict) {
				var node:GameNode = m_gameNodeDict[nodeId] as GameNode;
				if (node.constraintVar.constant) continue;
				if (!assignmentsObj["assignments"].hasOwnProperty(node.constraintVar.formattedId)) assignmentsObj["assignments"][node.constraintVar.formattedId] = { };
				assignmentsObj["assignments"][node.constraintVar.formattedId][ConstraintGraph.TYPE_VALUE] = node.constraintVar.getValue().verboseStrVal;
				var keyfors:Array = new Array();
				for (var i:int = 0; i < node.constraintVar.keyforVals.length; i++) keyfors.push(node.constraintVar.keyforVals[i]);
				if (keyfors.length > 0) assignmentsObj["assignments"][node.constraintVar.formattedId][ConstraintGraph.KEYFOR_VALUES] = keyfors;
				
				var isWide:Boolean = (node.constraintVar.getValue().verboseStrVal == ConstraintValue.VERBOSE_TYPE_1);
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
			trace("Disposed of : " + m_levelLayoutObj["id"]);
			if (m_disposed) {
				return;
			}
			
			if (tutorialManager) tutorialManager.endLevel();
			
			for (var nodeId:String in m_gameNodeDict) {
				var gameNodeSet:GameNode = m_gameNodeDict[nodeId] as GameNode;
				gameNodeSet.removeFromParent(true);
			}
			m_gameNodeDict = new Dictionary();
			for (var edgeId:String in m_gameEdgeDict) {
				var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
				gameEdge.removeFromParent(true);
			}
			m_gameEdgeDict = new Dictionary();
			
			if (m_nodesContainer) {
				while (m_nodesContainer.numChildren > 0) m_nodesContainer.getChildAt(0).removeFromParent(true);
				m_nodesContainer.removeFromParent(true);
			}
			if (m_errorContainer) {
				while (m_errorContainer.numChildren > 0) m_errorContainer.getChildAt(0).removeFromParent(true);
				m_errorContainer.removeFromParent(true);
			}
			if (m_edgesContainer) {
				while (m_edgesContainer.numChildren > 0) m_edgesContainer.getChildAt(0).removeFromParent(true);
				m_edgesContainer.removeFromParent(true);
			}
			if (m_plugsContainer) {
				while (m_plugsContainer.numChildren > 0) m_plugsContainer.getChildAt(0).removeFromParent(true);
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
			if (levelGraph) levelGraph.removeEventListener(ErrorEvent.ERROR_ADDED, onErrorAdded);
			if (levelGraph) levelGraph.removeEventListener(ErrorEvent.ERROR_REMOVED, onErrorRemoved);
			super.dispose();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage); //if re-added to stage, start up again
		}
		
		override protected function onTouch(event:TouchEvent):void
		{
			var touches:Vector.<Touch> = event.touches;
			if(event.getTouches(this, TouchPhase.MOVED).length){
				if (touches.length == 1)
				{
					// one finger touching -> move
					var x:int = 3;
				}
			}
		}
		
		private function onSegmentMoved(event:EdgeContainerEvent):void
		{
			var newLeft:Number = m_boundingBox.left;
			var newRight:Number = m_boundingBox.right;
			var newTop:Number = m_boundingBox.top;
			var newBottom:Number = m_boundingBox.bottom;
			if (event.container != null) {
				newLeft = Math.min(newLeft, event.container.boundingBox.left);
				newRight = Math.max(newRight, event.container.boundingBox.right);
				newTop = Math.min(newTop, event.container.boundingBox.top);
				newBottom = Math.max(newBottom, event.container.boundingBox.bottom);
				m_boundingBox = new Rectangle(newLeft, newTop, newRight - newLeft, newBottom - newTop);
			}
			if (tutorialManager != null) {
				var pointingAt:Boolean = false;
				if ((tutorialManager.getTextInfo() != null) && (tutorialManager.getTextInfo().pointAtFn != null)) {
					var pointAtObject:DisplayObject = tutorialManager.getTextInfo().pointAtFn(this);
					if (pointAtObject == event.segment) pointingAt = true;
				}
				tutorialManager.onSegmentMoved(event, pointingAt);
			}
		}
		
		private function onSegmentDeleted(event:EdgeContainerEvent):void
		{
			// TODO: notify tutorial manager
		}
		
		private function onHoverOver(event:EdgeContainerEvent):void
		{
			m_segmentHovered = event.segment;
		}
		
		private function onHoverOut(event:EdgeContainerEvent):void
		{
			m_segmentHovered = null;
		}
		
		//called when a segment is double-clicked on
		private function onCreateJoint(event:EdgeContainerEvent):void
		{
			if (tutorialManager && (event.container != null)) tutorialManager.onJointCreated(event);
		}
		
		//assume this only generates on toggle width events
		private function onWidgetChange(evt:VarChangeEvent = null):void
		{
			//trace("Level: onWidgetChange");
			if (evt) {
				levelGraph.updateScore(evt.graphVar.id, evt.prop, evt.newValue);
				//evt.graphVar.setProp(evt.prop, evt.newValue);
				//levelGraph.updateScore();
				if (tutorialManager) tutorialManager.onWidgetChange(evt.graphVar.id, evt.prop, evt.newValue);
				dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, evt.graphVar, evt.prop, evt.newValue, this, evt.pt));
				//save incremental changes so we can update if user quits and restarts
				if(PipeJam3.m_savedCurrentLevel.data.assignmentUpdates) //should only be null when doing assignments from assignments file
				{
					var constraintType:String = evt.newValue ? ConstraintValue.VERBOSE_TYPE_0 : ConstraintValue.VERBOSE_TYPE_1;
					PipeJam3.m_savedCurrentLevel.data.assignmentUpdates[evt.graphVar.id] = constraintType;
				}
			} else {
				levelGraph.updateScore();
				dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
			}
			onScoreChange(true, false);
		}
		
		private var m_propertyMode:String = PropDictionary.PROP_NARROW;
		public function onPropertyModeChange(evt:PropertyModeChangeEvent):void
		{
			var i:int, nodeId:String, gameNode:GameNode, edgeId:String, gameEdge:GameEdgeContainer;
			if (evt.prop == PropDictionary.PROP_NARROW) {
				m_propertyMode = PropDictionary.PROP_NARROW;
				for (edgeId in m_gameEdgeDict) {
					gameEdge = m_gameEdgeDict[edgeId] as GameEdgeContainer;
					gameEdge.setPropertyMode(m_propertyMode);
					activate(gameEdge);
				}
				for (nodeId in m_gameNodeDict) {
					gameNode = m_gameNodeDict[nodeId] as GameNode;
					gameNode.setPropertyMode(m_propertyMode);
					activate(gameNode);
				}
			} else {
				m_propertyMode = evt.prop;
				var edgesToActivate:Vector.<GameEdgeContainer> = new Vector.<GameEdgeContainer>();
				for (nodeId in m_gameNodeDict) {
					gameNode = m_gameNodeDict[nodeId] as GameNode;
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
				var gameNodesToActivate:Vector.<GameNode> = new Vector.<GameNode>();
				for (edgeId in m_gameEdgeDict) {
					gameEdge = m_gameEdgeDict[edgeId] as GameEdgeContainer;
					gameEdge.setPropertyMode(m_propertyMode);
					if (edgesToActivate.indexOf(gameEdge) > -1) {
						gameNodesToActivate.push(gameEdge.m_fromNode);
					} else {
						deactivate(gameEdge);
					}
				}
				for (nodeId in m_gameNodeDict) {
					gameNode = m_gameNodeDict[nodeId] as GameNode;	
					gameNode.setPropertyMode(m_propertyMode);
					if (gameNodesToActivate.indexOf(gameNode) == -1) {
						deactivate(gameNode);
					}
				}
			}
			flatten();
		}
		
		private function activate(comp:GameComponent):void
		{
			if (comp is GameEdgeContainer) {
				var edge:GameEdgeContainer = comp as GameEdgeContainer;
				m_edgesContainer.addChild(edge);
				if (edge.socket) m_plugsContainer.addChild(edge.socket);
				if (edge.plug)   m_plugsContainer.addChild(edge.plug);
			} else if (comp is GameNode) {
				m_nodesContainer.addChild(comp);
			}
		}
		
		private function deactivate(comp:GameComponent):void
		{
			if (comp is GameEdgeContainer) {
				var edge:GameEdgeContainer = comp as GameEdgeContainer;
				m_edgesInactiveContainer.addChild(edge);
				if (edge.socket) m_plugsInactiveContainer.addChild(edge.socket);
				if (edge.plug)   m_plugsInactiveContainer.addChild(edge.plug);
			} else if (comp is GameNode) {
				m_nodesInactiveContainer.addChild(comp);
			}
		}
		
		private function refreshTroublePoints():void
		{
			for (var edgeId:String in m_gameEdgeDict) {
				var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
				gameEdge.refreshConflicts();
			}
		}
		
		//data object should be in final selected/unselected state
		private function componentSelectionChanged(component:GameComponent, selected:Boolean):void
		{
			if(selected)
			{
				if(selectedComponents.indexOf(component) == -1)
					selectedComponents.push(component);
				//push any connecting edges that have both connected nodes selected
				if (component is GameNodeBase) {
					for each(var edge:GameEdgeContainer in (component as GameNodeBase).orderedIncomingEdges)
					{
						var fromComponent:GameNodeBase = edge.m_fromNode;
						if(selectedComponents.indexOf(fromComponent) != -1)
						{
							if(selectedComponents.indexOf(edge) == -1)
							{
								selectedComponents.push(edge);
							}
							edge.componentSelected(true);
						}
					}
					for each(var edge1:GameEdgeContainer in (component as GameNodeBase).orderedOutgoingEdges)
					{
						var toComponent:GameNodeBase = edge1.m_toNode;
						if(selectedComponents.indexOf(toComponent) != -1)
						{
							if(selectedComponents.indexOf(edge1) == -1)
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
				var index:int = selectedComponents.indexOf(component);
				if(index != -1)
					selectedComponents.splice(index, 1);
				if (component is GameNodeBase) {
					for each(var edge2:GameEdgeContainer in (component as GameNodeBase).orderedIncomingEdges)
					{
						if(selectedComponents.indexOf(edge2) != -1)
						{
							var edgeIndex:int = selectedComponents.indexOf(edge2);
							selectedComponents.splice(edgeIndex, 1);
							edge2.componentSelected(false);
						}
					}
					for each(var edge3:GameEdgeContainer in (component as GameNodeBase).orderedOutgoingEdges)
					{
						if(selectedComponents.indexOf(edge3) != -1)
						{
							var edgeIndex1:int = selectedComponents.indexOf(edge3);
							selectedComponents.splice(edgeIndex1, 1);
							edge3.componentSelected(false);
						}
					}
				}
			}
		}
		
		private function onComponentSelection(evt:GameComponentEvent):void
		{
			var component:GameComponent = evt.component;
			if(component)
				componentSelectionChanged(component, true);
			
			var selectionChangedComponents:Vector.<GameComponent> = new Vector.<GameComponent>();
			selectionChangedComponents.push(component);
			addSelectionUndoEvent(selectionChangedComponents, true);
		}
		
		private function onComponentUnselection(evt:GameComponentEvent):void
		{
			var component:GameComponent = evt.component;
			if(component)
				componentSelectionChanged(component, false);
			
			var selectionChangedComponents:Vector.<GameComponent> = new Vector.<GameComponent>();
			selectionChangedComponents.push(component);
			addSelectionUndoEvent(selectionChangedComponents, false);
		}
		
		private function onGroupSelection(evt:GroupSelectionEvent):void
		{
			var selectionChangedComponents:Vector.<GameComponent> = evt.selection.concat();
			for each (var comp:GameComponent in selectionChangedComponents) {
				comp.componentSelected(true);
				componentSelectionChanged(comp, true);
			}
			addSelectionUndoEvent(evt.selection.concat(), true, true);
		}
		
		private function onGroupUnselection(evt:GroupSelectionEvent):void
		{
			var selectionChangedComponents:Vector.<GameComponent> = evt.selection.concat();
			for each (var comp:GameComponent in selectionChangedComponents) {
				comp.componentSelected(false);
				componentSelectionChanged(comp, false);
			}
			addSelectionUndoEvent(evt.selection.concat(), false);
		}
		
		private function onFinishedMoving(evt:MoveEvent):void
		{
			// Recalc bounds
			var minX:Number, minY:Number, maxX:Number, maxY:Number;
			minX = minY = Number.POSITIVE_INFINITY;
			maxX = maxY = Number.NEGATIVE_INFINITY;
			var i:int;
			if (evt.component is GameNodeBase) {
				// If moved node, check those bounds - otherwise assume they're unchanged
				for (var nodeId:String in m_gameNodeDict) {
					var gameNode:GameNode = m_gameNodeDict[nodeId] as GameNode;
					minX = Math.min(minX, gameNode.boundingBox.left);
					minY = Math.min(minY, gameNode.boundingBox.top);
					maxX = Math.max(maxX, gameNode.boundingBox.right);
					maxY = Math.max(maxY, gameNode.boundingBox.bottom);
				}
			}
			for (var edgeId:String in m_gameEdgeDict) {
				var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
				minX = Math.min(minX, gameEdge.boundingBox.left);
				minY = Math.min(minY, gameEdge.boundingBox.top);
				maxX = Math.max(maxX, gameEdge.boundingBox.right);
				maxY = Math.max(maxY, gameEdge.boundingBox.bottom);
			}
			var oldBB:Rectangle = m_boundingBox.clone();
			m_boundingBox = new Rectangle(minX, minY, maxX - minX, maxY - minY);
			if (oldBB.x != m_boundingBox.x ||
			    oldBB.y != m_boundingBox.y ||
				oldBB.width != m_boundingBox.width ||
				oldBB.height != m_boundingBox.height) {
					dispatchEvent(new MiniMapEvent(MiniMapEvent.LEVEL_RESIZED));
			}
		}
		
		private function onErrorAdded(evt:ErrorEvent):void
		{
			errorConstraintDict[evt.constraintError.id] = evt.constraintError;
		}
		
		private function onErrorRemoved(evt:ErrorEvent):void
		{
			delete errorConstraintDict[evt.constraintError.id];
		}
		
		private function addSelectionUndoEvent(selection:Vector.<GameComponent>, selected:Boolean, addToLast:Boolean = false):void
		{
			if (selection.length == 0) {
				return;
			}
			var component:GameComponent = selection[0];
			var eventToUndo:Event;
			if (selected) {
				eventToUndo = new GroupSelectionEvent(GroupSelectionEvent.GROUP_SELECTED, component, selection);
			} else {
				eventToUndo = new GroupSelectionEvent(GroupSelectionEvent.GROUP_UNSELECTED, component, selection);
			}
			var eventToDispatch:UndoEvent = new UndoEvent(eventToUndo, this);
			eventToDispatch.addToLast = addToLast;
			dispatchEvent(eventToDispatch);
		}
		
		public function unselectAll(addEventToLast:Boolean = false):void
		{
			//make a copy of the selected list for the undo event
			var currentSelection:Vector.<GameComponent> = selectedComponents.concat();
			totalMoveDist = new Point();
			selectedComponents = new Vector.<GameComponent>();
			
			for each(var comp:GameComponent in currentSelection)
			{
				comp.componentSelected(false);
				componentSelectionChanged(comp, false);
			}
			
			if(currentSelection.length)
			{
				addSelectionUndoEvent(currentSelection, false, addEventToLast);
			}
		}
		
		private function onMoveEvent(evt:MoveEvent):void
		{
			var delta:Point = evt.delta;
			var newLeft:Number = m_boundingBox.left;
			var newRight:Number = m_boundingBox.right;
			var newTop:Number = m_boundingBox.top;
			var newBottom:Number = m_boundingBox.bottom;
			var movedNodes:Vector.<GameNode> = new Vector.<GameNode>();
			//if component isn't in the currently selected group, unselect everything, and then move component
			if(selectedComponents.indexOf(evt.component) == -1)
			{
				unselectAll();
				evt.component.componentMoved(delta);
				newLeft = Math.min(newLeft, evt.component.boundingBox.left);
				newRight = Math.max(newRight, evt.component.boundingBox.left);
				newTop = Math.min(newTop, evt.component.boundingBox.top);
				newBottom = Math.max(newBottom, evt.component.boundingBox.bottom);
				if (tutorialManager && (evt.component is GameNode)) {
					movedNodes.push(evt.component as GameNode);
					tutorialManager.onGameNodeMoved(movedNodes);
				}
			}
			else
			{
				//if (selectedComponents.length == 0) {
				//	totalMoveDist = new Point();
				//	return;
				//}
				var movedGameNode:Boolean = false;
				for each(var component:GameComponent in selectedComponents)
				{
					component.componentMoved(delta);
					newLeft = Math.min(newLeft, component.boundingBox.left);
					newRight = Math.max(newRight, component.boundingBox.left);
					newTop = Math.min(newTop, component.boundingBox.top);
					newBottom = Math.max(newBottom, component.boundingBox.bottom);

					if (component is GameNode) {
						movedNodes.push(component as GameNode);
						movedGameNode = true;
					}
				}
				if (tutorialManager && movedGameNode) tutorialManager.onGameNodeMoved(movedNodes);
			}
			totalMoveDist.x += delta.x;
			totalMoveDist.y += delta.y;
			//trace(totalMoveDist);
			dispatchEvent(new MiniMapEvent(MiniMapEvent.ERRORS_MOVED));
			m_boundingBox = new Rectangle(newLeft, newTop, newRight - newLeft, newBottom - newTop);
		}
		
		public override function handleUndoEvent(undoEvent:Event, isUndo:Boolean = true):void
		{
			if (undoEvent is GroupSelectionEvent) //individual selections come through here also
			{
				var groupEvt:GroupSelectionEvent = undoEvent as GroupSelectionEvent;
				if (groupEvt.selection)
				{
					for each(var selectedComp:GameComponent in groupEvt.selection)
					{
						if(selectedComp is GameNodeBase)
						{
							var performSelection:Boolean;
							if (undoEvent.type == GroupSelectionEvent.GROUP_SELECTED) {
								performSelection = !isUndo; // select if redo, unselect if undo
							} else {
								performSelection = isUndo; // unselect if redo, select if undo
							}
							selectedComp.componentSelected(performSelection);
							componentSelectionChanged(selectedComp as GameNodeBase, performSelection);
						}
					}
				}
			}
			else if (undoEvent is MoveEvent)
			{
				var moveEvt:MoveEvent = undoEvent as MoveEvent;
				var delta:Point;
				if (!isUndo) {
					delta = moveEvt.delta.clone();
				} else {
					delta = new Point(-moveEvt.delta.x, -moveEvt.delta.y);
				}
				//trace("isUndo:" + isUndo + " delta:" + delta);
				//not added as a temp selection, so move separately
				if (moveEvt.component)
					moveEvt.component.componentMoved(delta);
				for each(var selectedComponent:GameComponent in selectedComponents)
				{
					if (moveEvt.component != selectedComponent)
						selectedComponent.componentMoved(delta);
				}
			}
		}
		
		//to be called once to set everything up 
		//to move/update objects use update events
		public function draw():void
		{
			//trace("Bounding Box " + m_boundingBox);
			var maxX:Number = Number.NEGATIVE_INFINITY;
			var maxY:Number = Number.NEGATIVE_INFINITY;
			
			var nodeCount:int = 0;
			for (var nodeId:String in m_gameNodeDict) {
				var gameNode:GameNode = m_gameNodeDict[nodeId] as GameNode;
				gameNode.x = gameNode.boundingBox.x;
				gameNode.y = gameNode.boundingBox.y;
				gameNode.m_isDirty = true;
				m_nodesContainer.addChild(gameNode);
				nodeCount++;
			}
			
			var edgeCount:int = 0;
			for (var edgeId:String in m_gameEdgeDict) {
				var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
				gameEdge.m_isDirty = true;
				m_edgesContainer.addChild(gameEdge);
				m_errorContainer.addChild(gameEdge.errorContainer);
				if (gameEdge.socket) m_plugsContainer.addChild(gameEdge.socket);
				if (gameEdge.plug)   m_plugsContainer.addChild(gameEdge.plug);
				edgeCount++;
			}
			
			trace("Nodes " + nodeCount + " Edges " + edgeCount);
			if (m_backgroundImage) {
				m_backgroundImage.width = m_backgroundImage.height = 2 * MIN_BORDER + Math.max(m_boundingBox.width, m_boundingBox.height);
				m_backgroundImage.x = m_backgroundImage.y = - MIN_BORDER - 0.5 * Math.max(m_boundingBox.x, m_boundingBox.y);
				var texturesToRepeat:Number = (50.0 / Constants.GAME_SCALE) * (m_backgroundImage.width / BG_WIDTH);
				m_backgroundImage.setTexCoords(1, new Point(texturesToRepeat, 0.0));
				m_backgroundImage.setTexCoords(2, new Point(0.0, texturesToRepeat));
				m_backgroundImage.setTexCoords(3, new Point(texturesToRepeat, texturesToRepeat));
			}
			flatten();
		}
		
		private static function getVisible(_layoutObj:Object, _defaultValue:Boolean = true):Boolean
		{
			var value:String = _layoutObj["visible"];
			if (!value) return _defaultValue;
			return XString.stringToBool(value);
		}
		
		public function handleMarquee(startingPoint:Point, currentPoint:Point):void
		{
			if (m_layoutFixed) return;
			
			if(startingPoint != null)
			{
				marqueeRect.removeChildren();
				//scale line size
				var lineSize:Number = 1/(Math.max(parent.scaleX, parent.scaleY));
				marqueeRect.graphics.lineStyle(lineSize, 0xffffff);
				marqueeRect.graphics.moveTo(0,0);
				var pt1:Point = globalToLocal(startingPoint);
				var pt2:Point = globalToLocal(currentPoint);
				marqueeRect.graphics.lineTo(pt2.x-pt1.x, 0);
				marqueeRect.graphics.lineTo(pt2.x-pt1.x, pt2.y-pt1.y);
				marqueeRect.graphics.lineTo(0, pt2.y-pt1.y);
				marqueeRect.graphics.lineTo(0, 0);
				marqueeRect.x = pt1.x;
				marqueeRect.y = pt1.y;
				//do here to make sure we are on top
				addChild(marqueeRect);
				flatten();
			}
			else
			{
				var newSelectedComponents:Vector.<GameComponent> = new Vector.<GameComponent>();
				var newUnselectedComponents:Vector.<GameComponent> = new Vector.<GameComponent>();
				
				for (var nodeId:String in m_gameNodeDict) {
					var gameNode:GameNode = m_gameNodeDict[nodeId] as GameNode;
					handleSelection(gameNode, newSelectedComponents, newUnselectedComponents);
				}
				removeChild(marqueeRect);
				
				addSelectionUndoEvent(newSelectedComponents, true);
				addSelectionUndoEvent(newUnselectedComponents, false, true);
			}
		}
		
		protected function handleSelection(node:GameNodeBase, newSelectedComponents:Vector.<GameComponent>, newUnselectedComponents:Vector.<GameComponent>):void
		{
			var bottomRight:Point = globalToLocal(node.bounds.bottomRight);
			var topLeft:Point = globalToLocal(node.bounds.topLeft);
			var topRight:Point = globalToLocal(new Point(node.bounds.right, node.bounds.top));
			var bottomLeft:Point = globalToLocal(new Point(node.bounds.left, node.bounds.bottom));
			var mbottomLeft:Point = globalToLocal(new Point(marqueeRect.x, marqueeRect.y));
			
			if((marqueeRect.bounds.left < node.bounds.left && marqueeRect.bounds.right > node.bounds.left) || 
				(marqueeRect.bounds.left < node.bounds.right && marqueeRect.bounds.right > node.bounds.right))
			{
				if((marqueeRect.bounds.top < node.bounds.bottom && marqueeRect.bounds.bottom > node.bounds.bottom) || 
					(marqueeRect.bounds.top < node.bounds.top && marqueeRect.bounds.bottom > node.bounds.top))
				{
					node.componentSelected(!node.isSelected);
					if (node.isSelected) {
						if ((selectedComponents.indexOf(node) == -1) && (newSelectedComponents.indexOf(node) == -1)) {
							newSelectedComponents.push(node);
						}
					} else {
						if ((selectedComponents.indexOf(node) > -1) && (newUnselectedComponents.indexOf(node) == -1)) {
							newUnselectedComponents.push(node);
						}
					}
					componentSelectionChanged(node, node.isSelected);
				}
			}
		}
		
		public function toggleUneditableStrings():void
		{
			var visitedNodes:Dictionary = new Dictionary;
			for (var nodeId:String in m_gameNodeDict) {
				var node:GameNode = m_gameNodeDict[nodeId] as GameNode;
				if(visitedNodes[node.m_id] == null)
				{
					visitedNodes[node.m_id] = node;
					var groupDictionary:Dictionary = new Dictionary;
					node.findGroup(groupDictionary);
					//check for an editable node
					var uneditable:Boolean = true;
					for each(var comp:GameComponent in groupDictionary)
					{
						if(comp.m_isEditable)
						{
							uneditable = false;
							break;
						}
					}
					if(uneditable)
					{
						for each(var comp1:GameComponent in groupDictionary)
						{
							comp1.hideComponent(comp.visible);
							visitedNodes[comp1.m_id] = comp1;
						}
					}
				}
			}
		}
		
		public function getNode(_id:String):GameNode
		{
			if (m_gameNodeDict.hasOwnProperty(_id) && (m_gameNodeDict[_id] is GameNode)) {
				return (m_gameNodeDict[_id] as GameNode);
			}
			return null;
		}
		
		public function getEdges():Dictionary
		{
			return m_gameEdgeDict;
 		}
		
		public function getEdgeContainer(_id:String):GameEdgeContainer
		{
			if (m_gameEdgeDict.hasOwnProperty(_id) && (m_gameEdgeDict[_id] is GameEdgeContainer)) {
				return (m_gameEdgeDict[_id] as GameEdgeContainer);
			}
			return null;
		}
		
		public function getNodes():Dictionary
		{
			return m_gameNodeDict;
		}
		
		public function getLevelTextInfo():TutorialManagerTextInfo
		{
			return tutorialManager ? tutorialManager.getTextInfo() : null;
		}
		
		public function getLevelToolTipsInfo():Vector.<TutorialManagerTextInfo>
		{
			return tutorialManager ? tutorialManager.getPersistentToolTipsInfo() : (new Vector.<TutorialManagerTextInfo>());
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
			if (!m_hidingErrorText) {
				for (var edgeId:String in m_gameEdgeDict) {
					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
					gameEdge.hideErrorText();
				}
				m_hidingErrorText = true;
			}
		}
		
		public function showErrorText():void
		{
			if (m_hidingErrorText) {
				for (var edgeId:String in m_gameEdgeDict) {
					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
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
		public function getNextConflict(forward:Boolean):DisplayObject
		{
			if (m_conflictEdgesDirty) {
				for (var edgeId:String in m_gameEdgeDict) {
					var gameEdge:GameEdgeContainer = m_gameEdgeDict[edgeId] as GameEdgeContainer;
					if (gameEdge.hasError()) {
						if (!m_levelConflictEdgeDict.hasOwnProperty(gameEdge.m_id)) {
							// Add to list/dict if not on there already
							if (m_levelConflictEdges.indexOf(gameEdge) == -1) m_levelConflictEdges.push(gameEdge);
							m_levelConflictEdgeDict[gameEdge.m_id] = true;
						}
					} else {
						if (m_levelConflictEdgeDict.hasOwnProperty(gameEdge.m_id)) {
							// Remove from edge conflict list/dict if on it
							var delindx:int = m_levelConflictEdges.indexOf(gameEdge);
							if (delindx > -1) m_levelConflictEdges.splice(delindx, 1);
							delete m_levelConflictEdgeDict[gameEdge.m_id];
						}
					}
				}
				m_conflictEdgesDirty = false;
			}
			//keep track of number of conflicts
			PipeJamGame.levelInfo.conflicts = m_levelConflictEdges.length;
			
			if (m_levelConflictEdges.length == 0) return null;
			if (forward) {
				m_currentConflictIndex++;
			} else {
				m_currentConflictIndex--;
			}
			if (m_currentConflictIndex >= m_levelConflictEdges.length) {
				m_currentConflictIndex = 0;
			} else if (m_currentConflictIndex < 0) {
				m_currentConflictIndex = m_levelConflictEdges.length - 1;
			}
			return m_levelConflictEdges[m_currentConflictIndex].errorContainer;
		}
		
		//can't flatten errorContainer as particle system is unsupported display object
		public override function flatten():void
		{
			return; // uncomment when more testing performed
			// Active layers
			m_nodesContainer.flatten();
			//m_errorContainer.flatten();// Can't flatten due to animations
			m_edgesContainer.flatten();
			m_plugsContainer.flatten();
			// Inactive layers
			m_nodesInactiveContainer.flatten();
			//m_errorInactiveContainer.flatten();// Can't flatten due to animations
			m_edgesInactiveContainer.flatten();
			m_plugsInactiveContainer.flatten();
		}
		
		public override function unflatten():void
		{
			super.unflatten();
			// Active layers
			m_nodesContainer.unflatten();
			//m_errorContainer.unflatten();// Can't flatten due to animations
			m_edgesContainer.unflatten();
			m_plugsContainer.unflatten();
			// Inactive layers
			m_nodesInactiveContainer.unflatten();
			//m_errorInactiveContainer.unflatten();// Can't flatten due to animations
			m_edgesInactiveContainer.unflatten();
			m_plugsInactiveContainer.unflatten();
		}
		
		public function getPanZoomAllowed():Boolean
		{ 
			if (tutorialManager) return tutorialManager.getPanZoomAllowed();
			return true;
		}
		
		public function getSolveButtonsAllowed():Boolean
		{ 
			if (tutorialManager) return tutorialManager.getSolveButtonsAllowed();
			return true;
		}
		
		public static const SEGMENT_DELETION_ENABLED:Boolean = false;
		public function onDeletePressed():void
		{
			// Only delete if layout moves are allowed
			if (tutorialManager && tutorialManager.getLayoutFixed()) return;
			if (!SEGMENT_DELETION_ENABLED) return;
			if (m_segmentHovered) m_segmentHovered.onDeleted();
		}
		
		public function onUseSelectionPressed(choice:String):void
		{
			var assignmentIsWide:Boolean = false;
			if(choice == MenuEvent.MAKE_SELECTION_WIDE)
				assignmentIsWide = true;
			else if(choice == MenuEvent.MAKE_SELECTION_NARROW)
				assignmentIsWide = false;
			
			var gameNode:GameNode;	
			for(var i:int = 0; i<selectedComponents.length; i++)
			{
				var component:GameComponent = selectedComponents[i];
				if(component is GameNode)
				{
					gameNode = component as GameNode;
					if(gameNode.m_isEditable) gameNode.constraintVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
				}
			}
			//update score
			onWidgetChange();
		}
		
		public function get currentScore():int { return levelGraph.currentScore; }
		public function get bestScore():int { return m_bestScore; }
		public function get startingScore():int { return levelGraph.startingScore; }
		public function get prevScore():int { return levelGraph.prevScore; }
		public function get oldScore():int { return levelGraph.oldScore; }
		
		public function resetBestScore():void
		{
			m_bestScore = levelGraph.currentScore;
			m_levelBestScoreAssignmentsObj = XObject.clone(m_levelAssignmentsObj);
		}
		
		public function onScoreChange(recordBestScore:Boolean = false, logChange:Boolean = true):void
		{
			if (recordBestScore && (levelGraph.currentScore > m_bestScore)) {
				m_bestScore = levelGraph.currentScore;
				trace("New best score: " + m_bestScore);
				m_levelBestScoreAssignmentsObj = createAssignmentsObj();
				//don't update on loading
				if(!m_tutorialTag && levelGraph.oldScore != 0)
					dispatchEvent(new MenuEvent(MenuEvent.SUBMIT_LEVEL));
			}
			if (logChange && levelGraph.prevScore != levelGraph.currentScore)
				dispatchEvent(new WidgetChangeEvent(WidgetChangeEvent.LEVEL_WIDGET_CHANGED, null, null, false, this, null));
			m_conflictEdgesDirty = true;
		}
		
		public function solveSelection(updateCallback:Function, doneCallback:Function):void
		{
			//figure out which edges have both start and end components selected (all included edges have both ends selected?)
			//assign connected components to component to edge constraint number dict
			//create three constraints for conflicts and weights
			//run the solver, passing in the callback function
			nodeIDToConstraintsTwoWayMap = new Dictionary;
			var counter:int = 1;
			var constraintArray:Array = new Array;
			var initvarsArray:Array = new Array;
			for(var i:int = 0; i<selectedComponents.length; i++)
			{
				var constraint1Value:int = -1;
				var constraint2Value:int = -1;
				var component:GameComponent = selectedComponents[i];
				if(component is GameEdgeContainer)
				{
					var edge:GameEdgeContainer = component as GameEdgeContainer;
					var fromNode:GameNodeBase = edge.m_fromNode;
					var toNode:GameNodeBase = edge.m_toNode;
					
					if(fromNode.m_isEditable)
					{
						if(nodeIDToConstraintsTwoWayMap[fromNode.m_id] == null)
						{
							nodeIDToConstraintsTwoWayMap[fromNode.m_id] = counter;
							nodeIDToConstraintsTwoWayMap[counter] = fromNode.constraintVar;
							constraint1Value = counter;
							counter++;
						}
						else
							constraint1Value = nodeIDToConstraintsTwoWayMap[fromNode.m_id];
					} 
					
					if(toNode.m_isEditable)
					{
						if(nodeIDToConstraintsTwoWayMap[toNode.m_id] == null)
						{
							nodeIDToConstraintsTwoWayMap[toNode.m_id] = counter;
							nodeIDToConstraintsTwoWayMap[counter] = toNode.constraintVar;
							constraint2Value = counter;
							counter++;
						}
						else
							constraint2Value = nodeIDToConstraintsTwoWayMap[toNode.m_id];
					}
					
					if(fromNode.m_isEditable && toNode.m_isEditable)
						constraintArray.push(new Array(100, -constraint1Value, constraint2Value));
					else if(fromNode.m_isEditable && !toNode.m_isEditable)
					{
						if(!toNode.m_isWide)
							constraintArray.push(new Array(100, -constraint1Value));
					}
					if(!fromNode.m_isEditable && toNode.m_isEditable)
					{
						if(fromNode.m_isWide)
							constraintArray.push(new Array(100, constraint2Value));
					}
				}
				else if(component is GameNode)
				{
					var node:GameNode = component as GameNode;
					if(node.m_isEditable)
					{
						if(nodeIDToConstraintsTwoWayMap[node.m_id] == null)
						{
							nodeIDToConstraintsTwoWayMap[node.m_id] = counter;
							nodeIDToConstraintsTwoWayMap[counter] = node.constraintVar;
							constraint1Value = counter;
							counter++;
						}
						else
							constraint1Value = nodeIDToConstraintsTwoWayMap[node.m_id];
						
						constraintArray.push(new Array(1, constraint1Value));
					}
				}
			}
			
			if(constraintArray.length > 0)
			{
				//generate initvars array
				for(var ii:int = 1;ii<counter;ii++)
				{
					var constraintVar:ConstraintVar = nodeIDToConstraintsTwoWayMap[ii] as ConstraintVar;
					if(!constraintVar.getProps().hasProp(PropDictionary.PROP_NARROW))
						initvarsArray.push(1);
					else
						initvarsArray.push(0);
				}
				m_inSolver = true;
				MaxSatSolver.run_solver(constraintArray, initvarsArray, updateCallback, doneCallback);
			}
		}
		
		public function solverUpdate(vars:Array, unsat_weight:int):void
		{
			var constraintVar:ConstraintVar;
			var assignmentIsWide:Boolean = false;
			
			if(	m_inSolver == false) //got marked done early
				return;
			
			for (var ii:int = 0; ii < vars.length; ++ ii) 
			{
				constraintVar = nodeIDToConstraintsTwoWayMap[ii+1] as ConstraintVar;
				assignmentIsWide = false;
				if(vars[ii] == 1)
					assignmentIsWide = true;
				if(constraintVar) constraintVar.setProp(PropDictionary.PROP_NARROW, !assignmentIsWide);
			}
			onWidgetChange();
		}
		
		public function solverDone(errMsg:String):void
		{
			m_inSolver = false;
			MaxSatSolver.stop_solver();
			levelGraph.updateScore();
			onScoreChange(true); // TODO: need to log the widget changes here
		}
	}
}