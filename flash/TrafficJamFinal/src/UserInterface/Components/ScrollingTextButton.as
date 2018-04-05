package UserInterface.Components
{
	import UserInterface.Components.TextButton;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import mx.controls.Image;
	
	/**
	 * A text button containing text that may be very long, the button automatically scrolls from top to bottom and back up to allow reading
	 */
	public class ScrollingTextButton extends TextButton implements GeneralButton
	{
		
		protected var m_scroll_v:int;
		
		public function ScrollingTextButton(_x:int, _y:int, _width:int, _height:int, _text:String, _click_callback:Function = null)
		{
			super(_x, _y, _width, _height, _text, _click_callback);
			name = "ScrollingTextButton:" + _text;
		}
		
		public override function buttonRollOver(e:Event):void {
			m_mouseOver = true;
			if (m_textField.textHeight > m_height) {
				m_textField.height = m_height;
				if (m_textField.scrollV == m_textField.maxScrollV) {
					m_textField.scrollV = 1;
				} else {
					m_textField.scrollV += 1;
				}
			}
			draw();
		}
		
		public override function buttonRollOut(e:Event):void {
			//m_textField.scrollV = 1;
			m_mouseOver = false;
			draw();
		}
		
	}
}