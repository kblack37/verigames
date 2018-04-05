package display;

import assets.AssetInterface;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class SoundButton extends ImageStateButton
{
    public var sfxOn(never, set) : Bool;

    public function new()
    {
        var atlas : TextureAtlas = AssetInterface.ParadoxSpriteSheetAtlas;
        var soundUp : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonSound);
        var soundOver : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonSoundOver);
        var soundDown : Texture = atlas.getTexture(AssetInterface.ParadoxSubTexture_ButtonSoundClick);
        
        var soundOnUp : Image = new Image(soundUp);
        //soundOnUp.width = soundOnUp.height = 25;
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
    
    private function set_sfxOn(on : Bool) : Bool
    {
        setState((on) ? 0 : 1);
        return on;
    }
}

