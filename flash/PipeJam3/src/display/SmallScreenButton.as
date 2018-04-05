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
			var atlas:TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
			super(
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMinimize))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMinimizeOver))]),
				Vector.<DisplayObject>([new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMinimizeClick))])
			);			
		}
	}
}
