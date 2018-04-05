package state;

import flash.errors.Error;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import mx.core.UIComponent;

class GenericState extends UIComponent
{
    
    public static var display : DisplayObjectContainer;
    
    public function new()
    {
        super();
    }
    
    private function onEnterFrame(e : Event) : Void
    {
        stateUpdate();
    }
    
    /** Called when State is initialized/added to the screen */
    public function stateLoad() : Void
    {
        if (display != null)
        {
            display.addChild(this);
        }
        else
        {
            throw new Error("Display parent not initialized, could not add State to stage: " + this);
        }
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    /** Called when State is finished/to be removed from the screen */
    public function stateUnload() : Void
    {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        // Remove all children from stage
        while (numChildren > 0)
        {
            var disp : DisplayObject = getChildAt(0);removeChild(disp);disp = null;
        }
    }
    
    /** Called onEnterFrame */
    public function stateUpdate() : Void
    {  // Implemeted by children  
        
    }
}

