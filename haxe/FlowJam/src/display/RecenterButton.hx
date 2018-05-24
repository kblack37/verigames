package display;

import assets.AssetInterface;
import assets.AssetNames;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class RecenterButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Recenter";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_RecenterButton))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_RecenterButtonOver))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_RecenterButtonSelected))]
        );
    }
}

