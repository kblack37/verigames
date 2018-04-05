package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class ZoomOutButton extends ImageStateButton
	{
		public function ZoomOutButton()
		{
			m_toolTipText = "Zoom Out";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomOutButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomOutButtonOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomOutButtonSelected))])
			);
		}
	}
}
