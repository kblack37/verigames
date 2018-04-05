package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class MapHideButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Hide Map";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
        super(
                [new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMinimizeButton))], 
                [new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMinimizeButtonMouseover))], 
                [new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMinimizeButtonClick))]
        );
    }
}

