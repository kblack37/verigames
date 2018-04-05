package system;

import networkGraph.BoardNodes;
import networkGraph.Edge;
import networkGraph.FlowObject;
import networkGraph.MapGetNode;
import networkGraph.Node;
import networkGraph.NodeTypes;
import networkGraph.Port;
import networkGraph.SubnetworkNode;
import networkGraph.SubnetworkPort;
import visualWorld.Ball;
import visualWorld.Board;
import visualWorld.Level;
import visualWorld.MapGet;
import visualWorld.Pipe;
import visualWorld.TroublePoint;
import visualWorld.VerigameSystem;
import visualWorld.World;
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
class Simulator
{
    // If true, the pipes will be marked as failed or succeeded as the simulator makes the determination (as opposed to doing so outside of the simulator)
    public static var MARK_PIPES_FAILED_OR_SUCCEEDED : Bool = false;
    
    /* The world in which the Simulator detects trouble points */
    private var world : World;
    
    /* A map from level to a list that contains the trouble points 
		 * associated with that level. 
		 * 
		 * The list has exactly two elements. The first element is a list 
		 * of Port trouble points. The second is a list of Edge trouble points.
		 */
    private var levelToTroublePoints : Dictionary;
    private var boardToTroublePoints : Dictionary;
    
    //private var listNodeTroublePoints:Vector.<Node>;
    public var listPortTroublePoints : Array<Port>;
    public var listEdgeTroublePoints : Array<Edge>;
    
    private var edgeList : Dictionary = new Dictionary();
    
    /* The constuctor takes a World and runs and necessary initial computation. 
		 * 
		 * @param: _world, the current world in which the Simulator will detect trouble points
		 */
    public function new(_world : World)
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
    public function getAllTroublePoints(level : Level) : Array<Dynamic>
    {
        return Reflect.field(levelToTroublePoints, Std.string(level));
    }
    
    public function getAllTroublePointsByBoardName(name : String) : Dictionary
    {
        return Reflect.field(boardToTroublePoints, name);
    }
    
    public function updateOnPipeClickFlowSens(edgeSetId : String, boardNodes : Dictionary) : Array<BoardNodes>
    {
        var boards_in_prog : Array<BoardNodes> = new Array<BoardNodes>();
        var boards_touched : Array<BoardNodes> = new Array<BoardNodes>();
        for (boardNode/* AS3HX WARNING could not determine type for var: boardNode exp: EIdent(boardNodes) type: Dictionary */ in boardNodes)
        {
            boardNode.changed_since_last_sim = true;
            boardToTroublePoints[boardNode.board_name] = simulateFlowSensitiveAlg(boardNode, boards_in_prog, boards_touched);
        }
        return boards_touched;
    }
    
