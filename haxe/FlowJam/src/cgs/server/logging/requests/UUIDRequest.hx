package cgs.server.logging.requests;

import haxe.Constraints.Function;
import cgs.server.logging.IGameServerData;

class UUIDRequest extends CallbackRequest
{
    public var cacheUUID : Bool;
    
    public function new(callback : Function, cacheUUID : Bool, gameData : IGameServerData)
    {
        super(callback, gameData);
        this.cacheUUID = cacheUUID;
    }
}
