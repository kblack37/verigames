package UserInterface.Components
{
	
	import flash.display.Sprite;
	
	/**
	 * Generic game object
	 */
	public class Game extends RectangularObject
	{
		/**
		 * Generic game object
		 * @param	_x X coordinate to display the game at (top left)
		 * @param	_y Y coordinate to display the game at (top left)
		 * @param	_width Width of the game
		 * @param	_height Height of the game
		 */
		public function Game(_x:uint, _y:uint, _width:uint, _height:uint)
		{
			super(_x, _y, _width, _height);
		}
		
		/**
		 * Game initializing method, to be used by classes that extend from this
		 */
		public function init():void {
			
		}
	}
}