package state;

import flash.events.Event;
import starling.display.DisplayObject;
import starling.display.Sprite;

class GenericState extends Sprite
{
    
    public static var display : Sprite;
    
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
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    }
    
    /** Called when State is finished/to be removed from the screen */
    public function stateUnload() : Void
    {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        // Remove all children from stage
        while (numChildren > 0)
        {
            var disp : DisplayObject = getChildAt(0);
			removeChild(disp);
			disp = null;
        }
    }
    
    /** Called onEnterFrame */
    public function stateUpdate() : Void
    {  // Implemeted by children  
        
    }
}