    public function simulateSubNetwork(e : Edge, boards_in_progress : Array<BoardNodes>, recursive_boards : Array<BoardNodes>,
            boards_touched : Array<BoardNodes>, simulate_recursion_boards : Bool) : Void
    {
        var subnet_boardNode : BoardNodes = (try cast(e.to_node, SubnetworkNode) catch(e:Dynamic) null).associated_board.clone_parent.m_boardNodes;
        if (subnet_boardNode.changed_since_last_sim)
        
        // If this board hasn't been simulated yet{
            
            if (Lambda.indexOf(boards_in_progress, subnet_boardNode) > -1)
            
            // If we're already simulating this, a recursive case is found. For this, use the "default" result, meaning output ghost balls{
                
                if (Lambda.indexOf(recursive_boards, subnet_boardNode) == -1)
                {
                    recursive_boards.push(subnet_boardNode);
                }
            }
            // If we haven't begun simulating this yet, do so now and store results in dictionary
            else
            {
                
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
    public function simulateFlowSensitiveAlg(boardNode : BoardNodes, boards_in_progress : Array<BoardNodes> = null,
            boards_touched : Array<BoardNodes> = null, simulate_recursion_boards : Bool = true) : Dictionary
    {
        if (boards_in_progress == null)
        {
            boards_in_progress = new Array<BoardNodes>();
        }
        if (Lambda.indexOf(boards_in_progress, boardNode) == -1)
        {
            boards_in_progress.push(boardNode);
        }
        if (boards_touched == null)
        {
            boards_touched = new Array<BoardNodes>();
        }
        if (Lambda.indexOf(boards_touched, boardNode) == -1)
        {
            boards_touched.push(boardNode);
        }
        
        listPortTroublePoints = new Array<Port>();  //ports with trouble points  
        listEdgeTroublePoints = new Array<Edge>();  //edges with trouble points  
        var troublePointsResultDictionary : Dictionary = new Dictionary();
        Reflect.setField(troublePointsResultDictionary, "port", listPortTroublePoints);
        Reflect.setField(troublePointsResultDictionary, "edge", listEdgeTroublePoints);
        
        var dict : Dictionary = boardNode.startingEdgeDictionary;
        if (isEmpty(dict))
        
        // Nothing to compute on "Start" level.{
            
            boards_in_progress.splice(Lambda.indexOf(boards_in_progress, boardNode), 1);
            return troublePointsResultDictionary;
        }
        
        //shift() = dequeue, push() = enqueue
        var recursive_boards : Array<BoardNodes> = new Array<BoardNodes>();
        
        var queue : Array<Edge> = new Array<Edge>();
        
        for (v1/* AS3HX WARNING could not determine type for var: v1 exp: EIdent(dict) type: Dictionary */ in dict)
        {
            for (e1/* AS3HX WARNING could not determine type for var: e1 exp: EIdent(v1) type: null */ in v1)
            {
                if (e1.isStartingEdge())
                {
                    e1.setStartingBallType();
                    queue.push(e1);
                }
            }
        }
        
        // This is used for the case of MERGE where one pipe has been traversed but the other hasn't, in this case push to end of queue and try again later
        var edges_awaiting_others : Array<Edge> = new Array<Edge>();
        
        //traverse all edges starting from the top
        //
        while (queue.length != 0)
        
        // traverse all the pipes{
            
            var edge : Edge = queue.shift();  //dequeue  
            
            //store each edge we visit, so we can clean them up next time
            edgeList[edge.edge_id] = edge;
            
            edge.setExitBallType();
            
            //check to make sure we are ready
            var node : Node = edge.from_node;
            var nodeComplete : Bool = true;
            var _sw0_ = (node.kind);            

            switch (_sw0_)
            {
                case NodeTypes.MERGE:
                    for (port/* AS3HX WARNING could not determine type for var: port exp: EField(EIdent(node),incoming_ports) type: null */ in node.incoming_ports)
                    {
                        if (edgeList[port.edge.edge_id] == null)
                        {
                            nodeComplete = false;
                        }
                    }
                case NodeTypes.SUBBOARD:
                    for (subport/* AS3HX WARNING could not determine type for var: subport exp: EField(EIdent(node),outgoing_ports) type: null */ in node.outgoing_ports)
                    {
                        if (edgeList[subport.edge.edge_id] == null)
                        {
                            nodeComplete = false;
                        }
                    }
            }
            if (!nodeComplete)
            {
                queue.push(edge);
                continue;
            }
            
            //shouldn't get here if subboard incoming edges haven't been done yet
            if (edge.to_node.kind == NodeTypes.SUBBOARD)
            {
                simulateSubNetwork(edge, boards_in_progress, recursive_boards, boards_touched, simulate_recursion_boards);
            }
            
            //if we are coming from a subboard, pull flow info down.
            if (edge.from_node.kind == NodeTypes.SUBBOARD)
            
            //This should be fixed, why a board object?{
                
                var subnet_board : Board = (try cast(edge.from_port.node, SubnetworkNode) catch(e:Dynamic) null).associated_board.clone_parent;
                
                //find our incoming edge, and then grab the flow info
                var foundParentEdge : Bool = false;
                for (outgoingEdgeVector/* AS3HX WARNING could not determine type for var: outgoingEdgeVector exp: EField(EIdent(subnet_board),outgoingEdgeDictionary) type: null */ in subnet_board.outgoingEdgeDictionary)
                {
                    for (parentEdge/* AS3HX WARNING could not determine type for var: parentEdge exp: EIdent(outgoingEdgeVector) type: null */ in outgoingEdgeVector)
                    {
                        if (parentEdge.to_port_id == edge.from_port_id)
                        {
                            parentEdge.copyDropObjectFlowInfoToEdge(edge);
                            foundParentEdge = true;
                            break;
                        }
                    }
                    if (foundParentEdge == true)
                    {
                        break;
                    }
                }
            }
            
            
            // push flow Object Info down to children and push children into queue
            //push our exit ball type down to the next level
            var outgoingNode : Node = edge.to_node;
            var outgoingPorts : Array<Port> = outgoingNode.outgoing_ports;
            for (index in 0...outgoingPorts.length)
            {
                edge.copyDropObjectFlowInfoToEdge(outgoingPorts[index].edge);
                //check to see if this edge is already in the queue, if so, don't push
                if (Lambda.indexOf(queue, outgoingPorts[index].edge) == -1)
                {
                    queue.push(outgoingPorts[index].edge);
                }
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
    public function isEmpty(dict : Dictionary) : Bool
    {
        var empty : Bool = true;
        
        for (key in Reflect.fields(dict))
        {
            empty = false;
            break;
        }
        return empty;
    }
}
