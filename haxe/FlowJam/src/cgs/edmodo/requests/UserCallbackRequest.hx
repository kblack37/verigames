package cgs.edmodo.requests;

import haxe.Constraints.Function;
import cgs.server.logging.requests.CallbackRequest;

class UserCallbackRequest extends CallbackRequest
{
    public var userToken : String;
    
    public function new(callback : Function, userToken : String)
    {
        super(callback, null);
        
        this.userToken = userToken;
    }
}
