package cgs.user;

import cgs.cache.ICGSCache;
import cgs.server.abtesting.IUserAbTester;
import cgs.server.data.TosData;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.ICGSServerProps;
import cgs.server.logging.ICGSServerProps.LoggingVersion;
import cgs.server.logging.ICGSServerProps.ServerType;
import cgs.server.logging.IGameServerData.SkeyHashVersion;

class CgsUserProperties extends CGSServerProps implements ICgsUserProperties {
    public var authenticateCachedStudent(get, set) : Bool;
    public var loadAbTests(get, never) : Bool;
    public var loadHomeplays(get, set) : Bool;
    public var loadExistingAbTests(get, never) : Bool;
    public var abTester(get, set) : IUserAbTester;
    public var serverCacheVersion(get, never) : Int;
    public var cacheSaveKey(get, never) : String;
    public var defaultUsername(get, set) : String;
    public var tosKey(get, set) : String;
    public var tosExempt(get, never) : Bool;
    public var languageCode(get, set) : String;
    public var tosServerVersion(get, never) : Int;
    public var lessonId(get, set) : String;

    //Indicates that homeplays should be loaded for the user.
    private var _loadUserHomeplays : Bool = false;
    
    //Indicates that ab tests should be loaded for the user.
    private var _loadAbTests : Bool;
    private var _onlyExistingAbTests : Bool;
    private var _abTester : IUserAbTester;
    
    private var _localCaching : Bool;
    
    //Tos setup variables.
    private var _userTosType : String;
    private var _userTosExempt : Bool;
    private var _locale : String;
    private var _tosServerVersion : Int;
    
    //If this value is set ab tests are assigned by this id in lieu of cid.
    private var _abTestingId : Int;
    
    private var _lessonId : String;
    
    //Indicates the type of caching to be used for the game.
    //V2 is used for NoSQL store.
    private var _serverCacheVersion : Int = 1;
    private var _serverCacheKey : String;
    
    //Indicates if students should be authenticated against cache data.
    private var _authStudentCache : Bool;
    
    // Want to be able to set the username for the copilot
    private var _defaultUsername : String;
    
    public function new(
            skey : String, skeyHashType : SkeyHashVersion, gameName : String,
            gameID : Int, versionID : Int, categoryID : Int,
            serverTag : ServerType, serverVersion : LoggingVersion = LoggingVersion.CURRENT_VERSION)
    {
        super(skey, skeyHashType, gameName, 
                gameID, versionID, categoryID, serverTag, serverVersion
        );
    }
    
    public function cloneUserProperties() : ICgsUserProperties
    {
        var result : CgsUserProperties = new CgsUserProperties(skey, skeyHashVersion, gameName, gameID, versionID, categoryID, serverTag, serverVersion);
        
        // Server props
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
        
        // User props
        result.loadHomeplays = loadHomeplays;
        result._loadAbTests = loadAbTests;
        result._onlyExistingAbTests = loadExistingAbTests;
        result.abTester = abTester;
        result._localCaching = _localCaching;
        result.tosKey = tosKey;
        result._userTosExempt = _userTosExempt;
        result.languageCode = languageCode;
        result._tosServerVersion = tosServerVersion;
        result._abTestingId = _abTestingId;
        result.lessonId = lessonId;
        result._serverCacheVersion = serverCacheVersion;
        result._serverCacheKey = cacheSaveKey;
        result.authenticateCachedStudent = authenticateCachedStudent;
        result.defaultUsername = _defaultUsername;
        
        return result;
    }
    
    private function set_authenticateCachedStudent(value : Bool) : Bool
    {
        _authStudentCache = value;
        return value;
    }
    
    private function get_authenticateCachedStudent() : Bool
    {
        return _authStudentCache;
    }
    
    /**
		 * Indicates if ab tests should be loaded for the user.
		 */
    private function get_loadAbTests() : Bool
    {
        return _loadAbTests;
    }
    
    /**
     * Indicates if homeplays should be loaded. Homeplays will only be loaded
     * for users that log in with credentials. Default value is true.
     */
    private function get_loadHomeplays() : Bool
    {
        return _loadUserHomeplays;
    }
    
    private function set_loadHomeplays(value : Bool) : Bool
    {
        _loadUserHomeplays = value;
        return value;
    }
    
