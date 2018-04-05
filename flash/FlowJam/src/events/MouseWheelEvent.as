package events 
{
	import flash.geom.Point;
	import starling.events.Event;
	
	public class MouseWheelEvent extends Event 
	{
		public static const MOUSE_WHEEL:String = "mouse_wheel";
		
		public var mousePoint:Point;
		public var delta:Number;
		public var time:Number;
		
		public function MouseWheelEvent(_mousePoint:Point, _delta:Number, _time:Number) 
		{
			super(MOUSE_WHEEL, true);
			
			mousePoint = _mousePoint;
			delta = _delta;
			time = _time;
		}
		
	}

}