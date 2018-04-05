package GameScenes
{
	public class TutorialGameScene extends VerigameSystemGameScene 
	{
		public function TutorialGameScene(controller:SceneController)
		{
			super(controller);
			(controller as TrafficJamSceneController).getNextWorld(TrafficJamSceneController.TUTORIAL_ID);

		}
		
		override public function loadScene():void
		{
			gameSystem.m_shouldCelebrate = false;
			gameSystem.setGameSize(true);
		}
		
		override public function levelCompleted():void
		{
			gameSystem.game_panel.levelCompleted();
		}
	}
}