package assets
{
	import flash.media.Sound;
	
	public class AssetsAudio
	{
		// these correspond to entries in EmbeddedAudio.xml
		[Embed(source = '../../lib/audio/EmbeddedAudio.xml', mimeType = "application/octet-stream")] private static const XMLEmbeddedAudio:Class;
		
		// sound fx
		[Embed(source = "../../lib/audio/seatbelt.mp3")] private static const HighBeltClass:Class;
		public static const SFX_HIGH_BELT:String = "HighBelt";
		
		[Embed(source = "../../lib/audio/seatbelt-low.mp3")] private static const LowBeltClass:Class;
		public static const SFX_LOW_BELT:String = "LowBelt";
		
		[Embed(source = "../../lib/audio/menu_button.mp3")] private static const MenuButtonClass:Class;
		public static const SFX_MENU_BUTTON:String = "MenuButton";
		
		// music
		[Embed(source = "../../lib/audio/axtoncrolley-nodens-field-song-loop.mp3")] private static const MusicNodensFieldSongClass:Class;
		public static const MUSIC_FIELD_SONG:String = "MusicNodensFieldSong";
		
		public static function getEmbeddedAudioXML():XML
		{
			return XML(new XMLEmbeddedAudio());
		}
		
		public static function getSoundResource(soundName:String):Sound
		{
			switch (soundName) {
				// sound fx
				case SFX_HIGH_BELT:   return new HighBeltClass();
				case SFX_LOW_BELT:    return new LowBeltClass();
				case SFX_MENU_BUTTON: return new MenuButtonClass();
				
				// music
				case MUSIC_FIELD_SONG: return new MusicNodensFieldSongClass();
			}
			throw new Error("Unknown sound resource name " + soundName);
		}
	}
}
