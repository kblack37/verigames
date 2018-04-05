package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class RecenterButton extends ImageStateButton
	{
		public function RecenterButton()
		{
			m_toolTipText = "Recenter";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_RecenterButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_RecenterButtonOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_RecenterButtonSelected))])
			);
		}
	}
}
