package audio
{
	import assets.AssetsAudio;
	import cgs.Audio.IAudioResource;
	import flash.media.Sound;
	
	public class AudioResource implements IAudioResource
	{
		public function getSoundResource(soundName:String):Sound
		{
			return AssetsAudio.getSoundResource(soundName);
		}
	}
}
