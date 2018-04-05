package events 
{
	import flash.events.Event;
	
	import graph.EdgeSetRef;
	
	public class StampChangeEvent extends Event 
	{
		public var edgeSetChanged:EdgeSetRef;
		
		public static const STAMP_ACTIVATION:String = "STAMP_ACTIVATION";
		
		public function StampChangeEvent(type:String, _edgeSetChanged:EdgeSetRef) 
		{
			super(type, false, false);
			edgeSetChanged = _edgeSetChanged;
		}
	}
}