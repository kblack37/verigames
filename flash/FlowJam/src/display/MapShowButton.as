package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class MapShowButton extends ImageStateButton
	{
		public function MapShowButton()
		{
			m_toolTipText = "Show Map";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMaximizeButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMaximizeButtonMouseover))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMaximizeButtonClick))])
			);
		}
	}
}
