package UserInterface.Components
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import UserInterface.Components.RectangularObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.*;
	import mx.controls.Image;

	/**
	 * A generic clickable button that has a button bitmap given, and a rollover button bitmap given.
	 */
	public class BitmapButton extends RectangularObject implements GeneralButton
	{
		private var m_bmp:Bitmap;
		private var m_bmp_rollover:Bitmap;
		private var m_mouseOver:Boolean = false;
		private var m_disabled:Boolean = false;
		private var m_callback:Function;
		
		public function BitmapButton(_x:int, _y:int, _width:int, _height:int, _button_bitmap:Bitmap, _button_rollover_bitmap:Bitmap, _click_callback:Function = null)
		{
			super(_x, _y, _width, _height);
	//		name = "BitmapButton" + instanceIndex;
			m_bmp = _button_bitmap;
			m_bmp_rollover = _button_rollover_bitmap;
			
			if (_click_callback != null) {
				m_callback = _click_callback;
				addEventListener(MouseEvent.CLICK, _click_callback);
			}
			
			addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			
			buttonMode = true;
			
			draw();
		}
		
		public function draw():void {
			
			while (numChildren) removeChildAt(0);
			
			if (m_mouseOver) {
				addChild(m_bmp_rollover);
			} else {
				addChild(m_bmp);
			}
			
		}
		
		public function buttonRollOver(e:Event):void {
			m_mouseOver = true;
			draw();
		}
		
		public function buttonRollOut(e:Event):void {
			m_mouseOver = false;
			draw();
		}
		
		public function set disabled(b:Boolean):void {
			m_disabled = b;
			if (b) {
				m_bmp.alpha = 0.2;
				m_bmp_rollover.alpha = 0.2;
				buttonMode = false;
				removeEventListener(MouseEvent.CLICK, m_callback);
			} else {
				m_bmp.alpha = 1.0;
				m_bmp_rollover.alpha = 1.0;
				buttonMode = true;
				addEventListener(MouseEvent.CLICK, m_callback);
			}
			draw();
		}
		
		public function select():void {
			
		}
		
		public  function unselect():void {
			
		}
		
		public function get mouseOver():Boolean {
			return m_mouseOver;
		}
		
	}
}