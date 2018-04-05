package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.TextureAtlas;

class ZoomInButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Zoom In";
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        
        super(
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomIn))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomInOver))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonZoomInClick))]
        );
    }
}

