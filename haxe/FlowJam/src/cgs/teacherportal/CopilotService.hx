package cgs.teacherportal;

import cgs.CgsApi;
import cgs.server.responses.CgsUserResponse;
import haxe.Json;
import cgs.teacherportal.data.CopilotResponseTags;
//import cgs.user.CgsUser;
import cgs.user.CgsUserManager;
import cgs.user.ICgsUserProperties;
import cgs.user.ICgsUser;
import cgs.teacherportal.IExternalComm;

/**
 * Contains methods for talking to student app (game)
 * and for sending game information to teacher app dashboard
 **/
class CopilotService implements IActivityLogger
{
    public var externalComsEnabled(get, set) : Bool;
    public var dynamicActivityId(get, never) : String;
	public var copilotProps(never, set) : CgsCopilotProperties;
	
    private static inline var API_VERSION : String = "1.0";
    //from External
    private static inline var START_ACTIVITY : String = "startActivity";
    private static inline var STOP_ACTIVITY : String = "stopActivity";
    private static inline var SET_WIDGET_ID : String = "setWidgetId";
    private static inline var SET_PAUSED : String = "setPaused";
    private static inline var ADD_USER : String = "addUser";
    private static inline var REMOVE_USER : String = "removeUser";
    private static inline var COMMAND_TO_WIDGET : String = "commandToWidget";
    //to External
    private static inline var WIDGET_READY : String = "CgsGames.onWidgetReady";
    private static inline var ACTIVITY_COMPLETE : String = "CgsGames.onActivityComplete";
    private static inline var MESSAGE_COMPLETE : String = "CgsGames.onMessageComplete";
    private static inline var SEND_COMMAND : String = "CgsGames.commandToCopilot";
    private static inline var STORE_USER_STATE : String = "CgsGames.storeUserState";
    private static inline var PROBLEM_SET_START : String = "CgsGames.logProblemSetStart";
    private static inline var PROBLEM_SET_END : String = "CgsGames.logProblemSetEnd";
    private static inline var PROBLEM_RESULT : String = "CgsGames.logProblemResult";
    
    private var _cgsApi : CgsApi;
    
    //Properties
    private var _userProps : ICgsUserProperties;
    private var _completeCallbackOfGame : CgsUserResponse -> Void;
    private var _copilotProps : CgsCopilotProperties;
    private var _widgetId : String;
    
    //State
    private var _activityDefinition : Dynamic;
    private var _externalComsEnabled : Bool;
    
    // Users
    private var _userManager : CgsUserManager;
    
	// External Communication
	private var ec:IExternalComm;
	
    /**
		 * Creates the Copilot Service.
		 * NOTE: the Copilot Service ASSUMES you are caching to the database. If you do not, you will
		 * not get any UserState from the Copilot Service (ie. during the startActivity call).
		 * NOTE: Usernames are not currently set for any users. Contact the Copilot team if you need username data.
		 * @param	cgsApi
		 * @param	cgsProps - this properties instance must be unique to the Copilot Service, the game should generate another properties instance for its own usage.
		 * @param	copilotProps
		 */
    public function new(cgsApi : CgsApi, cgsProps : ICgsUserProperties, copilotProps : CgsCopilotProperties, ec:IExternalComm=null, userManager:CgsUserManager=null)
    {
        _cgsApi = cgsApi;
        _userProps = cgsProps;  // Note, the games should, and are in charge of whether or not they, cache to the database.  
        this.copilotProps = copilotProps;
        
        // Handle complete callback, so we can ensure users are registered before calling the start activity call
        if (_userProps.completeCallback != null)
        {
            _completeCallbackOfGame = _userProps.completeCallback;
        }
        
        _activityDefinition = null;
        _externalComsEnabled = true;
        _widgetId = "NEW_WIDGET";
        
		
		_userManager = (userManager != null) ? userManager : new CgsUserManager();
		
		this.ec = (ec != null) ? ec : new ExternalComm();
    }
    
    /**
     *
     * Internal State
     *
    **/
    
    /**
     * Returns a flag indicating the state of outgoing external interface
     */
    private function get_externalComsEnabled() : Bool
    {
        return (_externalComsEnabled);
    }
    
