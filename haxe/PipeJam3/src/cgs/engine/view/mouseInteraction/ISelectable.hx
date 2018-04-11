package cgs.engine.view.mouseInteraction;


/**
	 * ...
	 * @author Rich
	 */
interface ISelectable
{
    
    
    /**
		 * Returns whether or not this Selectable should be deselected when reselected.
		 */
    var deselectOnReselect(get, never) : Bool;    
    
    /**
		 * Returns whether or not this ISelectable is presently selected.
		 */
    var selected(get, never) : Bool;    
    
    /**
		 * Returns whether or not this ISelectable is presently selectable (is available to be selected).
		 */
    var isSelectable(get, never) : Bool;

    /**
		 * Selects this ISelectable.
		 */
    function select() : Void
    ;
    
    /**
		 * Deselects this ISelectable.
		 */
    function deselect() : Void
    ;
}

