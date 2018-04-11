package cgs.cache;

import cgs.server.logging.gamedata.UserGameData;
import cgs.user.ICgsCacheServerApi;
import cgs.cache.CacheFlushStatus;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import openfl.errors.Error;
import openfl.net.SharedObject;
import openfl.utils.Dictionary;



/**
	 * This is the main implementation of the CGS Cache object. It can cache data for 1+ unique players simultaneously.
	 * @author Rich
	 */
class CGSCache implements ICGSCache
{
    public var primaryUID(get, set) : String;
    public var size(get, never) : Int;

    private static inline var CACHE_NAME_OF_DEFAULT_PLAYER : String = "defaultPlayerCache";
    private static inline var CACHE_USER_PREFIX : String = "cgs.Cache.CGSCache.";
    
    // State
    private var m_privateCache : PrivateCache;
    private var m_primaryUserID : String;
    
    // Users
    private var m_registeredUUIDs : Array<String>;
    private var m_playerCaches : Dynamic;
    
    public function new()
    {
        init();
    }
    
    private function init() : Void
    {
        // Object creation
        m_privateCache = new PrivateCache();
        m_registeredUUIDs = new Array<String>();
        m_playerCaches = {};
        
        // Setup default user and migrate any old data
        m_primaryUserID = CACHE_NAME_OF_DEFAULT_PLAYER;
        registerUser(m_primaryUserID);
        m_privateCache.migrateOldCacheData(CACHE_USER_PREFIX, getPlayerCacheForUser(m_primaryUserID));
    }
    
    /**
     * Destroys (disconnects) the cache (so it can be garbage collected). 
		 * This does not delete any properties. To delete locally cached items call the clearCache() function.
     */
    public function destroy() : Void
    {
        // Disconnect private cache
        m_privateCache = null;
        
        // Disconnect player caches
        while ((m_registeredUUIDs != null) && m_playerCaches && m_registeredUUIDs.length > 0)
        {
            var registeredUser : String = m_registeredUUIDs.pop();
            var pCache : PlayerCache = try cast(Reflect.field(m_playerCaches, registeredUser), PlayerCache) catch(e:Dynamic) null;
            pCache.destroy();
            Reflect.setField(m_playerCaches, registeredUser, null);
        }
        m_registeredUUIDs = null;
        m_playerCaches = null;
    }
    
    /**
     * Resets the cache. This does not delete any properties. To delete locally cached items
     * call the clearCache() function.
     */
    public function reset() : Void
    {
        destroy();
        init();
    }
    
    /**
     *
     * State
     *
    **/
    
    /**
		 * Returns the player cache associated with the given userID.
		 * Will return the primary user's PlayerCache if no userID is provided or the userID is not registered.
		 * @param	userID
		 * @return
		 */
    private function getPlayerCacheForUser(userID : String = null) : PlayerCache
    {
        return try cast(Reflect.field(m_playerCaches, Std.string(chooseUserID(userID))), PlayerCache) catch(e:Dynamic) null;
    }
    
    /**
		 * Returns the UID of the current primary user.
		 */
    private function get_primaryUID() : String
    {
        return m_primaryUserID;
    }
    
    /**
		 * Sets the UID of the current primary user to be the given value.
		 * The provided UID must be of a currently registered user.
		 * Providing a value of null will return the CGS Cache to the original default UID.
		 */
    private function set_primaryUID(value : String) : String
    {
        if (value == null)
        {
            value = CACHE_NAME_OF_DEFAULT_PLAYER;
        }
        
        if (userRegistered(convertUidToCacheName(value)))
        {
            m_primaryUserID = value;
        }
        return value;
    }
    
    /**
     * Returns the present size of the cache (shared object) in bytes.
     */
    private function get_size() : Int
    {
        return m_privateCache.size;
    }
    
    /**
		 * Returns whether or not the user with the given userID is already registered.
		 * @param	userID ID for the user in question.
		 * @return
		 */
    public function userRegistered(userID : String) : Bool
    {
        return userID != null && userID != "" && Lambda.indexOf(m_registeredUUIDs, userID) >= 0;
    }
    
    /**
     *
     * Clearing
     *
    **/
    
    /**
     * Removes all properties from the cache. This also resets the server properties as well.
     */
    public function clearCacheForAll() : Void
    {
        // Clear cache for all players
        for (registeredUser in m_registeredUUIDs)
        {
            clearCache(registeredUser);
        }
        
        // Clear the shared object, just in case something got missed
        m_privateCache.clearSharedObject();
    }
    
