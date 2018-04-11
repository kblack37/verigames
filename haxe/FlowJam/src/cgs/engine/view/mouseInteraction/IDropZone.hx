package cgs.engine.view.mouseInteraction;

import openfl.events.MouseEvent;

interface IDropZone
{

    /**
		 * Drop a draggable sprite on the drop zone.
		 */
    function dropObject(sprite : ISelectable, stageX : Float, stageY : Float) : Void
    ;
    
    /**
		 * Test if a drop can be performed at the given stage coordinates.
		 */
    function canDrop(sprite : ISelectable, stageX : Float, stageY : Float) : Bool
    ;
}
