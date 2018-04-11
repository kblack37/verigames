package cgs.server.logging.actions;

import cgs.server.logging.data.IQuestActionSequenceData;

interface IClientAction extends IQuestActionSequenceData
{
    
    //Get the object which will be serialized into JSON and sent to server.
    var actionObject(get, never) : Dynamic;

    
    function addProperty(key : String, value : Dynamic) : Void
    ;
    
    function addDetailProperty(key : String, value : Dynamic) : Void
    ;
}
