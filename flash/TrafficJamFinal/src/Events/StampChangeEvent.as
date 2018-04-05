package Events 
{
	import NetworkGraph.Edge;
	import NetworkGraph.StampRef;
	
	import flash.events.Event;
	
	public class StampChangeEvent extends Event 
	{
		public var stamp_ref:StampRef;
		public var associated_edge:Edge;
		
		public static const STAMP_ACTIVATION:String = "STAMP_ACTIVATION";
		public static const STAMP_SET_CHANGE:String = "STAMP_SET_CHANGE";
		
		public function StampChangeEvent(type:String, _stamp_ref:StampRef = null, e:Edge = null) 
		{
			super(type, false, false);
			stamp_ref = _stamp_ref;
			associated_edge = e;
		}
		
		public override function clone():Event
		{
			return new StampChangeEvent(type, stamp_ref, associated_edge);
		}
	}

}