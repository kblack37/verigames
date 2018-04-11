package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.IGameServerData;

class CallbackRequest implements ICallbackRequest
{
    public var callback(get, set) : Dynamic;
    public var gameServerData(get, set) : IGameServerData;
    public var returnDataType(get, never) : String;

    private var _callback : Dynamic;
    
    private var _returnDataType : String;
    
    private var _gameServerData : IGameServerData;
    
    public function new(callback : Dynamic, gameServerData : IGameServerData, returnType : String = "TEXT")
    {
        _callback = callback;
        _gameServerData = gameServerData;
        _returnDataType = returnType;
    }
    
    private function get_callback() : Dynamic
    {
        return _callback;
    }
    
    private function set_callback(value : Dynamic) : Dynamic
    {
        _callback = value;
        return value;
    }
    
    private function set_gameServerData(value : IGameServerData) : IGameServerData
    {
        _gameServerData = value;
        return value;
    }
    
    private function get_gameServerData() : IGameServerData
    {
        return _gameServerData;
    }
    
    private function get_returnDataType() : String
    {
        return _returnDataType;
    }
}
