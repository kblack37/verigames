package GameScenes
{
	import UserInterface.Components.Game;
	
	import fl.core.UIComponent;
	
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.core.IInvalidating;

	/*
		Scene Controller controls what is currently visible on the screen. Basically two states:
			Splash Screen
			Everything else
				this consists of startWorld, victory, and endWorld states.
	*/
	public class SceneController extends Game
	{
		//keep this out of the hands of derived classes -  use loadScene or unloadScene to change
		private var m_currentScene:GameScene;
		
		public static const NATIVE_WIDTH:uint = 1024;
		public static const NATIVE_HEIGHT:uint = 768;

		protected var ACTION_FAILED:uint = 0;
		protected var ACTION_SUCCEEDED:uint = 1;
		
		
		public function SceneController(_x:uint, _y:uint, _width:uint, _height:uint)
		{
			super(_x, _y, _width, _height);
		}
		
		//override this in derived classes
		public function loadNextScene(nextAction:uint):void
		{
		}
		
		
		/* mostly you can leave the below functions as they are */
		protected function loadScene(newScene:GameScene):void
		{
			addChild(newScene);
			newScene.loadScene();
			newScene.draw();
			m_currentScene = newScene;
		}
		
		public function get currentScene():GameScene
		{
			return m_currentScene;
		}
		
		protected function unloadCurrentScene():void
		{
			if(m_currentScene)
			{
				m_currentScene.unloadScene();
				removeChild(m_currentScene);
				m_currentScene = null;
			}
		}

		public function updateSize(newWidth:Number, newHeight:Number):void
		{
			scaleX = Math.min(Number(newWidth / NATIVE_WIDTH), Number(newHeight / NATIVE_HEIGHT));
			scaleY = Math.min(Number(newWidth / NATIVE_WIDTH), Number(newHeight / NATIVE_HEIGHT));
			if(m_currentScene)
				m_currentScene.updateSize(scaleX, scaleY);
		}
	}
}