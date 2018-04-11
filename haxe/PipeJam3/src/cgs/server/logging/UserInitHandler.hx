package cgs.server.logging;

import haxe.Constraints.Function;
import flash.utils.Timer;
import cgs.cache.ICGSCache;
import cgs.logger.Logger;
import cgs.server.abtesting.IUserAbTester;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.CgsUserResponse;
import cgs.server.responses.GameUserDataResponseStatus;
import cgs.server.responses.HomeplayResponse;
import cgs.server.responses.TosResponseStatus;
import cgs.server.responses.UidResponseStatus;
import cgs.user.ICgsUserProperties;
import cgs.user.ICgsCacheServerApi;
import cgs.user.ICgsUser;

/**
	 * Handles making request for user setup data and associated callbacks. This class
	 * also handles resent requests.
	 */
class UserInitHandler implements IUserInitializationHandler
{
    public var gradeLevel(never, set) : Int;
    public var sessionRequestId(get, never) : Int;
    public var uidRequestId(get, never) : Int;
    public var completeCallback(get, set) : Function;
    public var timeValidCallback(never, set) : Function;
    public var failed(get, never) : Bool;
    public var uidValid(get, never) : Bool;
    public var sessionValid(get, never) : Bool;
    private var loadTosStatus(get, never) : Bool;
    private var tosStatusLoaded(get, never) : Bool;
    private var homeplaysLoaded(get, never) : Bool;
    public var loadHomeplays(get, never) : Bool;
    public var homeplayResponse(get, never) : HomeplayResponse;

    //Contains all of the server response information for initialization.
    private var _userResponseStatus : CgsUserResponse;
    private var _user : ICgsUser;
    
    private var _sessionRequestId : Int;
    private var _uidRequestId : Int;
    
    private var _server : ICgsServerApi;
    
    //Timeout for user authentication. There is only a timeout for initialization if
    //data is being requested from the server.
    private var _timeoutMs : Float = 30000;
    
    private var _serverTimeLoaded : Bool;
    private var _initTimestamp : Float;
    
    private var _serverApi : ICgsCacheServerApi;
    
    private var _authUser : Bool;
    private var _uid : String;
    private var _uidLoaded : Bool;
    private var _uidLoadFailed : Bool;
    private var _uidResponse : UidResponseStatus;
    
    private var _logPageLoad : Bool;
    private var _pageloadLogged : Bool;
    private var _pageloadFailed : Bool;
    private var _pageloadResponse : CgsResponseStatus;
    
    //Homeplays loading.
    private var _loadHomeplays : Bool;
    private var _homeplaysResponse : HomeplayResponse;
    
    //Ab testing options.
    private var _abTester : IUserAbTester;
    private var _abTestsCompleteCallback : Function;
    private var _loadAbTests : Bool;
    private var _existingAbTestsOnly : Bool;
    private var _abTestsResponse : CgsResponseStatus;
    
    //Flags indicating the state of ab test loading.
    private var _abTestsLoaded : Bool;
    private var _abTestsLoadFailed : Bool;
    
    private var _loadUserData : Bool;
    private var _userDataLoaded : Bool;
    private var _userDataLoadFailed : Bool;
    private var _cgsCache : ICGSCache;
    private var _userDataResponse : GameUserDataResponseStatus;
    
    private var _pageloadDetails : Dynamic;
    
    private var _cacheUid : Bool;
    private var _forceUid : String;
    
    private var _userAuthStatus : CgsResponseStatus;
    
    //Called when the uid is valid.
    private var _uidCallback : Function;
    
    //Called when the pageload has been made.
    private var _pageloadCallback : Function;
    
    //Called when all user data has been loaded from the server,
    //uid, pageload, data and homeplays.
    private var _completeCallback : Function;
    
    private var _timeValidCallback : Function;
    
    //TODO - Timeouts should be added to the request handler.
    //Timer used to handle timeouts of uid/pageloads/data loading.
    private var _timer : Timer;
    
    private var _userTosType : String;
    private var _userTosExempt : Bool;
    private var _languageCode : String;
    private var _tosResponseStatus : TosResponseStatus;
    private var _tosServerVersion : Int;
    
    private var _gradeLevel : Int;
    private var _gradeLevelSet : Bool;
    
    private var _serverCacheVersion : Int;
    private var _cacheSaveKey : String;
    
    public function new(
            cgsUser : ICgsUser, props : ICgsUserProperties,
            serverApi : ICgsCacheServerApi = null)
    {
        _user = cgsUser;
        
        _uidCallback = props.uidValidCallback;
        _pageloadCallback = props.pageLoadCallback;
        _completeCallback = props.completeCallback;
        _logPageLoad = props.logPageLoad;
        _pageloadDetails = props.pageLoadDetails;
        _loadUserData = props.saveCacheDataToServer;
        _cgsCache = props.cgsCache;
        
        _cacheUid = props.cacheUid;
        _forceUid = props.forceUid;
        
        _abTester = props.abTester;
        _loadAbTests = props.loadAbTests;
        
        _userTosType = props.tosKey;
        _userTosExempt = props.tosExempt;
        _languageCode = props.languageCode;
        _tosServerVersion = props.tosServerVersion;
        
        _existingAbTestsOnly = props.loadExistingAbTests;
        
        _loadHomeplays = props.loadHomeplays;
        
        _serverApi = serverApi;
        
        _serverCacheVersion = props.serverCacheVersion;
        _cacheSaveKey = props.cacheSaveKey;
    }
    
