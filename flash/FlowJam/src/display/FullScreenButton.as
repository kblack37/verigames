package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.TextureAtlas;
	
	public class FullScreenButton extends ImageStateButton
	{
		public function FullScreenButton()
		{
			m_toolTipText = "Make full screen";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_FullscreenButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_FullscreenButtonOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_FullscreenButtonSelected))])
			);			
		}
	}
}
