package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.TextureAtlas;

class FullScreenButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Make full screen";
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        super(
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMaximize))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMaximizeOver))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMaximizeClick))]
        );
    }
}

