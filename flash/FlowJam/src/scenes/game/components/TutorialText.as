package scenes.game.components
{
	import display.TextBubbleFollowComponent;
	import scenes.game.display.Level;
	import scenes.game.display.TutorialManagerTextInfo;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class TutorialText extends TextBubbleFollowComponent
	{
		private static const TUTORIAL_FONT_SIZE:Number = 10;
		private static const ARROW_SZ:Number = 10;
		private static const ARROW_BOUNCE:Number = 2;
		private static const ARROW_BOUNCE_SPEED:Number = 0.5;
		private static const INSET:Number = 3;
		
		public function TutorialText(level:Level, info:TutorialManagerTextInfo)
		{
			super(info.pointAtFn, level, info.text, TUTORIAL_FONT_SIZE, 0xEEEEEE, info.pointFrom, info.pointTo, info.size, ARROW_SZ, ARROW_BOUNCE, ARROW_BOUNCE_SPEED, INSET);
		}
	}
}