    /**
		 * Indicates if users that have previous played the game should be given
		 * new ab testing parameters.
		 */
    private function get_loadExistingAbTests() : Bool
    {
        return _onlyExistingAbTests;
    }
    
    /**
		 * Get the class that handles users ab tests.
		 */
    private function get_abTester() : IUserAbTester
    {
        return _abTester;
    }
    
    private function set_abTester(value : IUserAbTester) : IUserAbTester
    {
        _abTester = value;
        return value;
    }
    
    /**
		 * Calling this enables local caching for the user. Optionally, caching
		 * of data to the server can be enabled as well.
		 *
		 * @param saveCacheToServer indicates if cached data
     * should be saved to the server as well.
		 * @param cache optionally a specific instance of a cache can be provided.
     * If no cache is provided an instance of CGSCache will be used.
		 */
    public function enableCaching(
            saveCacheToServer : Bool = true, cache : ICGSCache = null) : Void
    {
        _localCaching = true;
        this.saveCacheDataToServer = saveCacheToServer;
        this.cgsCache = cache;
    }
    
    /**
     * Calling this enables local caching for the user. Optionally, caching
		 * of data to the server can be enabled as well. This type of caching can
     * not be used in conjuction with loadServerCacheDataByCid. The server cache
     * key can be used to version save data.
     * 
     * @param saveCacheToServer indicates if cached data
     * should be saved to the server as well.
     * @param serverCacheKey key used to create set of save data. Can be used for
     * save slots, or save data versioning etc. Null values indicates default set
     * of save data.
		 * @param cache optionally a specific instance of a cache can be provided.
     * If no cache is provided an instance of CGSCache will be used.
     */
    public function enableV2Caching(
            saveCacheToServer : Bool = true,
            serverCacheKey : String = null, cache : ICGSCache = null) : Void
    {
        _serverCacheVersion = 2;
        _serverCacheKey = serverCacheKey;
        enableCaching(saveCacheToServer, cache);
    }
    
    private function get_serverCacheVersion() : Int
    {
        return _serverCacheVersion;
    }
    
    private function get_cacheSaveKey() : String
    {
        return _serverCacheKey;
    }
    
    /**
     * Set the username which should be used by the resulting user, if no other username is provided.
     */
    private function set_defaultUsername(value : String) : String
    {
        _defaultUsername = value;
        return value;
    }
    
    private function get_defaultUsername() : String
    {
        return _defaultUsername;
    }
    
    /**
		 * Calling this enables ab tests to be loaded for the user.
		 *
		 * @param loadExistingOnly this value indicates that only existing tests
     * should be loaded for the user if they have already played the game.
		 * @param testingId
		 * @param tester optionally a specific instance of the ab tester can be provided.
     * If no tester is provided and instance of UserAbTester will be created.
		 */
    public function enableAbTesting(
            loadExistingOnly : Bool = true,
            testingId : Int = -1, tester : IUserAbTester = null) : Void
    {
        _loadAbTests = true;
        _onlyExistingAbTests = loadExistingOnly;
        _abTestingId = testingId;
        _abTester = tester;
    }
    
    //
    // Tos handling.
    //
    
    public function enableTosV2(
            tosKey : String, languageCode : String = "en") : Void
    {
        this.tosKey = tosKey;
        _tosServerVersion = 2;
    }
    
    private function get_tosKey() : String
    {
        return _userTosType;
    }
    
    private function set_tosKey(value : String) : String
    {
        if (value == null)
        {
            return value;
        }
        
        var tosKey : String = value.toLowerCase();
        _userTosExempt = TosData.EXEMPT_TERMS == tosKey;
        _userTosType = tosKey;
        return value;
    }
    
    private function get_tosExempt() : Bool
    {
        return _userTosExempt;
    }
    
    private function get_languageCode() : String
    {
        return _locale;
    }
    
    private function set_languageCode(value : String) : String
    {
        _locale = value;
        return value;
    }
    
    private function get_tosServerVersion() : Int
    {
        return _tosServerVersion;
    }
    
    private function set_lessonId(id : String) : String
    {
        _lessonId = id;
        return id;
    }
    
    private function get_lessonId() : String
    {
        return _lessonId;
    }
}
