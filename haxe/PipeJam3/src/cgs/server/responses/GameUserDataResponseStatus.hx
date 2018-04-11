package cgs.server.responses;

import cgs.server.logging.IGameServerData;
import cgs.server.logging.gamedata.UserDataChunk;
import cgs.server.logging.gamedata.UserGameData;
import cgs.server.logging.responses.UserDataChunkResponse;
import cgs.server.logging.responses.UserGameDataRequest;

class GameUserDataResponseStatus extends CgsResponseStatus
{
    public var userGameData(get, never) : UserGameData;
    public var userGameDataChunk(get, never) : UserDataChunk;

    private var _userGameData : UserGameData;
    private var _allData : Bool;
    
    private var _userDataChunk : UserDataChunk;
    
    public function new(
            allData : Bool, serverData : IGameServerData = null)
    {
        super(serverData);
        
        _allData = allData;
    }
    
    private function get_userGameData() : UserGameData
    {
        return _userGameData;
    }
    
    private function get_userGameDataChunk() : UserDataChunk
    {
        return _userDataChunk;
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        if (_allData)
        {
            var response : UserGameDataRequest = new UserGameDataRequest();
            response.data = this.data;
            _userGameData = response.userGameData;
            _success = true;
        }
        else
        {
            var chunkResponse : UserDataChunkResponse = new UserDataChunkResponse();
            chunkResponse.data = this.data;
            _userDataChunk = chunkResponse.dataChunk;
            _success = true;
        }
    }
}