    private function set_gradeLevel(value : Int) : Int
    {
        if (value != 0)
        {
            _gradeLevel = value;
            _gradeLevelSet = true;
        }
        return value;
    }
    
    private function get_sessionRequestId() : Int
    {
        return _sessionRequestId;
    }
    
    private function get_uidRequestId() : Int
    {
        return _uidRequestId;
    }
    
    private function get_completeCallback() : Function
    {
        return _completeCallback;
    }
    
    private function set_completeCallback(value : Function) : Function
    {
        _completeCallback = value;
        return value;
    }
    
    private function set_timeValidCallback(callback : Function) : Function
    {
        _timeValidCallback = callback;
        return callback;
    }
    
    private function get_failed() : Bool
    {
        var homeplaysFailed : Bool = 
        (_homeplaysResponse != null) ? _homeplaysResponse.failed : false;
        
        return _uidLoadFailed || _pageloadFailed ||
        _userDataLoadFailed || _abTestsLoadFailed || homeplaysFailed;
    }
    
    /**
		 * Initialize anonymous user.
		 */
    public function initiliazeUserData(server : ICgsServerApi) : Void
    {
        _server = server;
        _initTimestamp = Math.round(haxe.Timer.stamp() * 1000);
        
        _uidRequestId = server.requestUid(
                        function(response : UidResponseStatus) : Void
                        {
                            Logger.log("Flash: User Uid Loaded, " + response.uid);
                            
                            _uidResponse = response;
                            _uidLoadFailed = response.failed;
                            if (_uidLoadFailed)
                            {  //TODO - Make up a uid?  
                                
                            }
                            
                            _uid = response.uid;
                            _uidLoaded = true;
                            if (_uidCallback != null)
                            {
                                _uidCallback(response.uid, response.failed);
                            }
                            
                            testCompleted();
                        }, _cacheUid, _forceUid
            );
        
        makeInitLoggingCalls();
    }
    
    /**
		 * Indicates if a valid uid has been loaded from the server.
		 */
    private function get_uidValid() : Bool
    {
        return _uidLoaded && !_uidLoadFailed;
    }
    
    private function get_sessionValid() : Bool
    {
        return _pageloadLogged && !_pageloadFailed;
    }
    
    public function isAuthenticated(
            serverAuthFunction : Function, server : ICgsServerApi,
            completeCallback : Function, saveCacheDataToServer : Bool = true) : Void
    {
        handleAuthUser(
                serverAuthFunction, server, completeCallback, saveCacheDataToServer
        );
    }
    
    /**
     * Authenticate a user with the cgs server.
     */
    public function authenticateUser(
            name : String, password : String, authKey : String, serverAuthFunction : Function,
            server : ICgsServerApi, completeCallback : Function = null,
            saveCacheDataToServer : Bool = true) : Void
    {
        authenticateUserName(
                name, password, authKey, serverAuthFunction, server, completeCallback
        );
    }
    
    private function handleAuthUser(
            serverAuthFunction : Function, server : ICgsServerApi,
            completeCallback : Function = null, saveCacheDataToServer : Bool = true,
            name : String = null, password : String = null, authKey : String = null) : Void
    {
        _authUser = true;
        
        _server = server;
        _initTimestamp = Math.round(haxe.Timer.stamp() * 1000);
        
        if (completeCallback != null)
        {
            _completeCallback = completeCallback;
        }
        
        if (name == null || (password == null && authKey == null))
        {
            _uidRequestId = serverAuthFunction(handleUserAuthentication);
        }
        else
        {
            if (_gradeLevelSet)
            {
                _uidRequestId = serverAuthFunction(
                                name, password, authKey, handleUserAuthentication, _gradeLevel
                );
                _gradeLevel = 0;
                _gradeLevelSet = false;
            }
            else
            {
                _uidRequestId = serverAuthFunction(
                                name, password, authKey, handleUserAuthentication
                );
            }
        }
    }
    
    private function handleUserAuthentication(status : CgsResponseStatus, uid : String) : Void
    {
        _userAuthStatus = status;
        
        _uid = uid;
        _uidLoaded = true;
        _uidLoadFailed = status.failed;
        
        if (!_uidLoadFailed)
        {
            //Handle the additional logging calls.
            makeInitLoggingCalls();
        }
        
        if (_uidCallback != null)
        {
            _uidCallback(uid, status.failed);
        }
        
        testCompleted();
    }
    
    /**
		 * Authenticate a user with the cgs server.
		 *
     */
    public function authenticateUserName(
            name : String, password : String, authKey : String, serverAuthFunction : Function,
            server : ICgsServerApi, completeCallback : Function = null) : Void
    {
        handleAuthUser(
                serverAuthFunction, server, 
                completeCallback, true, name, password, authKey
        );
    }
    
