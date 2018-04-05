package dialogs
{	
	import flash.geom.Point;
	
	import scenes.game.display.TutorialManagerTextInfo;
	
	public class RankProgressDialogInfo extends TutorialManagerTextInfo
	{
		public var fadeTimeSeconds:Number;
		public var button1String:String;
		public var button1Callback:Function;
		
		public function RankProgressDialogInfo(_text:String , _fadeTimeSeconds:Number, _size:Point, _button1String:String = "", _button1Callback:Function = null)
		{
			super(_text, _size, null, null, null);
			
			fadeTimeSeconds = _fadeTimeSeconds;
			button1String = _button1String;
			button1Callback = _button1Callback;
		}
	}
}