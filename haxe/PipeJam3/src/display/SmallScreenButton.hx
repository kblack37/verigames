package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.TextureAtlas;

class SmallScreenButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Exit full screen";
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        super(
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMinimize))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMinimizeOver))], 
                [new Image(atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonMinimizeClick))]
        );
    }
}

