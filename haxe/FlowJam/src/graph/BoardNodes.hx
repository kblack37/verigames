package graph;

import flash.errors.Error;
import flash.utils.Dictionary;

class BoardNodes
{
    public var startingEdgeDictionary(get, never) : Dictionary;
    public var outgoingEdgeDictionary(get, never) : Dictionary;

    /** Board name (may be obfuscated) */
    public var board_name : String;
    
    /** Original board name from XML (unobfuscated) */
    public var original_board_name : String;
    
    /** This is a dictionary of Nodes; INDEXED BY NODE_ID */
    public var nodeDictionary : Dictionary = new Dictionary();
    public var nodeIDArray : Array<Dynamic> = new Array<Dynamic>();
    
    /** The names of any boards that appear on this board */
    public var subboardNames : Array<String> = new Array<String>();
    
    /** Any nodes that represent the beginning of a pipe, either INCOMING OR START_* OR SUBBOARD with no incoming edges */
    public var beginningNodes : Array<Node> = new Array<Node>();
    
    /** Map from edge set id to all starting edges for that edge set ON THIS BOARD (no other boards) */
    private var m_startingEdgeDictionary : Dictionary;
    
    /** Map from edge set id to all OUTGOING edges for that edge set ON THIS BOARD (no other boards) */
    private var m_outgoingEdgeDictionary : Dictionary;
    
    /** True if a change in pipe width or buzzsaw was made since the last simulation */
    public var changed_since_last_sim : Bool = true;
    /** True if a simulation has been run on this board */
    public var simulated : Bool = false;
    /** True if the board is being checked for trouble points */
    public var simulating : Bool = false;
    
    public var metadata : Dictionary = new Dictionary();
    /** After all BoardNodes are created, we want to associate all SubnetNodes with their appropriate BoardNodes */
    public var subnetNodesToAssociate : Array<SubnetworkNode> = new Array<SubnetworkNode>();
    
    public var incoming_node : Node;
    public var outgoing_node : Node;
    public var is_stub : Bool;
    
    public function new(_obfuscated_board_name : String, _original_board_name : String, _is_stub : Bool = false)
    {
        board_name = _obfuscated_board_name;
        original_board_name = _original_board_name;
        is_stub = _is_stub;
    }
    
    public function addNode(_node : Node) : Void
    {
        if (!nodeDictionary.exists(_node.node_id))
        {
            nodeDictionary[_node.node_id] = _node;
            nodeIDArray.push(_node.node_id);
            var ip : Port;
            var op : Port;
            var _sw0_ = (_node.kind);            

            switch (_sw0_)
            {
                case NodeTypes.SUBBOARD:
                    if ((try cast(_node, SubnetworkNode) catch(e:Dynamic) null).subboard_name.length > 0)
                    {
                        if (Lambda.indexOf(subboardNames, (try cast(_node, SubnetworkNode) catch(e:Dynamic) null).subboard_name) == -1)
                        {
                            subboardNames.push((try cast(_node, SubnetworkNode) catch(e:Dynamic) null).subboard_name);
                        }
                    }
                    subnetNodesToAssociate.push(try cast(_node, SubnetworkNode) catch(e:Dynamic) null);
                    if (Lambda.indexOf(beginningNodes, _node) == -1)
                    {
                        beginningNodes.push(_node);
                    }
                case NodeTypes.OUTGOING:
                //						if (outgoing_node) {
                //							throw new Error("Board found with multiple outgoing nodes: " + original_board_name + " nodes:" + outgoing_node.node_id + " & " + _node.node_id);
                //						}
                outgoing_node = _node;
                case NodeTypes.INCOMING, NodeTypes.START_LARGE_BALL, NodeTypes.START_NO_BALL, NodeTypes.START_PIPE_DEPENDENT_BALL, NodeTypes.START_SMALL_BALL:

                    switch (_sw0_)
                    {case NodeTypes.INCOMING:
                        //						if (incoming_node) {
                        //							throw new Error("Board found with multiple incoming nodes: " + original_board_name + " nodes:" + incoming_node.node_id + " & " + _node.node_id);
                        //						}
                        incoming_node = _node;
                    }
                    if (Lambda.indexOf(beginningNodes, _node) == -1)
                    {
                        beginningNodes.push(_node);
                    }
            }
        }
        else
        {
            throw new Error("Duplicate world nodes found for node_id: " + _node.node_id);
        }
    }
    