    /**
     * Removes all properties from the cache. This also resets the server properties as well.
		 * @param	uid Optional ID of the user to delete from. If none is provided, the primary will be used.
		 */
    public function clearCache(uid : String = null) : Void
    {
        getPlayerCacheForUser(uid).clearCache();
    }
    
    /**
		 * Deletes the given property from the cache, if it exits, for all users.
		 * @param	property The property to be removed.
		 */
    public function deleteSaveForAll(property : String) : Void
    {
        // Delete from everyone
        for (registeredUser in m_registeredUUIDs)
        {
            deleteSave(property, registeredUser);
        }
    }
    
    /**
     * Deletes the given property from the cache if it exists.
     * @param	property The property to be removed.
		 * @param	uid Optional ID of the user to delete from. If none is provided, the primary will be used.
     */
    public function deleteSave(property : String, uid : String = null) : Void
    {
        getPlayerCacheForUser(uid).deleteSave(property);
    }
    
    /**
     *
     * Flushing
     *
    **/
    
    /**
     * Flush changes made to all users the users save data in the local shared object.
     * This will also send updates to the server if this Cache instance is set to save to the server.
		 * @param	callback Optional callback to be used when completed
		 * @return
		 */
    public function flushForAll(callback : Dynamic = null) : Bool
    {
        var result : Bool = true;
        var totalUsersToFlush : Int = 0;
        var totalUsersFlushed : Int = 0;
        
        /**
			 * Callback used to track when all the user caches have been flushed.
			 * If you do not like internal functions like this, you can thank Eric for convincing me it is OK from time to time.
			 */
        function flushForAllCallback() : Void
        {
            totalUsersFlushed++;
            
            // Callback once all users are flushed
            if (totalUsersFlushed >= totalUsersToFlush)
            {
                callback();
            }
        };
        
        // Flush each user, use a flushForAllCallback to only use the specified callback once all users have flushed and called back on their own
        for (registeredUser in m_registeredUUIDs)
        {
            // Lets only bother with the flushForAllCallback if there is a callback to be used
            if (callback != null)
            {
                totalUsersToFlush++;
                flush(registeredUser, flushForAllCallback);
            }
            else
            {
                result = result && flush(registeredUser);
            }
        }
        
        return result;
    }
    
    /**
     * Flush changes made to the users save data in the local shared object.
     * This will also send updates to the server if this Cache instance is set to save to the server.
		 * @param	uid Optional ID of the user to flush. If none is provided, the primary will be used.
		 * @param	callback Optional callback to be used when completed
		 * @return
		 */
    public function flush(uid : String = null, callback : Dynamic = null) : Bool
    {
        return getPlayerCacheForUser(uid).flushPlayerCache(callback);
    }
    
    /**
     * Indicates if the given user has unsaved cache data that needs to be sent
     * or is being sent to the server.
     */
    public function hasUnsavedServerData(uid : String = null) : Bool
    {
        return getPlayerCacheForUser(uid).hasUnsavedServerData;
    }
    
    /**
     *
     * Register Users
     *
    **/
    
    /**
		 * Turns the given uid into the name used by the cache. The name has the form CACHE_USER_PREFIX + uid. 
		 * Will make sure the uid does not already have the prefix before it is added.
		 * @param	uid User ID to be converted to a Cache name
		 */
    private function convertUidToCacheName(uid : String) : String
    {
        // Only add the prefix if it does not already exist.
        return ((uid.indexOf(CACHE_USER_PREFIX) >= 0) ? uid : CACHE_USER_PREFIX + uid);
    }
    
    /**
		 * Helper function to decide whether to use the given ID or to use the primary UID.
		 * @param	uid
		 */
    private function chooseUserID(userID : String) : String
    {
        if (userID != null)
        {
            userID = convertUidToCacheName(userID);
            if (!userRegistered(userID))
            {
                userID = convertUidToCacheName(m_primaryUserID);
            }
        }
        else
        {
            userID = convertUidToCacheName(m_primaryUserID);
        }
        return userID;
    }
    
