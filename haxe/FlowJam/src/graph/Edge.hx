package graph;

import events.ConflictChangeEvent;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import events.EdgePropChangeEvent;
import graph.Node;
import utils.Metadata;

/**
	 * Directed Edge created when a graph structure is read in from XML.
	 */
class Edge extends EventDispatcher
{
    public var from_node(get, never) : Node;
    public var to_node(get, never) : Node;
    public var from_port_id(get, never) : String;
    public var to_port_id(get, never) : String;
    public var enter_ball_type(get, set) : Int;
    public var exit_ball_type(get, set) : Int;
    public var is_wide(get, never) : Bool;

    // ### BALL_TYPES ### \\
    //renumbered so you can now BIT AND these together, as needed.
    //Now you can & STARRED with the other types
    //Left wide_and_narrow combination so I don't have to rework code
    public static inline var BALL_TYPE_NONE : Int = 0;
    public static inline var BALL_TYPE_NARROW : Int = 1;
    public static inline var BALL_TYPE_WIDE : Int = 2;
    public static inline var BALL_TYPE_WIDE_AND_NARROW : Int = 3;
    public static inline var BALL_TYPE_STARRED : Int = 4;
    public static inline var BALL_TYPE_UNDETERMINED : Int = 8;
    public static inline var BALL_TYPE_GHOST : Int = 16;  // used for recursion  
    // ### END BALL_TYPES ### \\
    
    /* Network connections */
    /** Port on source node */
    public var from_port : Port;
    
    /** Port on destination node */
    public var to_port : Port;
    
    /** Any extra information contained in the orginal XML for this edge */
    public var metadata : Dynamic;
    
    /** The numerical index (starting at 0 = first) corresponding to the linked edge set (by level) that this edge belongs to */
    public var linked_edge_set : EdgeSetRef;
    
    /* Edge identifiers */
    /** Name of the variable provided in XML */
    public var description : String = "";
    
    /** The unique id given as input from XML (unique within a given world) */
    public var edge_id : String;
    
    /** Id of the variable identified in XML */
    public var variableID : Int;
    
    /** pointers back up to all starting edges that can reach this edge. */
    public var topmostEdgeDictionary : Dynamic = {};
    public var topmostEdgeIDArray : Array<Dynamic> = new Array<Dynamic>();
    
    /* Starting state of the pipe */
    /** True if edge has attribute width="wide" in XML, false otherwise */
    public var starting_is_wide : Bool = false;
    
    /** True if edge has attribute buzzsaw="true" in XML, false otherwise */
    public var starting_has_buzzsaw : Bool = false;
    
    /** True if this edge's width can be changed by the user, if false pipe is gray and cannot be changed */
    public var editable : Bool = false;
    
    /** True if edge has attribute buzzsaw="true" in XML, false otherwise */
    public var has_buzzsaw : Bool = false;
    
    /** True if this edge contains a pinch point, false otherwise */
    public var has_pinch : Bool = false;
    
    /** used to mark nodes that think they are starting nodes, and we check later if they actually are. 
		 I think this is only a situation that arises on mismade boards (like some I hand created) but I'll handle the case anyway as it helps with debugging
		*/
    public var isStartingNode : Bool;
    
    // The following five vars are used to plug in the PipeSimulator and detecting ball type changes:
    private var m_enter_ball_type : Int = BALL_TYPE_UNDETERMINED;
    private var m_exit_ball_type : Int = BALL_TYPE_UNDETERMINED;
    private var m_prev_enter_ball_type : Int = BALL_TYPE_UNDETERMINED;
    private var m_prev_exit_ball_type : Int = BALL_TYPE_UNDETERMINED;
    
    // Testbed:
    private var m_enterProps : PropDictionary = new PropDictionary();
    private var m_exitProps : PropDictionary = new PropDictionary();
    private var m_conflictProps : PropDictionary = new PropDictionary();
    
