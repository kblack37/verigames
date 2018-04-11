package cgs.server.logging.gamedata

import openfl.utils.Dictionary;
import cgs.server.logging.responses.UserDataChunkResponse;
import haxe.Json;


/**
 * Contains all game data for this user.
 */
public class UserGameData
{
	/**
	 * Flag to support legacy server data format. This only needs to be set if
	 * the game previously saved user data to the server prior to the fix on the server.
	 */
	private static var supportLegacyData:Boolean = false;
	
	//Dictionary which contains all of the user data chunks.
	private var _gameData:Dictionary<String, Dynamic>;
	
	private var _serverDataLoaded:Boolean;
	
	public function UserGameData()
	{
		_gameData = new Dictionary<String, Dynamic>();
	}
	
	public static function set SupportLegacyData(value:Boolean):void
	{
		supportLegacyData = value;
		UserDataChunkResponse.SupportLegacyData = true;
	}
	
	public function get keys():Array
	{
		var keys:Array = [];
		for(var key:String in _gameData)
		{
			keys.push(key);
		}
		
		return keys;
	}
	
	public function get isServerDataLoaded():Boolean
	{
		return _serverDataLoaded;
	}
	
	/**
	 * Indicates if the data for the given key exists.
	 */
	public function containsData(key:String):Boolean
	{
		return _gameData.hasOwnProperty(key);
		//var value:* = _gameData[key];
		//
		//return _gameData[key] != null;
	}
	
	/**
	 * Get the save data with the associated key.
	 */
	public function getData(key:String):*
	{
		return _gameData[key];
	}
	
	/**
	 * Update the value of the data with the given key. The value should
	 * be a primitive value, array or an Object. No other values are supported.
	 */
	public function updateData(key:String, value:*):void
	{
		_gameData[key] = value;
	}
	
	/**
	 * Copies all of the data properties from this class into the passed 
	 * user data instance.
	 */
	public function copyData(data:UserGameData):void
	{
		for(var dataKey:String in _gameData)
		{
			data._gameData[dataKey] = _gameData[dataKey];
		}
		
		_serverDataLoaded = true;
	}
	
	/**
	 * Parse game data returned from the server.
	 */
	public function parseUserGameData(data:Array):void
	{
		var key:String;
		var rawData:*;
		for each(var dataChunk:Object in data)
		{
			key = dataChunk.u_data_id;
			rawData = dataChunk.data_detail;
			if(rawData is String)
			{
				var stringData:String = rawData;
				if(stringData.toLowerCase() == "null")
				{
					_gameData[key] = null;
				}
				else if(supportLegacyData)
				{
					if(stringData.length == 0)
					{
						_gameData[key] = stringData;
					}
					else if(stringData.charAt(0) == "{" || stringData.charAt(0) == "[")
					{
						_gameData[key] = Json.parse(rawData);
					}
					else
					{
						_gameData[key] = stringData;
					}
				}
				else
				{
					_gameData[key] = stringData;
				}
			}
			else
			{
				_gameData[key] = rawData;
			}
		}
		
		_serverDataLoaded = true;
	}
}
