package networkGraph;

import utilities.NameObfuscater;
import utilities.XString;
import flash.utils.Dictionary;

class Network
{
    /**
		 * Collection of Nodes (and their associated edges contained within) arranged by level. This is what is created by LevelLayout when after XML input is processed.
		 */
    public var world_name : String;
    public var original_world_name : String;
    public var obfuscator : NameObfuscater;
    
    /** Dictionary mapping edge ids to edges */
    //static because edges are created before the network object
    public static var edgeDictionary : Dictionary = new Dictionary();
    
    /** This is a dictionary of LevelNodes, which is a dictionary of BoardNodes, which is a dictionary of Nodes; INDEXED BY LEVEL NAME, BOARD NAME, AND NODE ID, RESPECTIVELY */
    public var worldNodesDictionary : Dictionary = new Dictionary();
    
    public function new(_original_world_name : String, _world_index : Int = 1, _obfuscate_names : Bool = true)
    {
        original_world_name = _original_world_name;
        if (_obfuscate_names)
        {
            world_name = "World " + _world_index;
            var my_seed : Int = XString.stringToInt(world_name);
            obfuscator = new NameObfuscater(my_seed);
        }
        else
        {
            world_name = _original_world_name;
        }
    }
    
    public function addNode(_node : Node, _original_board_name : String, _original_level_name : String) : Void
    {
        var new_level_name : String = _original_level_name;
        if (obfuscator != null)
        {
            new_level_name = obfuscator.getLevelName(_original_level_name);
        }
        if (Reflect.field(worldNodesDictionary, new_level_name) == null)
        {
            Reflect.setField(worldNodesDictionary, new_level_name, new LevelNodes(_original_level_name, obfuscator));
        }
        (try cast(Reflect.field(worldNodesDictionary, new_level_name), LevelNodes) catch(e:Dynamic) null).addNode(_node, _original_board_name);
    }
    
    public function getNode(_original_level_name : String, _original_board_name : String, _node_id : String) : Node
    {
        var new_level_name : String = obfuscator.getLevelName(_original_level_name);
        var new_board_name : String = obfuscator.getBoardName(_original_board_name, _original_level_name);
        if (Reflect.field(worldNodesDictionary, new_level_name) != null)
        {
            if ((try cast(Reflect.field(worldNodesDictionary, new_level_name), LevelNodes) catch(e:Dynamic) null).boardNodesDictionary[new_board_name] != null)
            {
                return (try cast((try cast(Reflect.field(worldNodesDictionary, new_level_name), LevelNodes) catch(e:Dynamic) null).boardNodesDictionary[new_board_name], BoardNodes) catch(e:Dynamic) null).nodeDictionary[_node_id];
            }
        }
        return null;
    }
    
    //collect all outgoing edges belonging to nodes that start balls, and then
    //trace downward, marking each edge with a pointer to that topmost edge.
    public function setTopMostEdgeInEdges() : Void
    //map from edge id to edge
    {
        
        var topMostEdgeSet : Dictionary = new Dictionary();
        
        for (edgeID in Reflect.fields(edgeDictionary))
        {
            var edge : Edge = Reflect.field(edgeDictionary, edgeID);
            if (edge.from_node.kind == NodeTypes.START_PIPE_DEPENDENT_BALL ||
                edge.from_node.kind == NodeTypes.START_LARGE_BALL ||
                edge.from_node.kind == NodeTypes.START_SMALL_BALL ||
                edge.from_node.kind == NodeTypes.INCOMING)
            {
                topMostEdgeSet[edge.edge_id] = edge;
            }
        }
        
        for (topEdgeID in Reflect.fields(topMostEdgeSet))
        {
            var topEdge : Edge = Reflect.field(topMostEdgeSet, topEdgeID);
            markChildrenWithTopEdges(topEdge, topEdge);
        }
    }
    
    //mark current, and then recursively call on outgoing edges
    public function markChildrenWithTopEdges(topEdge : Edge, currentEdge : Edge) : Void
    //if we aren't in the dictionary currently, add ourselves
    {
        
        if (currentEdge.topmostEdgeDictionary[topEdge.edge_id] == null)
        {
            currentEdge.topmostEdgeIDArray[currentEdge.topmostEdgeIDArray.length] = topEdge.edge_id;
            currentEdge.topmostEdgeDictionary[topEdge.edge_id] = topEdge;
            if (currentEdge.topmostEdgeIDArray.length > 1)
            {
                var debugVar : Int = 3;
            }
        }
        var node : Node = currentEdge.to_node;
        for (outgoingPortID in Reflect.fields(node.outgoing_ports))
        {
            var outgoingPort : Port = node.outgoing_ports[outgoingPortID];
            var outgoingEdge : Edge = outgoingPort.edge;
            
            
            markChildrenWithTopEdges(topEdge, outgoingEdge);
        }
    }
    
    public function updateEdgeSetWidth(edgeSet : EdgeSetRef, isWide : Bool) : Void
    {
        for (edgeID/* AS3HX WARNING could not determine type for var: edgeID exp: EField(EIdent(edgeSet),edge_ids) type: null */ in edgeSet.edge_ids)
        {
            var edge : Edge = edgeDictionary[edgeID];
            edge.updateEdgeWidth(isWide);
        }
    }
}

