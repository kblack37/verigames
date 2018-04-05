package audio;

import assets.AssetsAudio;
import cgs.audio.IAudioResource;
import flash.media.Sound;

class AudioResource implements IAudioResource
{
    public function getSoundResource(soundName : String) : Sound
    {
        return AssetsAudio.getSoundResource(soundName);
    }

    public function new()
    {
    }
}

