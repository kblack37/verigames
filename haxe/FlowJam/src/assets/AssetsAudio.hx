package assets;

import flash.errors.Error;
import flash.media.Sound;
import haxe.xml.Fast;
import haxe.xml.Parser;
import openfl.Assets;

class AssetsAudio
{
    public static inline var SFX_HIGH_BELT : String = "HighBelt";

    public static inline var SFX_LOW_BELT : String = "LowBelt";

    public static inline var SFX_MENU_BUTTON : String = "MenuButton";
    
    public static inline var MUSIC_FIELD_SONG : String = "MusicNodensFieldSong";
    
    public static function getEmbeddedAudioXML() : Fast
    {	
        return new Fast(Xml.parse(Assets.getText("audio/EmbeddedAudio.xml")).firstElement());
    }
    
    public static function getSoundResource(soundName : String) : Sound
    {
        switch (soundName)
        {
            // sound fx
            case SFX_HIGH_BELT:return Assets.getSound("audio/seatbelt.mp3");
            case SFX_LOW_BELT:return Assets.getSound("audio/seatbelt-low.mp3");
            case SFX_MENU_BUTTON:return Assets.getSound("audio/menu_button.mp3");
            
            // music
            case MUSIC_FIELD_SONG:return Assets.getSound("audio/axtoncrolley-nodens-field-song-loop.mp3");
        }
        throw new Error("Unknown sound resource name " + soundName);
    }

    public function new()
    {
    }
}

