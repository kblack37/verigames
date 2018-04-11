//Package name revised to avoid conflict with application using PBE.
package cgs.pblabs.engine.debug;


/**
 * Simply dump log activity via trace(). 
 */
class TraceAppender implements ILogAppender
{
    public function addLogMessage(level : String, loggerName : String, message : String) : Void
    {
        trace(level + ": " + loggerName + " - " + message);
    }

    public function new()
    {
    }
}
