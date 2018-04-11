package cgs;

import cgs.cache.CGSCache;
import cgs.cache.ICGSCache;
import cgs.utils.Error;
import cgs.achievement.CgsAchievementManager;
//import cgs.logger.Logger;
//import cgs.login.LoginPopup;
//import cgs.logotos.TosUi;
import cgs.server.IntegrationDataService;
import cgs.server.NtpTimeService;
import cgs.server.RequestService;
import cgs.server.abtesting.AbTestingVariables;
import cgs.server.abtesting.IUserAbTester;
import cgs.server.abtesting.UserAbTester;
import cgs.server.challenge.ChallengeService;
import cgs.server.logging.CGSServerProps;
import cgs.server.logging.CgsServerApi;
import cgs.server.logging.IGameServerData;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.LoggingDataService;
import cgs.server.logging.MultiplayerLoggingService;
import cgs.server.requests.IUrlRequestHandler;
import cgs.server.requests.RequestFailureHandler;
import cgs.server.requests.UrlLoader;
import cgs.server.requests.UrlRequestHandler;
import cgs.server.responses.CgsUserResponse;
import cgs.teacherportal.CgsCopilotProperties;
import cgs.teacherportal.CopilotService;
import cgs.user.CgsUser;
import cgs.user.CgsUserManager;
import cgs.user.ICgsUserProperties;
import cgs.user.ICgsUser;
import cgs.user.ICgsUserManager;

/**
	 * Factory class for working with users and other common cgs components.
	 */
class CgsApi
{
    public var isProductionRelease(get, never) : Bool;
    public var isDevelopmentRelease(get, never) : Bool;
    private var urlRequestHandler(never, set) : IUrlRequestHandler;
    public var userManager(get, never) : ICgsUserManager;
    public var requestsObjectData(get, never) : Dynamic;

    public static inline var DEVELOPMENT_RELEASE : String = "DEV";
    public static inline var PRODUCTION_RELEASE : String = "PRD";
    
    public static inline var FONT_DEFAULT : String = "Roboto";
    public static inline var TOS_FONT_DEFAULT : String = "Vegur";
    
    private static inline var GAME_JS_FUNCTION : String = "CgsGames.canControlLogging";
    
    //Users that have been created / authenticated.
    private var _userManager : CgsUserManager;
    
    //CGSCache instance used by all users
    private var _cache : ICGSCache;
    
    //Request handler for all services.
    private var _requestHandler : IUrlRequestHandler;
    
    //Contains default properties for ab testing.
    private var _abTestingProperties : AbTestingVariables;
    
    //Handles keeping server time for requests that require ntp time.
    private var _ntpTime : NtpTimeService;
    
    private var _releaseMode : String = DEVELOPMENT_RELEASE;
    
    //Keep reference to the last game id used when creating user. Used to log
    //uncaught errors to the server.
    private var _lastGameId : Int;
    
    private var _jsCanControlLogging : Bool = false;
    
    private var _externalInterfaceAvail : Bool = true;
    
    private var _useHttps : Bool;
    
    /**
     *
     * @param useHttps
     *      A bit of a hack, this will overwrite the various server properties to use the same value
     *      as this one that was passed in.
     */
    public function new(requestHandler : IUrlRequestHandler = null,
            defaultCache : ICGSCache = null,
            defaultUserManager : CgsUserManager = null,
            useHttps : Bool = false)
    {
        // Create the CgsUserManager
        if (defaultUserManager != null)
        {
            _userManager = defaultUserManager;
        }
        else
        {
            _userManager = new CgsUserManager();
        }
        
        _abTestingProperties = new AbTestingVariables();
        
        //Create a request handler if one is not provided.
        urlRequestHandler = requestHandler;
        
        //Create the CGSCache if one is not provided
        if (defaultCache != null)
        {
            _cache = defaultCache;
        }
        else
        {
            _cache = new CGSCache();
        }
        
        //Update the ntp time to be used for all requests. Only needs to be
        //requested once.
        if (_ntpTime == null)
        {
            _ntpTime = new NtpTimeService(_requestHandler, useHttps);
        }
        
        _useHttps = useHttps;
        
        //Try and setup the javascript Api that allows save data and logging to
        //be flushed to the server.
        //setupExternalInterface();
    }
    
