package cgs.user;
import haxe.ds.StringMap;
import openfl.utils.Dictionary;

/**
	 * ...
	 * @author Rich
	 */
interface ICgsCacheServerApi
{

    function saveGameData(
            dataID : String, data : Dynamic, localSaveId : Int = -1, callback : Dynamic = null) : Void
    ;
    
    function loadGameData(callback : Dynamic, loadByCid : Bool = false) : Void
    ;
    
    function loadGameDataByID(dataID : String, callback : Dynamic) : Void
    ;
    
    //
    // Version 2 cache handling.
    //
    
    /**
     * Save multiple data properties in a single request. This gives the server the chance to
     * use transactions on the data as well as reduce latency.
     * 
     * @param dataMap
     *      Mapping from save key name to arbitrary as3 object data to be saved
     * @param saveKey
     *      Optional versioning data
     * @param localSaveId
     * @param callback
     * @param serverCacheVersion
     *      If 2, use the no sql store
     *      
     */
    function batchSaveGameData(dataMap : StringMap<Dynamic>,
            saveKey : String = null,
            localSaveId : Int = -1,
            callback : Dynamic = null,
            serverCacheVersion : Int = 1) : Void
    ;
    
    function loadGameSaveData(callback : Dynamic, saveKey : String = null) : Void
    ;
}

