package cgs.server.logging.actions;

import haxe.Constraints.Function;

interface IActionBufferListener
{

    function flushActions(localDQID : Int = -1, callback : Function = null) : Void
    ;
}
