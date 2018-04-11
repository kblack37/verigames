package cgs.user;


/**
	 * ...
	 * @author Rich
	 */
interface ICgsUserManager
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the number of users in this CGS User Manager
		 */
    var numUsers(get, never) : Int;    
    
    /**
		 * Returns a Vector (list) of all users.
		 */
    var userList(get, never) : Array<ICgsUser>;    
    
    /**
		 * Returns an array of all user ids.
		 */
    var userIdArray(get, never) : Array<Dynamic>;    
    
    /**
		 * Returns a Vector (list) of all user IDs.
		 */
    var userIdList(get, never) : Array<String>;    
    
    /**
		 * Returns a Vector (list) of all usernames.
		 */
    var usernameList(get, never) : Array<String>;    
    
    /**
		 * Returns an object of users.
		 */
    var users(get, never) : Dynamic;

    
    /**
		 * 
		 * Existence
		 * 
		**/
    
    /**
		 * Returnes whether or not the user with the give userId exists.
		 * @param	userId
		 * @return
		 */
    function userExistsByUserId(userId : String) : Bool
    ;
    
    /**
		 * Returnes whether or not the user with the give username exists.
		 * @param	username
		 * @return
		 */
    function userExistsByUsername(username : String) : Bool
    ;
    
    /**
		 * 
		 * Retrieval
		 * 
		**/
    
    /**
		 * Returns the ICgsUser associated with the given userId.
		 * @param	userId
		 * @return
		 */
    function getUserByUserId(userId : String) : ICgsUser
    ;
    
    /**
		 * Returns the ICgsUser associated with the given username.
		 * @param	userId
		 * @return
		 */
    function getUserByUsername(username : String) : ICgsUser
    ;
    
    /**
		 * 
		 * User Management
		 * 
		**/
    
    /**
		 * Adds the given user to this User Manager.
		 * @param	user
		 */
    function addUser(user : ICgsUser) : Void
    ;
    
    /**
		 * Removes the given user from this User Manager.
		 * @param	user
		 */
    function removeUser(user : ICgsUser) : Void
    ;
}

