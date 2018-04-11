package cgs.server.abtesting;


interface ICgsUserAbTester
{
    
    var defaultVariableProvider(never, set) : IVariableProvider;

    
    function registerDefaultValue(varName : String, value : Dynamic, valueType : Int) : Void
    ;
    
    function getVariableValue(varName : String) : Dynamic
    ;
    
    function overrideVariableValue(varName : String, value : Dynamic) : Void
    ;
    
    function variableTested(varName : String, results : Dynamic = null) : Void
    ;
    
    function startVariableTesting(varName : String, startData : Dynamic = null) : Void
    ;
    
    function endVariableTesting(varName : String, results : Dynamic = null) : Void
    ;
    
    function startTimedVariableTesting(varName : String, startData : Dynamic = null) : Void
    ;
    
    /**
     * Get the condition id for the user. If the user is in multiple conditions
     * this will return the first condition id. Will return -1 if no condition id for user.
     */
    function getUserConditionId() : Int
    ;
}
