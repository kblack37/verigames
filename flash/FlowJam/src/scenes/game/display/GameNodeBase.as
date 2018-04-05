package scenes.game.display
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import graph.PropDictionary;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import constraints.ConstraintVar;
	import events.GameComponentEvent;
	import events.GroupSelectionEvent;
	import events.MoveEvent;
	import events.UndoEvent;
	import utils.XMath;
	
	public class GameNodeBase extends GameComponent
	{
		public var costume:DisplayObject;
		protected var shapeWidth:Number = 100.0;
		protected var shapeHeight:Number = 100.0;
		
		public var storedXPosition:int;
		public var storedYPosition:int;
		
		public var constraintVar:ConstraintVar;
		protected var m_layoutObj:Object;
		public var orderedOutgoingEdges:Vector.<GameEdgeContainer>;
		public var orderedIncomingEdges:Vector.<GameEdgeContainer>;
		
		private var m_edgePortArray:Array;
		private var m_incomingPortsToEdgeDict:Dictionary;
		private var m_outgoingPortsToEdgeDict:Dictionary;
		
		protected static var WIDTH_CHANGE:String = "width_change";
		
		public function GameNodeBase(_layoutObj:Object, _constraintVar:ConstraintVar)
		{
			super(_constraintVar.id);
			constraintVar = _constraintVar;
			m_layoutObj = _layoutObj;
			
			orderedOutgoingEdges = new Vector.<GameEdgeContainer>();
			orderedIncomingEdges = new Vector.<GameEdgeContainer>();
			m_incomingPortsToEdgeDict = new Dictionary();
			m_outgoingPortsToEdgeDict = new Dictionary();
			m_edgePortArray = new Array();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public override function getProps():PropDictionary { return constraintVar.getProps().clone(); }
		
		public function updatePortIndexes():void
		{
			//sort things
			orderedOutgoingEdges.sort(GameEdgeContainer.sortOutgoingXPositions);
			orderedIncomingEdges.sort(GameEdgeContainer.sortIncomingXPositions);
			var currentPos:int = 0;
			m_edgePortArray = new Array();
			var i:int, j:int;
			// Reset positions to -1
			for (i = 0; i < orderedOutgoingEdges.length; i++) orderedOutgoingEdges[i].outgoingEdgePosition = -1;
			for (j = 0; j < orderedIncomingEdges.length; j++) orderedIncomingEdges[j].incomingEdgePosition = -1;
			for (i = 0; i < orderedOutgoingEdges.length; i++)
			{
				// m_outgoingEdges have been ordered from min X to 
				// max X so we are moving from left to right
				var startingCurrentPos:int = currentPos;
				var oedge:GameEdgeContainer = orderedOutgoingEdges[i];
				//if (oedge.outgoingEdgePosition != -1) trace("oedge:" + oedge.m_id + " skipped, outgoingEdgePosition:" + oedge.outgoingEdgePosition);
				if (oedge.outgoingEdgePosition != -1) continue;
				var oedgeXPos:Number = oedge.globalStart.x;
				//trace("oedge:" + oedge.m_id + " oedgeXPos:" + oedgeXPos);
				for (j = 0; j < orderedIncomingEdges.length; j++)
				{
					var iedge:GameEdgeContainer = orderedIncomingEdges[j];
					//if (iedge.incomingEdgePosition != -1) trace("iedge:" + iedge.m_id + " skipped, incomingEdgePosition:" + iedge.incomingEdgePosition);
					if (iedge.incomingEdgePosition != -1) continue;
					var iedgeXPos:Number = iedge.globalEnd.x;
					//trace("iedge:" + iedge.m_id + " iedgeXPos:" + iedgeXPos);
					if(oedgeXPos < iedgeXPos)
					{
						oedge.outgoingEdgePosition = currentPos;
						m_edgePortArray[currentPos] = oedge.m_fromPortID;
						currentPos++;
						break;
					}
					else
					{
						iedge.incomingEdgePosition = currentPos;
						m_edgePortArray[currentPos] = iedge.m_toPortID;
						currentPos++;
					}
				}
				//no incoming edges, or all incoming edges less than this outgoing edge?
				if(startingCurrentPos == currentPos || oedge.outgoingEdgePosition == -1)
				{
					oedge.outgoingEdgePosition = currentPos;
					m_edgePortArray[currentPos] = oedge.m_fromPortID;
					//trace("leftover oedge:" + oedge.m_id + " assigned:" + currentPos);
					currentPos++;
				}
			}
			
			//pick up any missed ones
			for(j = 0; j < orderedIncomingEdges.length; j++)
			{
				var edge:GameEdgeContainer = orderedIncomingEdges[j];
				if(edge.incomingEdgePosition == -1)
				{
					edge.incomingEdgePosition = currentPos;
					m_edgePortArray[currentPos] = edge.m_toPortID;
					//trace("edge:" + edge.m_id + " assigned:" + currentPos);
					currentPos++;
				}
			}
		}
		
		override public function dispose():void
		{
			if (m_disposed) {
				return;
			}
			disposeChildren();
			if (costume) {
				costume.removeFromParent(true);
			}
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(TouchEvent.TOUCH, onTouch);
			super.dispose();
		}
		
		private var m_isMoving:Boolean = false;
		private function set isMoving(value:Boolean):void {
			if (m_isMoving == value) return;
			m_isMoving = value;
			if (m_isMoving) {
				disableHover();
			} else {
				enableHover();
			}
		}
		private function get isMoving():Boolean { return m_isMoving; }
		
		private var hasMovedOutsideClickDist:Boolean = false;
		private var startingTouchPoint:Point;
		private var startingPoint:Point;
		private static const CLICK_DIST:Number = 0.2; // if the node is moved just a tiny bit, chances are the user meant to click rather than move
		override protected function onTouch(event:TouchEvent):void
		{
			var touches:Vector.<Touch> = event.touches;
			var touch:Touch = touches[0];
			super.onTouch(event);
			//trace(m_id);
			if(event.getTouches(this, TouchPhase.ENDED).length)
			{
				if (DEBUG_TRACE_IDS) trace("GameNodeBase '" + m_id + "'");
				if (DEBUG_TRACE_IDS) for (var i:int = 0; i < orderedIncomingEdges.length; i++) trace("i:" + orderedIncomingEdges[i].graphConstraint.lhs.id + "->" + orderedIncomingEdges[i].graphConstraint.rhs.id);
				if (DEBUG_TRACE_IDS) for (var o:int = 0; o < orderedOutgoingEdges.length; o++) trace("o:" + orderedOutgoingEdges[o].graphConstraint.lhs.id + "->" + orderedOutgoingEdges[o].graphConstraint.rhs.id);
				
				var undoData:Object, undoEvent:Event;
				if(isMoving) //if we were moving, stop it, and exit
				{
					isMoving = false;
					dispatchEvent(new MoveEvent(MoveEvent.FINISHED_MOVING, this));
					if (draggable && hasMovedOutsideClickDist) {
						var startPoint:Point = startingPoint.clone();
						var endPoint:Point = new Point(x, y);
						undoEvent = new MoveEvent(MoveEvent.MOVE_EVENT, this, startPoint, endPoint);
						var eventToDispatch:UndoEvent = new UndoEvent(undoEvent, this);
						eventToDispatch.levelEvent = true;
						dispatchEvent(eventToDispatch);
						hasMovedOutsideClickDist = false;
						return;
					}
				}
				
				if(event.shiftKey && event.ctrlKey && !PipeJam3.RELEASE_BUILD)
				{
					this.m_isEditable = !this.m_isEditable;
					this.m_isDirty = true;
				}
				
				//if shift key, select, else change size
				if(!event.shiftKey)
				{
					unflattenConnectedEdges();
					
					var touchClick:Touch = event.getTouch(this, TouchPhase.ENDED);
					var touchPoint:Point = touchClick ? new Point(touchClick.globalX, touchClick.globalY) : null;
					
					onClicked(touchPoint);
				}
				else //shift key down
				{
					if (!draggable) return;
					if(touch.tapCount == 1)
					{
						componentSelected(!isSelected);	
						if(isSelected)
							dispatchEvent(new GameComponentEvent(GameComponentEvent.COMPONENT_SELECTED, this));
						else
							dispatchEvent(new GameComponentEvent(GameComponentEvent.COMPONENT_UNSELECTED, this));
					}
					else //select/unselect whole group
					{
						var groupDictionary:Dictionary = new Dictionary();
						this.findGroup(groupDictionary);
						var selection:Vector.<GameComponent> = new Vector.<GameComponent>();
						for each(var comp:GameComponent in groupDictionary)
						{
							if(selection.indexOf(comp) == -1)
							{
								if(comp is GameNodeBase)
								{
									selection.push(comp);
								}
							}
						}
						if(isSelected) //we were selected on the first click
							dispatchEvent(new GroupSelectionEvent(GroupSelectionEvent.GROUP_SELECTED, this, selection));
						else
							dispatchEvent(new GroupSelectionEvent(GroupSelectionEvent.GROUP_UNSELECTED, this, selection));
					}
				}
			}
			else if (event.getTouches(this, TouchPhase.MOVED).length) {
				if (touches.length == 1)
				{
					var touchXY:Point = new Point(touch.globalX, touch.globalY);
					touchXY = this.globalToLocal(touchXY);
					if (!isMoving) {
						onHoverEnd();
						startingTouchPoint = touchXY;
						startingPoint = new Point(x, y);
						isMoving = true;
						hasMovedOutsideClickDist = false;
						return;
					} else if (!hasMovedOutsideClickDist) {
						if (XMath.getDist(startingTouchPoint, touchXY) > CLICK_DIST * Constants.GAME_SCALE) {
							hasMovedOutsideClickDist = true;
						} else {
							// Don't move if haven't moved outside CLICK_DIST
							return;
						}
					}
					if (!draggable) return;
					var currentMoveLocation:Point = touch.getLocation(this);
					var previousLocation:Point = touch.getPreviousLocation(this);
					unflattenConnectedEdges();
					dispatchEvent(new MoveEvent(MoveEvent.MOVE_EVENT, this, previousLocation, currentMoveLocation));
				}
			}
		}
		
		private function unflattenConnectedEdges():void
		{
			for each(var oedge1:GameEdgeContainer in this.orderedOutgoingEdges)
			{
				oedge1.unflatten();
			}
			for each(var iedge1:GameEdgeContainer in this.orderedIncomingEdges)
			{
				iedge1.unflatten();
			}
			
		}
		
		public function onClicked(pt:Point):void
		{
			// overriden by children
		}
		
		public function onEnterFrame(event:Event):void
		{
			if(m_isDirty)
			{
				removeChildren();
				draw();
				m_isDirty = false;
			}
		}
		
		public function draw():void
		{
			
		}
		
		override public function componentMoved(delta:Point):void
		{
			super.componentMoved(delta);
			
			rubberBandEdges(delta);
		}
		
		protected function rubberBandEdges(endPt:Point):void
		{
			for each(var oedge1:GameEdgeContainer in this.orderedOutgoingEdges)
			{
				oedge1.rubberBandEdge(endPt, true);
			}
			for each(var iedge1:GameEdgeContainer in this.orderedIncomingEdges)
			{
				iedge1.rubberBandEdge(endPt, false);
			}
		}
		
		public function drawEdges(rubberBanding:Boolean = false):void
		{
			for each(var oedge1:GameEdgeContainer in this.orderedOutgoingEdges)
			{
				oedge1.draw();
			}
			for each(var iedge1:GameEdgeContainer in this.orderedIncomingEdges)
			{
				iedge1.draw();
			}
		}
		
		//adds edge to outgoing edge method (unless currently in vector), then sorts
		public function setOutgoingEdge(edge:GameEdgeContainer):void
		{
			if (orderedOutgoingEdges.indexOf(edge) > -1) throw new Error("Unexpected: edge already added to Node before setOutgoingEdge call: " + edge.m_id);
			orderedOutgoingEdges.push(edge);
			edge.m_fromPortID = orderedOutgoingEdges.length + orderedIncomingEdges.length - 1;
			if (m_outgoingPortsToEdgeDict.hasOwnProperty(edge.m_fromPortID)) {
				throw new Error("Multiple outgoing edges found with same port id: " + edge.m_fromPortID + " node:" + m_id + " edge id:" + edge.m_id);
			}
			m_outgoingPortsToEdgeDict[edge.m_fromPortID] = edge;
			
			//I want the edges to be in ascending order according to x position, so do that here
			//only works when added to stage, so don't rely on initial placements
			orderedOutgoingEdges.sort(GameEdgeContainer.sortOutgoingXPositions);
		}
		
		//adds edge to incoming edge method (unless currently in vector), then sorts
		public function setIncomingEdge(edge:GameEdgeContainer):void
		{
			if (orderedIncomingEdges.indexOf(edge) > -1) throw new Error("Unexpected: edge already added to Node before setIncomingEdge call: " + edge.m_id);
			orderedIncomingEdges.push(edge);
			edge.m_toPortID = orderedOutgoingEdges.length + orderedIncomingEdges.length - 1;
			if (m_incomingPortsToEdgeDict.hasOwnProperty(edge.m_toPortID)) {
				throw new Error("Multiple incoming edges found with same port id: " + edge.m_toPortID + " node:" + m_id + " edge id:" + edge.m_id);
			}
			m_incomingPortsToEdgeDict[edge.m_toPortID] = edge;
			
			//I want the edges to be in ascending order according to x position, so do that here
			//only works when added to stage, so don't rely on initial placements
			orderedIncomingEdges.sort(GameEdgeContainer.sortIncomingXPositions);
		}
		
		public function removeEdges():void
		{
			// Delete references to edges, i.e. if recreating them
			orderedOutgoingEdges = new Vector.<GameEdgeContainer>();
			orderedIncomingEdges = new Vector.<GameEdgeContainer>();
			m_edgePortArray = new Array();
			m_incomingPortsToEdgeDict = new Dictionary();
			m_outgoingPortsToEdgeDict = new Dictionary();
		}
		
		//used when double clicking a node, handles selecting entire group. 
		public function findGroup(dictionary:Dictionary):void
		{
			dictionary[m_id] = this;
			for each(var oedge1:GameEdgeContainer in this.orderedOutgoingEdges)
			{
				if(dictionary[oedge1.m_toNode.m_id] == null)
					oedge1.m_toNode.findGroup(dictionary);
			}
			for each(var iedge1:GameEdgeContainer in this.orderedIncomingEdges)
			{
				if(dictionary[iedge1.m_fromNode.m_id] == null)
					iedge1.m_fromNode.findGroup(dictionary);
			}
		}
		
		public function organizePorts(edge:GameEdgeContainer, incrementing:Boolean):void
		{
			var isEdgeOutgoing:Boolean = (edge.m_fromNode == this);
			var edgeIndex:int;
			var edgeGlobalPt:Point;
			var savedEdgeGlobalPt:Point;
			if(isEdgeOutgoing)
			{
				edgeIndex = edge.outgoingEdgePosition;
				edgeGlobalPt = edge.globalStart;
				savedEdgeGlobalPt = edge.localToGlobal(edge.undoObject.m_savedStartPoint);
			}
			else
			{
				edgeIndex = edge.incomingEdgePosition;
				edgeGlobalPt = edge.globalEnd;
				savedEdgeGlobalPt = edge.localToGlobal(edge.undoObject.m_savedEndPoint);
			}
			
			var nextEdgeIndex:int = getNextEdgePosition(edgeIndex, incrementing);
			var nextEdge:GameEdgeContainer = edgeAt(nextEdgeIndex);
			if (nextEdge == null) trace("nextEdge == null");
			//trace("edgeGlobalPtX:" + edgeGlobalPt.x + " savedEdgeGlobalPtX:" + savedEdgeGlobalPt.x + "edgeIndex:" + edgeIndex + " nextEdgeIndex:" + nextEdgeIndex);
			if(nextEdge)
			{
				var isNextEdgeOutgoing:Boolean = (nextEdge.m_fromNode == this);
				var nextEdgeGlobalPt:Point = isNextEdgeOutgoing ? nextEdge.globalStart : nextEdge.globalEnd;
				var edgeUpdated:Boolean = false;
				//trace("nextEdgeGlobalPtX:" + nextEdgeGlobalPt.x + "nextEdgeIndex:" + nextEdgeIndex + " nextEdge:" + (nextEdge ? nextEdge.m_id : null));
				if(incrementing)
				{
					if(nextEdgeGlobalPt.x < edgeGlobalPt.x) {
						updateEdges(edge, nextEdgeGlobalPt, nextEdge, savedEdgeGlobalPt);
						edgeUpdated = true;
					}
				}
				else 
				{
					if(nextEdgeGlobalPt.x > edgeGlobalPt.x) {
						updateEdges(edge, nextEdgeGlobalPt, nextEdge, savedEdgeGlobalPt);
						edgeUpdated = true;
					}
				}
				
				if (edgeUpdated)
					switchEdgePositions(edge, edgeIndex, nextEdge, nextEdgeIndex);
			}
		}
		
		//find and return the position in the port array for the next edge, or -1
		protected function getNextEdgePosition(currentPos:int, increasing:Boolean):int
		{
			var i:int;
			if(increasing)
			{
				currentPos++;
				for (i = currentPos; i < m_edgePortArray.length; i++)
				{
					if (edgeAt(currentPos)) return i;
				}
			}
			else
			{
				currentPos--;
				for (i = currentPos; i >= 0; i--)
				{
					if (edgeAt(currentPos)) return i;
				}
			}
			return -1;
		}
		
		private function edgeAt(edgePortArrayIndex:int):GameEdgeContainer
		{
			if (edgePortArrayIndex < 0) return null;
			if (edgePortArrayIndex > m_edgePortArray.length - 1) return null;
			var port:int = m_edgePortArray[edgePortArrayIndex] as int;
			if (m_incomingPortsToEdgeDict.hasOwnProperty(port)) return m_incomingPortsToEdgeDict[port] as GameEdgeContainer;
			if (m_outgoingPortsToEdgeDict.hasOwnProperty(port)) return m_outgoingPortsToEdgeDict[port] as GameEdgeContainer;
			return null;
		}
		
		private function updateEdges(edge:GameEdgeContainer, newPosition:Point, nextEdge:GameEdgeContainer, newNextPosition:Point):void
		{
			var isNextEdgeOutgoing:Boolean = nextEdge.m_fromNode == this ? true : false;
			//for (var ee:int = 0; ee < m_edgePortArray.length; ee++) trace(ee + " p:" + m_edgePortArray[ee] + " e:" + (edgeAt(ee) ? edgeAt(ee).m_id : null));////debug
			//trace("rb edge0 " + nextEdge.m_id + " pt:" + (isNextEdgeOutgoing ? nextEdge.m_startPoint : nextEdge.m_endPoint));
			updateEdgePosition(edge, newPosition);
			updateNextEdgePosition(nextEdge, newNextPosition);
			nextEdge.rubberBandEdge(new Point(), isNextEdgeOutgoing);
			//trace("rb edge " + nextEdge.m_id + " pt:" + (isNextEdgeOutgoing ? nextEdge.m_startPoint : nextEdge.m_endPoint));
			
			//edge.hasChanged = true;
			edge.restoreEdge = false;
		}
		
		//update edge and extension edge to be at newPosition.x
		//the difference between this function and the next one, is that the mechanism is going to try to restore this
		//edge to the beginning state (as when you drag it a little bit, and it snaps back)
		//but, by setting the saved point, we will be snapping back to the new position, not the old one
		// in the next function, none of that holds, so we can just directly update the start and end points
		protected function updateEdgePosition(edge:GameEdgeContainer, newPosition:Point):void
		{
			var isEdgeOutgoing:Boolean = edge.m_fromNode == this ? true : false;
			if(isEdgeOutgoing)
			{
				if(edge.undoObject.m_savedStartPoint)
					edge.undoObject.m_savedStartPoint.x = edge.globalToLocal(newPosition).x;
			}
			else
			{
				if(edge.undoObject.m_savedEndPoint)
					edge.undoObject.m_savedEndPoint.x = edge.globalToLocal(newPosition).x;
			}
		}
		
		//update edge and extension edge to be at newPosition.x
		protected function updateNextEdgePosition(edge:GameEdgeContainer, newPosition:Point):void
		{
			var isEdgeOutgoing:Boolean = edge.m_fromNode == this ? true : false;
			if(isEdgeOutgoing)
			{
				edge.m_startPoint.x = edge.globalToLocal(newPosition).x;
			}
			else
			{
				edge.m_endPoint.x = edge.globalToLocal(newPosition).x;
			}
		}
		
		//switch edge port positions - both in the port index array and internally in the incoming and outgoing position variables
		protected function switchEdgePositions(currentEdgeContainer:GameEdgeContainer, currentPosition:int, nextEdgeContainer:GameEdgeContainer, nextPosition:int):void
		{
			var isEdgeOutgoing:Boolean = currentEdgeContainer.m_fromNode == this ? true : false;
			var isNextEdgeOutgoing:Boolean = nextEdgeContainer.m_fromNode == this ? true : false;
			
			//currentEdgeContainer.hasChanged = false;
			
			m_edgePortArray[currentPosition] = isNextEdgeOutgoing ? nextEdgeContainer.m_fromPortID : nextEdgeContainer.m_toPortID;
			m_edgePortArray[nextPosition] = isEdgeOutgoing ? currentEdgeContainer.m_fromPortID : currentEdgeContainer.m_toPortID;
			
			//trace("switch " + currentEdgeContainer.m_id + " out:"+isEdgeOutgoing+" @ pos " + currentPosition + " with " + nextEdgeContainer.m_id + " out:"+isNextEdgeOutgoing+" @ pos " + nextPosition);
			
			if(isEdgeOutgoing)
			{
				currentEdgeContainer.outgoingEdgePosition = nextPosition;
			}
			else
			{
				currentEdgeContainer.incomingEdgePosition = nextPosition;
			}
			if(isNextEdgeOutgoing)
			{
				nextEdgeContainer.outgoingEdgePosition = currentPosition;
			}
			else
			{
				nextEdgeContainer.incomingEdgePosition = currentPosition;
			}
		}
		
		public override function hideComponent(hide:Boolean):void
		{
			super.hideComponent(hide);
			
			for each(var outgoingEdge:GameEdgeContainer in orderedOutgoingEdges) {
				outgoingEdge.hideComponent(hide);
			}
			for each(var incomingEdge:GameEdgeContainer in orderedIncomingEdges) {
				incomingEdge.hideComponent(hide);
			}
		}
	}
}