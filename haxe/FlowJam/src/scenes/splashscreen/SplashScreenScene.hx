package scenes.splashscreen;

import assets.AssetInterface;
import particle.ErrorParticleSystem;
import scenes.Scene;
import starling.display.BlendMode;
import starling.display.Image;
import starling.events.Event;

class SplashScreenScene extends Scene
{
    
    public var startMenuBox : SplashScreenMenuBox;
    private var background : Image;
    private var particleSystem : ErrorParticleSystem;
    private var foreground : Image;
    
    //would like to dispatch an event and end up here, but
    public static var splashScreenScene : SplashScreenScene;
    
    public function new(game : PipeJamGame)
    {
        super(game);
        splashScreenScene = this;
    }
    
    override private function addedToStage(event : starling.events.Event) : Void
    {
        super.addedToStage(event);
        
        background = new Image(AssetInterface.getTexture("Game", "BoxesStartScreenImageClass"));
        background.scaleX = stage.stageWidth / background.width;
        background.scaleY = stage.stageHeight / background.height;
        background.blendMode = BlendMode.NONE;
        addChild(background);
        
        particleSystem = new ErrorParticleSystem();
        particleSystem.x = (721.0 / 2.0) * background.width / Constants.GameWidth;
        particleSystem.y = (555.0 / 2.0) * background.height / Constants.GameHeight;
        particleSystem.scaleX = particleSystem.scaleY = 8.0;
        addChild(particleSystem);
        
        foreground = new Image(AssetInterface.getTexture("Game", "BoxesStartScreenForegroundImageClass"));
        foreground.scaleX = background.scaleX;
        foreground.scaleY = background.scaleY;
        addChild(foreground);
        
        addMenuBox();
    }
    
    public function addMenuBox() : Void
    {
        startMenuBox = new SplashScreenMenuBox(this);
        addChild(startMenuBox);
    }
    
    override private function removedFromStage(event : Event) : Void
    {
    }
}
