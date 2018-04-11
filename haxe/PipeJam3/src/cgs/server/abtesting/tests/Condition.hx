package cgs.server.abtesting.tests;


class Condition
{
    public var id(get, never) : Int;
    public var variables(get, never) : Array<Variable>;
    public var hasTestingStarted(get, never) : Bool;
    public var tested(get, never) : Bool;
    public var test(get, set) : ABTest;

    //Test that the condition belongs to.
    private var _test : ABTest;
    
    //Id of the condition.
    private var _id : Int;
    
    //Variables contained in the condition.
    private var _variables : Array<Variable>;
    
    public function new()
    {
    }
    
    private function get_id() : Int
    {
        return _id;
    }
    
    private function get_variables() : Array<Variable>
    {
        return (_variables != null) ? _variables.copy() : null;
    }
    
    /**
		 * Indicates if testing has started on any variables in the condition.
		 */
    private function get_hasTestingStarted() : Bool
    {
        for (variable in _variables)
        {
            if (variable.testingStarted)
            {
                return true;
            }
        }
        
        return false;
    }
    
    /**
		 * Reset the test condition to be run again.
		 */
    public function reset() : Void
    {
        for (variable in _variables)
        {
            variable.tested = false;
        }
    }
    
    /**
		 * Indicates if all variables in the condition have been tested by the application.
		 */
    private function get_tested() : Bool
    {
        for (variable in _variables)
        {
            if (!variable.tested)
            {
                return false;
            }
        }
        
        return true;
    }
    
    private function set_test(abtest : ABTest) : ABTest
    {
        _test = abtest;
        return abtest;
    }
    
    private function get_test() : ABTest
    {
        return _test;
    }
    
    public function parseJSONData(dataObj : Dynamic) : Void
    {
        _id = dataObj.cond_id;
        
        _variables = new Array<Variable>();
        var variable : Variable;
        var vars : Array<Dynamic> = dataObj.vars;
        for (varObj in vars)
        {
            variable = new Variable();
            variable.parseJSONData(varObj);
            variable.condition = this;
            _variables.push(variable);
        }
    }
}
