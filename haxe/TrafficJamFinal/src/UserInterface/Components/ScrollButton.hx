package userInterface.components;

import haxe.Constraints.Function;
import userInterface.components.RectangularObject;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.*;
import mx.controls.Image;

/**
	 * A button to allow scrolling of an object according to the callbacks given
	 */
class ScrollButton extends ImageButton
{
    private var rollover_callback : Function;
    private var rollout_callback : Function;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, _bitmap : Bitmap, _rollover_callback : Function = null, _rollout_callback : Function = null)
    {
        rollover_callback = _rollover_callback;
        rollout_callback = _rollout_callback;
        
        super(_x, _y, _width, _height, _bitmap, null, function() : Void
                {
                });
        name = "ScrollButton|" + super.name;
    }
    
    override public function draw() : Void
    {
        graphics.clear();
        graphics.beginFill(0xFFFFFF, 0.0);
        graphics.lineStyle(0, 0xFFFFFF, 0.0);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
        
        while (numChildren)
        {
            removeChildAt(0);
        }
        if (m_mouseOver)
        {
            addChild(m_image);
        }
    }
    
    override public function buttonRollOver(e : Event) : Void
    {
        m_mouseOver = true;
        rollover_callback();
        draw();
    }
    
    override public function buttonRollOut(e : Event) : Void
    {
        m_mouseOver = false;
        rollout_callback();
        draw();
    }
}
