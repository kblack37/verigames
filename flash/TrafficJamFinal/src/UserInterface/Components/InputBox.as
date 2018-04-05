package UserInterface.Components
{
	import UserInterface.Components.RectangularObject;
	import Utilities.Fonts;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.*;

	/**
	 * Object that allows the user to enter text.
	 */
	public class InputBox extends RectangularObject
	{
		protected var m_textField:TextField;
		protected var m_inputField:TextField;
		protected var m_coverSprite:Sprite;
		protected var m_filled:Boolean = false;
		protected var m_color:Number;
		protected var m_inputWidth:uint;
		protected var m_textFormat:TextFormat;
		protected var m_inputFormat:TextFormat;
		protected var m_borderColor:Number;
		
		public function InputBox(_x:uint, _y:uint, _width:uint, _height:uint, text:String, fSize:Number, inputWidth:uint)
		{
			super(_x, _y, _width, _height);
			name = "InputBox" + instanceIndex;
			m_borderColor = 0x000000;
			m_color = 0x888888;
			m_inputWidth = inputWidth;
			
			m_textField = new TextField();
			m_textField.embedFonts = true;
			m_inputField = new TextField();
			m_inputField.embedFonts = true;
			m_textField.text = text;
			m_textFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, 0x000000, null, null, null, null, 
				null, TextFormatAlign.CENTER, 10, 10, null, 6);
			m_inputFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, 0x000000, null, null, null, null, 
				null, TextFormatAlign.CENTER, 10, 10, null, 6);
			m_textField.setTextFormat(m_textFormat);
			m_inputField.type = TextFieldType.INPUT;
			m_inputField.useRichTextClipboard = false;
			m_textField.wordWrap = true;
			m_textField.background = false;
			m_inputField.background = false;
			m_inputField.wordWrap = false;
			m_inputField.border = false;
			m_textField.width = width - inputWidth - 20;
			m_inputField.width = inputWidth;
			m_textField.height = height - 20;
			m_inputField.height = height - 20;
			m_textField.x = 0;
			m_textField.y = 10;
			m_inputField.x = width - inputWidth - 10;
			m_inputField.y = 10;
			m_inputField.defaultTextFormat = m_inputFormat;
			
			m_coverSprite = new Sprite();
			m_coverSprite.graphics.beginFill(0xFFFFFF, 0);
			m_coverSprite.graphics.drawRect(m_textField.x, m_textField.y, m_textField.width, m_textField.height);
			m_coverSprite.graphics.endFill();
			
			buttonMode = false;
			
			draw();
		}
		
		public function draw():void {
			
			graphics.clear();
			if (m_filled) {
				graphics.beginFill(m_color);
			}
			graphics.lineStyle(4, m_borderColor);
			graphics.drawRoundRect(0, 0, width, height, 30, 30);
			graphics.lineStyle(5, 0xFFFFFF);
			graphics.beginFill(0xFFFFFF);
			graphics.drawRoundRect(m_inputField.x-5, 5, m_inputWidth+10, height-10, 30, 30);
			graphics.endFill();
			while (numChildren) removeChildAt(0);
			m_inputField.defaultTextFormat = m_inputFormat;
			addChild(m_textField);
			addChild(m_inputField);
			addChild(m_coverSprite);

		}
		
		public function set fillColor(n:Number):void {
			m_filled = true;
			m_color = n;
			draw();
		}
		
		public function set filled(b:Boolean):void {
			m_filled = b;
		}
		
		public function set borderColor(n:Number):void {
			m_borderColor = n;
			draw();
		}
		
		public function set label(s:String):void {
			m_textField.text = s;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function set fontSize(n:Number):void {
			m_textFormat.size = n;
			m_inputFormat.size = n;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function set passwordInput(b:Boolean):void {
			m_inputField.displayAsPassword = b;
		}
		
		public function get inputText():String {
			return m_inputField.text;
		}
		
	}
}