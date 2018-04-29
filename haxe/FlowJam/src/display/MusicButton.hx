package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class MusicButton extends ImageStateButton
{
    public var musicOn(never, set) : Bool;

    public function new()
    {
        var atlas : TextureAtlas = AssetInterface.getTextureAtlas("atlases", "PipeJamSpriteSheet.png", "PipeJamSpriteSheet.xml");
        var soundUp : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_SoundButton);
        var soundOver : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_SoundButtonOver);
        var soundDown : Texture = atlas.getTexture(AssetInterface.PipeJamSubTexture_SoundButtonSelected);
        
        var soundOnUp : Image = new Image(soundUp);
        var soundOffUp : Image = new Image(soundUp);
        soundOffUp.alpha = 0.5;
        var soundOnOver : Image = new Image(soundOver);
        var soundOffOver : Image = new Image(soundOver);
        soundOffOver.alpha = 0.5;
        var soundOnDown : Image = new Image(soundDown);
        var soundOffDown : Image = new Image(soundDown);
        soundOffDown.alpha = 0.5;
        
        super(
                [soundOnUp, soundOffUp], 
                [soundOnOver, soundOffOver], 
                [soundOnDown, soundOffDown]
        );
    }
    
    private function set_musicOn(on : Bool) : Bool
    {
        setState((on) ? 0 : 1);
        return on;
    }
}

