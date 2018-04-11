package cgs.user;

import cgs.user.ICgsUser.AuthenticationCallback;
import haxe.Constraints.Function;
import cgs.cache.ICGSCache;
import cgs.achievement.ICgsAchievementManager;
import cgs.homeplays.data.UserHomeplaysData;
import cgs.logger.Logger;
import cgs.server.abtesting.IUserAbTester;
import cgs.server.abtesting.IVariableProvider;
import cgs.server.data.IUserTosStatus;
import cgs.server.logging.ICgsServerApi;
import cgs.server.logging.IMultiplayerLoggingService;
import cgs.server.logging.QuestActionLogContext;
import cgs.server.logging.QuestLogContext;
import cgs.server.logging.actions.QuestAction;
import cgs.server.logging.actions.UserAction;
import cgs.server.logging.messages.UserFeedbackMessage;
import cgs.server.logging.quests.QuestLogger;
import cgs.server.logging.requests.RequestDependency;
import cgs.server.responses.CgsResponseStatus;
import cgs.server.responses.CgsUserResponse;
import cgs.server.responses.HomeplayResponse;
import cgs.teacherportal.IActivityLogger;
import cgs.teacherportal.data.QuestPerformance;

class CgsUser implements ICgsUser
{
    public var lessonId(never, set) : String;
    public var languageCode(get, never) : String;
    public var uidRequestDependency(get, never) : RequestDependency;
    public var isValid(get, never) : Bool;
    public var server(get, never) : ICgsServerApi;
    public var userId(get, never) : String;
    public var isUidValid(get, never) : Bool;
    public var username(get, never) : String;
    public var sessionId(get, never) : String;
    public var conditionId(get, set) : Int;
    public var userPlayCount(get, never) : Int;
    public var userPreviousPlayCount(get, never) : Int;
    public var activityLogger(get, never) : IActivityLogger;
    public var tosRequired(get, never) : Bool;
    public var tosStatus(get, never) : IUserTosStatus;
    public var defaultVariableProvider(never, set) : IVariableProvider;
    public var size(get, never) : Int;
    public var gameQuestId(never, set) : Int;

    //Used to communicate with the cgs servers.
    private var _server : ICgsServerApi;
    
    private var _cache : ICGSCache;
    
    private var _abTester : IUserAbTester;
    
    private var _achievementManager : ICgsAchievementManager;
    
    //Flags that indicate the current state of the user.
    private var _initialized : Bool;
    private var _initializing : Bool;
    
    private var _username : String;
    private var _defaultUserName : String;
    private var _password : String;
    private var _authToken : String;
    
    //Homeplays for the user if they have any.
    private var _homeplays : UserHomeplaysData;
    
    //Service used to handle multiplayer logging.
    private var _multiplayerService : IMultiplayerLoggingService;
    
    private var _lanCode : String;
    
    public function new(
            server : ICgsServerApi, cache : ICGSCache = null,
            abTester : IUserAbTester = null, achieveManager : ICgsAchievementManager = null)
    {
        _server = server;
        _abTester = abTester;
        _cache = cache;
        _achievementManager = achieveManager;
    }
    
    private function set_lessonId(id : String) : String
    {
        //Update the lesson id in the cgs server.
        _server.lessonId = id;
        return id;
    }
    
    private function get_languageCode() : String
    {
        return _lanCode;
    }
    
    /**
		 * Initializes the user with an anonymous user id.
		 *
		 * @param props
		 */
    public function initializeAnonymousUser(props : ICgsUserProperties) : Void
    {
        if (!canInitialize())
        {
            return;
        }
        
        _lanCode = props.languageCode;
        
        //Set a default username if set username is null.
        _defaultUserName = props.defaultUsername;
        
        var userCallback : CgsUserResponse->Void = props.completeCallback;
        _server.initializeUser(this, props, 
                function(userResponse : CgsUserResponse) : Void
                {
                    _initializing = false;
                    _initialized = !userResponse.failed;
                    if (userCallback != null)
                    {
                        Logger.log("Flash: User Initialization Complete");
                        userCallback(userResponse);
                    }
                }
        );
    }
    
