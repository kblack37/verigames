package display;

import assets.AssetInterface;
import assets.AssetNames;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class ZoomInButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Zoom In";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_ZoomInButton))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_ZoomInButtonOver))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_ZoomInButtonSelected))]
        );
    }
}

