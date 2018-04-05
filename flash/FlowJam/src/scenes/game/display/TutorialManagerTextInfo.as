package scenes.game.display
{
	import flash.geom.Point;

	public class TutorialManagerTextInfo
	{
		public var text:String;
		public var size:Point;
		public var pointAtFn:Function;
		public var pointFrom:String;
		public var pointTo:String;
		
		public function TutorialManagerTextInfo(_text:String, _size:Point, _pointAtFn:Function, _pointFrom:String, _pointTo:String)
		{
			text = _text;
			size = _size;
			pointAtFn = _pointAtFn;
			pointFrom = _pointFrom;
			pointTo = _pointTo;
		}
	}
}