    /**
     * Set the state of outgoing external interface
     */
    private function set_externalComsEnabled(value : Bool) : Bool
    {
        _externalComsEnabled = value;
        return value;
    }
    
	private function set_copilotProps(value : CgsCopilotProperties) : CgsCopilotProperties
	{
		_copilotProps = value;
		return value;
	}
    /**
     *
     * Notifications of State
     *
    **/
    
    /**
     * Notifies the Copilot Service that activity is complete
     * @param datails - optional object to pass widget specific data
     */
    public function onActivityComplete(details : Dynamic = null) : Void
    {
        details = ((details != null)) ? details : { };
        callExternal(ACTIVITY_COMPLETE, [_activityDefinition.daid, details]);
    }
    
    /**
     * Notifies the Copilot Service that the widget is ready to recieve commands from the copilot.
     * @param datails - optional object to pass game specific data
     */
    public function onWidgetReady(details : Dynamic = null) : Void
    {
        // Setup user callbacks for the student app
        setupExternalInterface();
        
        //Tell external that we are ready, and our API version
        details = ((details != null)) ? details : { };
        callExternal(WIDGET_READY, [API_VERSION, details]);
    }
    
    /**
     *
     * Responses
     *
    **/
    
    /**
     * Creates onMessageComplete call to Javascript
     * @param mid - message ID
     * @param success - whether message was successfully processed
     * @param data - return data from message processing
     */
    private function onMessageComplete(mid : String, success : Bool, data : Dynamic) : Void
    {
        data = ((data != null)) ? data : { };
        callExternal(MESSAGE_COMPLETE, [mid, success, data]);
    }
    
    /**
     *
     * Result Set Calls
     *
    **/
    
    /**
		 * Returns the daid (Dynamic Activity ID) of the current activity, if any.
		 * Returns an empty string if there is no currently running activity
		 */
    private function get_dynamicActivityId() : String
    {
        var result : String = "";
        if (_activityDefinition != null)
        {
            result = _activityDefinition.daid;
        }
        return result;
    }
    
    /**
     * Logs start of problem set
     * @param uid - User ID of the problem set. Each User may have only one active Problem Set at any given time.
     * @param psid - ID of a problem set.
     * @param problemCount - number of problems in this set (negative value denotes unknown number).
     * @param problemSetData - widget-specific data about problem set. Null is converted to {}.
     * @param details - optional data about this problem set. Null is converted to {}.
     */
    public function logProblemSetStart(uid : String, psid : String, problemCount : Int = -1, problemSetData : Dynamic = null, details : Dynamic = null) : Void
    {
        if (isUidValid(uid))
        {
            problemSetData = ((problemSetData != null)) ? problemSetData : { };
            details = ((details != null)) ? details : { };
            callExternal(PROBLEM_SET_START, [uid, psid, problemCount, problemSetData, details]);
        }
    }
    
    /**
     * Logs end of problem set
     * @param uid - User ID of the problem set.
     * @param problemSetData - widget-specific data about problem set. Null is converted to {}.
     * @param details - optional data about problem set. Null is converted to {}.
     */
    public function logProblemSetEnd(uid : String, problemSetData : Dynamic = null, details : Dynamic = null) : Void
    {
        if (isUidValid(uid))
        {
            problemSetData = ((problemSetData != null)) ? problemSetData : { };
            details = ((details != null)) ? details : { };
            callExternal(PROBLEM_SET_END, [uid, problemSetData, details]);
        }
    }
    
    /**
     * Logs a problem result
     * @param uid - User ID of the problem.
     * @param value - value in range [0, 1] representing the result
     *          0 - complete failure (0%)
     *          1 - complete success (100%)
     * @param problemPartList - optional list of concept strings that this problem tests. Null is converted to [].
     * @param problemData - widget-specific data about problem. Null is converted to {}.
     * @param details - optional data about this problem. Null is converted to {}.
     */
    public function logProblemResult(uid : String, value : Float, problemPartList : Array<Dynamic> = null, problemData : Dynamic = null, details : Dynamic = null) : Void
    {
        if (isUidValid(uid))
        {
            problemPartList = ((problemPartList != null)) ? problemPartList : [];
            problemData = ((problemData != null)) ? problemData : { };
            details = ((details != null)) ? details : { };
            callExternal(PROBLEM_RESULT, [uid, value, problemPartList, problemData, details]);
        }
    }
    
