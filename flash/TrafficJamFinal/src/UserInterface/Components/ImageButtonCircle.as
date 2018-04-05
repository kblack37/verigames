package UserInterface.Components
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import UserInterface.Components.RectangularObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.*;
	import mx.controls.Image;

	/**
	 * A clickable button that displays an image in the center and a circle around the outside.
	 */
	public class ImageButtonCircle extends Sprite implements GeneralButton
	{
		public var m_image:DisplayObject;
		public var m_rollover_image:DisplayObject;
		protected var m_radius:int;
		protected var m_border_width:Number;
		protected var m_coverSprite:Sprite;
		public var m_mouseOver:Boolean = false;
		protected var m_borderColor:Number;
		protected var m_callback:Function;
		protected var m_enabled:Boolean = true;
		
		public function ImageButtonCircle(_x:int, _y:int, _radius:int, _image:DisplayObject, _rollover_image:DisplayObject = null, _click_callback:Function = null)
		{
			m_borderColor = -1;
			m_radius = _radius;
			m_callback = _click_callback;
			m_image = _image;
			m_image.width = 2 * _radius;
			m_image.height = 2 * _radius;
			m_image.x = -0.5*m_image.width;
			m_image.y = -0.5*m_image.height;
			name = "ImageButtonCircle";
			if (_click_callback!=null) {
				addEventListener(MouseEvent.CLICK, _click_callback);
			}
			
			m_border_width = 0.1 * Number(m_radius);
			
			addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);

			m_coverSprite = new Sprite();
			m_coverSprite.graphics.beginFill(0xFFFFFF, 0.1);
			m_coverSprite.graphics.lineStyle(m_border_width, 0xFFFFFF, 0.1);
			m_coverSprite.graphics.drawCircle(0, 0, _radius);
			
			buttonMode = true;
		}
		
		public function draw():void {
			graphics.clear();
			while (numChildren) removeChildAt(0);
			if (buttonMode && m_mouseOver) {
				graphics.lineStyle(m_border_width, 0xFFFFFF);
				graphics.drawCircle(0, 0, m_radius);
			} else if (m_borderColor != -1) {
				graphics.lineStyle(m_border_width, m_borderColor);
				graphics.drawCircle(0, 0, m_radius);
			}
			if (m_rollover_image && m_mouseOver) {
				addChild(m_rollover_image);
			} else {
				addChild(m_image);
			}
			addChild(m_coverSprite);
		}
		
		public function buttonRollOver(e:Event):void {
			m_mouseOver = true;
			draw();
		}
		
		public function set borderWidth(_n:Number):void {
			m_border_width = _n;
			draw();
		}
		
		public function buttonRollOut(e:Event):void {
			m_mouseOver = false;
			draw();
		}
		

		public function disable():void {
			if (!m_enabled)
				return;
			m_enabled = false;
			buttonMode = false;
			if (m_callback!=null) {
				removeEventListener(MouseEvent.CLICK, m_callback);
			}
			
			m_border_width = 0.1 * Number(m_radius);
			
			removeEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			
			m_mouseOver = false;
		}
		
		public function enable():void {
			if (m_enabled)
				return;
			m_enabled = true;
			buttonMode = true;
			if (m_callback!=null) {
				addEventListener(MouseEvent.CLICK, m_callback);
			}
			
			addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
		}
		
		public function select():void {
			m_borderColor = 0x000000;
			draw();
		}
		
		public function unselect():void {
			m_borderColor = -1;
			draw();
		}
		
		public function get mouseOver():Boolean {
			return m_mouseOver;
		}
		
	}
}