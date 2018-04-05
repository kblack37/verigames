package graph;


/**
	 * Special type of node - subnetwork. This does not contain any graphics/drawing information, but it does 
	 * contain a reference to the associated_board object that has all of that.
	 * 
	 * @author Tim Pavlik
	 */
class SubnetworkNode extends Node
{
    public var associated_board(get, set) : BoardNodes;

    /** Original (un-obfuscated) SUBBOARD board name */
    public var subboard_name : String = "";
    /** BoardNodes corresponding to subboard_name */
    private var m_associated_board : BoardNodes;
    /** True if the associated_board does not appear within the current LevelNodes */
    public var associated_board_is_external : Bool = true;
    
    public function new(_x : Float, _y : Float, _t : Float, _metadata : Dynamic = null)
    {
        if (_metadata != null)
        {
            if (_metadata.data != null)
            {
                if (_metadata.data.id != null)
                {
                    if (Std.string(_metadata.data.name).length > 0)
                    {
                        subboard_name = Std.string(_metadata.data.name);
                    }
                }
            }
        }
        
        super(_x, _y, _t, NodeTypes.SUBBOARD, _metadata);
    }
    
    private function get_associated_board() : BoardNodes
    {
        return m_associated_board;
    }
    
    private function set_associated_board(bNodes : BoardNodes) : BoardNodes
    {
        m_associated_board = bNodes;
        if (m_associated_board != null && m_associated_board.incoming_node)
        {
            for (ip in incoming_ports)
            {
                var sip : SubnetworkPort = try cast(ip, SubnetworkPort) catch(e:Dynamic) null;
                var innerInPort : Port = m_associated_board.incoming_node.getOutgoingPort(sip.port_id);
                if (innerInPort != null)
                {
                    sip.linked_subnetwork_edge = innerInPort.edge;
                }
            }
        }
        if (m_associated_board != null && m_associated_board.outgoing_node)
        {
            for (op in outgoing_ports)
            {
                var sop : SubnetworkPort = try cast(op, SubnetworkPort) catch(e:Dynamic) null;
                var innerOutPort : Port = m_associated_board.outgoing_node.getIncomingPort(sop.port_id);
                if (innerOutPort != null)
                {
                    sop.linked_subnetwork_edge = innerOutPort.edge;
                }
            }
        }
        return bNodes;
    }
}

