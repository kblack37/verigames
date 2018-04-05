package
{
	import assets.AssetInterface;
	import assets.AssetsFont;
	import display.NineSliceButton;
	import display.NineSliceToggleButton;
	
	public class ButtonFactory
	{
		private static var m_instance:ButtonFactory;
		
		private static const BUTTON_TEXT_COLOR:uint = PipeJam3.ASSET_SUFFIX ? 0xFFFFFF : 0x4F2C12;
		private static const BUTTON_BACKGROUND_COLOR:uint = PipeJam3.ASSET_SUFFIX ? 0x0 : 0xF3D18D;
		
		public static function getInstance():ButtonFactory
		{
			if (m_instance == null) {
				m_instance = new ButtonFactory(new SingletonLock());
			}
			return m_instance;
		}
		
		public function ButtonFactory(lock:SingletonLock):void
		{
		}
		
		public function createDefaultButton(text:String, width:Number, height:Number):NineSliceButton
		{
			return createButton(text, width, height, height / 3.0, height / 3.0);
		}
		
		public function createButton(text:String, width:Number, height:Number, cX:Number, cY:Number, toolTipText:String = ""):NineSliceButton
		{
			return new NineSliceButton(text, width, height, cX, cY, AssetInterface.PipeJamSpriteSheetAtlas, 
				AssetInterface.PipeJamSubTexture_MenuButtonPrefix, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR,
				AssetInterface.PipeJamSubTexture_MenuButtonOverPrefix, AssetInterface.PipeJamSubTexture_MenuButtonSelectedPrefix,
				0xFFFFFF, 0xFFFFFF, toolTipText);
		}
		
		public function createDefaultToggleButton(text:String, width:Number, height:Number, _toolTipText:String = ""):NineSliceToggleButton
		{
			return createToggleButton(text, width, height, width / 3.0, height / 3.0, _toolTipText);
		}
		
		public function createToggleButton(text:String, width:Number, height:Number, cX:Number, cY:Number, _toolTipText:String = ""):NineSliceToggleButton
		{
			return new NineSliceToggleButton(text, width, height, cX, cY, _toolTipText, AssetInterface.PipeJamSpriteSheetAtlas, 
				AssetInterface.PipeJamSubTexture_MenuButtonPrefix, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR,
				AssetInterface.PipeJamSubTexture_MenuButtonOverPrefix, AssetInterface.PipeJamSubTexture_MenuButtonSelectedPrefix);
		}
		
		public function createTabButton(text:String, width:Number, height:Number, cX:Number, cY:Number, _toolTipText:String = ""):NineSliceToggleButton
		{
			return new NineSliceToggleButton(text, width, height, cX, cY, _toolTipText, AssetInterface.PipeJamLevelSelectAtlas, 
				"TabInactive", AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR,
				"TabInactiveMouseover", "TabActive");
		}
		
		public function createImageButton(imageName:String, width:Number, height:Number, cX:Number, cY:Number):NineSliceButton
		{
			return new NineSliceButton("", width, height, cX, cY, AssetInterface.ParadoxSpriteSheetAtlas, 
				"Button"+imageName, AssetsFont.FONT_UBUNTU, BUTTON_TEXT_COLOR,
				"Button"+imageName+"Over", "Button"+imageName+"Click");
		}
	}
}

internal class SingletonLock {} // to prevent outside construction of singleton
