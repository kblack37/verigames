package events
{
	import flash.geom.Point;
	
	import starling.events.Event;
	
	public class MoveEvent extends Event
	{
		public static const MOVE_EVENT:String = "move_event";
		public static const FINISHED_MOVING:String = "FINISHED_MOVING";
		public static const MOUSE_DRAG:String = "mouse_drag";
		public static const MOVE_TO_POINT:String = "move_to_point";
		public static var CENTER_ON_COMPONENT:String = "center_on_component";
		
		public var startLoc:Point
		public var endLoc:Point;
		private var m_delta:Point;
		
		public var component:Object;
		
		public function MoveEvent(_type:String, _component:Object, _startLoc:Point = null, _endLoc:Point = null)
		{
			super(_type, true);
			
			component = _component;
			startLoc = _startLoc;
			endLoc = _endLoc;
		}
		
		public function get delta():Point
		{
			if (!m_delta && startLoc && endLoc) {
				m_delta = endLoc.subtract(startLoc);
			}
			return m_delta;
		}
	}
}