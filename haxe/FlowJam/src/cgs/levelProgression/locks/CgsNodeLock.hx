package cgs.levelProgression.locks;

import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.nodes.ICgsLevelNode;
import cgs.levelProgression.util.CgsLevelProgressionTypes;

/**
	 * ...
	 * @author Rich
	 */
class CgsNodeLock implements ICgsLevelLock
{
    public var lockType(get, never) : String;
    public var isLocked(get, never) : Bool;
    private var levelManager(get, never) : ICgsLevelManager;
    public var unlockNodeName(get, never) : String;
    public var unlockStatus(get, never) : String;

    public static inline var LOCK_TYPE : String = "NodeLock";
    
    // Data Keys
    public static inline var NODE_NAME_KEY : String = "nodeName";
    public static inline var NODE_STATUS_KEY : String = "nodeStatus";
    public static var DEFAULT_STATUS : String = CgsLevelProgressionTypes.NODE_PLAYED;
    
    // State
    private var m_levelManager : ICgsLevelManager;
    
    // Lock Specific State
    private var m_unlockNodeName : String;
    private var m_unlockStatus : String = DEFAULT_STATUS;  // The lock should unlock when the unlock node is at this status  
    
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
        
        // Node name - required
        m_unlockNodeName = Reflect.field(lockKeyData, NODE_NAME_KEY);
        
        // Node status - optional (defaults if not defined)
        m_unlockStatus = (Reflect.hasField(lockKeyData, NODE_STATUS_KEY)) ? Reflect.field(lockKeyData, NODE_STATUS_KEY) : DEFAULT_STATUS;
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
        m_unlockNodeName = null;
        m_unlockStatus = CgsLevelProgressionTypes.NODE_PLAYED;
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
		 * Returns the name of the node this lock is locking on.
		 */
    private function get_unlockNodeName() : String
    {
        return m_unlockNodeName;
    }
    
    /**
		 * Returns the status this lock is waiting for.
		 */
    private function get_unlockStatus() : String
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
		 */
    private function checkLock() : Bool
    {
        // "isLocked" reads better in the switch statement than "result"
        var isLocked : Bool = true;
        
        // Find the node we are locked on
        var levelNode : ICgsLevelNode = levelManager.getNodeByName(m_unlockNodeName);
        
        // Check lock
        if (levelNode != null)
        {
            switch (m_unlockStatus)
            {
                // Unlock if node is locked
                case (CgsLevelProgressionTypes.NODE_LOCKED):
                    isLocked = !levelNode.isLocked;
                // Unlock if node is unlocked
                case (CgsLevelProgressionTypes.NODE_UNLOCKED):
                    isLocked = levelNode.isLocked;
                // Unlock if node is played
                case (CgsLevelProgressionTypes.NODE_PLAYED):
                    isLocked = !levelNode.isPlayed;
                // Unlock if node is unplayed
                case (CgsLevelProgressionTypes.NODE_UNPLAYED):
                    isLocked = levelNode.isPlayed;
                // Unlock if node is complete
                case (CgsLevelProgressionTypes.NODE_COMPLETE):
                    isLocked = !levelNode.isComplete;
                // Unlock if node is uncomplete
                case (CgsLevelProgressionTypes.NODE_UNCOMPLETE):
                    isLocked = levelNode.isComplete;
                // Default behavior is to unlock if the node is played
                default:
                    isLocked = !levelNode.isPlayed;
            }
        }
        
        return isLocked;
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
        var result : Bool = false;
        if (keyData != null)
        {
            // Node name - required
            var keyNodeName : String = Reflect.field(keyData, NODE_NAME_KEY);
            
            // Node status - optional (defaults if not defined)
            var keyStatus : String = (Reflect.hasField(keyData, NODE_STATUS_KEY)) ? Reflect.field(keyData, NODE_STATUS_KEY) : DEFAULT_STATUS;
            
            result = keyNodeName == m_unlockNodeName && keyStatus == m_unlockStatus;
        }
        return result;
    }
}

