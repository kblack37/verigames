package userInterface.components;

import flash.events.Event;

/**
	 * Generic clickable button
	 */
interface GeneralButton
{
    
    
    var mouseOver(get, never) : Bool;

    function draw() : Void
    ;
    
    function buttonRollOver(e : Event) : Void
    ;
    
    function buttonRollOut(e : Event) : Void
    ;
    
    function select() : Void
    ;
    
    function unselect() : Void
    ;
}

