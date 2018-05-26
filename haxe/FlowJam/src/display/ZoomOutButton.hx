package display;

import assets.AssetInterface;
import assets.AssetNames;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class ZoomOutButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Zoom Out";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_ZoomOutButton))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_ZoomOutButtonOver))], 
                [new Image(atlas.getTexture(AssetNames.PipeJamSubTexture_ZoomOutButtonSelected))]
        );
    }
}

