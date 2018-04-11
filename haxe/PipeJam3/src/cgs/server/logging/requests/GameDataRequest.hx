package cgs.server.logging.requests;

import haxe.Constraints.Function;

class GameDataRequest extends CallbackRequest
{
    public var dataId : String;
    
    public var saveId : Int;
    
    public function new(callback : Function, dataId : String, saveId : Int = -1)
    {
        super(callback, null);
        this.dataId = dataId;
        this.saveId = saveId;
    }
}
