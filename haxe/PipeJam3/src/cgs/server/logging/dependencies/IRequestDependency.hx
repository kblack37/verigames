package cgs.server.logging.dependencies;

import haxe.Constraints.Function;

interface IRequestDependency
{
    
    /**
     * Indicates if all of the dependencies for this handler have been met.
     */
    var ready(get, never) : Bool;

    
    function setChangeListener(listener : Function) : Void
    ;
}
