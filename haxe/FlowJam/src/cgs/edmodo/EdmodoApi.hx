package cgs.edmodo;
import cgs.utils.Error;
import haxe.Json;

//import cgs.edmodo.data.EdmodoDataManager;
//import cgs.edmodo.data.EdmodoGroupData;
//import cgs.edmodo.data.EdmodoUserData;
//import cgs.edmodo.requests.GroupRequest;
//import cgs.edmodo.requests.UserCallbackRequest;
//import cgs.edmodo.requests.UserDataRequest;
//import cgs.pblabs.engine.debug.Logger;
//import cgs.server.logging.CGSServerProps;
//import cgs.server.logging.IGameServerData;
//import cgs.server.logging.messages.Message;
//import cgs.server.logging.requests.CallbackRequest;
//import cgs.server.requests.IUrlRequestHandler;
//import cgs.server.requests.UrlLoader;
//import cgs.server.requests.UrlRequestHandler;

class EdmodoApi
{
    public static var instance(get, never) : EdmodoApi;

    private static var _instance : EdmodoApi;
    
    //Handles requests to the edmodo server..
    private var _requestHandler : IUrlRequestHandler;
    
    private var _dataManager : EdmodoDataManager;
    
    private var _serverData : EdmodoApiData;
    
    private var _loadingUserData : Bool;
    private var _userDataRequest : UserDataRequest;
    
    private var _gameServerData : IGameServerData;
    
    public function new(requestHandler : IUrlRequestHandler)
    {
        _requestHandler = requestHandler;
        
        if (_requestHandler == null)
        {
            var loader : UrlLoader = new UrlLoader();
            _requestHandler = new UrlRequestHandler(loader);
        }
    }
    
    private static function get_instance() : EdmodoApi
    {
        if (_instance == null)
        {
            _instance = new EdmodoApi(null);
            _instance.init();
        }
        
        return _instance;
    }
    
    //
    // Data retrieval.
    //
    
    public static function GetUserData(userToken : String) : EdmodoUserData
    {
        return instance.getUserData(userToken);
    }
    
    public function getUserData(userToken : String) : EdmodoUserData
    {
        return _dataManager.getUserData(userToken);
    }
    
    public static function GetGroupData(groupId : Int) : EdmodoGroupData
    {
        return instance.getGroupData(groupId);
    }
    
    public function getGroupData(groupId : Int) : EdmodoGroupData
    {
        return _dataManager.getGroupData(groupId);
    }
    
    /**
		 * Initializes the api and sets the app launch user information.
		 */
    public static function startup(data : EdmodoApiData, props : CGSServerProps) : Void
    {
        var start : EdmodoApi = instance;
        start._serverData = data;
        
        start._gameServerData = new GameServerData(props.useHttps);
        start.setGameServerProps(props, start._gameServerData);
    }
    
    //Set the server properties for the given game server data.
    private function setGameServerProps(props : CGSServerProps, serverData : IGameServerData) : Void
    {
        serverData.skey = props.skey;
        serverData.g_name = props.gameName;
        serverData.gid = props.gameID;
        serverData.cid = props.categoryID;
        serverData.vid = props.versionID;
        serverData.useDevelopmentServer = props.useDevServer;
        serverData.skeyHashVersion = props.skeyHashVersion;
        serverData.externalAppId = props.externalAppId;
    }
    