    /**
     *
     * Cache (saving of data)
     *
    **/
    
    /**
     * Tells the Copilot Service to store a key:value pair for a user
     * @param uid - User ID. Must be valid
     * @param key - Data key. Must not me null.
     * @param val - Data value
     */
    public function storeUserState(uid : String, key : String, val : Dynamic) : Void
    {
        if (isUidValid(uid) &&  //check that we have a valid uid  
            key != null && key.length > 0)
        {
            //check that we have a valid key
            {
                callExternal(STORE_USER_STATE, [uid, key, val]);
            }
        }
    }
    
    /**
     *
     * Generic
     *
    **/
    
    /**
     * Sends a generic message to Javascript as a JSON encoded string
     * @param command - name of command
     * @param args - JSON encodable object containing command parameters. Null is converted to {}
     */
    public function commandToCopilot(command : String, args : Dynamic = null) : Void
    {
        args = ((args != null)) ? args : { };
        callExternal(SEND_COMMAND, [command, Json.stringify(args)]);
    }
    
    /**
     *
     * External Interface Calls
     *
    **/
    
    /**
     * Sets up ExternalInterface by registering all necessary functions
     */
	private function setupExternalInterface()
	{
		ec.setMessageCallback(START_ACTIVITY, startActivity);
		ec.setMessageCallback(STOP_ACTIVITY, stopActivity);
		ec.setMessageCallback(SET_WIDGET_ID, setWidgetId);
		ec.setMessageCallback(SET_PAUSED, setPaused);
		ec.setMessageCallback(COMMAND_TO_WIDGET, commandToWidget);
		ec.setMessageCallback(ADD_USER, addUser);
		ec.setMessageCallback(REMOVE_USER, removeUser);
	}
    
    /**
     * A wrapper to ExternalInterface.call
     * Does the check for ExternalInterface availability, and wraps the call in a try/catch,
     * so that the game does not crash if a method is missing in Javascript.
     * Adds gameId from flashVars as the first argument.
     * For further details, see calling functions. Their documentation can be found at
     * https://docs.google.com/a/cs.washington.edu/document/d/1xX2F8bIpGwQm6Bu4sbwgPdiUyMGum5hwj9JyDZPwftU/edit
     *
     * @param funcName - mothod name to call
     * @param ...args - method arguments to pass
     */
	private function callExternal(funcName:String, args:Array<Dynamic>)
	{
		//check that outside world exists and we are communicating with it
		if (this.externalComsEnabled)
		{
			try
			{
				args.insert(0, _widgetId);
				var msg:ExternalCommuicationParentMessage = 
				{
					command : funcName,
					
					args:args
				}
				ec.sendMsgToParent(msg);
			}
			catch (e:Dynamic)
			{
				this.externalComsEnabled = false;
				var exceptionCallback = _copilotProps.exceptionCallback;
				if (exceptionCallback != null)
				{
					exceptionCallback(e);
				}
			}
		}
	}
    
    /**
     * Logs a message in Javascript via console.log function
     * @param message - Message to log
     */
    private function traceExternal(message : String) : Void
    {
        if (!_cgsApi.isProductionRelease)
        {
            message = "Copilot Service: " + message;
            callExternal("console.log", [message]);
        }
    }
    
    /**
     *
     * Copilot Command Callbacks - Game Management
     *
    **/
    
    /**
     * Sets the id which the widget uses to identify itself to the copilot
     * @param mid - Message id of the request
     * @param widgetId - ID of this widget
     */
	private function setWidgetId(args:Array<Dynamic>)
	{
		var mid:String = args[0];
		var widgetId:String = args[1];
        _widgetId = widgetId;
        onMessageComplete(mid, true, { });
    }
    
