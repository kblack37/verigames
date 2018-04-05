package display
{
	import assets.AssetInterface;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.TextureAtlas;
	
	public class ZoomInButton extends ImageStateButton
	{
		public function ZoomInButton()
		{
			m_toolTipText = "Zoom In";
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
			
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomIn))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomInOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomInClick))])
			);
		}
	}
}