    //Indicates if any of the registers users has data that needs to be sent
    //to the server. Used by javascript to detect window close and send save data
    //and logs.
	private function hasServerData():Bool
	{
		if (_userManager.numUsers == 0) return false;
		
		var hasServerData:Bool = false;
		for(cgsUser in _userManager.userList)
		{
			hasServerData = hasServerData || cgsUser.flushServerRequests();
		}
		
		return hasServerData;
	}
    
    public function setReleaseMode(mode : String = DEVELOPMENT_RELEASE) : Void
    {
        _releaseMode = mode;
    }
    
    private function get_isProductionRelease() : Bool
    {
        return _releaseMode == "PRD";
    }
    
    private function get_isDevelopmentRelease() : Bool
    {
        return _releaseMode == "DEV";
    }
    
    private function set_urlRequestHandler(handler : IUrlRequestHandler) : IUrlRequestHandler
    {
        if (handler == null)
        {
            var failureHandler : RequestFailureHandler = new RequestFailureHandler();
            var loader : UrlLoader = new UrlLoader();
            
            handler = new UrlRequestHandler(loader, failureHandler);
        }
        
        _requestHandler = handler;
        return handler;
    }
    
   
    //
    // Service retrieval.
    //
    
    public function createRequestService(serviceUrl : String = null) : RequestService
    {
        return new RequestService(_requestHandler, serviceUrl);
    }
    
    /**
     * Get challenge service that can be used to log data for a user.
     */
    public function createChallengeService(user : ICgsUser, challengeId : Int) : ChallengeService
    {
        var server : ICgsServerApi = (try cast(user, CgsUser) catch(e:Dynamic) null).server;
        var props : IGameServerData = server.getCurrentGameServerData();
        
        var challengeService : ChallengeService = 
        new ChallengeService(
        _requestHandler, try cast(user, CgsUser) catch(e:Dynamic) null, 
        challengeId, props.serverTag, props.serverVersion, _useHttps);
        
        return challengeService;
    }
    
    public function createMultiplayerLoggingService(props : CGSServerProps) : MultiplayerLoggingService
    {
        props.useHttps = _useHttps;
        var server : CgsServerApi = new CgsServerApi(_requestHandler, _ntpTime, this);
        server.setupMultiplayerLogging(props);
        
        var service : MultiplayerLoggingService = 
        new MultiplayerLoggingService(
        server, _requestHandler, props.serverTag, props.serverVersion, _useHttps);
        
        return service;
    }
    
    /**
     * Get a remote service that can be used to retrieve logging data from server.
     * A new service is created each time this function is invoked.
     *
     * @param props properties object that defines parameters for connecting
     * to logging servers.
     * @return LoggingDataService service that can be used to retrieve data.
     * A new instance will be returned.
     */
    public function createLoggingDataService(props : CGSServerProps) : LoggingDataService
    {
        props.useHttps = _useHttps;
        
        var server : ICgsServerApi = new CgsServerApi(_requestHandler, _ntpTime);
        server.setup(props);
        
        var service : LoggingDataService = new LoggingDataService(
        _requestHandler, server, props.serverTag, props.serverVersion, _useHttps);
        
        return service;
    }
    
    /**
     * Get a remote service that can be used to retrieve data about usernames available
     * for users. Other features will be added as needed.
     *
     * @param props properties object that defines parameters for connecting
     * to logging servers.
     * @return IntegrationDataService service that can be used to retrieve data.
     * A new instance will be returned.
     */
    public function createIntegrationDataService(props : CGSServerProps) : IntegrationDataService
    {
        props.useHttps = _useHttps;
        
        var server : ICgsServerApi = new CgsServerApi(_requestHandler, _ntpTime);
        server.setup(props);
        
        var service : IntegrationDataService = new IntegrationDataService(
        _requestHandler, server, props.serverTag, props.serverVersion, _useHttps);
        
        return service;
    }
    
    //
    // User management functions.
    //
    
    /**
		 * Returns the User Manager used by this CgsApi.
		 */
    private function get_userManager() : ICgsUserManager
    {
        return _userManager;
    }
    
    /**
		 * Cleans up all allocated resources for a user.
		 */
    public function removeUser(user : ICgsUser) : Void
    {
        _userManager.removeUser(user);
    }
    
    private function addUser(user : ICgsUser) : Void
    {
        _userManager.addUser(user);
    }
    
    //
    // User creation functions.
    //
    
