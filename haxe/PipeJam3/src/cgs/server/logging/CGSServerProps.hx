package cgs.server.logging;

import cgs.cache.ICGSCache;
import cgs.server.abtesting.ABTesterConstants;
import cgs.server.logging.IGameServerData.SkeyHashVersion;
import cgs.server.logging.ICGSServerProps.LoggingVersion;

class CGSServerProps implements ICGSServerProps
{
    public var dataLevel(get, set) : Int;
    public var experimentId(get, set) : Int;
    public var serverVersion(get, never) : Int;
    public var pageLoadMultiplayerSequenceId(get, set) : Int;
    public var uidValidCallback(get, set) : Dynamic;
    public var forceUid(get, set) : String;
    public var cacheUid(get, set) : Bool;
    public var logPageLoad(get, set) : Bool;
    public var pageLoadDetails(get, set) : Dynamic;
    public var pageLoadCallback(get, set) : Dynamic;
    public var saveCacheDataToServer(get, set) : Bool;
    public var cgsCache(get, set) : ICGSCache;
    public var loadServerCacheDataByCid(get, set) : Bool;
    public var completeCallback(get, set) : Dynamic;
    public var skey(get, never) : String;
    public var loggingUrl(get, set) : String;
    public var isServerURLValid(get, never) : Bool;
    public var timeUrl(get, set) : String;
    public var serverURL(get, never) : String;
    public var isABTestingURLValid(get, never) : Bool;
    public var abTestingUrl(get, set) : String;
    public var isIntegrationURLValid(get, never) : Bool;
    public var integrationUrl(get, set) : String;
    public var serverTag(get, never) : String;
    public var useDevServer(get, never) : Bool;
    public var skeyHashVersion(get, never) : SkeyHashVersion;
    public var gameName(get, never) : String;
    public var gameID(get, never) : Int;
    public var versionID(get, never) : Int;
    public var categoryID(get, never) : Int;
    public var levelID(get, set) : Int;
    public var sessionID(get, set) : String;
    public var eventID(get, set) : Int;
    public var typeID(get, set) : Int;
    public var externalAppId(get, set) : Int;
    public var cacheActionForLaterCallback(get, set) : Dynamic;
    public var logPriority(get, set) : Int;

    public static inline var DELAYED_DATA_LEVEL : Int = 0;
    public static inline var IMMEDIATE_DATA_LEVEL : Int = 1;
    //
    public static inline var LOCAL_SERVER : String = "local";
    public static inline var DEVELOPMENT_SERVER : String = "dev";
    public static inline var STAGING_SERVER : String = "staging";
    public static inline var PRODUCTION_SERVER : String = "prd";
    public static inline var STUDY_SERVER : String = "school";
    public static inline var CUSTOM_SERVER : String = "custom";
    //
    ////Version of the logging code prior to sequence ids and client ts.
    public static inline var VERSION_DEV : Int = 3;
    public static inline var VERSION1 : Int = 1;
    //
   //Logging includes sequence ids and client timestamp.
    public static inline var VERSION2 : Int = 2;
    public static var CURRENT_VERSION : Int = VERSION2;
    
    /**
     * Important: If loading an application that uses a secure server, this must be set to true to avoid
     * mixed content errors.
     * 
     * This will tell various parts of the library to send https requests instead of regular http.
     * By default it is false.
     */
    public var useHttps : Bool;
    
    private var _timeUrl : String;
    
    private var _serverURL : String;
    
    private var _abTestingURL : String;
    
    private var _integrationURL : String;
    
    private var _deployServerTag : String;
    private var _useDevServer : Bool;
    
    private var _skeyHashType : SkeyHashVersion;
    
    //Properties which need to be set prior to starting logging. Should not change during a game session.
    
    //Skey must be set to enable logging to the server.
    private var _skey : String = null;
    
    private var _gameName : String = null;
    private var _gameID : Int = -1;
    private var _versionID : Int = -1;
    private var _categoryID : Int = -1;
    
    private var _experimentId : Int = -1;
    
    //TODO - How should optional properties be handled.
    private var _levelID : Int = -1;
    private var _sessionID : String = null;
    private var _eventID : Int = -1;
    private var _typeID : Int = -1;
    
