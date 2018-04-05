package UserInterface.Components
{
	import flash.geom.Rectangle;
	import UserInterface.Components.RectangularObject;
	import Utilities.Fonts;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.*;
	import mx.controls.Image;

	/**
	 * A clickable button containing text (such as "OK" Button) that has a highlighted border when moused over
	 */
	public class TextButton extends RectangularObject implements GeneralButton
	{
		
		protected var m_textField:TextField;
		protected var m_height:int;
		protected var m_width:int;
		protected var m_textFormat:TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 18, 0x000, true, false, false, null, null, TextFormatAlign.CENTER);
		protected var m_coverSprite:Sprite;
		public var m_mouseOver:Boolean = false;
		protected var m_borderColor:Number;
		protected var m_rolloverBorderColor:Number;
		protected var m_backgroundColor:Number;
		protected var m_alpha:Number = 1.0;
		protected var m_padding:uint = 12;
		protected var m_disabled:Boolean = false;
		protected var m_callback:Function;
		protected var m_blinking:Boolean = false;
		protected var m_cover_alpha:Number = 0.1;
		protected var m_curvature:Number = 24;
		
		public function TextButton(_x:int, _y:int, _width:int, _height:int, _text:String, _click_callback:Function = null)
		{
			super(_x, _y, _width, _height);
			name = "TextButton:" + _text;
			m_width = _width;
			m_height = _height;
			m_borderColor = -1;
			m_rolloverBorderColor = 0xFFFFFF;
			m_backgroundColor = -1;
			
			m_callback = _click_callback;
			m_textField = new TextField();
			m_textField.embedFonts = true;
			m_textField.text = _text;
			m_textField.setTextFormat(m_textFormat);
			m_textField.wordWrap = true;

			m_textField.width = width;
			m_textField.x = 0;
			m_textField.autoSize = TextFieldAutoSize.CENTER;
			m_textField.y = Math.max(0, height / 2 - (m_textField.getBounds(this) as Rectangle).height / 2);
			
			m_coverSprite = new Sprite();
			m_coverSprite.graphics.beginFill(0xFFFFFF, m_cover_alpha);
			m_coverSprite.graphics.lineStyle(4, 0xFFFFFF, m_cover_alpha);
			m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, width+2*m_padding, height+2*m_padding, m_curvature, m_curvature);
			m_coverSprite.graphics.endFill();
			
			if (_click_callback!=null) {
				addEventListener(MouseEvent.CLICK, _click_callback);
			}
			
			addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			
			m_textField.selectable = false;
			buttonMode = true;
			draw();
		}
		
		public function draw():void {
			
			graphics.clear();
			while (numChildren) removeChildAt(0);
			if (m_backgroundColor != -1) {
				graphics.beginFill(m_backgroundColor, m_alpha);
			} else {
				graphics.beginFill(0xFFFFFF, 0);
			}
			if ( (buttonMode && m_mouseOver && !m_disabled) || m_blinking) {
				graphics.lineStyle(4, m_rolloverBorderColor);
				graphics.drawRoundRect(-m_padding, -m_padding, width+2*m_padding, height+2*m_padding, m_curvature, m_curvature);
			} else {
				if (m_borderColor != -1) {
					graphics.lineStyle(4, m_borderColor);
				}
				graphics.drawRoundRect(-m_padding, -m_padding, width+2*m_padding, height+2*m_padding, m_curvature, m_curvature);
			}
			addChild(m_textField);
			addChild(m_coverSprite);
		}
		
		public function buttonRollOver(e:Event):void {
			m_mouseOver = true;
			draw();
		}
		
		public function buttonRollOut(e:Event):void {
			m_mouseOver = false;
			draw();
		}
		
		public function select():void {
			m_borderColor = 0x000000;
			draw();
		}
		
		public function unselect():void {
			m_borderColor = -1;
			draw();
		}
		
		public function set padding(p:uint):void {
			m_padding = p;
			m_coverSprite = new Sprite();
			m_coverSprite.graphics.beginFill(0xFFFFFF, 0.1);
			m_coverSprite.graphics.lineStyle(4, 0xFFFFFF, 0.1);
			m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, width+2*m_padding, height+2*m_padding, m_curvature, m_curvature);
			draw();
		}
		
		public function set text(s:String):void {
			m_textField.text = s;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function get text():String {
			return m_textField.text;
		}
		
		public function set fontSize(n:Number):void {
			m_textFormat.size = n;
			m_textField.setTextFormat(m_textFormat);
			draw();
		}
		
		public function set backgroundColor(c:Number):void {
			m_backgroundColor = c;
			draw();
		}
		
		public function get backgroundColor():Number {
			return m_backgroundColor;
		}
		
		public function set backgroundAlpha(a:Number):void {
			m_alpha = a;
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
		
		public function set borderColor(n:Number):void {
			m_borderColor = n;
			draw();
		}
		
		public function set rolloverBorderColor(n:Number):void {
			m_rolloverBorderColor = n;
			draw();
		}
		
		public function set disabled(b:Boolean):void {
			m_disabled = b;
			if (b) {
				m_textField.alpha = 0.2;
				buttonMode = false;
				removeEventListener(MouseEvent.CLICK, m_callback);
			} else {
				m_textField.alpha = 1.0;
				buttonMode = true;
				addEventListener(MouseEvent.CLICK, m_callback);
			}
			draw();
		}
		
		public function toggleBlink():void {
			if (m_blinking) {
				m_blinking = false;
			} else {
				m_blinking = true;
			}
			draw();
		}
		
		public function unblink():void {
			m_blinking = false;
			draw();
		}
		
		public function centerVertically():void {
			m_textField.y = 0.5 * (m_height - m_textField.textHeight);
		}
		
		public function get mouseOver():Boolean {
			return m_mouseOver;
		}

		public function set coverAlpha(n:Number):void {
			m_cover_alpha = n;
			m_coverSprite = new Sprite();
			m_coverSprite.graphics.beginFill(0xFFFFFF, m_cover_alpha);
			m_coverSprite.graphics.lineStyle(4, 0xFFFFFF, m_cover_alpha);
			m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, width+2*m_padding, height+2*m_padding, m_curvature, m_curvature);
			m_coverSprite.graphics.endFill();
		}
		
	}
}