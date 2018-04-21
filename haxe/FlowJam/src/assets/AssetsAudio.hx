package assets;

import flash.errors.Error;
import flash.media.Sound;
import haxe.xml.Fast;
import haxe.xml.Parser;

class AssetsAudio
{
    // these correspond to entries in EmbeddedAudio.xml
    @:meta(Embed(source="../../lib/audio/EmbeddedAudio.xml",mimeType="application/octet-stream"))
private static var XMLEmbeddedAudio : Class<Dynamic>;
    
    // sound fx
    @:meta(Embed(source="../../lib/audio/seatbelt.mp3"))
private static var HighBeltClass : Class<Dynamic>;
    public static inline var SFX_HIGH_BELT : String = "HighBelt";
    
    @:meta(Embed(source="../../lib/audio/seatbelt-low.mp3"))
private static var LowBeltClass : Class<Dynamic>;
    public static inline var SFX_LOW_BELT : String = "LowBelt";
    
    @:meta(Embed(source="../../lib/audio/menu_button.mp3"))
private static var MenuButtonClass : Class<Dynamic>;
    public static inline var SFX_MENU_BUTTON : String = "MenuButton";
    
    // music
    @:meta(Embed(source="../../lib/audio/axtoncrolley-nodens-field-song-loop.mp3"))
private static var MusicNodensFieldSongClass : Class<Dynamic>;
    public static inline var MUSIC_FIELD_SONG : String = "MusicNodensFieldSong";
    
    public static function getEmbeddedAudioXML() : Fast
    {	
        return new Fast(Xml.parse(Type.createInstance(XMLEmbeddedAudio, [])));
    }
    
    public static function getSoundResource(soundName : String) : Sound
    {
        switch (soundName)
        {
            // sound fx
            case SFX_HIGH_BELT:return Type.createInstance(HighBeltClass, []);
            case SFX_LOW_BELT:return Type.createInstance(LowBeltClass, []);
            case SFX_MENU_BUTTON:return Type.createInstance(MenuButtonClass, []);
            
            // music
            case MUSIC_FIELD_SONG:return Type.createInstance(MusicNodensFieldSongClass, []);
        }
        throw new Error("Unknown sound resource name " + soundName);
    }

    public function new()
    {
    }
}

