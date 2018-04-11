package cgs.server.logging;

import cgs.cache.ICGSCache;
import cgs.server.data.UserAuthData;
import cgs.server.data.IUserTosStatus;
import cgs.server.logging.ICGSServerProps.LoggingVersion;
import cgs.server.logging.IGameServerData.EncodingType;
import cgs.server.logging.IGameServerData.SkeyHashVersion;
import haxe.crypto.Md5;

/**
 * Contains server constants and data specific to a game and player session.
 */
class GameServerData implements IGameServerData
{
    public  inline static var NO_SKEY_HASH:SkeyHashVersion = SkeyHashVersion.NO_SKEY_HASH;
    public  inline static var UUID_SKEY_HASH:SkeyHashVersion = SkeyHashVersion.UUID_SKEY_HASH;
    public  inline static var DATA_SKEY_HASH:SkeyHashVersion = SkeyHashVersion.DATA_SKEY_HASH;

    public  inline static var NO_DATA_ENCODING:EncodingType = EncodingType.NO_DATA_ENCODING;
    public  inline static var BASE_64_ENCODING:EncodingType = EncodingType.BASE_64_ENCODING;

    public var experimentId(get, set) : Int;
    public var isExperimentIdValid(get, never) : Bool;
    public var serverTag(get, set) : String;
    public var userTosStatus(get, set) : IUserTosStatus;
    public var containsUserTosStatus(get, never) : Bool;
    public var nextSessionSequenceId(get, never) : Int;
    public var nextQuestSequenceId(get, never) : Int;
    public var nextAssignmentSequenceId(get, never) : Int;
    public var userLoggingHandler(get, set) : UserLoggingHandler;
    public var uidCallback(get, set) : String->Bool->Void;
    public var hasUidCallback(get, never) : Bool;
    public var hasCacheForLaterCallback(get, never) : Bool;
    public var saveCacheDataToServer(get, set) : Bool;
    public var cgsCache(get, set) : ICGSCache;
    public var hasCgsCache(get, never) : Bool;
    public var authenticateCachedStudent(get, set) : Bool;
    public var userAuthentication(never, set) : UserAuthData;
    public var externalSourceId(get, never) : Int;
    public var externalAppId(get, set) : Int;
    public var serverVersion(get, set) : Int;
    public var isVersion1(get, never) : Bool;
    public var atLeastVersion1(get, never) : Bool;
    public var isVersion2(get, never) : Bool;
    public var atLeastVersion2(get, never) : Bool;
    public var legacyMode(get, set) : Bool;
    public var timeUrl(get, set) : String;
    public var serverURL(get, set) : String;
    public var abTestingURL(get, set) : String;
    public var integrationURL(get, set) : String;
    public var useDevelopmentServer(get, set) : Bool;
    public var skeyHashVersion(get, set) : SkeyHashVersion;
    public var dataEncoding(get, set) : EncodingType;
    public var dataLevel(get, set) : Int;
    public var logPriority(get, set) : Int;
    public var skey(get, set) : String;
    public var userName(get, set) : String;
    public var isConditionIdValid(get, never) : Bool;
    public var conditionId(get, set) : Int;
    public var userPlayCount(get, set) : Int;
    public var uid(get, set) : String;
    public var isUidValid(get, never) : Bool;
    public var isSessionIdValid(get, never) : Bool;
    public var sessionId(get, set) : String;
    public var g_name(get, set) : String;
    public var gid(get, set) : Int;
    public var svid(get, never) : SkeyHashVersion;
    public var vid(get, set) : Int;
    public var cid(get, set) : Int;
    public var isEventIDValid(get, never) : Bool;
    public var eid(get, set) : Int;
    public var isTypeIDValid(get, never) : Bool;
    public var tid(get, set) : Int;
    public var isLevelIDValid(get, never) : Bool;
    public var lid(get, set) : Int;
    public var isSessionIDValid(get, never) : Bool;
    public var sid(get, set) : String;
    public var lessonId(get, set) : String;
    public var tosServerVersion(get, set) : Int;
    public var isSWFDomainValid(get, never) : Bool;
    public var swfDomain(get, set) : String;

