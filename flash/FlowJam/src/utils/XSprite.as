package utils
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.graphics.Fill;
	import starling.display.graphics.NGon;
	import starling.display.graphics.Stroke;
	import starling.events.Event;

	public class XSprite
	{
		public static function extractRed(cc:uint):uint
		{
			return ((cc >> 16) & 0xFF);
		}
		
		public static function extractGreen(cc:uint):uint
		{
			return ((cc >> 8) & 0xFF);
		}
		
		public static function extractBlue(cc:uint):uint
		{
			return (cc & 0xFF);
		}
		
		private static function toByte(nn:Number):uint
		{
			return Math.max(0, Math.min(255, nn * 255));
		}
		
		public static function toColor(rr:Number, gg:Number, bb:Number):uint
		{
			return (toByte(rr) << 16) | (toByte(gg) << 8) | toByte(bb);
		}
		
		public static function scaleColor(scale:Number, cc:uint):uint
		{
			return toColor(
				scale * extractRed(cc) / 255.0,
				scale * extractGreen(cc) / 255.0,
				scale * extractBlue(cc) / 255.0);
		}
		
		public static function removeAllChildren(doc:DisplayObjectContainer):void
		{
			while (doc.numChildren > 0) {
				doc.removeChildAt(0);
			}
		}

		public static function setupDisplayObject(obj:DisplayObject, x:Number, y:Number, sz:Number):void
		{
			obj.x = x;
			obj.y = y;
			obj.scaleX = obj.scaleY = (sz / Math.max(obj.width, obj.height));
		}
		
		public static function eventCallbackWrapper(func:Function, arg:*):Function
		{
			return function(ev:Event):void { func.call(null, ev, arg); };
		}
		
		public static function eventCallbackWrapper2(func:Function, arg0:*, arg1:*):Function
		{
			return function(ev:Event):void { func.call(null, ev, arg0, arg1); };
		}
		
		public static function setPivotCenter(obj:DisplayObject):void
		{
			obj.pivotX = int(obj.width / 2);
			obj.pivotY = int(obj.height / 2);
		}
		
		public static function createPolyLine(x0:Number, y0:Number, x1:Number, y1:Number, color:uint, thickness:uint, alpha:Number=1.0):DisplayObject
		{
			var stroke:Stroke = new Stroke();
			stroke.addVertex(x0, y0, thickness, color, alpha, color, alpha);
			stroke.addVertex(x1, y1, thickness, color, alpha, color, alpha);
			return stroke;
		}
		
		public static function createPolyRect(width:Number, height:Number, color:uint, thickness:uint, alpha:Number=1.0):DisplayObject
		{
			if (thickness == 0) {
				var fill:Fill = new Fill();
				fill.addVertex(0, 0, color, alpha);
				fill.addVertex(0, height, color, alpha);
				fill.addVertex(width, height, color, alpha);
				fill.addVertex(width, 0, color, alpha);
				return fill;
			} else {
				var stroke:Stroke = new Stroke();
				stroke.addVertex(0, 0, thickness, color, alpha, color, alpha);
				stroke.addVertex(0, height, thickness, color, alpha, color, alpha);
				stroke.addVertex(width, height, thickness, color, alpha, color, alpha);
				stroke.addVertex(width, 0, thickness, color, alpha, color, alpha);
				stroke.addVertex(0, 0, thickness, color, alpha, color, alpha);
				return stroke;
			}
		}
		
		public static function createPolyCircle(radius:Number, color:uint, thickness:uint, alpha:Number=1.0):DisplayObject
		{
			const SECTIONS:uint = 16;
			var ii:uint;
			var ang:Number;
			var ngon:NGon;
			
			if (thickness == 0) {
				ngon = new NGon(radius, SECTIONS);
			} else {
				ngon = new NGon(radius + thickness / 2, SECTIONS, radius - (thickness + 1) / 2);
			}
			
			ngon.material.color = color;
			ngon.material.alpha = alpha;
			return ngon;
		}
	}
}
