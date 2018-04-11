package cgs.server.abtesting;

import cgs.server.abtesting.IUserAbTester.ConditionsCallback;
import cgs.server.abtesting.tests.ABTest;
import cgs.server.abtesting.tests.Variable;
import cgs.server.responses.CgsResponseStatus;
//import cgs.server.responses.ResponseStatus;
//import cgs.server.abtesting.IVariableProvider;
import haxe.ds.StringMap;


/**
	 * Responsible for managing the ab tests for a specific user.
	 */
class UserAbTester implements IUserAbTester
{
    public var defaultVariableProvider(never, set) : IVariableProvider;
    public var serverApi(never, set) : IAbTestingServerApi;

    public static inline var BOOLEAN_VARIABLE : Int = 0;
    public static inline var INTEGER_VARIABLE : Int = 1;
    public static inline var NUMBER_VARIABLE : Int = 2;
    public static inline var STRING_VARIABLE : Int = 3;
    
    private var _tests : Array<ABTest>;
    
    //Dictionary of all variables. key = variable name, value = variableContainer.
    private var _variables : StringMap<VariableContainer>;
    
    //Reference to the server which is used to make requests.
    private var _server : IAbTestingServerApi;
    
    //Callback to be called when the conditions have been loaded.
    private var _conditionsCallback : ConditionsCallback;
    
    //Indicates if the conditions have been loaded from the server.
    private var _conditionsLoaded : Bool;
    
    private var _testVariableTimer : TestVariableTimer;
    
    private var _defaultVariables : IVariableProvider;
    
    public function new(
            server : IAbTestingServerApi, defaultVars : IVariableProvider = null)
    {
        _server = server;
        _variables = new StringMap<VariableContainer>();
        _testVariableTimer = new TestVariableTimer();
        
        _defaultVariables = defaultVars;
    }
    
    private function set_defaultVariableProvider(value : IVariableProvider) : IVariableProvider
    {
        _defaultVariables = value;
        
        for (variable in _variables)
        {
            variable.defaultVariableProvider = _defaultVariables;
        }
        return value;
    }
    
    /**
		 * Set the server api instance used to load and report results of ab tests.
		 * Must be set prior to request user conditions.
		 */
    private function set_serverApi(server : IAbTestingServerApi) : IAbTestingServerApi
    {
        _server = server;
        return server;
    }
    
    /**
		 * Get the test id for the user. If the user is in multiple tests this
		 * just returns the first test id. Will return -1 if no test is loaded.
		 */
    public function getUserTestId() : Int
    {
        if (_tests == null)
        {
            return 0;
        }
        if (_tests.length == 0)
        {
            return 0;
        }
        
        return _tests[0].id;
    }
    
    /**
		 * Get the category id for the user when they were first placed in the condition.
		 */
    public function getUserCategoryId() : Int
    {
        if (_tests == null)
        {
            return 0;
        }
        if (_tests.length == 0)
        {
            return 0;
        }
        
        return _tests[0].cid;
    }
    
    /**
		 * Get the condition id for the user. If the user is in multiple conditions
		 * this will return the first condition id. Will return -1 if no condition id for user.
		 */
    public function getUserConditionId() : Int
    {
        if (_tests == null)
        {
            return 0;
        }
        if (_tests.length == 0)
        {
            return 0;
        }
        
        return _tests[0].conditionID;
    }
    
    /**
		 * Loads / creates test conditions for the user. This also loads any variables
		 * that have been determined, by test results, to persist across all users.
		 * This should not be called until a valid CGS uid has been loaded from the server.
		 *
		 * @param callback a function to be called when the user's test conditions have been loaded
		 * from the server. Function should have the signature of (failed:Boolean).
		 * @param existing indicates if only existing test conditions should be loaded. Will not create new
		 * test conditions for the user.
		 */
    public function loadTestConditions(callback : ConditionsCallback, existing : Bool = false) : Void
    {
        resetTestConditions();
        
        _conditionsCallback = callback;
        _server.requestUserTestConditions(existing, handleConditionsLoaded);
    }
    
    /**
		 * Make the user a no condition user. They will not be assigned to a test and
		 * will use default values set in the client.
		 */
    public function noConditionUser() : Void
    {
        _server.noUserConditions();
    }
    
