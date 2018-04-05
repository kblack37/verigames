package NetworkGraph 
{
	import VisualWorld.Board;
	/**
	 * Special type of node - subnetwork. This does not contain any graphics/drawing information, but it does 
	 * contain a reference to the associated_board object that has all of that.
	 * 
	 * @author Tim Pavlik
	 */
	public class SubnetworkNode extends Node 
	{
		
		/** Boards that was created based on this node (a clone of the original board that this SUBNETWORK node refers to) */
		public var associated_board:Board;
		
		public var subboard_name:String = "";
		
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
		
	}

}