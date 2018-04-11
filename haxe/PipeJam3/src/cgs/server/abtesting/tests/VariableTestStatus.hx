package cgs.server.abtesting.tests;


class VariableTestStatus
{
    public var id(get, never) : Int;

    private var _id : Int;
    
    private var _started : Bool;
    private var _startCount : Int;
    
    private var _completed : Bool;
    private var _completeCount : Int;
    
    public function new(id : Int)
    {
        _id = id;
    }
    
    private function get_id() : Int
    {
        return _id;
    }
    
    public function parseVariableStatusData(dataObj : Dynamic) : Void
    {
        if (Reflect.hasField(dataObj, "start"))
        {
            var start : Bool = dataObj.start == "1";
            var count : Int = dataObj.v_count;
            
            if (start)
            {
                _started = true;
                _startCount = count;
            }
            else
            {
                _completed = true;
                _completeCount = count;
            }
        }
    }
}
