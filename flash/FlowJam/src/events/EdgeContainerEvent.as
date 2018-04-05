package events 
{
	import scenes.game.display.GameComponent;
	import scenes.game.display.GameEdgeContainer;
	import scenes.game.display.GameEdgeJoint;
	import scenes.game.display.GameEdgeSegment;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.events.Touch;
	
	public class EdgeContainerEvent extends Event 
	{
		public static const CREATE_JOINT:String = "CREATE_JOINT";
		public static const RUBBER_BAND_SEGMENT:String = "RUBBER_BAND_SEGMENT";
		public static const SEGMENT_MOVED:String = "SEGMENT_MOVED";
		public static const SEGMENT_DELETED:String = "SEGMENT_DELETED";
		public static const SAVE_CURRENT_LOCATION:String = "SAVE_CURRENT_LOCATION";
		public static const RESTORE_CURRENT_LOCATION:String = "RESTORE_CURRENT_LOCATION";
		public static const INNER_SEGMENT_CLICKED:String = "INNER_SEGMENT_CLICKED";
		public static const HOVER_EVENT_OVER:String = "HOVER_EVENT_OVER";
		public static const HOVER_EVENT_OUT:String = "HOVER_EVENT_OUT";
		
		public var segment:GameEdgeSegment;
		public var joint:GameEdgeJoint;
		public var container:GameEdgeContainer;
		public var segmentIndex:int;
		public var jointIndex:int;
		public var touches:Vector.<Touch>;
		
		public function EdgeContainerEvent(type:String, _segment:GameEdgeSegment = null, _joint:GameEdgeJoint = null, _touches:Vector.<Touch> = null) 
		{
			super(type, true);
			segment = _segment;
			joint = _joint;
			container = getEdgeContainerParent(segment);
			if (container == null) container = getEdgeContainerParent(joint); //try joint if segment/parent null
			if (container != null) {
				if (segment != null) segmentIndex = container.getSegmentIndex(segment);
				if (joint != null) jointIndex = container.getJointIndex(joint);
			} else {
				trace("WARNING: Event expects edge segment or joint with a parent edge container.");
			}
			touches = _touches;
			if (touches == null) touches = new Vector.<Touch>();
		}
		
		private static function getEdgeContainerParent(comp:GameComponent):GameEdgeContainer
		{
			if (comp == null) return null;
			if (comp.parent == null) return null;
			var currentParent:DisplayObjectContainer = comp.parent;
			while (currentParent) {
				if (currentParent is GameEdgeContainer) {
					return currentParent as GameEdgeContainer;
				}
				currentParent = currentParent.parent;
			}
			return null;
		}
	}
}