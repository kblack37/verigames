package cgs.server.abtesting.tests;

import flash.utils.Dictionary;

class ConditionTestStatus
{
    private var _condID : Int;
    
    //Test status of each variable in the test.
    private var _variables : Array<VariableTestStatus>;
    
    public function new()
    {
        _variables = new Array<VariableTestStatus>();
    }
    
    private function getVariableStatus(id : Int) : VariableTestStatus
    {
        for (variable in _variables)
        {
            if (variable.id == id)
            {
                return variable;
            }
        }
        
        return null;
    }
    
    public function parseVariableStatusData(dataObj : Dynamic) : Void
    {
        var varID : Int = dataObj.var_id;
        var variable : VariableTestStatus = getVariableStatus(varID);
        if (variable == null)
        {
            variable = new VariableTestStatus(varID);
            _variables.push(variable);
        }
        
        variable.parseVariableStatusData(dataObj);
    }
}
