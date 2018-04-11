package cgs.server.logging.messages;

import cgs.server.logging.dependencies.IRequestDependency;

interface IQuestMessage
{
    
    
    var dqid(get, never) : String;    
    
    var messageObject(get, never) : Dynamic;    
    
    var isStart(get, never) : Bool;    
    
    var dependencies(get, never) : Array<IRequestDependency>;

    function setQuestId(value : Int) : Void
    ;
    
    /**
		 * Sets the dynamic quest id for the quest message.
		 */
    function setDqid(value : String) : Void
    ;
    
    function injectParams() : Void
    ;
    
    function getQuestId() : Int
    ;
    
    function addProperty(key : String, value : Dynamic) : Void
    ;
    
    //
    // Dependency handling.
    //
    
    function addDependency(depen : IRequestDependency) : Void
    ;
}