    private var _extAppId : Int = 0;
    
    //Uid that gets set for the user.
    private var _forceUid : String;
    private var _cacheUid : Bool = true;
    private var _uidLoadedCallback : Dynamic;
    
    //Pageload logging.
    private var _logPageLoad : Bool = true;
    private var _pageloadMultiSeqId : Int = -1;
    private var _pageLoadDetails : Dynamic = null;
    private var _pageloadCallback : Dynamic;
    
    //Indicates if user cache data should be saved to the server.
    private var _cgsCache : ICGSCache;
    private var _loadUserData : Bool;
    
    //Indicates if the cid should be considered when loading game save state.
    private var _includeServerDataCid : Bool;
    
    //Callback called when all user data has been loaded from the server.
    private var _completeCallback : Dynamic;
    
    //Ab test handling.
    private var _loadUserAbUserConditions : Bool;
    
    //Indicates which version of the server code should be used for logging.
    //No value indicates that the original version of the logging is used.
    private var _serverVersion : Int;
    
    // Cache action for later callback. When defined, the CGSServer instance will
    // utilize the callback to determine whether a action should be cached or sent
    // at the time it is attempting to send the action.
    private var _cacheActionForLaterCallback : Dynamic;
    
    //Indicates the level of data availability. If set to 1, then data is logged
    //to the db
    private var _dataLevel : Int;
    
    //Indicates how game logs are handled on the server.
    private var _logPriority : Int = 1;
    
    /**
     * Create a server properties object with all propeties which are
     * required to be set for the server logging to function properly.
     *
     * @param skey key determined on the server which is used to validate requests to the server.
     *
     * @param skeyHashType the type of hashing to use for creating the final skey of a server request.
     * This should be set on the server.
     *
     * @param gameName name of the game as defined on the server.
     *
     * @param gameID id of the game as defined on the server.
     *
     * @param versionID current version id of the game. Can be used to seperate logging messages on the server.
     *
     * @param categoryID current category id for the game. This must be defined on the server for
     * logging to function properly.
     *
     * @param serverURL base URL to be used for logging.
     */
    public function new(skey : String, skeyHashType : SkeyHashVersion, gameName : String,
            gameID : Int, versionID : Int, categoryID : Int, serverTag : String, serverVersion : Int = LoggingVersion.CURRENT_VERSION)
    {
        _skey = skey;
        _skeyHashType = skeyHashType;
        
        _gameName = gameName;
        _gameID = gameID;
        _versionID = versionID;
        _categoryID = categoryID;
        
        _deployServerTag = serverTag;
        _serverVersion = serverVersion;
        
        this.useHttps = false;
    }
    
    public function cloneServerProps() : CGSServerProps
    {
        var result : CGSServerProps = new CGSServerProps(skey, _skeyHashType, gameName, gameID, versionID, categoryID, serverTag, serverVersion);
        
        result.timeUrl = timeUrl;
        result.loggingUrl = serverURL;
        result.abTestingUrl = abTestingUrl;
        result.integrationUrl = integrationUrl;
        result.experimentId = experimentId;
        result.levelID = levelID;
        result.sessionID = sessionID;
        result.eventID = eventID;
        result.typeID = typeID;
        result.externalAppId = externalAppId;
        result.forceUid = forceUid;
        result.cacheUid = cacheUid;
        result.uidValidCallback = uidValidCallback;
        result.logPageLoad = logPageLoad;
        result.pageLoadMultiplayerSequenceId = pageLoadMultiplayerSequenceId;
        result.pageLoadDetails = pageLoadDetails;
        result.pageLoadCallback = pageLoadCallback;
        result.cgsCache = cgsCache;
        result.saveCacheDataToServer = saveCacheDataToServer;
        result.loadServerCacheDataByCid = loadServerCacheDataByCid;
        result.completeCallback = completeCallback;
        //result._loadUserAbUserConditions = _loadUserAbUserConditions;
        result.cacheActionForLaterCallback = cacheActionForLaterCallback;
        result.dataLevel = dataLevel;
        result.logPriority = logPriority;
        result.useHttps = this.useHttps;
        
        return result;
    }
    
