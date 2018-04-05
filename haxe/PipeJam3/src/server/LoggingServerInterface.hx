package server;

import cgs.cache.Cache;
import cgs.server.logging.CGSServer;
import cgs.server.logging.CGSServerConstants;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.GameServerData;
import cgs.server.logging.actions.ClientAction;
import flash.display.Stage;
import system.VerigameServerConstants;

class LoggingServerInterface
{
    public var cgsServer(get, never) : CGSServer;

    public static inline var SETUP_KEY_FRIENDS_AND_FAMILY_BETA : String = "SETUP_KEY_FRIENDS_AND_FAMILY_BETA";
    public static inline var SETUP_KEY_TURK : String = "SETUP_KEY_TURK";
    public static inline var CGS_VERIGAMES_PREFIX : String = "cgs_vg_";
    public static inline var CACHE_PREV_UID : String = "prev_uid";  // used to track play sessions before a player was logged in  
    
    private var m_cgsServer : CGSServer;
    private var m_props : CGSServerProps;
    public var uid : String;
    public var prevUid : String;
    public var serverInitialized : Bool = false;
    public var serverToUse : String = (PipeJam3.RELEASE_BUILD) ? CGSServerProps.PRODUCTION_SERVER : CGSServerProps.DEVELOPMENT_SERVER;
    public var saveCacheToServer : Bool = false;
    public var provideIp : Bool = true;
    public var stage : Stage;
    
    public function new(_setupKey : String, _stage : Stage = null, _forceUid : String = "", _replay : Bool = false)
    {
        stage = _stage;
        setupServer(_setupKey, _stage, _forceUid);
        if (!_replay)
        {
            m_cgsServer.initialize(m_props, saveCacheToServer, onServerInit, null, (provideIp) ? _stage : null);
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
                cid = VerigameServerConstants.VERIGAME_CATEGORY_PARADOX_FRIENDS_FAMILY_BETA_MAY_15_2015;
                saveCacheToServer = true;
                provideIp = false;
            case SETUP_KEY_TURK:
                cid = VerigameServerConstants.VERIGAME_CATEGORY_PARADOX_MTURK_JUNE_2015;
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
    
    public function addPlayerID(playerID : String) : Void
    //setupServer(PipeJam3.loggingKey, null, playerID);
    {
        
        
        if (PipeJam3.LOGGING_ON)
        {
            PipeJam3.logging = new LoggingServerInterface(PipeJam3.loggingKey, stage, CGS_VERIGAMES_PREFIX + playerID, PipeJam3.REPLAY_DQID != null);
        }
    }
    
    private function get_cgsServer() : CGSServer
    {
        return m_cgsServer;
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
        prevUid = Std.string(Cache.getSave(CACHE_PREV_UID));
        if (prevUid == null)
        {
            Cache.setSave(CACHE_PREV_UID, uid);
        }
    }
    
    public function logQuestStart(questId : Int = VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, questDetails : Dynamic = null) : Void
    {
        trace("Logging quest start, qid:" + questId);
        if (prevUid != uid)
        {
            questDetails = add2det(questDetails, CACHE_PREV_UID, prevUid);
        }
        m_cgsServer.logQuestStart(questId, questDetails, onLogQuestStart);
    }
    
    public function logQuestEnd(questId : Int = VerigameServerConstants.VERIGAME_QUEST_ID_UNDEFINED_WORLD, questDetails : Dynamic = null) : Void
    {
        trace("Logging quest end, qid:" + questId);
        if (prevUid != uid)
        {
            questDetails = add2det(questDetails, CACHE_PREV_UID, prevUid);
        }
        m_cgsServer.logQuestEnd(questId, questDetails);
    }
    
    private function onLogQuestStart(dqid : String, failed : Bool) : Void
    {
        trace("onLogQuestStart dqid:" + dqid + " failed:" + failed);
    }
    
    public function logQuestAction(actionId : Int, actionDetails : Dynamic, levelTimeMs : Float) : Void
    {
        var clientAction : ClientAction = new ClientAction(actionId, levelTimeMs);
        if (prevUid != uid)
        {
            actionDetails = add2det(actionDetails, CACHE_PREV_UID, prevUid);
        }
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
    
    private static function add2det(obj : Dynamic, key : String, value : Dynamic) : Dynamic
    {
        if (obj == null)
        {
            obj = {};
        }
        Reflect.setField(obj, key, value);
        return obj;
    }
}
