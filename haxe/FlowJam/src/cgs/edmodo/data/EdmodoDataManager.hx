package cgs.edmodo.data;


/**
	 * Manages all of the data loaded from edmodo.
	 */
import openfl.utils.Dictionary;
class EdmodoDataManager implements IEdmodoDataProvider
{
    //User data for the user that launched the application.
    private var _launchUser : EdmodoUserData;
    
    //User data for all users that have been loaded into the application.
    private var _users : Dictionary<String, Dynamic>;
    
    //Group data for all of the groups that have been loaded into the application.
    private var _groups : Dictionary<String, Dynamic>;
    
    public function new()
    {
        _users = new Dictionary<String, Dynamic>();
        _groups = new Dictionary<String, Dynamic>();
    }
    
    public function getLaunchUser() : EdmodoUserData
    {
        return _launchUser;
    }
    
    public function getUserData(userToken : String) : EdmodoUserData
    {
        return _users[userToken];
    }
    
    public function getGroupData(groupID : Int) : EdmodoGroupData
    {
        return _groups[groupID];
    }
    
    private function addUserData(userData : EdmodoUserData) : Void
    {
        _users[userData.userToken] = userData;
    }
    
    //
    // Data parsing and adding functionality.
    //
    
    public function createLaunchUser(extData : Dynamic, data : Dynamic) : Void
    {
        _launchUser = new EdmodoUserData();
        _launchUser.parseJsonData(extData);
        _launchUser.parseCgsJsonData(data);
        addUserData(_launchUser);
    }
    
    public function parseJsonUserClassmates(userToken : String, users : Array<Dynamic>) : Void
    {
        parseJsonUserConnections(userToken, users, "CLASSMATES");
    }
    
    public function parseJsonUserTeachers(userToken : String, users : Array<Dynamic>) : Void
    {
        parseJsonUserConnections(userToken, users, "TEACHERS");
    }
    
    public function parseJsonUserParents(userToken : String, users : Array<Dynamic>) : Void
    {
        parseJsonUserConnections(userToken, users, "PARENTS");
    }
    
    private function parseJsonUserConnections(userToken : String, users : Array<Dynamic>, connectionType : String) : Void
    {
        var user : EdmodoUserData = getUserData(userToken);
        
        var userTokens : Array<Dynamic> = [];
        var currUserToken : String = "";
        var userData : EdmodoUserData;
        for (userDataObj in users)
        {
            userData = new EdmodoUserData();
            userData.parseJsonUserConnectionData(userToken, userDataObj);
            currUserToken = userData.userToken;
            userTokens.push(currUserToken);
            _users[currUserToken] = userData;
            if (user != null)
            {
                user.setSharedGroups(userData.userToken, userData.getSharedGroups(user.userToken));
            }
        }
        
        if (user != null)
        {
            if (connectionType == "CLASSMATES")
            {
                user.classmates = userTokens;
            }
            else
            {
                if (connectionType == "PARENTS")
                {
                    user.parents = userTokens;
                }
                else
                {
                    if (connectionType == "TEACHERS")
                    {
                        user.teachers = userTokens;
                    }
                }
            }
        }
    }
    
    /**
		 * Parse an array of users data and return an array of user tokens
		 * which can be used to retrieve the user data.
		 */
    public function parseJsonUsersData(users : Array<Dynamic>) : Array<Dynamic>
    {
        var userTokens : Array<Dynamic> = [];
        var currUserToken : String = "";
        var userData : EdmodoUserData;
        for (userDataObj in users)
        {
            if (Reflect.hasField(_users, userDataObj.user_token))
            {
                userData = _users[userDataObj.user_token];
            }
            else
            {
                userData = new EdmodoUserData();
            }
            
            userData.parseJsonData(userDataObj);
            currUserToken = userData.userToken;
            userTokens.push(currUserToken);
            _users[currUserToken] = userData;
        }
        
        return userTokens;
    }
    
    public function parseJsonGroupMembers(users : Array<Dynamic>, groupID : Int) : Void
    {
        var userTokens : Array<Dynamic> = parseJsonUsersData(users);
        
        var groupData : EdmodoGroupData = _groups[groupID];
        if (groupData != null)
        {
            groupData.members = userTokens;
        }
    }
    
    /**
		 * Parse and group data. Will return and array of group ids.
		 */
    public function parseJsonGroupData(groups : Array<Dynamic>, userToken : String = null) : Array<Dynamic>
    {
        var groupIds : Array<Dynamic> = [];
        var groupOwners : Array<Dynamic>;
        var groupData : EdmodoGroupData;
        var userData : EdmodoUserData;
        for (groupDataObj in groups)
        {
            //Does this group already exist.
            if (Reflect.hasField(_groups, groupDataObj.group_id))
            {
                groupData = Reflect.getProperty(_groups, groupDataObj.group_id);
            }
            else
            {
                groupData = new EdmodoGroupData();
            }
            
            groupData.parseJsonData(groupDataObj);
            _groups[groupData.groupID] = groupData;
            groupIds.push(groupData.groupID);
            
            if (userToken != null)
            {
                userData = _users[userToken];
                if (userData != null)
                {
                    userData.addGroup(groupData.groupID, groupData.isOwner(userToken));
                }
            }
        }
        
        return groupIds;
    }
}