    /**
     * To avoid mixed content errors in domain using https, we need to consistently append
     * the right http prefix to all requests
     * 
     * Set to true if we should use https
     */
    public var useHttps : Bool;
    
    //Indicates if messages should be sent in legacy mode.
    private var _legacyMode : Bool;
    
    private var _serverVersion : LoggingVersion;
    
    //Current server profile being used.
    private var _serverTag : String;
    
    //URLs used to log to the server.
    private var _serverURL : String;
    private var _abTestingURL : String;
    private var _integrationURL : String;
    
    //Set the condition id to be logged with messages.
    private var _conditionId : Int = -1;
    
    //Url to request ntp time from server.
    private var _timeUrl : String;
    
    //Indicates if the development server is being used for logging.
    private var _useDevServer : Bool;
    
    //Key used to validate logging messages on the server.
    private var _skey : String;
    
    //Indicates how the skey should be hashed for the game.
    private var _skeyHashVersion : SkeyHashVersion = SkeyHashVersion.UUID_SKEY_HASH;
    
    //Indicates the type of encoding to use for the data paramter.
    private var _encoding : EncodingType = NO_DATA_ENCODING;
    
    private var _dataLevel : Int = 0;
    
    //Optional user name that can be set. Used for some requests to the server.
    private var _userName : String = "";
    
    //CGS user id for the current player session.
    private var _uid : String = "";
    
    //Game id must be defined on the server.
    private var _gid : Int;
    
    //Name of the game as defined on the server.
    private var _g_name : String;
    
    //Version id for the game.
    private var _vid : Int;
    
    //Category id for the game. Must be defined on the server for logging to work.
    private var _cid : Int;
    
    //Event id for the game. Parameter is optional for most messages. Will be
    //sent as 0 for required messages if not set.
    private var _eid : Int = -1;
    
    //Type id for the game. This is required for action messages. Parameter is
    //optional for most messages. Will be sent as 0 for required messages if not set.
    private var _tid : Int = -1;
    
    //Current level id. This is required for action messages. Parameter is
    //optional for most messages. Will be sent as 0 for required messages if not set.
    private var _lid : Int = -1;
    
    private var _playCount : Int;
    
    //Parameter is optional for all messages.
    private var _sessionId : String;
    
    //Sequence ids.
    private var _sessionSequenceId : Int;
    private var _questSequenceId : Int;
    private var _assignmentSequenceId : Int;
    
    private var _userAuth : UserAuthData;
    
    //Indicates the external app from which the user originated.
    private var _extAppId : Int;
    private var _swfDomain : String;
    private var _uidCallback : Dynamic;
    
    private var _loggingHandler : UserLoggingHandler;
    
    // Cache action for later callback. When defined, the CGSServer instance will
    // utilize the callback to determine whether a action should be cached or sent
    // at the time it is attempting to send the action.
    private var _cacheForLaterCallback : Dynamic;
    
    // Cache object to be used by server, only available for CgsServerApi, not for CGSServer
    private var _saveCacheDataToServer : Bool;
    
    private var _userTosStatus : IUserTosStatus;
    private var _tosServerVersion : Int;
    
    private var _cgsCache : ICGSCache;
    
    //Optional id that can be set to assign ab tests to users.
    private var _experimentId : Int;
    
    private var _lessonId : String;
    
    private var _logPriority : Int;
    
    private var _authStudentCache : Bool;
    
    public function new(useHttps : Bool)
    {
        _sessionSequenceId = 0;
        _questSequenceId = 0;
        _assignmentSequenceId = 0;
        this.useHttps = useHttps;
    }
    
    private function set_experimentId(value : Int) : Int
    {
        _experimentId = value;
        return value;
    }
    
    private function get_experimentId() : Int
    {
        return _experimentId;
    }
    
    private function get_isExperimentIdValid() : Bool
    {
        return _experimentId >= 0;
    }
    
    //
    // Server version handling.
    //
    
    private function set_serverTag(value : String) : String
    {
        _serverTag = value;
        return value;
    }
    
