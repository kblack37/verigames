package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class RecenterButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Recenter";
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        super(
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonCenter))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonCenterOver))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonCenterClick))]
        );
    }
}