    /**
		 * Initialize the logged in Edmodo user from the flash parameters. This will
		 * return the launch user with all of the available data. More data will still
		 * be loaded from the server and will be valid when userDataLoaded callback is called.
		 * The uid on the EdmodoUserData is valid when this function returns.
		 *
		 * @return true if the user data was successfully parsed from the FlashVars.
		 */
    public static function initUser(parameters : Dynamic, userDataLoaded : Dynamic) : EdmodoUserData
    {
        var hasUserData : Bool = false;
        if (Reflect.hasField(parametersReflect.hasField("ext_data") && Reflect.hasField(parameters, "data"))
        {
            ParseJsonLaunchUserData(parameters.ext_data, parameters.data, true, userDataLoaded);
            return GetLaunchUser();
        }
        return null;
    }
    
    private function init() : Void
    {
        _dataManager = new EdmodoDataManager();
    }
    
    //
    // Properties.
    //
    
    /**
		 * Set the properties used to communicate with the Edmodo server.
		 */
    public function setProperties(baseURL : String, version : String = "v1") : Void
    {
    }
    
    public static function ParseJsonLaunchUserData(extData : Dynamic, data : Dynamic, loadUserData : Bool = true, callback : Dynamic = null) : Void
    {
        instance.parseJsonLaunchUserData(extData, data, loadUserData, callback);
    }
    
    public function parseJsonLaunchUserData(extData : Dynamic, data : Dynamic, loadUserData : Bool = true, callback : Dynamic = null) : Void
    {
        if (Std.is(extData, String))
        {
            extData = createJSONObject(extData);
        }
        if (Std.is(data, String))
        {
            data = createJSONObject(data);
        }
        
        _dataManager.createLaunchUser(extData, data);
        
        if (loadUserData && !_loadingUserData)
        {
            loadAllLaunchUserData(callback);
        }
    }
    
    public static function GetLaunchUser() : EdmodoUserData
    {
        return instance._dataManager.getLaunchUser();
    }
    
    //Creates a JSON string from an object.
    private static function createJSONString(data : Dynamic) : String
    {
        return Json.stringify(data);
    }
    
    //Creates a data object from a json string.
    private static function createJSONObject(data : String) : Dynamic
    {
        return Json.parse(data);
    }
    
    /**
		 * Handle a request to the Edmodo api.
		 */
    public static function Request(method : String, callback : Dynamic, data : Dynamic,
            params : Dynamic = null, extraData : Dynamic = null, isPOST : Bool = false, dataFormat : String = URLLoaderDataFormat.TEXT) : Void
    {
        instance.request(method, callback, data, params, extraData, isPOST, dataFormat);
    }
    
    public function request(method : String, callback : Dynamic, data : Dynamic,
            params : Dynamic = null, extraData : Dynamic = null, isPOST : Bool = false, dataFormat : String = URLLoaderDataFormat.TEXT) : Void
    {
        var apiRequest : ApiRequest = new ApiRequest(_serverData, method, callback, data, params, extraData, isPOST, dataFormat);
        
        _requestHandler.sendUrlRequest(apiRequest);
    }
    
    //
    // Get requests.
    //
    
    /**
		 * Handles loading all of the launch users classmates, teachers, parents and group data.
		 * Callback function should have the signature: (failed:Boolean):void;
		 */
    public static function LoadAllLaunchUserData(callback : Dynamic = null) : Void
    {
        instance.loadAllLaunchUserData(callback);
    }
    
    public function loadAllLaunchUserData(callback : Dynamic = null, loadGroupMembers : Bool = false) : Void
    {
        var launchUser : EdmodoUserData = _dataManager.getLaunchUser();
        if (launchUser == null)
        {
            if (callback != null)
            {
                callback(true);
            }
        }
        
        //Load all related users and group info.
        _loadingUserData = true;
        _userDataRequest = new UserDataRequest(launchUser.userToken, callback);
        
        _userDataRequest.userDataLoaded();
        _userDataRequest.loadGroupMembers = loadGroupMembers;
        _userDataRequest.userGroupCount = launchUser.groupCount;
        
        requestAllUserData(launchUser);
    }
    
    /**
		 * Load all of the data for a user. Only one of these requests can be performed at a time. Will
		 * call the callback with failed if another users data is already loading.
		 */
    public static function LoadAllUserData(userToken : String, callback : Dynamic = null, loadGroupMembers : Bool = false) : Void
    {
        instance.loadAllUserData(userToken, callback, loadGroupMembers);
    }
    
    public function loadAllUserData(userToken : String, callback : Dynamic = null, loadGroupMembers : Bool = false) : Void
    {
        if (_loadingUserData)
        {
            if (callback != null)
            {
                callback(true);
            }
            return;
        }
        
        _userDataRequest = new UserDataRequest(userToken, callback);
        _userDataRequest.loadGroupMembers = loadGroupMembers;
        
        var userData : EdmodoUserData = _dataManager.getUserData(userToken);
        if (userData == null)
        {
            requestUsersData([userToken], loadRemainingUserData);
        }
        else
        {
            _userDataRequest.userDataLoaded();
            requestAllUserData(userData);
        }
    }
    
    private function loadRemainingUserData(userTokens : Array<Dynamic>, failed : Bool) : Void
    {
        if (userTokens.length == 1)
        {
            var userToken : String = userTokens[0];
            var userData : EdmodoUserData = _dataManager.getUserData(userToken);
            _userDataRequest.userDataLoaded();
            
            //Load the remaining user data.
            requestAllUserData(userData);
        }
    }
    
    private function requestAllUserData(userData : EdmodoUserData) : Void
    {
        _userDataRequest.userGroupCount = userData.groupCount;
        
        if (userData.isStudent)
        {
            //Load the users relevant to students.
            requestClassmates(userData.userToken, userClassmatesLoaded);
            requestTeachers(userData.userToken, userTeachersLoaded);
            requestParents(userData.userToken, userParentsLoaded);
        }
        else
        {
            _userDataRequest.classmatesLoaded();
            _userDataRequest.parentsLoaded();
            _userDataRequest.teachersLoaded();
        }
        
        requestGroupsForUser(userData.userToken, userGroupIdsLoaded);
    }
    
    private function testUserDataLoaded() : Void
    {
        if (_userDataRequest.allDataLoaded)
        {
            Logger.print(this, "All user data loaded");
            var callback : Dynamic = _userDataRequest.callback;
            if (callback != null)
            {
                callback(false);
            }
            _userDataRequest = null;
            _loadingUserData = false;
        }
    }
    
    private function userClassmatesLoaded(userToken : String, failed : Bool) : Void
    {
        _userDataRequest.classmatesLoaded();
        testUserDataLoaded();
    }
    
    private function userTeachersLoaded(userToken : String, failed : Bool) : Void
    {
        _userDataRequest.teachersLoaded();
        testUserDataLoaded();
    }
    
    private function userParentsLoaded(userToken : String, failed : Bool) : Void
    {
        _userDataRequest.parentsLoaded();
        testUserDataLoaded();
    }
    
    private function userGroupIdsLoaded(userToken : String, failed : Bool) : Void
    {
        _userDataRequest.groupIdsLoaded();
        
        //Load the data relevant to all users.
        var userData : EdmodoUserData = _dataManager.getUserData(userToken);
        requestGroupsData(userData.groupIDs, userGroupsLoaded);
    }
    
    private function userGroupsLoaded(failed : Bool) : Void
    {
        _userDataRequest.groupsLoaded();
        _userDataRequest.userGroupCount = _dataManager.getUserData(_userDataRequest.userToken).groupCount;
        
        //Load all of the groups member data.
        if (_userDataRequest.loadGroupMembers)
        {
            var userData : EdmodoUserData = _dataManager.getUserData(_userDataRequest.userToken);
            for (groupID/* AS3HX WARNING could not determine type for var: groupID exp: EField(EIdent(userData),groupIDs) type: null */ in userData.groupIDs)
            {
                requestGroupMembers(groupID, groupMembersLoaded);
            }
        }
        
        testUserDataLoaded();
    }
    
    private function groupMembersLoaded(failed : Bool) : Void
    {
        _userDataRequest.groupMembersLoaded();
        testUserDataLoaded();
    }
    
    /**
		 * Callback should have the following method sig: (userTokens:Array, failed:Boolean);
		 * @exampleText example: GET /users?api_key=<API_KEY>&user_tokens=["b020c42d1","jd3i1c0pl"]
		 */
    public static function RequestUsersData(users : Array<Dynamic>, callback : Dynamic) : Void
    {
        instance.requestUsersData(users, callback);
    }
    
    public function requestUsersData(users : Array<Dynamic>, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            user_tokens : createJSONString(users)
        };
        
        var callbackRequest : CallbackRequest = null;
        if (callback != null)
        {
            callbackRequest = new CallbackRequest(callback, null);
        }
        
        request(EdmodoConstants.USERS, handleUsersDataLoaded, data.messageObject, params, callbackRequest);
    }
    