    /**
		 * @inheritDoc
     */
    public function registerUser(
            userID : String, saveToServer : Bool = false, serverCacheVersion : Int = 1,
            userGameData : UserGameData = null, serverApi : ICgsCacheServerApi = null, cacheVersioningKey : String = null) : Void
    {
        // We reject null user IDs
        if (userID == null)
        {
            throw new Error("userID provided to CGSCache.registerUser() is null! Must provide valid (non-null) userID");
            return;
        }
        
        userID = convertUidToCacheName(userID);
        // Only create a new user if it is not already registered
        if (!userRegistered(userID))
        {
            var newPlayerCache : PlayerCache = null;
            
            // Create Player Cache
            if (saveToServer)
            {
                // Only set a player to save to server if the server has been specified and a userGameData is specified
                if (userGameData != null && serverApi != null)
                {
                    // PlayerCache and PrivateCache rely on the server and usergamedata existing when saveToServer == true; consult Rich before changing
                    newPlayerCache = new PlayerCache(
                            m_privateCache, userID, saveToServer, 
                            serverCacheVersion, userGameData, serverApi, cacheVersioningKey);
                }
                else
                {
                    // TODO: Do we really want to throw an error? Can we make it fail silently? Maybe set it to not save to server, or not register at all!
                    var userGameDataExistsText : String = ((userGameData != null) ? "" : "not ") + "been specified";
                    var serverApiExistsText : String = ((serverApi != null) ? "" : "not ") + "been specified";
                    throw new Error("CGSCache - Register User: User " + userID + " cannot save to server: userGameData has " + userGameDataExistsText + " and serverApi has " + serverApiExistsText);
                    
                    // Default to not saving to server
                    newPlayerCache = new PlayerCache(m_privateCache, userID);
                }
            }
            else
            {
                // Not saving to server
                newPlayerCache = new PlayerCache(m_privateCache, userID);
            }
            
            // Check for first non-default player
            var isFirstRealPlayer : Bool = (m_registeredUUIDs.length == 1 && userRegistered(CACHE_NAME_OF_DEFAULT_PLAYER));
            
            // Remember the userID and the associated Player Cache
            m_registeredUUIDs.push(userID);
            Reflect.setField(m_playerCaches, userID, newPlayerCache);
            
            // If this is the first real player to be registered, make them the primay UID instead of the default player
            if (isFirstRealPlayer)
            {
                primaryUID = userID;
            }
        }
    }
    
    /**
		 * Unregisters the user with the given userID, if any exists.
		 * Unregistering the primary user will revert the primaryUID to the default setting.
		 * The default user can never be unregistered.
		 * @param	userID
		 */
    public function unregisterUser(userID : String) : Void
    {
        userID = convertUidToCacheName(userID);
        
        // Do not unregister default user ever
        if (userID == convertUidToCacheName(CACHE_NAME_OF_DEFAULT_PLAYER))
        {
            return;
        }
        
        // Unregister the user if it is registered
        if (userRegistered(userID))
        {
            // Clear stored Player Cache
            var pCache : PlayerCache = try cast(Reflect.field(m_playerCaches, userID), PlayerCache) catch(e:Dynamic) null;
            pCache.destroy();
            Reflect.setField(m_playerCaches, userID, null);
            
            // Remove userID from list of registered UUIDs
            m_registeredUUIDs.splice(Lambda.indexOf(m_registeredUUIDs, userID), 1);
            
            // Set primary UID back to default if this users was the primary UID
            if (userID == convertUidToCacheName(primaryUID))
            {
                primaryUID = null;
            }
        }
    }
    
    /**
     *
     * Save Callbacks
     *
    **/
    
    /**
     * Register a callback listener for data saved on the server. This is used for testing
     * and can also be used by games to detect failures to saving data on the server.
     * Once the data has been saved on the server this callback is called.
     * Only one callback can be registered per property.
     * @param	property The unqiue id for data being saved.
		 * @param	callback Callback when completed.
		 */
    public function registerSaveCallback(property : String, callback : Dynamic) : Void
    {
        m_privateCache.registerSaveCallback(property, callback);
    }
    
    /**
     * Remove the callback fuction that has been registered for the given property.
		 * @param	property
		 */
    public function unregisterSaveCallback(property : String) : Void
    {
        m_privateCache.unregisterSaveCallback(property);
    }
    
    /**
     *
     * Saving
     *
    **/
    
    /**
     * Attempts to retrieve the given property, may return null if not found.
     * @param	property The property to be retrieved.
		 * @param	uid Optional ID of the user to get from. If none is provided, the primary will be used.
		 * @return
		 */
    public function getSave(property : String, uid : String = null) : Dynamic
    {
        return getPlayerCacheForUser(uid).getSave(property);
    }
    
