package NetworkGraph 
{

	import flash.utils.Dictionary;
	import Utilities.NameObfuscater;
	
	public class LevelNodes
	{
		
		public var level_name:String;
		public var original_level_name:String;
		private var obfuscator:NameObfuscater;
		
		public var metadata:Dictionary = new Dictionary();
		
		/** This is a dictionary of BoardNodes, which is a dictionary of Nodes; INDEXED BY BOARD NAME AND NODE ID, RESPECTIVELY */
		public var boardNodesDictionary:Dictionary = new Dictionary();
			
		public function LevelNodes(_original_level_name:String, _obfuscater:NameObfuscater = null) 
		{
			original_level_name = _original_level_name;
			obfuscator = _obfuscater;
			if (obfuscator) {
				level_name = obfuscator.getLevelName(_original_level_name);
			} else {
				level_name = _original_level_name;
			}
		}
		
		public function addNode(_node:Node, _original_board_name:String):void {
			var new_board_name:String = _original_board_name;
			if (obfuscator) {
				new_board_name = obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			if (boardNodesDictionary[new_board_name] == null) {
				boardNodesDictionary[new_board_name] = new BoardNodes(new_board_name);
			}
			(boardNodesDictionary[new_board_name] as BoardNodes).addNode(_node);
		}
		
		public function getDictionary(_original_board_name:String):BoardNodes {
			var new_board_name:String = _original_board_name;
			if (obfuscator) {
				new_board_name = obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			 return boardNodesDictionary[new_board_name];
		}
		
		public function getNode(_original_board_name:String, _node_id:String):Node {
			var new_board_name:String = _original_board_name;
			if (obfuscator) {
				new_board_name = obfuscator.getBoardName(_original_board_name, original_level_name);
			}
			if (boardNodesDictionary[new_board_name] != null) {
				return (boardNodesDictionary[new_board_name] as BoardNodes).nodeDictionary[_node_id];
			}
			return null;
		}
		
	}

}