package scenes;

import audio.AudioManager;
import starling.display.Sprite;
import starling.events.Event;

class Scene extends BaseComponent
{
    public static var m_gameSystem : Game;
    
    public static function getScene(className : Class<Dynamic>, game : Game) : Scene
    {
        return Type.createInstance(className, [game]);
    }
    
    public function new(game : Game)
    {
        super();
        m_gameSystem = game;
        this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
        this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
    }
    
    //override to get your scene initialized for viewing
    private function addedToStage(event : starling.events.Event) : Void
    {
        AudioManager.getInstance().reset();
    }
    
    private function removedFromStage(event : starling.events.Event) : Void
    {
        AudioManager.getInstance().reset();
    }
    
    public function setGame(game : Game) : Void
    {
        m_gameSystem = game;
    }
    
    public function setStatus(text : String) : Void
    {
    }
}