    public function isUserAuthenticated(
            props : ICgsUserProperties, callback : Void->Void = null) : Void
    {
        initAuthUser(props, null, null, null, _server.isAuthenticated, callback);
    }
    
    /**
		 * Initialize the user with the given credentials.
		 *
		 * @param props
		 * @param username
		 * @param password
		 * @param callback
		 */
    public function initializeAuthenticatedUser(
            props : ICgsUserProperties, username : String,
            password : String, callback : Void->Void = null) : Void
    {
        initAuthUser(props, username, password, null, _server.authenticateUser, callback);
    }
    
    /**
     * Initialize a student with the given credentials.
     *
     * @param props
     * @param username
     * @param teacherCode
     * @param callback
     */
    public function initializeAuthenticatedStudent(
            props : ICgsUserProperties, username : String,
            teacherCode : String, password : String,
            gradeLevel : Int = 0, callback : Void->Void = null) : Void
    {
        initAuthUser(
                props, username, password, teacherCode, 
                _server.authenticateStudent, callback, [gradeLevel]);
    }
    
    private function initAuthUser(
            props : ICgsUserProperties, username : String,
            password : String, authToken : String,
            authFunction : Dynamic, callback : Void->Void, args : Array<Dynamic> = null) : Void
    {
        if (!canInitialize())
        {
            return;
        }
        
        _lanCode = props.languageCode;
        
        _server.setupUserProperties(this, props);
        
        var fullArgs : Array<Dynamic> = [username, password, authToken, authFunction, callback];
        
		if (args != null)
		{
			for (arg in args)
			{
				fullArgs.push(arg);
			}
		}
        
        //Called like this so args is not passed as a 2D array.
        //handleAuthentication.apply(null, fullArgs);
		Reflect.callMethod(this, handleAuthentication, args);
    }
    
    /**
     * Register the user with the given credentials.
     *
     * @param props
     * @param username
     * @param password
     * @param email not required.
     * @param callback
     */
    public function registerUser(
            props : ICgsUserProperties, username : String,
            password : String, email : String, callback : CgsUserResponse->Void) : Void
    {
        if (!canInitialize())
        {
            return;
        }
        
        _initializing = true;
        
        _server.setupUserProperties(this, props);
        
        _server.registerUser(
                username, password, email, 
                function(userResponse : CgsUserResponse) : Void
                {
                    _initializing = false;
                    _initialized = userResponse.success;
                    
                    if (userResponse.success)
                    {
                        _username = username;
                        _password = password;
                    }
                    
                    if (callback != null)
                    {
                        callback(userResponse);
                    }
                }
        );
    }
    
    public function createAccount(
            username : String,
            password : String,
            email : String,
            grade : Int,
            gender : Int,
            teacherCode : String,
            callback : Dynamic,
            externalId : String = null,
            externalSourceId : Int = -1) : Void
    {
        if (_username != null)
        {
            callback(new CgsResponseStatus());
        }
        
        _server.registerUserWithUid(
                username, password, email, 
                grade, gender, teacherCode, 
                function(response : CgsResponseStatus) : Void
                {
                    if (response.success)
                    {
                        _username = username;
                        _password = password;
                    }
                    
                    if (callback != null)
                    {
                        callback(response);
                    }
                }, 
                externalId, 
                externalSourceId
        );
    }
    
    private function get_uidRequestDependency() : RequestDependency
    {
        return _server.uidRequestDependency;
    }
    
    public function checkUserNameAvailable(name : String, userCallback : Dynamic) : Void
    {
        _server.checkUserNameAvailable(name, userCallback);
    }
    
    /**
     * @inheritDoc
     */
    public function registerStudent(props : ICgsUserProperties,
            username : String,
            teacherCode : String,
            grade : Int,
            gender : Int,
            callback : Dynamic) : Void
    {
        if (!canInitialize())
        {
            return;
        }
        
        _initializing = true;
        
        _server.setupUserProperties(this, props);
        
        _server.registerStudent(username, 
                teacherCode, 
                grade, 
                function(userResponse : CgsUserResponse) : Void
                {
                    _initializing = false;
                    _initialized = userResponse.success;
                    
                    if (userResponse.success)
                    {
                        _username = username;
                    }
                    
                    if (callback != null)
                    {
                        callback(userResponse);
                    }
                }, 
                gender
        );
    }
    
