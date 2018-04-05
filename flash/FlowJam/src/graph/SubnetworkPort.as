package graph 
{
	/**
	 * Special case of a port on a board connecting to a subnetwork node. The 
	 * @author Tim Pavlik
	 */
	public class SubnetworkPort extends Port 
	{
		
		/** The edge (inside of the Subnetwork board) that this port points to. */
		public var linked_subnetwork_edge:Edge;
		
		public var default_ball_type:uint;
		public var default_props:PropDictionary;
		public var default_is_wide:Boolean;
		
		public function SubnetworkPort(_node:SubnetworkNode, _edge:Edge, _id:String, _type:uint = INCOMING_PORT_TYPE) {
			super(_node, _edge, _id, _type);
			default_props = new PropDictionary();
			if (type == INCOMING_PORT_TYPE) {
				setDefaultWidth("wide");
			} else {
				setDefaultWidth("narrow");
			}
		}
		
		public function setDefaultWidth(width:String):void
		{
			if (width == "wide") {
				default_ball_type = Edge.BALL_TYPE_WIDE;
				default_is_wide = true;
			} else if (width == "narrow") {
				default_ball_type = Edge.BALL_TYPE_NARROW;
				default_is_wide = false;
			} else {
				throw new Error("Illegal width ('" + width + "') for port:" + port_id);
			}
			default_props.setProp(PropDictionary.PROP_NARROW, !default_is_wide);
		}
	}

}