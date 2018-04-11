package cgs.server.abtesting.tests;


class TestStatus
{
    public var nextResultID(get, never) : Int;
    public var currentResultID(get, never) : Int;

    //Indicates if the test start message has been logged on the server.
    private var _started : Bool;
    private var _startCount : Int;
    
    //Indicates if the test complete message has been logged on the server.
    private var _completed : Bool;
    private var _completeCount : Int;
    
    //Current results id to be used for the test.
    private var _currResultID : Int;
    
    private var _conditonStatus : ConditionTestStatus;
    
    public function new()
    {
        _conditonStatus = new ConditionTestStatus();
    }
    
    /**
		 * Get the next valid id for a test result.
		 */
    private function get_nextResultID() : Int
    {
        return ++_currResultID;
    }
    
    private function get_currentResultID() : Int
    {
        return _currResultID;
    }
    
    public function parseTestStatusData(dataObj : Dynamic) : Void
    {
        _completeCount = dataObj.count;
        _completed = _completeCount > 0;
        _currResultID = dataObj.result_id;
    }
    
    public function parseVariableStatusData(dataObj : Dynamic) : Void
    {
        _conditonStatus.parseVariableStatusData(dataObj);
    }
}
