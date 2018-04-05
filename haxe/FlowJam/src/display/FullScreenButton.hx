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
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
        super(
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_FullscreenButton))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_FullscreenButtonOver))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_FullscreenButtonSelected))]
        );
    }
}