    private function handleCompleteCallback() : Void
    {
        if (_completeCallback == null)
        {
            return;
        }
        
        //Create the response status object returned via callback.
        var userResponse : CgsUserResponse = new CgsUserResponse(_user);
        
        userResponse.uidResponse = _uidResponse;
        userResponse.authorizationResponse = _userAuthStatus;
        userResponse.pageloadResponse = _pageloadResponse;
        userResponse.abTestingResponse = _abTestsResponse;
        userResponse.dataLoadResponse = _userDataResponse;
        
        _completeCallback(userResponse);
    }
    
    //Make the initial logging calls to the server.
    //Can be handled as part of initialize or user authorization.
    private function makeInitLoggingCalls() : Void
    {
        _server.isServerTimeValid(_timeValidCallback);
        
        if (_logPageLoad)
        {
            _sessionRequestId = _server.logPageLoad(
                            _pageloadDetails, function(response : CgsResponseStatus) : Void
                            {
                                _pageloadResponse = response;
                                _pageloadFailed = response.failed;
                                
                                if (_pageloadFailed)
                                {  //TODO - Make up a session id?  
                                    
                                }
                                
                                _pageloadLogged = true;
                                if (_pageloadCallback != null)
                                {
                                    _pageloadCallback(response);
                                }
                                
                                handlePageLoadComplete();
                                
                                if (_userTosExempt)
                                {
                                    _server.exemptUserFromTos();
                                }
                                
                                Logger.log("Flash: Testing UserInit complete from PageLoad Complete");
                                testCompleted();
                            }
                );
        }
        
        if (_loadUserData)
        {
            // Pick between different backends to handle saving
            if (_serverCacheVersion == 2)
            {
                _server.loadGameSaveData(handleServerDataLoaded, _cacheSaveKey);
            }
            else
            {
                _server.loadGameData(handleServerDataLoaded);
            }
        }
        
        if (loadTosStatus)
        {
            //TODO - Need to add the grade level.
            //Load the tos status for the user.
            _server.loadUserTosStatus(_userTosType, 
                    function(response : TosResponseStatus) : Void
                    {
                        _tosResponseStatus = response;
                        
                        testCompleted();
                    }, _languageCode
            );
        }
        
        if (loadHomeplays)
        {
            _server.retrieveUserAssignments(
                    function(response : HomeplayResponse) : Void
                    {
                        _homeplaysResponse = response;
                        testCompleted();
                    }
            );
        }
    }
    
    private function handleServerDataLoaded(response : GameUserDataResponseStatus) : Void
    {
        _userDataResponse = response;
        _userDataLoadFailed = response.failed;
        
        if (_userDataLoadFailed)
        {  //TODO - Do anything.  
            
        }
        
        _userDataLoaded = true;
        if (_cgsCache != null)
        {
            _cgsCache.registerUser(
                    _uid, _loadUserData, _serverCacheVersion, 
                    response.userGameData, _serverApi, _cacheSaveKey
            );
        }
        
        Logger.log("Flash: Testing UserInit complete from ServerDataLoaded");
        testCompleted();
    }
    
    private function handlePageLoadComplete() : Void
    {
        if (_loadAbTests)
        {
            var playCount : Int = _server.getCurrentGameServerData().userPlayCount;
            var exitingAbTests : Bool = _existingAbTestsOnly && playCount > 1;
            
            _abTester.loadTestConditions(function(response : CgsResponseStatus) : Void
                    {
                        _abTestsLoadFailed = response.failed;
                        _abTestsLoaded = !response.failed;
                        if (_abTestsCompleteCallback != null)
                        {
                            _abTestsCompleteCallback(response.failed);
                        }
                        
                        testCompleted();
                    }, 
                    exitingAbTests
            );
        }
    }
    
    private function get_loadTosStatus() : Bool
    {
        return (!_userTosExempt && _userTosType != null);
    }
    
    private function get_tosStatusLoaded() : Bool
    {
        return _tosResponseStatus != null;
    }
    
    private function get_homeplaysLoaded() : Bool
    {
        return _homeplaysResponse != null;
    }
    
    private function get_loadHomeplays() : Bool
    {
        return _loadHomeplays && _authUser;
    }
    
    private function get_homeplayResponse() : HomeplayResponse
    {
        return _homeplaysResponse;
    }
    
    //Test if the initialization is complete and make the complete callback if so.
    private function testCompleted() : Void
    {
        if (	failed 
			||  (	_uidLoaded 
				&& 	(!_logPageLoad || _pageloadLogged)
				&&  (!_loadUserData || _userDataLoaded) 
				&&  (!loadTosStatus || tosStatusLoaded)
				&&  (!_loadAbTests || _abTestsLoaded)
				&&  (!loadHomeplays || homeplaysLoaded)
			)	)
        {
            Logger.log("Flash: Handling UserInit complete callback");
            handleCompleteCallback();
        }
    }
}
