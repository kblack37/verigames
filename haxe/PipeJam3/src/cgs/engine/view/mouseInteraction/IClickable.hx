package cgs.engine.view.mouseInteraction;

import openfl.events.MouseEvent;

/**
	 * ...
	 * @author Rich
	 */
interface IClickable
{
    
    /**
		 * Returns whether or not this IClickable is actually clickable at the moment
		 */
    var isClickable(get, never) : Bool;

    
    /**
		 * Click on this IClickable.
		 */
    function click(event : MouseEvent = null) : Void
    ;
    
    /**
		 * Mouse Down on this IClickable.
		 */
    function mouseDown(event : MouseEvent = null) : Void
    ;
}

