package
{
	import assets.AssetsFont;
	
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import starling.display.DisplayObject;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class TextFactory
	{
		private static var m_instance:TextFactory;
		
		public static function getInstance():TextFactory
		{
			if (m_instance == null) {
				m_instance = new TextFactory(new SingletonLock());
			}
			return m_instance;
		}
		
		public function TextFactory(lock:SingletonLock):void
		{
		}

		public function updateText(textField:TextFieldWrapper, text:String):void
		{
			var tf:TextFieldHack = (textField as TextFieldHack);
			
			tf.text = text;
		}
		
		public function updateColor(textField:TextFieldWrapper, color:uint):void
		{
			var tf:TextFieldHack = (textField as TextFieldHack);
			
			tf.color = color;
		}
		
		public static const HLEFT:uint     = 0;
		public static const HCENTER:uint   = 1;
		public static const HRIGHT:uint    = 2;
		public static const VTOP:uint      = 0;
		public static const VCENTER:uint   = 1;
		public static const VBOTTOM:uint   = 2;

		public function updateAlign(textField:TextFieldWrapper, hAlign:uint, vAlign:uint):void
		{
			var tf:TextFieldHack = (textField as TextFieldHack);
			
			switch(hAlign) {
				case HLEFT:
					tf.hAlign = HAlign.LEFT;
					break;
				case HCENTER:
					tf.hAlign = HAlign.CENTER;
					break;
				default:
					tf.hAlign = HAlign.RIGHT;
					break;
			}
			switch(vAlign) {
				case VTOP:
					tf.vAlign = VAlign.TOP;
					break;
				case VCENTER:
					tf.vAlign = VAlign.CENTER;
					break;
				default:
					tf.vAlign = VAlign.BOTTOM;
					break;
			}
		}
		
		public function updateFilter(textField:TextFieldWrapper, filter:BitmapFilter):void
		{
			var tf:TextFieldHack = (textField as TextFieldHack);
			
			if (filter) {
				tf.nativeFilters = [filter];
			} else {
				tf.nativeFilters = null;
			}
		}
		
		public function createDefaultTextField(text:String, width:Number, height:Number, fontSize:Number, color:uint):TextFieldWrapper
		{
			return createTextField(text, AssetsFont.FONT_DEFAULT, width, height, fontSize, color);
		}
		
		public function createDebugTextField(text:String, width:Number, height:Number, fontSize:Number, color:uint):TextFieldWrapper
		{
			return createTextField(text, "Verdana", width, height, fontSize, color);
		}
		
		public function createTextField(text:String, fontName:String, width:Number, height:Number, fontSize:Number, color:uint, wrap:Boolean = false):TextFieldWrapper
		{
			var ret:TextFieldHack = new TextFieldHack(width, height, text, fontName, fontSize, color, false, wrap);
			//ret.border = true;
			ret.touchable = false;
			return ret;
		}
		
		public function estimateTextFieldSize(text:String, fontName:String, fontSize:Number):Point
		{
			var estField:TextField = new TextField();
			estField.defaultTextFormat = new TextFormat(fontName, fontSize);
			estField.embedFonts = true;
			estField.autoSize = TextFieldAutoSize.CENTER;
			estField.text = text;
			return new Point(estField.width + 8, estField.height + 8);
		}
	}
}

internal class SingletonLock {} // to prevent outside construction of singleton
