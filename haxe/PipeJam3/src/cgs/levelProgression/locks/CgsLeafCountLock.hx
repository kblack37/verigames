package cgs.levelProgression.locks;

import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.locks.ICgsLevelLock;
import cgs.levelProgression.nodes.ICgsLevelNode;
import cgs.levelProgression.nodes.ICgsLevelPack;
import cgs.levelProgression.nodes.CgsLevelPack;
import cgs.levelProgression.util.CgsLevelProgressionTypes;

/**
	 * ...
	 * @author Jack
	 */
class CgsLeafCountLock implements ICgsLevelLock
{
    public var lockType(get, never) : String;
    public var isLocked(get, never) : Bool;
    private var levelManager(get, never) : ICgsLevelManager;
    public var unlockPackName(get, never) : String;
    public var unlockStatus(get, never) : String;
    public var unlockCount(get, never) : Int;

    public static inline var LOCK_TYPE : String = "LeafCountLock";
    
    // Data Keys
    public static inline var UNLOCK_COUNT_KEY : String = "unlockCount";
    public static inline var UNLOCK_PACK_KEY : String = "unlockPack";
    public static inline var UNLOCK_STATUS_KEY : String = "unlockStatus";
    public static var DEFAULT_STATUS : String = CgsLevelProgressionTypes.NODE_PLAYED;
    
    // State
    private var m_levelManager : ICgsLevelManager;
    
    // Lock Specific State
    private var m_unlockCount : Int;  // The count to unlock at  
    private var m_unlockPackName : String;  // The name of the level pack to look at the count of  
    private var m_unlockStatus : String = DEFAULT_STATUS;  // The status to check the count of  
    
    public function new(levelManager : ICgsLevelManager)
    {
        m_levelManager = levelManager;
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(lockKeyData : Dynamic = null) : Void
    {
        if (lockKeyData == null)
        {
            // Do nothing if no data provided
            return;
        }
        
        // Unlock Count - required
        m_unlockCount = Reflect.field(lockKeyData, UNLOCK_COUNT_KEY);
        
        // Unlock pack - optional (defaults to current level progression)
        m_unlockPackName = (Reflect.hasField(lockKeyData, UNLOCK_PACK_KEY)) ? Reflect.field(lockKeyData, UNLOCK_PACK_KEY) : m_levelManager.currentLevelProgression.nodeName;
        
        // Unlock Status - optional (defaults to DEFAULT_STATUS)
        m_unlockStatus = (Reflect.hasField(lockKeyData, UNLOCK_STATUS_KEY)) ? Reflect.field(lockKeyData, UNLOCK_STATUS_KEY) : DEFAULT_STATUS;
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
        m_unlockCount = 0;
        m_unlockPackName = null;
        m_unlockStatus = DEFAULT_STATUS;
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
		 * Returns the name of the pack this lock is locking on.
		 */
    private function get_unlockPackName() : String
    {
        return m_unlockPackName;
    }
    
    /**
		 * Returns the status this lock is waiting for.
		 */
    private function get_unlockStatus() : String
    {
        return m_unlockStatus;
    }
    
    /**
		 * Gets the unlock Count
		 */
    private function get_unlockCount() : Int
    {
        return m_unlockCount;
    }
    
    /**
		 * 
		 * Lock Checking
		 * 
		**/
    
    /**
		 * Checks the lock and returns whether or not it is locked.
		 */
    private function checkLock() : Bool
    {
        var isLocked : Bool = true;
        
        // Find the level pack we are locked on
        var levelNode : ICgsLevelNode;
        if (m_unlockPackName != null && m_unlockPackName != "")
        {
            levelNode = m_levelManager.getNodeByName(m_unlockPackName);
        }
        else
        {
            levelNode = m_levelManager.currentLevelProgression;
        }
        
        // Verify that the node returned is a level pack. return locked if not
        if (levelNode != null && levelNode.nodeType == CgsLevelPack.NODE_TYPE)
        {
            var levelPack : ICgsLevelPack = try cast(levelNode, ICgsLevelPack) catch(e:Dynamic) null;
            switch (m_unlockStatus)
            {
                // Node Locked
                case (CgsLevelProgressionTypes.NODE_LOCKED):
                    isLocked = levelPack.numLevelLeafsLocked < m_unlockCount;
                // Node Unlocked
                case (CgsLevelProgressionTypes.NODE_UNLOCKED):
                    isLocked = levelPack.numLevelLeafsUnlocked < m_unlockCount;
                // Node Played
                case (CgsLevelProgressionTypes.NODE_PLAYED):
                    isLocked = levelPack.numLevelLeafsPlayed < m_unlockCount;
                // Node Unplayed
                case (CgsLevelProgressionTypes.NODE_UNPLAYED):
                    isLocked = levelPack.numLevelLeafsUnplayed < m_unlockCount;
                // Node Complete
                case (CgsLevelProgressionTypes.NODE_COMPLETE):
                    isLocked = levelPack.numLevelLeafsCompleted < m_unlockCount;
                // Node uncomplete
                case (CgsLevelProgressionTypes.NODE_UNCOMPLETE):
                    isLocked = levelPack.numLevelLeafsUncompleted < m_unlockCount;
                // Default is Node Played
                default:
                    isLocked = levelPack.numLevelLeafsPlayed < m_unlockCount;
            }
        }
        return isLocked;
    }
    
    /**
		 * @inheritDoc
		 */
    public function doesKeyMatch(keyData : Dynamic) : Bool
    {
        var result : Bool = false;
        if (keyData != null)
        {
            // Unlock Count - Required
            var keyUnlockCount : Int = Reflect.field(keyData, UNLOCK_COUNT_KEY);
            
            // Unlock Pack - optional (defaults to current level progression)
            var keyUnlockPackName : String = (Reflect.hasField(keyData, UNLOCK_PACK_KEY)) ? Reflect.field(keyData, UNLOCK_PACK_KEY) : m_levelManager.currentLevelProgression.nodeName;
            
            // Node status - optional (defaults to played if not defined)
            var keyUnlockStatus : String = (Reflect.hasField(keyData, UNLOCK_STATUS_KEY)) ? Reflect.field(keyData, UNLOCK_STATUS_KEY) : DEFAULT_STATUS;
            
            result = keyUnlockCount == m_unlockCount && keyUnlockPackName == m_unlockPackName && keyUnlockStatus == m_unlockStatus;
        }
        return result;
    }
}
