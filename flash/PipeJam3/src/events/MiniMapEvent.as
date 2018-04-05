package events 
{
	import flash.geom.Rectangle;
	import scenes.game.display.Level;
	import starling.events.Event;
	
	public class MiniMapEvent extends Event 
	{
		public static const VIEWSPACE_CHANGED:String = "VIEWSPACE_CHANGED";
		public static const ERRORS_MOVED:String = "ERRORS_MOVED";
		public static const LEVEL_RESIZED:String = "LEVEL_RESIZED";
		
		public var contentX:Number;
		public var contentY:Number;
		public var contentScale:Number;
		public var level:Level;
		
		public function MiniMapEvent(_type:String, _contentX:Number = NaN, _contentY:Number = NaN, _contentScale:Number = NaN, _level:Level = null)
		{
			super(_type, true);
			contentX = _contentX;
			contentY = _contentY;
			contentScale = _contentScale;
			level = _level;
		}
		
	}

}