    /**
     * Creates the given property with the given default value, if it does not already exist, for all players.
		 * Does NOT overwrite the value if the property already exists.
     * @param	property The property to be added.
     * @param	defaultVal The default value of the added property.
		 * @param	flush Whether or not to flush immediately
		 */
    public function initSaveForAll(property : String, defaultVal : Dynamic, flush : Bool = true) : Void
    {
        // Init for everyone
        for (registeredUser in m_registeredUUIDs)
        {
            initSave(property, defaultVal, registeredUser, flush);
        }
    }
    
    /**
     * Creates the given property with the given default value if it does not already exist.
     * @param	property The property to be added.
     * @param	defaultVal The default value of the added property.
		 * @param	uid Optional ID of the user to save to. If none is provided, the primary will be used.
		 * @param	flush Whether or not to flush immediately
		 */
    public function initSave(property : String, defaultVal : Dynamic, uid : String = null, flush : Bool = true) : Void
    {
        getPlayerCacheForUser(uid).initSave(property, defaultVal, flush);
    }
    
    /**
     * Returns whether or not the given property already exists in the cache.
     * @param	property The property to look for.
		 * @param	uid Optional ID of the user to check for. If none is provided, the primary will be used.
     * @return
     */
    public function saveExists(property : String, uid : String = null) : Bool
    {
        return getPlayerCacheForUser(uid).saveExists(property);
    }
    
    /**
     * Sets the property with the given value (will always override the existing value) for all users.
     * @param	property The property to be updated
     * @param	val The new value of the property
		 * @param	flush Whether or not to flush immediately
		 * @return
		 */
    public function setSaveForAll(property : String, val : Dynamic, flush : Bool = true) : Bool
    {
        // Set for all users
        var result : Bool = true;
        for (registeredUser in m_registeredUUIDs)
        {
            result = result && setSave(property, val, registeredUser, flush);
        }
        return result;
    }
    
    /**
     * Sets the property with the given value (will always override the existing value).
     * @param	property The property to be updated
     * @param	val The new value of the property
		 * @param	uid Optional ID of the user to save to. If none is provided, the primary will be used.
		 * @param	flush Whether or not to flush immediately
		 * @return
		 */
    public function setSave(property : String, val : Dynamic, uid : String = null, flush : Bool = true) : Bool
    {
        return getPlayerCacheForUser(uid).setSave(property, val, flush);
    }
}




/**
 * 
 * 
 *
 * Player Cache
 * 
 * 
 *
**/

/**
 * This is an internal CGSCache class responsible for handling the Cache of a single player. 
 * This class is primarily used to coordinate individual player caches when 2+ unique players exist. 
 * @author Rich
 */
class PlayerCache
{
    public var hasUnsavedServerData(get, never) : Bool;
    public var cacheUUID(get, never) : String;
    private var nextSaveId(get, never) : Int;

    // State
    private var m_privateCache : PrivateCache;
    private var m_cacheUUID : String;  // Unique user ID of this cache object, such as "default" or the player's CGSServer uuid  
    
    // Server interaction
    private var m_saveToServer : Bool;
    private var m_userGameData : UserGameData;
    private var m_serverApi : ICgsCacheServerApi;
    private var m_updateMap : StringMap<Dynamic>;
    private var m_updateCount : Int;
    
    // Flush state
    private var m_serverSaveIdGen : Int;  // Counter for server save id's. Used to track state inconsistencies between client and server.  
    private var m_flushStatusMap : IntMap<CacheFlushStatus>;
    private var m_savingData : StringMap<Dynamic>;
    private var m_savingDataCount : Int;
    
    private var m_serverCacheVersion : Int;
    private var m_cacheVersioningKey : String;
    
    public function new(
            privateCache : PrivateCache, uniqueID : String,
            saveToServer : Bool = false, serverCacheVersion : Int = 1,
            userGameData : UserGameData = null, serverApi : ICgsCacheServerApi = null, cacheVersioningKey : String = null)
    {
        // State
        m_privateCache = privateCache;
        m_cacheUUID = uniqueID;
        
        // Flush State
        m_flushStatusMap = new IntMap<CacheFlushStatus>();
        m_savingData = new StringMap<Dynamic>();
        
        m_serverCacheVersion = serverCacheVersion;
        m_cacheVersioningKey = cacheVersioningKey;
        
        // Create server related objects if we will be saving to the server
        if (saveToServer)
        {
            m_saveToServer = saveToServer;
            m_userGameData = userGameData;
            m_updateMap = new StringMap<Dynamic>();
            m_updateCount = 0;
            m_savingDataCount = 0;
            m_serverApi = serverApi;
            cloneServerDataToSharedObject();
        }
    }
    
