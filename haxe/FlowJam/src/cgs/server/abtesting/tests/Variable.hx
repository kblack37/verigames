package cgs.server.abtesting.tests;


class Variable
{
    public var id(get, never) : Int;
    public var abTest(get, never) : ABTest;
    public var name(get, never) : String;
    public var results(get, set) : Dynamic;
    public var hasResults(get, never) : Bool;
    public var inTest(get, set) : Bool;
    public var testingStarted(get, set) : Bool;
    public var tested(get, set) : Bool;
    public var condition(never, set) : Condition;
    public var value(get, never) : Dynamic;
    public var type(get, never) : Int;

    public static inline var BOOLEAN_VARIABLE : Int = 0;
    public static inline var INTEGER_VARIABLE : Int = 1;
    public static inline var NUMBER_VARIABLE : Int = 2;
    public static inline var STRING_VARIABLE : Int = 3;
    
    private var _id : Int;
    
    //Condition that the variable belongs to.
    private var _condition : Condition;
    
    private var _name : String;
    
    private var _value : Dynamic;
    
    private var _type : Int;
    
    //Indicates if the variable has been tested by the application.
    private var _tested : Bool;
    
    //Indicates if testing was started on the variable.
    private var _testingStarted : Bool;
    
    //Indicates if a test end can be logged.
    private var _inTest : Bool;
    
    //Results of this variable being tested.
    private var _results : Dynamic;
    
    public function new()
    {
    }
    
    private function get_id() : Int
    {
        return _id;
    }
    
    /**
		 * Get the test that the variable belongs to.
		 */
    private function get_abTest() : ABTest
    {
        return (_condition != null) ? _condition.test : null;
    }
    
    /**
		 * Get the name of the variable.
		 * @return String the name of the variable.
		 */
    private function get_name() : String
    {
        return _name;
    }
    
    private function set_results(value : Dynamic) : Dynamic
    {
        _results = value;
        return value;
    }
    
    private function get_results() : Dynamic
    {
        return _results;
    }
    
    private function get_hasResults() : Bool
    {
        return _results != null;
    }
    
    //
    // Local testing variables. Keeps end results from being sent when the variable is not in test.
    //
    
    private function set_inTest(value : Bool) : Bool
    {
        _inTest = value;
        return value;
    }
    
    private function get_inTest() : Bool
    {
        return _inTest;
    }
    
    /**
		 * Set that overall testing has started for the variable.
		 */
    private function set_testingStarted(value : Bool) : Bool
    {
        _testingStarted = value;
        return value;
    }
    
    private function get_testingStarted() : Bool
    {
        return _testingStarted;
    }
    
    /**
		 * Set that the first
		 */
    private function set_tested(value : Bool) : Bool
    {
        _tested = value;
        return value;
    }
    
    private function get_tested() : Bool
    {
        return _tested;
    }
    
    private function set_condition(cond : Condition) : Condition
    {
        _condition = cond;
        return cond;
    }
    
    private function get_value() : Dynamic
    {
        return _value;
    }
    
    private function get_type() : Int
    {
        return _type;
    }
    
    public function parseJSONData(dataObj : Dynamic) : Void
    {
        _id = dataObj.id;
        _name = dataObj.v_key;
        _type = dataObj.v_type;
        
        if (_type == BOOLEAN_VARIABLE)
        {
            _value = convertToBoolean(dataObj.v_value);
        }
        else
        {
            _value = dataObj.v_value;
        }
    }
    
    private function convertToBoolean(text : String) : Bool
    {
        var normalizedText : String = text.toLowerCase();
        return normalizedText == "true" || normalizedText == "1";
    }
}
