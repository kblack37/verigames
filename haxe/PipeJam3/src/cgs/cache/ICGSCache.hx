package cgs.cache;
import cgs.server.logging.gamedata.UserGameData;
import cgs.user.ICgsCacheServerApi;

/**
	 * Interface to the CGS games for the CGSCache.
	 * @author Rich
	 */
interface ICGSCache
{
    
    
    /**
     * Returns the present size of the cache (shared object) in bytes.
     */
    var size(get, never) : Int;

    /**
     * Resets the cache. This does not delete any properties. To delete locally cached items
     * call the clearCache() function.
     */
    function reset() : Void
    ;
    
    /**
     * Removes all properties from the cache. This also resets the server properties as well.
     */
    function clearCacheForAll() : Void
    ;
    
    /**
     * Removes all properties from the cache. This also resets the server properties as well.
		 * @param	uid Optional ID of the user to delete from. If none is provided, the primary will be used.
		 */
    function clearCache(uid : String = null) : Void
    ;
    
    /**
		 * Deletes the given property from the cache, if it exits, for all users.
		 * @param	property The property to be removed.
		 */
    function deleteSaveForAll(property : String) : Void
    ;
    
    /**
     * Deletes the given property from the cache if it exists.
     * @param	property The property to be removed.
		 * @param	uid Optional ID of the user to delete from. If none is provided, the primary will be used.
     */
    function deleteSave(property : String, uid : String = null) : Void
    ;
    
    /**
     * Flush changes made to all users the users save data in the local shared object.
     * This will also send updates to the server if this Cache instance is set to save to the server.
		 * @param	callback Optional callback to be used when completed
		 * @return
		 */
    function flushForAll(callback : Dynamic = null) : Bool
    ;
    
    /**
     * Flush changes made to the users save data in the local shared object.
     * This will also send updates to the server if this Cache instance is set to save to the server.
		 * @param	uid Optional ID of the user to flush. If none is provided, the primary will be used.
		 * @param	callback Optional callback to be used when completed
		 * @return
		 */
    function flush(uid : String = null, callback : Dynamic = null) : Bool
    ;
    
    /**
		 * Registers a new user with the given userID and starting data. 
		 * Will load user's cache if it existed previously, 
     * will create the user's cache if it did not exist previously.
		 * @param	userID Unique ID of user
		 * @param	saveToServer Whether or not this user saves to the server.
     *      Requires a userGameData and a serverApi to be provided to save to server.
     * @param   serverCacheVersion If set to two, use nosql data storage (use this option
     *      if there are many users that will be saving at the same time as it may be better configured for scaling)
		 * @param	userGameData Initial server game data, required if saving to the server.
		 * @param	serverApi Server API used to send data to the server for this user.
     * @param   cacheVersioningKey If serverCacheVersion is set to 2, this key is used to create versioned
     *      save entries so the game can filter data just for specific application releases.
		 */
    function registerUser(
            userID : String, saveToServer : Bool = false, serverCacheVersion : Int = 1,
            userGameData : UserGameData = null, serverApi : ICgsCacheServerApi = null, cacheVersioningKey : String = null) : Void
    ;
    /**
		 * Unregisters the user with the given userID, if any exists.
		 * Unregistering the primary user will revert the primaryUID to the default setting.
		 * The default user can never be unregistered.
		 * @param	userID
		 */
    function unregisterUser(userID : String) : Void
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
		 * @param	uid Optional ID of the user to get from. If none is provided, the primary will be used.
		 * @return
		 */
    function getSave(property : String, uid : String = null) : Dynamic
    ;
    
    /**
     * Creates the given property with the given default value, if it does not already exist, for all players.
		 * Does NOT overwrite the value if the property already exists.
     * @param	property The property to be added.
     * @param	defaultVal The default value of the added property.
		 * @param	flush Whether or not to flush immediately
		 */
    function initSaveForAll(property : String, defaultVal : Dynamic, flush : Bool = true) : Void
    ;
    
    /**
     * Creates the given property with the given default value if it does not already exist.
     * @param	property The property to be added.
     * @param	defaultVal The default value of the added property.
		 * @param	uid Optional ID of the user to save to. If none is provided, the primary will be used.
		 * @param	flush Whether or not to flush immediately
		 */
    function initSave(property : String, defaultVal : Dynamic, uid : String = null, flush : Bool = true) : Void
    ;
    
    /**
     * Returns whether or not the given property already exists in the cache.
     * @param	property The property to look for.
		 * @param	uid Optional ID of the user to check for. If none is provided, the primary will be used.
     * @return
     */
    function saveExists(property : String, uid : String = null) : Bool
    ;
    
    /**
     * Sets the property with the given value (will always override the existing value) for all users.
     * @param	property The property to be updated
     * @param	val The new value of the property
		 * @param	flush Whether or not to flush immediately
		 * @return
		 */
    function setSaveForAll(property : String, val : Dynamic, flush : Bool = true) : Bool
    ;
    
    /**
     * Sets the property with the given value (will always override the existing value).
     * @param	property The property to be updated
     * @param	val The new value of the property
		 * @param	uid Optional ID of the user to save to. If none is provided, the primary will be used.
		 * @param	flush Whether or not to flush immediately
		 * @return
		 */
    function setSave(property : String, val : Dynamic, uid : String = null, flush : Bool = true) : Bool
    ;
    
    /**
     * Indicates if the given user has unsaved cache data that needs to be sent
     * or is being sent to the server.
     * @param	uid Optional ID of the user to check for.
     * If none is provided, the primary will be used.
     * @return true if there is data to be sent to the server.
     */
    function hasUnsavedServerData(uid : String = null) : Bool
    ;
}

