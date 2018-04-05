package scenes.game.display
{
	import assets.AssetsFont;
	
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	
	import utils.XSprite;

	public class TextPopup extends Sprite
	{
		public function TextPopup(str:String, color:uint)
		{
			var textField:TextFieldWrapper = TextFactory.getInstance().createTextField(str, AssetsFont.FONT_UBUNTU, 100, 25, 8, color);
			TextFactory.getInstance().updateAlign(textField, TextFactory.HCENTER, TextFactory.VCENTER);
			if (!PipeJam3.DISABLE_FILTERS) TextFactory.getInstance().updateFilter(textField, OutlineFilter.getOutlineFilter());
			XSprite.setPivotCenter(textField);
			addChild(textField);
		}
		
		public static function popupText(container:DisplayObjectContainer, pos:Point, str:String, color:uint):void
		{
			var text:TextPopup = new TextPopup(str, color);
			text.x = pos.x;
			text.y = pos.y - 8;
			
			container.addChild(text);
			
			Starling.juggler.tween(text, 1.5, {y:pos.y - 20, alpha:0.2, onComplete:function():void { text.removeFromParent(); }});
		}
	}
}
