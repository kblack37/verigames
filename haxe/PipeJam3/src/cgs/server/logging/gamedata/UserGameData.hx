package cgs.server.logging.gamedata;

import cgs.server.logging.responses.UserDataChunkResponse;
import haxe.Json;
import haxe.ds.StringMap;

/**
	 * Contains all game data for this user.
	 */
class UserGameData
{
    public static var SupportLegacyData(never, set) : Bool;
    public var keys(get, never) : Array<Dynamic>;
    public var isServerDataLoaded(get, never) : Bool;

    /**
		 * Flag to support legacy server data format. This only needs to be set if
		 * the game previously saved user data to the server prior to the fix on the server.
		 */
    private static var supportLegacyData : Bool = false;
    
    //Dictionary which contains all of the user data chunks.
    private var _gameData : StringMap<Dynamic>;
    
    private var _serverDataLoaded : Bool;
    
    public function new()
    {
        _gameData = new StringMap<Dynamic>();
    }
    
    private static function set_SupportLegacyData(value : Bool) : Bool
    {
        supportLegacyData = value;
        UserDataChunkResponse.SupportLegacyData = true;
        return value;
    }
    
    private function get_keys() : Array<Dynamic>
    {
        var keys : Array<Dynamic> = [];
        for (key in Reflect.fields(_gameData))
        {
            keys.push(key);
        }
        
        return keys;
    }
    
    private function get_isServerDataLoaded() : Bool
    {
        return _serverDataLoaded;
    }
    
    /**
		 * Indicates if the data for the given key exists.
		 */
    public function containsData(key : String) : Bool
    {
        return _gameData.exists(key);
    }
    
    /**
		 * Get the save data with the associated key.
		 */
    public function getData(key : String) : Dynamic
    {
        return _gameData.get(key);
    }
    
    /**
		 * Update the value of the data with the given key. The value should
		 * be a primitive value, array or an Object. No other values are supported.
		 */
    public function updateData(key : String, value : Dynamic) : Void
    {
        _gameData.set(key, value);
    }
    
    /**
		 * Copies all of the data properties from this class into the passed 
		 * user data instance.
		 */
    public function copyData(data : UserGameData) : Void
    {
        for (dataKey in Reflect.fields(_gameData))
        {
            data._gameData.set(dataKey, _gameData.get(dataKey));
        }
        
        _serverDataLoaded = true;
    }
    
    /**
		 * Parse game data returned from the server.
		 */
    public function parseUserGameData(data : Array<Dynamic>) : Void
    {
        var key : String;
        var rawData : Dynamic;
        for (dataChunk in data)
        {
            key = dataChunk.u_data_id;
            rawData = dataChunk.data_detail;
            if (Std.is(rawData, String))
            {
                var stringData : String = rawData;
                if (stringData.toLowerCase() == "null")
                {
                    _gameData.remove(key);
                }
                else
                {
                    if (supportLegacyData)
                    {
                        if (stringData.length == 0)
                        {
                            _gameData.set(key, stringData);
                        }
                        else
                        {
                            if (stringData.charAt(0) == "{" || stringData.charAt(0) == "[")
                            {
                                _gameData.set(key, Json.parse(rawData));
                            }
                            else
                            {
                                _gameData.set(key, stringData);
                            }
                        }
                    }
                    else
                    {
                        _gameData.set(key, stringData);
                    }
                }
            }
            else
            {
                _gameData.set(key, rawData);
            }
        }
        
        _serverDataLoaded = true;
    }
}
