package system;

import flash.errors.Error;
import flash.utils.Dictionary;
import graph.BoardNodes;
import graph.ConflictDictionary;
import graph.Edge;
import graph.LevelNodes;
import graph.MapGetNode;
import graph.Network;
import graph.Node;
import graph.NodeTypes;
import graph.Port;
import graph.PropDictionary;
import graph.SubnetworkNode;
import graph.SubnetworkPort;

/**
	 * The PipeSimulator class calculates and stores where conflicts
	 * can occur in the game, based on the current edge/graph configuration.
	 * 
	 * Conflicts can occur at either Ports or Edges. 
	 * 
	 * A conflict Port occurs only when an edge with a WIDE ball flows
	 * into a NARROW SUBNETWORK edge stub or when a WIDE ball in the argument
	 * edge of a MAPGET node flows into a MAPGET where the VALUE edge is
	 * NARROW.
	 * 
	 * Conflict edges occur any time a WIDE ball flows into a NARROW edge
	 * or an edge that has a pinch point. For these edges, the edge.enter_ball_type
	 * would be WIDE while the edge.exit_ball_type would be NARROW or NONE.
	 * 
	 * @author Steph
	 */
class PipeSimulator
{
    private static var DEBUG : Bool = false;
    
    /** True to use simulation results from external board calls (outside of the current level) on current board */
    private static var SIMULATE_EXTERNAL_BOARDS : Bool = false;
    
    /* The world in which the PipeSimulator detects conflicts */
    private var network : Network;
    
    /* A map from boardname ConflictDict associated with that level.*/
    public var boardToConflicts : Dictionary;
    private var prevBoardToConflicts : Dictionary;
    
