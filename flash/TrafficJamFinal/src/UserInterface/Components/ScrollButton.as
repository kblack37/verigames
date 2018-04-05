package UserInterface.Components
{
	import UserInterface.Components.RectangularObject;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import mx.controls.Image;

	/**
	 * A button to allow scrolling of an object according to the callbacks given
	 */
	public class ScrollButton extends ImageButton
	{
		protected var rollover_callback:Function;
		protected var rollout_callback:Function;
		
		public function ScrollButton(_x:int, _y:int, _width:int, _height:int, _bitmap:Bitmap, _rollover_callback:Function = null, _rollout_callback:Function = null)
		{
			rollover_callback = _rollover_callback;
			rollout_callback = _rollout_callback;
			
			super(_x, _y, _width, _height, _bitmap, null, function ():void {});
			name = "ScrollButton|" + super.name;
		}
		
		public override function draw():void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF, 0.0);
			graphics.lineStyle(0, 0xFFFFFF, 0.0);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			while (numChildren) removeChildAt(0);
			if (m_mouseOver) {
				addChild(m_image);
			}
			//addChild(m_coverSprite);
		}
		
		public override function buttonRollOver(e:Event):void {
			m_mouseOver = true;
			rollover_callback();
			draw();
		}
		
		public override function buttonRollOut(e:Event):void {
			m_mouseOver = false;
			rollout_callback();
			draw();
		}
		
	}
}