    /**
     * @inheritDoc
     */
    public function updateStudent(username : String,
            teacherCode : String,
            gradeLevel : Int,
            gender : Int,
            callback : Dynamic) : Void
    {
        _server.updateStudent(username, teacherCode, gradeLevel, gender, callback);
    }
    
    /**
		 * Try re-initializing the user with the new credentials.
		 *
		 * @param username
		 * @param password
		 * @param callback
		 */
    public function retryAuthentication(username : String,
            password : String, callback : AuthenticationCallback = null) : Void
    {
        handleAuthentication(username, password, null, _server.authenticateUser, callback);
    }
    
    public function retryUserRegistration(
            cgsUser : ICgsUser, name : String,
            password : String, email : String, callback : Function) : Void
    {
        if (!canInitialize())
        {
            return;
        }
    }
    
    /**
     * Try to initialize the user with new credentials.
     *
     * @param username
		 * @param teacherCode
		 * @param callback
     */
    public function retryStudentAuthentication(
            username : String, teacherCode : String,
            password : String = null, gradeLevel : Int = 0, callback : AuthenticationCallback = null) : Void
    {
        handleAuthentication(username, password, teacherCode, _server.authenticateStudent, callback, [gradeLevel]);
    }
    
    //Generic function to handle user authentication.
    //Auth functions must have the following
    //signature: auth(username:String, password:String, callback:Function):void
    private function handleAuthentication(
            username : String, password : String, authToken : String,
            authFunction : Dynamic, callback : AuthenticationCallback, args : Array<Dynamic> = null) : Void
    {
        if (!canInitialize())
        {
            return;
        }
        
        _initializing = true;
        
        _username = username;
        _password = password;
        _authToken = authToken;
        
        var localCallback : AuthenticationCallback = function(response : CgsUserResponse) : Void
        {
            handleUserAuth(response, callback);
        }
        
        if (username == null || (password == null && authToken == null))
        {
            authFunction(localCallback);
        }
        else
        {
            if (args.length > 0)
            {
                var fullArgs : Array<Dynamic> = [username, password, authToken];
                for (arg in args)
                {
                    fullArgs.push(arg);
                }
                fullArgs.push(localCallback);
                
                Reflect.callMethod(null, authFunction, fullArgs);
            }
            else
            {
                authFunction(username, password, authToken, localCallback);
            }
        }
    }
    
    private function handleUserAuth(userResponse : CgsUserResponse, callback : AuthenticationCallback) : Void
    {
        _initializing = false;
        _initialized = userResponse.success;
        
        //Get and set the homeplays data.
        var homeplays : HomeplayResponse = userResponse.homeplaysResponse;
        if (homeplays != null)
        {
            _homeplays = homeplays.homeplays;
        }
        
        if (callback != null)
        {
            callback(userResponse);
        }
    }
    
    private function canInitialize() : Bool
    {
        return !_initialized && !_initializing;
    }
    
    private function get_isValid() : Bool
    {
        return true;
    }
    
    private function get_server() : ICgsServerApi
    {
        return _server;
    }
    
    private function get_userId() : String
    {
        return _server.uid;
    }
    
    private function get_isUidValid() : Bool
    {
        return _server.isUidValid;
    }
    
    private function get_username() : String
    {
        return (_username == null) ? _defaultUserName : _username;
    }
    
    private function get_sessionId() : String
    {
        return _server.sessionId;
    }
    
    private function get_conditionId() : Int
    {
        return _server.conditionId;
    }
    
    private function set_conditionId(value : Int) : Int
    {
        _server.conditionId = value;
        return value;
    }
    
    /**
     * Get the number of times the user has played the game based on pageloads.
     * Includes the current pageload of session.
     */
    private function get_userPlayCount() : Int
    {
        return _server.userPlayCount;
    }
    
    /**
     * Get the number of times the user has played the game based on pageloads.
     * Does not include the pageload of the current session.
     */
    private function get_userPreviousPlayCount() : Int
    {
        return _server.userPlayCount - 1;
    }
    
    //
    // Quest Logging interface functions.
    //
    
