package display;

import assets.AssetInterface;
import assets.AssetNames;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class MapShowButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Show Map";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetNames.LevelSelectSubTexture_MapMaximizeButton))], 
                [new Image(atlas.getTexture(AssetNames.LevelSelectSubTexture_MapMaximizeButtonMouseover))], 
                [new Image(atlas.getTexture(AssetNames.LevelSelectSubTexture_MapMaximizeButtonClick))]
        );
    }
}