    /**
		 * Simulates the ball types for each edge in the given network
		 * @param	_network
		 */
    public function new(_network : Network)
    {
        network = _network;
        boardToConflicts = new Dictionary();
        // TODO: globally mark Edges and Ports has_error = true
        var boards_in_prog : Array<BoardNodes> = new Array<BoardNodes>();
        //trace("Simulating");
        for (levelName in Reflect.fields(network.LevelNodesDictionary))
        {
            var levelNodes : LevelNodes = try cast(network.LevelNodesDictionary[levelName], LevelNodes) catch(e:Dynamic) null;
            for (boardName in Reflect.fields(levelNodes.boardNodesDictionary))
            {
                var board : BoardNodes = try cast(levelNodes.boardNodesDictionary[boardName], BoardNodes) catch(e:Dynamic) null;
                var conflictDict : ConflictDictionary = simulateBoard(board, boards_in_prog);
                var prop : String;
                for (portk in Reflect.fields(conflictDict.iterPorts()))
                {
                    var portToMark : Port = conflictDict.getPort(portk);
                    for (prop in Reflect.fields(conflictDict.getPortConflicts(portk).iterProps()))
                    
                    // TODO: merge them all at once instead of adding individually{
                        
                        portToMark.addConflict(prop);
                    }
                }
                for (edgek in Reflect.fields(conflictDict.iterEdges()))
                {
                    var edgeToMark : Edge = conflictDict.getEdge(edgek);
                    for (prop in Reflect.fields(conflictDict.getEdgeConflicts(edgek).iterProps()))
                    
                    // TODO: merge them all at once instead of adding individually{
                        
                        edgeToMark.addConflict(prop);
                    }
                }
                boardToConflicts[board.board_name] = conflictDict;
            }
        }
    }
    
    /**
		 * Call this when a box has been clicked by the user to re-simulate.
		 * @param	edgeSetId Corresponding to box clicked
		 * @param	levelToSimulate To simulate a given level, "" to simulate all in world
		 */
    public function updateOnBoxSizeChange(edgeSetId : String, levelToSimulate : String = "") : Void
    // Copy previous conflicts
    {
        
        prevBoardToConflicts = new Dictionary();
        for (boardName in Reflect.fields(boardToConflicts))
        {
            Reflect.setField(prevBoardToConflicts, boardName, (try cast(Reflect.field(boardToConflicts, boardName), ConflictDictionary) catch(e:Dynamic) null).clone());
        }
        //trace("Simulating");
        var boardsToSim : Array<BoardNodes> = new Array<BoardNodes>();
        for (levelName in Reflect.fields(network.LevelNodesDictionary))
        {
            if ((levelToSimulate.length == 0) || (levelName == levelToSimulate))
            {
                var levelNodes : LevelNodes = try cast(network.LevelNodesDictionary[levelName], LevelNodes) catch(e:Dynamic) null;
                for (boardName1 in Reflect.fields(levelNodes.boardNodesDictionary))
                {
                    var board : BoardNodes = try cast(levelNodes.boardNodesDictionary[boardName1], BoardNodes) catch(e:Dynamic) null;
                    // TODO: We should not have to simulate everything, just any boards that contain this
                    // edge id and boards that refer to those boards
                    board.changed_since_last_sim = true;
                    boardsToSim.push(board);
                }
            }
        }
        var boards_in_prog : Array<BoardNodes> = new Array<BoardNodes>();
        var boards_touched : Array<BoardNodes> = new Array<BoardNodes>();
        var i : Int;
        for (i in 0...boardsToSim.length)
        {
            var simBoard : BoardNodes = boardsToSim[i];
            if (simBoard.changed_since_last_sim)
            {
                boardToConflicts[simBoard.board_name] = simulateBoard(simBoard, boards_in_prog, boards_touched);
            }
        }
        //trace("Determining new/removed conflicts");
        var addConflictDict : ConflictDictionary = new ConflictDictionary();
        var removeConflictDict : ConflictDictionary = new ConflictDictionary();
        var portk : String;
        var edgek : String;
        var prop : String;
        for (i in 0...boards_touched.length)
        {
            var boardTouched : BoardNodes = boards_touched[i];
            var newConflictDict : ConflictDictionary = try cast(boardToConflicts[boardTouched.board_name], ConflictDictionary) catch(e:Dynamic) null;
            var prevConflictDict : ConflictDictionary = try cast(prevBoardToConflicts[boardTouched.board_name], ConflictDictionary) catch(e:Dynamic) null;
            // check new conflict, if they weren't in prevConflictDict then they are new and need to be added
            for (portk in Reflect.fields(newConflictDict.iterPorts()))
            {
                var port : Port = newConflictDict.getPort(portk);
                var newPortConfl : PropDictionary = newConflictDict.getPortConflicts(portk);
                var oldPortConfl : PropDictionary = prevConflictDict.getPortConflicts(portk);
                for (prop in Reflect.fields(newPortConfl.iterProps()))
                {
                    if (oldPortConfl == null)
                    {
                        addConflictDict.addPortConflict(port, prop);
                        continue;
                    }
                    if (oldPortConfl.hasProp(prop))
                    
                    // If appears in new and old, remove from old so that only removed conflict props are there{
                        
                        oldPortConfl.setProp(prop, false);
                    }
                    else
                    {
                        addConflictDict.addPortConflict(port, prop);
                    }
                }
            }
            for (edgek in Reflect.fields(newConflictDict.iterEdges()))
            {
                var edge : Edge = newConflictDict.getEdge(edgek);
                var newEdgeConfl : PropDictionary = newConflictDict.getEdgeConflicts(edgek);
                var oldEdgeConfl : PropDictionary = prevConflictDict.getEdgeConflicts(edgek);
                for (prop in Reflect.fields(newEdgeConfl.iterProps()))
                {
                    if (oldEdgeConfl == null)
                    {
                        addConflictDict.addEdgeConflict(edge, prop);
                        continue;
                    }
                    if (oldEdgeConfl.hasProp(prop))
                    
                    // If appears in new and old, remove from old so that only removed conflict props are there{
                        
                        oldEdgeConfl.setProp(prop, false);
                    }
                    else
                    {
                        addConflictDict.addEdgeConflict(edge, prop);
                    }
                }
            }
            // Now all that's left in prevConflictDict should be conflicts that should be removed
            // Mark added conflicts
            for (portk in Reflect.fields(addConflictDict.iterPorts()))
            {
                for (prop in Reflect.fields(addConflictDict.getPortConflicts(portk).iterProps()))
                
                // TODO: merge them all at once instead of adding individually{
                    
                    //trace("->adding " + portk);
                    addConflictDict.getPort(portk).addConflict(prop);
                }
            }
            for (edgek in Reflect.fields(addConflictDict.iterEdges()))
            {
                for (prop in Reflect.fields(addConflictDict.getEdgeConflicts(edgek).iterProps()))
                
                // TODO: merge them all at once instead of adding individually{
                    
                    //trace("->adding " + edgek);
                    addConflictDict.getEdge(edgek).addConflict(prop);
                }
            }
            
            // Un-mark removed conflicts
            for (portk in Reflect.fields(prevConflictDict.iterPorts()))
            {
                for (prop in Reflect.fields(prevConflictDict.getPortConflicts(portk).iterProps()))
                
                // TODO: merge them all at once instead of removing individually{
                    
                    //trace("->removing " + portk);
                    prevConflictDict.getPort(portk).removeConflict(prop);
                }
            }
            for (edgek in Reflect.fields(prevConflictDict.iterEdges()))
            {
                for (prop in Reflect.fields(prevConflictDict.getEdgeConflicts(edgek).iterProps()))
                
                // TODO: merge them all at once instead of removing individually{
                    
                    //trace("->removing " + edgek);
                    prevConflictDict.getEdge(edgek).removeConflict(prop);
                }
            }
        }
    }
    
    /**
		 * Simulates a given level and finds conflicts in the level based on 
		 * width of pipes. It is not flow sensitive.
		 * 
		 * @param	level the level to simulate
		 * @param	boards_in_progress Any boards that are already being simulated, used to avoid infinite recursion loops
		 * @return Conflict dictionary representing conflicts found by port and edge
		 */
    private function simulateBoard(sim_board : BoardNodes, boards_in_progress : Array<BoardNodes> = null, boards_touched : Array<BoardNodes> = null, simulate_recursion_boards : Bool = true) : ConflictDictionary
    {
        if (boards_in_progress == null)
        {
            boards_in_progress = new Array<BoardNodes>();
        }
        if (Lambda.indexOf(boards_in_progress, sim_board) == -1)
        {
            boards_in_progress.push(sim_board);
        }
        if (boards_touched == null)
        {
            boards_touched = new Array<BoardNodes>();
        }
        if (Lambda.indexOf(boards_touched, sim_board) == -1)
        {
            boards_touched.push(sim_board);
        }
        
        //if (DEBUG) { trace("----Simulating " + sim_board.board_name + "----"); }
        
        // When we transition to an algorithm that only traverses the edges that have changes widths (after a click), we will mark
        // ONLY those pipes as BALL_TYPE_UNDETERMINED and then only perform collision detection below on BALL_TYPE_UNDETERMINED edges (and below)
        // For now, mark all pipes as BALL_TYPE_UNDETERMINED and recompute all
        var i : Int;
        for (startingEdgeSetId in Reflect.fields(sim_board.startingEdgeDictionary))
        {
            var startingEdgeVec : Array<Edge> = try cast(sim_board.startingEdgeDictionary[startingEdgeSetId], Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
            for (i in 0...startingEdgeVec.length)
            {
                var startingEdge : Edge = startingEdgeVec[i];
                startingEdge.resetPropsAndRecurse();
            }
        }
        
        // This will tell us in the end whether we have an infinite recursision problem
        var initial_ghost_outputs : Int = 0;
        var total_outputs : Int = 0;
        for (edgeSetId in Reflect.fields(sim_board.outgoingEdgeDictionary))
        {
            var outgoing_vec : Array<Edge> = try cast(sim_board.outgoingEdgeDictionary[edgeSetId], Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
            for (i in 0...outgoing_vec.length)
            {
                var oEdge : Edge = outgoing_vec[i];
                total_outputs++;
                if ((oEdge.exit_ball_type == Edge.BALL_TYPE_UNDETERMINED) ||
                    (oEdge.exit_ball_type == Edge.BALL_TYPE_GHOST))
                {
                    initial_ghost_outputs++;
                }
            }
        }
        //if (DEBUG) { trace("  ["+sim_board.board_name+"] Ghost outputs/total: " + initial_ghost_outputs + "/" + total_outputs); }
        
        var conflictDict : ConflictDictionary = new ConflictDictionary();
        
        var dict : Dictionary = sim_board.startingEdgeDictionary;
        if (isEmpty(dict))
        
        // Nothing to compute on "Start" level.{
            
            boards_in_progress.splice(Lambda.indexOf(boards_in_progress, sim_board), 1);
            return conflictDict;
        }
        
        //shift() = dequeue, push() = enqueue
        var queue : Array<Edge> = new Array<Edge>();
        
        var recursive_boards : Array<BoardNodes> = new Array<BoardNodes>();
        //check starting edges to see if they come out of a subnetwork and add them to the queue
        var props : PropDictionary;
        var edgeSetProps : PropDictionary;
        for (edgeKey in Reflect.fields(dict))
        {
            var v : Array<Edge> = try cast(Reflect.field(dict, edgeKey), Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
            for (i in 0...v.length)
            {
                var e : Edge = v[i];
                props = new PropDictionary();
                edgeSetProps = e.linked_edge_set.getProps().clone();
                // check for SUBNETWORK width mismatch - this is the case when a SUBNETWORK edge flows into this edge (e)
                var _sw0_ = (e.from_node.kind);                

                switch (_sw0_)
                {
                    case NodeTypes.INCOMING:
                        // For now we've agreed to make this a pipe-dependent ball: wide for wide, small for small
                        if (e.is_wide)
                        {
                            e.enter_ball_type = Edge.BALL_TYPE_WIDE;
                        }
                        else
                        {
                            e.enter_ball_type = Edge.BALL_TYPE_NARROW;
                        }
                        edgeSetProps.setProp(PropDictionary.PROP_NARROW, !e.is_wide);
                        e.setEnterProps(edgeSetProps);
                        queue.push(e);
                    case NodeTypes.START_LARGE_BALL:
                        e.enter_ball_type = Edge.BALL_TYPE_WIDE;
                        edgeSetProps.setProp(PropDictionary.PROP_NARROW, false);
                        e.setEnterProps(edgeSetProps);
                        queue.push(e);
                    case NodeTypes.START_NO_BALL:
                        e.enter_ball_type = Edge.BALL_TYPE_NONE;
                        edgeSetProps.setProp(PropDictionary.PROP_NARROW, true);
                        e.setEnterProps(edgeSetProps);
                        queue.push(e);
                    case NodeTypes.START_SMALL_BALL:
                        e.enter_ball_type = Edge.BALL_TYPE_NARROW;
                        edgeSetProps.setProp(PropDictionary.PROP_NARROW, true);
                        e.setEnterProps(edgeSetProps);
                        queue.push(e);
                    case NodeTypes.START_PIPE_DEPENDENT_BALL:
                        e.enter_ball_type = (e.is_wide) ? Edge.BALL_TYPE_WIDE : Edge.BALL_TYPE_NARROW;
                        edgeSetProps.setProp(PropDictionary.PROP_NARROW, !e.is_wide);
                        e.setEnterProps(edgeSetProps);
                        queue.push(e);
                    case NodeTypes.SUBBOARD:
                        var subnet_node : SubnetworkNode = try cast(e.from_node, SubnetworkNode) catch(e:Dynamic) null;
                        //if (DEBUG) { trace("  ["+sim_board.board_name+"] Found subboard starting edge: " + e.edge_id + " board:" + subnet_node.associated_board.board_name); }
                        var changedSinceLastSim : Bool = false;
                        var useDefaultBoardOutputs : Bool = true;
                        if (subnet_node.associated_board && (!subnet_node.associated_board_is_external || SIMULATE_EXTERNAL_BOARDS))
                        {
                            var subnet_board : BoardNodes = subnet_node.associated_board;
                            useDefaultBoardOutputs = false;
                            if (subnet_board.changed_since_last_sim)
                            {
                                changedSinceLastSim = true;
                                // If this board hasn't been simulated yet
                                if (Lambda.indexOf(boards_in_progress, subnet_board) > -1)
                                
                                // If we're already simulating this, a recursive case is found. For this, use the "default" result, meaning output ghost balls{
                                    
                                    if (Lambda.indexOf(recursive_boards, subnet_board) == -1)
                                    {
                                        recursive_boards.push(subnet_board);
                                    }
                                }
                                // If we haven't begun simulating this yet, do so now and store results in dictionary
                                else
                                {
                                    
                                    //if (DEBUG) { trace("  ["+sim_board.board_name+"] Simulate this subboard: " + subnet_board.board_name); }
                                    boardToConflicts[subnet_board.board_name] = simulateBoard(subnet_board, boards_in_progress, boards_touched, simulate_recursion_boards);
                                }
                            }
                            else
                            {
                                changedSinceLastSim = false;
                            }
                        }
                        // Now we can initialize the ball types for pipes on this board flowing out of the subnet_board
                        for (i1 in 0...e.from_node.outgoing_ports.length)
                        {
                            var my_port : Port = e.from_node.outgoing_ports[i1];
                            var subnet_port : SubnetworkPort = (try cast(my_port, SubnetworkPort) catch(e:Dynamic) null);
                            // Mark the ball types on *this* board based on the outputs of the subnet_board (undetermined get set as ghost balls)
                            var out_type : Int;
                            var out_props : PropDictionary;
                            if (!useDefaultBoardOutputs && subnet_port.linked_subnetwork_edge)
                            {
                                out_type = subnet_port.linked_subnetwork_edge.exit_ball_type;
                                out_props = subnet_port.linked_subnetwork_edge.getExitProps().clone();
                                subnet_port.default_ball_type = out_type;  // update best-known default  
                                subnet_port.default_props = out_props;
                            }
                            else
                            {
                                out_type = subnet_port.default_ball_type;
                                out_props = subnet_port.default_props.clone();
                            }
                            switch (out_type)
                            {
                                case Edge.BALL_TYPE_WIDE:
                                    subnet_port.edge.enter_ball_type = Edge.BALL_TYPE_WIDE;
                                case Edge.BALL_TYPE_NONE:
                                    subnet_port.edge.enter_ball_type = Edge.BALL_TYPE_NONE;
                                case Edge.BALL_TYPE_WIDE_AND_NARROW:
                                    subnet_port.edge.enter_ball_type = Edge.BALL_TYPE_WIDE_AND_NARROW;
                                case Edge.BALL_TYPE_NARROW:
                                    subnet_port.edge.enter_ball_type = Edge.BALL_TYPE_NARROW;
                                case Edge.BALL_TYPE_UNDETERMINED, Edge.BALL_TYPE_GHOST:
                                //if (DEBUG) { trace("  ["+sim_board.board_name+"] Ball coming out of subboard is UNDETERMINED or GHOST. changedSinceLastSim=" + changedSinceLastSim); }
                                if (!changedSinceLastSim)
                                
                                // Unable to make any progress (mutually recursive boards where no new outputs{
                                    
                                    // were simulated. In this case, give up and output no ball
                                    subnet_port.edge.enter_ball_type = Edge.BALL_TYPE_NONE;
                                }
                                else
                                {
                                    subnet_port.edge.enter_ball_type = Edge.BALL_TYPE_GHOST;
                                }
                                default:
                                    throw new Error("Flow sensitive PipeSimulator: Ball type not defined - " + out_type);
                            }
                            subnet_port.edge.setEnterProps(out_props);
                        }
                        queue.push(e);
                    default:
                        //trace("FOUND a " + e.from_node.kind);
                        break;
                }
            }
        }
        
        // This is used for the case of MERGE where one pipe has been traversed but the other hasn't, in this case push to end of queue and try again later
        var edges_awaiting_others : Array<Edge> = new Array<Edge>();
        
        while (queue.length != 0)
        
        // traverse all the pipes{
            
            var edge : Edge = queue.shift();  //dequeue  
            if (edge.enter_ball_type == Edge.BALL_TYPE_UNDETERMINED)
            {
                throw new Error("Flow sensitive PipeSimulator: Traversed to edge where we begin with ball_type == BALL_TYPE_UNDETERMINED. Cannot proceed.");
            }
            // Deal with incoming properties
            // Outgoing properties = incoming || edge set properties
            // Contlict properties = edge set properties NOT IN incoming
            var outgoing_props : PropDictionary = edge.getEnterProps().clone();
            var prop : String;
            var edgeProps : PropDictionary = edge.linked_edge_set.getProps().clone();
            if (edge.has_buzzsaw || edge.has_pinch || !edge.is_wide)
            {
                edgeProps.setProp(PropDictionary.PROP_NARROW, true);
            }
            for (prop in Reflect.fields(edgeProps.iterProps()))
            {
                outgoing_props.setProp(prop, true);
                if ((prop == PropDictionary.PROP_NARROW) && edge.has_buzzsaw)
                {
                    continue;
                }  // no conflict  
                // If there is a prop in the edge set that isn't in the entering prop, mark as conflict props
                if (!edge.getEnterProps().hasProp(prop))
                {
                    conflictDict.addEdgeConflict(edge, prop);
                }
            }
            edge.setExitProps(outgoing_props);
            
            // Move from top of this edges's pipe to the bottom
            // If there's a pinch point, remove any large balls and insert a conflict
            var outgoing_ball_type : Int = edge.enter_ball_type;
            if (edge.has_buzzsaw)
            
            // Top of pipe has a Buzzsaw. That means pass any small balls through, otherwise no balls{
                
                var _sw1_ = (edge.enter_ball_type);                

                switch (_sw1_)
                {
                    case Edge.BALL_TYPE_NONE:
                        outgoing_ball_type = Edge.BALL_TYPE_NONE;
                    case Edge.BALL_TYPE_WIDE, Edge.BALL_TYPE_NARROW, Edge.BALL_TYPE_WIDE_AND_NARROW:
                        outgoing_ball_type = Edge.BALL_TYPE_NARROW;
                    case Edge.BALL_TYPE_GHOST:
                        outgoing_ball_type = Edge.BALL_TYPE_GHOST;
                    default:
                        throw new Error("Flow sensitive PipeSimulator: Ball type not defined - " + edge.enter_ball_type);
                }
            }
            // Top of pipe has no buzzsaw, fail any wide balls and pass through any narrow/pinched pipes
            else
            {
                
                var _sw2_ = (edge.enter_ball_type);                

                switch (_sw2_)
                {
                    case Edge.BALL_TYPE_NONE, Edge.BALL_TYPE_NARROW, Edge.BALL_TYPE_GHOST:
                        outgoing_ball_type = edge.enter_ball_type;
                    case Edge.BALL_TYPE_WIDE:
                        if (edge.has_pinch || !edge.is_wide)
                        
                        //conflictDict.addEdgeConflict(edge, PropDictionary.PROP_NARROW);{
                            
                            outgoing_ball_type = Edge.BALL_TYPE_NONE;
                        }
                        else
                        {
                            outgoing_ball_type = Edge.BALL_TYPE_WIDE;
                        }
                    case Edge.BALL_TYPE_WIDE_AND_NARROW:
                        if (edge.has_pinch || !edge.is_wide)
                        
                        //conflictDict.addEdgeConflict(edge, PropDictionary.PROP_NARROW);{
                            
                            outgoing_ball_type = Edge.BALL_TYPE_NARROW;
                        }
                        else
                        {
                            outgoing_ball_type = Edge.BALL_TYPE_WIDE_AND_NARROW;
                        }
                    default:
                        throw new Error("Flow sensitive PipeSimulator: Ball type not defined - " + edge.enter_ball_type);
                }
            }
            
            // If already simulated, move on
            if (edge.exit_ball_type == outgoing_ball_type)
            {
                continue;
            }
            edge.exit_ball_type = outgoing_ball_type;
            
            // At this point we have determined what type of ball should be output of this edge, now process next node
            
            var node : Node = edge.to_node;
            
            var _sw3_ = (node.kind);            

            switch (_sw3_)
            {
                //possible traversal ends
                case NodeTypes.OUTGOING:{ }  //traversal ends  ;
                
                case NodeTypes.END:{ }  //traversal ends  ;
                
                case NodeTypes.SUBBOARD:{
                    // This is the case when this edge ("edge") flows into a SUBNETWORK edge
                    // Problem only if wide ball flows into narrow pipe
                    var subnet_incoming_edge : Edge = (try cast(edge.to_port, SubnetworkPort) catch(e:Dynamic) null).linked_subnetwork_edge;
                    var subnet_is_external : Bool = (try cast(node, SubnetworkNode) catch(e:Dynamic) null).associated_board_is_external;
                    var subnet_stub_is_wide : Bool;
                    edgeProps = new PropDictionary();
                    if (subnet_incoming_edge != null && (!subnet_is_external || SIMULATE_EXTERNAL_BOARDS))
                    {
                        subnet_stub_is_wide = subnet_incoming_edge.is_wide;
                        edgeProps = subnet_incoming_edge.linked_edge_set.getProps().clone();
                    }
                    else
                    {
                        subnet_stub_is_wide = (try cast(edge.to_port, SubnetworkPort) catch(e:Dynamic) null).default_is_wide;
                        edgeProps.setProp(PropDictionary.PROP_NARROW, !subnet_stub_is_wide);
                    }
                    
                    // Deal with properties
                    var exit_props : PropDictionary = edge.getExitProps().clone();
                    for (prop in Reflect.fields(edgeProps.iterProps()))
                    
                    // If there is a prop in the edge set that isn't in the entering prop, mark as conflict props{
                        
                        if (!edge.getExitProps().hasProp(prop))
                        {
                            conflictDict.addPortConflict(edge.to_port, prop);
                        }
                    }
                    
                    if (!subnet_stub_is_wide)
                    {
                        var _sw4_ = (edge.exit_ball_type);                        

                        switch (_sw4_)
                        {
                            case Edge.BALL_TYPE_WIDE, Edge.BALL_TYPE_WIDE_AND_NARROW:
                            //conflictDict.addPortConflict(edge.to_port, PropDictionary.PROP_NARROW);
                            break;
                        }
                    }
                }
                
                case NodeTypes.MERGE:{
                    var other_edge : Edge = getOtherMergeEdge(edge);
                    if (other_edge.exit_ball_type == Edge.BALL_TYPE_UNDETERMINED)
                    
                    // If the other edge has not made a determination yet, push this edge to the back of the queue and try later{
                        
                        if (Lambda.indexOf(queue, edge) == -1)
                        {
                            queue.push(edge);
                        }
                        if (Lambda.indexOf(edges_awaiting_others, edge) == -1)
                        {
                            edges_awaiting_others.push(edge);
                        }
                    }
                    else if (node.outgoing_ports.length == 1)
                    {
                        var outgoingMergeEdge : Edge = node.outgoing_ports[0].edge;
                        // Merge the ball types - narrow if either incoming ball is narrow, same with wide
                        var narrow_ball_into_next_edge : Bool = (
                        (edge.exit_ball_type == Edge.BALL_TYPE_NARROW) ||
                        (edge.exit_ball_type == Edge.BALL_TYPE_WIDE_AND_NARROW) ||
                        (other_edge.exit_ball_type == Edge.BALL_TYPE_NARROW) ||
                        (other_edge.exit_ball_type == Edge.BALL_TYPE_WIDE_AND_NARROW));
                        var wide_ball_into_next_edge : Bool = (
                        (edge.exit_ball_type == Edge.BALL_TYPE_WIDE) ||
                        (edge.exit_ball_type == Edge.BALL_TYPE_WIDE_AND_NARROW) ||
                        (other_edge.exit_ball_type == Edge.BALL_TYPE_WIDE) ||
                        (other_edge.exit_ball_type == Edge.BALL_TYPE_WIDE_AND_NARROW));
                        if (wide_ball_into_next_edge && narrow_ball_into_next_edge)
                        {
                            outgoingMergeEdge.enter_ball_type = Edge.BALL_TYPE_WIDE_AND_NARROW;
                        }
                        else if (wide_ball_into_next_edge)
                        {
                            outgoingMergeEdge.enter_ball_type = Edge.BALL_TYPE_WIDE;
                        }
                        else if (narrow_ball_into_next_edge)
                        {
                            outgoingMergeEdge.enter_ball_type = Edge.BALL_TYPE_NARROW;
                        }
                        else if ((edge.exit_ball_type == Edge.BALL_TYPE_GHOST)
                            || (other_edge.exit_ball_type == Edge.BALL_TYPE_GHOST))
                        
                        // TODO: we don't cover the none + ghost case, what should that output? For now, output ghost{
                            
                            outgoingMergeEdge.enter_ball_type = Edge.BALL_TYPE_GHOST;
                        }
                        else
                        {
                            outgoingMergeEdge.enter_ball_type = Edge.BALL_TYPE_NONE;
                        }
                        
                        // Deal with properties - only add if BOTH merging edges have the property
                        props = other_edge.getExitProps().clone();
                        props.addProps(edge.getExitProps());
                        outgoing_props = new PropDictionary();
                        for (prop in Reflect.fields(props.iterProps()))
                        {
                            if (other_edge.getExitProps().hasProp(prop) && edge.getExitProps().hasProp(prop))
                            {
                                outgoing_props.setProp(prop, true);
                            }
                        }
                        outgoingMergeEdge.setEnterProps(outgoing_props);
                        
                        // Remove edges from waiting list if they're in there
                        if (Lambda.indexOf(edges_awaiting_others, edge) > -1)
                        {
                            edges_awaiting_others.splice(Lambda.indexOf(edges_awaiting_others, edge), 1);
                        }
                        if (Lambda.indexOf(edges_awaiting_others, other_edge) > -1)
                        {
                            edges_awaiting_others.splice(Lambda.indexOf(edges_awaiting_others, other_edge), 1);
                        }
                        if (Lambda.indexOf(queue, outgoingMergeEdge) == -1)
                        {
                            queue.push(outgoingMergeEdge);
                        }
                    }
                    //trace("WARNING! Found MERGE node (node_id:" + node.node_id + ") with " + node.outgoing_ports.length + " output ports.");
                    else
                    {
                        
                        // Remove edges from waiting list if they're in there
                        if (Lambda.indexOf(edges_awaiting_others, edge) > -1)
                        {
                            edges_awaiting_others.splice(Lambda.indexOf(edges_awaiting_others, edge), 1);
                        }
                        if (Lambda.indexOf(edges_awaiting_others, other_edge) > -1)
                        {
                            edges_awaiting_others.splice(Lambda.indexOf(edges_awaiting_others, other_edge), 1);
                        }
                    }
                }
                
                //other nodes
                case NodeTypes.SPLIT:{
                    node.outgoing_ports[0].edge.enter_ball_type = edge.exit_ball_type;
                    node.outgoing_ports[0].edge.setEnterProps(edge.getExitProps());
                    if (Lambda.indexOf(queue, node.outgoing_ports[0].edge) == -1)
                    {
                        queue.push(node.outgoing_ports[0].edge);
                    }  //enqueue  
                    if (node.outgoing_ports.length == 2)
                    {
                        node.outgoing_ports[1].edge.enter_ball_type = edge.exit_ball_type;
                        node.outgoing_ports[1].edge.setEnterProps(edge.getExitProps());
                        if (Lambda.indexOf(queue, node.outgoing_ports[1].edge) == -1)
                        {
                            queue.push(node.outgoing_ports[1].edge);
                        }
                    }
                    else
                    {
                        throw new Error("Simulator: split found with # outputs = " + node.outgoing_ports.length);
                    }
                }
                
                case NodeTypes.BALL_SIZE_TEST:{
                    // "Sort" the balls
                    for (i in 0...node.outgoing_ports.length)
                    {
                        var outgoing_port : Port = node.outgoing_ports[i];
                        outgoing_props = node.incoming_ports[0].edge.getExitProps().clone();
                        if (outgoing_port.edge.is_wide)
                        {
                            var _sw5_ = (node.incoming_ports[0].edge.exit_ball_type);                            

                            switch (_sw5_)
                            {
                                case Edge.BALL_TYPE_WIDE, Edge.BALL_TYPE_WIDE_AND_NARROW:
                                    outgoing_port.edge.enter_ball_type = Edge.BALL_TYPE_WIDE;
                                    outgoing_props.setProp(PropDictionary.PROP_NARROW, false);
                                default:
                                    outgoing_port.edge.enter_ball_type = Edge.BALL_TYPE_NONE;
                                    outgoing_props = new PropDictionary();
                                    outgoing_props.setProp(PropDictionary.PROP_NARROW, true);
                            }
                        }
                        else
                        {
                            var _sw6_ = (node.incoming_ports[0].edge.exit_ball_type);                            

                            switch (_sw6_)
                            {
                                case Edge.BALL_TYPE_NARROW, Edge.BALL_TYPE_WIDE_AND_NARROW:
                                    outgoing_port.edge.enter_ball_type = Edge.BALL_TYPE_NARROW;
                                default:
                                    outgoing_port.edge.enter_ball_type = Edge.BALL_TYPE_NONE;
                                    outgoing_props = new PropDictionary();
                            }
                            outgoing_props.setProp(PropDictionary.PROP_NARROW, true);
                        }
                        outgoing_port.edge.setEnterProps(outgoing_props);
                        if (Lambda.indexOf(queue, outgoing_port.edge) == -1)
                        {
                            queue.push(outgoing_port.edge);
                        }
                    }
                }
                
                case NodeTypes.GET:{
                    // Process the GET node when the "VALUE" or "ARGUMENT" edge is reached
                    var getNode : MapGetNode = try cast(node, MapGetNode) catch(e:Dynamic) null;
                    if ((edge == getNode.valueEdge) || (edge == getNode.argumentEdge))
                    {
                        if ((getNode.argumentEdge.exit_ball_type != Edge.BALL_TYPE_UNDETERMINED) &&
                            (getNode.valueEdge.exit_ball_type != Edge.BALL_TYPE_UNDETERMINED))
                        
                        // Process if argument and value have both been determined{
                            
                            node.outgoing_ports[0].edge.enter_ball_type = getNode.getOutputBallType();
                            // Deal with props: no props except narrow
                            node.outgoing_ports[0].edge.setEnterProps(getNode.getOutputProps());
                            // Remove value/argument from queues
                            if (Lambda.indexOf(edges_awaiting_others, getNode.valueEdge) > -1)
                            {
                                edges_awaiting_others.splice(Lambda.indexOf(edges_awaiting_others, getNode.valueEdge), 1);
                            }
                            if (Lambda.indexOf(queue, getNode.valueEdge) > -1)
                            {
                                queue.splice(Lambda.indexOf(queue, getNode.valueEdge), 1);
                            }
                            if (Lambda.indexOf(queue, getNode.argumentEdge) > -1)
                            {
                                queue.splice(Lambda.indexOf(queue, getNode.argumentEdge), 1);
                            }
                            // enqueue outgoing edge
                            if (Lambda.indexOf(queue, node.outgoing_ports[0].edge) == -1)
                            {
                                queue.push(node.outgoing_ports[0].edge);
                            }
                        }
                        else if (edge == getNode.valueEdge)
                        
                        // If argument edge has not made a determination yet, push value edge to the back of the queue and try later{
                            
                            if (Lambda.indexOf(queue, edge) == -1)
                            {
                                queue.push(edge);
                            }
                            if (Lambda.indexOf(edges_awaiting_others, edge) == -1)
                            {
                                edges_awaiting_others.push(edge);
                            }
                        }
                    }
                }
                
                case NodeTypes.CONNECT:{
                    // Apparently there is a possibility that the CONNECT node doesn't have an output
                    if (node.outgoing_ports.length == 1)
                    {
                        node.outgoing_ports[0].edge.enter_ball_type = edge.exit_ball_type;
                        node.outgoing_ports[0].edge.setEnterProps(edge.getExitProps());
                        if (Lambda.indexOf(queue, node.outgoing_ports[0].edge) == -1)
                        {
                            queue.push(node.outgoing_ports[0].edge);
                        }
                    }
                    else
                    {  //trace("WARNING! Found CONNECT node (node_id:" + node.node_id + ") with " + node.outgoing_ports.length + " output ports.");  
                        
                    }
                }
                default:{
                        // Totally random observation: When this next statement was output as a trace() it caused a stack underflow error when compiled with FlashDevelop,
                        // when changed to an Error, it works fine.
                        throw new Error("Flow sensitive PipeSimulator missed a kind of node: " + node.kind);
                    }
            }
            
            if ((queue.length > 0) && (queue.length <= edges_awaiting_others.length))
            
            // If we only have edges that are awaiting others, perform any merges with at least one determined ball type{
                
                // exiting. Perform on non-ghost exiting ball edges first (if any), then proceed to ghost ball exiting edges
                var non_ghost_edge : Edge;
                var ghost_edge : Edge;
                for (j in 0...edges_awaiting_others.length)
                {
                    if (edges_awaiting_others[j].exit_ball_type != Edge.BALL_TYPE_UNDETERMINED)
                    {
                        if (edges_awaiting_others[j].exit_ball_type != Edge.BALL_TYPE_GHOST)
                        {
                            non_ghost_edge = edges_awaiting_others[j];
                            break;
                        }
                        else if (ghost_edge == null)
                        {
                            ghost_edge = edges_awaiting_others[j];
                        }
                    }
                }
                // proceed with non-ghost if any
                var edge_to_proceed : Edge = ((non_ghost_edge != null)) ? non_ghost_edge : ghost_edge;
                if (edge_to_proceed == null)
                
                // If only edges with undetermined ball type, throw Error{
                    
                    throw new Error("Flow sensitive PipeSimulator: Stuck with only edges that require further traversal to proceed "
                    + "(edges that are entering a MERGE node where the other pipe entering hasn't reached this point yet).");
                    queue = new Array<Edge>();
                }
                // Mark other edge's output as ghost (or whatever input ball type is if not undetermined)
                var other_edge_to_proceed : Edge;
                if (edge_to_proceed.to_node.kind == NodeTypes.MERGE)
                {
                    other_edge_to_proceed = getOtherMergeEdge(edge_to_proceed);
                }
                else if (Std.is(edge_to_proceed.to_node, MapGetNode))
                {
                    var mapget : MapGetNode = try cast(edge_to_proceed.to_node, MapGetNode) catch(e:Dynamic) null;
                    other_edge_to_proceed = mapget.argumentEdge;
                }
                if (other_edge_to_proceed.enter_ball_type == Edge.BALL_TYPE_UNDETERMINED)
                {
                    other_edge_to_proceed.enter_ball_type = Edge.BALL_TYPE_GHOST;
                    outgoing_props = new PropDictionary();
                    outgoing_props.setProp(PropDictionary.PROP_NARROW, true);
                    other_edge_to_proceed.setEnterProps(outgoing_props);
                }
                // enqueue other edge, move to top of queue (remove if in queue, then add to beginning)
                if (Lambda.indexOf(edges_awaiting_others, other_edge_to_proceed) > -1)
                {
                    edges_awaiting_others.splice(Lambda.indexOf(edges_awaiting_others, other_edge_to_proceed), 1);
                }
                if (Lambda.indexOf(queue, other_edge_to_proceed) > -1)
                {
                    queue.splice(Lambda.indexOf(queue, other_edge_to_proceed), 1);
                }
                queue.unshift(other_edge_to_proceed);
            }
        }
        
        var latest_ghost_outputs : Int = 0;
        // Check for any ghost outputs on *this* board
        for (edgeK in Reflect.fields(sim_board.outgoingEdgeDictionary))
        {
            var outgoing_vec1 : Array<Edge> = try cast(sim_board.outgoingEdgeDictionary[edgeK], Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
            for (i in 0...outgoing_vec1.length)
            {
                var oEdge1 : Edge = outgoing_vec1[i];
                if ((oEdge1.exit_ball_type == Edge.BALL_TYPE_UNDETERMINED) ||
                    (oEdge1.exit_ball_type == Edge.BALL_TYPE_GHOST))
                {
                    latest_ghost_outputs++;
                }
            }
        }
        //if (DEBUG) { trace("  ["+sim_board.board_name+"] Latest ghost outputs for " + sim_board.board_name + " = " + latest_ghost_outputs); }
        
        /* Here we're looping over any subnetwork board that has pipes that output into this board and was already being simulated (recursive case).
			* We want to:
			* 	Check if there are any "ghost" or "undetermined" outputs:
			*     F: If there are none, this board is ready to be used.
			*     T: If there are any ghost outputs, check for unfinished merges where at least one merge input has a
			*        valid ball type (not "ghost" or "undetermined") and continue with that merge
			*/
        var new_ghost_outputs : Int = 0;
        while (simulate_recursion_boards && (latest_ghost_outputs > 0))
        {
            for (i in 0...recursive_boards.length)
            {
                var recursive_board : BoardNodes = recursive_boards[i];
                // Re-simulate this board, but don't use the current stack of recursive calls, this should allow the top-level
                // board to see the updated output ball types
                //if (DEBUG) { trace("  ["+sim_board.board_name+"] Recursively simulating " + recursive_board.board_name + " within " + sim_board.board_name); }
                boardToConflicts[recursive_board.board_name] = simulateBoard(recursive_board, null, null, false);
                new_ghost_outputs = 0;
                // Check for any ghost outputs on *this* board
                for (edgeK2 in Reflect.fields(sim_board.outgoingEdgeDictionary))
                {
                    var outgoing_vec2 : Array<Edge> = try cast(sim_board.outgoingEdgeDictionary[edgeK2], Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
                    for (i2 in 0...outgoing_vec2.length)
                    {
                        var oEdge2 : Edge = outgoing_vec2[i2];
                        if ((oEdge2.exit_ball_type == Edge.BALL_TYPE_UNDETERMINED) ||
                            (oEdge2.exit_ball_type == Edge.BALL_TYPE_GHOST))
                        {
                            new_ghost_outputs++;
                        }
                    }
                }
                //if (DEBUG) { trace("  ["+sim_board.board_name+"] New ghost outputs = " + new_ghost_outputs); }
                // If we reach zero ghost outputs, that's good enough for this level - exit the routine
                if (new_ghost_outputs == 0)
                {
                    break;
                }
            }
            
            if (new_ghost_outputs >= latest_ghost_outputs)
            
            // We aren't making progress, infinite loop suspected. Just assign outputs and continue{
                
                for (edgeK3 in Reflect.fields(sim_board.outgoingEdgeDictionary))
                {
                    var outgoing_vec3 : Array<Edge> = try cast(sim_board.outgoingEdgeDictionary[edgeK3], Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
                    for (i in 0...outgoing_vec3.length)
                    {
                        var oEdge3 : Edge = outgoing_vec3[i];
                        if ((oEdge3.exit_ball_type == Edge.BALL_TYPE_UNDETERMINED) ||
                            (oEdge3.exit_ball_type == Edge.BALL_TYPE_GHOST))
                        {
                            outgoing_props = oEdge3.getEnterProps().clone();
                            if (oEdge3.is_wide)
                            {
                                oEdge3.exit_ball_type = Edge.BALL_TYPE_WIDE;
                                outgoing_props.setProp(PropDictionary.PROP_NARROW, false);
                                oEdge3.setExitProps(outgoing_props);
                            }
                            else
                            {
                                oEdge3.exit_ball_type = Edge.BALL_TYPE_NARROW;
                                outgoing_props.setProp(PropDictionary.PROP_NARROW, true);
                                oEdge3.setExitProps(outgoing_props);
                            }
                        }
                    }
                }
                new_ghost_outputs = 0;
            }
            
            latest_ghost_outputs = new_ghost_outputs;
        }
        
        // Remove sim_board from boards_in_progress, this board's outgoing exit ball types have been updated at this point
        boards_in_progress.splice(Lambda.indexOf(boards_in_progress, sim_board), 1);
        sim_board.changed_since_last_sim = false;
        
        //if (DEBUG) { trace("----Finished simulating board: " + sim_board.board_name + "----"); }
        
        return conflictDict;
    }
    
    private static function getOtherMergeEdge(edge : Edge) : Edge
    {
        var node : Node = edge.to_node;
        var other_edge : Edge;
        if (node.incoming_ports[0] == edge.to_port)
        {
            return node.incoming_ports[1].edge;
        }
        else if (node.incoming_ports[1] == edge.to_port)
        {
            return node.incoming_ports[0].edge;
        }
        else
        {
            throw new Error("MERGE node encountered which didn't link to the edge's port. Edge: " + edge.edge_id);
        }
        return null;
    }
    
    private static function cloneDict(dict : Dictionary) : Dictionary
    {
        var newDict : Dictionary = new Dictionary();
        for (oldKey in Reflect.fields(dict))
        {
            Reflect.setField(newDict, oldKey, Reflect.field(dict, oldKey));
        }
        return newDict;
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
