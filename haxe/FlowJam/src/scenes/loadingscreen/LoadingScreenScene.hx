package scenes.loadingscreen;

import assets.AssetInterface;
import assets.AssetsFont;
import display.NineSliceButton;
import events.NavigationEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import networking.PlayerValidation;
import networking.TutorialController;
import particle.ErrorParticleSystem;
import scenes.Scene;
import starling.display.BlendMode;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;

class LoadingScreenScene extends Scene
{
    
    private var background : Image;
    private var particleSystem : ErrorParticleSystem;
    private var foreground : Image;
    
    /**Used to hold final message open so it's visible */
    private var timer : Timer;
    /** Set timeout of entire process to not have it feel like it's hanging. */
    private var timeoutTimer : Timer;
    
    public var loading_button : NineSliceButton;
    
    private var sessionVerificationHasBeenAttempted : Bool = false;
    
    
    //would like to dispatch an event and end up here, but
    private static var loadingScreenScene : LoadingScreenScene;
    
    public function new(game : PipeJamGame)
    {
        super(game);
        loadingScreenScene = this;
    }
    
    public static function getLoadingScreenScene() : LoadingScreenScene
    {
        if (loadingScreenScene != null)
        {
            return loadingScreenScene;
        }
        else
        {
            return new LoadingScreenScene(null);
        }
    }
    
    override private function addedToStage(event : starling.events.Event) : Void
    {
        super.addedToStage(event);
        
        background = new Image(AssetInterface.getTexture("img/misc", "BoxesStartScreen.jpg"));
        background.scaleX = stage.stageWidth / background.width;
        background.scaleY = stage.stageHeight / background.height;
        background.blendMode = BlendMode.NONE;
        addChild(background);
        
        particleSystem = new ErrorParticleSystem();
        particleSystem.x = 395.5 * background.width / Constants.GameWidth;
        particleSystem.y = 302.0 * background.height / Constants.GameHeight;
        particleSystem.scaleX = particleSystem.scaleY = 8.0;
        addChild(particleSystem);
        
        foreground = new Image(AssetInterface.getTexture("img/misc", "BoxesStartScreenForeground.png"));
        foreground.scaleX = background.scaleX;
        foreground.scaleY = background.scaleY;
        addChild(foreground);
        
        var BUTTON_CENTER_X : Float = 241;  // center point to put Play and Log In buttons  
        
        loading_button = ButtonFactory.getInstance().createButton("Loading...", 150, 42, 42 / 3.0, 42 / 3.0);
        loading_button.x = BUTTON_CENTER_X - loading_button.width / 2;
        loading_button.y = 230;
        loading_button.removeTouchEvent();  //we want a non-responsive button look  
        addChild(loading_button);
        
        //set max loading time of ten seconds
        timeoutTimer = new Timer(10000, 1);
        timeoutTimer.addEventListener(TimerEvent.TIMER, playerValidationAttempted);
        timeoutTimer.start();
        
        PlayerValidation.validatePlayerIsLoggedInAndActive(playerValidationAttempted, this);
    }
    
    public function timeout(e : TimerEvent = null) : Void
    {
    }
    
    public var count : Int = 0;
    public var playerTimeOut : Bool = false;
    public function playerValidationAttempted(e : TimerEvent = null) : Void
    {
        if (e != null && e.target == timeoutTimer && sessionVerificationHasBeenAttempted == false)
        {
            setStatus("Player Validation Timed Out");
            playerTimeOut = true;
        }
        
        sessionVerificationHasBeenAttempted = true;
        if (timeoutTimer != null)
        {
            timeoutTimer.removeEventListener(TimerEvent.TIMER, playerValidationAttempted);
            timeoutTimer.stop();
        }
        timeoutTimer = null;
        //burn part of a second to let last loading message be visible
        timer = new Timer(600, 1);
        timer.addEventListener(TimerEvent.TIMER, changeScene);
        timer.start();
    }
    
    public function changeScene(e : TimerEvent = null) : Void
    {
        var tutorialController : TutorialController = TutorialController.getTutorialController();
        //would like some way for this to show message when validation failed, not just timed out
        //but without playerTimeOut flag, this never exits the loading screen
        if (timer != null && timer.running && playerTimeOut)
        {
            return;
        }
        else if (timer != null && !timer.running && tutorialController.completedTutorialDictionary != null)
        {
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, changeScene);
        }
        else if (tutorialController.completedTutorialDictionary == null && PlayerValidation.playerLoggedIn)
        {
            timer = new Timer(200, 1);
            timer.addEventListener(TimerEvent.TIMER, changeScene);
            timer.start();  //repeat until tutorial list is returned  
            return;
        }
        timer == null;
        
        if (tutorialController.completedTutorialDictionary != null || PlayerValidation.playerLoggedIn == false)
        {
            dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "SplashScreen"));
        }
    }
    
    override public function setStatus(text : String) : Void
    {
        loading_button.setButtonText(text);
    }
}