    private function get_hasUnsavedServerData() : Bool
    {
        return m_updateCount > 0 || m_savingDataCount > 0;
    }
    
    /**
	 * Copies all of the data in the userGameData, if any, into the shared object for this player.
	 * This will overwrite any values in the shared object.
	 */
    private function cloneServerDataToSharedObject() : Void
    {
        if (m_userGameData != null)
        {
            // Copy all data from the userGameData to the shared object
            for (dataKey/* AS3HX WARNING could not determine type for var: dataKey exp: EField(EIdent(m_userGameData),keys) type: null */ in m_userGameData.keys)
            {
                var dataValue : Dynamic = m_userGameData.getData(dataKey);
                m_privateCache.setSaveToSharedObject(dataKey, dataValue, m_cacheUUID);
            }
            flushPlayerCache();
        }
    }
    
    /**
	 * Destroys (disconnects) this Player Cache. This does not delete any properties. To delete locally cached items
	 * call the clearCache() function.
	 */
    public function destroy() : Void
    {
        // Destroy basic state
        m_privateCache = null;
        m_cacheUUID = null;
        
        // Destroy server related objects, if saving to server
        if (m_saveToServer)
        {
            m_saveToServer = false;
            m_userGameData = null;
            m_updateMap = null;
            m_updateCount = 0;
        }
    }
    
    /**
	 *
	 * State
	 *
	**/
    
    /**
	 * Returns the unique name of this Player Cache object.
	 */
    private function get_cacheUUID() : String
    {
        return m_cacheUUID;
    }
    
    /**
	 *
	 * Clearing
	 *
	**/
    
    /**
	 * Removes all properties from this player cache. This also resets the server properties as well.
	 */
    public function clearCache() : Void
    {
        // Set server values to null
        if (m_saveToServer)
        {
            for (dataKey/* AS3HX WARNING could not determine type for var: dataKey exp: EField(EIdent(m_userGameData),keys) type: null */ in m_userGameData.keys)
            {
                setSave(dataKey, null, false);
            }
            flushPlayerCache();
        }
        
        // Clear shared object
        m_privateCache.clearSharedObjectForUser(m_cacheUUID);
    }
    
    /**
	 * Deletes the given property from the cache if it exists.
	 * @param	property The property to be removed.
	 */
    public function deleteSave(property : String) : Void
    {
        // Clear from server
        if (m_saveToServer)
        {
            setSave(property, null, true);
        }
        
        // Clear from shared object
        m_privateCache.deleteSaveFromSharedObject(property, m_cacheUUID);
    }
    
    /**
	 *
	 * Flush to Server
	 *
	**/
    
    /**
	 * Flush changes made to the users save data in the local shared object.
	 * This will also send updates to the server if this Cache instance is set to save to the server.
	 * @param	callback Optional callback to be used when completed
	 * @return
	 */
    public function flushPlayerCache(callback : Dynamic = null) : Bool
    {
        var flushStatus : CacheFlushStatus = null;
        if (m_saveToServer)
        {
            // Update flush status map
            var flushSaveId : Int = nextSaveId;
            if (callback != null)
            {
                flushStatus = new CacheFlushStatus(flushSaveId, m_updateCount, callback);
                m_flushStatusMap.set(flushSaveId, flushStatus);
            }
            
            // Flush all values
            var serverData : StringMap<Dynamic> = new StringMap<Dynamic>();
            var value : Dynamic;
            for (key in m_updateMap.keys())
            {
                // Move each key-value in the update map to the shared object and userGameData
                value = m_updateMap.get(key);
                m_privateCache.setSaveToSharedObject(key, value, m_cacheUUID);  // Do we need to do this twice? I guess it cannot hurt  
                m_userGameData.updateData(key, value);
                m_savingData.set(key, value);  // For tracking, to make sure the data made it to the server  
                ++m_savingDataCount;
                m_updateMap.remove(key);  // Update flush status with key  ;
                
                
                
                if (flushStatus != null)
                {
                    flushStatus.addDataKey(key);
                }
                
                serverData.set(key, value);
            }
            
            sendSaveDataToServer(serverData, flushSaveId);
            m_updateCount = 0;
        }
        
        // Flush to shared object
        var localFlushSuccess : Bool = m_privateCache.flushPrivateCache();
        
        // Update the status of the local save.
        if (callback != null)
        {
            if (flushStatus == null)
            {
                flushStatus = new CacheFlushStatus(0, 0, callback);
            }
            flushStatus.localFlushStatus = localFlushSuccess;
            if (flushStatus.completed())
            {
                flushStatus.makeCompleteCallback();
            }
        }
        
        return localFlushSuccess;
    }
    