    /**
     * Starts the widget with given parameters. Attempts to end any currently running activity.
     * @param mid - Message id of the request
	 * @param userList - list of user objects with folowing format {uid:String, userState:Dynamic}
	 * @param activityDefinition - object containing activity data with the folowing format
	 *          {daid:String, lid:String, activityData:Dynamic}
	 * @param details - object containing additional/optional parameters
	 */
	private function startActivity(args:Array<Dynamic>)
	{
		var mid:String = args[0];
		var userList:Array<Dynamic> = args[1];
		var activityDefinition:Dynamic = args[2];
		var details:Dynamic = args[3];
        // Attempt to start
        function callStart(success : Bool, data : Dynamic = null) : Void
        {
            if (success)
            {
                // Call the start
                doStart(mid, userList, activityDefinition, details);
            }
            else
            {
                // There must be a currently running activity, and it did not stop. Report failure to the Copilot.
                var traceStr : String = Json.stringify({
                            userList : userList,
                            activityDefinition : activityDefinition,
                            details : details
                        });
                onMessageComplete(mid, false, {
                            tag : CopilotResponseTags.ERROR,
                            message : "CopilotService could not stop currently running activity. " + traceStr
                        });
            }
        };
        // Stop the currently running activity, if any
        if (_activityDefinition != null)
        {
            doStop({ }, callStart);
        }
        else
        {
            callStart(true);
        }
    }
    
    /**
     * Starts the widget with given parameters
     * @param mid - Message id of the request
	 * @param userList - list of user objects with folowing format {uid:String, userState:Dynamic}
	 * @param activityDefinition - object containing activity data with the folowing format
	 *          {daid:String, lid:String, activityData:Dynamic}
     * @param details - object containing additional/optional parameters
		 */
    private function doStart(mid : String, userList : Array<Dynamic>, activityDefinition : Dynamic, details : Dynamic) : Void
    {
        var func : Dynamic->Dynamic->Dynamic->Void = _copilotProps.startCallback;
        var traceStr : String = Json.stringify(
				{
                    userList : userList,
                    activityDefinition : activityDefinition,
                    details : details
                });
        var userCompletedCount : Int = 0;
        var that : CopilotService = this;
        
        var callback = function(success : Bool, data : Dynamic = null) : Void
        {
		that.onMessageComplete(mid, success, data);
        }

        /**
			 * Complete callback for the start activity. Ensures all users are completed before calling the start activity.
			 * @param	userResponse
			 */
        function completeCallbackForStart(userResponse : CgsUserResponse) : Void
        {
            // Increment counter, call complete callback of the game for each user
            userCompletedCount++;
            callGameCompleteCallback(userResponse);
            
            // Once all users are registered, call the start activity on the game
            if (userCompletedCount >= userList.length)
            {
                //call start callback
                func(callback, activityDefinition, details);
            }
        };
        
        if (func != null && userList != null && activityDefinition != null)
        {
            traceExternal("Starting widget with: " + traceStr);
            
            //create users
	    for (user in userList)
            {
                // Clone user props for each player
                // Insert complete callback for start, so that we can ensure all users are registered before we call the start activity.
                var cloneUserProps : ICgsUserProperties = _userProps.cloneUserProperties();
                cloneUserProps.completeCallback = completeCallbackForStart;
                
	    addUserImpl(user.uid, cloneUserProps, user.userState, details);
            }
            _activityDefinition = activityDefinition;
        }
        else
        {
            onMessageComplete(mid, false, {
                        tag : CopilotResponseTags.ERROR,
                        message : "CopilotService is missing the startGameCallback or necessary data. " + traceStr
                    });
        }
    }
    
    /**
     * Stops the widget
     * @param mid - Message id of the request
     * @param details - object containing additiona/optional parameters
     */
     private function stopActivity(args:Array<Dynamic>)
     {
     	var mid:String = args[0];
		var details:Dynamic = args[1];
        var that : CopilotService = this;

        // Notify the Copilot that the stop completed
        function stopCompleteCallback(success : Bool, data : Dynamic = null) : Void
        {
			that.onMessageComplete(mid, success, data);
        };
		
		doStop(details, stopCompleteCallback);
    }
    
    /**
     * Stops the widget
     * @param details - object containing additiona/optional parameters
     * @param stopCompleteCallback - callback when stop is complete
     */
    private function doStop(details : Dynamic, stopCompleteCallback : Bool->?Dynamic->Void) : Void
    {
        var func = _copilotProps.stopCallback;
        if (func != null)
        {
            traceExternal("Stopping activity");
            var that : CopilotService = this;
            var callback = function(success : Bool, data : Dynamic = null) : Void
            {
                // Only clear the users if we have a currently running activity.
                if (_activityDefinition != null)
                {
                    clearUsers();
                    _activityDefinition = null;
                }
                stopCompleteCallback(true);
            }
            func(callback, details);
        }
        else
        {
            stopCompleteCallback(false);
        }
    }
    
