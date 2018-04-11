package cgs.server.logging.requests;


class FailureRequest
{
    public var count(get, never) : Int;
    public var method(get, never) : String;

    //Method which failed to log on the server.
    private var _method : String;
    
    //Count of failures.
    private var _count : Int;
    
    public function new(method : String)
    {
        _method = method;
        _count = 0;
    }
    
    public function incrementCount(value : Int) : Void
    {
        _count += value;
    }
    
    private function get_count() : Int
    {
        return _count;
    }
    
    private function get_method() : String
    {
        return _method;
    }
}