    private function sendSaveDataToServer(data : StringMap<Dynamic>, flushSaveId : Int) : Void
    {
        // Send the data as a batch of items
        m_serverApi.batchSaveGameData(data, m_cacheVersioningKey, flushSaveId, handleBatchDataSaved, m_serverCacheVersion);
    }
    
    private function handleBatchDataSaved(props : Array<Dynamic>, failed : Bool, saveId : Int) : Void
    {
        for (property in props)
        {
            handleDataSaved(property, failed, saveId);
        }
    }
    
    /**
	 * Handle the update message from the server.
	 * @param	property Property being flushed.
	 * @param	failed Whether or not the flush failed.
	 * @param	saveId ID of flush status for flush tracking purposes.
	 */
    private function handleDataSaved(property : String, failed : Bool, saveId : Int) : Void
    {
        if (!failed)
        {
            --m_savingDataCount;
            m_savingData.remove(property);
        }
        
        // Tracking for each individual property being set
        if (m_flushStatusMap.exists(saveId))
        {
            var flushStatus : CacheFlushStatus = m_flushStatusMap.get(saveId);
            flushStatus.updateDataSaveStatus(property, !failed);
            if (flushStatus.completed())
            {
                m_flushStatusMap.remove(saveId);
                flushStatus.makeCompleteCallback();
            }
        }
        
        // Save Callbacks for each property
        m_privateCache.callSaveCallback(property, failed);
    }
    
    /**
	 * Returns the next save ID.
	 */
    private function get_nextSaveId() : Int
    {
        return ++m_serverSaveIdGen;
    }
    
    /**
	 *
	 * Saving
	 *
	**/
    
    /**
	 * Attempts to retrieve the given property, may return null if not found.
	 * @param	property The property to be retrieved.
	 * @return
	 */
    public function getSave(property : String) : Dynamic
    {
        // resultFound is used in case the result found is null, thus we do not want to check the result itself to see if it has been found
        // Use Case: value for prop is set to null, does not get reflected in shared object, want to return null as result
        var resultFound : Bool = false;
        var result : Dynamic = null;
        
        // Saving to server, check there first
        if (m_saveToServer)
        {
            // Value still in update map
            if (m_updateMap.exists(property))
            {
                result = m_updateMap.get(property);
                resultFound = true;
            }
            else
            {
                // Value found in userGameData (on database)
				if (m_userGameData.isServerDataLoaded && m_userGameData.containsData(property))
                {
                    result = m_userGameData.getData(property);
                    resultFound = true;
                }
            }
        }
        
        // Pull the value from the shared object
        if (!resultFound)
        {
            result = m_privateCache.getSaveFromSharedObject(property, m_cacheUUID);
        }
        
        return result;
    }
    
    /**
	 * Creates the given property with the given default value if it does not already exist.
	 * @param	property The property to be added.
	 * @param	defaultVal The default value of the added property.
	 * @param	flush Whether or not to flush immediately
	 */
    public function initSave(property : String, defaultVal : Dynamic, flush : Bool = true) : Void
    {
        // Only init a save for something that does not already exist.
        // We are assuming saveExists will err on the side of saying the save exists when it does not than the other way around.
        if (!saveExists(property))
        {
            setSave(property, defaultVal, flush);
        }
    }
    
    /**
	 * Returns whether or not the given property already exists in the cache.
	 * @param	property The property to look for.
	 * @return
	 */
    public function saveExists(property : String) : Bool
    {
        // We are checking the shared object first. If it exists there, it certainly exists.
        var result : Bool = m_privateCache.saveExistsInSharedObject(property, m_cacheUUID);
        
        // Lets check the server too if not found in the shared object
        if (!result && m_saveToServer)
        {
            var sharedObjectWorking : Bool = m_privateCache.sharedObjectExists;
            
            // Check the update map for the property. If the update map has a value of null for the property, that could could mean it got deleted.
            // We can only assume this if the shared object is working, meaning the property was not found there either.
            result = m_updateMap.exists(property) && (sharedObjectWorking || m_updateMap.get(property) != null);
            
            // Same spiel, this time for userGameData.
            if (!result)
            {
                result = (m_userGameData.isServerDataLoaded && m_userGameData.containsData(property)) && (sharedObjectWorking || m_userGameData.getData(property) != null);
            }
        }
        
        return result;
    }
    
