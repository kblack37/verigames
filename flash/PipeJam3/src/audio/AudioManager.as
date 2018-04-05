package audio
{
	import assets.AssetsAudio;
	import cgs.Audio.Audio;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import display.BasicButton;
	import starling.events.Event;

	public class AudioManager
	{
		/** The cgs common audio class instance for playing all audio */
		private var m_audioDriver:Audio = new Audio();
		
		/** Audio is loading. */
		private var m_audioLoaded:Boolean = false;
		
		/** Button for user to turn music on/off */
		private var m_musicButton:BasicButton;
		private var m_musicCallback:Function;
		
		/** Button for user to turn sound fx on/off */
		private var m_sfxButton:BasicButton;
		private var m_sfxCallback:Function;
		
		/** Button for user to turn all sounds off (sfx + musix) */
		private var m_audioButton:BasicButton;
		private var m_audioCallback:Function;
		private var m_currentMusic:String = "";
		
		private static var m_instance:AudioManager; // singleton instance

		public static function getInstance():AudioManager
		{
			if (m_instance == null) {
				m_instance = new AudioManager(new SingletonLock());
			}
			return m_instance;
		}
		
		public function AudioManager(lock:SingletonLock)
		{
			beginAudioLoad();
		}
		
		public function beginAudioLoad():void
		{
			if (m_audioLoaded) {
				return;
			}
			loadAudioFromEmbedded();
		}

		public function audioLoaded():Boolean
		{
			return m_audioLoaded;
		}
		
		public function audioDriver():Audio
		{
			return m_audioDriver;
		}
		
		public function reset():void
		{
			playMusic("");
			m_audioDriver.reset();
		}
		
		public function playMusic(music:String):void
		{
			m_currentMusic = music;
			m_audioDriver.playMusic(m_currentMusic);
		}
		
		private function loadAudioFromEmbedded():void
		{
			var audioXML:XML = AssetsAudio.getEmbeddedAudioXML();
			loadFromXML(audioXML);
		}
		
		private function loadFromXML(xml:XML):void
		{
			var xmlVec:Vector.<XML> = new Vector.<XML>();
			xmlVec.push(new XML(xml));
			m_audioDriver.init(xmlVec, new AudioResource());
			m_audioDriver.globalVolume = (PipeJam3.ASSET_SUFFIX == "Turk") ? 0 : 0.3;
			m_audioLoaded = true;
		}
		
		public function setMusicButton(musicButton:BasicButton, musicCallback:Function):void
		{
			m_musicButton = musicButton;
			m_musicButton.addEventListener(starling.events.Event.TRIGGERED, onMusicClick);
			
			m_musicCallback = musicCallback;
			updateMusicState();
		}
		
		public function get musicButton():BasicButton
		{
			return m_musicButton;
		}
		
		private function onMusicClick(ev:starling.events.Event):void
		{
			audioDriver().musicOn = (PipeJam3.ASSET_SUFFIX == "Turk") ? false : !audioDriver().musicOn;
			
			updateMusicState();
		}
		
		private function updateMusicState():void
		{
			if (m_musicCallback != null) {
				m_musicCallback(audioDriver().musicOn);
			}
		}
		
		public function setSfxButton(sfxButton:BasicButton, sfxCallback:Function):void
		{
			m_sfxButton = sfxButton;
			m_sfxButton.addEventListener(starling.events.Event.TRIGGERED, onSfxClick);
			
			m_sfxCallback = sfxCallback;
			updateSfxState();
		}
		
		public function get sfxButton():BasicButton
		{
			return m_sfxButton;
		}
		
		private function onSfxClick(ev:starling.events.Event):void
		{
			audioDriver().sfxOn = (PipeJam3.ASSET_SUFFIX == "Turk") ? false : !audioDriver().sfxOn;
			
			updateSfxState();
		}
		
		private function updateSfxState():void
		{
			if (m_sfxCallback != null) {
				m_sfxCallback((PipeJam3.ASSET_SUFFIX == "Turk") ? false : audioDriver().sfxOn);
			}
		}
		
		public function setAllAudioButton(audioButton:BasicButton, audioCallback:Function):void
		{
			m_audioButton = audioButton;
			m_audioButton.addEventListener(starling.events.Event.TRIGGERED, onAllAudioClick);
			audioDriver().musicOn = audioDriver().sfxOn; // force these to be the same value
			m_audioCallback = audioCallback;
			updateAllAudioState();
		}
		
		public function get allAudioButton():BasicButton
		{
			return m_audioButton;
		}
		
		private function onAllAudioClick(ev:starling.events.Event):void
		{
			audioDriver().musicOn = (PipeJam3.ASSET_SUFFIX == "Turk") ? false : (audioDriver().sfxOn = !audioDriver().sfxOn);  // this way they are sure to be both on or both off
			updateAllAudioState();
		}
		
		private function updateAllAudioState():void
		{
			if (m_audioCallback != null) {
				m_audioCallback((PipeJam3.ASSET_SUFFIX == "Turk") ? false : audioDriver().sfxOn);
			}
		}
		
	}
}

internal class SingletonLock {} // to prevent outside construction of singleton
