package graph 
{
	/**
	 * Special type of node - subnetwork. This does not contain any graphics/drawing information, but it does 
	 * contain a reference to the associated_board object that has all of that.
	 * 
	 * @author Tim Pavlik
	 */
	public class SubnetworkNode extends Node 
	{
		/** Original (un-obfuscated) SUBBOARD board name */
		public var subboard_name:String = "";
		/** BoardNodes corresponding to subboard_name */
		private var m_associated_board:BoardNodes;
		/** True if the associated_board does not appear within the current LevelNodes */
		public var associated_board_is_external:Boolean = true;
		
		public function SubnetworkNode(_x:Number, _y:Number, _t:Number, _metadata:Object = null) {
			if (_metadata) {
				if (_metadata.data != null) {
					if (_metadata.data.id != null) {
						if (String(_metadata.data.name).length > 0) {
							subboard_name = String(_metadata.data.name);
						}
					}
				}
			}
			
			super(_x, _y, _t, NodeTypes.SUBBOARD, _metadata);
		}
		
		public function get associated_board():BoardNodes
		{
			return m_associated_board;
		}
		
		public function set associated_board(bNodes:BoardNodes):void
		{
			m_associated_board = bNodes;
			if (m_associated_board && m_associated_board.incoming_node) {
				for each (var ip:Port in incoming_ports) {
					var sip:SubnetworkPort = ip as SubnetworkPort;
					var innerInPort:Port = m_associated_board.incoming_node.getOutgoingPort(sip.port_id);
					if (innerInPort) {
						sip.linked_subnetwork_edge = innerInPort.edge;
					}
				}
			}
			if (m_associated_board && m_associated_board.outgoing_node) {
				for each (var op:Port in outgoing_ports) {
					var sop:SubnetworkPort = op as SubnetworkPort;
					var innerOutPort:Port = m_associated_board.outgoing_node.getIncomingPort(sop.port_id);
					if (innerOutPort) {
						sop.linked_subnetwork_edge = innerOutPort.edge;
					}
				}
			}
		}
		
	}

}