package server;

import cgs.server.logging.CGSServer;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.GameServerData;
import cgs.server.logging.actions.ClientAction;
import flash.display.Stage;
import mochi.as3.MochiServices;
import system.VerigameServerConstants;

class LoggingServerInterface
{
    public var cgsServer(get, never) : CGSServer;

    /** True to log to the CGS server */
    public static var LOGGING_ON : Bool = PipeJam3.LOGGING_ON;
    
    public static inline var SETUP_KEY_FRIENDS_AND_FAMILY_BETA : String = "SETUP_KEY_FRIENDS_AND_FAMILY_BETA";
    public static inline var CGS_VERIGAMES_PREFIX : String = "cgs_vg_";
    
    private var m_cgsServer : CGSServer;
    private var m_useMochi : Bool = PipeJam3.LOGGING_ON;
    private var m_props : CGSServerProps;
    public var uid : String;
    public var serverInitialized : Bool = false;
    public var serverToUse : String = (PipeJam3.RELEASE_BUILD) ? CGSServerProps.PRODUCTION_SERVER : CGSServerProps.DEVELOPMENT_SERVER;
    public var saveCacheToServer : Bool = false;
    public var provideIp : Bool = true;
    
    public function new(_setupKey : String, _stage : Stage = null, _forceUid : String = "", _replay : Bool = false)
    {
        setupServer(_setupKey, _stage, _forceUid);
        if (!_replay)
        {
            m_cgsServer.initialize(m_props, saveCacheToServer, onServerInit, null, (provideIp) ? _stage : null);
            
            if (m_useMochi)
            {
                MochiServices.connect(VerigameServerConstants.MOCHI_GAME_ID, _stage, onMochiError);
            }
        }
    }
    
    public function setupServer(_setupKey : String, _stage : Stage = null, _forceUid : String = "") : Void
    //Initialize logging
    {
        
        m_cgsServer = new CGSServer();
        var cid : Int = VerigameServerConstants.VERIGAME_CATEGORY_SEEDLING_BETA;
        switch (_setupKey)
        {
            case SETUP_KEY_FRIENDS_AND_FAMILY_BETA:
                cid = VerigameServerConstants.VERIGAME_CATEGORY_DARPA_FRIENDS_FAMILY_BETA_JULY_1_2013;
                saveCacheToServer = true;
                provideIp = false;
        }
        
        m_props = new CGSServerProps(
                VerigameServerConstants.VERIGAME_SKEY, 
                GameServerData.NO_SKEY_HASH, 
                VerigameServerConstants.VERIGAME_GAME_NAME, 
                VerigameServerConstants.VERIGAME_GAME_ID, 
                VerigameServerConstants.VERIGAME_VERSION_GRID_WORLD_BETA, 
                cid, 
                serverToUse, 
                CGSServerProps.VERSION2);
        
        m_props.cacheUid = false;
        m_props.uidValidCallback = onUidSet;
        //m_props.loadServerCacheDataByCid = true;
        if (_forceUid.length > 0)
        {
            m_props.forceUid = _forceUid;
        }
        m_cgsServer.setup(m_props);
    }
    
    private function get_cgsServer() : CGSServer
    {
        return m_cgsServer;
    }
    
    private function onMochiError(errorCode : String) : Void
    {
        trace("MOCHI errorCode: " + errorCode);
    }
    
    private function onServerInit(failed : Bool) : Void
    {
        trace("onServerInit() failed=" + Std.string(failed));
        serverInitialized = !failed;
    }
    
    private function onUidSet(_uid : String, failed : Bool) : Void
    {
        trace("onUidSet uid:" + _uid + " failed:" + failed);
        uid = _uid;
    }
    
    public function logQuestStart(questId : Int = VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, questDetails : Dynamic = null) : Void
    {
        trace("Logging quest start, qid:" + questId);
        m_cgsServer.logQuestStart(questId, questDetails, onLogQuestStart);
    }
    
    public function logQuestEnd(questId : Int = VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, questDetails : Dynamic = null) : Void
    {
        trace("Logging quest end, qid:" + questId);
        m_cgsServer.logQuestEnd(questId, questDetails);
    }
    
    private function onLogQuestStart(dqid : String, failed : Bool) : Void
    {
        trace("onLogQuestStart dqid:" + dqid + " failed:" + failed);
    }
    
    public function logQuestAction(actionId : Int, actionDetails : Dynamic, levelTimeMs : Float) : Void
    {
        var clientAction : ClientAction = new ClientAction(actionId, levelTimeMs);
        clientAction.setDetail(actionDetails);
        trace("logQuestAction actionId:" + actionId + " details:" + obj2str(actionDetails) + " levelTimeMs:" + levelTimeMs);
        m_cgsServer.logQuestAction(clientAction);
    }
    
    private static function obj2str(obj : Dynamic) : String
    {
        var str : String = "{\n";
        for (key in Reflect.fields(obj))
        {
            str = str + key + ":" + Reflect.field(obj, key) + "\n";
        }
        str = str + "}";
        return str;
    }
}
