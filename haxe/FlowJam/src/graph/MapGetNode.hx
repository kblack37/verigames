package graph;


/**
	 * MapGet Node has four incoming edges:
	 * map - type of map itself
	 * key - type of keys in the map
	 * value - type of values output from the map
	 * argument - type of the argument provided to the mapGet(arg) call
	 * 
	 * And one outgoing edge that outputs a ball under one of two conditions:
	 * a) If the ARGUMENT edge has a stamp indicating it is a keyFor the MAP, then
	 *    the ball type that exited the VALUE edge will be output from the
	 *    MAPGET node.
	 * Otherwise,
	 * b) A WIDE ball will be output.
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
    
    public function new(_x : Float, _y : Float, _t : Float, _metadata : Dynamic = null)
    {
        super(_x, _y, _t, NodeTypes.GET, _metadata);
    }
    
    public function getOutputBallType() : Int
    {
        if (argumentHasMapStamp())
        {
        // Argument pinstriping matches key, ball travels from value to output
            
            if (valueEdge.is_wide)
            {
                return valueEdge.exit_ball_type;
            }
            else
            {
                var _sw3_ = (valueEdge.exit_ball_type);                

                switch (_sw3_)
                {
                    case Edge.BALL_TYPE_WIDE:
                    // WIDE ball through narrow pipe? This shouldn't be possible, but process it anyway
                    return Edge.BALL_TYPE_NONE;
                    case Edge.BALL_TYPE_WIDE_AND_NARROW:
                        return Edge.BALL_TYPE_NARROW;
                }
                return valueEdge.exit_ball_type;
            }
        }
        // Argument pinstriping doesn't match key, null literal (WIDE ball) thrown)
        return Edge.BALL_TYPE_WIDE;
    }
    
    public function getOutputProps() : PropDictionary
    {
        var props : PropDictionary = new PropDictionary();
        if (argumentHasMapStamp())
        {
        // Pass argument props as output
            
            props = valueEdge.getExitProps().clone();
        }
        return props;
    }
    
    public function argumentHasMapStamp() : Bool
    {
        return argumentEdge.getExitProps().hasProp(getMapProperty());
    }
    
    public function getMapProperty() : String
    {
        return (PropDictionary.PROP_KEYFOR_PREFIX + Std.string(mapEdge.linked_edge_set.id));
    }
    
    private function get_mapEdge() : Edge
    {
        var my_port : Port = getIncomingPort(MAP_PORT_IDENTIFIER);
        if (my_port != null)
        {
            return my_port.edge;
        }
        return null;
    }
    
    private function get_keyEdge() : Edge
    {
        var my_port : Port = getIncomingPort(KEY_PORT_IDENTIFIER);
        if (my_port != null)
        {
            return my_port.edge;
        }
        return null;
    }
    
    private function get_valueEdge() : Edge
    {
        var my_port : Port = getIncomingPort(VALUE_PORT_IDENTIFIER);
        if (my_port != null)
        {
            return my_port.edge;
        }
        return null;
    }
    
    private function get_argumentEdge() : Edge
    {
        var my_port : Port = getIncomingPort(ARGUMENT_PORT_IDENTIFIER);
        if (my_port != null)
        {
            return my_port.edge;
        }
        return null;
    }
    
    private function get_outputEdge() : Edge
    {
        return outgoing_ports[0].edge;
    }
}