    /**
     * Pause or resume this widget
     * @param mid - Message id of the request
     * @param value - true if pausing the widget
     * @param details - object containing additional/optional parameters
     */
	private function setPaused(args:Array<Dynamic>)
	{
		var mid:String = args[0];
		var value:Bool = args[1];
		var details:Dynamic = args[2];
        var func = _copilotProps.pauseCallback;
        if (func != null)
        {
            traceExternal("Setting pause: " + value);
            var that : CopilotService = this;
            var callback = function(success : Bool, data : Dynamic = null) : Void
            {
                that.onMessageComplete(mid, success, data);
            }
            func(callback, value, details);
        }
        else
        {
            onMessageComplete(mid, false, {
                        tag : CopilotResponseTags.ERROR,
                        message : "CopilotService is missing the pause/resume callback."
                    });
        }
    }
    
    /**
     * Add a user. Used after the activity has been started.
     * @param mid - id of this message
     * @param uid - id of the user
     * @param userState - object containing user data
     * @param details - object containing additional/optional parameters
     */
	private function addUser(args:Array<Dynamic>)
	{
		var mid:String = args[0];
		var uid:String = args[1];
		var userState:Dynamic = args[2];
		var details:Dynamic = args[3];
        var func = _copilotProps.userAddedCallback;
        var that : CopilotService = this;
        
		var callback = function(success : Bool, data : Dynamic = null) : Void
		{
			that.onMessageComplete(mid, success, data);
		}

        /**
			 * Complete callback for the add user. Ensures that the user add is completed before calling the add user on the game.
			 * @param	userResponse
			 */
        function completeCallbackForAddUser(userResponse : CgsUserResponse) : Void
        {
            // Increment counter, ensure complete is called for the game
            callGameCompleteCallback(userResponse);
            
            //var user:ICgsUser = _userManager.getUserByUserId(uid);
            var user : ICgsUser = userResponse.cgsUser;
            if (user != null)
            {
                if (func != null)
                {
                    // Call addUser callback
                    func(callback, user);
                }
                else
                {
                    onMessageComplete(mid, true, {
                                tag : CopilotResponseTags.WARNING,
                                message : "CopilotService is missing the addUser callback."
                            });
                }
            }
            else
            {
                onMessageComplete(mid, false, {
                            tag : CopilotResponseTags.ERROR,
                            message : "No user added"
                        });
            }
        };
        // Insert complete callback for addUser, so that we can ensure the user add is completed before we call add user on the game.
        var cloneUserProps : ICgsUserProperties = _userProps.cloneUserProperties();
        cloneUserProps.completeCallback = completeCallbackForAddUser;
        
        // Add user
        addUserImpl(uid, cloneUserProps, userState, details);
    }
    
    /**
     * Remove a user. Used after the activity has been started.
     * @param mid - id of this message
     * @param uid - id of the user
     * @param details - object containing additional/optional parameters
     */
	private function removeUser(args:Array<Dynamic>)
	{
		var mid:String = args[0];
		var uid:String = args[1];
		var data:Dynamic = args[2];
        var user : ICgsUser = _userManager.getUserByUserId(uid);  //get user  
        if (user != null)
        {
            //call the callback if it exists and then remove the user
            var func = _copilotProps.userRemovedCallback;
            if (func != null)
            {
                var that : CopilotService = this;
                var callback = function(success : Bool, data : Dynamic = null) : Void
                {
                    removeUserImpl(uid, data);
		    that.onMessageComplete(mid, success, data);
                }
                func(callback, user);
            }
            else
            {
                removeUserImpl(uid, data);
                onMessageComplete(mid, true, {
                            tag : CopilotResponseTags.WARNING,
                            message : "CopilotService is missing the removeUser callback."
                        });
            }
        }
        else
        {
            onMessageComplete(mid, false, {
                        tag : CopilotResponseTags.ERROR,
                        message : "No user to remove"
                    });
        }
    }
    