    /**
     * Initialize an anonymous user
     * 
     * @param props
     *      Parameters to initialize the server object that sends request.
     *      IMPORTANT the callback when the server has gotten the message is located inside
     *      the props object (called completeCallback)
     */
    public function initializeUser(props : ICgsUserProperties) : ICgsUser
    {
        var user : CgsUser = createUser(props);
        addUser(user);
        user.initializeAnonymousUser(props);
        
        return user;
    }
    
    //
    // Authenticated user functions.
    //
    
    public function isUserAuthenticated(props : ICgsUserProperties, callback : Dynamic = null) : ICgsUser
    {
        var user : CgsUser = createUser(props);
        
        handleUserAuth(user.isUserAuthenticated, user, callback, [props]);
        
        return user;
    }
    
    /**
		 * Authenticate a user with the cgs servers. A user
     * instance will be returned immediately but will not be valid
     * until the complete callback is called and is successful.
		 *
     * @param callback
     *      Signature callback(response:CgsUserResponse)
		 * @return ICgsUser
		 */
    public function authenticateUser(
            props : ICgsUserProperties, userName : String,
            password : String, callback : Dynamic = null) : ICgsUser
    {
        var user : CgsUser = createUser(props);
        
        handleUserAuth(user.initializeAuthenticatedUser, user, callback, [props, userName, password]);
        
        return user;
    }
    
    public function registerUser(
            props : ICgsUserProperties, name : String,
            password : String, email : String, callback : Dynamic) : ICgsUser
    {
        var user : CgsUser = createUser(props);
        
		handleUserAuth(user.registerUser, user, callback, [props, name, password, email]);
        
        return user;
    }
    
    /**
     *
     * @param callback
     *      Signature callback(response:CgsUserResponse)
     */
    public function authenticateStudent(
            props : ICgsUserProperties, username : String,
            teacherCode : String, password : String = null,
            gradeLevel : Int = 0, callback : Dynamic = null) : ICgsUser
    {
        var user : CgsUser = createUser(props);
        
		handleUserAuth(user.initializeAuthenticatedStudent, user, [callback, props, username, teacherCode, password, gradeLevel]);
        
        return user;
    }
    
    /**
     * Create a new account with a given username and bind it to a teacher account
     * 
     * @param username
     *      Name that needs to be unique amongst all other tied to the teacherCode
     * @param teacherCode
     *      A special identifier that links users to a teacher account
     * @param gradeLevel
     *      0 is unset
     * @param userCallback
     *      Callback when registration complete, signature callback(response:CgsUserResponse)
     * @param gender
     *      1 for female, 2 for male, 0 is unset
     */
    public function registerStudent(
            props : ICgsUserProperties, username : String, teacherCode : String,
            gradeLevel : Int = 0, userCallback : Dynamic = null, gender : Int = 0) : ICgsUser
    {
        var user : CgsUser = createUser(props);
        
		handleUserAuth(user.registerStudent, user, userCallback, [props, username, teacherCode, gradeLevel, gender]);
        
        return user;
    }
    
    /**
		 * Allow retry of authentication if the first try failed.
		 *
		 * @param cgsUser the user on which to retry authentication.
		 * @param username the login name of the user.
		 * @param password the input password for the user.
		 * @param callback the function to be called when
     * authentication succeeds or fails.
		 */
    public function retryUserAuthentication(cgsUser : ICgsUser,
            username : String, password : String, callback : Dynamic = null) : Void
    {
        handleUserAuth(cgsUser.retryAuthentication, cgsUser, [callback, username, password]);
    }
    
    /**
     * Generic method to handle all user authentication methods. This is used
     * to delay adding users to the user manager until they are valid.
     * 
     */
    private function handleUserAuth(
            authFunction : Dynamic, user : ICgsUser,
            userCallback : Dynamic, args : Array<Dynamic> = null) : Void
    {
        // IMPORTANT the user callback is always put at the end
        // Any function in that gets passed MUST have a callback as its last
        // parameter
        args.push(function(response : CgsUserResponse) : Void
                {
                    if (response.success)
                    {
                        addUser(user);
                    }
                    
                    if (userCallback != null)
                    {
                        userCallback(response);
                    }
                });
        
        Reflect.callMethod(null, authFunction, args);
    }
    
