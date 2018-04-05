package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class ZoomOutButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Zoom Out";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamSpriteSheetPNG", "PipeJamSpriteSheetXML");
        super(
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomOutButton))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomOutButtonOver))], 
                [new Image(atlas.getTexture(AssetInterface.PipeJamSubTexture_ZoomOutButtonSelected))]
        );
    }
}

