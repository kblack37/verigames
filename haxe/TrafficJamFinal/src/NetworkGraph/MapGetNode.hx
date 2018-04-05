package networkGraph;

import visualWorld.Board;
import visualWorld.VerigameSystem;
import visualWorld.MapGet;

/**
	 * Special type of node - subnetwork. This does not contain any graphics/drawing information, but it does 
	 * contain a reference to the associated_board object that has all of that.
	 * 
	 * @author Tim Pavlik
	 */
class MapGetNode extends Node
{
    public var mapEdge(get, never) : Edge;
    public var keyEdge(get, never) : Edge;
    public var valueEdge(get, never) : Edge;
    public var argumentEdge(get, never) : Edge;
    public var outputEdge(get, never) : Edge;

    public static inline var MAP_PORT_IDENTIFIER : String = "0";
    public static inline var KEY_PORT_IDENTIFIER : String = "1";
    public static inline var VALUE_PORT_IDENTIFIER : String = "2";
    public static inline var ARGUMENT_PORT_IDENTIFIER : String = "3";
    
    /** MapGet object that this GET node refers to) */
    public var associated_mapget : MapGet;
    
    public function new(_x : Float, _y : Float, _t : Float, _metadata : Dynamic = null)
    {
        super(_x, _y, _t, NodeTypes.GET, _metadata);
    }
    
    public function getOutputBallType() : Int
    /*if (associated_mapget.argumentHasMapStamp) {
				// Argument pinstriping matches key, ball travels from value to output
				if (valueEdge.associated_pipe.is_wide) {
					return valueEdge.associated_pipe.exit_ball_type;
				} else {
					switch (valueEdge.associated_pipe.exit_ball_type) {
						case VerigameSystem.BALL_TYPE_WIDE:
							return VerigameSystem.BALL_TYPE_NONE;
						break;
						case VerigameSystem.BALL_TYPE_WIDE_AND_NARROW:
							return VerigameSystem.BALL_TYPE_NARROW;
						break;
						default:
							return valueEdge.associated_pipe.exit_ball_type;
						break;
					}
				}
			} else {
				// Argument pinstriping doesn't match key, null literal (WIDE ball) thrown)
				return VerigameSystem.BALL_TYPE_WIDE;
			}*/
    {
        
        return VerigameSystem.BALL_TYPE_NONE;
    }
    
    private function get_mapEdge() : Edge
    {
        for (my_port/* AS3HX WARNING could not determine type for var: my_port exp: EIdent(incoming_ports) type: null */ in incoming_ports)
        {
            if (my_port.port_id == MAP_PORT_IDENTIFIER)
            {
                return my_port.edge;
            }
        }
        return null;
    }
    
    private function get_keyEdge() : Edge
    {
        for (my_port/* AS3HX WARNING could not determine type for var: my_port exp: EIdent(incoming_ports) type: null */ in incoming_ports)
        {
            if (my_port.port_id == KEY_PORT_IDENTIFIER)
            {
                return my_port.edge;
            }
        }
        return null;
    }
    
    private function get_valueEdge() : Edge
    {
        for (my_port/* AS3HX WARNING could not determine type for var: my_port exp: EIdent(incoming_ports) type: null */ in incoming_ports)
        {
            if (my_port.port_id == VALUE_PORT_IDENTIFIER)
            {
                return my_port.edge;
            }
        }
        return null;
    }
    
    private function get_argumentEdge() : Edge
    {
        for (my_port/* AS3HX WARNING could not determine type for var: my_port exp: EIdent(incoming_ports) type: null */ in incoming_ports)
        {
            if (my_port.port_id == ARGUMENT_PORT_IDENTIFIER)
            {
                return my_port.edge;
            }
        }
        return null;
    }
    
    private function get_outputEdge() : Edge
    {
        return outgoing_ports[0].edge;
    }
}