    private function resetTestConditions() : Void
    {
        for (variable in _variables)
        {
            variable.removeTestVariables();
        }
    }
    
    private function handleConditionsLoaded(response : CgsResponseStatus) : Void
    {
        var callback : Dynamic = null;
        if (_conditionsCallback != null)
        {
            callback = _conditionsCallback;
            _conditionsCallback = null;
        }
        
        if (!response.failed)
        {
            parseJSONData(response.data);
        }
        
        if (callback != null)
        {
            callback(response);
        }
    }
    
    /**
		 * Register a default value for a variable with the given name. This default value
     * will only apply to a specific user.
		 */
    public function registerDefaultValue(varName : String, value : Dynamic, valueType : Int) : Void
    {
        var varContainer : VariableContainer = _variables.get(varName);
        if (varContainer == null)
        {
            varContainer = new VariableContainer(varName, value, valueType);
            _variables.set(varName, varContainer);
        }
        else
        {
            varContainer.setDefaultValue(value);
            varContainer.type = valueType;
        }
    }
    
    private function registerTestVariable(variable : Variable) : Void
    {
        var varContainer : VariableContainer = _variables.get(variable.name);
        if (varContainer == null)
        {
            varContainer = new VariableContainer(variable.name, variable.value, variable.type);
            _variables.set(variable.name, varContainer);
        }
        
        varContainer.setTestVariable(variable);
    }
    
    /**
		 * Get the current value for the variable with the given name. Will
     * return default variable value if there is no test value for the variable.
		 *
		 * @param varName the name of the variable.
		 * @return the current value of the variable. Will return null if the
		 * variable is not contained in the tester.
		 */
    public function getVariableValue(varName : String) : Dynamic
    {
        var varValue : Dynamic = null;
        var varCon : VariableContainer = _variables.get(varName);
        if (varCon != null)
        {
            varValue = varCon.currentValue();
        }
        else
        {
            if (_defaultVariables.containsVariable(varName))
            {
                varValue = _defaultVariables.getVariableValue(varName);
            }
        }
        
        return varValue;
    }
    
    private function getVariable(varName : String) : Variable
    {
        var varCon : VariableContainer = _variables.get(varName);
        if (varCon != null)
        {
            return varCon.testVariable;
        }
        
        return null;
    }
    
    /**
		 * Indicates if the variable with the given name is being tested.
		 *
		 * @param varName the name of the variable.
		 * @return true if the variable is currently being tested.
		 */
    public function isVariableInTest(varName : String) : Bool
    {
        var varContainer : VariableContainer = _variables.get(varName);
        if (varContainer != null)
        {
            return varContainer.isInTest();
        }
        
        return false;
    }
    
    //
    // Override values for variables.
    //
    
    public function overrideVariableValue(varName : String, value : Dynamic) : Void
    {
        var varCon : VariableContainer = _variables.get(varName);
        if (varCon != null)
        {
            varCon.setOverrideValue(value);
        }
    }
    
    //
    // Should time utilities be added to the tester?
    // Any other testing utilities?
    //
    
    /**
		 * Log the start and end of a variable test. This method should be used when the start and end
		 * of a variable test occur at the same time. If the start and end of tests occur at different times
		 * the startVariableTesting and endVariableTesting should be used.
		 */
    public function variableTested(varName : String, results : Dynamic = null) : Void
    {
        var variable : Variable = getVariable(varName);
        
        if (variable == null)
        {
            return;
        }
        
        var test : ABTest = variable.abTest;
        if (!test.hasTestingStarted)
        {
            //Test start is only logged once.
            logTestStart(test.id, test.conditionID);
        }
        
        //Log the start of the variable test.
        variable.testingStarted = true;
        logVariableTestStart(test.id, test.conditionID, variable.id, test.nextResultID);
        
        //Log the end of the variable test.
        variable.tested = true;
        logVariableResults(test.id, test.conditionID, variable.id, test.currentResultID, -1, results);
        
        //Send the test complete event to the server if the test has been completed.
        if (test.tested)
        {
            logTestEnd(test.id, test.conditionID);
        }
    }
    
