package audio;

import haxe.Constraints.Function;
import assets.AssetsAudio;
import cgs.audio.Audio;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import display.BasicButton;
import haxe.xml.Fast;
import starling.events.Event;

class AudioManager
{
    public var musicButton(get, never) : BasicButton;
    public var sfxButton(get, never) : BasicButton;
    public var allAudioButton(get, never) : BasicButton;

    /** The cgs common audio class instance for playing all audio */
    private var m_audioDriver : Audio = new Audio();
    
    /** Audio is loading. */
    private var m_audioLoaded : Bool = false;
    
    /** Button for user to turn music on/off */
    private var m_musicButton : BasicButton;
    private var m_musicCallback : Function;
    
    /** Button for user to turn sound fx on/off */
    private var m_sfxButton : BasicButton;
    private var m_sfxCallback : Function;
    
    /** Button for user to turn all sounds off (sfx + musix) */
    private var m_audioButton : BasicButton;
    private var m_audioCallback : Function;
    private var m_currentMusic : String = "";
    
    private static var m_instance : AudioManager;  // singleton instance  
    
    public static function getInstance() : AudioManager
    {
        if (m_instance == null)
        {
            m_instance = new AudioManager(new SingletonLock());
        }
        return m_instance;
    }
    
    public function new(lock : SingletonLock)
    {
        beginAudioLoad();
    }
    
    public function beginAudioLoad() : Void
    {
        if (m_audioLoaded)
        {
            return;
        }
        loadAudioFromEmbedded();
    }
    
    public function audioLoaded() : Bool
    {
        return m_audioLoaded;
    }
    
    public function audioDriver() : Audio
    {
        return m_audioDriver;
    }
    
    public function reset() : Void
    {
        playMusic("");
        m_audioDriver.reset();
    }
    
    public function playMusic(music : String) : Void
    {
        m_currentMusic = music;
        m_audioDriver.playMusic(m_currentMusic);
    }
    
    private function loadAudioFromEmbedded() : Void
    {
        var audioXML : Fast = AssetsAudio.getEmbeddedAudioXML();
        loadFromXML(audioXML);
    }
    
    private function loadFromXML(xml : Fast) : Void
    {
        var xmlVec : Array<Fast> = new Array<Fast>();
        xmlVec.push(xml);
        m_audioDriver.init(xmlVec, new AudioResource());
        m_audioDriver.globalVolume = 0.3;
        m_audioLoaded = true;
    }
    
    public function setMusicButton(musicButton : BasicButton, musicCallback : Function) : Void
    {
        m_musicButton = musicButton;
        m_musicButton.addEventListener(starling.events.Event.TRIGGERED, onMusicClick);
        
        m_musicCallback = musicCallback;
        updateMusicState();
    }
    
    private function get_musicButton() : BasicButton
    {
        return m_musicButton;
    }
    
    private function onMusicClick(ev : starling.events.Event) : Void
    {
        audioDriver().musicOn = !audioDriver().musicOn;
        
        updateMusicState();
    }
    
    private function updateMusicState() : Void
    {
        if (m_musicCallback != null)
        {
            m_musicCallback(audioDriver().musicOn);
        }
    }
    
    public function setSfxButton(sfxButton : BasicButton, sfxCallback : Function) : Void
    {
        m_sfxButton = sfxButton;
        m_sfxButton.addEventListener(starling.events.Event.TRIGGERED, onSfxClick);
        
        m_sfxCallback = sfxCallback;
        updateSfxState();
    }
    
    private function get_sfxButton() : BasicButton
    {
        return m_sfxButton;
    }
    
    private function onSfxClick(ev : starling.events.Event) : Void
    {
        audioDriver().sfxOn = !audioDriver().sfxOn;
        
        updateSfxState();
    }
    
    private function updateSfxState() : Void
    {
        if (m_sfxCallback != null)
        {
            m_sfxCallback(audioDriver().sfxOn);
        }
    }
    
    public function setAllAudioButton(audioButton : BasicButton, audioCallback : Function) : Void
    {
        m_audioButton = audioButton;
        m_audioButton.addEventListener(starling.events.Event.TRIGGERED, onAllAudioClick);
        audioDriver().musicOn = audioDriver().sfxOn;  // force these to be the same value  
        m_audioCallback = audioCallback;
        updateAllAudioState();
    }
    
    private function get_allAudioButton() : BasicButton
    {
        return m_audioButton;
    }
    
    private function onAllAudioClick(ev : starling.events.Event) : Void
    {
        audioDriver().musicOn = audioDriver().sfxOn = !audioDriver().sfxOn;  // this way they are sure to be both on or both off  
        updateAllAudioState();
    }
    
    private function updateAllAudioState() : Void
    {
        if (m_audioCallback != null)
        {
            m_audioCallback(audioDriver().sfxOn);
        }
    }
}


class SingletonLock
{

    @:allow(audio)
    private function new()
    {
    }
}  // to prevent outside construction of singleton  
