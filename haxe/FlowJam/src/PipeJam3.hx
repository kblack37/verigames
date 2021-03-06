//import com.spikything.utils.MouseWheelTrap;
import cgs.server.logging.data.QuestData;
import events.NavigationEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.text.TextField;
import flash.text.TextFormat;
import networking.GameFileHandler;
import networking.NetworkConnection;
import openfl.display.Sprite;
import openfl.events.Event;
import server.LoggingServerInterface;
import starling.core.Starling;
import system.VerigameServerConstants;
//import net.hires.debug.Stats;

//import mx.core.FlexGlobals;
//import spark.components.Application;

class PipeJam3 extends Sprite
{
    public static var GAME_ID : Int = 1;
    
    private var m_starling : Starling;
    
    /** Set to true if a build for the server*/
    public static var RELEASE_BUILD : Bool = false;
    public static var LOGGING_ON : Bool = false;
    public static var LOCAL_DEPLOYMENT : Bool = true;
    public static var TUTORIAL_DEMO : Bool = false;
    public static var USE_LOCAL_PROXY : Bool = false;
    public static var SHOW_PERFORMANCE_STATS : Bool = false;
	
    
    public static var PRODUCTION : Bool = false;
    public static var INSTALL_DVD : Bool = false;
    public static var REPLAY_DQID : String;  // = "dqid_5252fd7aa741e8.90134465";  
    private static var REPLAY_TEXT_FORMAT : TextFormat = new TextFormat("_sans", 6, 0xFFFF00);
    
    public static var DISABLE_FILTERS : Bool = true;
    
    public static var logging : LoggingServerInterface;
    
    private var hasBeenAddedToStage : Bool = false;
    private var isFullScreen : Bool = false;
    
    //We store 5 pieces of info, the level record ID, the three file IDs, and a dictionary of widget size changes since last save (or load).
    //This is for restoring game play between sessions.
    public static var m_savedCurrentLevel : SharedObject;
    
    //used to know if this is the inital launch, and the Play button should load a tutorial level or the level dialog instead
    public static var initialLevelDisplay : Bool = true;
    public static var pipeJam3 : PipeJam3;
    
    private static var m_replayText : TextField = new TextField();
    
    public function new()
    {
        super();
        pipeJam3 = this;
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        
        //if (REPLAY_DQID != null || LoggingServerInterface.LOGGING_ON)
        //{
            //logging = new LoggingServerInterface(LoggingServerInterface.SETUP_KEY_FRIENDS_AND_FAMILY_BETA, stage, "", REPLAY_DQID != null);
            //if (REPLAY_DQID != null)
            //{
                ////ReplayController.getInstance().loadQuestData(REPLAY_DQID, logging.cgsServer, onReplayQuestDataLoaded);
            //}
        //}
    }
    
    public function onAddedToStage(evt : Event) : Void
    {
        if (hasBeenAddedToStage == false)
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            initialize();
        }
    }
    
    public function initialize(result : Int = 0, e : Event = null) : Void
    {
        //MouseWheelTrap.setup(stage);
		m_starling = Starling.current;
        
        //set up the main controller
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        
        Starling.multitouchEnabled = false;  // useful on mobile devices  
        //Starling.handleLostContext = true;  // deactivate on mobile devices (to save memory)  
        
        //if (SHOW_PERFORMANCE_STATS)
        //{
            //var stats : Stats = new Stats();
            //stage.addChild(stats);
        //}
		
		m_starling = new Starling(PipeJamGame, this.stage);
        
        //mostly just an annoyance in desktop mode, so turn off...
        m_starling.simulateMultitouch = false;
        m_starling.enableErrorChecking = false;
        m_starling.start();
        
        if (REPLAY_DQID != null)
        {
            m_replayText.text = "Loading replay...";
            m_replayText.width = Constants.GameWidth;
            m_replayText.height = 30;
            m_replayText.setTextFormat(REPLAY_TEXT_FORMAT);
            m_starling.nativeOverlay.addChild(m_replayText);
        }
        
        // this event is dispatched when stage3D is set up
        m_starling.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated);
        
        stage.addEventListener(Event.RESIZE, updateSize);
        stage.dispatchEvent(new Event(Event.RESIZE));
        if (ExternalInterface.available)
        {
            ExternalInterface.addCallback("loadLevelFromObjectID", loadLevelFromObjectID);
        }
        
        //var fullURL : String = this.loaderInfo.url;
        //var protocolEndIndex : Int = fullURL.indexOf("//");
        //var baseURLEndIndex : Int = fullURL.indexOf("/", protocolEndIndex + 2);
        //NetworkConnection.baseURL = fullURL.substring(0, baseURLEndIndex);
        //if (NetworkConnection.baseURL.indexOf("http") != -1)
        //{
            //if (PipeJam3.PRODUCTION == true)
            //{
                //NetworkConnection.productionInterop = NetworkConnection.baseURL + "/game/interop.php";
            //}
            //else if (PipeJam3.INSTALL_DVD == true)
            //{
                //NetworkConnection.productionInterop = NetworkConnection.baseURL + "/flowjam/scripts/interop.php";
            //}
        //}
        //else
        //{
            //NetworkConnection.productionInterop = "http://flowjam.verigames.com/game/interop.php";
            //NetworkConnection.baseURL = "http://flowjam.verigames.com";
        //}
        //initialize stuff
        new NetworkConnection();
        m_savedCurrentLevel = SharedObject.getLocal("FlowJamData");
        GameFileHandler.retrieveLevels();
        
        Starling.current.nativeStage.addEventListener(flash.events.Event.FULLSCREEN, changeFullScreen);
    }
    
    private function changeFullScreen(event : flash.events.Event) : Void
    //adjust sizes and stuff
    {
        
        isFullScreen = !isFullScreen;
        
        var newWidth : Int = Starling.current.nativeStage.fullScreenWidth;
        var newHeight : Int = Starling.current.nativeStage.fullScreenHeight;
        
        stage.width = newWidth;
        stage.height = newHeight;
        Starling.current.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        PipeJamGame.m_pipeJamGame.changeFullScreen(newWidth, newHeight);
    }
    
    private function onContextCreated(event : flash.events.Event) : Void
    // set framerate to 30 in software mode
    {
        
        
        if (Starling.current.context.driverInfo.toLowerCase().indexOf("software") != -1)
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
    
    //call from JavaScript to load specific level
    public function loadLevelFromObjectID(levelID : String) : Void
    {
        GameFileHandler.loadLevelInfoFromObjectID(levelID, loadLevel);
    }
    
    private function loadLevel(result : Int, objVector : Array<Dynamic>) : Void
    {
        PipeJamGame.levelInfo = Type.createInstance(objVector[0], []);
        PipeJamGame.m_pipeJamGame.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, "PipeJamGame"));
    }
    
    private function onReplayQuestDataLoaded(questData : QuestData, err : String = null) : Void
    {
        trace("Found " + (questData.actions != null ? questData.actions.length : 0) + " actions");
        if (err != null)
        {
            trace("Error: " + err);
        }
        if (questData != null && questData.startData != null && questData.startData.details != null &&
            Reflect.hasField(questData.startData.details, VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO) &&
            Reflect.hasField(Reflect.field(questData.startData.details, VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO), "m_id"))
        {
            var levelId : String = Reflect.field(Reflect.field(questData.startData.details, VerigameServerConstants.QUEST_PARAMETER_LEVEL_INFO), "m_id");
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

