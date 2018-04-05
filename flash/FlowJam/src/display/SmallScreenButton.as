package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.TextureAtlas;
	
	public class SmallScreenButton extends ImageStateButton
	{
		public function SmallScreenButton()
		{
			m_toolTipText = "Exit full screen";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_SmallscreenButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_SmallscreenButtonOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_SmallscreenButtonSelected))])
			);			
		}
	}
}
