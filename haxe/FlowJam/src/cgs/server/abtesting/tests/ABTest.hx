package cgs.server.abtesting.tests;


class ABTest
{
    public var id(get, never) : Int;
    public var hasCID(get, never) : Bool;
    public var cid(get, never) : Int;
    public var nextResultID(get, never) : Int;
    public var currentResultID(get, never) : Int;
    public var conditionID(get, never) : Int;
    public var variables(get, never) : Array<Variable>;
    public var hasTestingStarted(get, never) : Bool;
    public var tested(get, never) : Bool;

    //Unique id of the test.
    private var _id : Int;
    
    //Overrides the cid of the game if user is placed in the test.
    private var _cid : Int;
    
    //Indicates if multiple results can be logged for the test.
    private var _multiResults : Bool;
    
    //Condition for this test.
    private var _condition : Condition;
    
    private var _testStatus : TestStatus;
    
    private var _completeCount : Int;
    
    public function new()
    {
        _testStatus = new TestStatus();
    }
    
    private function get_id() : Int
    {
        return _id;
    }
    
    /**
		 * Indicates if the test has a CID set for the user.
		 */
    private function get_hasCID() : Bool
    {
        return _cid >= 0;
    }
    
    /**
		 * Get the logging cid for the user.
		 */
    private function get_cid() : Int
    {
        return _cid;
    }
    
    private function get_nextResultID() : Int
    {
        return _testStatus.nextResultID;
    }
    
    private function get_currentResultID() : Int
    {
        return _testStatus.currentResultID;
    }
    
    private function get_conditionID() : Int
    {
        return _condition.id;
    }
    
    private function get_variables() : Array<Variable>
    {
        return _condition.variables;
    }
    
    /**
		 * Indicates if testing has started on any of the variables in the test.
		 */
    private function get_hasTestingStarted() : Bool
    {
        return _condition.hasTestingStarted;
    }
    
    /**
		 * Reset the test. To be run again.
		 */
    public function reset() : Void
    {
        _completeCount++;
        
        _condition.reset();
    }
    
    /**
		 * Indicates if this test has been fully tested on the client. 
		 */
    private function get_tested() : Bool
    {
        return _condition.tested;
    }
    
    public function parseTestStatusData(dataObj : Dynamic) : Void
    {
        _testStatus.parseTestStatusData(dataObj);
    }
    
    public function parseVariableStatus(dataObj : Dynamic) : Void
    {
        _testStatus.parseVariableStatusData(dataObj);
    }
    
    public function parseJSONData(dataObj : Dynamic) : Void
    {
        _id = dataObj.test_id;
        _multiResults = dataObj.multi_results;
        
        _condition = new Condition();
        _condition.parseJSONData(dataObj.cond);
        _condition.test = this;
        
        _cid = dataObj.cid;
    }
}
