package System
{
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	import UserInterface.Components.Game;
	
	/**
	 * Wrapper function to apply to any generic game
	 */
	public class GenericSystem extends UIComponent
	{
		/** Width the game was designed to use */
		protected var m_nativeWidth:uint;
		
		/** Height the game was designed to use */
		protected var m_nativeHeight:uint;
		
		/**
		 * Wrapper function to apply to any generic game
		 * @param	_width Desired width to display game at
		 * @param	_height Desired height to display game at
		 */
		public function GenericSystem(_width:uint, _height:uint)
		{
			m_nativeWidth = _width;
			m_nativeHeight = _height;
			addEventListener(Event.ADDED_TO_STAGE, initResize );
			function initResize(e:Event):void {
				resize(new ResizeEvent("start"));
				parent.addEventListener(ResizeEvent.RESIZE, resize);
				removeEventListener(Event.ADDED_TO_STAGE, initResize);
			}
		}
		
		/**
		 * Initializes the game
		 * @param	gameName Name of game class to initialize
		 */
		public function start(gameName:Class):void {
			var game:Game = new gameName(0, 0, m_nativeWidth, m_nativeHeight) as Game;
			addChild(game);
			game.init();
		}
		
		/**
		 * Function to resize the game to the new desired dimensions
		 * @param	e Associated ResizeEvent
		 */
		public function resize(e:ResizeEvent): void {
			
			var hScale:Number = parent.width/m_nativeWidth;
			var vScale:Number = parent.height/m_nativeHeight;
			
			var scale:Number = Math.min(hScale, vScale);
			
			//scaleX = scale;
			//scaleY = scale;
			
		}	
		
	}
}