    /**
		 * Signal to the ab testing engine that a variable has started being tested on the user.
		 *
		 * @param varName the name of the variable being tested.
		 * @param startData optional data to be logged on the server as part of the test.
		 */
    public function startVariableTesting(varName : String, startData : Dynamic = null) : Void
    {
        sendVariableStart(varName, -1, startData);
    }
    
    private function sendVariableStart(varName : String, time : Float = -1, detail : Dynamic = null) : Void
    {
        var variable : Variable = getVariable(varName);
        
        if (variable == null)
        {
            return;
        }
        
        //TODO - Send a cancel if the variable is still in test?
        variable.inTest = true;
        
        var test : ABTest = variable.abTest;
        if (!test.hasTestingStarted)
        {
            logTestStart(test.id, test.conditionID);
        }
        
        variable.testingStarted = true;
        logVariableTestStart(test.id, test.conditionID, variable.id, test.nextResultID, time, detail);
    }
    
    /**
		 * Let the tester know that the variable with the given name has been tested and
		 * it's results are known. If all variables in the test have been tested
		 * the results of the test will be logged on the server. Use this method
		 * if the variable test is not time based.
		 *
		 * @param varName the name of the variable which has been tested.
		 * @param results an optional object containing the results of the variable test.
		 */
    public function endVariableTesting(varName : String, results : Dynamic = null) : Void
    {
        var time : Float = -1;
        if (_testVariableTimer.containsVariableTimer(varName))
        {
            time = _testVariableTimer.endVariableTimer(varName);
        }
        
        sendVariableResults(varName, time, results);
    }
    
    private function sendVariableResults(varName : String, time : Float = -1, results : Dynamic = null) : Void
    {
        //Send the variable test results to the server.
        var variable : Variable = getVariable(varName);
        
        if (variable == null)
        {
            return;
        }
        
        //Do not send variable results if the start testing has not been called.
        if (!variable.inTest)
        {
            return;
        }
        
        var test : ABTest = variable.abTest;
        
        variable.tested = true;
        logVariableResults(test.id, test.conditionID, variable.id, test.currentResultID, time, results);
        
        //Send the test complete event to the server if the test has been completed.
        if (test.tested)
        {
            logTestEnd(test.id, test.conditionID);
            test.reset();
        }
    }
    
    //
    // Timed variable testing.
    //
    
    /**
		 * Let the tester know that a variable has begun its testing on the user.
		 */
    public function startTimedVariableTesting(varName : String, startData : Dynamic = null) : Void
    {
        var variable : Variable = getVariable(varName);
        
        if (variable == null)
        {
            return;
        }
        
        //Variable test has already been started.
        if (variable.inTest)
        {
            return;
        }
        
        _testVariableTimer.startVariableTimer(varName);
        sendVariableStart(varName, -1, startData);
    }
    
    //
    // Server request handling.
    //
    
    private function logTestStart(testID : Int, condID : Int) : Void
    {
        _server.logTestStart(testID, condID);
    }
    
    private function logTestEnd(testID : Int, condID : Int) : Void
    {
        _server.logTestEnd(testID, condID);
    }
    
    //Log the start of a variable test.
    private function logVariableTestStart(testID : Int, condID : Int, varID : Int, resultID : Int, time : Float = -1, detail : Dynamic = null) : Void
    {
        _server.logConditionVariableStart(testID, condID, varID, resultID, time, detail);
    }
    
    //Log the results for a variable test.
    private function logVariableResults(testID : Int, condID : Int, varID : Int, resultID : Int, time : Float = -1, detail : Dynamic = null) : Void
    {
        _server.logConditionVariableResults(testID, condID, varID, resultID, time, detail);
    }
    
    //Cancel a variable test.
    private function logCancelVariableTesting(testID : Int, condID : Int, varID : Int, detail : Dynamic = null) : Void
    {  //TODO - Implement.  
        
    }
    
    private function getABTest(id : Int) : ABTest
    {
        if (_tests == null)
        {
            return null;
        }
        
        for (test in _tests)
        {
            if (test.id == id)
            {
                return test;
            }
        }
        
        return null;
    }
    
