package cgs.achievement;


/**
	 * Tracks the progress of things (or "achievements")
	 * @author Jack
	 */
interface ICgsAchievementManager
{

    
    /**
		 * 
		 * Achievement Management
		 * 
		**/
    
    /**
		 * Adds the given achievement to the manager with the given startStatus.  Does nothing if achievement is already in the manager
		 * @param	achievement	- The achievement to add
		 * @param	startStatus - The startingStatus of this acheivement (Defaults to false or not achieved)
		 * @return	Boolean - if the achievement was successfully added (it didn't already exist)
		 */
    function initAchievement(achievement : String, startStatus : Bool = false) : Bool
    ;
    
    /**
		 * Returns the status of a given achievement for the first user in the user manager
		 * @param	achievement - the achievement to return the status of
		 * @return	Boolean - whether the achievement is achieved or not. Returns false if achievement doesn't exist
		 */
    function getAchievementStatus(achievement : String) : Bool
    ;
    
    /**
		 * Sets the status of the achievement
		 * @param	achievement	- The achievement to set the status of
		 * @param	status	- The status to set the achievement to
		 * @return	Boolean	- The achievement was successfully set to the status
		 */
    function setAchievementStatus(achievement : String, status : Bool) : Bool
    ;
    
    /**
		 * Returns whether the achievement is in the manager or not for the first user in the user manager
		 * @param	achievement	- A string detailing the name of the achievement
		 * @return	Boolean - Does this acheivement exist in the manager
		 */
    function achievementExists(achievement : String) : Bool
    ;
}

