package display
{
	import scenes.game.display.Level;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class ToolTipText extends TextBubbleFollowComponent
	{
		private static const ACTIVE_FONT_SZ:Number = 8;
		private static const PERSISTENT_FONT_SZ:Number = 10;
		private static const INSET:Number = 1.5;
		private static const OUTLINE_CLR:uint = 0x0;
		private static const OUTLINE_WEIGHT:Number = 2;
		
		public function ToolTipText(text:String, level:Level, persistent:Boolean, pointAtFunction:Function, pointFrom:String = Constants.TOP_LEFT, pointTo:String = Constants.CENTER)
		{
			var fontSz:uint = persistent ? PERSISTENT_FONT_SZ : ACTIVE_FONT_SZ;
			var textColor:uint = persistent ? 0x0 : 0xFFFFFF;
			var inset:Number = fontSz / 6.0;
			
			super(pointAtFunction, level, text, fontSz, textColor, pointFrom, pointTo, null, fontSz / 1.5, 0, 0, INSET, false, textColor, OUTLINE_WEIGHT, OUTLINE_CLR);
		}
		
		
	}
}
