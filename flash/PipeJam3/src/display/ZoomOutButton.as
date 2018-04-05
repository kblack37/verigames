package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.TextureAtlas;
	
	public class ZoomOutButton extends ImageStateButton
	{
		public function ZoomOutButton()
		{
			m_toolTipText = "Zoom Out";
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;

			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomOut))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomOutOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomOutClick))])
			);
		}
	}
}
