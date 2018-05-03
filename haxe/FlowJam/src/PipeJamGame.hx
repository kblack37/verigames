import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.net.URLVariables;
import flash.system.System;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.Timer;
import assets.AssetsAudio;
import audio.AudioManager;
import buildInfo.BuildInfo;
import cgs.cache.CGSCache;
import dialogs.SimpleAlertDialog;
import display.GameObjectBatch;
import display.MusicButton;
import display.NineSliceBatch;
//import display.PipeJamTheme;
import display.SoundButton;
import events.MenuEvent;
import events.NavigationEvent;
import networking.GameFileHandler;
import networking.PlayerValidation;
import networking.TutorialController;
import scenes.game.PipeJamGameScene;
import scenes.game.display.World;
import scenes.levelselectscene.LevelSelectScene;
import scenes.loadingscreen.LoadingScreenScene;
import scenes.splashscreen.SplashScreenScene;
import starling.core.Starling;
import starling.events.Event;
import starling.events.KeyboardEvent;
import utils.XSprite;

// TODO: the cgs cache is no longer static and so any references
// to it must be refactored
class PipeJamGame extends Game
{
    /** Set by flashVars */
    public static var DEBUG_MODE : Bool = false;
    
    /** Set to true to print trace statements identifying the type of objects that are clicked on */
    public static var DEBUG_IDENTIFY_CLICKED_ELEMENTS_MODE : Bool = false;
    
    public static var SEPARATE_FILES : Int = 1;
    public static var ALL_IN_ONE : Int = 2;
    
    //public static var theme : PipeJamTheme;
    
    private var m_musicButton : MusicButton;
    private static var m_sfxButton : SoundButton;
    
    private var m_gameObjectBatch : GameObjectBatch;
    
    /** this is the main holder of information about the level. */
    public static var levelInfo : Dynamic;
    
    public static var m_pipeJamGame : PipeJamGame;
    