    /**
		 * @inheritDoc
		 */
    public function logMultiplayerQuestStart(
            questId : Int, questHash : String, details : Dynamic,
            callback : Dynamic = null, localDqid : Int = -1) : Int
    {
        var request : QuestLogContext = 
        _server.createMultiplayerQuestStartRequest(questId, questHash, details, null, -1, callback, null, localDqid);
        
        handleQuestDependencies(request);
        
        request.sendRequest();
        
        return request.localDqid;
    }
    
    /**
     * @inheritDoc
     */
    public function logMultiplayerQuestEnd(details : Dynamic, callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        var request : QuestLogContext = 
        _server.createMultiplayerQuestEndRequest(details, null, -1, callback, localDqid);
        
        handleQuestDependencies(request);
        request.sendRequest();
    }
    
    private function handleQuestDependencies(request : QuestLogContext) : Void
    {
        var multiSeqId : Int = -1;
        var parentDqid : String = null;
        if (_multiplayerService != null)
        {
            multiSeqId = _multiplayerService.nextMultiplayerSequenceId(
                            function(seqId : Int) : Void
                            {
                                multiSeqId = seqId;
                                request.setPropertyValue(QuestLogContext.MULTIPLAYER_SEQUENCE_ID_KEY, multiSeqId);
                            }
                );
            
            if (multiSeqId < 0)
            {
                request.addPropertyDependcy(QuestLogContext.MULTIPLAYER_SEQUENCE_ID_KEY);
            }
            else
            {
                request.setPropertyValue(QuestLogContext.MULTIPLAYER_SEQUENCE_ID_KEY, multiSeqId);
            }
            
            if (_multiplayerService.isDqidValid)
            {
                parentDqid = _multiplayerService.dqid;
                request.setPropertyValue(QuestLogContext.PARENT_DQID_KEY, parentDqid);
            }
            else
            {
                if (_multiplayerService.isRemoteService)
                {
                    request.addPropertyDependcy(QuestLogContext.PARENT_DQID_KEY);
                }
                else
                {
                    request.addRequestDependencyById(_multiplayerService.dqidRequestId, true);
                }
                
                _multiplayerService.addDqidValidCallback(function(dqid : String) : Void
                        {
                            request.setPropertyValue(QuestLogContext.PARENT_DQID_KEY, dqid);
                        });
            }
        }
    }
    
    public function createQuestPerformance(localDqid : Int = -1) : QuestPerformance
    {
        return new QuestPerformance(this, _server.getQuestLogger(localDqid));
    }
    
