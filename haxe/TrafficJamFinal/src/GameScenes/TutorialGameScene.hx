package gameScenes;


class TutorialGameScene extends VerigameSystemGameScene
{
    public function new(controller : SceneController)
    {
        super(controller);
        (try cast(controller, TrafficJamSceneController) catch(e:Dynamic) null).getNextWorld(TrafficJamSceneController.TUTORIAL_ID);
    }
    
    override public function loadScene() : Void
    {
        gameSystem.m_shouldCelebrate = false;
        gameSystem.setGameSize(true);
    }
    
    override public function levelCompleted() : Void
    {
        gameSystem.game_panel.levelCompleted();
    }
}
