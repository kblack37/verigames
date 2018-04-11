package cgs.server.logging;

import cgs.CgsApi;
import cgs.cache.CGSCache;
import cgs.cache.ICGSCache;
import cgs.server.abtesting.IABTestingServer;
import cgs.server.data.GroupData;
import cgs.server.data.TosData;
import cgs.server.data.TosItemData;
import cgs.server.data.UserAuthData;
import cgs.server.data.UserData;
import cgs.server.data.UserDataManager;
import cgs.server.data.IUserTosStatus;
import cgs.server.logging.IGameServerData.SkeyHashVersion;
import cgs.server.logging.actions.DefaultActionBufferHandler;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.actions.UserAction;
import cgs.server.logging.messages.CreateQuestRequest;
import cgs.server.logging.messages.Message;
import cgs.server.logging.messages.UserFeedbackMessage;
import cgs.server.logging.quests.QuestLogger;
import cgs.server.logging.requests.CallbackRequest;
import cgs.server.logging.requests.DQIDRequest;
import cgs.server.logging.requests.GameDataRequest;
import cgs.server.logging.requests.IServerRequest;
import cgs.server.logging.requests.QuestDataRequest;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.logging.requests.ServerRequest;
import cgs.server.logging.requests.UUIDRequest;
import cgs.server.requests.IUrlRequest;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.requests.PageloadRequest;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.CgsUserResponse;
import cgs.server.responses.DqidResponseStatus;
import cgs.server.responses.GameUserDataResponseStatus;
import cgs.server.responses.HomeplayResponse;
import cgs.server.responses.ResponseStatus;
import cgs.server.responses.TosResponseStatus;
import cgs.server.responses.UidResponseStatus;
import cgs.server.utils.INtpTime;
import cgs.server.utils.RequestCache;
import cgs.server.logging.requests.ServerRequest;
import cgs.user.ICgsUserProperties;
import cgs.utils.Error;
import cgs.user.ICgsUser;
import cgs.utils.Guid;
import haxe.Json;
import haxe.ds.StringMap;
import openfl.display.Stage;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLVariables;

/**
 * Implementation of API to log and request data from the CGS logging server.
 * Call init() to initialize the server with it starting properties
 * @see CGSServerProps. Once this is called the user id should
 * be requested/set before any requests are made to the server.
 */
class CgsServerApi implements ICGSLoggingServer implements IABTestingServer implements ICgsServerApi
{
    public var isProductionRelease(get, never) : Bool;
    public var urlRequestHandler(get, never) : IUrlRequestHandler;
    public var sessionRequestDependency(get, never) : RequestDependency;
    public var uidRequestDependency(get, never) : RequestDependency;
    public var userAuthData(get, never) : UserAuthData;
    public var userLoggedIn(get, never) : Bool;
    public var userDataManager(get, never) : UserDataManager;
    public var uid(get, never) : String;
    public var isUidValid(get, never) : Bool;
    public var username(get, never) : String;
    public var sessionId(get, set) : String;
    public var userPlayCount(get, never) : Int;
    public var userPreviousPlayCount(get, never) : Int;
    public var logPriorityChangeCallback(never, set) : Dynamic;
    public var requireTermsOfService(never, set) : Bool;
    public var termsServiceAccepted(never, set) : Bool;
    private var userLoggingDisabled(get, never) : Bool;
    public var actionBufferHandlerClass(never, set) : Class<Dynamic>;
    private var gameServerData(get, never) : IGameServerData;
    private var userHandler(get, never) : UserLoggingHandler;
    public var userLoggingHandler(get, never) : UserLoggingHandler;
    public var conditionId(get, set) : Int;
    public var externalAppId(never, set) : Int;
    public var serverData(get, never) : IGameServerData;
    public var skey(never, set) : String;
    public var skeyHashVersion(never, set) : SkeyHashVersion;
    public var gameName(never, set) : String;
    public var gameID(never, set) : Int;
    public var questGameID(never, set) : Int;
    public var versionID(never, set) : Int;
    public var categoryID(never, set) : Int;
    public var serverURL(never, set) : String;
    public var useDevelopmentServer(never, set) : Bool;
    public var abTestingURL(never, set) : String;
    public var legacyMode(never, set) : Bool;
    public var message(get, never) : Message;
    public var serverTime(get, never) : INtpTime;
    public var ntpTime(never, set) : INtpTime;
    private var localCache(get, never) : CGSCache;
    private var userCache(get, never) : ICGSCache;
    public var tosResponseExists(get, never) : Bool;
    public var lessonId(never, set) : String;
    public var userTosStatus(get, never) : IUserTosStatus;
    public var containsUserTosStatus(get, never) : Bool;
    public var userData(get, never) : UserData;
    public var hasPendingLogs(get, never) : Bool;

    public static inline var DEFAULT_DATA_KEY : String = "default";
    
    public static inline var LOG_ALL_DATA : Int = 1;
    public static inline var LOG_PRIORITY_ACTIONS : Int = 2;
    public static inline var LOG_NO_ACTIONS : Int = 4;
    
    //Should the game continue working at this point?
    public static inline var LOG_NO_DATA : Int = 6;
    public static inline var LOG_AND_SAVE_NO_DATA : Int = 7;
    
    private var _initialized : Bool;
    private var _loadingAbConditions : Bool;
    
    //Request cache used to resend requests with backoff.
    private var _requestCache : RequestCache;
    
    //This is called when the server responds with a logging priority change.
    //Function should have following signature: callback(priority:int):void.
    private var _logPriorityChangeCallback : Dynamic;
    
    //Map of log failues.
    //private var _logFailures : Dictionary<>;
    //private var _totalLogFailures : Int;
    
    //Local quest id generator. Used to handle the case where the server
    //take a while to respond and two quests are played consecutively with
    //the same qid.
    private var _localQuestID : Int = 0;
    
    //Optional parameter which is used to override game id for quest messages.
    private var _questGameID : Int = -1;
    
    //Class used to create the action buffer handler. This
    //class must implement IActionBufferHandler.
    private var _actionBufferHandlerClass : Class<Dynamic>;
    
    //private var _requestHandlerClass:Class = RequestHandler;
    
    //Handles requests to the server. Implemented as it's own class to handle
    //local unit testing.
    //private var _requestHandler:IServerRequestHandler;
    
    private var _urlRequestHandler : IUrlRequestHandler;
    
    //Local logging disable flag.
    private var _loggingDisabled : Bool = false;
    
    //Terms of service disable flag.
    private var _requireTermsService : Bool = false;
    private var _userAcceptedTOS : Bool = false;
    
    //Current server logging priority.
    private var _serverLoggingPriority : Int = LOG_ALL_DATA;
    private var _priorityMap : StringMap<Int>;
    
    //Methods which are not sent to the server if user is non-consenting.
    private var _nonConsentingMap : StringMap<Bool>;
    
    //Indicates the version of the response recieved from the server.
    private var _currentResponseVersion : Int;
    
    private var _domain : String;
    
    //Contains authentication data for a user.
    //Will be null if the user is not logged in.
    private var _userAuth : UserAuthData;
    private var _userDataManager : UserDataManager;
    
    //Contains methods to get timestamps that are in sync with server.
    //This value is set when setup or initialize is called.
    private var _serverTime : INtpTime;
    
    /**
     * This looks like a very similar to user server properties.
     * Still not sure what it's purpose is
     */
    private var _gameServerData : IGameServerData;
    
    //Contains all of the loaded terms that can be shown to a user.
    private var _tosData : TosData;
    
    //Used to cache a uid in the flash cache.
    private var _localCache : CGSCache;
    
    private var _cgsApi : CgsApi;
    
    public function new(
            requestHandler : IUrlRequestHandler,
            ntpTime : INtpTime = null, cgsApi : CgsApi = null)
    {
        _urlRequestHandler = requestHandler;
        
        _cgsApi = cgsApi;
        
        this.ntpTime = ntpTime;
        initDefaultProps();
    }
    
    private function get_isProductionRelease() : Bool
    {
        return (_cgsApi != null) ? _cgsApi.isProductionRelease : false;
    }
    
    private function get_urlRequestHandler() : IUrlRequestHandler
    {
        return _urlRequestHandler;
    }
    
    private function get_sessionRequestDependency() : RequestDependency
    {
        var logHandler : UserLoggingHandler = _gameServerData.userLoggingHandler;
        return logHandler.sessionRequestDependency;
    }
    
    private function get_uidRequestDependency() : RequestDependency
    {
        var logHandler : UserLoggingHandler = _gameServerData.userLoggingHandler;
        return logHandler.uidRequestDependency;
    }
    
    private function initDefaultProps() : Void
    {
        //_logFailures = new Dictionary();
        
        _actionBufferHandlerClass = DefaultActionBufferHandler;
        
        //_requestHandler = new _requestHandlerClass();
        setupLogPriorites();
        
        _userDataManager = new UserDataManager();
        
        _requestCache = new RequestCache(this);
        
        _tosData = new TosData();
        
        _localQuestID = 0;
    }
    
    //
    // User data handling. This is used for the teacher portal and authentication.
    //
    
    private function get_userAuthData() : UserAuthData
    {
        return _userAuth;
    }
    
    private function get_userLoggedIn() : Bool
    {
        return _userAuth != null;
    }
    
    private function get_userDataManager() : UserDataManager
    {
        return _userDataManager;
    }
    
    //Creates a mapping of logging functions and what
    //priority they are allowed to log at.
    private function setupLogPriorites() : Void
    {
        if (_priorityMap == null)
        {
            _priorityMap = new StringMap<Int>();
        }
        
        //Add all of logging and saving methods.
        _priorityMap.set(CGSServerConstants.ACTION_NO_QUEST, LOG_PRIORITY_ACTIONS);
        _priorityMap.set(CGSServerConstants.DQID_REQUEST, LOG_NO_ACTIONS);
        _priorityMap.set(CGSServerConstants.LEGACY_QUEST_START, LOG_NO_ACTIONS);
        _priorityMap.set(CGSServerConstants.LOAD_GAME_DATA, LOG_NO_DATA);
        _priorityMap.set(CGSServerConstants.LOAD_USER_GAME_DATA, LOG_NO_DATA);
        _priorityMap.set(CGSServerConstants.LOG_FAILURE, LOG_AND_SAVE_NO_DATA);
        _priorityMap.set(CGSServerConstants.PAGELOAD, LOG_NO_ACTIONS);
        _priorityMap.set(CGSServerConstants.QUEST_ACTIONS, LOG_PRIORITY_ACTIONS);
        _priorityMap.set(CGSServerConstants.SAVE_GAME_DATA, LOG_NO_DATA);
        _priorityMap.set(CGSServerConstants.QUEST_START, LOG_NO_ACTIONS);
        _priorityMap.set(CGSServerConstants.SAVE_SCORE, LOG_NO_DATA);
        _priorityMap.set(CGSServerConstants.SCORE_REQUEST, LOG_NO_DATA);
        _priorityMap.set(CGSServerConstants.USER_FEEDBACK, LOG_NO_DATA);
        _priorityMap.set(CGSServerConstants.UUID_REQUEST, LOG_AND_SAVE_NO_DATA);
        
        if (_nonConsentingMap == null)
        {
            _nonConsentingMap = new StringMap<Bool>();
        }
        
        _nonConsentingMap.set(CGSServerConstants.PAGELOAD, true);
        _nonConsentingMap.set(CGSServerConstants.QUEST_ACTIONS, true);
        _nonConsentingMap.set(CGSServerConstants.QUEST_START, true);
    }
    
