package UserInterface.Components
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	/**
	 * Generic display object with X, Y (defining the top left corner) and width and height
	 */
	public class RectangularObject extends UIComponent
	{
		
		public function RectangularObject(_x:int, _y:int, _width:uint, _height:uint) 
		{
			
			setPositionAndSize(_x, _y, _width, _height);	
			
		}
		
		public function setPositionAndSize(_x:int, _y:int, _width:uint, _height:uint):void {
			
			x = _x;
			y = _y;
			width = _width;
			height = _height;
			
		}
		
		public function get position():Point {
			return new Point(x, y);
		}
		
		public function get midpoint():Point {
			return new Point(x + width/2, y + height/2);
		}

	}
}