    /**
		 * Adds the input edge and edge set index id pair to the m_startingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
    private function addStartingEdgeToDictionary(e : Edge, checkIfExists : Bool = true) : Void
    {
        var id : String = e.linked_edge_set.id;
        if (Reflect.field(m_startingEdgeDictionary, id) == null)
        {
            Reflect.setField(m_startingEdgeDictionary, id, new Array<Edge>());
        }
        if ((!checkIfExists) || (Reflect.field(m_startingEdgeDictionary, id).indexOf(e) == -1))
        {
            Reflect.field(m_startingEdgeDictionary, id).push(e);
        }
    }
    
    /**
		 * Adds the input edge and edge set index id pair to the outgoingEdgeDictionary
		 * @param	e A starting edge to be added to the dictionary
		 * @param	checkIfExists True if only edges that do not already exist in the dictionary are added
		 */
    private function addOutgoingEdgeToDictionary(e : Edge, checkIfExists : Bool = true) : Void
    {
        var id : String = e.linked_edge_set.id;
        if (Reflect.field(m_outgoingEdgeDictionary, id) == null)
        {
            Reflect.setField(m_outgoingEdgeDictionary, id, new Array<Edge>());
        }
        if ((!checkIfExists) || (Reflect.field(m_outgoingEdgeDictionary, id).indexOf(e) == -1))
        {
            Reflect.field(m_outgoingEdgeDictionary, id).push(e);
        }
    }
    
    private var m_stubInputWidthsByPort : Dictionary = new Dictionary();
    private var m_stubOutputWidthsByPort : Dictionary = new Dictionary();
    public function addStubBoardPortWidth(_port_num : String, _stub_width : String, _is_input : Bool) : Void
    {
        _stub_width = _stub_width.toLowerCase();
        if ((_stub_width != "narrow") && (_stub_width != "wide"))
        {
            throw new Error("Illegal stub width found ('" + _stub_width + "') for board:" + original_board_name + " port_num:" + _port_num);
        }
        if (_is_input)
        {
            if (m_stubInputWidthsByPort.exists(_port_num))
            {
                throw new Error("Duplicate stub inputs found for board:" + original_board_name + " port_num:" + _port_num);
            }
            Reflect.setField(m_stubInputWidthsByPort, _port_num, _stub_width);
        }
        else
        {
            if (m_stubOutputWidthsByPort.exists(_port_num))
            {
                throw new Error("Duplicate stub outputs found for board:" + original_board_name + " port_num:" + _port_num);
            }
            Reflect.setField(m_stubOutputWidthsByPort, _port_num, _stub_width);
        }
    }
    
    public function getStubBoardPortWidth(_port_num : String, _is_input : Bool) : String
    {
        if (_is_input)
        {
            if (!m_stubInputWidthsByPort.exists(_port_num))
            {
                return null;
            }
            return Std.string(Reflect.field(m_stubInputWidthsByPort, _port_num));
        }
        else
        {
            if (!m_stubOutputWidthsByPort.exists(_port_num))
            {
                return null;
            }
            return Std.string(Reflect.field(m_stubOutputWidthsByPort, _port_num));
        }
    }
    
    private function get_startingEdgeDictionary() : Dictionary
    {
        if (m_startingEdgeDictionary == null)
        {
            m_startingEdgeDictionary = new Dictionary();
            for (i in 0...beginningNodes.length)
            {
                var begNode : Node = beginningNodes[i];
                for (j in 0...begNode.outgoing_ports.length)
                {
                    var begport : Port = begNode.outgoing_ports[j];
                    addStartingEdgeToDictionary(begport.edge);
                }
            }
        }
        return m_startingEdgeDictionary;
    }
    
    private function get_outgoingEdgeDictionary() : Dictionary
    {
        if (m_outgoingEdgeDictionary == null)
        {
            m_outgoingEdgeDictionary = new Dictionary();
            if (outgoing_node != null)
            {
                for (i in 0...outgoing_node.incoming_ports.length)
                {
                    var outport : Port = outgoing_node.incoming_ports[i];
                    addOutgoingEdgeToDictionary(outport.edge);
                }
            }
        }
        return m_outgoingEdgeDictionary;
    }
}
