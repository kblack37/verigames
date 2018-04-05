package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class ZoomInButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Zoom In";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
        super(
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomInButton))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomInButtonOver))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomInButtonSelected))]
        );
    }
}

