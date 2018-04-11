package cgs.server.logging.requests;

import haxe.Constraints.Function;

class DQIDRequest extends CallbackRequest
{
    public var localLevelID : Int;
    
    public function new(id : Int, callback : Function)
    {
        super(callback, null);
        localLevelID = id;
    }
}
