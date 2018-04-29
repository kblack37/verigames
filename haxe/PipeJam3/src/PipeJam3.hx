import server.MTurkAPI;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import assets.AssetsFont;
//import cgs.server.logging.data.QuestData;
import dialogs.SimpleAlertDialog;
import events.MenuEvent;
import events.NavigationEvent;
//import net.hires.debug.Stats;
import networking.Achievements;
import networking.GameFileHandler;
import networking.HTTPCookies;
import networking.NetworkConnection;
import server.LoggingServerInterface;
import server.ReplayController;
import starling.core.Starling;
import system.VerigameServerConstants;

@:meta(SWF(width="960",height="640",frameRate="30",backgroundColor="#ffffff"))

class PipeJam3 extends flash.display.Sprite
{
    public static var GAME_ID : Int = 1;
    
    private var mStarling : Starling;
    
    /** At most one of these two should be true. They can both be false. */
    public static var RELEASE_BUILD : Bool = false;
    public static var TUTORIAL_DEMO : Bool = false;
    public static var ASSET_SUFFIX : String = "";  // specify "Turk" to change atlases to turk  
	
    //if release build is true, true if using production machine db/info, false if using staging
    public static var PRODUCTION_BUILD : Bool = true;
    
    /** turn on logging of game play. */
    public static var LOGGING_ON : Bool = true;
    
    /** to be hosted on the installer dvd. Changes location of scripts on server */
    public static var INSTALL_DVD : Bool = false;
    
    /** show frames per second, and memory usage. */
    public static var SHOW_PERFORMANCE_STATS : Bool = false;
    
    public static var REPLAY_DQID : String;  // = "dqid_5252fd7aa741e8.90134465";  
    private static var REPLAY_TEXT_FORMAT : TextFormat = new TextFormat(AssetsFont.FONT_UBUNTU, 6, 0xFFFF00);
    
    public static var DISABLE_FILTERS : Bool = true;
    
    public static inline var SELECTION_STYLE_CLASSIC : Int = 0;
    public static inline var SELECTION_STYLE_VAR_BY_VAR : Int = 1;
    public static inline var SELECTION_STYLE_VAR_BY_VAR_AND_CNSTR : Int = 2;
    public static var SELECTION_STYLE : Int = SELECTION_STYLE_VAR_BY_VAR_AND_CNSTR;
    
    public static var logging : LoggingServerInterface;
    public static var loggingKey : String = ((ASSET_SUFFIX == "Turk")) ? LoggingServerInterface.SETUP_KEY_TURK : LoggingServerInterface.SETUP_KEY_FRIENDS_AND_FAMILY_BETA;
    private var hasBeenAddedToStage : Bool = false;
    private var isFullScreen : Bool = false;
    
    public static var pipeJam3 : PipeJam3;
    
    private static var m_replayText : TextField = new TextField();
    
    public function new()
    {
        super();
        pipeJam3 = this;
        addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
        
        if (REPLAY_DQID != null || PipeJam3.LOGGING_ON)
        {
            logging = new LoggingServerInterface(loggingKey, stage, "", REPLAY_DQID != null);
            if (REPLAY_DQID != null)
            {
                ReplayController.getInstance().loadQuestData(REPLAY_DQID, logging.cgsServer, onReplayQuestDataLoaded);
            }
        }
    }
    
    public function onAddedToStage(evt : flash.events.Event) : Void
    {
        if (hasBeenAddedToStage == false)
        {
            removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
            
            initialize();
        }
    }
    
    public function initialize(result : Int = 0, e : flash.events.Event = null) : Void
    {
        MouseWheelTrap.setup(stage);
        
        //set up the main controller
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        
        Starling.multitouchEnabled = false;  // useful on mobile devices  
        Starling.handleLostContext = true;  // deactivate on mobile devices (to save memory)  
        
        if (SHOW_PERFORMANCE_STATS)
        {
            var stats : Stats = new Stats();
            stage.addChild(stats);
        }
        
        //	mStarling = new Starling(PipeJamGame, stage, null, null,Context3DRenderMode.SOFTWARE);
        mStarling = new Starling(PipeJamGame, stage);
        //mostly just an annoyance in desktop mode, so turn off...
        mStarling.simulateMultitouch = false;
        mStarling.enableErrorChecking = false;
        mStarling.start();
        
        if (REPLAY_DQID != null)
        {
            m_replayText.text = "Loading replay...";
            m_replayText.width = Constants.GameWidth;
            m_replayText.height = 30;
            m_replayText.setTextFormat(REPLAY_TEXT_FORMAT);
            mStarling.nativeOverlay.addChild(m_replayText);
        }
        
        // this event is dispatched when stage3D is set up
        mStarling.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated);
        
        stage.addEventListener(flash.events.Event.RESIZE, updateSize);
        stage.dispatchEvent(new flash.events.Event(flash.events.Event.RESIZE));
        if (ExternalInterface.available)
        {
            ExternalInterface.addCallback("loadLevelFromObjectID", loadLevelFromObjectID);
        }
        
        //initialize JS to ActionScript link
        HTTPCookies.initialize();
        
