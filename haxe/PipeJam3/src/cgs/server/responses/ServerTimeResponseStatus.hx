package cgs.server.responses;

class ServerTimeResponseStatus extends ResponseStatus
{
    public var time(get, never) : Float;

    private var _time : Float;
    private var _success : Bool;
    
    public function new()
    {
        super();
    }
    
    /**
     * Indicates if the request to the server suceeded.
     */
    override private function get_success() : Bool
    {
        return _success && super.success;
    }
    
    override private function handleResponse() : Void
    {
        super.handleResponse();
        
        _time = parseResponseData(rawData);
    }
    
    private function parseResponseData(rawData : String) : Dynamic
    {
        var failed : Bool = false;
        var returnTime : Float = 0;
        try
        {
            var timeSeconds : Float = Std.parseFloat(rawData);
            var timeMilli : Float = timeSeconds * 1000;
            returnTime = Math.round(timeMilli);
            if (Math.isNaN(returnTime))
            {
                returnTime = 0;
            }
        }
        catch (e:Dynamic)
        {
            _success = false;
        }
        
        return returnTime;
    }
    
    private function get_time() : Float
    {
        return _time;
    }
}
