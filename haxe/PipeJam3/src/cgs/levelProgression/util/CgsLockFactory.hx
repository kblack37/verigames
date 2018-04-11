package cgs.levelProgression.util;

import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.locks.CgsAchievementLock;
import cgs.levelProgression.locks.CgsAndLock;
import cgs.levelProgression.locks.CgsLeafCountLock;
import cgs.levelProgression.locks.CgsNodeLock;
import cgs.levelProgression.locks.CgsOrLock;
import cgs.levelProgression.locks.CgsTimeLock;
import cgs.levelProgression.locks.ICgsLevelLock;

/**
	 * @author marcfont
	 */
class CgsLockFactory implements ICgsLockFactory
{
    private var levelManager(get, never) : ICgsLevelManager;

    private var m_lockStorage : Dynamic;
    private var m_levelManager : ICgsLevelManager;
    
    public function new(levelManager : ICgsLevelManager)
    {
        m_levelManager = levelManager;
        m_lockStorage = {};
    }
    
    /**
		 * 
		 * Internal State
		 * 
		**/
    
    /**
		 * Returns the levelManager instance used by this level factory.
		 */
    private function get_levelManager() : ICgsLevelManager
    {
        return m_levelManager;
    }
    
    /**
		 * 
		 * Node Management
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function getLockInstance(lockType : String, lockKeyData : Dynamic) : ICgsLevelLock
    {
        // Do nothing if no lock type given
        if (lockType == null || lockType == "")
        {
            return null;
        }
        
        var result : ICgsLevelLock;
        
        // Get the lock storage for this type, creating the storage if this is a new type
        if (!Reflect.hasField(m_lockStorage, lockType))
        {
            // create new array for this type id
            Reflect.setField(m_lockStorage, lockType, new Array<Dynamic>());
        }
        var lockStorage : Array<Dynamic> = Reflect.field(m_lockStorage, lockType);
        
        // Get a lock out of storage
        if (lockStorage.length > 0)
        {
            result = lockStorage.pop();
        }
        else
        {
            // Generate a new lock
            {
                result = generateLockInstance(lockType);
            }
        }
        
        // Init the lock
        if (result != null)
        {
            result.init(lockKeyData);
        }
        
        return result;
    }
    
    /**
		 * Helper for getLockInstance that generates new locks.
		 * @param	lockType - The type of lock to generate.
		 * @return
		 */
    private function generateLockInstance(lockType : String) : ICgsLevelLock
    {
        var result : ICgsLevelLock = null;
        
        switch (lockType)
        {
            case CgsTimeLock.LOCK_TYPE:
                result = new CgsTimeLock();
            case CgsNodeLock.LOCK_TYPE:
                result = new CgsNodeLock(levelManager);
            case CgsAchievementLock.LOCK_TYPE:
                result = new CgsAchievementLock(levelManager);
            case CgsLeafCountLock.LOCK_TYPE:
                result = new CgsLeafCountLock(levelManager);
            case CgsAndLock.LOCK_TYPE:
                result = new CgsAndLock(this);
            case CgsOrLock.LOCK_TYPE:
                result = new CgsOrLock(this);
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function recycleLock(lock : ICgsLevelLock) : Void
    {
        lock.reset();
        Reflect.field(m_lockStorage, Std.string(lock.lockType)).push(lock);
    }
}

