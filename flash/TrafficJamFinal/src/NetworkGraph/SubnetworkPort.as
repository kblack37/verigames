package NetworkGraph 
{
	/**
	 * Special case of a port on a board connecting to a subnetwork node. The 
	 * @author Tim Pavlik
	 */
	public class SubnetworkPort extends Port 
	{
		
		/** The edge (inside of the Subnetwork board) that this port points to. */
		public var linked_subnetwork_edge:Edge;
		
		public function SubnetworkPort(_node:SubnetworkNode, _edge:Edge, _id:String, _type:uint = INCOMING_PORT_TYPE) {
			super(_node, _edge, _id, _type);
		}
		
	}

}