    /**
	 * Sets the property with the given value (will always override the existing value).
	 * @param	property The property to be updated
	 * @param	val The new value of the property
	 * @param	flush Whether or not to flush immediately
	 * @return
	 */
    public function setSave(property : String, val : Dynamic, flush : Bool = true) : Bool
    {
        // Save to shared object
        var result : Bool = m_privateCache.setSaveToSharedObject(property, val, m_cacheUUID);
        
        // Save to server
        if (m_saveToServer)
        {
            if (!m_updateMap.exists(property))
            {
                m_updateCount++;
            }
            m_updateMap.set(property, val);
        }
        
        // Flush if told to. The Shared Object does need to be flushed from time to time, so this is not only for the server.
        if (flush)
        {
            result = result && flushPlayerCache();
        }
        
        return result;
    }
}

/**
 * 
 * 
 *
 * Private Cache
 * 
 * 
 *
**/

/**
 * This is an internal CGSCache class to handle the saving and loading of data to/from the shared object and
 * the database via CGSServer.
 * @author Rich
 */
class PrivateCache
{
    public var sharedObjectExists(get, never) : Bool;
    public var size(get, never) : Int;

    // State
    private var m_sharedObject : SharedObject;
    
    // Save Callbacks
    private var m_serverSaveCallbackMap : StringMap<Dynamic>;
    
    public function new()
    {
        m_serverSaveCallbackMap = new StringMap<Dynamic>();
    }
    
    /**
	 *
	 * State
	 *
	**/
    
    /**
	 * Returns whether or not the shared object presently exists.
	 */
    private function get_sharedObjectExists() : Bool
    {
        var result : Bool = m_sharedObject != null;
        if (!result)
        {
            try
            {
                m_sharedObject = SharedObject.getLocal("userData");
                result = true;
            }
            catch (err : Error)
            {
                trace("ERROR: Unable to obtain the Shared Object - aka The Flash Cache");
            }
        }
        return result;
    }
    
    /**
	 * Returns the present size of the shared object in bytes.
	 */
    private function get_size() : Int
    {
        return (m_sharedObject != null) ? m_sharedObject.size : 0;
    }
    
    /**
	 *
	 * Backwards Compatability
	 *
	**/
    
    /**
	 * Examines the shared object for data from older versions of caching and puts all of the data into
	 * the default user. If no user is provided, no data will be transferred.
	 * @param	prefix Prefix used to identify users from the current version of the Cache.
	 * @param	defaultUser User to migrate all old cache data to.
	 */
    public function migrateOldCacheData(prefix : String, defaultUser : PlayerCache) : Void
    {
        if (sharedObjectExists && defaultUser != null)
        {
            // Collect list of old properties
            var oldPropertiesInCache : Array<String> = new Array<String>();
            for (property in Reflect.fields(m_sharedObject.data))
            {
                if (property != null && property.indexOf(prefix) < 0)
                {
                    oldPropertiesInCache.push(property);
                }
            }
            
			var property:String;
            // Migrate all values to default player
            while (oldPropertiesInCache.length > 0)
            {
                property = oldPropertiesInCache.pop();
                var value : Dynamic = Reflect.getProperty(m_sharedObject.data, property);
                defaultUser.setSave(property, value, false);
            }
            
            // Flush
            defaultUser.flushPlayerCache();
        }
    }
    
    /**
	 *
	 * Clearing
	 *
	**/
    
    /**
	 * Removes all properties from the shared object only.
	 */
    public function clearSharedObject() : Void
    {
        // Clear the shared object
        if (sharedObjectExists)
        {
            m_sharedObject.clear();
        }
    }
    
    /**
	 * Removes all properties from the shared object only.
	 */
    public function clearSharedObjectForUser(userID : String) : Void
    {
        // Clear the shared object
        if (sharedObjectExists && Reflect.hasField(m_sharedObject.data, userID))
        {
            // Delete the user!
			Reflect.deleteField(m_sharedObject.data, userID);
			
			// Immediately flush;
            try
            {
                m_sharedObject.flush();
            }
            catch (err : Error)
            {
                trace("ERROR: Flush Failed! " + err.message);
            }
        }
    }
    
