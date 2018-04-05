package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.TextureAtlas;

class ZoomOutButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Zoom Out";
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        
        super(
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomOut))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomOutOver))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomOutClick))]
        );
    }
}

