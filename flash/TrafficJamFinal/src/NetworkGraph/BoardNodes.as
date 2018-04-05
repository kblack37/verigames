package NetworkGraph 
{

	import flash.utils.Dictionary;

	public class BoardNodes
	{
		
		public var board_name:String;
			
		/** This is a dictionary of Nodes; INDEXED BY NODE_ID */
		public var nodeDictionary:Dictionary = new Dictionary();
		
		/** The names of any boards that appear on this board */
		public var subboardNames:Vector.<String> = new Vector.<String>();
		
		/** Any nodes that represent the beginning of a pipe, either INCOMING OR START_* OR SUBBOARD with no incoming edges */
		public var beginningNodes:Vector.<Node> = new Vector.<Node>();
		
		/** Map from edge set id to all starting edges for that edge set ON THIS BOARD (no other boards) */
		public var startingEdgeDictionary:Dictionary = new Dictionary();
		
		/** True if a change in pipe width or buzzsaw was made since the last simulation */
		public var changed_since_last_sim:Boolean = true;
		/** True if a simulation has been run on this board */
		public var simulated:Boolean = false;
		/** True if the board is being checked for trouble points */
		public var simulating:Boolean = false;
		
		public var metadata:Dictionary = new Dictionary();;

		public function BoardNodes(_board_name:String) 
		{
			board_name = _board_name;
		}
		
		public function addNode(_node:Node):void {
			if (nodeDictionary[_node.node_id] == null) {
				nodeDictionary[_node.node_id] = _node;
				switch (_node.kind) {
					case NodeTypes.SUBBOARD:
						if ((_node as SubnetworkNode).subboard_name.length > 0) {
							if (subboardNames.indexOf((_node as SubnetworkNode).subboard_name) == -1) {
								subboardNames.push((_node as SubnetworkNode).subboard_name);
							}
						}
						// If there are no incoming pipes to the subboard, this is a beginning node - fall through to add to beginningNodes list
						if (_node.incoming_ports.length == 0) {
							if (beginningNodes.indexOf(_node) == -1) {
								beginningNodes.push(_node);
							}
						}
					break;
					case NodeTypes.OUTGOING:
						// It is also (apparently) possible for an outgoing node to have no inputs or outputs, this won't actually get processed but include it anyway
						if (_node.incoming_ports.length == 0) {
							if (beginningNodes.indexOf(_node) == -1) {
								beginningNodes.push(_node);
							}
						}
					break;
					case NodeTypes.INCOMING:
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
		 * Adds the input edge and edge set index id pair to the startingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	id An edge set id to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
		public function addStartingEdgeToDictionary(e:Edge, id:String, checkIfExists:Boolean = true):void {
			if (startingEdgeDictionary[id] == null) {
				startingEdgeDictionary[id] = new Vector.<Edge>();
			}
			if ((!checkIfExists) || (startingEdgeDictionary[id].indexOf(e) == -1)) {
				startingEdgeDictionary[id].push(e);
			}
		}
		
	}
}