    /**
	 * Deletes the given property from the shared object if it exists.
	 * @param	property The property to be removed.
	 * @param	userID ID of the user to remove from.
	 */
    public function deleteSaveFromSharedObject(property : String, userID : String) : Void
    {
        if (sharedObjectExists && saveExistsInSharedObject(property, userID))
        {
            // Get the user's cache
            var userCache : Dynamic = Reflect.getProperty(m_sharedObject.data, userID);
            
            // Delete property!
            Reflect.deleteField(userCache, property);  // Save user's cache back to shared object  ;
            
			// Save user's cache back to shared object
            Reflect.setProperty(m_sharedObject.data, userID, userCache);
            
            // Immediately flush
            try
            {
                m_sharedObject.flush();
            }
            catch (err : Error)
            {
                trace("ERROR: Flush Failed! " + err.message);
            }
        }
    }
    
    /**
	 *
	 * Flush to Server
	 *
	**/
    
    /**
	 * Flush changes made to the users save data in the local shared object.
	 * @return
	 */
    public function flushPrivateCache() : Bool
    {
        // Flush the local cache.
        var result : Bool = true;
        try
        {
            m_sharedObject.flush();
        }
        catch (err : Error)
        {
            trace("ERROR: Flush Failed! " + err.message);
            result = false;
        }
        return result;
    }
    
    /**
	 *
	 * Save Callbacks
	 *
	**/
    
    /**
	 * Checks for and calls the callback associated with the the given property being flushed.
	 * @param	property Property which got flushed to the server.
	 * @param	failed Whether or not the property failed to flush.
	 */
    public function callSaveCallback(property : String, failed : Bool) : Void
    {
        if (m_serverSaveCallbackMap.exists(property))
        {
            var callback : Dynamic = m_serverSaveCallbackMap.get(property);
            if (callback != null)
            {
                callback(property, failed);
            }
        }
    }
    
    /**
	 * Register a callback listener for data saved on the server. This is used for testing
	 * and can also be used by games to detect failures to saving data on the server.
	 * Once the data has been saved on the server this callback is called.
	 * Only one callback can be registered per property.
	 * @param	property The unqiue id for data being saved.
	 * @param	callback Callback when completed.
	 */
    public function registerSaveCallback(property : String, callback : Dynamic) : Void
    {
        m_serverSaveCallbackMap.set(property, callback);
    }
    
    /**
	 * Remove the callback fuction that has been registered for the given property.
	 * @param	property
	 */
    public function unregisterSaveCallback(property : String) : Void
    {
        if (m_serverSaveCallbackMap.exists(property))
        {
            m_serverSaveCallbackMap.remove(property);
        }
    }
    
    /**
	 *
	 * Saving
	 *
	**/
    
    /**
	 * Attempts to retrieve the given property from the shared object, may return null if not found.
	 * @param	property The property to be retrieved.
	 * @param	userID ID of the user to get from.
	 * @return
	 */
    public function getSaveFromSharedObject(property : String, userID : String) : Dynamic
    {
        var result : Dynamic = null;
        if (sharedObjectExists)
        {
            // Get the user's cache
            var userCache : Dynamic = Reflect.getProperty(m_sharedObject.data, userID);
            
            // Get the data out of the user's cache, but only if the user's cache even exists
            if (userCache != null)
            {
                result = Reflect.field(userCache, property);
            }
        }
        return result;
    }
    
    /**
	 * Returns whether or not the given property already exists in the shared object.
	 * @param	property The property to look for.
	 * @param	userID ID of the user to look for.
	 * @return
	 */
    public function saveExistsInSharedObject(property : String, userID : String) : Bool
    {
        var result : Bool = false;
        if (sharedObjectExists)
        {
            // Get the user's cache
            var userCache : Dynamic = Reflect.getProperty(m_sharedObject.data, userID);
            
            // Check if the property is in the user's cache
            result = userCache != null && Reflect.hasField(userCache, property);
        }
        return result;
    }
    
    /**
	 * Sets the property with the given value (will always override the existing value) to the shared object.
	 * @param	property The property to be updated
	 * @param	val The new value of the property
	 * @param	userID ID of the user to get from.
	 * @return
	 */
    public function setSaveToSharedObject(property : String, val : Dynamic, userID : String) : Bool
    {
        var result : Bool = false;
        if (sharedObjectExists)
        {
            // Get the user's cache
            var userCache : Dynamic = Reflect.getProperty(m_sharedObject.data, userID);
            
            // Create user's cache if it did not exist
            if (userCache == null)
            {
                userCache = {};
            }
            
            // Save property to user's cache
            Reflect.setField(userCache, property, val);
            
            // Save user's cache back to shared object
            Reflect.setProperty(m_sharedObject.data, userID, userCache);
            
            result = true;
        }
        return result;
    }
}
