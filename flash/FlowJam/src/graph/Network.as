package graph 
{
	import utils.NameObfuscater;
	import utils.XString;
	
	import flash.utils.Dictionary;
	
	public class Network 
	{
		/**
		 * Collection of Nodes (and their associated edges contained within) arranged by level. This is what is created by LevelLayout when after XML input is processed.
		 */
		public var world_name:String;
		public var original_world_name:String;
		public var world_version:String;
		public var obfuscator:NameObfuscater;
		
		/** This is a dictionary of LevelNodes, which is a dictionary of BoardNodes, which is a dictionary of Nodes; INDEXED BY LEVEL NAME, BOARD NAME, AND NODE ID, RESPECTIVELY */
		public var LevelNodesDictionary:Dictionary = new Dictionary();
		public var levelNodeNameArray:Array = new Array();
		public var globalBoardNameToBoardNodesDictionary:Dictionary = new Dictionary();
		// BEGIN XML v3 dicts //
		public var globalEdgeIdToEdgeSetDictionary:Dictionary = new Dictionary();
		private var m_varIdSetIdToEdgeSetDictionary:Dictionary = new Dictionary();
		private var m_variableIDToVarIdSetIdDictionary:Dictionary = new Dictionary();
		// END XML v3 dicts //
		
		public function Network(_original_world_name:String, _world_version:String, _world_index:uint = 1, _obfuscate_names:Boolean = true) 
		{
			original_world_name = _original_world_name;
			world_version = _world_version;
			if (_obfuscate_names) {
				world_name = "World " + _world_index;
				var my_seed:int = XString.stringToInt(world_name);
				obfuscator = new NameObfuscater(my_seed);
			} else {
				world_name = _original_world_name;
			}
		}
		
		public function addLinkedVariableId(variable_id:String, variable_id_set:String):void
		{
			if (!m_varIdSetIdToEdgeSetDictionary.hasOwnProperty(variable_id_set)) {
				m_varIdSetIdToEdgeSetDictionary[variable_id_set] = new EdgeSetRef(variable_id_set);
			}
			if (m_variableIDToVarIdSetIdDictionary.hasOwnProperty(variable_id)) return;
			m_variableIDToVarIdSetIdDictionary[variable_id] = variable_id_set;
		}
		
		public function addEdge(edge_id:String, variable_id:String):void
		{
			if (!m_variableIDToVarIdSetIdDictionary.hasOwnProperty(variable_id)) {
				if (variable_id.indexOf(Constants.XML_ANNOT_NEG) == 0) {
					variable_id_set = variable_id;
				} else {
					variable_id_set = variable_id + "_varIDset";
				}
				m_variableIDToVarIdSetIdDictionary[variable_id] = variable_id_set;
			}
			var variable_id_set:String = m_variableIDToVarIdSetIdDictionary[variable_id];
			if (!m_varIdSetIdToEdgeSetDictionary.hasOwnProperty(variable_id_set)) {
				m_varIdSetIdToEdgeSetDictionary[variable_id_set] = new EdgeSetRef(variable_id_set);
			}
			var edge_set_ref:EdgeSetRef = m_varIdSetIdToEdgeSetDictionary[variable_id_set];
			globalEdgeIdToEdgeSetDictionary[edge_id] = edge_set_ref;
		}
		
		public function addLevel(level:LevelNodes):void
		{
			//if (LevelNodesDictionary[level.level_name] == null) {
				LevelNodesDictionary[level.level_name] = level;
				levelNodeNameArray.push(level.level_name);
				for (var obfusBoardName:String in level.boardNodesDictionary) {
					var boardNodes:BoardNodes = level.boardNodesDictionary[obfusBoardName];
					if (globalBoardNameToBoardNodesDictionary.hasOwnProperty(boardNodes.original_board_name)) {
						throw new Error("Duplicate board name found for level: " + level.original_level_name + " board:" + boardNodes.original_board_name);
					}
					globalBoardNameToBoardNodesDictionary[boardNodes.original_board_name] = boardNodes;
				}
//			} else {
//				throw new Error("Duplicate Level entries found for level: " + level.original_level_name);
//			}
		}
		
		public function attachExternalSubboardNodesToBoardNodes():void
		{
			for (var levelName:String in LevelNodesDictionary) {
				var levelNodes:LevelNodes = LevelNodesDictionary[levelName] as LevelNodes;
				for (var boardName:String in levelNodes.boardNodesDictionary) {
					var boardNodes:BoardNodes = levelNodes.boardNodesDictionary[boardName] as BoardNodes;
					for each (var externalSubnetNode:SubnetworkNode in boardNodes.subnetNodesToAssociate) {
						externalSubnetNode.associated_board_is_external = true;
						if (globalBoardNameToBoardNodesDictionary.hasOwnProperty(externalSubnetNode.subboard_name)) {
							externalSubnetNode.associated_board = globalBoardNameToBoardNodesDictionary[externalSubnetNode.subboard_name] as BoardNodes;
						} else {
							// If the board doesn't exist in this world, mark as null
							externalSubnetNode.associated_board = null;
						}
					}
					boardNodes.subnetNodesToAssociate = new Vector.<SubnetworkNode>();
				}
			}
		}
		
		public function getNode(_original_level_name:String, _original_board_name:String, _node_id:String):Node {
			var new_level_name:String = obfuscator.getLevelName(_original_level_name);
			var new_board_name:String = obfuscator.getBoardName(_original_board_name, _original_level_name);
			if (LevelNodesDictionary[new_level_name] != null) {
				if ((LevelNodesDictionary[new_level_name] as LevelNodes).boardNodesDictionary[new_board_name] != null) {
					return ((LevelNodesDictionary[new_level_name] as LevelNodes).boardNodesDictionary[new_board_name] as BoardNodes).nodeDictionary[_node_id];
				}
			}
			return null;
		}
		
		/**
		 * Returns the board in this world of the given name
		 * @param	_name Name of the desired board
		 * @return The board with the name input to this function
		 */
		public function getOriginalBoardName(_name:String):String {
			if (_name == null) {
				return null;
			}
			if (_name.length == 0) {
				return null;
			}
			var new_name:String = _name;
			if (obfuscator) {
				if (obfuscator.boardNameExists(_name)) {
					new_name = obfuscator.getBoardName(_name, "");
				} else {
					return null;
				}
			}
			
			return new_name;
		}
	}

}