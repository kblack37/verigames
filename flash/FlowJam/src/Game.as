package 
{
    import assets.AssetInterface;
	import starling.display.Quad;
    
    import events.NavigationEvent;
    
    import flash.external.ExternalInterface;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
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
    import starling.utils.VAlign;

    public class Game extends BaseComponent
    {
        protected var mMainMenu:Sprite;
        protected var mCurrentScene:Scene;
		protected var scenesToCreate:Dictionary = new Dictionary;
		protected var sceneDictionary:Dictionary = new Dictionary;
				
		private var m_blackFadeScreen:Quad;
		
		private static const FADE_TIME:Number = 0.5;
		public static const START_BUSY_ANIMATION:String = "startBusyAnimation";
		public static const STOP_BUSY_ANIMATION:String = "stopBusyAnimation";
		
		public static const SUPPRESS_TRACE_STATEMENTS:Boolean = true;
		
        public function Game()
        {
            // The following settings are for mobile development (iOS, Android):
            //
            // You develop your game in a *fixed* coordinate system of 480x320; the game might 
            // then run on a device with a different resolution, and the assets class will
            // provide textures in the most suitable format.
            Starling.current.stage.stageWidth  = Constants.GameWidth;
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
		
		protected function prepareAssets():void
		{
			assets.AssetInterface.prepareSounds();
			
			//load images if we haven't
			if(loadingAnimationImages == null)
			{
				loadingAnimationImages = new Vector.<Texture>();
				for(var i:int = 1; i<9; i++)
					loadingAnimationImages.push(AssetInterface.getTexture("Game", "Loading"+i+"Class"));
				
				waitAnimationImages = new Vector.<Texture>();
				for(var ii:int = 1; ii<9; ii++)
					waitAnimationImages.push(AssetInterface.getTexture("Game", "Wait"+ii+"Class"));
			}
		}
        
		protected function onAddedToStage(event:Event):void
        {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
        
		protected function onRemovedFromStage(event:Event):void
        {
         
		}
        
		protected function onChangeScreen(event:NavigationEvent):void
		{
			var callback:Function =
				function():void
				{
					if (mCurrentScene) {
						closeCurrentScene();
					}
					if (event.scene) {
						showScene(event.scene);
					}
				};
			fadeOut(callback);
		}
		
		public function onFadeScreen(event:NavigationEvent):void
		{
			fadeOut(event.fadeCallback);
		}
		
		private var m_fadeCallback:Function;
		public function fadeOut(callback:Function):void
		{
			if (m_fadeCallback != null) {
				m_fadeCallback();
			}
			m_fadeCallback = callback;
			Starling.juggler.removeTweens(m_blackFadeScreen);
			m_blackFadeScreen.alpha = 0;
			addChild(m_blackFadeScreen);
			Starling.juggler.tween(m_blackFadeScreen, FADE_TIME, { alpha:1, 
				onComplete:function():void
				{
					if (m_fadeCallback != null) {
						m_fadeCallback();
					}
					m_fadeCallback = null;
					fadeIn();
				}
			});
		}
		
		public function fadeIn():void
		{
			m_blackFadeScreen.alpha = 1;
			addChild(m_blackFadeScreen);
			Starling.juggler.tween(m_blackFadeScreen, FADE_TIME, { alpha:0, onComplete:function():void { m_blackFadeScreen.removeFromParent(); } } );
		}
		
        protected function closeCurrentScene():void
        {
            mCurrentScene.removeFromParent();
            mCurrentScene = null;
        }
        
        protected function showScene(name:String):void
        {
            if (mCurrentScene) return;
            
			mCurrentScene = sceneDictionary[name];
			if(mCurrentScene == null)
			{
            	var sceneClass:Class = scenesToCreate[name];
            	mCurrentScene = Scene.getScene(sceneClass, this);
				sceneDictionary[name] = mCurrentScene;
				mCurrentScene.setPosition(0,0,480,320);
			}
			
			addChildAt(mCurrentScene, 0);
        }
		
		//use for global wait states. BaseComponent has one you can use with local parents.
		public function onStartBusyAnimation(e:Event):void
		{
			startBusyAnimation();
		}
		
		public function onStopBusyAnimation(e:Event):void
		{
			stopBusyAnimation();
		}
		
		/**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)"
		 * @param	_msg Text to print
		 */
		public static function printDebug(_msg:String):void {
			if (!SUPPRESS_TRACE_STATEMENTS) {
				trace(_msg);
				if (ExternalInterface.available) {
					var reply:String = ExternalInterface.call("printDebug", _msg);
				}
			}
		}
		
		/**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)" - Specifically warnings that may be wanted even if other debug messages are not
		 * @param	_msg Warning text to print
		 */
		public static function printWarning(_msg:String):void {
			if (!SUPPRESS_TRACE_STATEMENTS) {
				trace(_msg);
				if (ExternalInterface.available) {
					var reply:String = ExternalInterface.call("printDebug", _msg);
				}
			}
		}
		
    }
}