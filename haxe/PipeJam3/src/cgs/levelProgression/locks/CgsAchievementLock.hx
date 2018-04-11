package cgs.levelProgression.locks;

import cgs.achievement.ICgsAchievementManager;
import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.locks.ICgsLevelLock;

/**
	 * ...
	 * @author Jack
	 */
class CgsAchievementLock implements ICgsLevelLock
{
    public var lockType(get, never) : String;
    public var isLocked(get, never) : Bool;
    private var levelManager(get, never) : ICgsLevelManager;
    public var unlockAchievement(get, never) : String;
    public var unlockStatus(get, never) : Bool;

    public static inline var LOCK_TYPE : String = "AchievementLock";
    
    // Data Keys
    public static inline var UNLOCK_ACHIEVEMENT_KEY : String = "achievement";
    public static inline var UNLOCK_STATUS_KEY : String = "unlockStatus";
    
    // State
    private var m_levelManager : ICgsLevelManager;
    
    // Lock Specific State
    private var m_unlockAchievement : String;
    private var m_unlockStatus : Bool;
    
    public function new(levelManager : ICgsLevelManager)
    {
        m_levelManager = levelManager;
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(lockKeyData : Dynamic = null) : Void
    {
        if (lockKeyData != null)
        {
            // Required field
            m_unlockAchievement = Reflect.field(lockKeyData, UNLOCK_ACHIEVEMENT_KEY);
            
            // Defaults to true if not present
            m_unlockStatus = (Reflect.hasField(lockKeyData, UNLOCK_STATUS_KEY)) ? Reflect.field(lockKeyData, UNLOCK_STATUS_KEY) : true;
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function destroy() : Void
    {
        reset();
        m_levelManager = null;
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        m_unlockAchievement = null;
        m_unlockStatus = false;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_lockType() : String
    {
        return LOCK_TYPE;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isLocked() : Bool
    {
        return checkLock();
    }
    
    /**
		 * 
		 * Internal State
		 * 
		**/
    
    /**
		 * Returns the level manager used by this lock.
		 */
    private function get_levelManager() : ICgsLevelManager
    {
        return m_levelManager;
    }
    
    /**
		 * 
		 * Lock Specific State
		 * 
		**/
    
    /**
		 * Returns the unlockAchievement for this CgsAchievementLock
		 */
    private function get_unlockAchievement() : String
    {
        return m_unlockAchievement;
    }
    
    /**
		 * Returns the unlockStatus for this CgsAchievementLock
		 */
    private function get_unlockStatus() : Bool
    {
        return m_unlockStatus;
    }
    
    /**
		 * 
		 * Lock Checking
		 * 
		**/
    
    /**
		 * Checks the lock and returns whether or not it is locked.
		 * If the achievement cannot be found in the achievement manager, it locks by default
		 */
    private function checkLock() : Bool
    {
        var result : Bool = true;
        var aManager : ICgsAchievementManager = levelManager.achievementManager;
        if (aManager != null && aManager.achievementExists(m_unlockAchievement))
        {
            var achievementStatus : Bool = aManager.getAchievementStatus(m_unlockAchievement);
            result = achievementStatus != m_unlockStatus;
        }
        return result;
    }
    
    /**
		 * 
		 * Key functions
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function doesKeyMatch(keyData : Dynamic) : Bool
    {
        var result : Bool;
        if (keyData == null)
        {
            result = m_unlockAchievement == null;
        }
        else
        {
            // Required field
            var keyAchievement : String = Reflect.field(keyData, UNLOCK_ACHIEVEMENT_KEY);
            
            // Defaults to true if not present
            var keyStatus : Bool = (Reflect.hasField(keyData, UNLOCK_STATUS_KEY)) ? Reflect.field(keyData, UNLOCK_STATUS_KEY) : true;
            
            result = keyAchievement == m_unlockAchievement && keyStatus == m_unlockStatus;
        }
        return result;
    }
}