    private function get_serverTag() : String
    {
        return _serverTag;
    }
    
    //
    // Tos Data handling.
    //
    
    private function set_userTosStatus(value : IUserTosStatus) : IUserTosStatus
    {
        _userTosStatus = value;
        return value;
    }
    
    private function get_userTosStatus() : IUserTosStatus
    {
        return _userTosStatus;
    }
    
    private function get_containsUserTosStatus() : Bool
    {
        return _userTosStatus != null;
    }
    
    //
    // Sequence id handling.
    //
    
    //Session sequence id starts at zero.
    private function get_nextSessionSequenceId() : Int
    {
        return ++_sessionSequenceId;
    }
    
    //Quest sequence id starts at 1 for the first quest.
    private function get_nextQuestSequenceId() : Int
    {
        return ++_questSequenceId;
    }
    
    private function get_nextAssignmentSequenceId() : Int
    {
        return ++_assignmentSequenceId;
    }
    
    private function set_userLoggingHandler(value : UserLoggingHandler) : UserLoggingHandler
    {
        _loggingHandler = value;
        return value;
    }
    
    private function get_userLoggingHandler() : UserLoggingHandler
    {
        return _loggingHandler;
    }
    
    private function set_uidCallback(value : String->Bool->Void) : String->Bool->Void
    {
        _uidCallback = value;
        return value;
    }
    
    private function get_uidCallback() : String->Bool->Void
    {
        return _uidCallback;
    }
    
    private function get_hasUidCallback() : Bool
    {
        return _uidCallback != null;
    }
    
    private function get_hasCacheForLaterCallback() : Bool
    {
        return _cacheForLaterCallback != null;
    }
    
    //
    // CGS Cache handling.
    //
    
    private function set_saveCacheDataToServer(value : Bool) : Bool
    {
        _saveCacheDataToServer = value;
        return value;
    }
    
    private function get_saveCacheDataToServer() : Bool
    {
        return _saveCacheDataToServer;
    }
    
    private function set_cgsCache(value : ICGSCache) : ICGSCache
    {
        _cgsCache = value;
        return value;
    }
    
    private function get_cgsCache() : ICGSCache
    {
        return _cgsCache;
    }
    
    private function get_hasCgsCache() : Bool
    {
        return _cgsCache != null;
    }
    
    //
    // Cached authentication.
    //
    
    private function set_authenticateCachedStudent(value : Bool) : Bool
    {
        _authStudentCache = value;
        return value;
    }
    
    private function get_authenticateCachedStudent() : Bool
    {
        return _authStudentCache;
    }
    
    //
    // External id handling.
    //
    
    private function set_userAuthentication(value : UserAuthData) : UserAuthData
    {
        _userAuth = value;
        _uid = (_userAuth == null) ? "" : _userAuth.uid;
        return value;
    }
    
    private function get_externalSourceId() : Int
    {
        return (_userAuth == null) ? 0 : _userAuth.externalSourceId;
    }
    
    private function set_externalAppId(value : Int) : Int
    {
        _extAppId = value;
        return value;
    }
    
    private function get_externalAppId() : Int
    {
        return _extAppId;
    }
    
    //
    // Server url handling.
    //
    
    private function set_serverVersion(value : LoggingVersion) : LoggingVersion
    {
        _serverVersion = value;
        return value;
    }
    
    private function get_serverVersion() : LoggingVersion
    {
        return _serverVersion;
    }
    
    private function get_isVersion1() : Bool
    {
        return _serverVersion == ICGSServerProps.LoggingVersion.VERSION1;
    }
    
    private function get_atLeastVersion1() : Bool
    {
        return _serverVersion >= ICGSServerProps.LoggingVersion.VERSION1;
    }
    
    private function get_isVersion2() : Bool
    {
        return _serverVersion == ICGSServerProps.LoggingVersion.VERSION2;
    }
    
    private function get_atLeastVersion2() : Bool
    {
        return _serverVersion >= ICGSServerProps.LoggingVersion.VERSION2;
    }
    
    private function get_legacyMode() : Bool
    {
        return _legacyMode;
    }
    
