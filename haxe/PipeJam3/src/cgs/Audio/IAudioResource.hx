package cgs.audio;

import flash.media.Sound;

/**
	 * Functions defining an IAudioResource
	 * 
	 * @author Rich
	 **/
interface IAudioResource
{

    function getSoundResource(soundName : String) : Sound
    ;
}