    //
    // Reset and clean up singleton instance.
    //
    
    /**
     * Reset the server instance to be used for another player. This must be called
     * prior to calling initialize again.
     */
    public function reset() : Void
    {
        _initialized = false;
        
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData != null)
        {
            var cache : ICGSCache = serverData.cgsCache;
            if (cache != null)
            {
                clearCachedUid();
                cache.reset();
            }
            logoutUser();
        }
        
        _domain = "";
        initDefaultProps();
    }
    
    //
    // Properties handling.
    //
    
    private function get_uid() : String
    {
        return getCurrentGameServerData().uid;
    }
    
    private function get_isUidValid() : Bool
    {
        return getCurrentGameServerData().isUidValid;
    }
    
    private function get_username() : String
    {
        return getCurrentGameServerData().userName;
    }
    
    private function get_sessionId() : String
    {
        var serverData : IGameServerData = getCurrentGameServerData();
        return (serverData == null) ? "" : serverData.sessionId;
    }
    
    /**
     * Set the session id for the user. This should not normally be called as
     * a session id is generated on the server
     */
    private function set_sessionId(value : String) : String
    {
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData == null)
        {
            serverData.sessionId = value;
        }
        return value;
    }
    
    /**
     * Get the number of times the user has played the game based on pageloads.
     * Includes the current pageload of session.
     */
    private function get_userPlayCount() : Int
    {
        return getCurrentGameServerData().userPlayCount;
    }
    
    /**
     * Get the number of times the user has played the game based on pageloads.
     * Does not include the pageload of the current session.
     */
    private function get_userPreviousPlayCount() : Int
    {
        return getCurrentGameServerData().userPlayCount - 1;
    }
    
    private function set_logPriorityChangeCallback(value : Dynamic) : Dynamic
    {
        _logPriorityChangeCallback = value;
        return value;
    }
    
    /**
     * Disables all logging to the logging server and the ab testing engine.
     */
    public function disableLogging() : Void
    {
        _loggingDisabled = true;
    }
    
    public function enableLogging() : Void
    {
        _loggingDisabled = false;
    }
    
    /**
     * Only set this if logging should be disabled if the terms of
     * service is declined. This should be false in nearly all cases.
     */
    private function set_requireTermsOfService(value : Bool) : Bool
    {
        _requireTermsService = value;
        return value;
    }
    
    private function set_termsServiceAccepted(value : Bool) : Bool
    {
        _userAcceptedTOS = value;
        return value;
    }
    
    /**
     * Indicates if logging to the server or ab testing is enabled.
     */
    private function loggingDisabled(method : String = null) : Bool
    {
        var priorityLogDisable : Bool = false;
        /*if(method != null && _priorityMap.hasOwnProperty(method))
        {
        var priority:int = _priorityMap[method];
        priorityLogDisable = _serverLoggingPriority > priority;
        }*/
        
        //TODO - This should still save the user data to the server.
        return _loggingDisabled ||
        (_requireTermsService && !_userAcceptedTOS) || priorityLogDisable;
    }
    
    //Test if user should not log
    private function get_userLoggingDisabled() : Bool
    {
        if (_userAuth != null)
        {
            var userData : UserData = _userAuth.userData;
            if (userData.loggingType == UserData.NON_CONSENTED_LOGGING)
            {
                return true;
            }
        }
        
        return false;
    }
    
    private function isUserMethodDisabled(method : String) : Bool
    {
        if (_userAuth != null)
        {
            var userData : UserData = _userAuth.userData;
            if (userData.loggingType == UserData.NON_CONSENTED_LOGGING)
            {
                return _nonConsentingMap.exists(method);
            }
        }
        
        return false;
    }
    
    private function set_actionBufferHandlerClass(bufferClass : Class<Dynamic>) : Class<Dynamic>
    {
        _actionBufferHandlerClass = bufferClass;
        return bufferClass;
    }
    
    /*public function set serverRequestHandler(handler:IServerRequestHandler):void
    {
    _requestHandler = handler;
    }*/
    
    /**
     * Create a new server data object which can be used to log properties to the server.
     */
    public function addServerDataProps(props : CGSServerProps) : Void
    {
        var data : IGameServerData = new GameServerData(props.useHttps);
        setServerProps(props, data);
    }
    
    private function addUserDataProps(user : ICgsUser, props : ICgsUserProperties) : Void
    {
        var data : IGameServerData = new GameServerData(props.useHttps);
        setUserServerProps(user, props, data);
    }
    
    public function getCurrentGameServerData() : IGameServerData
    {
        return _gameServerData;
    }
    
    private function get_gameServerData() : IGameServerData
    {
        return _gameServerData;
    }
    
    private function get_userHandler() : UserLoggingHandler
    {
        return gameServerData.userLoggingHandler;
    }
    
    private function get_userLoggingHandler() : UserLoggingHandler
    {
        var serverData : IGameServerData = getCurrentGameServerData();
        
        if (serverData != null)
        {
            return serverData.userLoggingHandler;
        }
        
        return null;
    }
    
    /**
     * Initialize the logging server with the passed properties object.
     * A user id can be set in the passed properties and whether or not it
     * is cached can also be set. The default is to load the cached uid if the uid
     * is not set explicitly. Page load messages will also be sent to the server
     * with this call. Initialize must be called prior to making any logging requests.
     *
     * Use the setup function if setting up the server for generic requests or logging.
     * @see #setup(props:CGSServerProps):void
     *
     * @param props the server properties which define all of the properties set for making logging calls.
     * @param completeCallback function which will be called when all user data has been loaded from the server.
     * This callback will be called when the uid is valid and pageload has been called if loadUserData is false. The callback function
     * should have the following signature: (failed:Boolean):void. Note: If this parameter is included
     * it will override the completeCallback in the props parameter.
     */
    public function initializeUser(
            user : ICgsUser, props : ICgsUserProperties,
            completeCallback : Dynamic = null) : Void
    {
        if (_initialized && !isProductionRelease)
        {
            throw new Error("CgsServer must be reset prior to calling initialize again.");
        }
        
        _initialized = true;
        
        if (completeCallback != null)
        {
            props.completeCallback = completeCallback;
        }
        
        addUserDataProps(user, props);
        
        setUserDomain(null);
        
        var logHandler : UserLoggingHandler = getCurrentGameServerData().userLoggingHandler;
        logHandler.initiliazeUserData(this);
    }
    
    /**
     * Setup the CGS server class with the given properties. This
     * should be called prior to making any requests to the server.
     * Requests or logging calls that do not require a uid can be made a this point.
     * A valid uid must be set prior to logging any information specific to a user.
     * Use the initialize function if you want to log information for user.
     *
     * Use the initialize function if you are setting up the server for user logging.
     * @see #initialize(props:CGSServerProps, loadUserData:Boolean = false,
     * callback:Dynamic = null):void
     *
     * @param props initial properties to be set on the server.
		 * @param	stage
		 */
    public function setup(props : CGSServerProps, stage : Stage = null) : Void
    {
        var gameServerData : IGameServerData = new GameServerData(props.useHttps);
        setServerProps(props, gameServerData);
        
        setUserDomain(stage);
    }
    
    /**
     * Setup for using with a multiplayer logging service.
     */
    public function setupMultiplayerLogging(props : CGSServerProps) : Void
    {
        var serverData : IGameServerData = new GameServerData(props.useHttps);
        
        setServerProps(props, serverData);
        var loggingHandler : UserLoggingHandler = 
        new UserLoggingHandler(this, null, null, _actionBufferHandlerClass);
        serverData.userLoggingHandler = loggingHandler;
        serverData.sessionId = Guid.create();
        
        var requestId : Int = requestUid(null, false, props.forceUid);
        loggingHandler.uidRequestId = requestId;
    }
    
    public function setupUserProperties(user : ICgsUser, props : ICgsUserProperties) : Void
    {
        var gameServerData : IGameServerData = new GameServerData(props.useHttps);
        
        setUserServerProps(user, props, gameServerData);
    }
    
    private function setUserServerProps(
            user : ICgsUser, props : ICgsUserProperties, serverData : IGameServerData) : Void
    {
        setServerProps(props, serverData);
        
        var loggingHandler : UserLoggingHandler = 
        new UserLoggingHandler(this, user, props, _actionBufferHandlerClass);
        serverData.userLoggingHandler = loggingHandler;
    }
    
    //Set the server properties for the given game server data.
    private function setServerProps(
            props : ICGSServerProps, serverData : IGameServerData) : Void
    {
        serverData.skey = props.skey;
        serverData.g_name = props.gameName;
        serverData.gid = props.gameID;
        serverData.cid = props.categoryID;
        serverData.vid = props.versionID;
        serverData.useDevelopmentServer = props.useDevServer;
        serverData.skeyHashVersion = props.skeyHashVersion;
        serverData.externalAppId = props.externalAppId;
        
        //Set the optional properties if they are valid.
        serverData.serverURL = props.loggingUrl;
        serverData.abTestingURL = props.abTestingUrl;
        serverData.integrationURL = props.integrationUrl;
        serverData.timeUrl = props.timeUrl;
        
        serverData.serverVersion = props.serverVersion;
        
        serverData.uidCallback = props.uidValidCallback;
        
        serverData.cgsCache = props.cgsCache;
        serverData.saveCacheDataToServer = props.saveCacheDataToServer;
        
        serverData.serverTag = props.serverTag;
        
        _gameServerData = serverData;
        serverData.experimentId = props.experimentId;
        
        if (Std.is(props, ICgsUserProperties))
        {
            var userProps : ICgsUserProperties = try cast(props, ICgsUserProperties) catch(e:Dynamic) null;
            serverData.lessonId = userProps.lessonId;
            serverData.tosServerVersion = userProps.tosServerVersion;
            serverData.authenticateCachedStudent = userProps.authenticateCachedStudent;
        }
        
        serverData.dataLevel = props.dataLevel;
        
        //If the swfDomain is null, try and get the domain from the singleton.
        if (_domain != null)
        {
            serverData.swfDomain = _domain;
        }
        
        serverData.logPriority = props.logPriority;
    }
    
    /**
     * Set the condition to be logged with quests.
     */
    private function set_conditionId(value : Int) : Int
    {
        getCurrentGameServerData().conditionId = value;
        return value;
    }
    
    private function get_conditionId() : Int
    {
        return getCurrentGameServerData().conditionId;
    }
    
    private function set_externalAppId(value : Int) : Int
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.externalAppId = value;
        return value;
    }
    
    private function get_serverData() : IGameServerData
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        return gameServerData;
    }
    
    private function set_skey(value : String) : String
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.skey = value;
        return value;
    }
    
    private function set_skeyHashVersion(value : SkeyHashVersion) : SkeyHashVersion
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.skeyHashVersion = value;
        return value;
    }
    
    private function set_gameName(value : String) : String
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.g_name = value;
        return value;
    }
    
    private function set_gameID(value : Int) : Int
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.gid = value;
        return value;
    }
    
    private function set_questGameID(value : Int) : Int
    {
        _questGameID = value;
        return value;
    }
    
    private function set_versionID(value : Int) : Int
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.vid = value;
        return value;
    }
    
    private function set_categoryID(value : Int) : Int
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.cid = value;
        return value;
    }
    
    private function set_serverURL(value : String) : String
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.serverURL = value;
        return value;
    }
    
    private function set_useDevelopmentServer(value : Bool) : Bool
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.useDevelopmentServer = value;
        return value;
    }
    
    private function set_abTestingURL(value : String) : String
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.abTestingURL = value;
        return value;
    }
    
    private function set_legacyMode(value : Bool) : Bool
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        gameServerData.legacyMode = value;
        return value;
    }
    
    //
    // User domain handling.
    //
    
    /**
     * Store a reference to the domain that the SWF was loaded into.
     */
    public function setUserDomain(stage : Stage) : Void
    {
        if (stage == null)
        {
            _domain = "na";
            return;
        }
        
        var domain : String = stage.root.loaderInfo.url.split("/")[2];
        domain = (domain == null) ? "" : domain;
        if (domain.length == 0)
        {
            domain = "local";
        }
        
        _domain = domain;
        var gameServerData : IGameServerData = getCurrentGameServerData();
        if (gameServerData != null)
        {
            gameServerData.swfDomain = domain;
        }
    }
    
    /**
     * Get a server message with properties for this server already set.
     */
    public function getServerMessage() : Message
    {
        return new Message(getCurrentGameServerData(), _serverTime);
    }
    
    private function get_message() : Message
    {
        return getServerMessage();
    }
    
    //
    // Generic server request handling.
    //
    
    /**
     * Generic request should only be used for non-logging and non-abtesting requests.
     */
    public function genRequest(
            url : String, method : String, callback : Dynamic = null, data : Dynamic = null,
            params : Dynamic = null, extraData : Dynamic = null, responseClass : Class<Dynamic> = null,
            dataFormat : URLLoaderDataFormat = URLLoaderDataFormat.TEXT) : Int
    {
        var request : ServerRequest = new ServerRequest(method, callback, data, params, extraData, url, getCurrentGameServerData());
        request.urlType = ServerRequest.GENERAL_URL;
		request.dataFormat = dataFormat;
        
        return _urlRequestHandler.sendUrlRequest(request);
    }
    
    /**
     * Make a generic logging request to the CGS server. This function only needs to be used if there is not an
     * appropriate function for the desired request to the server.
     *
     * @param method the method to call on the server, @see CGSServerConstants for list of possible methods.
     *
     * @param callback function which will be called when the server responds.
     * Callback needs to have the method signature of (response:*, failed:Boolean, extraData:* = null):void.
     * The extra data parameter only needs to be included in the callback if extra data is specified in the request.
     *
     * @param responseClass class which should be created when the server responds. This class must
     * extend IServerResponse. If the reponse class is not specified, the raw data recieved from the
     * server will be returned to the callback.
     *
     * @param data Object which will be converted to a JSON formatted string. Object must contain
     * all required paramters for the server request method. The object should not contain
     * any dynamic properties which need to be sent to the server, unless it is of type object.
     * This is due to the fact that the JSON encoder used does not handle dynamic properties.
     * The skey needs to be included in the object.
     *
     * @param params URL variables which will be added to the request to the server.
     *
     * @param dataFormat the type of the data to be returned from the server. Valid values
     * are contained within URLLoaderDataFormat class.
     *
     * @param extraData arbitrary object which can be cached with the server request.
     *
     */
    public function request(
            method : String, callback : Dynamic = null, message : Message = null,
            data : Dynamic = null, params : Dynamic = null, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, dataFormat : String = "text",
            uidRequired : Bool = false) : Int
    {
        return serverRequest(method, message, data, params, ServerRequest.LOGGING_URL, 
                extraData, responseClass, ServerRequest.GET, 
                dataFormat, uidRequired, null, callback
        );
    }
    
    //Make a request which requires the user id to be valid.
    public function userRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, requestType : String = "GET",
            extraData : Dynamic = null, callback : Dynamic = null) : Int
    {
        return serverRequest(method, message, data, params, type, 
                extraData, null, requestType, URLLoaderDataFormat.TEXT, 
                true, null, callback
        );
    }
    
    public function serverRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, requestType : String = "GET",
            dataFormat : String = "text", uidRequired : Bool = false,
            responseStatus : ResponseStatus = null, callback : Dynamic = null) : Int
    {
        type = (type < 0) ? ServerRequest.LOGGING_URL : type;
        
        //TODO - Add handling for local logging and UUID not being set?
        /*if(loggingDisabled(method))
        {
        //Callback with a failed message and null return value.
        if(callback != null)
        {
        if(extraData == null)
        {
        callback(null, true);
        }
        else
        {
        callback(null, true, extraData);
        }
        }
        return -1;
        }*/
        
        var gameServerData : IGameServerData = getCurrentGameServerData();
        var request : ServerRequest = new ServerRequest(method, callback, data, params, extraData, null, gameServerData);
        
        request.message = message;
        request.urlType = type;
        request.responseStatus = responseStatus;
        request.requestType = requestType;
        request.maxFailures = 1;
        
        if (request.hasClientTimestamp)
        {
            request.addReadyHandler(handleRequestReady);
            request.addRequestDependency(_serverTime.timeRequestDependency);
        }
        if (uidRequired || request.uidRequired)
        {
            request.addReadyHandler(handleRequestReady);
            request.addRequestDependency(uidRequestDependency);
            request.uidRequired = true;
        }
        if (request.hasSessionId)
        {
            request.addReadyHandler(handleRequestReady);
            request.addRequestDependency(sessionRequestDependency);
        }
        
        return _urlRequestHandler.sendUrlRequest(request);
    }
    
    private function handleRequestReady(request : IUrlRequest) : Void
    {
        if (Std.is(request, IServerRequest))
        {
            var sRequest : IServerRequest = try cast(request, IServerRequest) catch(e:Dynamic) null;
            if (sRequest.hasClientTimestamp)
            {
                sRequest.injectClientTimestamp(0);
            }
            if (sRequest.uidRequired)
            {
                sRequest.injectUid();
            }
            if (sRequest.hasSessionId)
            {
                sRequest.injectSessionId(_gameServerData.sessionId);
            }
        }
    }
    
    private function isRequestDataReady(request : ServerRequest,
            gameServerData : IGameServerData, uidRequired : Bool) : Bool
    {
        return (_serverTime.isTimeValid || !request.hasClientTimestamp) &&
        (gameServerData.isUidValid || !uidRequired);
    }
    
    /**
     * Send a server request that already has all of it's required data set.
     * This function does not prevent the request from being sent
     * if the user should not log.
     */
    public function sendRequest(request : IServerRequest) : Int
    {
        return _urlRequestHandler.sendUrlRequest(request);
    }
    
    /**
     * @inheritDoc
     */
    public function createRequest(
            method : String, message : Message, data : Dynamic = null,
            passThroughData : Dynamic = null, type : Int = -1, requestType : String = "GET",
            callback : Dynamic = null) : IServerRequest
    {
        return createServerRequest(
                method, message, data, null, type, passThroughData, null, 
                requestType, URLLoaderDataFormat.TEXT, false, null, callback
        );
    }
    
    /**
     * @inheritDoc
     */
    public function createServerRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, requestType : String = "GET",
            dataFormat : String = "text", uidRequired : Bool = false,
            responseStatus : ResponseStatus = null, callback : Dynamic = null) : IServerRequest
    {
        var gameServerData : IGameServerData = getCurrentGameServerData();
        
        var request : ServerRequest = new ServerRequest(
        method, callback, data, params, extraData, 
        dataFormat, gameServerData);
        request.message = message;
        request.urlType = type;
        request.responseStatus = responseStatus;
        request.requestType = requestType;
        
        return request;
    }
    
    /**
     * @inheritDoc
     */
    public function createUserRequest(
            method : String, message : Message = null, data : Dynamic = null,
            params : Dynamic = null, type : Int = -1, requestType : String = "GET",
            extraData : Dynamic = null, callback : Dynamic = null) : IServerRequest
    {
        return createServerRequest(
                method, message, data, params, type, extraData, 
                null, requestType, URLLoaderDataFormat.TEXT, true, null, callback
        );
    }
    
    /**
     * @inheritDoc
     */
    public function createAbRequest(
            method : String, callback : Dynamic = null, data : Dynamic = null,
            params : Dynamic = null, extraData : Dynamic = null, responseClass : Class<Dynamic> = null,
            dataFormat : String = "TEXT", uidRequired : Bool = false) : IServerRequest
    {
        return createServerRequest(
                method, null, data, params, ServerRequest.AB_TESTING_URL, extraData, 
                responseClass, ServerRequest.GET, dataFormat, uidRequired, null, callback
        );
    }
    
    /**
     * Make a request to the intergration server. This server is used for storing data related
     * to specific players.
     */
    public function integrationRequest(
            method : String, callback : Dynamic = null, message : Message = null,
            data : Dynamic = null, params : Dynamic = null, extraData : Dynamic = null,
            responseClass : Class<Dynamic> = null, dataFormat : URLLoaderDataFormat = URLLoaderDataFormat.TEXT,
            uidRequired : Bool = false, status : ResponseStatus = null) : Void
    {
        serverRequest(
                method, message, data, params, ServerRequest.INTEGRATION_URL, 
                extraData, responseClass, ServerRequest.GET, 
                dataFormat, uidRequired, status, callback
        );
    }
    
    public function abRequest(
            method : String, callback : Dynamic = null, data : Dynamic = null,
            params : Dynamic = null, extraData : Dynamic = null, responseClass : Class<Dynamic> = null,
            dataFormat : String = "TEXT", uidRequired : Bool = false) : Void
    {
        serverRequest(
                method, null, data, params, ServerRequest.AB_TESTING_URL, 
                extraData, responseClass, ServerRequest.GET, 
                dataFormat, uidRequired, null, callback
        );
    }
    
    //
    // Server time handling.
    //
    
    public function getClientTimestamp() : Float
    {
        if (_serverTime == null)
        {
            return 0;
        }
        
        return _serverTime.clientTimeStamp;
    }
    
    public function getOffsetClientTimestamp(localTime : Float) : Float
    {
        if (_serverTime == null)
        {
            return 0;
        }
        
        return _serverTime.getOffsetClientTimeStamp(localTime);
    }
    
    private function get_serverTime() : INtpTime
    {
        return _serverTime;
    }
    
    private function set_ntpTime(value : INtpTime) : INtpTime
    {
        _serverTime = value;
        return value;
    }
    
    public function isServerTimeValid(callback : Dynamic) : Void
    {
        if (callback == null)
        {
            return;
        }
        
        _serverTime.addTimeValidCallback(callback);
    }
    
    //
    // User authentication handling.
    //
    
    /**
     * Test to see if user is already authorized with cgs servers.
     * 
     * @param callback
     */
    public function isAuthenticated(
            callback : Dynamic, saveCacheDataToServer : Bool = true) : Void
    {
        userLoggingHandler.isAuthenticated(
                isUserAuthenticated, this, callback, saveCacheDataToServer
        );
    }
    
    private function isUserAuthenticated(callback : Dynamic) : Int
    {
        return serverRequest(
                CGSServerConstants.AUTHENTICATED, null, null, null, 
                ServerRequest.INTEGRATION_URL, callback, null, ServerRequest.GET, 
                URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(serverData), handleUserAuthentication
        );
    }
    
    /**
     *
     * @param userName the registered name for the user.
     * @param password the password entered by the user.
     * @param callback function to be called when the server responds.
     * This callback is called when the user is authenticated if
     * saveCacheDataToServer is false. It is called after user data has been
     * loaded if saveCacheDataToServer is true. The function should have
     * the following signature: (status:ResponseStatus, uid:String):void
     */
    // [Deprecated]
    public function authenticateUser(
            userName : String, password : String, authKey : String = null,
            callback : Dynamic = null, saveCacheDataToServer : Bool = true) : Void
    {
        // Forward!
        authenticateUserName(userName, password, authKey, callback);
    }
    
    /**
     * Authenticate a user with the server. If this is successful it will
     * replace the previously loaded uid. This function will also log a
     * pageload for the user and request save data from the server.
     *
     * @param userName the registered name for the user.
     * @param password the password entered by the user.
     * @param callback function to be called when the server responds.
     * This callback is called when the user is authenticated if
     * saveCacheDataToServer is false. It is called after user data has been
     * loaded if saveCacheDataToServer is true. The function should have
     * the following signature: (status:ResponseStatus, uid:String):void
     */
    public function authenticateUserName(
            userName : String, password : String,
            authKey : String = null, callback : Dynamic = null) : Void
    {
        _initialized = true;
        
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        
        logHandler.authenticateUserName(
                userName, password, null, userInitAuthUser, this, callback
        );
    }
    
    //Handle user authentication.
    private function userInitAuthUser(
            userName : String, password : String, authKey : String, callback : Dynamic = null) : Int
    {
        var data : Dynamic = {
            mem_login : userName,
            mem_pcode : password
        };
        
        getCurrentGameServerData().userName = userName;
        
        return serverRequest(
                CGSServerConstants.AUTHENTICATE_USER, null, data, null, 
                ServerRequest.INTEGRATION_URL, callback, null, ServerRequest.GET, 
                URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                handleUserAuthentication
        );
    }
    
    private function handleUserAuthentication(status : CgsResponseStatus) : Void
    {
        //Create auth user data from the returned data.
        var callback : Dynamic = status.passThroughData;
        var uid : String = null;
        
        if (status.success)
        {
            var responseObj : Dynamic = status.data;
            var userData : UserData = new UserData();
            
            //Get the member data.
            var memberData : Dynamic = responseObj.member;
            if (Std.is(memberData, Array))
            {
                memberData = (try cast(memberData, Array<Dynamic>) catch(e:Dynamic) null)[0];
            }
            else
            {
                if (Reflect.hasField(memberData, "0"))
                {
                    memberData = Reflect.field(memberData, "0");
                }
            }
            
            userData.parseJsonData(memberData);
            
            _userAuth = new UserAuthData();
            _userAuth.parseJsonData(memberData);
            _userAuth.userData = userData;
            getCurrentGameServerData().userAuthentication = _userAuth;
            
            _userDataManager.addUserData(userData);
            
            uid = _userAuth.uid;
        }
        
        if (callback != null)
        {
            callback(status, uid);
        }
    }
    
    /**
     * @inheritdoc
     */
    public function registerUser(
            name : String, password : String, email : String, userCallback : Dynamic) : Void
    {
        //User is created as student.
        var data : Dynamic = 
        {
            mem_login : name,
            mem_pcode : password,
            mem_email : email,
            role_id : 3
        };
        
        serverRequest(CGSServerConstants.REGISTER_USER, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, ServerRequest.POST, 
                URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
                    handleUserRegistration(name, password, status, userCallback);
                }
        );
    }
    
    public function registerUserWithUid(name : String,
            password : String,
            email : String,
            grade : Int,
            gender : Int,
            teacherCode : String,
            userCallback : Dynamic,
            externalId : String = null,
            externalSourceId : Int = -1) : Void
    {
        //User is created as student.
        var data : Dynamic = 
        {
            mem_login : name,
            mem_pcode : password,
            mem_email : email,
            role_id : 3,
            uid : uid
        };
        
        // Add optional external source and external id, set to defaults if no valid values provided
        if (externalId != null && externalSourceId > 0)
        {
            data.ext_s_id = externalSourceId;
            data.mem_ext_id = externalId;
        }
        
        // If teacher code was set then the newly registered user should be treated as a student
        var requestMethod : String = CGSServerConstants.REGISTER_USER;
        if (teacherCode != null)
        {
            requestMethod = CGSServerConstants.REGISTER_STUDENT;
            
            data.teacher_code = teacherCode;
            
            if (grade > 0)
            {
                data.grade = grade;
            }
            
            if (gender > 0)
            {
                data.gender = gender;
            }
        }
        
        serverRequest(requestMethod, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, ServerRequest.POST, 
                URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
                    if (userCallback != null)
                    {
                        userCallback(status);
                    }
                }
        );
    }
    
    //Function to handle the registration of a user.
    private function handleUserRegistration(
            userName : String, password : String,
            status : ResponseStatus, userCallback : Dynamic) : Void
    {
        if (status.success)
        {
            //Authenticate the user.
            authenticateUser(userName, password, null, userCallback);
        }
        else
        {
            if (userCallback != null)
            {
                var userStatus : CgsUserResponse = new CgsUserResponse(null);
                userStatus.registrationResponse = status;
                userCallback(userStatus);
            }
        }
    }
    
    /**
     * @inheritDoc
     */
    public function checkUserNameAvailable(name : String, userCallback : Dynamic) : Void
    {
        var data : Dynamic = {
            mem_login : name
        };
        
        serverRequest(CGSServerConstants.CHECK_USER_NAME_AVAILABLE, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.GET, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
                    userCallback(status);
                }
        );
    }
    
    /**
     * @inheritDoc
     */
    public function checkStudentNameAvailable(name : String,
            teacherUid : String,
            teacherCode : String,
            userCallback : Dynamic) : Void
    {
        var data : Dynamic = {
            username : name
        };
        if (teacherUid != null)
        {
            data.teacher_uid = teacherUid;
        }
        
        if (teacherCode != null)
        {
            data.teacher_code = teacherCode;
        }
        
        serverRequest(CGSServerConstants.CHECK_STUDENT_NAME_AVAILABLE, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.GET, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                function(status : ResponseStatus) : Void
                {
                    userCallback(status);
                }
        );
    }
    
    /**
     * Logs out the current user by removing their authentication data.
     * A new uid should be requested from the server prior to logging more messages.
     */
    public function logoutUser() : Void
    {
        _userAuth = null;
        getCurrentGameServerData().userAuthentication = null;
    }
    
    public function requestMembersByGroupId(groupId : Int, callback : Dynamic) : Void
    {
        //Throw an error if user is not authenticated.
        if (_userAuth == null && !isProductionRelease)
        {
            throw new Error("User must be authenticated prior to getting group members.");
        }
        
        var message : Dynamic = {
            group_id : groupId,
            ext_s_id : _userAuth.externalSourceId
        };
        integrationRequest(CGSServerConstants.GET_MEMBER_BY_GROUP_ID, 
                handleMembersByGroupIdResponse, null, message, null, [groupId, callback]
        );
    }
    
    private function handleMembersByGroupIdResponse(response : CgsResponseStatus) : Void
    {
        var params : Array<Dynamic> = response.passThroughData;
        if (!response.failed)
        {
            var groupId : Int = params[0];
            var groupData : GroupData = _userDataManager.getGroupData(groupId);
            if (groupData == null)
            {
                groupData = new GroupData();
                groupData.id = groupId;
                
                _userDataManager.addGroupData(groupData);
            }
            
            //Create user data and add it to the data manager.
            var responseObj : Dynamic = response.data;
            var currUserData : UserData;
            var members : Array<Dynamic> = responseObj.members;
            var memberUids : Array<Dynamic> = [];
            for (memberObj in members)
            {
                currUserData = _userDataManager.getUserData(memberObj.uid);
                if (currUserData == null)
                {
                    currUserData = new UserData();
                    currUserData.parseJsonData(memberObj);
                    _userDataManager.addUserData(currUserData);
                }
                else
                {
                    currUserData.parseJsonData(memberObj);
                }
                
                memberUids.push(memberObj.uid);
            }
            
            groupData.userUids = memberUids;
        }
        
        var callback : Dynamic = params[1];
        if (callback != null)
        {
            callback(response);
        }
    }
    
    //
    //
    // Homeplays handling.
    //
    
    /**
		 * Get all of the active assignments that have been assigned to a user.
		 * The user must be authorized with the application prior to making this call.
		 * If the user is not authorized, the callback will be called with failed immediatly.
		 *
		 * @param callback function to be called when server responds. Function should
		 * have the following signature: callback(failed:Boolean):void
		 */
    public function retrieveUserAssignments(callback : Dynamic = null) : Void
    {
        if (_userAuth == null && callback != null)
        {
            callback(true);
        }
        
        var message : Message = getServerMessage();
        message.addProperty("uid", _userAuth.uid);
        
        integrationRequest(
                CGSServerConstants.RETRIEVE_HOMEPLAY_ASSIGNMENTS_FOR_STUDENT, 
                handleHomeplayResponse, message, null, null, 
                callback, null, URLLoaderDataFormat.TEXT, 
                true, new HomeplayResponse()
        );
    }
    
    private function handleHomeplayResponse(response : HomeplayResponse) : Void
    {
        _userDataManager.addUserHomeplayData(response.homeplays, _userAuth.uid);
        
        var callback : Dynamic = response.passThroughData;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    //
    // AB testing handling.
    //
    
    public function requestUserTestConditions(
            existing : Bool = false, callback : Dynamic = null) : Void
    {
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        logHandler.requestUserTestConditions(existing, callback);
    }
    
    /**
     * Set the user as having no conditions. If the user already has test conditions,
     * this will have no effect.
     */
    public function noUserConditions() : Void
    {
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        logHandler.noUserConditions();
    }
    
    /**
     * Log the start of ab testing.
     */
    public function logTestStart(
            testId : Int, conditionId : Int,
            detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        logHandler.logTestStart(testId, conditionId, detail, callback);
    }
    
    /**
     *
     */
    public function logTestEnd(
            testId : Int, conditionId : Int,
            detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        logHandler.logTestEnd(testId, conditionId, detail, callback);
    }
    
    /**
     * Log the start of testing on a variable.
     */
    public function logConditionVariableStart(
            testId : Int, conditionId : Int, varId : Int, resultId : Int,
            time : Float = -1, detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        logHandler.logConditionVariableStart(
                testId, conditionId, varId, resultId, time, detail, callback
        );
    }
    
    /**
     * Log the results for a single variable in a test. Use the log test end to log
     * results for test as a whole.
     *
     * @param testID the id of the test for which to log results.
     * @param conditionID the id of the condition for which to log results.
     * @param variableID the id of the condition variable for which to log results.
     * @param time an optional time parameter for the results.
     * Pass -1 if there is not a time value associated with the results.
     * @param detail optional detail information to be logged.
     */
    public function logConditionVariableResults(
            testId : Int, conditionId : Int, variableId : Int, resultId : Int,
            time : Float = -1, detail : Dynamic = null, callback : Dynamic = null) : Void
    {
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        logHandler.logConditionVariableResults(
                testId, conditionId, variableId, resultId, time, detail, callback
        );
    }
    
    //
    // User id request handling.
    //
    
    /**
     * NOT IMPLEMENTED ON SERVER.
     *
     * Request a CGS UUID from the server which maps to the passed external id. If
     * the server does not have a mapping for the external id, a new CGS UUID will be
     * created and a mapping will be created between the UUID and external id.
     *
     * @param callback
     */
    public function createUidForExternalId(callback : Dynamic, externalID : String) : Void
    {  //TODO - Implement once server side is complete.  
        
    }
    
    /**
     * NOT IMPLEMENTED ON SERVER.
     *
     * Request a CGS UUID which maps to the passed external id.
     */
    public function requestUidForExternalId(externalId : String, callback : Dynamic) : Void
    {
        var message : Message = getServerMessage();
    }
    
    /**
     * Request a CGS user if from the server. This function must be called
     * before any logging calls are made to the server. This request will not
     * work is a user is logged in. Must call logout prior to requesting a new uid.
     * If a user has been authenticated this request will fail.
     *
     * @param callback function which will be called when the UUID has been
     * loaded from the server. Callback should have
     * the signature (response:ResponseStatus):void. The callback will be called even
     * if forceName is set or the uid is retrieved from the flash cache.
     *
     * @param cacheUUID indicates if the UUID is saved to the flash cache.
     * If true the UUID will also be retrieved from the flash cache if it exists.
     * If game is going to support more than 1-player, this should be set to
     * false and saving the UUID will need to be done in game logic.
     *
     * @param forceName name which should be used for the UUID
     */
    public function requestUid(
            callback : Dynamic, cacheUUID : Bool = false,
            forceName : String = null) : Int
    {
        if (_userAuth != null)
        {
            if (callback != null)
            {
                callback(null, true);
            }
            return -1;
        }
        
        var uidSet : Bool = false;
        
        //Handle force name not being null.
        var gameServerData : IGameServerData = getCurrentGameServerData();
        if (forceName != null)
        {
            gameServerData.uid = forceName;
            if (cacheUUID)
            {
                saveUid(forceName, gameServerData.g_name);
            }
            uidSet = true;
        }
        
        //Try and get a uuid from the flash cache. If it does not exist,
        //then a uuid will be requested from the server.
        if (cacheUUID)
        {
            var uuid : String = loadUid(gameServerData.g_name);
            if (uuid != null)
            {
                gameServerData.uid = uuid;
                uidSet = true;
            }
        }
        
        //Handle callback if the uid has already been set.
        if (uidSet)
        {
            if (callback != null)
            {
                var response : UidResponseStatus = new UidResponseStatus();
                response.cacheUid = uid;
                callback(response);
            }
            
            //handlePendingUidRequiredMessages();
            return -1;
        }
        
        var uuidRequest : UUIDRequest = 
        new UUIDRequest(callback, cacheUUID, getCurrentGameServerData());
        
        var message : Message = getServerMessage();
        message.injectGameParams();
        message.injectCategoryId();
        //message.injectSKEY();
        
        //Make a generic request to load / create UUID.
        return serverRequest(
                CGSServerConstants.UUID_REQUEST, message, null, null, 
                ServerRequest.LOGGING_URL, uuidRequest, null, 
                ServerRequest.POST, URLLoaderDataFormat.TEXT, false, 
                new UidResponseStatus(), handleUidLoaded
        );
    }
    
    //Handle the UUID being loaded from the server.
    private function handleUidLoaded(response : CgsResponseStatus) : Void
    {
        var request : UUIDRequest = response.passThroughData;
        var uuid : String = "";
        var uuidFailed : Bool = response.failed;
        var gameServerData : IGameServerData = request.gameServerData;
        //Possible that the server responded but returned junk.
        try
        {
            var urlVars : URLVariables= new URLVariables(response.rawData);
            var uuidObject : Dynamic = Json.parse(urlVars.data);
            uuid = uuidObject.uid;
            gameServerData.uid = uuid;
        }
        catch (er : Dynamic)
        {
            uuidFailed = true;
        }

		var cacheUUID : Bool = request.cacheUUID;
		if (cacheUUID && !uuidFailed)
		{
			saveUid(uuid, gameServerData.g_name);
		}
		
		var callback : Dynamic = request.callback;
		if (callback != null)
		{
			callback(response);
		}
    }
    
    private function get_localCache() : CGSCache
    {
        if (_localCache == null)
        {
            _localCache = new CGSCache();
        }
        
        return _localCache;
    }
    
    private function get_userCache() : ICGSCache
    {
        var serverData : IGameServerData = getCurrentGameServerData();
        var cache : ICGSCache = serverData.cgsCache;
        if (cache == null)
        {
            cache = localCache;
        }
        
        return cache;
    }
    
    //Saves UUID to the flash cache.
    private function saveUid(uuid : String, gameName : String) : Void
    {
        // Only save the UID if we are not saving to the server
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData == null || serverData.saveCacheDataToServer)
        {
            return;
        }
        
        var cache : ICGSCache = userCache;
        cache.setSave(getUidCacheName(gameName), uuid);
    }
    
    //Load uuid from the flash cache. Will return null if no uuid exists.
    private function loadUid(gameName : String) : String
    {
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData == null)
        {
            return null;
        }
        
        var cache : ICGSCache = userCache;
        
        if (cache.saveExists("cgs_uid"))
        {
            migrateCacheName();
        }
        return cache.getSave(getUidCacheName(gameName));
    }
    
    public function containsUid() : Bool
    {
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData == null)
        {
            return false;
        }
        
        var cache : ICGSCache = userCache;
        
        if (cache.saveExists("cgs_uid"))
        {
            migrateCacheName();
        }
        return cache.saveExists(getUidCacheName(serverData.g_name));
    }
    
    /**
     * Clear uuid stored in the flash cache.
     */
    public function clearCachedUid() : Void
    {
        // Only delete the UID if we are not saving to the server
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData == null || serverData.saveCacheDataToServer)
        {
            return;
        }
        
        var cache : ICGSCache = userCache;
        cache.deleteSave(getUidCacheName(serverData.g_name));
    }
    
    //Moves the cache save to the new name.
    private function migrateCacheName() : Void
    {
        // Only migrate the UID if we are not saving to the server
        var serverData : IGameServerData = getCurrentGameServerData();
        if (serverData == null || serverData.saveCacheDataToServer)
        {
            return;
        }
        
        var cache : ICGSCache = userCache;
        var currUid : String = cache.getSave("cgs_uid");
        cache.deleteSave("cgs_uid");
        saveUid(currUid, serverData.g_name);
    }
    
    private function getUidCacheName(gameName : String) : String
    {
        var cacheName : String = "cgs_uid";
        cacheName += (gameName != null) ? "_" + gameName : "_default";
        
        return cacheName;
    }
    
    //
    // Action with no quest log handling.
    //
    
    /**
     * Log a generic game action which is not associated with a specific quest.
     */
    public function logActionNoQuest(
            action : UserAction, callback : Dynamic = null) : Void
    {
        localLogAction(action, -1, null, callback);
    }
    
    /**
		 * @param action
		 * @param multiSeqId
		 * @param callback
		 */
    public function logMultiplayerAction(
            action : UserAction, multiSeqId : Int, callback : Dynamic = null) : Void
    {
        localLogAction(action, multiSeqId, null, callback);
    }
    
    public function logServerMultiplayerAction(
            action : UserAction, multiSeqId : Int,
            multiUid : String, callback : Dynamic = null) : Void
    {
        localLogAction(action, multiSeqId, multiUid, callback);
    }
    
    private function localLogAction(
            action : UserAction, multiSeqId : Int = -1,
            multiUid : String = null, callback : Dynamic = null) : Void
    {
        userHandler.logAction(action, callback, multiSeqId, multiUid);
    }
    
    //
    // Page load handling.
    //
    
    public function logPageLoad(
            details : Dynamic = null, callback : Dynamic = null,
            multiSeqId : Int = -1) : Int
    {
        if (userLoggingDisabled)
        {
            if (callback != null)
            {
                callback(null, false);
            }
            return -1;
        }
        
        var request : PageloadRequest = new PageloadRequest(this, details, callback);
        request.makeRequests(null);
        
        return request.requestId;
    }
    
    //
    // User feedback handling.
    //
    
    /**
     * Submit user feedback to the server.
     */
    public function submitUserFeedback(
            feedback : UserFeedbackMessage, callback : Dynamic = null) : Void
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        userHandler.submitUserFeedback(feedback, callback);
    }
    
    //
    // DQID handling.
    //
    
    /**
     * Request a dqid from the server. logQuestStart can be used in lieu of this
     * function as it will request a DQID from the server and send quest start message
     * and any quest actions when the server returns a dqid.
     *
     * @param callback function which will be called when the server responds with DQID.
     * The function should have the signature: (response:DqidResponseStatus):void.
     *
     * @param localDQID a local unique quest id used to ensure the quest logging actions
     * are logged with the correct DQID returned from the server. If an id is not
     * passed one will be created.
     *
     * @return int the localDQID which is created for the dqid request. This value
     * is not needed if logQuestStart is used in lieu of logQuestStartWithDQID.
     */
    public function requestDqid(callback : Dynamic, localDqid : Int = -1) : Int
    {
        var dqidRequest : DQIDRequest = new DQIDRequest(localDqid, callback);
        
        var message : Message = getServerMessage();
        message.injectGameParams();
        message.injectSKEY();
        
        return serverRequest(
                CGSServerConstants.DQID_REQUEST, message, null, null, 
                ServerRequest.LOGGING_URL, dqidRequest, null, ServerRequest.GET, 
                URLLoaderDataFormat.TEXT, false, new DqidResponseStatus(), callback
        );
    }
    
    //
    // Quest creation.
    //
    
    /**
     * Create a quest on the server. This allows for actions to be logged
     * for the quest id that is created by the server due to this request.
     *
     * @param questName the name of the quest.
     * @param questTypeID the id for the quest type.
     * @param callback should have the signature (questID:int, failed:Boolean):void.
     * Failed will be true if the request to the server failed for any reason,
     * the questID will be -1 in the case.
     */
    public function createQuest(
            questName : String, questTypeID : Int, callback : Dynamic = null) : Void
    {
        var message : CreateQuestRequest = 
        new CreateQuestRequest(questName, questTypeID);
        message.injectParams();
        
        var callbackData : CallbackRequest = 
        new CallbackRequest(callback, getCurrentGameServerData());
        
        //No uid required for this request.
        request(
                CGSServerConstants.CREATE_QUEST, handleCreateQuestResponse, 
                message, null, null, callbackData
        );
    }
    
    private function handleCreateQuestResponse(
            data : String, failed : Bool, request : ServerRequest) : Void
    {
        var callback : Dynamic = request.callback;
        if (failed)
        {
            if (callback != null)
            {
                callback(-1, true);
            }
        }
        else
        {
            try
            {
                var urlVariables : URLVariables = new URLVariables(data);
                var jsonObject : Dynamic = Json.parse(urlVariables.data);
                
                var questData : Dynamic = jsonObject.rdata;
                var qid : Int = questData.qid;
                if (callback != null)
                {
                    callback(qid, false);
                }
            }
            catch (er : Error)
            {
                if (callback != null)
                {
                    callback(-1, true);
                }
            }
        }
    }
    
    //
    // Quest logging.
    //
    
    /**
     * Start logging quest actions for a quest with the given dqid. This function does NOT
     * send a quest start message to the server.
     */
    public function startLoggingQuestActions(
            questId : Int, dqid : String, localDqid : Int = -1) : Int
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        return userHandler.startLoggingQuestActions(questId, dqid, localDqid);
    }
    
    /**
     * Flush out all actions for the active quest.
     */
    public function endLoggingQuestActions(localDqid : Int = -1) : Void
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        return userHandler.endLoggingQuestActions(localDqid);
    }
    
    /**
     * Log the start of a new quest with the specified dqid which
		 * has already been retrieved from the server.
     * If a dqid is needed from the server, use logQuestStart.
     * When the quest is complete, the logQuestEnd must be called.
     *
     * @param questID the quest id as defined on the server.
     * @param dqid the dynamic quest id which has been requested from the server.
     * @param details an object which contains name/value pairs of
		 * 		  propertiesto be stored on the server.
     * @param levelID an optional server paramter which
		 *        can be used to group quests into a level.
     * @param aeSeqID an optional id which may be needed if
		 * 		  the Assessment Engine is involved with the game.
     * @param localDQID optional parameter for a local unique quest id.
     *
     * @return localDQID which can be used to log actions for the quest.
     * If your game only has one active quest at a time,
     * you do not need to pass the localDQID to log actions.
     */
    public function logQuestStartWithDQID(
            questID : Int, questHash : String, dqid : String, details : Dynamic,
            aeSeqID : String = null, localDQID : Int = -1) : Int
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        
        return userHandler.logQuestStartWithDQID(
                questID, questHash, dqid, details, null, aeSeqID, localDQID
        );
    }
    
    /**
     * Log the start of a quest. This assumes that there is no valid dqid
     * for the quest and one will be requested from the server.
     * When the quest is complete, the logQuestEnd must be called.
     *
     * @param questID the id of the quest as defined on the server.
     * @param details properties to be logged with the quest start.
     * @param callback function to be called when the dqid is returned from the
     * server. Function should have the signature of (dqid:String, failed:Boolean).
     * @param levelID an optional server paramter which can be used to
     * group quests into a level.
     * @param aeSeqID used in conjection with the Assessment engine.
     * @param localDQID optional parameter for a local unique quest id.
     *
     * @return localDQID which can be used to log actions for the quest.
		 * If your game only has one active quest at a time,
		 * you do not need to pass the localDQID to log actions.
     */
    public function logQuestStart(
            questID : Int, questHash : String, details : Dynamic, callback : Dynamic = null,
            aeSeqID : String = null, localDQID : Int = -1) : Int
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        return userHandler.logQuestStart(
                questID, questHash, details, callback, aeSeqID, localDQID
        );
    }
    
    /**
		 * Log the start of a quest. This assumes that there is no valid dqid for the quest and
		 * one will be requested from the server. This function should only be used in a multiplayer game.
		 * The parentDqid value should be the dqid value of the quest being logged on the server.
		 *
		 * @param questID the id of the quest as defined on the server.
		 * @param details properties to be logged with the quest start.
		 * @param parentDqid dqid of the quest being logged on the server.
		 * @param multiSeqId the sequence id, dictated by the server, that is used to interleave multiple
		 * client quests and actions.
		 * @param callback function to be called when the dqid is returned from the server.
		 * Function should have the signature of (dqid:String, failed:Boolean).
		 * @param aeSeqID used in conjection with the Assessment engine.
		 * @param localDQID optional parameter for a local unique quest id.
		 *
		 * @return localDQID which can be used to log actions for the quest. If your game only has one active quest
		 * at a time, you do not need to pass the localDQID to log actions.
		 */
    public function logMultiplayerQuestStart(
            questId : Int, questHash : String, details : Dynamic, parentDqid : String,
            multiSeqId : Int, callback : Dynamic = null,
            aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        return userHandler.logMultiplayerQuestStart(
                questId, questHash, details, parentDqid, 
                multiSeqId, callback, aeSeqId, localDqid
        );
    }
    
    public function createMultiplayerQuestStartRequest(
            questId : Int, questHash : String, details : Dynamic, parentDqid : String,
            multiSeqId : Int, callback : Dynamic = null, aeSeqId : String = null,
            localDqid : Int = -1) : QuestLogContext
    {
        return userHandler.createQuestStartRequest(
                questId, questHash, details, callback, aeSeqId, 
                localDqid, null, parentDqid, -1, -1, -1, -1, multiSeqId
        );
    }
    
    /**
     * @param dqid the dqid for the foreign quest being linked to this game.
     * @param foreignGameId the game id for the game quest being linked to this game.
     */
    public function logForeignQuestStart(
            dqid : String, foreignGameId : Int, foreignCategoryId : Int,
            foreignVersionId : Int, foreignConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null) : Void
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        
        userHandler.logForeignQuestStart(
                dqid, foreignGameId, foreignCategoryId, 
                foreignVersionId, foreignConditionId, details, callback
        );
    }
    
    public function logLinkedQuestStart(
            questId : Int, questHash : String, linkGameId : Int, linkCategoryId : Int,
            linkVersionId : Int, linkConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null,
            aeSeqId : String = null, localDqid : Int = -1) : Int
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        
        return userHandler.logLinkedQuestStart(
                questId, questHash, linkGameId, 
                linkCategoryId, linkVersionId, linkConditionId, 
                details, callback, aeSeqId, localDqid
        );
    }
    
    /**
     * Log a quest start using the legacy method on the server. This method
     * should not be used, @see logQuestStart for updated server method.
     *
     * @param questID the id of the quest as defined on the server.
     * @param details properties to be logged with the quest start.
     * @param callback function to be called when the dqid is returned from the
     * server. Function should have the signature of (dqid:String, failed:Boolean).
     * @param levelID an optional server paramter which
     * can be used to group quests into a level.
     * @param aeSeqID used in conjection with the Assessment engine.
     * @param localDQID optional parameter for a local unique quest id.
     *
     * @return localDQID which can be used to log actions for the quest.
     * If your game only has one active quest at a time, you do not need to
     * pass the localDQID to log actions.
     * @deprecated
     *
    public function legacyLogQuestStart(
    questID:int, details:Object, callback:Dynamic = null,
    aeSeqID:String = null, localDQID:int = -1):int
    {
    var userHandler:UserLoggingHandler =
    getCurrentGameServerData().userLoggingHandler;

    return userHandler.legacyLogQuestStart(
    questID, details, callback, aeSeqID, localDQID);
    }*/
    
    /**
     * Log the end of a quest. This also causes the buffer handler to be
     * stopped and wait for the next quest start message. After this method is
     * called no more actions should be logged for the quest.
     *
     * @param questID the id of the quest to end.
     * @param details the information to be logged at the end of quest.
     * @param callback function that will be called when the log quest
     * end is logged on the server. Function should have
     * the signature of (dqid:String, failed:Boolean).
     * @param localDQID only needed if game has multiple open quests.
     */
    public function logQuestEnd(
            details : Dynamic, callback : Dynamic = null, localDQID : Int = -1) : Void
    {
        userHandler.logQuestEnd(details, localDQID, callback);
    }
    
    public function logMultiplayerQuestEnd(
            details : Dynamic, parentDqid : String, multiSeqId : Int,
            callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        userHandler.logMultiplayerQuestEnd(
                details, parentDqid, multiSeqId, localDqid, callback
        );
    }
    
    public function createMultiplayerQuestEndRequest(
            details : Dynamic, parentDqid : String, multiSeqId : Int,
            callback : Dynamic = null, localDqid : Int = -1) : QuestLogContext
    {
        return userHandler.createQuestEndRequest(
                details, localDqid, callback, parentDqid, multiSeqId
        );
    }
    
    public function hasQuestLoggingStarted(localDqid : Int = -1) : Bool
    {
        return userLoggingHandler.hasQuestLoggingStarted(localDqid);
    }
    
    public function isQuestActive(localDqid : Int = -1) : Bool
    {
        return hasQuestLoggingStarted(localDqid);
    }
    
    //
    // Quest action handling.
    //
    
    /**
		 * Log a quest action that is related to a multiplayer quest.
     * This function should be used if the action is being logged on the client.
		 *
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param multiSeqId the sequence id, dictated by the server,
     * that is used to interleave multiple client actions.
		 * @param localDqid the localDQID for the quest that this action should be
     * logged under. Only needed if there is more than one active quest for
     * which actions are being logged.
		 * @param forceFlush indicates if the actions buffer should be flushed
     * after the passed action is added to the actions buffer.
		 */
    public function logMultiplayerQuestAction(
            action : QuestAction, multiSeqId : Int,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        action.setMultiplayerSequenceId(multiSeqId);
        logQuestAction(action, localDqid, forceFlush);
    }
    
    /**
		 * Log a quest action that is related to a multiplayer quest. This function
     * should be used if the action is being logged on the server for a specific user.
		 *
		 * @param action the client action to be logged on the server. Can not be null.
		 * @param multiSeqId the sequence id, dictated by the server,
     * that is used to interleave multiple client actions.
		 * @param multiUid the uid for the user that action relates to.
		 * @param localDqid the localDQID for the quest that this action should
     * be logged under. Only needed if there is more than one active quest for
     * which actions are being logged.
     * @param forceFlush indicates if the actions buffer should be flushed
     * after the passed action is added to the actions buffer.
		 */
    public function logServerMultiplayerQuestAction(
            action : QuestAction, multiSeqId : Int, multiUid : String,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        action.setMultiplayerSequenceId(multiSeqId);
        action.setMultiplayerUid(multiUid);
        logQuestAction(action, localDqid, forceFlush);
    }
    
    /**
     * Log a quest action. If the action is not bufferable, it will be
     * sent as it own message to the server. This will also cause all previosly
     * buffered actions to be flushed to the server regardless of
     * the forceFlush parameter.
     *
     * @param action the client action to be logged on the server. Can not be null.
     * @param localDQID the localDQID for the quest that this action should
     * be logged under. Only needed if there is more than one active quest
     * for which actions are being logged.
     * @param forceFlush indicates if the actions buffer should be flushed
     * after the passed action is added to the actions buffer.
     */
    public function logQuestAction(
            action : QuestAction, localDQID : Int = -1, forceFlush : Bool = false) : Void
    {
        userHandler.logQuestAction(action, localDQID, forceFlush);
    }
    
    public function logQuestActionData(
            action : QuestActionLogContext,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        userHandler.logQuestActionData(action, localDqid, forceFlush);
    }
    
    /**
     * Sends all buffered actions to the server.
     *
     * @param localDQID the localDQID for which actions should be flushed. If
     * -1 is passed, actions for all quests are flushed to the server.
     */
    public function flushActions(localDQID : Int = -1, callback : Dynamic = null) : Void
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        userHandler.flushActions(localDQID, callback);
    }
    
    //
    // Score saving and loading.
    //
    
    /**
     * Save a score for the user. This score is saved with the current
     * quest id and dqid which have been set by the startQuest call.
     *
     * @param score the score for the current quest.
     * @param callback function to be called when the score
     * has been logged on the server.
     * @param localDQID
     */
    public function logQuestScore(
            score : Int, callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        userHandler.logQuestScore(score, callback, localDqid);
    }
    
    /**
     * Save a user score which is not associated with a single quest. This score
     * could be the total score for several quests or game levels.
     * The passed quest id should be unique and can be used to
     * differentiate this score value from other player scores.
     *
     * @param score the score for the current quest.
     * @param questID the unique id which indentifies the passed score.
     */
    public function logScore(score : Int, questId : Int, callback : Dynamic = null) : Void
    {
        var userHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        userHandler.logScore(score, questId, callback);
    }
    
    /**
     * Request all of the scores for the given quest id.
     */
    public function requestScores() : Void
    {  //TODO - Implement once server has functionality implemented.  
        
    }
    
    //
    // Saving and loading game data.
    //
    
    /**
     * Save the passed data object to the server with the passed data id.
     *
     * @param dataID the id which should be associated with the passed data object.
     * @param data the object to be saved on the server. This object will be converted
     * to a JSON encoded string.
     * @param callback an optional function to be called when the data has
     * been successfully loaded to the server. The function should have
     * the signature (dataID:int, failed:Boolean, localSaveId:int).
     */
    public function saveGameData(
            dataID : String, data : Dynamic, localSaveId : Int = -1, callback : Dynamic = null) : Void
    {
        var message : Message = getServerMessage();
        message.addProperty("udata_id", dataID);
        message.addProperty("data_detail", data);
        message.injectParams();
        
        var dataRequest : GameDataRequest = 
        new GameDataRequest(callback, dataID, localSaveId);
        
        userRequest(
                CGSServerConstants.SAVE_GAME_DATA, message, null, null, 
                ServerRequest.LOGGING_URL, ServerRequest.POST, 
                dataRequest, handleGameDataSaved
        );
    }
    
    private function handleGameDataSaved(response : CgsResponseStatus) : Void
    {
        var dataRequest : GameDataRequest = response.passThroughData;
        var callback : Dynamic = dataRequest.callback;
        var dataID : String = dataRequest.dataId;
        
        if (callback != null)
        {
            callback(dataID, response.failed, dataRequest.saveId);
        }
    }
    
    public function batchSaveGameData(dataMap : StringMap<Dynamic>,
            saveKey : String = null,
            localSaveId : Int = -1,
            callback : Dynamic = null,
            serverCacheVersion : Int = 1) : Void
    {
        var message : Message = getServerMessage();
        message.injectParams();
        
        var dataIds : Array<Dynamic> = [];
        var saveData : Array<Dynamic> = [];
        for (dataId in dataMap.keys())
        {
            saveData.push({
                        udata_id : dataId,
                        data_detail : dataMap.get(dataId)
                    });
            dataIds.push(dataId);
        }
        
        if (saveData.length == 0)
        {
            return;
        }
        
        message.addProperty("save_data", saveData);
        
        if (saveKey != null)
        {
            message.addProperty("save_key", saveKey);
        }
        
        var serverUrlHost : Int = ServerRequest.LOGGING_URL;
        var serverActionName : String = CGSServerConstants.SAVE_GAME_DATA;
        if (serverCacheVersion == 2)
        {
            serverUrlHost = ServerRequest.INTEGRATION_URL;
            serverActionName = CGSServerConstants.BATCH_APP_GAME_DATA;
        }
        
        userRequest(serverActionName, 
                message, null, null, 
                serverUrlHost, ServerRequest.POST, 
                null, function(response : CgsResponseStatus) : Void
                {
                    if (callback != null)
                    {
                        callback(dataIds, response.failed, localSaveId);
                    }
                }
        );
    }
    
    /**
     * Why is this function so similarly named, is a bit confusing to know what exactly it does
     */
    public function loadGameSaveData(callback : Dynamic, saveKey : String = null) : Void
    {
        var message : Message = getServerMessage();
        message.injectParams();
        if (saveKey != null)
        {
            message.addProperty("save_key", saveKey);
        }
        
        serverRequest(
                CGSServerConstants.LOAD_USER_APP_SAVE_DATA_V2, 
                message, null, null, ServerRequest.INTEGRATION_URL, 
                null, null, ServerRequest.GET, URLLoaderDataFormat.TEXT, 
                true, new GameUserDataResponseStatus(true), 
                function(response : GameUserDataResponseStatus) : Void
                {
                    if (callback != null)
                    {
                        callback(response);
                    }
                }
        );
    }
    
    /**
     * Loads all saved data for the current user.
     *
     * @param callback 
     *      function which will be called when the users game data
     *      has been loaded from the server. Function should have the
     *      signature (data:UserGameData, failed:Boolean):void.
     * @param loadByCid
     */
    public function loadGameData(callback : Dynamic, loadByCid : Bool = false) : Void
    {
        var message : Message = getServerMessage();
        message.injectParams();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, getCurrentGameServerData());
        var serverMethod : String = (loadByCid) ? 
        CGSServerConstants.LOAD_USER_GAME_SERVER_DATA : 
        CGSServerConstants.LOAD_USER_GAME_DATA;
        
        serverRequest(
                serverMethod, message, null, null, ServerRequest.LOGGING_URL, 
                callbackRequest, null, ServerRequest.GET, URLLoaderDataFormat.TEXT, 
                true, new GameUserDataResponseStatus(true), handleGameDataLoaded
        );
    }
    
    private function handleGameDataLoaded(response : GameUserDataResponseStatus) : Void
    {
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        
        if (callback != null)
        {
            callback(response);
        }
    }
    
    /**
     * Load a users game data from the server.
     *
     * @param dataID the id of the data to load from the server.
     * @param callback the function to be called when the data is loaded from the server.
     * callback should have the signature (data:UserDataChunk, failed:Boolean).
     */
    public function loadGameDataByID(dataID : String, callback : Dynamic) : Void
    {
        var message : Message = getServerMessage();
        message.addProperty("udata_id", dataID);
        message.injectParams();
        
        var callbackRequest : GameDataRequest = new GameDataRequest(callback, dataID);
        
        serverRequest(
                CGSServerConstants.LOAD_GAME_DATA, message, null, null, 
                ServerRequest.LOGGING_URL, callbackRequest, null, 
                ServerRequest.GET, URLLoaderDataFormat.TEXT, true, 
                new GameUserDataResponseStatus(false), handleGameDataLoadByID
        );
    }
    
    //Handle loading of data from the server.
    private function handleGameDataLoadByID(response : GameUserDataResponseStatus) : Void
    {
        var request : GameDataRequest = response.passThroughData;
        var callback : Dynamic = request.callback;
        
        if (callback != null)
        {
            callback(response.userGameDataChunk, response.failed);
        }
    }
    
    //
    // Terms of service handling.
    //
    
    /**
     * Indicates if the user has responded to the tos.
     */
    private function get_tosResponseExists() : Bool
    {
        var gameData : IGameServerData = getCurrentGameServerData();
        return (gameData != null) && gameData.cgsCache.saveExists(CGSServerConstants.TOS_DATA_ID);
    }
    
    /**
     * Save the user's response to the terms of service.
     *
     * @param callback function to be called when the users response has been saved on the server.
     * Function should have the following signature: (response:ResponseStatus):void.
     */
    public function saveTosStatus(
            accepted : Bool, tosVersion : Int, tosHash : String,
            languageCode : String, callback : Dynamic = null) : Void
    {
        var timeStamp : Float = Math.round(Date.now().getTime() / 1000);
        var gameServerData : IGameServerData = getCurrentGameServerData();
        var saveObject : Dynamic = 
        {
            sessionid : gameServerData.sessionId,
            accepted : accepted,
            version : tosVersion,
            timestamp : timeStamp,
            hash : tosHash,
            language : languageCode
        };
        saveGameData(CGSServerConstants.TOS_DATA_ID, saveObject, -1, callback);
    }
    
    //
    // Generic data loading methods.
    //
    
    /**
     * Make a generic request to retrieve data from the server.
     *
     * @param method the path of the method to be called on the server.
     * @param dataParams object containing parameters to be
     * included in the data url variable.
     * @param callback function to be called when data has
     * been retrieved from the server. Function should have the
     * following signature (response:ResponseStatus):void.
     * @param returnType the type of data to be returned.
     */
    public function requestLoggingData(
            method : String, dataParams : Dynamic,
            callback : Dynamic, returnType : String = "TEXT") : Void
    {
        var message : Message = getServerMessage();
        for (key in Reflect.fields(dataParams))
        {
            message.addProperty(key, Reflect.field(dataParams, key));
        }
        message.injectParams();
        
        var callbackRequest : CallbackRequest = 
        new CallbackRequest(callback, getCurrentGameServerData(), returnType);
        
        userRequest(
                method, message, null, null, ServerRequest.LOGGING_URL, 
                ServerRequest.GET, callbackRequest, handleLoggingDataLoaded
        );
    }
    
    //TODO - Update to allow for the return data type to be specified, test, json object.
    private function handleLoggingDataLoaded(response : CgsResponseStatus) : Void
    {
        var callbackRequest : CallbackRequest = response.passThroughData;
        var callback : Dynamic = callbackRequest.callback;
        if (callback != null)
        {
            callback(response);
        }
    }
    
    
    //
    // Logging data retrieval.
    //
    
    /**
     * Request all of the quest data associated with the given dqid.
     *
     * @param dqid the dynamic quest id for which all quest data should be retrieved from the server.
     * @param callback the callback to be called when quest data has been loaded. The callback
     * should have the following signatire (questData:QuestData, failed:Boolean):void.
     **/
    public function requestQuestData(dqid : String, callback : Dynamic = null) : Void
    {
        var dataRequest : QuestDataRequest = new QuestDataRequest(this, dqid, callback);
        dataRequest.makeRequests(_urlRequestHandler);
    }
    
    //
    // Helper functions.
    //
    
    /**
		 * Parse the data returned from the server
		 * Will return null if the parse fails.
		 */
    private function parseResponseData(
            rawData : String, returnDataType : String = "JSON") : Dynamic
    {
        var data : Dynamic = null;
        try
        {
            var urlVars : URLVariables = new URLVariables(rawData);
            var dataString : String = urlVars.data;
            if (returnDataType == "JSON")
            {
                data = Json.parse(dataString);
            }
            else
            {
                data = dataString;
            }
			
            //Handle the server data for the response.
            if (Reflect.hasField(urlVars, "server_data"))
            {
                var serverDataRaw : String = urlVars.serverData;
                var serverData : Dynamic = Json.parse(serverDataRaw);
                
                //updateLoggingLoad(serverData);
                
                if (Reflect.hasField(serverData, "pvid"))
                {
                    _currentResponseVersion = serverData.pvid;
                }
                else
                {
                    _currentResponseVersion = 0;
                }
            }
            else
            {
                _currentResponseVersion = 0;
                if (returnDataType == "JSON")
                {  //updateLoggingLoad(data);  
                    
                }
            }
        }
        catch (er : Error)
        {  //Unable to parse the returned data from the server. Server must have failed.  
            
        }
        
        return data;
    }
    
    private function didRequestFail(dataObject : Dynamic) : Bool
    {
        if (dataObject == null)
        {
            return true;
        }
        
        var failed : Bool = true;
        if (Reflect.hasField(dataObject, "tstatus"))
        {
            failed = dataObject.tstatus != "t";
        }
        
        return failed;
    }
    
    /**
     * Get timestamp to prevent URL caching.
     */
    public static function getTimeStamp() : String
    {
        var timeStamp : Float = Date.now().getTime();
        return Std.string(timeStamp);
    }
    
    //
    // External timer handling.
    //
    
    /**
     * External timer handling. Can be used for custom buffer flush handling.
     * This allows the buffer flush handler to be paused with a global timer.
     *
     * @param delta time change in seconds.
     */
    public function onTick(delta : Float) : Void
    {  /*if(_actionBufferHandler != null)
        {
        _actionBufferHandler.onTick(delta);
        }*/  
        
    }
    
    /**
		 * @inheritDoc
		 */
    public function authenticateStudent(
            username : String, password : String, teacherCode : String, gradeLevel : Int = -1,
            callback : Dynamic = null, saveCacheDataToServer : Bool = true) : Void
    {
        _initialized = true;
        
        var logHandler : UserLoggingHandler = 
        getCurrentGameServerData().userLoggingHandler;
        
        logHandler.authenticateUser(username, password, teacherCode, gradeLevel, 
                userInitAuthStudent, this, callback, saveCacheDataToServer
        );
    }
    
    private function userInitAuthStudent(
            username : String, password : String,
            teacherCode : String, callback : Dynamic = null, gradeLevel : Int = 0) : Int
    {
        var data : Dynamic = 
        {
            mem_login : username,
            teacher_code : teacherCode,
            grade_level : gradeLevel
        };
        
        if (password != null)
        {
            data.mem_pcode = password;
        }
        
        var gameSaveData : IGameServerData = getCurrentGameServerData();
        gameSaveData.userName = username;
        
        var method : String = (gameSaveData.authenticateCachedStudent) ? 
        CGSServerConstants.AUTHENTICATE_CACHED_STUDENT : 
        CGSServerConstants.AUTHENTICATE_STUDENT;
        
        return serverRequest(
                method, null, data, null, 
                ServerRequest.INTEGRATION_URL, callback, null, 
                ServerRequest.POST, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                handleUserAuthentication
        );
    }
    
    /**
		 * @inheritDoc
		 */
    public function registerStudent(
            username : String, teacherCode : String,
            gradeLevel : Int = 0, userCallback : Dynamic = null,
            gender : Int = 0) : Void
    {
        var data : Dynamic = {
            mem_login : username,
            teacher_code : teacherCode
        };
        
        // Include grade in the register request if set
        if (gradeLevel != 0)
        {
            data.grade = gradeLevel;
        }
        
        // Include gender in the register request if set
        if (gender != 0)
        {
            data.gender = gender;
        }
        
        serverRequest(CGSServerConstants.REGISTER_STUDENT, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.POST, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                function(status : CgsResponseStatus) : Void
                {
                    handleStudentRegistration(
                            username, teacherCode, status, userCallback
                );
                }
        );
    }
    
    private function handleStudentRegistration(
            username : String, teacherCode : String, status : CgsResponseStatus, userCallback : Dynamic) : Void
    {
        if (status.success)
        {
            authenticateStudent(username, null, teacherCode, 0, userCallback);
        }
        else
        {
            if (userCallback != null)
            {
                var userResponse : CgsUserResponse = new CgsUserResponse(null, null);
                userResponse.authorizationResponse = status;
                userCallback(userResponse);
            }
        }
    }
    
    /**
     * @inheritDoc
     */
    public function updateStudent(username : String, teacherUid : String, gradeLevel : Int, gender : Int, userCallback : Dynamic) : Void
    {
        var data : Dynamic = {
            login : username,
            teacher_code : teacherUid,
            grade : gradeLevel,
            gender : gender
        };
        serverRequest(CGSServerConstants.UPDATE_STUDENT, null, data, null, 
                ServerRequest.INTEGRATION_URL, userCallback, null, 
                ServerRequest.POST, URLLoaderDataFormat.TEXT, false, 
                new CgsResponseStatus(getCurrentGameServerData()), 
                function(status : CgsResponseStatus) : Void
                {
                    userCallback();
                }
        );
    }
    
    //
    // Co-pilot handling.
    //
    
    private function set_lessonId(id : String) : String
    {
        gameServerData.lessonId = id;
        return id;
    }
    
    //
    // Tos handling.
    //
    
    public function containsTosItemData(
            tosKey : String, languageCode : String = "en", version : Int = -1) : Bool
    {
        return _tosData.containsTos(tosKey, languageCode, version);
    }
    
    public function getTosItemData(tosKey : String,
            languageCode : String = "en", version : Int = -1) : TosItemData
    {
        return _tosData.getTosData(tosKey, languageCode, version);
    }
    
    private function get_userTosStatus() : IUserTosStatus
    {
        return getCurrentGameServerData().userTosStatus;
    }
    
    private function get_containsUserTosStatus() : Bool
    {
        return getCurrentGameServerData().containsUserTosStatus;
    }
    
    /**
		 * Handle loading the user tos status.
		 */
    public function loadUserTosStatus(
            tosKey : String, callback : Dynamic = null,
            languageCode : String = "en", gradeLevel : Int = 0) : Void
    {
        var message : Message = getServerMessage();
        message.injectParams();
        
        message.addProperty("tos_key", tosKey);
        message.addProperty("lan_code", languageCode);
        message.addProperty("grade_level", gradeLevel);
        
        var method : String = CGSServerConstants.TOS_USER_STATUS;
        if (gameServerData.tosServerVersion == 2)
        {
            method = CGSServerConstants.TOS_USER_STATUS_V2;
        }
        
        serverRequest(method, message, null, null, 
                ServerRequest.INTEGRATION_URL, null, null, 
                ServerRequest.GET, URLLoaderDataFormat.TEXT, true, 
                new TosResponseStatus(_tosData, tosKey, getCurrentGameServerData()), 
                function(response : TosResponseStatus) : Void
                {
                    _tosData.addTosDataItems(response.tosItemData);
                    
                    if (callback != null)
                    {
                        callback(response);
                    }
                }
        );
    }
    
    public function updateUserTosStatus(
            userStatus : IUserTosStatus, callback : Dynamic = null) : Void
    {
        var message : Message = getServerMessage();
        message.injectParams();
        message.injectSessionId();
        message.injectClientTimeStamp();
        
        message.addProperty("accepted", (userStatus.accepted) ? 1 : 0);
        message.addProperty("tos_key", userStatus.tosKey);
        message.addProperty("tos_version", userStatus.tosVersion);
        message.addProperty("language_code", userStatus.tosLanguageCode);
        message.addProperty("tos_hash", userStatus.tosMd5Hash);
        
        var method : String = CGSServerConstants.TOS_USER_UPDATE;
        if (gameServerData.tosServerVersion == 2)
        {
            method = CGSServerConstants.TOS_USER_UPDATE_V2;
        }
        
        serverRequest(method, message, null, null, 
                ServerRequest.INTEGRATION_URL, null, null, ServerRequest.POST, 
                URLLoaderDataFormat.TEXT, true, null, callback
        );
    }
    
    public function exemptUserFromTos(callback : Dynamic = null) : Void
    {
        localExemptUserFromTos(gameServerData.tosServerVersion, callback);
    }
    
    private function localExemptUserFromTos(
            version : Int, callback : Dynamic = null) : Void
    {
        var message : Message = getServerMessage();
        
        message.injectParams();
        message.injectSessionId();
        message.injectClientTimeStamp();
        
        var method : String = CGSServerConstants.TOS_USER_EXEMPT;
        
        if (version == 2)
        {
            method = CGSServerConstants.TOS_USER_EXEMPT_V2;
        }
        
        serverRequest(method, message, null, null, 
                ServerRequest.INTEGRATION_URL, null, null, ServerRequest.POST, 
                URLLoaderDataFormat.TEXT, true, null, callback
        );
    }
    
    /**
		 * Load a specific version of the tos.
		 */
    public function loadTos(
            tosKey : String, languageCode : String = "en",
            version : Int = -1, callback : Dynamic = null) : Void
    {
        var message : Message = getServerMessage();
        message.injectParams();
        
        message.addProperty("tos_key", tosKey);
        message.addProperty("language_code", languageCode);
        if (version >= 0)
        {
            message.addProperty("version", version);
        }
        
        serverRequest(CGSServerConstants.TOS_REQUEST, message, 
                null, null, ServerRequest.INTEGRATION_URL, null, null, 
                ServerRequest.POST, URLLoaderDataFormat.TEXT, true, 
                new TosResponseStatus(_tosData, tosKey, getCurrentGameServerData()), 
                function(response : TosResponseStatus) : Void
                {  //TODO - Save the tos terms locally.  
                    
                }
        );
    }
    
    public function containsTos(
            tosKey : String, languageCode : String = "en", version : Int = -1) : Bool
    {
        return _tosData.containsTos(tosKey, languageCode, version);
    }
    
    public function userTosRequired() : Bool
    {
        var userTosStatus : IUserTosStatus = getCurrentGameServerData().userTosStatus;
        
        return (userTosStatus != null) ? userTosStatus.acceptanceRequired : false;
    }
    
    private function get_userData() : UserData
    {
        return (_userAuth != null) ? _userAuth.userData : null;
    }
    
    //
    // Quest log dqid functions.
    //
    
    public function isDqidValid(localDqid : Int = -1) : Bool
    {
        return userLoggingHandler.isDqidValid(localDqid);
    }
    
    public function getDqidRequestId(localDqid : Int = -1) : Int
    {
        return userLoggingHandler.getDqidRequestId(localDqid);
    }
    
    public function getDqid(localDqid : Int = -1) : String
    {
        return userLoggingHandler.getDqid(localDqid);
    }
    
    public function addDqidCallback(callback : Dynamic, localDqid : Int = -1) : Void
    {
        userLoggingHandler.addDqidCallback(callback, localDqid);
    }
    
    public function getQuestLogger(localDqid : Int = -1) : QuestLogger
    {
        return userLoggingHandler.getQuestLog(localDqid);
    }
    
    //
    // Homeplay handling.
    //
    
    public function logHomeplayQuestStart(
            questId : Int, questHash : String, questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic, localDqid : Int = -1, callback : Dynamic = null) : Int
    {
        return userHandler.logHomeplayQuestStart(
                questId, questHash, questDetails, homeplayId, 
                homeplayDetails, localDqid, callback
        );
    }
    
    /**
		 * Callback should have the following signature: (failed:Boolean):void
		 */
    public function logHomeplayQuestComplete(
            questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false,
            localDqid : Int = -1, callback : Dynamic = null) : Void
    {
        userHandler.logHomeplayQuestComplete(
                questDetails, homeplayId, 
                homeplayDetails, homeplayCompleted, localDqid, callback
        );
    }
    
    private function get_hasPendingLogs() : Bool
    {
        return false;
    }
}
