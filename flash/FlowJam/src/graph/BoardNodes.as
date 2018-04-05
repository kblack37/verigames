package graph 
{

	import flash.utils.Dictionary;

	public class BoardNodes
	{
		/** Board name (may be obfuscated) */
		public var board_name:String;
		
		/** Original board name from XML (unobfuscated) */
		public var original_board_name:String;
		
		/** This is a dictionary of Nodes; INDEXED BY NODE_ID */
		public var nodeDictionary:Dictionary = new Dictionary();
		public var nodeIDArray:Array = new Array;
		
		/** The names of any boards that appear on this board */
		public var subboardNames:Vector.<String> = new Vector.<String>();
		
		/** Any nodes that represent the beginning of a pipe, either INCOMING OR START_* OR SUBBOARD with no incoming edges */
		public var beginningNodes:Vector.<Node> = new Vector.<Node>();
		
		/** Map from edge set id to all starting edges for that edge set ON THIS BOARD (no other boards) */
		private var m_startingEdgeDictionary:Dictionary;
		
		/** Map from edge set id to all OUTGOING edges for that edge set ON THIS BOARD (no other boards) */
		private var m_outgoingEdgeDictionary:Dictionary;
		
		/** True if a change in pipe width or buzzsaw was made since the last simulation */
		public var changed_since_last_sim:Boolean = true;
		/** True if a simulation has been run on this board */
		public var simulated:Boolean = false;
		/** True if the board is being checked for trouble points */
		public var simulating:Boolean = false;
		
		public var metadata:Dictionary = new Dictionary();;
		/** After all BoardNodes are created, we want to associate all SubnetNodes with their appropriate BoardNodes */
		public var subnetNodesToAssociate:Vector.<SubnetworkNode> = new Vector.<SubnetworkNode>();
		
		public var incoming_node:Node;
		public var outgoing_node:Node;
		public var is_stub:Boolean;
		
		public function BoardNodes(_obfuscated_board_name:String, _original_board_name:String, _is_stub:Boolean = false) 
		{
			board_name = _obfuscated_board_name;
			original_board_name = _original_board_name;
			is_stub = _is_stub;
		}
		
		public function addNode(_node:Node):void {
			if (!nodeDictionary.hasOwnProperty(_node.node_id)) {
				nodeDictionary[_node.node_id] = _node;
				nodeIDArray.push(_node.node_id);
				var ip:Port, op:Port;
				switch (_node.kind) {
					case NodeTypes.SUBBOARD:
						if ((_node as SubnetworkNode).subboard_name.length > 0) {
							if (subboardNames.indexOf((_node as SubnetworkNode).subboard_name) == -1) {
								subboardNames.push((_node as SubnetworkNode).subboard_name);
							}
						}
						subnetNodesToAssociate.push(_node as SubnetworkNode);
						if (beginningNodes.indexOf(_node) == -1) {
							beginningNodes.push(_node);
						}
						break;
					case NodeTypes.OUTGOING:
//						if (outgoing_node) {
//							throw new Error("Board found with multiple outgoing nodes: " + original_board_name + " nodes:" + outgoing_node.node_id + " & " + _node.node_id);
//						}
						outgoing_node = _node;
						break;
					case NodeTypes.INCOMING:
//						if (incoming_node) {
//							throw new Error("Board found with multiple incoming nodes: " + original_board_name + " nodes:" + incoming_node.node_id + " & " + _node.node_id);
//						}
						incoming_node = _node;
						// intentional fall-thru (no break)
					case NodeTypes.START_LARGE_BALL:
					case NodeTypes.START_NO_BALL:
					case NodeTypes.START_PIPE_DEPENDENT_BALL:
					case NodeTypes.START_SMALL_BALL:
						if (beginningNodes.indexOf(_node) == -1) {
							beginningNodes.push(_node);
						}
						break;
				}
			} else {
				throw new Error("Duplicate world nodes found for node_id: " + _node.node_id);
			}
		}
		
		/**
		 * Adds the input edge and edge set index id pair to the m_startingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
		private function addStartingEdgeToDictionary(e:Edge, checkIfExists:Boolean = true):void {
			var id:String = e.linked_edge_set.id;
			if (m_startingEdgeDictionary[id] == null) {
				m_startingEdgeDictionary[id] = new Vector.<Edge>();
			}
			if ((!checkIfExists) || (m_startingEdgeDictionary[id].indexOf(e) == -1)) {
				m_startingEdgeDictionary[id].push(e);
			}
		}
		
		/**
		 * Adds the input edge and edge set index id pair to the outgoingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
		private function addOutgoingEdgeToDictionary(e:Edge, checkIfExists:Boolean = true):void {
			var id:String = e.linked_edge_set.id;
			if (m_outgoingEdgeDictionary[id] == null) {
				m_outgoingEdgeDictionary[id] = new Vector.<Edge>();
			}
			if ((!checkIfExists) || (m_outgoingEdgeDictionary[id].indexOf(e) == -1)) {
				m_outgoingEdgeDictionary[id].push(e);
			}
		}
		
		private var m_stubInputWidthsByPort:Dictionary = new Dictionary();
		private var m_stubOutputWidthsByPort:Dictionary = new Dictionary();
		public function addStubBoardPortWidth(_port_num:String, _stub_width:String, _is_input:Boolean):void
		{
			_stub_width = _stub_width.toLowerCase();
			if ((_stub_width != "narrow") && (_stub_width != "wide")) {
				throw new Error("Illegal stub width found ('" + _stub_width + "') for board:" + original_board_name + " port_num:" + _port_num);
			}
			if (_is_input) {
				if (m_stubInputWidthsByPort.hasOwnProperty(_port_num)) {
					throw new Error("Duplicate stub inputs found for board:" + original_board_name + " port_num:" + _port_num);
				}
				m_stubInputWidthsByPort[_port_num] = _stub_width;
			} else {
				if (m_stubOutputWidthsByPort.hasOwnProperty(_port_num)) {
					throw new Error("Duplicate stub outputs found for board:" + original_board_name + " port_num:" + _port_num);
				}
				m_stubOutputWidthsByPort[_port_num] = _stub_width;
			}
		}
		
		public function getStubBoardPortWidth(_port_num:String, _is_input:Boolean):String
		{
			if (_is_input) {
				if (!m_stubInputWidthsByPort.hasOwnProperty(_port_num)) return null;
				return m_stubInputWidthsByPort[_port_num] as String;
			} else {
				if (!m_stubOutputWidthsByPort.hasOwnProperty(_port_num)) return null;
				return m_stubOutputWidthsByPort[_port_num] as String;
			}
		}
		
		public function get startingEdgeDictionary():Dictionary
		{
			if (m_startingEdgeDictionary == null) {
				m_startingEdgeDictionary = new Dictionary();
				for (var i:int = 0; i < beginningNodes.length; i++) {
					var begNode:Node = beginningNodes[i];
					for (var j:int = 0; j < begNode.outgoing_ports.length; j++) {
						var begport:Port = begNode.outgoing_ports[j];
						addStartingEdgeToDictionary(begport.edge);
					}
				}
			}
			return m_startingEdgeDictionary;
		}
		
		public function get outgoingEdgeDictionary():Dictionary
		{
			if (m_outgoingEdgeDictionary == null) {
				m_outgoingEdgeDictionary = new Dictionary();
				if (outgoing_node) {
					for (var i:int = 0; i < outgoing_node.incoming_ports.length; i++) {
						var outport:Port = outgoing_node.incoming_ports[i];
						addOutgoingEdgeToDictionary(outport.edge);
					}
				}
			}
			return m_outgoingEdgeDictionary;
		}
		
	}
}