    private function handleUsersDataLoaded(response : String, failed : Bool, callbackRequest : CallbackRequest = null) : Void
    {
        var usersData : Dynamic = null;
        var userTokens : Array<Dynamic> = [];
        if (!failed)
        {
            try
            {
                usersData = createJSONObject(response);
                userTokens = _dataManager.parseJsonUsersData(try cast(usersData, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        if (callbackRequest != null)
        {
            var callback : Dynamic = callbackRequest.callback;
            callback(userTokens, failed);
        }
    }
    
    /**
		 * @exampleText example: GET /groups?api_key=<API_KEY>&group_ids=[379557,379562]
		 */
    public static function RequestGroupsData(groups : Array<Dynamic>, callback : Dynamic) : Void
    {
        instance.requestGroupsData(groups, callback);
    }
    
    public function requestGroupsData(groups : Array<Dynamic>, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            group_ids : createJSONString(groups)
        };
        
        var callbackRequest : CallbackRequest = null;
        if (callback != null)
        {
            callbackRequest = new CallbackRequest(callback, null);
        }
        
        request(EdmodoConstants.GROUPS, handleGroupDataLoaded, data.messageObject, params, callbackRequest);
    }
    
    private function handleGroupDataLoaded(response : String, failed : Bool, callbackRequest : CallbackRequest = null) : Void
    {
        var groupData : Dynamic = null;
        if (!failed)
        {
            try
            {
                groupData = createJSONObject(response);
                _dataManager.parseJsonGroupData(try cast(groupData, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        if (callbackRequest != null)
        {
            var callback : Dynamic = callbackRequest.callback;
            callback(failed);
        }
    }
    
    /**
		 * @exampleText example: GET /groupsForUser?api_key=<API_KEY>&user_token=b020c42d1
		 */
    public static function RequestGroupsForUser(userToken : String, callback : Dynamic) : Void
    {
        instance.requestGroupsForUser(userToken, callback);
    }
    
    public function requestGroupsForUser(userToken : String, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            user_token : userToken
        };
        
        var userRequest : UserCallbackRequest = new UserCallbackRequest(callback, userToken);
        
        request(EdmodoConstants.GROUPS_FOR_USER, handleGroupsForUserLoaded, data.messageObject, params, userRequest);
    }
    
    private function handleGroupsForUserLoaded(response : String, failed : Bool, userRequest : UserCallbackRequest) : Void
    {
        var groupData : Dynamic = null;
        if (!failed)
        {
            try
            {
                groupData = createJSONObject(response);
                var groupIds : Array<Dynamic> = _dataManager.parseJsonGroupData(try cast(groupData, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
                
                var user : EdmodoUserData = _dataManager.getUserData(userRequest.userToken);
                var currGroup : EdmodoGroupData;
                for (groupId in groupIds)
                {
                    currGroup = _dataManager.getGroupData(groupId);
                    user.addGroup(groupId, currGroup.isOwner(userRequest.userToken));
                }
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        if (userRequest.callback != null)
        {
            var callback : Dynamic = userRequest.callback;
            callback(userRequest.userToken, failed);
        }
    }
    
    /**
		 * @exampleText example: GET /members?api_key=<API_KEY>&group_id=379557
		 */
    public static function RequestGroupMembers(groupID : Int, callback : Dynamic) : Void
    {
        instance.requestGroupMembers(groupID, callback);
    }
    
    public function requestGroupMembers(groupID : Int, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            group_id : groupID
        };
        
        var groupRequest : GroupRequest = new GroupRequest(callback, groupID);
        
        request(EdmodoConstants.MEMBERS, handleRequestGroupsMembersLoaded, data.messageObject, params, groupRequest);
    }
    
    public function handleRequestGroupsMembersLoaded(response : String, failed : Bool, groupRequest : GroupRequest) : Void
    {
        var members : Dynamic = null;
        if (!failed)
        {
            try
            {
                members = createJSONObject(response);
                _dataManager.parseJsonGroupMembers(try cast(members, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null, groupRequest.groupID);
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        if (groupRequest.callback != null)
        {
            var callback : Dynamic = groupRequest.callback;
            callback(failed);
        }
    }
    
    /**
		 * @param callback function to be called when the users classmates have been loaded and processed.
		 * ` should have the following signature: (userToken:String, failed:Boolean):void.
		 *
		 * @exampleText example: GET /classmates?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestClassmates(userToken : String, callback : Dynamic) : Void
    {
        instance.requestClassmates(userToken, callback);
    }
    
    public function requestClassmates(userToken : String, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            user_token : userToken
        };
        
        var userRequest : UserCallbackRequest = new UserCallbackRequest(callback, userToken);
        
        request(EdmodoConstants.CLASSMATES, handleClassmatesLoaded, data.messageObject, params, userRequest, false);
    }
    
    public function handleClassmatesLoaded(response : String, failed : Bool, request : UserCallbackRequest) : Void
    {
        if (!failed)
        {
            try
            {
                var userData : Dynamic = createJSONObject(response);
                _dataManager.parseJsonUserClassmates(request.userToken, try cast(userData, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        var callback : Dynamic = request.callback;
        if (callback != null)
        {
            callback(request.userToken, failed);
        }
    }
    
    /**
		 * @param callback function to be called when the users teachers have been loaded and processed.
		 * Function should have the following signature: (failed:Boolean):void.
		 *
		 * @exampleText eample: GET /teachers?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestTeachers(userToken : String, callback : Dynamic) : Void
    {
        instance.requestTeachers(userToken, callback);
    }
    
    public function requestTeachers(userToken : String, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            user_token : userToken
        };
        
        var userRequest : UserCallbackRequest = new UserCallbackRequest(callback, userToken);
        
        request(EdmodoConstants.TEACHERS, handleTeachersLoaded, data.messageObject, params, userRequest);
    }
    
    private function handleTeachersLoaded(response : String, failed : Bool, userCallback : UserCallbackRequest) : Void
    {
        if (!failed)
        {
            try
            {
                var userData : Dynamic = createJSONObject(response);
                _dataManager.parseJsonUserTeachers(userCallback.userToken, try cast(userData, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        var callback : Dynamic = userCallback.callback;
        if (callback != null)
        {
            callback(userCallback.userToken, failed);
        }
    }
    
    /**
		 * @exampleText example: GET /teachermates?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestTeachermates(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /teacherConnections?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestTeacherConnections(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /assignmentsComingDue?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function AssignmentsComingDue(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /gradesSetByAppForUser?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestGradesSetByAppForUser(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /gradesSetByAppForGroup?api_key=<API_KEY>&group_id=379557
		 */
    public static function RequestGradesSetByAppForGroup(groupID : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /badgesAwarded?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestBadgesAwarded(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /eventsByApp?api_key=<API_KEY>&user_token=b020c42d1
		 */
    public static function RequestEventsByApp(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /parents?api_key=<API_KEY>&user_token=jd3i1c0pl
		 */
    public static function RequestParents(userToken : String, callback : Dynamic) : Void
    {
        instance.requestParents(userToken, callback);
    }
    
    public function requestParents(userToken : String, callback : Dynamic) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            user_token : userToken
        };
        
        var userRequest : UserCallbackRequest = new UserCallbackRequest(callback, userToken);
        
        request(EdmodoConstants.PARENTS, handleParentsLoaded, data.messageObject, params, userRequest);
    }
    
    private function handleParentsLoaded(response : String, failed : Bool, userCallback : UserCallbackRequest) : Void
    {
        if (!failed)
        {
            try
            {
                var userData : Dynamic = createJSONObject(response);
                _dataManager.parseJsonUserParents(userCallback.userToken, try cast(userData, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null);
            }
            catch (er : Error)
            {
                failed = true;
            }
        }
        
        var callback : Dynamic = userCallback.callback;
        if (callback != null)
        {
            callback(userCallback.userToken, failed);
        }
    }
    
    /**
		 * @exampleText example: GET /children?api_key=<API_KEY>&user_token=5e9c0e0f5
		 */
    public static function RequestChildren(userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: GET /getAppData?api_key=<API_KEY>&keys=["user_scores_123","user_scores_456","user_scores_789"]
		 */
    public static function RequestAppData(callback : Dynamic) : Void
    {
    }
    
    //
    // POST methods.
    //
    
    /**
		 * Send a post on behalf of a user.
		 *
		 * @param callback the function to be called when the server responds. Function should
		 * have the following signature: (failed:Boolean):void.
		 *
		 * @exampleText example: POST /userPost?api_key=<API_KEY>&user_token=b020c42d1&content=Test+message&recipients=<json>&attachments=<json>
		 */
    public static function SendUserPost(userToken : String,
            content : String, userIDs : Array<Dynamic>, groupIDs : Array<Dynamic>, attachments : Array<Dynamic> = null, callback : Dynamic = null) : Void
    {
        instance.sendUserPost(userToken, content, userIDs, groupIDs, attachments, callback);
    }
    
    public function sendUserPost(userToken : String,
            content : String, userIDs : Array<Dynamic>, groupIDs : Array<Dynamic>, attachments : Array<Dynamic> = null, callback : Dynamic = null) : Void
    {
        var data : Message = new Message(_gameServerData, null);
        data.injectGameParams();
        data.addProperty("ext_app_id", 1);
        
        var params : Dynamic = {
            user_token : userToken,
            content : content
        };
        
        var recipients : Array<Dynamic> = [];
        var idObject : Dynamic;
        for (userID in userIDs)
        {
            idObject = {
                        user_token : userID
                    };
            recipients.push(idObject);
        }
        
        for (groupID in groupIDs)
        {
            idObject = {
                        group_id : groupID
                    };
            recipients.push(idObject);
        }
        
        params.recipients = createJSONString(recipients);
        
        //Logger.print(this, "Sending user post to recipients: " + params.recipients);
        
        if (attachments != null)
        {
            params.attachments = createJSONString(attachments);
        }
        
        var callbackRequest : CallbackRequest = null;
        if (callback != null)
        {
            callbackRequest = new CallbackRequest(callback, null);
        }
        
        request(EdmodoConstants.USER_POST, handleUserPostResponse, data, params, callbackRequest, true);
    }
    
    private function handleUserPostResponse(response : String, failed : Bool) : Void
    {
    }
    
    /**
		 * @exampleText example: POST /turnInAssignment?api_key=<API_KEY>&user_token=83a8e614d&assignment_id=4738052&content="text"&attachments=<json>
		 */
    public static function TurnInAssignment(userToken : String,
            assignmentID : String, content : String, attachments : Dynamic = null, callback : Dynamic = null) : Void
    {
    }
    
    /**
		 * @exampleText example: POST /awardBadge?api_key=<API_KEY>&badge_id=6580&user_token=jd3i1c0pl
		 */
    public static function AwardBadge(badgeID : Int, userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: POST /revokeBadge?api_key=<API_KEY>&badge_id=6580&user_token=jd3i1c0pl
		 */
    public static function RevokeBadge(badgeID : Int, userToken : String, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: POST /newGrade?api_key=<API_KEY>&grade_id=3694&user_token=jd3i1c0pl&score=3
		 */
    public static function SetUserGrade(gradeID : Int,
            userToken : String, score : Int, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: POST /newEvent?api_key=<API_KEY>&user_token=b020c42d1&description=Pizza+party+tomorrow&start_date=2011-12-07&end_date=2011-12-07&recipients=<json>
		 */
    public static function CreateNewEvent(userToken : String, description : String,
            startDate : String, endDate : String, users : Array<Dynamic>, groups : Array<Dynamic>) : Void
    {
    }
    
    //
    // App management requests.
    //
    
    /**
		 * @exampleText example: POST /registerBadge?api_key=<API_KEY>&badge_title=Good+Job&description=You+did+a+good+job&image_url=<URL>
		 */
    public static function RegisterBadge(badgeTitle : String, description : String, imageURL : String) : Void
    {
    }
    
    /**
		 * @param data a object which contains key/value pairs of data to be stored
		 * on the server.
		 * @param callback function which will be called with fail or success of the request.
		 *
		 * @exampleText example: POST /setAppData?api_key=<API_KEY>&dataobject=<json>
		 */
    public static function SetAppData(data : Dynamic, callback : Dynamic) : Void
    {
    }
    
    /**
		 * @exampleText example: POST /newGrade?api_key=<API_KEY>&group_id=379557&title=Super+Project&total=10
		 */
    public static function AddNewGrade(groupID : Int, gradeTitle : String, totalGrade : Int) : Void
    {
    }
}
