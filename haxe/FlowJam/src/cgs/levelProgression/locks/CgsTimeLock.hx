package cgs.levelProgression.locks;


/**
	 * ...
	 * @author Rich
	 */
class CgsTimeLock implements ICgsLevelLock
{
    public var lockType(get, never) : String;
    public var isLocked(get, never) : Bool;
    public var unlockTime(get, never) : Float;

    public static inline var LOCK_TYPE : String = "TimeLock";
    
    // Data Keys
    public static inline var TIME_KEY : String = "unlockTime";
    
    // Lock Specific State
    private var m_unlockTime : Float = 0;
    
    public function new()
    {  // do nothing  
        
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
        
        // Lock time - required
        m_unlockTime = Reflect.field(lockKeyData, TIME_KEY);
    }
    
    /**
		 * @inheritDoc
		 */
    public function destroy() : Void
    {
        reset();
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        m_unlockTime = 0;
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
		 * Returns the unlockTime of this lock.
		 */
    private function get_unlockTime() : Float
    {
        return m_unlockTime;
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
        var curTime : Float = Date.now().getTime() / 1000; // Converting current time to seconds  
        var isLocked : Bool = curTime < m_unlockTime;
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
            // Lock time - required
            var keyTime : Float = Reflect.field(keyData, TIME_KEY);
            
            result = keyTime == m_unlockTime;
        }
        return result;
    }
}