    private function set_legacyMode(value : Bool) : Bool
    {
        _legacyMode = value;
        return value;
    }
    
    private function set_timeUrl(value : String) : String
    {
        _timeUrl = value;
        return value;
    }
    
    private function get_timeUrl() : String
    {
        return (_timeUrl != null) ? _timeUrl : CGSServerConstants.GetTimeUrl(_serverTag, this.useHttps, _serverVersion);
    }
    
    private function set_serverURL(value : String) : String
    {
        _serverURL = value;
        return value;
    }
    
    private function get_serverURL() : String
    {
        return _serverURL;
    }
    
    private function set_abTestingURL(value : String) : String
    {
        _abTestingURL = value;
        return value;
    }
    
    private function get_abTestingURL() : String
    {
        return _abTestingURL;
    }
    
    private function get_integrationURL() : String
    {
        return _integrationURL;
    }
    
    private function set_integrationURL(value : String) : String
    {
        _integrationURL = value;
        return value;
    }
    
    private function set_useDevelopmentServer(value : Bool) : Bool
    {
        _useDevServer = value;
        return value;
    }
    
    private function get_useDevelopmentServer() : Bool
    {
        return _useDevServer;
    }
    
    private function set_skeyHashVersion(value : SkeyHashVersion) : SkeyHashVersion
    {
        _skeyHashVersion = value;
        return value;
    }
    
    /**
     * Indicates how the skey should be hashed and included in the URL.
     */
    private function get_skeyHashVersion() : SkeyHashVersion
    {
        return _skeyHashVersion;
    }
    
    private function get_dataEncoding() : EncodingType
    {
        return _encoding;
    }
    
    private function set_dataEncoding(value : EncodingType) : EncodingType
    {
        _encoding = value;
        return value;
    }
    
    private function get_dataLevel() : Int
    {
        return _dataLevel;
    }
    
    private function set_dataLevel(level : Int) : Int
    {
        _dataLevel = level;
        return level;
    }
    
    private function set_logPriority(value : Int) : Int
    {
        _logPriority = value;
        return value;
    }
    
    private function get_logPriority() : Int
    {
        return _logPriority;
    }
    
    //
    // Skey handling.
    //
    
    private function set_skey(value : String) : String
    {
        _skey = value;
        return value;
    }
    
    private function get_skey() : String
    {
        return _skey;
    }
    
    /**
     * Get the skey for the associated URL / uuid.
     *
     * @param value the string value which should be used to create the hashed skey.
     * @return a hashed version of the server skey.
     */
    public function createSkeyHash(value : String) : String
    {
		
        var salt : String = value + _skey;
		
		return Md5.encode(salt);
    }
    
    /**
     * Set the current user name for the game session.
     * This is an optional parameter.
     */
    private function set_userName(value : String) : String
    {
        _userName = value;
        return value;
    }
    
    /**
     * Get the user name for the current game session.
     */
    private function get_userName() : String
    {
        return _userName;
    }
    
    private function get_isConditionIdValid() : Bool
    {
        return _conditionId >= 0;
    }
    
    private function set_conditionId(cdid : Int) : Int
    {
        _conditionId = cdid;
        return cdid;
    }
    
    private function get_conditionId() : Int
    {
        return _conditionId;
    }
    
    /**
     * Get the number of times a user has played game. This value
     * is based on the number of pageloads logged for the user.
     */
    private function get_userPlayCount() : Int
    {
        return _playCount;
    }
    
    /**
     * Set the player count for the user.
     */
    private function set_userPlayCount(value : Int) : Int
    {
        _playCount = value;
        return value;
    }
    
    /**
     * Set the current uuid for the game session.
     * This must be set for the logging to function properly.
     */
    private function set_uid(value : String) : String
    {
        _uid = value;
        return value;
    }
    
    /**
     * Get the UUID for the current game session.
     */
    private function get_uid() : String
    {
        return (_userAuth == null) ? _uid : _userAuth.uid;
    }
    
    private function get_isUidValid() : Bool
    {
        return uid.length > 0;
    }
    
