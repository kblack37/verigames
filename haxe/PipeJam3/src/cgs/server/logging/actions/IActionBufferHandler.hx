package cgs.server.logging.actions;


interface IActionBufferHandler
{
    
    
    /**
		 * Set a listener on the handler which can be called to flush actions to the server.
		 */
    var listener(never, set) : IActionBufferListener;

    function setProperties(startFlushTime : Float, endFlushTime : Float, rampTime : Float) : Void
    ;
    
    /**
		 * Start the handler with flushing action messages to the server.
		 */
    function start() : Void
    ;
    
    /**
		 * Stop the handler from flushing any messages.
		 */
    function stop() : Void
    ;
    
    /**
		 * Reset the handler to its default starting values.
		 */
    function reset() : Void
    ;
    
    /**
		 * External time handler.
		 */
    function onTick(delta : Float) : Void
    ;
}
