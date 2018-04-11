  //Package name revised to avoid conflict with application using PBE.  
package cgs.pblabs.engine.debug;


interface ILogAppender
{

    function addLogMessage(level : String, loggerName : String, message : String) : Void
    ;
}
