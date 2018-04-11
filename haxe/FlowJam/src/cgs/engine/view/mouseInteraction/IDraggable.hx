package cgs.engine.view.mouseInteraction;

import openfl.events.MouseEvent;

/**
	 * ...
	 * @author Rich
	 */
interface IDraggable
{
    
    /**
		 * Returns whether or not this IDraggable should be added to the mouse interaction's drag
		 * layer when drug.
		 */
    var addToDragLayerWhenDragged(get, never) : Bool;    
    /**
		 * Returns whether or not this IDraggable will follow the mouse when selected, 
		 * even when the mouse button is not being held down.
		 */
    var followMouseWhenSelected(get, never) : Bool;    
    
    /**
		 * Returns whether or not this IDraggable is presently draggable.
		 */
    var isDraggable(get, never) : Bool;    
    
    /**
		 * Returns whether or not this IDraggable is currently being dragged.
		 */
    var isDragging(get, never) : Bool;

    /**
		 * Notifies this IDraggable that it is being dragged.
		 * @param	event Mouse Event
		 */
    function beginDrag(dragX : Float, dragY : Float) : Void
    ;
    
    /**
		 * Notifies this IDraggable that its drag has ended.
		 * @param	reason Identifies different possible sources of why the drag may have ended.
		 * @param	data Optional data field containing extra information about the end of the drag.
		 */
    function endDrag(reason : String, data : Dynamic = null) : Void
    ;
    
    /**
		 * Notifies this IDraggable to update its position.
		 * @param	event Mouse Event
		 */
    function updateDrag(dragX : Float, dragY : Float) : Void
    ;
}

