package cgs.user;


/**
	 * ...
	 * @author Rich
	 */
class CgsUserManager implements ICgsUserManager
{
    public var numUsers(get, never) : Int;
    public var userList(get, never) : Array<ICgsUser>;
    public var userIdArray(get, never) : Array<Dynamic>;
    public var userIdList(get, never) : Array<String>;
    public var usernameList(get, never) : Array<String>;
    public var users(get, never) : Dynamic;

    // State
    private var m_users : Array<ICgsUser>;  // Vector of users stored by userId  
    
    public function new()
    {
        m_users = new Array<ICgsUser>();
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_numUsers() : Int
    {
        return m_users.length;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_userList() : Array<ICgsUser>
    {
        // Cloning user vector; apparently concat returns a shallow clone if no args are provided.
        return m_users.copy();
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_userIdArray() : Array<Dynamic>
    {
        var result : Array<Dynamic> = new Array<Dynamic>();
        
        // Converting user vector into an array.
        for (user in m_users)
        {
            result.push(user.userId);
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_userIdList() : Array<String>
    {
        var result : Array<String> = new Array<String>();
        
        for (user in m_users)
        {
            result.push(user.userId);
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_usernameList() : Array<String>
    {
        var result : Array<String> = new Array<String>();
        
        for (user in m_users)
        {
            result.push(user.username);
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_users() : Dynamic
    {
        // Convert the user vector to an object
        var result : Dynamic = {};
        for (user in m_users)
        {
            Reflect.setField(result, Std.string(user.userId), user);
        }
        return result;
    }
    
    /**
		 * 
		 * Existence
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function userExistsByUserId(userId : String) : Bool
    {
        var aUser : ICgsUser = getUserByUserId(userId);
        return (aUser != null);
    }
    
    /**
		 * @inheritDoc
		 */
    public function userExistsByUsername(username : String) : Bool
    {
        var aUser : ICgsUser = getUserByUsername(username);
        return (aUser != null);
    }
    
    /**
		 * 
		 * Management
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function addUser(user : ICgsUser) : Void
    {
        if (user != null && Lambda.indexOf(m_users, user) < 0)
        {
            m_users.push(user);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeUser(user : ICgsUser) : Void
    {
        if (user != null && Lambda.indexOf(m_users, user) >= 0)
        {
            m_users.splice(Lambda.indexOf(m_users, user), 1);
        }
    }
    
    /**
		 * 
		 * Retrieval
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function getUserByUserId(userId : String) : ICgsUser
    {
        var result : ICgsUser = null;
        for (user in m_users)
        {
            if (userId == user.userId)
            {
                result = user;
                break;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getUserByUsername(username : String) : ICgsUser
    {
        var result : ICgsUser = null;
        for (user in m_users)
        {
            if (username == user.username)
            {
                result = user;
                break;
            }
        }
        return result;
    }
}