    private function get_isSessionIdValid() : Bool
    {
        return _sessionId != null;
    }
    
    private function get_sessionId() : String
    {
        return _sessionId;
    }
    
    private function set_sessionId(value : String) : String
    {
        _sessionId = value;
        return value;
    }
    
    /**
     * Set the name for the game as defined by the server.
     * This must be set for the logging to function properly.
     */
    private function set_g_name(value : String) : String
    {
        _g_name = value;
        return value;
    }
    
    /**
     * Get the server defined name of the game.
     */
    private function get_g_name() : String
    {
        return _g_name;
    }
    
    /**
     * Set the game id. This must be set for the logging to function properly.
     */
    private function set_gid(value : Int) : Int
    {
        _gid = value;
        return value;
    }
    
    /**
     * Get the game id.
     */
    private function get_gid() : Int
    {
        return _gid;
    }
    
    /**
     * Get the version server vid for the game.
     */
    private function get_svid() : SkeyHashVersion
    {
        return _skeyHashVersion;
    }
    
    /**
     * Set the version id for the game.
     */
    private function set_vid(value : Int) : Int
    {
        _vid = value;
        return value;
    }
    
    /**
     * Get the version id for the game.
     */
    private function get_vid() : Int
    {
        return _vid;
    }
    
    /**
     * Set the category id for the game.
     */
    private function set_cid(value : Int) : Int
    {
        _cid = value;
        return value;
    }
    
    /**
     * Get the category id for the game.
     */
    private function get_cid() : Int
    {
        return _cid;
    }
    
    /**
     * Indicates if the tid has been explicitly set.
     */
    private function get_isEventIDValid() : Bool
    {
        return _eid >= 0;
    }
    
    /**
     * Set the event id for the game.
     */
    private function set_eid(value : Int) : Int
    {
        _eid = value;
        return value;
    }
    
    /**
     * Get the event id for the game.
     */
    private function get_eid() : Int
    {
        return _eid;
    }
    
    /**
     * Indicates if the tid has been explicitly set.
     */
    private function get_isTypeIDValid() : Bool
    {
        return _tid >= 0;
    }
    
    /**
     * Set the type id for the game.
     */
    private function set_tid(value : Int) : Int
    {
        _tid = value;
        return value;
    }
    
    /**
     * Get the type id for the game.
     */
    private function get_tid() : Int
    {
        return _tid;
    }
    
    /**
     * Indicates if the lid has been explicitly set.
     */
    private function get_isLevelIDValid() : Bool
    {
        return _lid >= 0;
    }
    
    /**
     * Set the current level id for the game.
     */
    private function set_lid(value : Int) : Int
    {
        _lid = value;
        return value;
    }
    
    /**
     * Get the current level id for the game.
     */
    private function get_lid() : Int
    {
        return _lid;
    }
    
    /**
     * Indicates if the session id has been explicitly set.
     */
    private function get_isSessionIDValid() : Bool
    {
        return _sessionId != null;
    }
    
    /**
     * Set the session id for the game.
     */
    private function set_sid(value : String) : String
    {
        _sessionId = value;
        return value;
    }
    
    /**
     * Get the current level id for the game.
     */
    private function get_sid() : String
    {
        return _sessionId;
    }
    
    //
    // Co-pilot id handling.
    //
    
    private function set_lessonId(id : String) : String
    {
        _lessonId = id;
        return id;
    }
    
    private function get_lessonId() : String
    {
        return _lessonId;
    }
    
    //
    // Tos handling.
    //
    
    private function get_tosServerVersion() : Int
    {
        return _tosServerVersion;
    }
    
    private function set_tosServerVersion(value : Int) : Int
    {
        _tosServerVersion = value;
        return value;
    }
    
    //
    // SWF domain handling.
    //
    
    private function get_isSWFDomainValid() : Bool
    {
        return _swfDomain != null;
    }
    
    private function get_swfDomain() : String
    {
        return _swfDomain;
    }
    
    private function set_swfDomain(value : String) : String
    {
        _swfDomain = value;
        return value;
    }
}
