package display;

import assets.AssetInterface;
import assets.AssetNames;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.TextureAtlas;

class FullScreenButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Make full screen";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_FullscreenButton))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_FullscreenButtonOver))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_FullscreenButtonSelected))]
        );
    }
}

