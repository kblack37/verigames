package System 
{	
	import NetworkGraph.BoardNodes;
	
	import NetworkGraph.Edge;
	import NetworkGraph.FlowObject;
	import NetworkGraph.MapGetNode;
	import NetworkGraph.Node;
	import NetworkGraph.NodeTypes;
	import NetworkGraph.Port;
	import NetworkGraph.SubnetworkNode;
	import NetworkGraph.SubnetworkPort;
	
	import VisualWorld.Ball;
	import VisualWorld.Board;
	import VisualWorld.Level;
	import VisualWorld.MapGet;
	import VisualWorld.Pipe;
	import VisualWorld.TroublePoint;
	import VisualWorld.VerigameSystem;
	import VisualWorld.World;
	
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.operations.PasteOperation;
	
	import mx.events.PropertyChangeEvent;
	
	import org.osmf.elements.F4MElement;
	
	/**
	 * The Simulator class calculates and stores where trouble points
	 * can occur in the game, based on the current pipe configuration.
	 * 
	 * Trouble points can be either Nodes or Edges. 
	 * 
	 * A trouble point Node can be, for example, a MERGE node where a wide
	 * pipe flows into a narrow pipe.
	 * 
	 * A trouble edge can be, for example, an edge on a wide chute with a 
	 * pinch point. Other trouble edges can happen flowing into and flowing
	 * out of subnetworks. 
	 * 
	 * @author Steph
	 */
	public class Simulator 
	{
		// If true, the pipes will be marked as failed or succeeded as the simulator makes the determination (as opposed to doing so outside of the simulator)
		public static const MARK_PIPES_FAILED_OR_SUCCEEDED:Boolean = false;
		
		/* The world in which the Simulator detects trouble points */
		private var world:World;
		
		/* A map from level to a list that contains the trouble points 
		 * associated with that level. 
		 * 
		 * The list has exactly two elements. The first element is a list 
		 * of Port trouble points. The second is a list of Edge trouble points.
		 */
		private var levelToTroublePoints:Dictionary;
		private var boardToTroublePoints:Dictionary;
		
		//private var listNodeTroublePoints:Vector.<Node>;
		public var listPortTroublePoints:Vector.<Port>;
		public var listEdgeTroublePoints:Vector.<Edge>;
				
		private var edgeList:Dictionary = new Dictionary;
		
		/* The constuctor takes a World and runs and necessary initial computation. 
		 * 
		 * @param: _world, the current world in which the Simulator will detect trouble points
		 */
		public function Simulator(_world:World) 
		{
			world = _world;
			levelToTroublePoints = new Dictionary();
			boardToTroublePoints = new Dictionary();
		}
		
		/* Takes a given level and returns a two element list of the trouble points
		 * associated with that level. The first element is a list of the Node trouble
		 * points. The second is a list of Edge trouble points.
		 * 
		 * @param: level
		 * @returns: a two element list (list of Port trouble points, list of Edge trouble points)
		 */
		public function getAllTroublePoints(level:Level):Array {
			return levelToTroublePoints[level];
		}
		
		public function getAllTroublePointsByBoardName(name:String):Dictionary {
			return boardToTroublePoints[name];
		}
		
		public function updateOnPipeClickFlowSens(edgeSetId:String, boardNodes:Dictionary): Vector.<BoardNodes>
		{
			var boards_in_prog:Vector.<BoardNodes> = new Vector.<BoardNodes>();
			var boards_touched:Vector.<BoardNodes> = new Vector.<BoardNodes>();
			for each (var boardNode:BoardNodes in boardNodes) {
				boardNode.changed_since_last_sim = true;
				boardToTroublePoints[boardNode.board_name] = simulateFlowSensitiveAlg(boardNode, boards_in_prog, boards_touched);
			}
			return boards_touched;
		}

		public function simulateSubNetwork(e:Edge, boards_in_progress:Vector.<BoardNodes>, recursive_boards:Vector.<BoardNodes>,
										 										boards_touched:Vector.<BoardNodes>, simulate_recursion_boards:Boolean):void
		{
			var subnet_boardNode:BoardNodes = (e.to_node as SubnetworkNode).associated_board.clone_parent.m_boardNodes;
			if (subnet_boardNode.changed_since_last_sim) {
				// If this board hasn't been simulated yet
				if (boards_in_progress.indexOf(subnet_boardNode) > -1) {
					// If we're already simulating this, a recursive case is found. For this, use the "default" result, meaning output ghost balls
					if (recursive_boards.indexOf(subnet_boardNode) == -1) {
						recursive_boards.push(subnet_boardNode);
					}
				} else {
					// If we haven't begun simulating this yet, do so now and store results in dictionary
					boardToTroublePoints[subnet_boardNode.board_name] = simulateFlowSensitiveAlg(subnet_boardNode, boards_in_progress, boards_touched, simulate_recursion_boards);
				}
			}
		}

		/**
		 * Simulates a given level and finds trouble points in the level based on 
		 * width of pipes. It is not flow sensitive.
		 * 
		 * @param	level the level to simulate
		 * @param	boards_in_progress Any boards that are already being simulated, used to avoid infinite recursion loops
		 * @return A two element array (list of Port trouble points, list of Edge trouble points)
		 */
		public function simulateFlowSensitiveAlg(boardNode:BoardNodes, boards_in_progress:Vector.<BoardNodes> = null, 
												 boards_touched:Vector.<BoardNodes> = null, simulate_recursion_boards:Boolean = true):Dictionary
		{
			if (!boards_in_progress) {
				boards_in_progress = new Vector.<BoardNodes>();
			}
			if (boards_in_progress.indexOf(boardNode) == -1) {
				boards_in_progress.push(boardNode);
			}
			if (!boards_touched) {
				boards_touched = new Vector.<BoardNodes>();
			}
			if (boards_touched.indexOf(boardNode) == -1) {
				boards_touched.push(boardNode);
			}
			
			listPortTroublePoints = new Vector.<Port>(); //ports with trouble points
			listEdgeTroublePoints = new Vector.<Edge>(); //edges with trouble points
			var troublePointsResultDictionary:Dictionary = new Dictionary;
			troublePointsResultDictionary["port"] = listPortTroublePoints;
			troublePointsResultDictionary["edge"] = listEdgeTroublePoints;
			
			var dict:Dictionary = boardNode.startingEdgeDictionary; 
			if (isEmpty(dict)) { // Nothing to compute on "Start" level. 
				boards_in_progress.splice(boards_in_progress.indexOf(boardNode), 1);
				return troublePointsResultDictionary;				
			}
			
			//shift() = dequeue, push() = enqueue
			var recursive_boards:Vector.<BoardNodes> = new Vector.<BoardNodes>();
			
			var queue:Vector.<Edge> = new Vector.<Edge>();
			
			for each (var v1:Vector.<Edge> in dict) {
				for each (var e1:Edge in v1) {
					if(e1.isStartingEdge())
					{
						e1.setStartingBallType();
						queue.push(e1);
					}
				}
			}	
			
			// This is used for the case of MERGE where one pipe has been traversed but the other hasn't, in this case push to end of queue and try again later
			var edges_awaiting_others:Vector.<Edge> = new Vector.<Edge>();
			
			//traverse all edges starting from the top
			//
			while ( queue.length != 0 ) { // traverse all the pipes
				var edge:Edge = queue.shift(); //dequeue
				
				//store each edge we visit, so we can clean them up next time
				edgeList[edge.edge_id] = edge;
								
				edge.setExitBallType();
				
				//check to make sure we are ready
				var node:Node = edge.from_node;
				var nodeComplete:Boolean = true;
				switch(node.kind)
				{
					case NodeTypes.MERGE:
						for each(var port:Port in node.incoming_ports)
						{
							if(edgeList[port.edge.edge_id] == null)
							{
								nodeComplete = false;
							}
						}
						break;
					case NodeTypes.SUBBOARD:
						for each(var subport:Port in node.outgoing_ports)
						{
							if(edgeList[subport.edge.edge_id] == null)
							{
								nodeComplete = false;
							}
						}
						break;
				}
				if(!nodeComplete)
				{
					queue.push(edge);
					continue;
				}

				//shouldn't get here if subboard incoming edges haven't been done yet
				if(edge.to_node.kind == NodeTypes.SUBBOARD)
					simulateSubNetwork(edge, boards_in_progress, recursive_boards, boards_touched, simulate_recursion_boards);
				
				//if we are coming from a subboard, pull flow info down.
				if(edge.from_node.kind == NodeTypes.SUBBOARD)
				{
					//This should be fixed, why a board object?
					var subnet_board:Board = (edge.from_port.node as SubnetworkNode).associated_board.clone_parent;
					
					//find our incoming edge, and then grab the flow info
					var foundParentEdge:Boolean = false;
					for each(var outgoingEdgeVector:Vector.<Edge>  in subnet_board.outgoingEdgeDictionary)
					{
						for each(var parentEdge:Edge in outgoingEdgeVector)
						{
							if(parentEdge.to_port_id == edge.from_port_id)
							{
								parentEdge.copyDropObjectFlowInfoToEdge(edge);
								 foundParentEdge = true;
								 break;
							}
						}
						if(foundParentEdge == true)
							break;
					}
				}

				
				// push flow Object Info down to children and push children into queue
				//push our exit ball type down to the next level
				var outgoingNode:Node = edge.to_node;
				var outgoingPorts:Vector.<Port> = outgoingNode.outgoing_ports;
				for(var index:uint = 0; index<outgoingPorts.length; index++)
				{
					
					edge.copyDropObjectFlowInfoToEdge(outgoingPorts[index].edge);
					//check to see if this edge is already in the queue, if so, don't push
					if(queue.indexOf(outgoingPorts[index].edge) == -1)
						queue.push(outgoingPorts[index].edge);
				}
				
				//now we should be set to check for all possible trouble spots, save in results dictionary
				edge.checkForTroubleSpots(troublePointsResultDictionary);
			}
			return troublePointsResultDictionary;
		}
		
		/* Checks if a given dictionary is empty or not. 
		 * 
		 * @param: dict, a dictionary.
		 * @returns: a boolean, true if the dictionary is empty, false otherwise.
		 */
		public function isEmpty(dict:Dictionary):Boolean {
			var empty:Boolean = true;

			for (var key:Object in dict)
			{
			   empty = false;
			   break;
			}
			return empty;
		}
	}	
}