    //
    // Server data parsing.
    //
    
    private function parseJSONData(data : Dynamic) : Void
    {
        if (data == null)
        {
            return;
        }
        
        _tests = new Array<ABTest>();
        var testData : Array<Dynamic> = data.tests;
        var test : ABTest;
        for (currTestData in testData)
        {
            test = new ABTest();
            test.parseJSONData(currTestData);
            addTestVariables(test);
            _tests.push(test);
        }
        
        //Parse the current status of the tests.
        var testID : Int;
        if (Reflect.hasField(data, "t_status"))
        {
            var testStatus:Array<Dynamic> = data.t_status;
            for (currTestStatus in testStatus)
            {
                testID = currTestStatus.test_id;
                test = getABTest(testID);
                if (test != null)
                {
                    test.parseTestStatusData(currTestStatus);
                }
            }
        }
        
        //Parse the current status of the condition variables.
        if (Reflect.hasField(data, "v_status"))
        {
            var variablesStatus:Array<Dynamic> = data.v_status;
            for(currVarStatus in variablesStatus)
            {
                testID = currVarStatus.test_id;
                test = getABTest(testID);
                if (test != null)
                {
                    test.parseVariableStatus(currVarStatus);
                }
            }
        }
    }
    
    private function addTestVariables(test : ABTest) : Void
    {
        for (variable in test.variables)
        {
            registerTestVariable(variable);
        }
    }
}



private class VariableContainer
{
    public var defaultVariableProvider(never, set) : IVariableProvider;
    public var type(never, set) : Int;
    public var testVariable(get, never) : Variable;

    //Provider of default variable values.
    private var _defaultVars : IVariableProvider;
    
    //Type of the variable.
    private var _varType : Int;
    
    private var _name : String;
    
    //Default value for the variable. This is used if there is no test or override values.
    private var _defaultValue : Dynamic;
    
    //Indicates if the default value was set to null.
    private var _defaultIsNull : Bool;
    
    //Value which can be set if completed test has been set to propagate it's values.
    private var _overrideValue : Dynamic;
    
    //Indicates if the override value was set to null.
    private var _overrideIsNull : Bool;
    
    //Test variable information. This variable value is used if it is set.
    private var _testVariable : Variable;
    
    @:allow(cgs.server.abtesting)
    private function new(
            name : String, defaultValue : Dynamic, varType : Int, defaultVars : IVariableProvider = null)
    {
        _name = name;
        
        _defaultValue = defaultValue;
        _varType = varType;
        
        _defaultVars = defaultVars;
    }
    
    private function set_defaultVariableProvider(value : IVariableProvider) : IVariableProvider
    {
        _defaultVars = value;
        return value;
    }
    
    private function set_type(type : Int) : Int
    {
        _varType = type;
        return type;
    }
    
    /**
	 * Get the current valid value for the variable. Will return overriden value if set
	 * then the actual test value and then the default value.
	 */
    public function currentValue() : Dynamic
    {
        if (_overrideValue != null || _overrideIsNull)
        {
            return _overrideValue;
        }
        else
        {
            if (_testVariable != null)
            {
                return _testVariable.value;
            }
            else
            {
                if (_defaultValue != null || _defaultIsNull)
                {
                    return _defaultValue;
                }
                else
                {
                    if (_defaultVars != null)
                    {
                        return _defaultVars.getVariableValue(_name);
                    }
                }
            }
        }
        
        return null;
    }
    
    public function setDefaultValue(value : Dynamic) : Void
    {
        _defaultValue = value;
        _defaultIsNull = _defaultValue == null;
    }
    
    public function setOverrideValue(value : Dynamic) : Void
    {
        _overrideValue = value;
        _overrideIsNull = _overrideValue == null;
    }
    
    public function removeTestVariables() : Void
    {
        _testVariable = null;
        _overrideValue = null;
    }
    
    public function setTestVariable(value : Variable) : Void
    {
        _testVariable = value;
    }
    
    /**
	 * Indicates if the variable is currently being tested.
	 */
    public function isInTest() : Bool
    {
        return _testVariable != null;
    }
    
    private function get_testVariable() : Variable
    {
        return _testVariable;
    }
}