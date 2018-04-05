package scenes.splashscreen
{
	import assets.AssetInterface;
	import particle.ErrorParticleSystem;
	import scenes.Scene;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	
	public class SplashScreenScene extends Scene
	{
		
		public var startMenuBox:SplashScreenMenuBox;
		protected var background:Image;
		protected var particleSystem:ErrorParticleSystem;
		protected var foreground:Image;
		
		//would like to dispatch an event and end up here, but
		public static var splashScreenScene:SplashScreenScene;
		
		public function SplashScreenScene(game:PipeJamGame)
		{
			super(game);
			splashScreenScene = this;
		}
		
		protected override function addedToStage(event:starling.events.Event):void
		{
			super.addedToStage(event);
			
			background = new Image(AssetInterface.getTexture("Game", "BoxesStartScreenImageClass"));
			background.scaleX = stage.stageWidth/background.width;
			background.scaleY = stage.stageHeight/background.height;
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
			
		public function addMenuBox():void
		{	
			startMenuBox = new SplashScreenMenuBox(this);
			addChild(startMenuBox);
		}
		
		protected  override function removedFromStage(event:Event):void
		{
			
		}
	}
}