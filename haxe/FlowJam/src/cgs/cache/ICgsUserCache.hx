package cgs.cache;

interface ICgsUserCache
{
    
    /**
		 * Returns the present size of the cache (shared object) in bytes.
		 */
    var size(get, never) : Int;

    
    /**
		 * Removes all properties from the cache. This also resets the server properties as well.
		 */
    function clearCache() : Void
    ;
    
    /**
		 * Deletes the given property from the cache if it exists.
		 * @param	property The property to be removed.
		 */
    function deleteSave(property : String) : Void
    ;
    
    /**
		 * Flush changes made to the users save data in the local shared object.
		 * This will also send updates to the server if this Cache instance is set to save to the server.
		 * @param	callback Optional callback to be used when completed
		 * @return
		 */
    function flush(callback : Dynamic = null) : Bool
    ;
    
    /**
		 * Register a callback listener for data saved on the server. This is used for testing
		 * and can also be used by games to detect failures to saving data on the server.
		 * Once the data has been saved on the server this callback is called.
		 * Only one callback can be registered per property.
		 * @param	property The unqiue id for data being saved.
		 * @param	callback Callback when completed.
		 */
    function registerSaveCallback(property : String, callback : Dynamic) : Void
    ;
    
    /**
		 * Remove the callback fuction that has been registered for the given property.
		 * @param	property
		 */
    function unregisterSaveCallback(property : String) : Void
    ;
    
    /**
		 * Attempts to retrieve the given property, may return null if not found.
		 * @param	property The property to be retrieved.
		 * @return
		 */
    function getSave(property : String) : Dynamic
    ;
    
    /**
		 * Creates the given property with the given default value if it does not already exist.
		 * @param	property The property to be added.
		 * @param	defaultVal The default value of the added property.
		 * @param	flush Whether or not to flush immediately
		 */
    function initSave(property : String, defaultVal : Dynamic, flush : Bool = true) : Void
    ;
    
    /**
		 * Returns whether or not the given property already exists in the cache.
		 * @param	property The property to look for.
		 * @return
		 */
    function saveExists(property : String) : Bool
    ;
    
    /**
		 * Sets the property with the given value (will always override the existing value).
		 * @param	property The property to be updated
		 * @param	val The new value of the property
		 * @param	flush Whether or not to flush immediately
		 * @return
		 */
    function setSave(property : String, val : Dynamic, flush : Bool = true) : Bool
    ;
}
