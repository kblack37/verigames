package UserInterface.Components
{
	import UserInterface.Components.RectangularObject;
	import Utilities.Fonts;
	import flash.display.Sprite;
	
	import flash.text.*;

	/**
	 * A rectangular text box label (not clickable)
	 */
	public class ClearLabel extends RectangularObject
	{
		protected var m_width:uint;
		protected var m_height:uint;
		protected var m_textField:TextField;
		protected var m_coverSprite:Sprite;
		protected var m_color:Number;
		protected var m_text_color:Number = 0xFFFFFF;
		protected var m_textFormat:TextFormat;
		protected var m_borderColor:Number;
		protected var m_blinking:Boolean = false;
		protected var m_alpha:Number = 0.85;
		protected var m_curvature:Number = 30;
		
		public function ClearLabel(_x:uint, _y:uint, _width:uint, _height:uint, text:String, fSize:Number)
		{
			super(_x, _y, _width, _height);
			name = "ClearLabel" + instanceIndex;
			m_width = _width;
			m_height = _height;
			m_color = 0x8B8B51;
			m_borderColor = 0x4A4A2B;
			
			m_textField = new TextField();
			m_textField.embedFonts = true;
			m_textField.selectable = false;
			m_textField.text = text;
			m_textFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, m_text_color, null, null, null, null, 
				null, TextFormatAlign.CENTER, 10, 10, null, 6);
			m_textField.setTextFormat(m_textFormat);
			m_textField.wordWrap = true;
			m_textField.background = false;
			
			m_textField.width = width;
			m_textField.height = height;
			m_textField.x = width/2 - m_textField.width/2;
			m_textField.y = height/2 - m_textField.height/2;
			
			m_coverSprite = new Sprite();
			m_coverSprite.graphics.beginFill(0xFFFFFF, 0.01);
			m_coverSprite.graphics.drawRoundRect(m_textField.x, m_textField.y, m_textField.width, m_textField.height, m_curvature, m_curvature);
			m_coverSprite.graphics.endFill();
			
			buttonMode = false;
			
			draw();
		}
		
		public function draw():void {
			
			graphics.clear();
			
			graphics.beginFill(m_color, m_alpha);
			graphics.lineStyle(4, m_borderColor);
			if (m_blinking) {
				graphics.lineStyle(4, 0xFFFFFF);
			}
			
			graphics.drawRoundRect(0, 0, width, height, m_curvature, m_curvature);
			graphics.endFill();
			
			addChild(m_textField);
			
			addChild(m_coverSprite);

		}
		
		public function set color(n:Number):void {
			m_color = n;
			draw();
		}
		
		public function set backgroundAlpha(n:Number):void {
			m_alpha = n;
			draw();
		}
		
		public function set borderColor(n:Number):void {
			m_borderColor = n;
			draw();
		}
		
		// use this to emphasize/blink label [e.g. during tutorial]
		public function toggleBlink():void {
			if (m_blinking) {
				m_blinking = false;
			} else {
				m_blinking = true;
			}
			draw();
		}
		
		public function set blinking(b:Boolean):void {
			m_blinking = b;
			draw();
		}
		
		public function set text(s:String):void {
			m_textField.text = s;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function set fontSize(n:Number):void {
			m_textFormat.size = n;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function set curvature(n:Number):void {
			m_curvature = n;
			draw();
		}
		
		public function set textColor(n:Number):void {
			m_textFormat.color = n;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function centerVertically():void {
			m_textField.y = 0.5 * (m_height - m_textField.textHeight);
		}
		
	}
}