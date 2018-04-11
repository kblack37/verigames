package cgs.achievement;

import cgs.user.ICgsUser;

/**
	 * ...
	 * @author Jack
	 */
class CgsAchievementManager implements ICgsAchievementManager
{
    public var user(get, set) : ICgsUser;

    // Constants
    public static var ACHIEVEMENT_LIST_KEY : String = "achievements";  // Internal Status  ;
    
    
    
    private var m_user : ICgsUser;
    
    public function new(user : ICgsUser = null)
    {
        m_user = user;
    }
    
    /**
		 * 
		 * Internal State
		 * 
		**/
    
    /**
		 * Returns the user manager for this achievement manager.
		 */
    private function get_user() : ICgsUser
    {
        return m_user;
    }
    
    private function set_user(user : ICgsUser) : ICgsUser
    {
        m_user = user;
        return user;
    }
    
    /**
		 * 
		 * Achievement Management - Per User
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function initAchievement(achievement : String, startStatus : Bool = false) : Bool
    {
        var result : Bool = false;
        if (!achievementExists(achievement))
        {
            result = setAchievementStatus(achievement, startStatus);
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getAchievementStatus(achievement : String) : Bool
    {
        var result : Bool = false;
        if (achievementExists(achievement))
        {
            var achievements : Dynamic = getSave();
            result = Reflect.field(achievements, achievement);
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function setAchievementStatus(achievement : String, status : Bool) : Bool
    {
        var achievements : Dynamic = getSave();
        Reflect.setField(achievements, achievement, status);
        m_user.setSave(ACHIEVEMENT_LIST_KEY, achievements);
        return true;
    }
    
    /**
		 * @inheritDoc
		 */
    public function achievementExists(achievement : String) : Bool
    {
        var achievements : Dynamic = getSave();
        var result : Bool = false;
        if (Reflect.field(achievements, achievement) != null)
        {
            result = true;
        }
        return result;
    }
    
    /**
		 * 
		 * Helper Functions
		 * 
		**/
    
    /**
		 * Gets the achievement save data for the provided user.  Creates a new one if it doesn't exist
		 * @param	user	- the user to retrieve the data from
		 * @return	Object	- The achievement completion data for this user
		 */
    private function getSave() : Dynamic
    {
        var result : Dynamic;
        if (m_user.saveExists(ACHIEVEMENT_LIST_KEY) && m_user.getSave(ACHIEVEMENT_LIST_KEY) != null)
        {
            result = m_user.getSave(ACHIEVEMENT_LIST_KEY);
        }
        else
        {
            result = {};
            m_user.setSave(ACHIEVEMENT_LIST_KEY, result);
        }
        return result;
    }
}
