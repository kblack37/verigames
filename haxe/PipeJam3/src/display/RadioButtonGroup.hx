package display;

import starling.display.DisplayObjectContainer;
import starling.display.DisplayObject;
import starling.events.Event;

class RadioButtonGroup extends DisplayObjectContainer
{
    
    public function new()
    {
        super();
    }
    
    override public function addChild(_child : DisplayObject) : DisplayObject
    {
        super.addChild(_child);
        return _child;
    }
    
    private function buttonClicked(event : Event) : Void
    {
        var button : NineSliceToggleButton = try cast(event.target, NineSliceToggleButton) catch(e:Dynamic) null;
        makeActive(button);
    }
    
    public function makeActive(button : NineSliceToggleButton) : Void
    {
        button.setToggleState(true);
        for (i in 0...numChildren)
        {
            var childButton : NineSliceToggleButton = try cast(getChildAt(i), NineSliceToggleButton) catch(e:Dynamic) null;
            if (childButton != null && childButton != button)
            {
                childButton.setToggleState(false);
            }
        }
    }
    
    public function resetGroup() : Void
    //set first visible button to on
    {
        
        for (i in 0...numChildren)
        {
            var button : NineSliceToggleButton = try cast(getChildAt(i), NineSliceToggleButton) catch(e:Dynamic) null;
            if (button != null && button.visible)
            {
                makeActive(button);
                return;
            }
        }
    }
}
