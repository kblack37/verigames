package NetworkGraph
{
	import Events.*;
	
	import NetworkGraph.Node;
	
	import Utilities.Geometry;
	import Utilities.Metadata;
	
	import VisualWorld.Ball;
	import VisualWorld.Board;
	import VisualWorld.Car;
	import VisualWorld.DropObjectBase;
	import VisualWorld.Pipe;
	import VisualWorld.Theme;
	import VisualWorld.TroublePoint;
	import VisualWorld.VerigameSystem;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * Directed Edge created when a graph structure is read in from XML.
	 */
	public class Edge extends EventDispatcher
	{
		/* Network connections */
		/** Port on source node */
		public var from_port:Port;
		
		/** Port on destination node */
		public var to_port:Port;
		
		/** Any extra information contained in the orginal XML for this edge */
		public var metadata:Object;
		
		/** The numerical index (starting at 0 = first) corresponding to the linked edge set (by level) that this edge belongs to */
		public var linked_edge_set:EdgeSetRef;
		
		/* Edge identifiers */
		/** Name of the variable provided in XML */
		public var description:String = "";
		
		/** The unique id given as input from XML (unique within a given world) */
		public var edge_id:String;		
		
		/** Id of the variable identified in XML */
		public var variableID:int;
				
		/** The spline control points associated with this edge for drawing purposes */
		public var spline_control_points:Vector.<Point>;	
		
		/** The pipe object (if any) created from this edge */
		public var _associated_pipe:Pipe;
		
		/** pointers back up to all starting edges that can reach this edge. */
		public var topmostEdgeDictionary:Dictionary = new Dictionary;
		public var topmostEdgeIDArray:Array = new Array;
		
		/* Starting state of the pipe */
		/** True if edge has attribute width="wide" in XML, false otherwise */
		public var starting_is_wide:Boolean = false;
		
		/** True if edge has attribute buzzsaw="true" in XML, false otherwise */
		public var starting_has_buzzsaw:Boolean = false;
				
		/** True if this edge's width can be changed by the user, if false pipe is gray and cannot be changed */
		public var editable:Boolean = false;
		
		/* current state of the pipe */
		/** True if edge has attribute width="wide" in XML, false otherwise */
		public var is_wide:Boolean = false;
		
		/** True if edge has attribute buzzsaw="true" in XML, false otherwise */
		public var has_buzzsaw:Boolean = false;
		
		/** True if this edge contains a pinch point, false otherwise */
		public var has_pinch:Boolean = false;
		
		/* Flow state information */
		/** an array of values for the drop objects, a set for each incoming pipe (one for each parent that's a starting node) **/
		public var dropObjectFlowStateEdgeIDArray:Array = new Array;
		
		/* used for lookup so we don't create/store multiple copies of them. */
		public var dropObjectFlowStateCache:Dictionary = new Dictionary;
		
		private var currentFlowStateObjectIndex:uint = 0;
		
		/** used to mark nodes that think they are starting nodes, and we check later if they actually are. 
		 I think this is only a situation that arises on mismade boards (like some I hand created) but I'll handle the case anyway as it helps with debugging
		*/
		public var isStartingNode:Boolean;		
		
		/**
		 * Directed Edge created when a graph structure is read in from XML.
		 * @param	_from_node Source node
		 * @param	_from_port Port on source node
		 * @param	_to_node Destination node
		 * @param	_to_port Port on destination node
		 * @param   _spline_control_points Points defining the spline to connect the from_node to the to_node
		 * @param	_metadata Extra information about this edge (for example: any attributes in the original XML object)
		 */
		public function Edge(_from_node:Node, _from_port_id:String, _to_node:Node, _to_port_id:String, _spline_control_points:Vector.<Point> = null, _linked_edge_set:EdgeSetRef = null, _metadata:Object = null)
		{
			if (_from_node is SubnetworkNode) {
				from_port = new SubnetworkPort((_from_node as SubnetworkNode), this, _from_port_id, Port.OUTGOING_PORT_TYPE);
			} else {
				from_port = new Port(_from_node, this, _from_port_id, Port.OUTGOING_PORT_TYPE);
			}
			
			if (_to_node is SubnetworkNode) {
				to_port = new SubnetworkPort((_to_node as SubnetworkNode), this, _to_port_id, Port.INCOMING_PORT_TYPE);
			} else {
				to_port = new Port(_to_node, this, _to_port_id, Port.INCOMING_PORT_TYPE);
			}
			
			metadata = _metadata;
			linked_edge_set = _linked_edge_set;
			if (_metadata == null) {
				metadata = new Metadata(null);
			} else if (_metadata.data != null) {
				//Example: <edge description="chute1" variableID="-1" pinch="false" width="wide" id="e1" buzzsaw="false">
				if (metadata.data.description) {
					if (String(metadata.data.description).length > 0) {
						description = String(metadata.data.description);
					}
				}
				if (metadata.data.variableID) {
					if (!isNaN(int(metadata.data.variableID))) {
						variableID = int(metadata.data.variableID);
					}
				}
				if (String(metadata.data.pinch).toLowerCase() == "true") {
					has_pinch = true;
				}
				if (String(metadata.data.editable).toLowerCase() == "true") {
					editable = true;
				}
				if (String(metadata.data.width).toLowerCase() == "wide") {
					starting_is_wide = true;
					is_wide = true;
				}
				if (String(metadata.data.buzzsaw).toLowerCase() == "true") {
					starting_has_buzzsaw = true;
					has_buzzsaw = true;
				}
				if (String(_metadata.data.id).length > 0) {
					edge_id = String(_metadata.data.id);
				}
			}
			_associated_pipe = null;
			
			// Default is to add control points to make a straight line between endpoints
			spline_control_points = _spline_control_points;
			if (!spline_control_points) {
				spline_control_points = new Vector.<Point>();
			}

			if (spline_control_points.length < 4) {
				// If none supplied, assume a straight line (from_node -> to_node)
				spline_control_points = new Vector.<Point>();
				var from_point:Point = new Point(from_node.x, from_node.y);
				spline_control_points.push(from_point);
				spline_control_points.push(from_point);
				var to_point:Point = new Point(to_node.x, to_node.y);
				spline_control_points.push(to_point);
				spline_control_points.push(to_point);
			}
			
			Network.edgeDictionary[edge_id] = this;
		}
		
		public function set associated_pipe(p:Pipe):void
		{
	//		if(_associated_pipe != null)
	//			_associated_pipe.removeEventListener(PipeChangeEvent.PIPE_CHANGE, onPipeChange);
			_associated_pipe = p;
	//		_associated_pipe.addEventListener(PipeChangeEvent.PIPE_CHANGE, onPipeChange);
		}
		
		public function get associated_pipe():Pipe
		{
			return _associated_pipe;
		}
		
		public function pipeChanged():void
		{
			//Update local variables
			is_wide = associated_pipe.is_wide;
			has_buzzsaw = associated_pipe.has_buzzsaw;
		}
		
		public function updateEdgeWidth(isWide:Boolean):void
		{
			if(editable)
				is_wide = isWide;
		}
		
		//set has_buzzsaw var to true or false depending if pipe
		//then recurse through children, passing down value, except if value = false, and child pipe does actually have one, then pass true
		public function updateEdgeHasBuzz(hasBuzz:Boolean = true):void
		{
			has_buzzsaw = hasBuzz;
			
			//update flow objects and their children
			updateFlowObjects(true);
		}
		
		public function updateFlowObjects(recursive:Boolean):void
		{
			for each(var flowObjID:String in this.dropObjectFlowStateEdgeIDArray)
			{
				var flowObj:FlowObject = this.dropObjectFlowStateCache[flowObjID];
				flowObj.updateOnEdgeChange(this, recursive);
			}
		}
		public function addToFlowStateStore(newDropObjectFlowState:FlowObject):void
		{
			//if we currently have an exact match, skip this
			for(var index:uint = 0; index < dropObjectFlowStateEdgeIDArray.length; index ++)
			{
				var id:uint = dropObjectFlowStateEdgeIDArray[index];
				var flowStateObject:FlowObject = dropObjectFlowStateCache[id];
				if(flowStateObject.compare(newDropObjectFlowState) == true)
					return;
			}
				
			dropObjectFlowStateEdgeIDArray.push(newDropObjectFlowState.objectID);
			dropObjectFlowStateCache[newDropObjectFlowState.objectID] = newDropObjectFlowState;
		}
		
		public function removeFromFlowStateStore(dropObject:FlowObject):void
		{
			var index:uint = dropObjectFlowStateEdgeIDArray.indexOf(dropObject.objectID);
			if(index != -1)
			{
				dropObjectFlowStateEdgeIDArray.splice(index, 1);
				delete dropObjectFlowStateCache[dropObject.objectID];
			}
		}
		
		public function getCurrentFlowObject():FlowObject
		{
			var arrayLength:uint = dropObjectFlowStateEdgeIDArray.length;
			var currentIndex:uint = currentFlowStateObjectIndex;
			
			//resimulation might change the number of flow objects
			if(currentIndex >= arrayLength)
				currentIndex = 0;
			
			currentFlowStateObjectIndex = (currentFlowStateObjectIndex+1) % arrayLength;
			
			var flowObjID:uint = dropObjectFlowStateEdgeIDArray[currentIndex];
			return this.dropObjectFlowStateCache[flowObjID];
		}
		
		//find this edge's flow object with this flow Object as parent
		public function findSimilarFlowObject(flowObject:FlowObject):FlowObject
		{
			for(var index:uint = 0; index < dropObjectFlowStateEdgeIDArray.length; index ++)
			{
				var id:uint = dropObjectFlowStateEdgeIDArray[index];
				var ourFlowObject:FlowObject = dropObjectFlowStateCache[id];
				if(ourFlowObject.parentFlowObject == flowObject)
				{
					return ourFlowObject;
				}
			}
			
			return null;
		}
		
		//loop over flow objects fixing up starting ball types
		public function setStartingBallType():void
		{
			var flowObject:FlowObject;
			if(from_port.node.kind != NodeTypes.SUBBOARD && dropObjectFlowStateEdgeIDArray.length == 0)
			{
				this.createDropObjectFlowArray();	
				flowObject = new FlowObject(this, this); //only get's called for starting edges
				addToFlowStateStore(flowObject);
			}
			else //grab first (and only) existing one
				flowObject = dropObjectFlowStateCache[dropObjectFlowStateEdgeIDArray[0]];

			switch (from_port.node.kind) {
				case NodeTypes.INCOMING: // TODO: not totally clear in this case, just stick to wide for wide, small for small - CC: I think this is right
				case NodeTypes.START_PIPE_DEPENDENT_BALL:
					flowObject.starting_ball_type = is_wide ? VerigameSystem.BALL_TYPE_WIDE : VerigameSystem.BALL_TYPE_NARROW;
					break;					
				case NodeTypes.START_LARGE_BALL:
					flowObject.starting_ball_type = VerigameSystem.BALL_TYPE_WIDE;
					break;
				case NodeTypes.START_NO_BALL:
					flowObject.starting_ball_type = VerigameSystem.BALL_TYPE_NONE;
					break;
				case NodeTypes.START_SMALL_BALL:
					flowObject.starting_ball_type = VerigameSystem.BALL_TYPE_NARROW;
					break;
				default:
					trace("FOUND a " + from_node.kind);
					break;
			}
		}
		
		
		/*This sets up the default exit ball type, which will be modified if there are trouble points along the way */
		public function setExitBallType():Boolean
		{
			for(var index:uint = 0; index<dropObjectFlowStateEdgeIDArray.length; index++)
			{
				var edgeID:String = dropObjectFlowStateEdgeIDArray[index];
				var flowObject:FlowObject = dropObjectFlowStateCache[edgeID];
				
				// Set outgoing ball type
				switch (flowObject.starting_ball_type) {
					case VerigameSystem.BALL_TYPE_NONE:
					case VerigameSystem.BALL_TYPE_GHOST:
						flowObject.exit_ball_type = flowObject.starting_ball_type;
						break;
					case VerigameSystem.BALL_TYPE_WIDE:
					case VerigameSystem.BALL_TYPE_NARROW:
					case VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
						if (has_buzzsaw)
							flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NARROW;
						else
							flowObject.exit_ball_type = flowObject.starting_ball_type;
						break;
					default:
						throw new Error("Flow sensitive Simulator: Ball type not defined - ");
						break;
				}
			}
				
			return true;
		}
		
		public function isStartingEdge():Boolean
		{
			switch (from_node.kind) {
				case NodeTypes.START_LARGE_BALL:
				case NodeTypes.START_NO_BALL:
				case NodeTypes.START_SMALL_BALL:
				case NodeTypes.START_PIPE_DEPENDENT_BALL:
				case NodeTypes.INCOMING:
			//	case NodeTypes.SUBBOARD:
					return true;
					break;
			}
			
			return false;
		}
		

		/*
		clear old (when simulator starts to run) and
		create new Drop Object Info object for the edge
		*/
		public function createDropObjectFlowArray():void
		{
			isStartingNode = true;
			dropObjectFlowStateEdgeIDArray = new Array;
			dropObjectFlowStateCache = new Dictionary;
		}
		
		//returns the active stamps associated with this edge
		protected function getActiveStampVector():Vector.<StampRef> {

			var activeStampVector:Vector.<StampRef> = new Vector.<StampRef>;

			var numActiveStamps:uint = linked_edge_set.num_active_stamps;
			for(var i:uint = 0; i < numActiveStamps; i++)
			{
				var activeStamp:StampRef = linked_edge_set.getActiveStampAt(i);
				activeStampVector[activeStampVector.length] = activeStamp;				
			}
			
			return activeStampVector;
		}
		
		/*
			copy current DropObjectInfo into the new edge, usually from parent to child
		*/
		public function copyDropObjectFlowInfoToEdge(newEdge:Edge = null):void
		{	
			//copy all of parent's drop info object to here
			for(var index:uint = 0; index<dropObjectFlowStateEdgeIDArray.length; index++)
			{
				//create object and then copy over relevant data
				var parentFOEdgeID:String = dropObjectFlowStateEdgeIDArray[index];
				var parentFlowStateObj:FlowObject = dropObjectFlowStateCache[parentFOEdgeID];
				
				//that we get here is probably an error, but for the time being...
				if(parentFlowStateObj.exit_ball_type == VerigameSystem.BALL_TYPE_UNDETERMINED)
				{
					parentFlowStateObj.exit_ball_type = parentFlowStateObj.starting_ball_type;
				}
				//check to make sure both parent and child have flow objects, else copy down
				if(parentFlowStateObj.childrenFlowObjectArray.length == 0 || newEdge.dropObjectFlowStateEdgeIDArray.length == 0)
				{
					var newDropObjectFlowStateObj:FlowObject = parentFlowStateObj.createChildCopy(newEdge);
					newEdge.addToFlowStateStore(newDropObjectFlowStateObj);
				}
				else
				{
					for each(var childFlowObj:FlowObject in parentFlowStateObj.childrenFlowObjectArray)
					{
						childFlowObj._starting_ball_type = parentFlowStateObj.exit_ball_type;
					}
				}
			}
		}
		
		/* check for all edge related trouble spots
			ball and width issues - pinchpoints, buzzsaws
			exit issues -outgoing size compared to next ports
			drop object issues - existing stamps versus allowed ones
		*/
		public function checkForTroubleSpots(resultsDictionary:Dictionary):void
		{
			var listEdgeTroublePointsVector:Vector.<Edge> = resultsDictionary["edge"];
			var listPortTroublePointsVector:Vector.<Port> = resultsDictionary["port"];
			
			if(hasWidthTroubleSpot())
			{
				if (listEdgeTroublePointsVector.indexOf(this) == -1) {
					listEdgeTroublePointsVector.push(this);
				}
			}
			
			var problemPort:Port = hasExitTroubleSpot();
			if(problemPort != null)
			{
				if (listPortTroublePointsVector.indexOf(to_port) == -1) {
					listPortTroublePointsVector.push(to_port); 
				}
				if (listPortTroublePointsVector.indexOf(problemPort) == -1) {
					listPortTroublePointsVector.push(problemPort); 
				}
			}
		}
		
		//check incoming edges vs. outgoing, taking into account buzzsaws and pinch points
		public function hasWidthTroubleSpot():Boolean
		{
			for(var index:uint = 0; index<dropObjectFlowStateEdgeIDArray.length; index++)
			{
				var edgeID:String = dropObjectFlowStateEdgeIDArray[index];
				var flowObject:FlowObject = dropObjectFlowStateCache[edgeID];

				var in_type:uint = flowObject.starting_ball_type;
				var out_type:uint = flowObject.exit_ball_type;
				switch (in_type) {
					case VerigameSystem.BALL_TYPE_WIDE:
					case VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
						if (out_type != VerigameSystem.BALL_TYPE_NARROW)
							if (this.has_pinch)
							{
								flowObject.exit_ball_type =  VerigameSystem.BALL_TYPE_NARROW;
								
								flowObject.updateChildren(true);
								return true;
							}
				}
			}
			return false;
		}
		
		//check outgoing nodes, our ingoing port versus all outgoing ports
		//return outgoing port that we have issues with, or null
		public function hasExitTroubleSpot():Port
		{
			var outgoingNode:Node = this.to_node;
			
			for(var index:uint = 0; index<dropObjectFlowStateEdgeIDArray.length; index++)
			{
				//find my exit ball sizes
				var edgeID:String = dropObjectFlowStateEdgeIDArray[index];
				var flowObject:FlowObject = dropObjectFlowStateCache[edgeID];
				var exitBallType:uint = flowObject.exit_ball_type;

				//check for width issues
				var outgoingPort:Port = hasExitWidthTroubleSpot(outgoingNode, flowObject);
				
				if(outgoingPort != null)
					return outgoingPort;
					
				
				//check for stamp conflicts (i.e. next road has stamps that current car doesn't)
				outgoingPort = hasStampTroubleSpot(outgoingNode, flowObject);
				
				if(outgoingPort != null)
					return outgoingPort;
			}
			return null;
		}
		
		public function hasExitWidthTroubleSpot(outgoingNode:Node, flowObject:FlowObject):Port
		{
			var exitBallType:uint = flowObject.exit_ball_type;

			for(var outgoingPortIndex:uint = 0; outgoingPortIndex<outgoingNode.outgoing_ports.length; outgoingPortIndex++)
			{
				var outgoingPort:Port = outgoingNode.outgoing_ports[outgoingPortIndex];
				
				if(!outgoingPort.edge.is_wide && (exitBallType == VerigameSystem.BALL_TYPE_WIDE))
				{
					var foundProblem:Boolean = false;
					for(var nextEdgeFOIndex:uint = 0; nextEdgeFOIndex<outgoingPort.edge.dropObjectFlowStateEdgeIDArray.length; nextEdgeFOIndex++)
					{
						var nextEdgeFOID:String = outgoingPort.edge.dropObjectFlowStateEdgeIDArray[nextEdgeFOIndex];
						var nextEdgeFOFlowObject:FlowObject = outgoingPort.edge.dropObjectFlowStateCache[nextEdgeFOID];
						//make sure we are dealing with our children only
						if(flowObject.objectID == nextEdgeFOFlowObject.parentFlowObject.objectID)
						{
							if(exitBallType == VerigameSystem.BALL_TYPE_WIDE_AND_NARROW)
							{
								//this state shouldn't exist, but until I'm sure I'll leave it here
								nextEdgeFOFlowObject.starting_ball_type =  VerigameSystem.BALL_TYPE_NARROW;
								foundProblem = true;
							}
							else if(exitBallType == VerigameSystem.BALL_TYPE_WIDE)
							{
								flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NONE;
								nextEdgeFOFlowObject.starting_ball_type =  VerigameSystem.BALL_TYPE_NARROW;
								foundProblem = true;
							}
						}
						
					}
					if(foundProblem)
						return outgoingPort;
				}
			}
			return null;
		}
		
		public function hasStampTroubleSpot(outgoingNode:Node, flowObject:FlowObject):Port
		{
			var objectStampVector:Vector.<StampRef> = flowObject.flowStartingEdge.getActiveStampVector();
			for each(var outgoingPort:Port in outgoingNode.outgoing_ports)
			{
				var edgeStampVector:Vector.<StampRef> = outgoingPort.edge.getActiveStampVector();
				
				//for each stamp on the road, make sure there is a similar one on the object
				for(var index1:uint=0; index1<edgeStampVector.length; index1++)
				{
					var edgeStamp:StampRef = edgeStampVector[index1];
					var found:Boolean = false;
					for(var index2:uint=0; index2<objectStampVector.length; index2++)
					{
						var objectStamp:StampRef = objectStampVector[index2];
						//if the current stamp is active (and it should be) and we find a matching edge set id, and the next stamp is active
						//(it also should be), then check the next case
						if( edgeStamp.edge_set_id == objectStamp.edge_set_id)
						{
							found = true;
							continue;
						}
					}
					if(!found)
					{
						flowObject.exit_ball_type = VerigameSystem.BALL_TYPE_NONE;
						return outgoingPort;
					}
				}
			}
			return null;
		}
		
		//notify prior edge(s) that it needs to redraw (update)
		public function updatePriorEdges():void
		{
			for each(var port:Port in from_node.incoming_ports)
			{
				port.edge.associated_pipe.draw();
			}
		}
		
		public function get midpoint():Point {
			var my_pt:Point = _associated_pipe.getXYbyT(0.5);
			return my_pt;
		}
		
		public function get from_node():Node {
			return from_port.node;
		}
		
		public function get to_node():Node {
			return to_port.node;
		}
		
		public function get from_port_id():String {
			return from_port.port_id;
		}
		
		public function get to_port_id():String {
			return to_port.port_id;
		}
		
	}
}