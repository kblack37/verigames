package cgs.levelProgression.locks;

import cgs.levelProgression.locks.ICgsLevelLock;
import cgs.levelProgression.util.ICgsLockFactory;

/**
	 * This lock contains a list of other locks and is unlocked if any of its locks are unlocked
	 * @author Jack
	 */
class CgsOrLock implements ICgsLevelLock
{
    private var lockFactory(get, never) : ICgsLockFactory;
    public var lockType(get, never) : String;
    public var isLocked(get, never) : Bool;
    public var numLocks(get, never) : Int;

    
    //Lock Type Key
    public static inline var LOCK_TYPE : String = "orLock";
    
    // Data Key
    public static inline var LOCKS_KEY : String = "locks";
    
    // State
    private var m_lockFactory : ICgsLockFactory;
    private var m_locks : Array<ICgsLevelLock>;
    
    public function new(lockFactory : ICgsLockFactory)
    {
        m_lockFactory = lockFactory;
        m_locks = new Array<ICgsLevelLock>();
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
        
        // Locks - required
        var lockDatas : Array<Dynamic> = Reflect.field(lockKeyData, LOCKS_KEY);
        
        
        // Create the locks
        for (data in lockDatas)
        {
            m_locks.push(lockFactory.getLockInstance(Reflect.field(data, "lockType"), Reflect.field(data, "lockKey")));
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function destroy() : Void
    {
        m_locks = null;
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        m_locks = new Array<ICgsLevelLock>();
    }
    
    /**
		 * 
		 * Internal State
		 * 
		**/
    
    /**
		 * Return the lock factory
		 */
    private function get_lockFactory() : ICgsLockFactory
    {
        return m_lockFactory;
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
		 * Lock Specific State
		 * 
		**/
    
    /**
		 * Returns the name of the pack this lock is locking on.
		 */
    private function get_numLocks() : Int
    {
        return ((m_locks != null)) ? m_locks.length : 0;
    }
    
    /**
		 * 
		 * Lock Checking
		 * 
		**/
    
    /**
		 * Checks if the lock is locked
		 * @return
		 */
    private function checkLock() : Bool
    {
        var result : Bool = true;
        if (m_locks != null && m_locks.length > 0)
        {
            for (aLock in m_locks)
            {
                result = result && aLock.isLocked;
                // If we find a unlocked lock, we break, because we only need one unlocked lock to be unlocked
                if (!aLock.isLocked)
                {
                    break;
                }
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function doesKeyMatch(keyData : Dynamic) : Bool
    {
        var result : Bool = false;
        if (keyData == null)
        {
            result = m_locks.length == 0;
        }
        else
        {
            if (Std.is(Reflect.field(keyData, LOCKS_KEY), Array))
            {
                // Get key lock datas
                var keyLocks : Array<Dynamic> = Reflect.field(keyData, LOCKS_KEY);
                
                // If there aren't the same number of locks, we already know that they don't match
                if (keyLocks != null && m_locks.length == keyLocks.length)
                {
                    // Making a shallow clone, since we will be removing items from the array as we go
                    keyLocks = keyLocks.copy();
                    
                    result = true;
                    // Look through each of our locks
                    for (i in 0...m_locks.length)
                    {
                        var lock : ICgsLevelLock = m_locks[i];
                        var lockFound : Bool = false;
                        // Check each one against each lock in keyData, remove keydata from list if found
                        for (data in keyLocks)
                        {
                            var dataKey : Dynamic = Reflect.field(data, "lockKey");
                            lockFound = lock.doesKeyMatch(dataKey);
                            
                            // Break if found
                            if (lockFound)
                            {
                                // Remove the matching key
                                keyLocks.splice(Lambda.indexOf(keyLocks, data), 1);
                                break;
                            }
                        }
                        // if any lock is not found, break and set result to false
                        if (!lockFound)
                        {
                            result = false;
                            break;
                        }
                    }
                }
            }
        }
        return result;
    }
}

