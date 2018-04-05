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
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
        super(
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_RecenterButton))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_RecenterButtonOver))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_RecenterButtonSelected))]
        );
    }
}

