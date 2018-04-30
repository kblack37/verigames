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
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_SmallscreenButton))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_SmallscreenButtonOver))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_SmallscreenButtonSelected))]
        );
    }
}

