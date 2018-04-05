package graph 
{
	import events.StampChangeEvent;
	import graph.EdgeSetRef;

	public class StampRef 
	{
		public var edge_set_id:String;
		private var pipe_edge_set_ref:EdgeSetRef;
		private var m_active:Boolean;
		
		public function StampRef(_edge_set_id:String, _active:Boolean, _pipe_edge_set_ref:EdgeSetRef) 
		{
			edge_set_id = _edge_set_id;
			m_active = _active;
			pipe_edge_set_ref = _pipe_edge_set_ref;
		}
		
		public function get active():Boolean {
			return m_active;
		}
		
		public function set active(b:Boolean):void {
			m_active = b;
		}
		
		public function toString():String {
			return "{'edge_set_id':'"+edge_set_id+"', 'active':'"+m_active.toString()+"'}";
		}
		
	}

}