    /**
     * Process a serialized command
     * @param mid - message id
     * @param command - command name
     * @param args - serialized arguments to be deserialized by the widget
     */
     private function commandToWidget(args:Array<Dynamic>)
     {
     	var mid:String = args[0];
		var cbCommand:String = args[1];
		var cbArgs:String = args[2];
        var func = _copilotProps.commandToWidgetCallback;
        if (func != null)
        {
            traceExternal("Processing command: " + {
                        command : cbCommand,
                        args : cbArgs
                    });
            var that : CopilotService = this;
            var callback = function(success : Bool, data : Dynamic = null) : Void
            {
				that.onMessageComplete(mid, success, data);
            }
            func(callback, cbCommand, cbArgs);
        }
        else
        {
            onMessageComplete(mid, false, {
                        tag : CopilotResponseTags.ERROR,
                        message : "CopilotService is missing the command callback."
                    });
        }
    }
    
    /**
		 * Removes all users registered in the user manager of this copilot service from the cgsapi.
		 */
    private function clearUsers() : Void
    {
	for (user in _userManager.userList)
        {
            (try cast(user, ICopilotLogger) catch(e:Dynamic) null).clearActivityLogger();  //clear ourselves from this user  
            _cgsApi.removeUser(user);
        }
        _userManager = new CgsUserManager();
    }
    
    /**
		 * Copilot responds calls the complete callback of the game.
		 * @param	userResponse
		 */
    private function callGameCompleteCallback(userResponse : CgsUserResponse) : Void
    {
        if (_completeCallbackOfGame != null)
        {
            _completeCallbackOfGame(userResponse);
        }
    }
    
    /**
     *
     * Copilot Command Callbacks - Users Management
     *
    **/
    
    //User State keys
    //private static const USER_NAME:String = "username";
    //private static const DEFAULT_USER_NAME:String = "YOU";
    
    /**
     * Adds the given user to the users in the game/in the copilot service.
     * @param uid - user ID.
     * @param userState - Data about the user
     * @param details - object containing additional/optional parameters
     */
    private function addUserImpl(uid : String, userProps : ICgsUserProperties, userState : Dynamic, details : Dynamic) : Void
    {
        traceExternal("Adding user with id: " + uid);
        
        if (uid != null && uid.length > 0)
        {
            var aUser : ICgsUser;
            
            // Create a new user
            if (!_cgsApi.userManager.userExistsByUserId(uid))
            {
                traceExternal("Creating new user");
                
                // Check for a username
                // NOTE: Usernames are not to be handled by the Copilot Service until someone (a game) wants them.
                // We will figure out how to handle this case at that time.
                /*if (userState != null && userState.hasOwnProperty(USER_NAME))
                {
                userProps.defaultUsername = userState[USER_NAME];
                }
                else
                {
                userProps.defaultUsername = null;
                }*/
                
                userProps.forceUid = uid;
                aUser = _cgsApi.initializeUser(userProps);
            }
            else
            {
                // User already exists, lets get it from the main user manager
                {
                    traceExternal("Getting existing user");
                    aUser = _cgsApi.userManager.getUserByUserId(uid);
                }
            }
            
            // Track the user internally
            (try cast(aUser, ICopilotLogger) catch(e:Dynamic) null).setActivityLogger(this);
            _userManager.addUser(aUser);
        }
    }
    
    /**
     * Removes the given user from the users in the game/in the copilot service.
     * @param uid - User ID
     * @param details - object containing additional/optional parameters
     */
    private function removeUserImpl(userId : String, details : Dynamic) : Void
    {
        var aUser : ICgsUser = _userManager.getUserByUserId(userId);
        if (aUser != null)
        {
            (try cast(aUser, ICopilotLogger) catch(e:Dynamic) null).clearActivityLogger();
            // Get the user and remove it
            removeUserFromUserManagers(aUser);
        }
    }
    
    /**
     * Removes the given user from the copilot user manager and the user manager in the CgsApi.
     * @param aUser
     */
    private function removeUserFromUserManagers(aUser : ICgsUser) : Void
    {
        _userManager.removeUser(aUser);
        _cgsApi.removeUser(aUser);
    }
    
    /**
     * Checks if the uid is for a known user and of valid fromat for logging
     * @param uid - User ID.
     * @return
     */
    private function isUidValid(uid : String) : Bool
    {
        return (uid != null && _userManager.userExistsByUserId(uid));
    }
}
