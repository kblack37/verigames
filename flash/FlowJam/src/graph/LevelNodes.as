package graph 
{

	import flash.utils.Dictionary;
	import utils.NameObfuscater;
	
	public class LevelNodes
	{
		
		public var level_name:String;
		public var original_level_name:String;
		private var m_obfuscator:NameObfuscater;
		
		public var metadata:Dictionary = new Dictionary();
		// Edge set id -> Edge set ref
		public var edge_set_dictionary:Dictionary;
		
		/** This is a dictionary of BoardNodes, which is a dictionary of Nodes; INDEXED BY BOARD NAME AND NODE ID, RESPECTIVELY */
		public var boardNodesDictionary:Dictionary = new Dictionary();
		/** This is a dictionary of Node's indexed by nodeID - so that nodes may be looked up without needing board information */
		public var nodeIdToNodeDictionary:Dictionary = new Dictionary();
		public var edgeIdToEdgeDictionary:Dictionary = new Dictionary();
		public var qid:int = -1;
		
		public function LevelNodes(_original_level_name:String, _obfuscater:NameObfuscater = null, _edge_set_dictionary:Dictionary = null) 
		{
			original_level_name = _original_level_name;
			m_obfuscator = _obfuscater;
			if (m_obfuscator) {
				level_name = m_obfuscator.getLevelName(_original_level_name);
			} else {
				level_name = _original_level_name;
			}
			edge_set_dictionary = _edge_set_dictionary;
			if (edge_set_dictionary == null) edge_set_dictionary = new Dictionary();
		}
		
		public function addNode(_node:Node, _original_board_name:String):void {
			var new_board_name:String = _original_board_name;
			if (m_obfuscator) {
				new_board_name = m_obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			if (boardNodesDictionary[new_board_name] == null) {
				boardNodesDictionary[new_board_name] = new BoardNodes(new_board_name, _original_board_name);
			}
			if (nodeIdToNodeDictionary.hasOwnProperty(_node.node_id)) {
				throw new Error("Duplicate nodes found for node_id: " + _node.node_id);
			}
			nodeIdToNodeDictionary[_node.node_id] = _node;
			(boardNodesDictionary[new_board_name] as BoardNodes).addNode(_node);
		}
		
		public function addEdge(_edge:Edge):void {
			if (edgeIdToEdgeDictionary.hasOwnProperty(_edge.edge_id)) {
				throw new Error("Duplicate edges found for edge_id: " + _edge.edge_id);
			}
			edgeIdToEdgeDictionary[_edge.edge_id] = _edge;
		}
		
		
		public function addStubBoardPortWidth(_original_board_name:String, _port_num:String, _stub_width:String, _is_input:Boolean):void
		{
			var new_board_name:String = _original_board_name;
			if (m_obfuscator) {
				new_board_name = m_obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			if (boardNodesDictionary[new_board_name] == null) {
				boardNodesDictionary[new_board_name] = new BoardNodes(new_board_name, _original_board_name, true);
			}
			if (!(boardNodesDictionary[new_board_name] as BoardNodes).is_stub) {
				throw new Error("Attempting to add stub width to non-stub board: " + _original_board_name + " (port: " + _port_num + ")");
			}
			(boardNodesDictionary[new_board_name] as BoardNodes).addStubBoardPortWidth(_port_num, _stub_width, _is_input);
		}
		
		public function getStubBoardPortWidth(_original_board_name:String, _port_num:String, _is_input:Boolean):String
		{
			var new_board_name:String = _original_board_name;
			if (m_obfuscator) {
				new_board_name = m_obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			if (!boardNodesDictionary.hasOwnProperty(new_board_name)) return null;
			return (boardNodesDictionary[new_board_name] as BoardNodes).getStubBoardPortWidth(_port_num, _is_input);
		}
		
		public function getEdge(_edge_id:String):Edge
		{
			return edgeIdToEdgeDictionary[_edge_id] as Edge;
		}
		
		public function getBoardNodes(_original_board_name:String):BoardNodes {
			var new_board_name:String = _original_board_name;
			if (m_obfuscator) {
				new_board_name = m_obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			return boardNodesDictionary[new_board_name];
		}
		
		public function getNode(_node_id:String):Node
		{
			return nodeIdToNodeDictionary[_node_id] as Node;
		}
		
		//public function getNode(_original_board_name:String, _node_id:String):Node {
			//var new_board_name:String = _original_board_name;
			//if (m_obfuscator) {
				//new_board_name = m_obfuscator.getBoardName(_original_board_name, original_level_name);
			//}
			//if (boardNodesDictionary[new_board_name] != null) {
				//return (boardNodesDictionary[new_board_name] as BoardNodes).nodeDictionary[_node_id];
			//}
			//return null;
		//}
		
		public function associateSubnetNodesToBoardNodes():void
		{
			for (var boardName:String in boardNodesDictionary) {
				var boardNodes:BoardNodes = boardNodesDictionary[boardName];
				var remainingNodes:Vector.<SubnetworkNode> = new Vector.<SubnetworkNode>();
				for each (var subnetNodeToFinish:SubnetworkNode in boardNodes.subnetNodesToAssociate) {
					var obsName:String = m_obfuscator.getBoardName(subnetNodeToFinish.subboard_name, original_level_name);
					if (obsName && boardNodesDictionary.hasOwnProperty(obsName)) {
						var foundBoardNodes:BoardNodes = boardNodesDictionary[obsName] as BoardNodes;
						subnetNodeToFinish.associated_board = foundBoardNodes;
						subnetNodeToFinish.associated_board_is_external = false;
					} else {
						// Must be external, keep as unassociated
						remainingNodes.push(subnetNodeToFinish);
					}
				}
				boardNodes.subnetNodesToAssociate = remainingNodes;
			}
		}
		
		public function clone():LevelNodes
		{
			return this;
		}
		
	}

}