    /**
     * Set the level at which data is saved on the server. There are two possible levels:
     * 0 = delayed, this level logs the data to a flat file which is later processed
     * and placed in the db. The delay to get data in the db can be up to a day.
     * 1 = immediate, this level logs the data to flat file and to the db.
     * Data is logged to the flat file to handle cases where the db is down or
     * unresponsive.
     * 
     * Delayed logging should be used in cases where data is not required in the db
     * immediately. Cases that would required data in the db are, games used in
     * conjunction with the teacher portal, assessment engine, etc.
     * 
     * @param the level indicating how data should be logged on the server.
     */
    private function set_dataLevel(level : Int) : Int
    {
        _dataLevel = level;
        return level;
    }
    
    private function get_dataLevel() : Int
    {
        return _dataLevel;
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
    
    private function get_serverVersion() : Int
    {
        return _serverVersion;
    }
    
    private function set_pageLoadMultiplayerSequenceId(value : Int) : Int
    {
        _pageloadMultiSeqId = value;
        return value;
    }
    
    private function get_pageLoadMultiplayerSequenceId() : Int
    {
        return _pageloadMultiSeqId;
    }
    
    /*
    public function set loadAbTestingUserConditions(value:Boolean):void
    {
    _loadUserAbUserConditions = value;
    }

    public function get loadAbTestingUserConditions():Boolean
    {
    return _loadUserAbUserConditions;
    }*/
    
    /**
     * Set the callback function to be called when the server returns
     * a uid. This callback will also be called if the uid is set by the application.
     */
    private function set_uidValidCallback(callback : Dynamic) : Dynamic
    {
        _uidLoadedCallback = callback;
        return callback;
    }
    
    private function get_uidValidCallback() : Dynamic
    {
        return _uidLoadedCallback;
    }
    
    /**
     * Set the uid which should be used to log server information.
     */
    private function set_forceUid(value : String) : String
    {
        _forceUid = value;
        return value;
    }
    
    private function get_forceUid() : String
    {
        return _forceUid;
    }
    
    /**
     * Indicates if the logging server api should save the uid to the local flash cache.
     */
    private function set_cacheUid(value : Bool) : Bool
    {
        _cacheUid = value;
        return value;
    }
    
    private function get_cacheUid() : Bool
    {
        return _cacheUid;
    }
    
    /**
     * Indicates if a pageload should be logged when the server is initialized.
     */
    private function get_logPageLoad() : Bool
    {
        return _logPageLoad;
    }
    
    private function set_logPageLoad(b : Bool) : Bool
    {
        _logPageLoad = b;
        return b;
    }
    
    private function get_pageLoadDetails() : Dynamic
    {
        return _pageLoadDetails;
    }
    
    private function set_pageLoadDetails(details : Dynamic) : Dynamic
    {
        _pageLoadDetails = details;
        return details;
    }
    
    private function set_pageLoadCallback(callback : Dynamic) : Dynamic
    {
        _pageloadCallback = callback;
        return callback;
    }
    
    private function get_pageLoadCallback() : Dynamic
    {
        return _pageloadCallback;
    }
    
    /**
		 * Sets whether or not the CGSServer should save cache data to the server.
		 * Requires a valid cgsCache to be provided, otherwise the CGSServer will NOT save cache data to the server.
		 */
    private function set_saveCacheDataToServer(value : Bool) : Bool
    {
        _loadUserData = value;
        return value;
    }
    
    private function get_saveCacheDataToServer() : Bool
    {
        return _loadUserData;
    }
    
    /**
		 * Set the cgsCache object to be used by the CGSServer.
		 */
    private function set_cgsCache(value : ICGSCache) : ICGSCache
    {
        _cgsCache = value;
        return value;
    }
    
    private function get_cgsCache() : ICGSCache
    {
        return _cgsCache;
    }
    
    private function set_loadServerCacheDataByCid(value : Bool) : Bool
    {
        _includeServerDataCid = value;
        return value;
    }
    
    private function get_loadServerCacheDataByCid() : Bool
    {
        return _includeServerDataCid;
    }
    
    /**
     *
     */
    private function set_completeCallback(value : Dynamic) : Dynamic
    {
        _completeCallback = value;
        return value;
    }
    
    private function get_completeCallback() : Dynamic
    {
        return _completeCallback;
    }
    
    private function get_skey() : String
    {
        return _skey;
    }
    
    private function set_loggingUrl(value : String) : String
    {
        _serverURL = value;
        return value;
    }
    
    private function get_isServerURLValid() : Bool
    {
        return _serverURL != null;
    }
    
    private function get_loggingUrl() : String
    {
        var loggingUrl : String = null;
        if (isServerURLValid)
        {
            loggingUrl = _serverURL;
        }
        else
        {
            loggingUrl = CGSServerConstants.GetBaseUrl(_deployServerTag, this.useHttps, _serverVersion);
        }
        
        return loggingUrl;
    }
    
    private function get_timeUrl() : String
    {
        if (_timeUrl != null)
        {
            return _timeUrl;
        }
        else
        {
            return CGSServerConstants.GetTimeUrl(_deployServerTag, this.useHttps, _serverVersion);
        }
    }
    
    private function set_timeUrl(url : String) : String
    {
        _timeUrl = url;
        return url;
    }
    
    private function get_serverURL() : String
    {
        return loggingUrl;
    }
    
    private function get_isABTestingURLValid() : Bool
    {
        return _abTestingURL != null;
    }
    
    private function set_abTestingUrl(value : String) : String
    {
        _abTestingURL = value;
        return value;
    }
    
    private function get_abTestingUrl() : String
    {
        if (isABTestingURLValid)
        {
            return _abTestingURL;
        }
        else
        {
            return ABTesterConstants.GetAbTestingUrl(_deployServerTag, this.useHttps, _serverVersion);
        }
    }
    
    private function get_isIntegrationURLValid() : Bool
    {
        return _integrationURL != null;
    }
    
    private function set_integrationUrl(value : String) : String
    {
        _integrationURL = value;
        return value;
    }
    
    private function get_integrationUrl() : String
    {
        if (isIntegrationURLValid)
        {
            return _integrationURL;
        }
        else
        {
            return CGSServerConstants.GetIntegrationUrl(_deployServerTag, this.useHttps, _serverVersion);
        }
    }
    
    private function get_serverTag() : String
    {
        return _deployServerTag;
    }
    
    private function get_useDevServer() : Bool
    {
        return _deployServerTag == ICGSServerProps.ServerType.DEVELOPMENT_SERVER;
    }
    
    private function get_skeyHashVersion() : SkeyHashVersion
    {
        return _skeyHashType;
    }
    
    private function get_gameName() : String
    {
        return _gameName;
    }
    
    private function get_gameID() : Int
    {
        return _gameID;
    }
    
    private function get_versionID() : Int
    {
        return _versionID;
    }
    
    private function get_categoryID() : Int
    {
        return _categoryID;
    }
    
    //
    // Optional server properties.
    //
    
    private function set_levelID(value : Int) : Int
    {
        _levelID = value;
        return value;
    }
    
    private function get_levelID() : Int
    {
        return _levelID;
    }
    
    private function set_sessionID(value : String) : String
    {
        _sessionID = value;
        return value;
    }
    
    private function get_sessionID() : String
    {
        return _sessionID;
    }
    
    private function set_eventID(value : Int) : Int
    {
        _eventID = value;
        return value;
    }
    
    private function get_eventID() : Int
    {
        return _eventID;
    }
    
    private function set_typeID(value : Int) : Int
    {
        _typeID = value;
        return value;
    }
    
    private function get_typeID() : Int
    {
        return _typeID;
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
    
    /**
		 * Set the callback function to be called when the server attempts to send an action.
		 * This callback allows the game to decide if the action should be A. sent or B. cached until
		 * a later time. This callback has the following definition:
		 * function():Boolean
		 *    -return true to cache the action until a later time
		 *    -return false to send the action now
		 */
    private function set_cacheActionForLaterCallback(callback : Dynamic) : Dynamic
    {
        _cacheActionForLaterCallback = callback;
        return callback;
    }
    
    private function get_cacheActionForLaterCallback() : Dynamic
    {
        return _cacheActionForLaterCallback;
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
}
