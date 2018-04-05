package NetworkGraph 
{
	import VisualWorld.Board;
	import VisualWorld.VerigameSystem;
	import VisualWorld.MapGet;

	/**
	 * Special type of node - subnetwork. This does not contain any graphics/drawing information, but it does 
	 * contain a reference to the associated_board object that has all of that.
	 * 
	 * @author Tim Pavlik
	 */
	public class MapGetNode extends Node 
	{
		public static const MAP_PORT_IDENTIFIER:String = 		"0";
		public static const KEY_PORT_IDENTIFIER:String = 		"1";
		public static const VALUE_PORT_IDENTIFIER:String = 		"2";
		public static const ARGUMENT_PORT_IDENTIFIER:String = 	"3";
		
		/** MapGet object that this GET node refers to) */
		public var associated_mapget:MapGet;
		
		public function MapGetNode(_x:Number, _y:Number, _t:Number, _metadata:Object = null) {
			super(_x, _y, _t, NodeTypes.GET, _metadata);
		}
		
		public function getOutputBallType():uint {
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
			return VerigameSystem.BALL_TYPE_NONE;
		}
		
		public function get mapEdge():Edge {
			for each (var my_port:Port in incoming_ports) {
				if (my_port.port_id == MAP_PORT_IDENTIFIER) {
					return my_port.edge;
				}
			}
			return null;
		}
		
		public function get keyEdge():Edge {
			for each (var my_port:Port in incoming_ports) {
				if (my_port.port_id == KEY_PORT_IDENTIFIER) {
					return my_port.edge;
				}
			}
			return null;
		}
		
		public function get valueEdge():Edge {
			for each (var my_port:Port in incoming_ports) {
				if (my_port.port_id == VALUE_PORT_IDENTIFIER) {
					return my_port.edge;
				}
			}
			return null;
		}
		
		public function get argumentEdge():Edge {
			for each (var my_port:Port in incoming_ports) {
				if (my_port.port_id == ARGUMENT_PORT_IDENTIFIER) {
					return my_port.edge;
				}
			}
			return null;
		}
		
		public function get outputEdge():Edge {
			return outgoing_ports[0].edge;
		}
		
	}

}