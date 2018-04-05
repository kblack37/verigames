package graph
{
	import events.ConflictChangeEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import events.EdgePropChangeEvent;
	import graph.Node;
	import utils.Metadata;
	
	/**
	 * Directed Edge created when a graph structure is read in from XML.
	 */
	public class Edge extends EventDispatcher
	{
		// ### BALL_TYPES ### \\
		//renumbered so you can now BIT AND these together, as needed.
		//Now you can & STARRED with the other types
		//Left wide_and_narrow combination so I don't have to rework code
		public static const BALL_TYPE_NONE:uint 			= 0;
		public static const BALL_TYPE_NARROW:uint 			= 1;
		public static const BALL_TYPE_WIDE:uint 			= 2;
		public static const BALL_TYPE_WIDE_AND_NARROW:uint 	= 3;
		public static const BALL_TYPE_STARRED:uint 			= 4;
		public static const BALL_TYPE_UNDETERMINED:uint 	= 8;
		public static const BALL_TYPE_GHOST:uint 			= 16; // used for recursion
		// ### END BALL_TYPES ### \\

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
		
		/** True if edge has attribute buzzsaw="true" in XML, false otherwise */
		public var has_buzzsaw:Boolean = false;
		
		/** True if this edge contains a pinch point, false otherwise */
		public var has_pinch:Boolean = false;
		
		/** used to mark nodes that think they are starting nodes, and we check later if they actually are. 
		 I think this is only a situation that arises on mismade boards (like some I hand created) but I'll handle the case anyway as it helps with debugging
		*/
		public var isStartingNode:Boolean;		
		
		// The following five vars are used to plug in the PipeSimulator and detecting ball type changes:
		private var m_enter_ball_type:uint = BALL_TYPE_UNDETERMINED;
		private var m_exit_ball_type:uint = BALL_TYPE_UNDETERMINED;
		private var m_prev_enter_ball_type:uint = BALL_TYPE_UNDETERMINED;
		private var m_prev_exit_ball_type:uint = BALL_TYPE_UNDETERMINED;
		
		// Testbed:
		private var m_enterProps:PropDictionary = new PropDictionary();
		private var m_exitProps:PropDictionary = new PropDictionary();
		private var m_conflictProps:PropDictionary = new PropDictionary();
		
		/**
		 * Directed Edge created when a graph structure is read in from XML.
		 * @param	_from_node Source node
		 * @param	_from_port Port on source node
		 * @param	_to_node Destination node
		 * @param	_to_port Port on destination node
		 * @param	_metadata Extra information about this edge (for example: any attributes in the original XML object)
		 */
		public function Edge(_from_node:Node, _from_port_id:String, _to_node:Node, _to_port_id:String, _linked_edge_set:EdgeSetRef = null, _metadata:Object = null)
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
				if (String(_metadata.data.id).length > 0) {
					edge_id = String(_metadata.data.id);
				}
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
				if (!linked_edge_set.propsInitialized) {
					linked_edge_set.editable = editable;
				} else if (linked_edge_set.editable != editable) {
					trace("WARNING! Edge doesn't match linked edge set, edge_id " + edge_id + " editable:" + editable + ", edge_set_id:" + linked_edge_set.id + " editable:" + linked_edge_set.editable);
					editable = linked_edge_set.editable; // force this edge to match edge set
				}
				if (String(metadata.data.width).toLowerCase() == "wide") {
					starting_is_wide = true;
				}
				if (!linked_edge_set.propsInitialized) {
					linked_edge_set.setProp(PropDictionary.PROP_NARROW, !starting_is_wide);
				} else if (linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW) == starting_is_wide) {
					trace("WARNING! Edge doesn't match linked edge set, edge_id " + edge_id + " narrow?:" + !starting_is_wide + ", edge_set_id:" + linked_edge_set.id + " narrow?:" + linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW));
					starting_is_wide = !linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW); // force this edge to match edge set
				}
				linked_edge_set.propsInitialized = true;
				/*
				// Flow Jam: IGNORE BUZZSAW ANNOTATIONS
				if (String(metadata.data.buzzsaw).toLowerCase() == "true") {
					starting_has_buzzsaw = true;
					has_buzzsaw = true;
				}
				*/
			}
			
			metadata = null;
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
		
		public function get enter_ball_type():uint
		{
			return m_enter_ball_type;
		}
		
		public function get exit_ball_type():uint
		{
			return m_exit_ball_type;
		}
		
		public function set enter_ball_type(typ:uint):void
		{
			if (ballUnknown(typ) && !ballUnknown(m_enter_ball_type)) {
				// If setting a ball to be UNDETERMINED/GHOST to begin sim, keep previous type to compare after sim
				m_prev_enter_ball_type = m_enter_ball_type;
				m_enter_ball_type = typ;
			} else if (!ballUnknown(typ)) {
				// If setting a type to a KNOWN ball type (done simulating, for example) record change
				m_enter_ball_type = typ;
				if (m_prev_enter_ball_type != m_enter_ball_type) {
					dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.ENTER_BALL_TYPE_CHANGED, this, null, null, m_prev_enter_ball_type, m_enter_ball_type));
				}
				m_prev_enter_ball_type = m_enter_ball_type;
			} else {
				// Was unknown, still unknown - simply make the change
				m_enter_ball_type = typ;
			}
		}
		
		public function set exit_ball_type(typ:uint):void
		{
			if (ballUnknown(typ) && !ballUnknown(m_exit_ball_type)) {
				// If setting a ball to be UNDETERMINED/GHOST to begin sim, keep previous type to compare after sim
				m_prev_exit_ball_type = m_exit_ball_type;
				m_exit_ball_type = typ;
			} else if (!ballUnknown(typ)) {
				// If setting a type to a KNOWN ball type (done simulating, for example) record change
				m_exit_ball_type = typ;
				if (m_prev_exit_ball_type != m_exit_ball_type) {
					dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.EXIT_BALL_TYPE_CHANGED, this, null, null, m_prev_exit_ball_type, m_exit_ball_type));
				}
				m_prev_exit_ball_type = m_exit_ball_type;
			} else {
				// Was unknown, still unknown - simply make the change
				m_exit_ball_type = typ;
			}
		}
		
		// Set this edge to UNDETERMINED and outgoing Edge's
		public function resetPropsAndRecurse():void
		{
			m_enterProps = new PropDictionary();
			m_exitProps = new PropDictionary();
			//m_conflictProps = new PropDictionary();
			if ((m_enter_ball_type == BALL_TYPE_UNDETERMINED) && (m_exit_ball_type == BALL_TYPE_UNDETERMINED)) {
				return;
			}
			m_enter_ball_type = BALL_TYPE_UNDETERMINED;
			m_exit_ball_type = BALL_TYPE_UNDETERMINED;
			for each (var outport:Port in to_port.node.outgoing_ports) {
				outport.edge.resetPropsAndRecurse();
			}
		}
		
		public function addConflict(prop:String):void
		{
			if (hasConflictProp(prop)) return;
			m_conflictProps.setProp(prop, true);
			dispatchEvent(new ConflictChangeEvent());
		}
		
		public function removeConflict(prop:String):void
		{
			if (!hasConflictProp(prop)) return;
			m_conflictProps.setProp(prop, false);
			dispatchEvent(new ConflictChangeEvent());
		}
		
		private function ballUnknown(typ:uint):Boolean
		{
			switch (typ) {
				case BALL_TYPE_UNDETERMINED:
				case BALL_TYPE_GHOST:
					return true;
			}
			return false;
		}
		
		public function get is_wide():Boolean
		{
			return !linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW);
		}
		
		/**
		 * Traverse upsteam returning any editable edge sets that may have set the desired property/value
		 * combination for this edge (the edge set of the starting edges that this edge originated
		 * from)
		 * @param	prop Property of intereset
		 * @param	value Value of property of interest
		 * @return List of editable starting edgeSets upstream matching desired prop, value
		 */
		public function getOriginatingEdgeSetsMatchingPropValue(prop:String, value:Boolean):Vector.<EdgeSetRef>
		{
			var edgeSets:Vector.<EdgeSetRef> = new Vector.<EdgeSetRef>();
			var edgesToExamine:Vector.<Edge> = new Vector.<Edge>();
			var edgesExamined:Dictionary = new Dictionary();
			edgesToExamine.push(this);
			while (edgesToExamine.length > 0) {
				var thisEdge:Edge = edgesToExamine.shift();
				if (edgesExamined.hasOwnProperty(thisEdge.edge_id)) continue;
				edgesExamined[thisEdge.edge_id] = true;
				if (!thisEdge.from_node) continue;
				// Test for originating set and matching this prop
				if (thisEdge.from_node.isOriginationNode && 
				    thisEdge.linked_edge_set.editable &&
				    (thisEdge.linked_edge_set.getProps().hasProp(prop) == value) &&
					(edgeSets.indexOf(thisEdge.linked_edge_set) == -1))
				{
					edgeSets.push(thisEdge.linked_edge_set);
				}
				var nextPorts:Vector.<Port> = thisEdge.from_node.incoming_ports;
				if (thisEdge.from_port is SubnetworkPort) {
					// Connect through subnet if possible, otherwise don't bother
					var subnetPort:SubnetworkPort = thisEdge.from_port as SubnetworkPort;
					nextPorts = new Vector.<Port>();
					if (subnetPort && subnetPort.linked_subnetwork_edge && subnetPort.linked_subnetwork_edge.to_port) nextPorts.push(subnetPort.linked_subnetwork_edge.to_port);
				}
				for (var i:int = 0; i < nextPorts.length; i++) {
					var nextEdge:Edge = nextPorts[i].edge;
					if (!nextEdge) continue;
					if (nextEdge.getExitProps().hasProp(prop) != value) continue;
					// Only continue upstream thru value or argument (if keyfor)
					if (thisEdge.from_node.kind == NodeTypes.GET) {
						var map:MapGetNode = thisEdge.from_node as MapGetNode;
						if ((nextEdge == map.mapEdge) || (nextEdge == map.keyEdge)) continue;
						if ((prop == PropDictionary.PROP_NARROW) && (nextEdge != map.valueEdge)) continue;
						if ((prop == PropDictionary.PROP_NARROW) && !map.argumentHasMapStamp()) continue;
					}
					if (edgesExamined.hasOwnProperty(nextEdge.edge_id)) continue;
					edgesToExamine.push(nextEdge);
				}
			}
			return edgeSets;
		}
		
		/**
		 * Traverse down the edge and out_node, continuing through any edges originating in an edge-set
		 * traversed, return any editable edgeSets matching desired prop, value
		 * @param	prop Property of intereset
		 * @param	value Value of property of interest
		 * @return List of editable edgeSets matching desired prop, value
		 */
		public function getDownStreamEdgeSetsMatchingPropValue(prop:String, value:Boolean, levelName:String):Vector.<EdgeSetRef>
		{
			var edgeSets:Vector.<EdgeSetRef> = new Vector.<EdgeSetRef>();
			var edgesToExamine:Vector.<Edge> = new Vector.<Edge>();
			var edgesExamined:Dictionary = new Dictionary();
			edgesToExamine.push(this);
			while (edgesToExamine.length > 0) {
				var thisEdge:Edge = edgesToExamine.shift();
				if (edgesExamined.hasOwnProperty(thisEdge.edge_id)) continue;
				edgesExamined[thisEdge.edge_id] = true;
				if (!thisEdge.linked_edge_set.editable) continue;
				if (!thisEdge.linked_edge_set.getProps().hasProp(prop) == value) continue;
				// Special case: skip pinched edges, they are essentially uneditable
				if (thisEdge.has_pinch && (prop == PropDictionary.PROP_NARROW)) continue;
				if (edgeSets.indexOf(thisEdge.linked_edge_set) == -1) {
					edgeSets.push(thisEdge.linked_edge_set);
					// Continue with any edges originating from this edge set
					var levelEdges:Vector.<Edge> = thisEdge.linked_edge_set.getLevelEdges(levelName);
					for (var oe:int = 0; oe < levelEdges.length; oe++) {
						var outEdge:Edge = levelEdges[oe];
						if (!outEdge) continue;
						if (!outEdge.isStartingEdge()) continue;
						if (edgesExamined.hasOwnProperty(outEdge.edge_id)) continue;
						edgesToExamine.push(outEdge);
					}
				}
				// Continue through to_node
				var toNode:Node = thisEdge.to_node;
				if (!toNode) continue;
				// Special cases: GET/SUBBOARD stop downstream traversal for most cases
				var nextPorts:Vector.<Port> = toNode.outgoing_ports;
				var map:MapGetNode = null;
				switch (toNode.kind) {
					// Continue to connecting INCOMING edge if possible, otherwise don't continue
					case NodeTypes.SUBBOARD:
						nextPorts = new Vector.<Port>();
						if (thisEdge.to_port is SubnetworkPort) {
							var subnetPort:SubnetworkPort = thisEdge.to_port as SubnetworkPort;
							if (subnetPort.linked_subnetwork_edge && subnetPort.linked_subnetwork_edge.from_port) {
								nextPorts.push(subnetPort.linked_subnetwork_edge.from_port);
							}
						}
						break;
					// Only continue upstream thru value or argument (if keyfor)
					case NodeTypes.GET:
						map = toNode as MapGetNode;
						break;
				}
				for (var op:int = 0; op < nextPorts.length; op++) {
					var nextEdge:Edge = nextPorts[op].edge;
					if (!nextEdge) continue;
					// Skip mapget node for most cases
					if (map && (nextEdge == map.mapEdge)) continue;
					if (map && (nextEdge == map.keyEdge)) continue;
					if (map && !map.argumentHasMapStamp()) continue;
					if (edgesExamined.hasOwnProperty(nextEdge.edge_id)) continue;
					edgesToExamine.push(nextEdge);
				}
			}
			return edgeSets;
		}
		
		public function setEnterProps(props:PropDictionary):void
		{
			dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.ENTER_PROPS_CHANGED, this, m_enterProps.clone(), props.clone()));
			m_enterProps = props.clone();
		}
		
		public function setExitProps(props:PropDictionary):void
		{
			dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.EXIT_PROPS_CHANGED, this, m_exitProps.clone(), props.clone()));
			m_exitProps = props.clone();
		}
		
		public function getEnterProps():PropDictionary
		{
			return m_enterProps;
		}
		
		public function getExitProps():PropDictionary
		{
			return m_exitProps;
		}
		
		public function getConflictProps():PropDictionary
		{
			return m_conflictProps;
		}
		
		// Testbed:
		public function hasConflictProp(prop:String):Boolean
		{
			return m_conflictProps.hasProp(prop);
		}
		
		public function hasAnyConflict():Boolean
		{
			for (var prop:String in m_conflictProps.iterProps()) {
				return true;
			}
			return false;
		}
		
	}
}