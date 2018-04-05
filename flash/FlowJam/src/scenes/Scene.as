package scenes
{
	import audio.AudioManager;
    import starling.display.Sprite;
    import starling.events.Event;
    
    public class Scene extends BaseComponent
    {	
		public static var m_gameSystem:Game;
				
		public static function getScene(className:Class, game:Game):Scene
		{
			return new className(game);
		}
		
        public function Scene(game:Game)
        {
			m_gameSystem = game;
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
        }
		
		//override to get your scene initialized for viewing
		protected function addedToStage(event:starling.events.Event):void
		{
			AudioManager.getInstance().reset();
		}
		
		protected function removedFromStage(event:starling.events.Event):void
		{
			AudioManager.getInstance().reset();
		}
		
		public function setGame(game:Game):void
		{
			m_gameSystem = game;
		}
		
		public function setStatus(text:String):void
		{
		}
	}
}