    /**
		 * Directed Edge created when a graph structure is read in from XML.
		 * @param	_from_node Source node
		 * @param	_from_port Port on source node
		 * @param	_to_node Destination node
		 * @param	_to_port Port on destination node
		 * @param	_metadata Extra information about this edge (for example: any attributes in the original XML object)
		 */
    public function new(_from_node : Node, _from_port_id : String, _to_node : Node, _to_port_id : String, _linked_edge_set : EdgeSetRef = null, _metadata : Dynamic = null)
    {
        super();
        if (Std.is(_from_node, SubnetworkNode))
        {
            from_port = new SubnetworkPort((try cast(_from_node, SubnetworkNode) catch(e:Dynamic) null), this, _from_port_id, Port.OUTGOING_PORT_TYPE);
        }
        else
        {
            from_port = new Port(_from_node, this, _from_port_id, Port.OUTGOING_PORT_TYPE);
        }
        
        if (Std.is(_to_node, SubnetworkNode))
        {
            to_port = new SubnetworkPort((try cast(_to_node, SubnetworkNode) catch(e:Dynamic) null), this, _to_port_id, Port.INCOMING_PORT_TYPE);
        }
        else
        {
            to_port = new Port(_to_node, this, _to_port_id, Port.INCOMING_PORT_TYPE);
        }
        
        metadata = _metadata;
        linked_edge_set = _linked_edge_set;
        if (_metadata == null)
        {
            metadata = new Metadata(null);
        }
        else if (_metadata.data != null)
        {
        //Example: <edge description="chute1" variableID="-1" pinch="false" width="wide" id="e1" buzzsaw="false">
            
            if (Std.string(_metadata.data.id).length > 0)
            {
                edge_id = Std.string(_metadata.data.id);
            }
            if (metadata.data.description)
            {
                if (Std.string(metadata.data.description).length > 0)
                {
                    description = Std.string(metadata.data.description);
                }
            }
            if (metadata.data.variableID)
            {
                if (!Math.isNaN(as3hx.Compat.parseInt(metadata.data.variableID)))
                {
                    variableID = as3hx.Compat.parseInt(metadata.data.variableID);
                }
            }
            if (Std.string(metadata.data.pinch).toLowerCase() == "true")
            {
                has_pinch = true;
            }
            if (Std.string(metadata.data.editable).toLowerCase() == "true")
            {
                editable = true;
            }
            if (!linked_edge_set.propsInitialized)
            {
                linked_edge_set.editable = editable;
            }
            else if (linked_edge_set.editable != editable)
            {
                trace("WARNING! Edge doesn't match linked edge set, edge_id " + edge_id + " editable:" + editable + ", edge_set_id:" + linked_edge_set.id + " editable:" + linked_edge_set.editable);
                editable = linked_edge_set.editable;
            }
            if (Std.string(metadata.data.width).toLowerCase() == "wide")
            {
                starting_is_wide = true;
            }
            if (!linked_edge_set.propsInitialized)
            {
                linked_edge_set.setProp(PropDictionary.PROP_NARROW, !starting_is_wide);
            }
            else if (linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW) == starting_is_wide)
            {
                trace("WARNING! Edge doesn't match linked edge set, edge_id " + edge_id + " narrow?:" + !starting_is_wide + ", edge_set_id:" + linked_edge_set.id + " narrow?:" + linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW));
                starting_is_wide = !linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW);
            }
            linked_edge_set.propsInitialized = true;
        }
        
        metadata = null;
    }
    
    public function isStartingEdge() : Bool
    {
        var _sw1_ = (from_node.kind);        

        switch (_sw1_)
        {
            case NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_SMALL_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.INCOMING:
            //	case NodeTypes.SUBBOARD:
            return true;
        }
        
        return false;
    }
    
    private function get_from_node() : Node
    {
        return from_port.node;
    }
    
    private function get_to_node() : Node
    {
        return to_port.node;
    }
    
    private function get_from_port_id() : String
    {
        return from_port.port_id;
    }
    
    private function get_to_port_id() : String
    {
        return to_port.port_id;
    }
    
    private function get_enter_ball_type() : Int
    {
        return m_enter_ball_type;
    }
    
    private function get_exit_ball_type() : Int
    {
        return m_exit_ball_type;
    }
    
    private function set_enter_ball_type(typ : Int) : Int
    {
        if (ballUnknown(typ) && !ballUnknown(m_enter_ball_type))
        {
        // If setting a ball to be UNDETERMINED/GHOST to begin sim, keep previous type to compare after sim
            
            m_prev_enter_ball_type = m_enter_ball_type;
            m_enter_ball_type = typ;
        }
        else if (!ballUnknown(typ))
        {
        // If setting a type to a KNOWN ball type (done simulating, for example) record change
            
            m_enter_ball_type = typ;
            if (m_prev_enter_ball_type != m_enter_ball_type)
            {
                dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.ENTER_BALL_TYPE_CHANGED, this, null, null, m_prev_enter_ball_type, m_enter_ball_type));
            }
            m_prev_enter_ball_type = m_enter_ball_type;
        }
        // Was unknown, still unknown - simply make the change
        else
        {
            
            m_enter_ball_type = typ;
        }
        return typ;
    }
    
    private function set_exit_ball_type(typ : Int) : Int
    {
        if (ballUnknown(typ) && !ballUnknown(m_exit_ball_type))
        {
        // If setting a ball to be UNDETERMINED/GHOST to begin sim, keep previous type to compare after sim
            
            m_prev_exit_ball_type = m_exit_ball_type;
            m_exit_ball_type = typ;
        }
        else if (!ballUnknown(typ))
        {
        // If setting a type to a KNOWN ball type (done simulating, for example) record change
            
            m_exit_ball_type = typ;
            if (m_prev_exit_ball_type != m_exit_ball_type)
            {
                dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.EXIT_BALL_TYPE_CHANGED, this, null, null, m_prev_exit_ball_type, m_exit_ball_type));
            }
            m_prev_exit_ball_type = m_exit_ball_type;
        }
        // Was unknown, still unknown - simply make the change
        else
        {
            
            m_exit_ball_type = typ;
        }
        return typ;
    }
    
    // Set this edge to UNDETERMINED and outgoing Edge's
    public function resetPropsAndRecurse() : Void
    {
        m_enterProps = new PropDictionary();
        m_exitProps = new PropDictionary();
        //m_conflictProps = new PropDictionary();
        if ((m_enter_ball_type == BALL_TYPE_UNDETERMINED) && (m_exit_ball_type == BALL_TYPE_UNDETERMINED))
        {
            return;
        }
        m_enter_ball_type = BALL_TYPE_UNDETERMINED;
        m_exit_ball_type = BALL_TYPE_UNDETERMINED;
        for (outport in to_port.node.outgoing_ports)
        {
            outport.edge.resetPropsAndRecurse();
        }
    }
    
    public function addConflict(prop : String) : Void
    {
        if (hasConflictProp(prop))
        {
            return;
        }
        m_conflictProps.setProp(prop, true);
        dispatchEvent(new ConflictChangeEvent());
    }
    
    public function removeConflict(prop : String) : Void
    {
        if (!hasConflictProp(prop))
        {
            return;
        }
        m_conflictProps.setProp(prop, false);
        dispatchEvent(new ConflictChangeEvent());
    }
    
    private function ballUnknown(typ : Int) : Bool
    {
        switch (typ)
        {
            case BALL_TYPE_UNDETERMINED, BALL_TYPE_GHOST:
                return true;
        }
        return false;
    }
    
    private function get_is_wide() : Bool
    {
        return !linked_edge_set.getProps().hasProp(PropDictionary.PROP_NARROW);
    }
    
    /**
		 * Traverse upsteam returning any editable edge sets that may have set the desired property/value
		 * combination for this edge (the edge set of the starting edges that this edge originated
		 * from)
		 * @param	prop Property of intereset
		 * @param	value Value of property of interest
		 * @return List of editable starting edgeSets upstream matching desired prop, value
		 */
    public function getOriginatingEdgeSetsMatchingPropValue(prop : String, value : Bool) : Array<EdgeSetRef>
    {
        var edgeSets : Array<EdgeSetRef> = new Array<EdgeSetRef>();
        var edgesToExamine : Array<Edge> = new Array<Edge>();
        var edgesExamined : Dynamic = {};
        edgesToExamine.push(this);
        while (edgesToExamine.length > 0)
        {
            var thisEdge : Edge = edgesToExamine.shift();
            if (Reflect.hasField(edgesExamined, thisEdge.edge_id))
            {
                continue;
            }
			Reflect.setField(edgesExamined, thisEdge.edge_id, true);
            if (thisEdge.from_node == null)
            {
                continue;
            }
            // Test for originating set and matching this prop
            if (thisEdge.from_node.isOriginationNode &&
                thisEdge.linked_edge_set.editable &&
                (thisEdge.linked_edge_set.getProps().hasProp(prop) == value) &&
                (Lambda.indexOf(edgeSets, thisEdge.linked_edge_set) == -1))
            {
                edgeSets.push(thisEdge.linked_edge_set);
            }
            var nextPorts : Array<Port> = thisEdge.from_node.incoming_ports;
            if (Std.is(thisEdge.from_port, SubnetworkPort))
            {
            // Connect through subnet if possible, otherwise don't bother
                
                var subnetPort : SubnetworkPort = try cast(thisEdge.from_port, SubnetworkPort) catch(e:Dynamic) null;
                nextPorts = new Array<Port>();
                if (subnetPort != null && subnetPort.linked_subnetwork_edge != null && subnetPort.linked_subnetwork_edge.to_port != null)
                {
                    nextPorts.push(subnetPort.linked_subnetwork_edge.to_port);
                }
            }
            for (i in 0...nextPorts.length)
            {
                var nextEdge : Edge = nextPorts[i].edge;
                if (nextEdge == null)
                {
                    continue;
                }
                if (nextEdge.getExitProps().hasProp(prop) != value)
                {
                    continue;
                }
                // Only continue upstream thru value or argument (if keyfor)
                if (thisEdge.from_node.kind == NodeTypes.GET)
                {
                    var map : MapGetNode = try cast(thisEdge.from_node, MapGetNode) catch(e:Dynamic) null;
                    if ((nextEdge == map.mapEdge) || (nextEdge == map.keyEdge))
                    {
                        continue;
                    }
                    if ((prop == PropDictionary.PROP_NARROW) && (nextEdge != map.valueEdge))
                    {
                        continue;
                    }
                    if ((prop == PropDictionary.PROP_NARROW) && !map.argumentHasMapStamp())
                    {
                        continue;
                    }
                }
                if (Reflect.hasField(edgesExamined, nextEdge.edge_id))
                {
                    continue;
                }
                edgesToExamine.push(nextEdge);
            }
        }
        return edgeSets;
    }
    
    /**
		 * Traverse down the edge and out_node, continuing through any edges originating in an edge-set
		 * traversed, return any editable edgeSets matching desired prop, value
		 * @param	prop Property of intereset
		 * @param	value Value of property of interest
		 * @return List of editable edgeSets matching desired prop, value
		 */
    public function getDownStreamEdgeSetsMatchingPropValue(prop : String, value : Bool, levelName : String) : Array<EdgeSetRef>
    {
        var edgeSets : Array<EdgeSetRef> = new Array<EdgeSetRef>();
        var edgesToExamine : Array<Edge> = new Array<Edge>();
        var edgesExamined : Dynamic = {};
        edgesToExamine.push(this);
        while (edgesToExamine.length > 0)
        {
            var thisEdge : Edge = edgesToExamine.shift();
            if (Reflect.hasField(edgesExamined, thisEdge.edge_id))
            {
                continue;
            }
			Reflect.setField(edgesExamined, thisEdge.edge_id, true);
            if (!thisEdge.linked_edge_set.editable)
            {
                continue;
            }
            if (!thisEdge.linked_edge_set.getProps().hasProp(prop) == value)
            {
                continue;
            }
            // Special case: skip pinched edges, they are essentially uneditable
            if (thisEdge.has_pinch && (prop == PropDictionary.PROP_NARROW))
            {
                continue;
            }
            if (Lambda.indexOf(edgeSets, thisEdge.linked_edge_set) == -1)
            {
                edgeSets.push(thisEdge.linked_edge_set);
                // Continue with any edges originating from this edge set
                var levelEdges : Array<Edge> = thisEdge.linked_edge_set.getLevelEdges(levelName);
                for (oe in 0...levelEdges.length)
                {
                    var outEdge : Edge = levelEdges[oe];
                    if (outEdge == null)
                    {
                        continue;
                    }
                    if (!outEdge.isStartingEdge())
                    {
                        continue;
                    }
                    if (Reflect.hasField(edgesExamined, outEdge.edge_id))
                    {
                        continue;
                    }
                    edgesToExamine.push(outEdge);
                }
            }
            // Continue through to_node
            var toNode : Node = thisEdge.to_node;
            if (toNode == null)
            {
                continue;
            }
            // Special cases: GET/SUBBOARD stop downstream traversal for most cases
            var nextPorts : Array<Port> = toNode.outgoing_ports;
            var map : MapGetNode = null;
            var _sw2_ = (toNode.kind);            

            switch (_sw2_)
            {
                // Continue to connecting INCOMING edge if possible, otherwise don't continue
                case NodeTypes.SUBBOARD:
                    nextPorts = new Array<Port>();
                    if (Std.is(thisEdge.to_port, SubnetworkPort))
                    {
                        var subnetPort : SubnetworkPort = try cast(thisEdge.to_port, SubnetworkPort) catch(e:Dynamic) null;
                        if (subnetPort.linked_subnetwork_edge != null && subnetPort.linked_subnetwork_edge.from_port != null)
                        {
                            nextPorts.push(subnetPort.linked_subnetwork_edge.from_port);
                        }
                    }
                // Only continue upstream thru value or argument (if keyfor)
                case NodeTypes.GET:
                    map = try cast(toNode, MapGetNode) catch(e:Dynamic) null;
            }
            for (op in 0...nextPorts.length)
            {
                var nextEdge : Edge = nextPorts[op].edge;
                if (nextEdge == null)
                {
                    continue;
                }
                // Skip mapget node for most cases
                if (map != null && (nextEdge == map.mapEdge))
                {
                    continue;
                }
                if (map != null && (nextEdge == map.keyEdge))
                {
                    continue;
                }
                if (map != null && !map.argumentHasMapStamp())
                {
                    continue;
                }
                if (Reflect.hasField(edgesExamined, nextEdge.edge_id))
                {
                    continue;
                }
                edgesToExamine.push(nextEdge);
            }
        }
        return edgeSets;
    }
    
    public function setEnterProps(props : PropDictionary) : Void
    {
        dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.ENTER_PROPS_CHANGED, this, m_enterProps.clone(), props.clone()));
        m_enterProps = props.clone();
    }
    
    public function setExitProps(props : PropDictionary) : Void
    {
        dispatchEvent(new EdgePropChangeEvent(EdgePropChangeEvent.EXIT_PROPS_CHANGED, this, m_exitProps.clone(), props.clone()));
        m_exitProps = props.clone();
    }
    
    public function getEnterProps() : PropDictionary
    {
        return m_enterProps;
    }
    
    public function getExitProps() : PropDictionary
    {
        return m_exitProps;
    }
    
    public function getConflictProps() : PropDictionary
    {
        return m_conflictProps;
    }
    
    // Testbed:
    public function hasConflictProp(prop : String) : Bool
    {
        return m_conflictProps.hasProp(prop);
    }
    
    public function hasAnyConflict() : Bool
    {
        for (prop in Reflect.fields(m_conflictProps.iterProps()))
        {
            return true;
        }
        return false;
    }
}
