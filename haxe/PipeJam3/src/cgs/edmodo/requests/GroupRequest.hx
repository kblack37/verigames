package cgs.edmodo.requests;

import haxe.Constraints.Function;
import cgs.server.logging.requests.CallbackRequest;

class GroupRequest extends CallbackRequest
{
    public var groupID : Int;
    
    public function new(callback : Function, groupID : Int)
    {
        super(callback, null);
        
        this.groupID = groupID;
    }
}
