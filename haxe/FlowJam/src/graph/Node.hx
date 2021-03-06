package graph;

import flash.errors.Error;
import flash.utils.Dictionary;
import graph.Edge;
import system.VerigameServerConstants;
import utils.Metadata;
import flash.geom.Point;

/**
	 * Directed Graph Node created when a graph structure is read in from XML (or internally for pipe objects - but this is being deprecated)
	 * 
	 * Incoming and outgoing edges each have a to_port (for incoming) or from_port (for outgoing) that correspond to this node.
	 * 
	 */
class Node
{
    
    /** X coordinate of the center of this node in board space (where 0, 0 is the top left of the board and it extends to board.max_pipe_width, board.max_pipe_height) */
    public var x : Float;
    
    /** Y coordinate of center of this node in board space (where 0, 0 is the top left of the board and it extends to board.max_pipe_width, board.max_pipe_height) */
    public var y : Float;
    
    /** Parametric coordinate of this node in pipe space (where 0 is typically the top of the pipe and t extends downward to pipe.current_t at the bottom) */
    public var t : Float;
    
    /** String describing the type of node - the entire list is contained in the NodeTypes class */
    public var kind : String;
    
    /** Extra information about this node (for example: any attributes in the original XML object) */
    public var metadata : Dynamic;
    
    /** All ports for edges that end at this node */
    public var incoming_ports : Array<Port>;
    
    /** All ports for edges that originate from this node */
    public var outgoing_ports : Array<Port>;
    
    /** Ports listed by port_id */
    private var incoming_port_dict : Dynamic = {};
    private var outgoing_port_dict : Dynamic = {};
    
    /** The unique id given as input from XML (unique within a given world) */
    public var node_id : String;
    
    /** True if start node/incoming node */
    public var isOriginationNode : Bool = false;
    
    /**
		 * Directed Graph Node created when a graph structure is read in from XML (or internally for pipe objects - but this is being deprecated)
		 * @param	_x X coordinate of this node in board space
		 * @param	_y Y coordinate of this node in board space
		 * @param	_t Parametric coordinate of this node in pipe object space
		 * @param	_kind String describing the type of node (Ex: SPLIT, MERGE, etc)
		 * @param	_metadata Extra information about this node (for example: any attributes in the original XML object)
		 */
    public function new(_x : Float, _y : Float, _t : Float, _kind : String, _metadata : Dynamic = null)
    {
        x = _x;
        y = _y;
        t = _t;
        kind = _kind;
        metadata = _metadata;
        if (_metadata == null)
        {
            metadata = new Metadata(null);
        }
        else if (_metadata.data != null)
        {
            if (_metadata.data.id != null)
            {
                if (Std.string(_metadata.data.id).length > 0)
                {
                    node_id = Std.string(_metadata.data.id);
                }
            }
        }
        
        metadata = null;
        incoming_ports = new Array<Port>();
        outgoing_ports = new Array<Port>();
        
        switch (kind)
        {
            case NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.START_SMALL_BALL, NodeTypes.INCOMING:
                isOriginationNode = true;
        }
    }
    
    /**
		 * Creates an outgoing edge object and links it to the desired destination node
		 * @param	_outgoing_port Port on this node to be associated with the new outgoing edge
		 * @param	_destination_node Destination node to be associated with the new outgoing edge
		 * @param	_destination_port Port on destination node to be associated with the new outgoing edge
		 * @param	_metadata Extra information about this edge (for example: any attributes in the original XML object)
		 */
    public function addOutgoingEdge(_outgoing_port : String, _destination_node : Node, _destination_port : String, _linked_edge_set : EdgeSetRef, _levelName : String, _metadata : Dynamic = null) : Edge
    {
        var new_edge : Edge = new Edge(this, _outgoing_port, _destination_node, _destination_port, _linked_edge_set, _metadata);
        _linked_edge_set.addEdge(new_edge, _levelName);
        outgoing_ports.push(new_edge.from_port);
        _destination_node.connectIncomingEdge(new_edge);
        if (Reflect.hasField(outgoing_port_dict, new_edge.from_port.port_id))
        {
            throw new Error("Attempting to add more than one port for outgoing port id:" + new_edge.from_port.port_id);
        }
		Reflect.setField(outgoing_port_dict, new_edge.from_port.port_id, new_edge.from_port);
        return new_edge;
    }
    
    /**
		 * Connect an incoming edge to this node 
		 * @param	_e Edge to be connected/linked to this node
		 */
    public function connectIncomingEdge(_edge : Edge) : Void
    {
        incoming_ports.push(_edge.to_port);
        if (Reflect.hasField(incoming_port_dict, _edge.to_port.port_id))
        {
            throw new Error("Attempting to add more than one port for incoming port id:" + _edge.to_port.port_id);
        }
		Reflect.setField(incoming_port_dict, _edge.to_port.port_id, _edge.to_port);
    }
    
    public function getIncomingPort(_portId : String) : Port
    {
        return Reflect.field(incoming_port_dict, _portId);
    }
    
    public function getOutgoingPort(_portId : String) : Port
    {
        return Reflect.field(outgoing_port_dict, _portId);
    }
    
    /**
		 * This orders the incoming and outgoing edges from smallest port to largest port (Ex: 0, 2, 4, 5, 6)
		 * This is used when drawing the incoming pipes to a subnetwork node, as the pipe order should be consistent from
		 * smallest to largest port, as it will appear on the zoomed in version of the board (if clicked).
		 */
    public function orderEdgesByPort() : Void
    {
        incoming_ports.sort(function(x : Port, y : Port) : Int
        {
            if ((try cast(x, Port) catch(e:Dynamic) null).port_id < (try cast(y, Port) catch(e:Dynamic) null).port_id)
            {
                return -1;
            }
            if ((try cast(x, Port) catch(e:Dynamic) null).port_id > (try cast(y, Port) catch(e:Dynamic) null).port_id)
            {
                return 1;
            }
            return 0;
        });
        outgoing_ports.sort(function(x : Port, y : Port) : Int
        {
            if ((try cast(x, Port) catch(e:Dynamic) null).port_id < (try cast(y, Port) catch(e:Dynamic) null).port_id)
            {
                return -1;
            }
            if ((try cast(x, Port) catch(e:Dynamic) null).port_id > (try cast(y, Port) catch(e:Dynamic) null).port_id)
            {
                return 1;
            }
            return 0;
        });
    }
}
