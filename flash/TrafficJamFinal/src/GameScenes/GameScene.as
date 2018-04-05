package GameScenes
{
	import flash.display.DisplayObject;
	import UserInterface.Components.RectangularObject;
	
	public class GameScene extends RectangularObject
	{
		
		public var m_controller:SceneController;

		//set up class, don't try to call addChild here, as there's no parent to add to, do that in loadScene
		public function GameScene(controller:SceneController)
		{
			super(controller.x, controller.y, controller.width, controller.height);
			m_controller = controller;
		}
		
		//load display objects and other objects that need a parent
		public function loadScene():void
		{
			
		}
		
		//called by controller when scene is being unloaded
		public function unloadScene():void
		{
		}
		
		//called when level has no trouble points
		public function levelCompleted():void
		{
			
		}
		
		//call to change to next scene
		public function loadNextScene(nextAction:uint = 0):void
		{
			if(parent is SceneController)
				(parent as SceneController).loadNextScene(nextAction);
		}
		

		//called when resizing, so remove and re-add. Could we just invalidate the display list??
		public function draw():void
		{
			removeChildren();
		}
		
		//override if you have special update needs
		public function updateSize(newWidth:Number, newHeight:Number):void
		{
			
		}
	}
}