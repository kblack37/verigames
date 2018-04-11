package cgs.levelProgression.locks;


/**
	 * ...
	 * @author Rich
	 */
interface ICgsLevelLock
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the lock type of this Level Lock.
		 */
    var lockType(get, never) : String;    
    
    /**
		 * Returns whether or not this Level Lock is unlocked.
		 */
    var isLocked(get, never) : Bool;

    
    /**
		 * Initializes this lock with the given lockKeyData.
		 * @param	lockKeyData - The data object defining the lock's key (the values that will cause it to be unlocked or locked).
		 */
    function init(lockKeyData : Dynamic = null) : Void
    ;
    
    /**
		 * Destroys this lock.
		 */
    function destroy() : Void
    ;
    
    /**
		 * Resets this lock.
		 */
    function reset() : Void
    ;
    
    /**
		 * 
		 * Key functions
		 * 
		**/
    
    /**
		 * Returns whether or not the given key data matches the key data of this lock.
		 * @param	keyData
		 * @return
		 */
    function doesKeyMatch(keyData : Dynamic) : Bool
    ;
}

