package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class ZoomInButton extends ImageStateButton
	{
		public function ZoomInButton()
		{
			m_toolTipText = "Zoom In";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomInButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomInButtonOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomInButtonSelected))])
			);
		}
	}
}
