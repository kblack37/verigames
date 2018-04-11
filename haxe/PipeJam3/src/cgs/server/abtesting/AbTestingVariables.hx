package cgs.server.abtesting;

import haxe.ds.StringMap;

class AbTestingVariables implements IVariableProvider
{
    private var _variableMap : StringMap<Dynamic>;
    
    public function new()
    {
        _variableMap = new StringMap<Dynamic>();
    }
    
    public function registerDefaultVariable(name : String, value : Dynamic) : Void
    {
        _variableMap.set(name, value);
    }
    
    public function containsVariable(name : String) : Bool
    {
        return _variableMap.exists(name);
    }
    
    public function getVariableValue(name : String) : Dynamic
    {
        return _variableMap.get(name);
    }
}