        var fullURL : String = this.loaderInfo.url;
        
        var protocolEndIndex : Int = fullURL.indexOf("//");
        var baseURLEndIndex : Int = fullURL.indexOf("/", protocolEndIndex + 2);
        NetworkConnection.baseURL = fullURL.substring(0, baseURLEndIndex);
        if (NetworkConnection.baseURL.indexOf("http") != -1)
        {
            if (PipeJam3.INSTALL_DVD == true)
            {
                NetworkConnection.productionInterop = NetworkConnection.baseURL + "/flowjam/scripts/interop.php";
            }
            else
            {
                NetworkConnection.productionInterop = NetworkConnection.baseURL + "/cgi-bin/interop.php";
            }
        }
        else if (ASSET_SUFFIX == "Turk")
        {
            NetworkConnection.productionInterop = "http://ec2-184-73-33-59.compute-1.amazonaws.com/cgi-bin/interop.php";
            NetworkConnection.baseURL = "http://ec2-184-73-33-59.compute-1.amazonaws.com/";
        }
        else if (PRODUCTION_BUILD)
        {
            NetworkConnection.productionInterop = "http://paradox.verigames.com/cgi-bin/interop.php";
            NetworkConnection.baseURL = "http://paradox.verigames.com";
        }
        else
        {
            NetworkConnection.productionInterop = "http://paradox.verigames.org/cgi-bin/interop.php";
            NetworkConnection.baseURL = "http://paradox.verigames.org";
        }
        
        if (ASSET_SUFFIX == "Turk")
        {
            MTurkAPI.getInstance();
        }
        GameFileHandler.retrieveLevelMetadata();
        
        Starling.current.nativeStage.addEventListener(flash.events.Event.FULLSCREEN, changeFullScreen);
        addEventListener(NavigationEvent.LOAD_LEVEL, onLoadLevel);
    }
    
    private function changeFullScreen(event : flash.events.Event) : Void
    //adjust sizes and stuff
    {
        
        isFullScreen = !isFullScreen;
        
        var newWidth : Int = Starling.current.nativeStage.fullScreenWidth;
        var newHeight : Int = Starling.current.nativeStage.fullScreenHeight;
        
        stage.stageWidth = newWidth;
        stage.stageHeight = newHeight;
        Starling.current.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        PipeJamGame.m_pipeJamGame.changeFullScreen(newWidth, newHeight);
    }
    
    private function onContextCreated(event : flash.events.Event) : Void
    // set framerate to 30 in software mode
    {
        
        
        if (Starling.context.driverInfo.toLowerCase().indexOf("software") != -1)
        {
            Starling.current.nativeStage.frameRate = 30;
        }
    }
    
    public function updateSize(e : flash.events.Event) : Void
    // Compute max view port size
    {
        
        var fullViewPort : Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        var DES_WIDTH : Float = Constants.GameWidth;
        var DES_HEIGHT : Float = Constants.GameHeight;
        var scaleFactor : Float = Math.min(stage.stageWidth / DES_WIDTH, stage.stageHeight / DES_HEIGHT);
        
        // Compute ideal view port
        var viewPort : Rectangle = new Rectangle();
        viewPort.width = scaleFactor * DES_WIDTH;
        viewPort.height = scaleFactor * DES_HEIGHT;
        viewPort.x = 0.5 * (stage.stageWidth - viewPort.width);
        viewPort.y = 0.5 * (stage.stageHeight - viewPort.height);
        
        // Ensure the ideal view port is not larger than the max view port (could cause a crash otherwise)
        viewPort = viewPort.intersection(fullViewPort);
        
        // Set the updated view port
        Starling.current.viewPort = viewPort;
    }
    
    public function onLoadLevel(event : NavigationEvent = null) : Void
    {
        loadLevelFromObjectID(event.info);
    }
    
    //call from JavaScript to load specific level
    public function loadLevelFromObjectID(levelID : String) : Void
    {
        GameFileHandler.loadLevelInfoFromObjectID(levelID, loadLevel);
    }
    
    private function loadLevel(result : Int, objVector : Array<Dynamic>) : Void
    {
        PipeJamGame.levelInfo = new ObjVector()[0];
        PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
    }
    
    private function onReplayQuestDataLoaded(questData : QuestData, err : String = null) : Void
    {
        trace("Found " + ((questData.actions) ? questData.actions.length : 0) + " actions");
        if (err != null)
        {
            trace("Error: " + err);
        }
        if (questData != null && questData.startData && questData.startData.details &&
            questData.startData.details.exists(VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO) &&
            questData.startData.details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO] != null &&
            questData.startData.details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO].m_id)
        {
            var levelId : String = Std.string(questData.startData.details[VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO].m_id);
            trace("Replaying levelId: " + levelId);
            loadLevelFromObjectID(levelId);
            return;
        }
        trace("Error: Couldn't find levelId for replay.");
    }
    
    public static function showReplayText(text : String) : Void
    {
        if (m_replayText == null)
        {
            return;
        }
        m_replayText.text = text;
        m_replayText.setTextFormat(REPLAY_TEXT_FORMAT);
    }
}

