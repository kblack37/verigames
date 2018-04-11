package cgs.server.abtesting;


interface IVariableProvider
{

    function containsVariable(name : String) : Bool
    ;
    
    function getVariableValue(name : String) : Dynamic
    ;
}
