package cgs.levelProgression.util;

import cgs.levelProgression.locks.ICgsLevelLock;

/**
	 * ...
	 * @author Rich
	 */
interface ICgsLockFactory
{

    
    /**
		 * 
		 * Node Management
		 * 
		**/
    
    /**
		 * Returns a lock of they given type with the given key.
		 * @param	lockType - The type of lock that needs to be created (TimeLock, NodeLock, etc).
		 * @param	lockKey - The key of the lock.
		 * @return
		 */
    function getLockInstance(lockType : String, lockKeyData : Dynamic) : ICgsLevelLock
    ;
    
    /**
		 * Resets and recycles a lock to the factory
		 * @param	lock
		 */
    function recycleLock(lock : ICgsLevelLock) : Void
    ;
}

