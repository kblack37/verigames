package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class MapHideButton extends ImageStateButton
	{
		public function MapHideButton()
		{
			m_toolTipText = "Hide Map";
			var atlas:TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMinimizeButton))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMinimizeButtonMouseover))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMinimizeButtonClick))])
			);
		}
	}
}
