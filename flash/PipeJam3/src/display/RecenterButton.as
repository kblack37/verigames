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
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonCenter))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonCenterOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonCenterClick))])
			);
		}
	}
}
