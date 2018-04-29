import haxe.Constraints.Function;
import lime.utils.AssetType;
//import assets.AssetInterface;
import starling.display.Quad;
import flash.Vector;
import events.NavigationEvent;
import flash.external.ExternalInterface;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import scenes.BaseComponent;
import scenes.Scene;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Button;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.Align;
import lime.Assets;

class Game extends BaseComponent
{
    private var mMainMenu : Sprite;
    private var mCurrentScene : Scene;
    private var scenesToCreate : Dictionary<String,Scene> = new Dictionary();
    private var sceneDictionary : Dictionary<String,Scene> = new Dictionary();
    
    private var m_blackFadeScreen : Quad;
    
    private static inline var FADE_TIME : Float = 0.5;
    public static inline var START_BUSY_ANIMATION : String = "startBusyAnimation";
    public static inline var STOP_BUSY_ANIMATION : String = "stopBusyAnimation";
    
    public static var SUPPRESS_TRACE_STATEMENTS : Bool = true;
    
    public function new()
    {
        super();
        // The following settings are for mobile development (iOS, Android):
        //
        // You develop your game in a *fixed* coordinate system of 480x320; the game might
        // then run on a device with a different resolution, and the assets class will
        // provide textures in the most suitable format.
        Starling.current.stage.stageWidth = Constants.GameWidth;
        Starling.current.stage.stageHeight = Constants.GameHeight;
        
        m_blackFadeScreen = new Quad(Constants.GameWidth, Constants.GameHeight, 0x0);
        
        assets.AssetInterface.contentScaleFactor = Starling.current.contentScaleFactor;
        
        addEventListener(NavigationEvent.CHANGE_SCREEN, onChangeScreen);
        addEventListener(NavigationEvent.FADE_SCREEN, onFadeScreen);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        
        addEventListener(START_BUSY_ANIMATION, onStartBusyAnimation);
        addEventListener(STOP_BUSY_ANIMATION, onStopBusyAnimation);
    }
    
    private function prepareAssets() : Void
    {
       // assets.AssetInterface.prepareSounds();
        
        //load images if we haven't
        if (BaseComponent.loadingAnimationImages == null)
        {
            BaseComponent.loadingAnimationImages = new Vector<Texture>();
            for (i in 1...9)
            {
                //BaseComponent.loadingAnimationImages.push(AssetInterface.getTexture("Game", "Loading" + i + "Class"));TODO: remove if works
				BaseComponent.loadingAnimationImages.push(Assets.getAsset("img/LoadingAnimation/Loading"+i+".png",AssetType.IMAGE,true));
            }
            
            BaseComponent.waitAnimationImages = new Vector<Texture>();
            for (ii in 1...9)
            {
                //BaseComponent.waitAnimationImages.push(AssetInterface.getTexture("Game", "Wait" + ii + "Class"));TODO:remove if works
				BaseComponent.loadingAnimationImages.push(Assets.getAsset("img/LoadingAnimation/FlowJamWait" + ii + ".png",AssetType.IMAGE,true));
            }
			
        }
		
    }
    
    private function onAddedToStage(event : Event) : Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function onRemovedFromStage(event : Event) : Void
    {
    }
    
    private function onChangeScreen(event : NavigationEvent) : Void
    {
        var callback : Function = 
        function() : Void
        {
            if (mCurrentScene != null)
            {
                closeCurrentScene();
            }
            if (event.scene!=null)
            {
                showScene(event.scene);
            }
        };
        fadeOut(callback);
    }
    
    public function onFadeScreen(event : NavigationEvent) : Void
    {
        fadeOut(event.fadeCallback);
    }
    
    private var m_fadeCallback : Function;
    public function fadeOut(callback : Function) : Void
    {
        if (m_fadeCallback != null)
        {
            m_fadeCallback();
        }
        m_fadeCallback = callback;
        Starling.current.juggler.removeTweens(m_blackFadeScreen);
        m_blackFadeScreen.alpha = 0;
        addChild(m_blackFadeScreen);
        Starling.current.juggler.tween(m_blackFadeScreen, FADE_TIME, {
                    alpha : 1,
                    onComplete : function() : Void
                    {
                        if (m_fadeCallback != null)
                        {
                            m_fadeCallback();
                        }
                        m_fadeCallback = null;
                        fadeIn();
                    }
                });
    }
    
    public function fadeIn() : Void
    {
        m_blackFadeScreen.alpha = 1;
        addChild(m_blackFadeScreen);
        Starling.current.juggler.tween(m_blackFadeScreen, FADE_TIME, {
                    alpha : 0,
                    onComplete : function() : Void
                    {
                        m_blackFadeScreen.removeFromParent();
                    }
                });
    }
    
    private function closeCurrentScene() : Void
    {
        mCurrentScene.removeFromParent();
        mCurrentScene = null;
    }
    
    private function showScene(name : String) : Void
    {
        if (mCurrentScene != null)
        {
            return;
        }
        
        mCurrentScene = Reflect.field(sceneDictionary, name);
        if (mCurrentScene == null)
        {
            var sceneClass : Class<Dynamic> = Reflect.field(scenesToCreate, name);
            mCurrentScene = Scene.getScene(sceneClass, this);
            Reflect.setField(sceneDictionary, name, mCurrentScene);
            mCurrentScene.setPosition(0, 0, 480, 320);
        }
        
        addChildAt(mCurrentScene, 0);
    }
    
    //use for global wait states. BaseComponent has one you can use with local parents.
    public function onStartBusyAnimation(e : Event) : Void
    {
        startBusyAnimation();
    }
    
    public function onStopBusyAnimation(e : Event) : Void
    {
        stopBusyAnimation();
    }
    
    /**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)"
		 * @param	_msg Text to print
		 */
    public static function printDebug(_msg : String) : Void
    {
        if (!SUPPRESS_TRACE_STATEMENTS)
        {
            trace(_msg);
            if (ExternalInterface.available)
            {
                var reply : String = ExternalInterface.call("printDebug", _msg);
            }
        }
    }
    
    /**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)" - Specifically warnings that may be wanted even if other debug messages are not
		 * @param	_msg Warning text to print
		 */
    public static function printWarning(_msg : String) : Void
    {
        if (!SUPPRESS_TRACE_STATEMENTS)
        {
            trace(_msg);
            if (ExternalInterface.available)
            {
                var reply : String = ExternalInterface.call("printDebug", _msg);
            }
        }
    }
}
