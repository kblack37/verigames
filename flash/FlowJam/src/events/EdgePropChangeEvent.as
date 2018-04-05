package events 
{
	import flash.events.Event;
	
	import graph.Edge;
	import graph.PropDictionary;
	
	public class EdgePropChangeEvent extends Event 
	{
		public static const ENTER_BALL_TYPE_CHANGED:String = "ENTER_BALL_TYPE_CHANGED";
		public static const EXIT_BALL_TYPE_CHANGED:String = "EXIT_BALL_TYPE_CHANGED";
		public static const ENTER_PROPS_CHANGED:String = "ENTER_PROPS_CHANGED";
		public static const EXIT_PROPS_CHANGED:String = "EXIT_PROPS_CHANGED";
		
		public var oldProps:PropDictionary;
		public var newProps:PropDictionary
		public var oldBallType:uint;
		public var newBallType:uint;
		public var edge:Edge;
		
		public function EdgePropChangeEvent(eventType:String, _edge:Edge, _oldProps:PropDictionary = null, _newProps:PropDictionary = null, _oldType:uint = 0, _newType:uint = 0) 
		{
			super(eventType);
			edge = _edge;
			oldProps = _oldProps;
			newProps = _newProps;
			oldBallType = _oldType;
			newBallType = _newType;
			//trace("dispatching: " + this);
		}
		
		override public function toString():String
		{
			return "[BallTypeChangeEvent:" + type + " edgeId:" + edge.edge_id + " oldType:" + oldBallType + " newType:" + newBallType + "]";
		}
		
	}

}