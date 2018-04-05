package scenes.splashscreen
{
	import assets.AssetInterface;
	import scenes.Scene;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	import starling.textures.Texture;
	
	public class SplashScreenScene extends Scene
	{
		
		public var startMenuBox:SplashScreenMenuBox;
		protected var background:Image;
		
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
			
			background = new Image(AssetInterface.getTexture("Game", "ParadoxStartScreenImageClass"));
			background.scaleX = stage.stageWidth/background.width;
			background.scaleY = stage.stageHeight/background.height;
			background.blendMode = BlendMode.NONE;
			addChild(background);
			
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
			var logoTexture:Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ParadoxLogoBlackLarge);
			var logo:Image = new Image(logoTexture);
			logo.scaleX = logo.scaleY = .6;
			logo.x = (background.width - logo.width)/2 + 10; //looks better slightly off-center
			logo.y = 150;
			//logo.scaleX = stage.stageWidth/background.width;
			//logo.scaleY = stage.stageHeight/background.height;
			//logo.blendMode = BlendMode.NONE;
			addChild(logo);
			
			addMenuBox();
			dispatchEvent(new starling.events.Event(PipeJamGame.SET_SOUNDBUTTON_PARENT, true, this));
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