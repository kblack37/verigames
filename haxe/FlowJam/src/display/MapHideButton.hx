package display;

import assets.AssetInterface;
import assets.AssetNames;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class MapHideButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Hide Map";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamLevelSelectSpriteSheet.png", "PipeJamLevelSelectSpriteSheet.xml");
        super(
                [new Image(atlas.getTexture(AssetNames.LevelSelectSubTexture_MapMinimizeButton))], 
                [new Image(atlas.getTexture(AssetNames.LevelSelectSubTexture_MapMinimizeButtonMouseover))], 
                [new Image(atlas.getTexture(AssetNames.LevelSelectSubTexture_MapMinimizeButtonClick))]
        );
    }
}

