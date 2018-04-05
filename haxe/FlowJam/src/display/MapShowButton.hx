package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class MapShowButton extends ImageStateButton
{
    public function new()
    {
        m_toolTipText = "Show Map";
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("Game", "PipeJamLevelSelectSpriteSheetPNG", "PipeJamLevelSelectSpriteSheetXML");
        super(
                [new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMaximizeButton))], 
                [new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMaximizeButtonMouseover))], 
                [new Image(atlas.getTexture(AssetInterface.LevelSelectSubTexture_MapMaximizeButtonClick))]
        );
    }
}