    /**
		 * @inheritDoc
		 */
    public function logQuestStartWithDqid(
            questId : Int, questHash : String, dqid : String,
            details : Dynamic, localDqid : Int = -1) : Int
    {
        return _server.logQuestStartWithDQID(
                questId, questHash, dqid, details, null, localDqid);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logQuestStart(
            questId : Int, questHash : String, details : Dynamic,
            callback : Dynamic = null, localDqid : Int = -1) : Int
    {
        return _server.logQuestStart(questId, questHash, details, callback, null, localDqid);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logMultiplayerQuestAction(
            action : QuestAction, localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        localMultiplayerLogQuestAction(action, null, localDqid, forceFlush);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logServerMultiplayerQuestAction(
            action : QuestAction, multiUid : String,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        localMultiplayerLogQuestAction(action, multiUid, localDqid, forceFlush);
    }
    
    private function localMultiplayerLogQuestAction(
            action : QuestAction, multiUid : String,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        if (multiUid != null)
        {
            action.setMultiplayerUid(multiUid);
        }
        
        var actionLog : QuestActionLogContext = new QuestActionLogContext(action);
        
        var multiSeqId : Int = -1;
        if (_multiplayerService != null)
        {
            multiSeqId = _multiplayerService.nextMultiplayerSequenceId(
                            function(seqId : Int) : Void
                            {
                                actionLog.setPropertyValue(QuestActionLogContext.MULTIPLAYER_SEQUENCE_ID_KEY, seqId);
                            }
                );
            
            if (multiSeqId < 0)
            {
                actionLog.addPropertyDependcy(QuestActionLogContext.MULTIPLAYER_SEQUENCE_ID_KEY);
            }
            else
            {
                actionLog.setPropertyValue(QuestActionLogContext.MULTIPLAYER_SEQUENCE_ID_KEY, multiSeqId);
            }
        }
        
        _server.logQuestActionData(actionLog, localDqid, forceFlush);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logQuestAction(action : QuestAction,
            localDqid : Int = -1, forceFlush : Bool = false) : Void
    {
        _server.logQuestAction(action, localDqid, forceFlush);
    }
    
    /**
		 * @inheritDoc
		 */
    public function flushActions(localDqid : Int = -1, callback : Dynamic = null) : Void
    {
        _server.flushActions(localDqid, callback);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logQuestScore(
            score : Int, callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        _server.logQuestScore(score, callback, localDqid);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logQuestEnd(
            details : Dynamic, callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        _server.logQuestEnd(details, callback, localDqid);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logForeignQuestStart(
            dqid : String, foreignGameId : Int, foreignCategoryId : Int,
            foreignVersionId : Int, foreignConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null) : Void
    {
        _server.logForeignQuestStart(dqid, foreignGameId, foreignCategoryId, foreignVersionId, foreignConditionId, details, callback);
    }
    
    /**
     * @inheritDoc
     */
    public function logLinkedQuestStart(
            questId : Int, questHash : String, linkGameId : Int,
            linkCategoryId : Int, linkVersionId : Int, linkConditionId : Int = 0,
            details : Dynamic = null, callback : Dynamic = null) : Int
    {
        return _server.logLinkedQuestStart(
                questId, questHash, linkGameId, linkCategoryId, 
                linkVersionId, linkConditionId, details, callback
        );
    }
    
    /**
		 * @inheritDoc
		 */
    public function submitFeedback(feedback : UserFeedbackMessage, callback : Dynamic = null) : Void
    {
        _server.submitUserFeedback(feedback, callback);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logScore(score : Int, questId : Int, callback : Dynamic = null) : Void
    {
        _server.logScore(score, questId, callback);
    }
    
    /**
		 * @inheritDoc
		 */
    public function logMultiplayerAction(action : UserAction, callback : Dynamic = null) : Void
    {
        var multiSeqId : Int = -1;
        if (_multiplayerService != null)
        {
        }
        
        _server.logMultiplayerAction(action, multiSeqId, callback);
    }
    
    /**
		 * @inheritDoc
		 
		public function logServerMultiplayerAction(
    action:UserAction, multiSeqId:int,
    multiUid:String, callback:Function = null):void
		{
			_server.logServerMultiplayerAction(action, multiSeqId, multiUid, callback);
		}*/
    
    /**
		 * @inheritDoc
		 */
    public function logAction(action : UserAction, callback : Dynamic = null) : Void
    {
        _server.logActionNoQuest(action, callback);
    }
    
    //
    // Copilot Logging interface functions.
    //
    
    private var _activityLogger : IActivityLogger = null;
    
    private function get_activityLogger() : IActivityLogger
    {
        return (_activityLogger);
    }
    
    // This is called by the CopilotService
    public function setActivityLogger(logger : IActivityLogger) : Void
    {
        _activityLogger = logger;
    }
    
    // This is called by the CopilotService
    public function clearActivityLogger() : Void
    {
        _activityLogger = null;
    }
    
    /**
		 *  @inheritDoc
		 */
    public function logProblemSetStart(problemSetGuid : String, problemCount : Int = -1, details : Dynamic = null) : Void
    {
        //delegate to activityLogger if it exists
        if (_activityLogger != null)
        {
            _activityLogger.logProblemSetStart(this.userId, problemSetGuid, problemCount, details);
        }
    }
    
    /**
		 *  @inheritDoc
		 */
    public function logProblemSetEnd(details : Dynamic = null) : Void
    {
        //delegate to activityLogger if it exists
        if (_activityLogger != null)
        {
            _activityLogger.logProblemSetEnd(this.userId, details);
        }
    }
    
    /**
		 *  @inheritDoc
		 */
    public function logProblemResult(result : Float, problemPartList : Array<Dynamic> = null, problemData : Dynamic = null, details : Dynamic = null) : Void
    {
        //delegate to activityLogger if it exists
        if (_activityLogger != null)
        {
            _activityLogger.logProblemResult(this.userId, result, problemPartList, problemData, details);
        }
    }
    
    //
    // Multiplayer logging handling.
    //
    
    public function setMultiplayerService(service : IMultiplayerLoggingService) : Void
    {
        _multiplayerService = service;
    }
    
    //
    // Homeplays handling.
    //
    
    public function logHomeplayQuestStart(
            questId : Int, questHash : String, questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic, callback : Dynamic = null, localDqid : Int = -1) : Int
    {
        return _server.logHomeplayQuestStart(
                questId, questHash, questDetails, 
                homeplayId, homeplayDetails, localDqid, callback
        );
    }
    
    public function logHomeplayQuestComplete(
            questDetails : Dynamic, homeplayId : String,
            homeplayDetails : Dynamic = null, homeplayCompleted : Bool = false,
            callback : Dynamic = null, localDqid : Int = -1) : Void
    {
        _server.logHomeplayQuestComplete(
                questDetails, homeplayId, 
                homeplayDetails, homeplayCompleted, localDqid, callback
        );
    }
    
    public function retrieveUserAssignments() : UserHomeplaysData
    {
        return _homeplays;
    }
    
    //
    // Dqid dependency handling.
    //
    
    public function isDqidValid(localDqid : Int = -1) : Bool
    {
        return _server.isDqidValid(localDqid);
    }
    
    public function getDqid(localDqid : Int = -1) : String
    {
        return _server.getDqid(localDqid);
    }
    
    public function getQuestId(localDqid : Int = -1) : Int
    {
        var questId : Int = -1;
        var logger : QuestLogger = _server.getQuestLogger(localDqid);
        if (logger != null)
        {
            questId = logger.getQuestId();
        }
        
        return questId;
    }
    
    public function getDqidRequestId(localDqid : Int = -1) : Int
    {
        return _server.getDqidRequestId(localDqid);
    }
    
    public function addDqidCallback(callback : Dynamic, localDqid : Int = -1) : Void
    {
        _server.addDqidCallback(callback, localDqid);
    }
    
    //
    // Tos handling.
    //
    
    private function get_tosRequired() : Bool
    {
        return _server.userTosRequired();
    }
    
    private function get_tosStatus() : IUserTosStatus
    {
        return _server.userTosStatus;
    }
    
    public function updateTosStatus(
            status : IUserTosStatus, callback : Dynamic = null) : Void
    {
        _server.updateUserTosStatus(status, callback);
    }
    
    //
    // Ab testing interface functions.
    //
    
    /*public function loadTestConditions(
    callback:Function, existing:Bool = false):void
		{
			if(_abTester == null) return;

			_abTester.loadTestConditions(callback, existing);
		}*/
    
    public function registerDefaultValue(
            varName : String, value : Dynamic, valueType : Int) : Void
    {
        if (_abTester == null)
        {
            return;
        }
        
        _abTester.registerDefaultValue(varName, value, valueType);
    }
    
    public function getVariableValue(varName : String) : Dynamic
    {
        if (_abTester == null)
        {
            return null;
        }
        
        return _abTester.getVariableValue(varName);
    }
    
    public function overrideVariableValue(varName : String, value : Dynamic) : Void
    {
        if (_abTester == null)
        {
            return;
        }
        
        _abTester.overrideVariableValue(varName, value);
    }
    
    public function variableTested(varName : String, results : Dynamic = null) : Void
    {
        if (_abTester == null)
        {
            return;
        }
        
        _abTester.variableTested(varName, results);
    }
    
    public function startVariableTesting(
            varName : String, startData : Dynamic = null) : Void
    {
        if (_abTester == null)
        {
            return;
        }
        
        _abTester.startVariableTesting(varName, startData);
    }
    
    public function endVariableTesting(varName : String, results : Dynamic = null) : Void
    {
        if (_abTester == null)
        {
            return;
        }
        
        _abTester.endVariableTesting(varName, results);
    }
    
    public function startTimedVariableTesting(
            varName : String, startData : Dynamic = null) : Void
    {
        if (_abTester == null)
        {
            return;
        }
        
        _abTester.startTimedVariableTesting(varName, startData);
    }
    
    /**
		 * Get the condition id for the user. If the user is in multiple conditions
		 * this will return the first condition id.
     * Will return -1 if no condition id for user.
		 */
    public function getUserConditionId() : Int
    {
        if (_abTester == null)
        {
            return -1;
        }
        
        return _abTester.getUserConditionId();
    }
    
    private function set_defaultVariableProvider(value : IVariableProvider) : IVariableProvider
    {
        if (_abTester == null)
        {
            return value;
        }
        
        _abTester.defaultVariableProvider = value;
        return value;
    }
    
    //
    // Cache interface functions.
    //
    
    /**
		 * @inheritDoc
		 */
    private function get_size() : Int
    {
        if (_cache == null)
        {
            return 0;
        }
        
        return _cache.size;
    }
    
    /**
		 * @inheritDoc
		 */
    public function clearCache() : Void
    {
        if (_cache == null)
        {
            return;
        }
        
        _cache.clearCache(userId);
    }
    
    /**
		 * @inheritDoc
		 */
    public function deleteSave(property : String) : Void
    {
        if (_cache == null)
        {
            return;
        }
        
        _cache.deleteSave(property, userId);
    }
    
    /**
		 * @inheritDoc
		 */
    public function flush(callback : Dynamic = null) : Bool
    {
        if (_cache == null)
        {
            return false;
        }
        
        return _cache.flush(userId, callback);
    }
    
    /**
		 * @inheritDoc
		 */
    public function registerSaveCallback(property : String, callback : Dynamic) : Void
    {
        if (_cache == null)
        {
            return;
        }
        
        _cache.registerSaveCallback(property, callback);
    }
    
    /**
		 * @inheritDoc
		 */
    public function unregisterSaveCallback(property : String) : Void
    {
        if (_cache == null)
        {
            return;
        }
        
        _cache.unregisterSaveCallback(property);
    }
    
    /**
		 * @inheritDoc
		 */
    public function getSave(property : String) : Dynamic
    {
        if (_cache == null)
        {
            return null;
        }
        
        return _cache.getSave(property, userId);
    }
    
    /**
		 * @inheritDoc
		 */
    public function initSave(
            property : String, defaultVal : Dynamic, flush : Bool = true) : Void
    {
        if (_cache == null)
        {
            return;
        }
        
        _cache.initSave(property, defaultVal, userId, flush);
    }
    
    /**
		 * @inheritDoc
		 */
    public function saveExists(property : String) : Bool
    {
        if (_cache == null)
        {
            return false;
        }
        
        return _cache.saveExists(property, userId);
    }
    
    /**
		 * @inheritDoc
		 */
    public function setSave(property : String, val : Dynamic, flush : Bool = true) : Bool
    {
        if (_cache == null)
        {
            return false;
        }
        
        return _cache.setSave(property, val, userId, flush);
    }
    
    //
    // Properties handling.
    //
    
    private function set_gameQuestId(value : Int) : Int
    {  //TODO - Needs to be updated to handle refraction  
        
        return value;
    }
    
    /**
		 * 
		 * Achievement Manager Functions
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function initAchievement(achievement : String, startStatus : Bool = false) : Bool
    {
        var result : Bool = false;
        if (_achievementManager != null)
        {
            result = _achievementManager.initAchievement(achievement, startStatus);
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getAchievementStatus(achievement : String) : Bool
    {
        var result : Bool = false;
        if (_achievementManager != null)
        {
            result = _achievementManager.getAchievementStatus(achievement);
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function setAchievementStatus(achievement : String, status : Bool) : Bool
    {
        var result : Bool = false;
        if (_achievementManager != null)
        {
            result = _achievementManager.setAchievementStatus(achievement, status);
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function achievementExists(achievement : String) : Bool
    {
        var result : Bool = false;
        if (_achievementManager != null)
        {
            result = _achievementManager.achievementExists(achievement);
        }
        return result;
    }
    
    //
    // Javascript interface handling.
    //
    
    /**
     * @inheritDoc
     */
    public function flushServerRequests() : Bool
    {
        var hasRequests : Bool = false;
        if (_cache != null)
        {
            hasRequests = _cache.hasUnsavedServerData(userId);
            _cache.flushForAll();
        }
        if (_server.hasPendingLogs)
        {  //TODO - Flush the logs.  
            
        }
        
        return hasRequests;
    }
}