    public var m_fileName : String;
    
    
    public function new()
    {
        super();
        m_pipeJamGame = this;
        
        // load general assets
        prepareAssets();
        
        Reflect.setField(scenesToCreate, "LoadingScene", LoadingScreenScene);
        Reflect.setField(scenesToCreate, "SplashScreen", SplashScreenScene);
        Reflect.setField(scenesToCreate, "LevelSelectScene", LevelSelectScene);
        Reflect.setField(scenesToCreate, "PipeJamGame", PipeJamGameScene);
        
        AudioManager.getInstance().reset();
        //AudioManager.getInstance().audioDriver().musicOn = !Boolean(Cache.getSave(Constants.CACHE_MUTE_MUSIC));
        //AudioManager.getInstance().audioDriver().sfxOn = AudioManager.getInstance().audioDriver().musicOn = !cast(CGSCache.getSave(Constants.CACHE_MUTE_SFX), Bool);
        
        /*
			m_musicButton = new MusicButton();
			XSprite.setupDisplayObject(m_musicButton, 16.5, Constants.GameHeight - 14.5, 12.5);
			AudioManager.getInstance().setMusicButton(m_musicButton, updateMusicState);
			*/
        m_sfxButton = new SoundButton();
        XSprite.setupDisplayObject(m_sfxButton, 20, Constants.GameHeight - 20, 12.5);
        AudioManager.getInstance().setAllAudioButton(m_sfxButton, updateSfxState);
        
        this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStage);
        this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, removedFromStage);
        
        this.addEventListener(MenuEvent.TOGGLE_SOUND_CONTROL, toggleSoundControl);
        addEventListener(NavigationEvent.GET_RANDOM_LEVEL, onGetRandomLevel);
        addEventListener(NavigationEvent.GET_SAVED_LEVEL, onGetSavedLevel);
    }
    
    //override to get your scene initialized for viewing
    private function addedToStage(event : starling.events.Event) : Void
    {
        //theme = new PipeJamTheme(this.stage);
        //	theme1 = new AeonDesktopTheme( this.stage );
        
        m_gameObjectBatch = new GameObjectBatch();
        NineSliceBatch.gameObjectBatch = m_gameObjectBatch;
        
        var obj : Dynamic = Starling.current.nativeStage.loaderInfo.parameters;
        if (obj.exists("localfile"))
        {
            m_fileName = Reflect.field(obj, "localfile");
            PipeJamGame.levelInfo = {};
        }
        else if (obj.exists("dbfile"))
        {
            m_fileName = Reflect.field(obj, "dbfile");
        }
        if (obj.exists("tutorial"))
        {
            m_fileName = "tutorial";
            PipeJamGame.levelInfo = {};
            PipeJamGame.levelInfo.name = "foo";
            PipeJamGame.levelInfo.id = Reflect.field(obj, "tutorial");
            PipeJamGame.levelInfo.tutorialLevelID = Reflect.field(obj, "tutorial");
            TutorialController.getTutorialController().getTutorialsCompletedFromCookieString();
        }
        else if (ExternalInterface.available)
        {
            var url : String = ExternalInterface.call("window.location.href.toString");
            var paramsStart : Int = url.indexOf("?");
            if (paramsStart != -1)
            {
                var params : String = url.substring(paramsStart + 1);
                var vars : URLVariables = new URLVariables(params);
                if (vars.localfile)
                {
                    m_fileName = vars.localfile;
                    //create this here so we know this is a local file
                    PipeJamGame.levelInfo = {};
                }
                else if (vars.dbfile)
                {
                    m_fileName = vars.dbfile;
                }
                else if (vars.tutorial)
                {
                    m_fileName = "tutorial";
                    PipeJamGame.levelInfo = {};
                    PipeJamGame.levelInfo.name = "foo";
                    PipeJamGame.levelInfo.id = vars.tutorial;
                    PipeJamGame.levelInfo.tutorialLevelID = vars.tutorial;
                    TutorialController.getTutorialController().getTutorialsCompletedFromCookieString();
                }
            }
        }
        
        // use file if set in url, else create and show menu screen
        if (m_fileName != null)
        {
            if (PipeJamGame.levelInfo)
            {
            //local file
                
                showScene("PipeJamGame");
            }
            else
            {
                loadLevelFromName(m_fileName);
            }
        }
        else if (PipeJam3.RELEASE_BUILD && !PipeJam3.LOCAL_DEPLOYMENT)
        {
            showScene("LoadingScene");
        }
        else
        {
            PlayerValidation.playerID = PlayerValidation.playerIDForTesting;
            TutorialController.getTutorialController().getTutorialsCompletedByPlayer();
            showScene("SplashScreen");
        }
        
        addChild(m_sfxButton);
        
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }
    
    //load file from db based on level name i.e. L120_V60
    public function loadLevelFromName(levelName : String) : Void
    {
        GameFileHandler.loadLevelInfoFromName(levelName, loadLevel);
    }
    
    private function loadLevel(result : Int, objVector : Array<Dynamic>) : Void
    {
        PipeJamGame.levelInfo = Type.createInstance(objVector[0], new Array<Dynamic>());
        PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
    }
    
    private function removedFromStage(event : starling.events.Event) : Void
    {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        removeEventListener(NavigationEvent.GET_RANDOM_LEVEL, onGetRandomLevel);
        removeEventListener(NavigationEvent.GET_SAVED_LEVEL, onGetSavedLevel);
    }
    
    private function onGetSavedLevel(event : NavigationEvent) : Void
    {
        PipeJamGameScene.inTutorial = false;
        PipeJamGame.levelInfo = GameFileHandler.findLevelObject(PipeJam3.m_savedCurrentLevel.data.levelInfoID);
        
        if (levelInfo != null)
        {
        //update assignmentsID if needed
            
            PipeJamGameScene.levelContinued = true;
            PipeJamGame.levelInfo.assignmentsID = PipeJam3.m_savedCurrentLevel.data.assignmentsID;
            dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
            GameFileHandler.getHighScoresForLevel(handleHighScoreList, PipeJamGame.levelInfo.levelID);
        }
        //just alert user, and then get random level
        else
        {
            
            {
                var dialogText : String = "Previous level doesn't exist any\n more. Serving a random level.";
                var alert : SimpleAlertDialog = new SimpleAlertDialog(dialogText, 160, 80, "", onGetRandomLevel, 2);
                addChild(alert);
            }
        }
    }
    
    private function onGetRandomLevel(event : NavigationEvent = null) : Void
    {
        PipeJamGameScene.inTutorial = false;
        PipeJamGame.levelInfo = GameFileHandler.getRandomLevelObject();
        if (PipeJamGame.levelInfo == null)
        {
        //assume level file is slow loading, and cycle back around after a while.
            
            //maybe only happens when debugging locally...
            var timer : Timer = new Timer(250, 1);
            timer.addEventListener(TimerEvent.TIMER, getRandomLevelCallback);
            timer.start();
        }
        else
        {
            GameFileHandler.getHighScoresForLevel(handleHighScoreList, PipeJamGame.levelInfo.levelID);
            //save info locally so we can retrieve next run
            PipeJam3.m_savedCurrentLevel.data.levelInfoID = PipeJamGame.levelInfo.id;
            PipeJam3.m_savedCurrentLevel.data.levelID = PipeJamGame.levelInfo.levelID;
            PipeJam3.m_savedCurrentLevel.data.assignmentsID = PipeJamGame.levelInfo.assignmentsID;
            PipeJam3.m_savedCurrentLevel.data.layoutID = PipeJamGame.levelInfo.layoutID;
            PipeJam3.m_savedCurrentLevel.data.assignmentUpdates = {};
            dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
        }
    }
    
    public function getRandomLevelCallback(e : TimerEvent = null) : Void
    {
        onGetRandomLevel();
    }
    
    private function handleHighScoreList(result : Int, list : Array<Dynamic>) : Void
    {
        var highScoreArray : Array<Dynamic> = new Array<Dynamic>();
        for (level in list)
        {
            level.numericScore = level.current_score;
            highScoreArray.push(level);
        }
        
        if (highScoreArray.length > 0)
        {
            highScoreArray.sort(function(a : Dynamic, b : Dynamic) : Int {
				if (b.numericScore > a.numericScore) {
					return -1;
				} else if (a.numericScore > b.numericScore) {
					return 1;
				} else {
					return 0;
				}
			});
        }
        
        PipeJamGame.levelInfo.highScores = highScoreArray;
        
        if (World.m_world != null)
        {
            World.m_world.setHighScores();
        }
    }
    
    private function toggleSoundControl(event : starling.events.Event) : Void
    {
        m_sfxButton.visible = event.data;
        if (m_sfxButton.visible)
        {
            AudioManager.getInstance().reset();
            AudioManager.getInstance().playMusic(AssetsAudio.MUSIC_FIELD_SONG);
        }
    }
    
    private function onKeyDown(event : KeyboardEvent) : Void
    {
        if (event.ctrlKey && event.altKey && event.shiftKey && event.keyCode == Keyboard.V)
        {
            var buildId : String = BuildInfo.DATE + "-" + BuildInfo.VERSION;
            trace(buildId);
            System.setClipboard(buildId);
        }
    }
    
    private function updateMusicState(musicOn : Bool) : Void
    {
        m_musicButton.musicOn = musicOn;
        //var result : Bool = Cache.setSave(Constants.CACHE_MUTE_MUSIC, !musicOn);
        //trace("Cache updateMusicState: " + result);
    }
    
    private function updateSfxState(sfxOn : Bool) : Void
    {
        m_sfxButton.sfxOn = sfxOn;
        //var result : Bool = Cache.setSave(Constants.CACHE_MUTE_SFX, !sfxOn);
        //trace("Cache updateSfxState: " + result);
    }
    
    /**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)"
		 * @param	_msg Text to print
		 */
    public static function printDebug(_msg : String) : Void
    {  //			if (!SUPPRESS_TRACE_STATEMENTS) {  
        //				trace(_msg);
        //				if (ExternalInterface.available) {
        //					//var reply:String = ExternalInterface.call("navTo", URLBASE + "browsing/card.php?id=" + quiz_card_asked + "&topic=" + TOPIC_NUM);
        //					var reply:String = ExternalInterface.call("printDebug", _msg);
        //				}
        //			}
        
    }
    
    /**
		 * This prints any debug messages to Javascript if embedded in a webpage with a script "printDebug(msg)" - Specifically warnings that may be wanted even if other debug messages are not
		 * @param	_msg Warning text to print
		 */
    public static function printWarning(_msg : String) : Void
    {
        if (!Game.SUPPRESS_TRACE_STATEMENTS)
        {
            trace(_msg);
            if (ExternalInterface.available)
            {
            //var reply:String = ExternalInterface.call("navTo", URLBASE + "browsing/card.php?id=" + quiz_card_asked + "&topic=" + TOPIC_NUM);
                
                var reply : String = ExternalInterface.call("printDebug", _msg);
            }
        }
    }
    
    public static function resetSoundButtonParent() : Void
    {
        if (World.m_world != null)
        {
            World.m_world.addSoundButton(m_sfxButton);
        }
    }
    
    public function changeFullScreen(newWidth : Int, newHeight : Int) : Void
    {
        if (World.m_world != null)
        {
            World.m_world.changeFullScreen(newWidth, newHeight);
        }
    }
}
