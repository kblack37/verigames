package cgs.server.logging.responses;

import cgs.server.logging.gamedata.UserGameData;

/**
	 * Contains all of the users game data returned from the server.
	 */
class UserGameDataRequest implements IServerResponse
{
    public var userGameData(get, never) : UserGameData;
    public var data(never, set) : Dynamic;

    private var _gameData : UserGameData;
    
    public function new()
    {
    }
    
    private function get_userGameData() : UserGameData
    {
        return _gameData;
    }
    
    private function set_data(value : Dynamic) : Dynamic
    {
        _gameData = new UserGameData();
        _gameData.parseUserGameData(value);
        return value;
    }
}