    /**
     * Create a blank anonymous user.
     */
    private function createUser(props : ICgsUserProperties) : CgsUser
    {
        // Override https usage
        props.useHttps = _useHttps;
        
        var server : ICgsServerApi = new CgsServerApi(_requestHandler, _ntpTime, this);
        var abTester : IUserAbTester = props.abTester;
        
        //Create the CgsUser and all required components.
        if (abTester == null && props.loadAbTests)
        {
            abTester = new UserAbTester(server);
            props.abTester = abTester;
        }
        
        if (abTester != null)
        {
            abTester.defaultVariableProvider = _abTestingProperties;
        }
        
        // Add the cache to the props, if not already set by game.
        if (props.cgsCache == null)
        {
            props.cgsCache = _cache;
        }
        
        if (_requestHandler != null)
        {
            _requestHandler.delayRequestListener = props.cacheActionForLaterCallback;
        }
        
        var achieveManager : CgsAchievementManager = new CgsAchievementManager();
        var aUser : CgsUser = new CgsUser(server, _cache, abTester, achieveManager);
        achieveManager.user = aUser;
        
        return aUser;
    }
    
    //
    // Ui creation for user specific Ui elements.
    //
    
    /**
		 * Create a login dialog that will create a new user with the given user
		 * properties.
		 *
		 * @param props the user properties to user when creating a new cgs user.
		 * @param loginCallback function for when the user logs in successfully,
		 * function should have the following signature (cgsUser:ICgsUser):void.
     * When this callback is called the user is valid for use.
     * This callback will override the completeCallback set on the props object.
		 * @param allowCancel indicates if the user can close the dialog.
     * Should be set to true when login is not required.
		 * @param cancelCallback function for when the user clicks cancel,
     * takes no arguments. This param is not required if cancel is not allowed.
		 * @param fontName Custom embedded font's name (must be embedded beforehand)
		 */
    //public function createUserLoginDialog(
            //props : ICgsUserProperties, loginCallback : Dynamic, allowCancel : Bool = true,
            //cancelCallback : Dynamic = null, fontName : String = FONT_DEFAULT) : LoginPopup
    //{
        //props.useHttps = _useHttps;
        //if (_requestHandler != null)
        //{
            //_requestHandler.delayRequestListener = props.cacheActionForLaterCallback;
        //}
        //
        //return new LoginPopup(
        //this, props, loginCallback, cancelCallback, allowCancel, fontName);
    //}
    
    /**
     * Create a tos acceptance dialog that can be used to show and handle
     * user's acceptance of terms of service. The Ui element will handle
     * saving terms of service for the user.
     *
     * @param user the user for which terms of service Ui is being created.
     * @param gameName the name being displayed in the Ui.
     * @param callback function called when TosUi should be removed from displaylist.
     * @param requireTos indicates if the user will be required to accept the tos.
     * @param witdh the available width for the Tos Ui.
     * @param height the available height for the Tos Ui.
     * @param fontName the name of the font to be used. The default font has already
     * been embedded. Custom fonts will need to be embedded before use.
     */
    //public function createUserTosUi(
            //user : ICgsUser, gameName : String, callback : Dynamic9,
            //requireTos : Bool = false, width : Float = 800,
            //height : Float = 600, fontName : String = TOS_FONT_DEFAULT) : TosUi
    //{
        //return new TosUi(user, user.tosStatus, 
        //callback, gameName, requireTos, width, height, fontName);
    //}
    
    /**
     * Register a default variable value to be used for all user ab tests.
     * Variable values can be accessed via the CgsUser instance.
     *
     * @param name the name of the variable. This must match name of variable
     * specified on server.
     * @param value the default value of the variable with the given name.
     */
    public function registerDefaultAbVariable(name : String, value : Dynamic) : Void
    {
        _abTestingProperties.registerDefaultVariable(name, value);
    }
    
    /**
     * Create a copilot api that can be used to control game and log data relating to the copilot.
     * 
     * @param cgsProps the properties used to setup logging for a user.
     * @param copilotProps the properties used to setup the copilot service.
     * @param factory used to create options objects. Custom class can be provided
     * to support different options for different games if concrete functions
     * are desired otherwise getProperty can be used on all options objects.
     */
    public function createCopilotService(
            cgsProps : ICgsUserProperties, copilotProps : CgsCopilotProperties) : CopilotService
    {
        cgsProps.useHttps = _useHttps;
        var copilot : CopilotService = new CopilotService(this, cgsProps, copilotProps);
        
        return copilot;
    }
    
    //
    // Log serialization.
    //
    
    /**
     * 
     */
    private function get_requestsObjectData() : Dynamic
    {
        return _requestHandler.objectData;
    }
}
