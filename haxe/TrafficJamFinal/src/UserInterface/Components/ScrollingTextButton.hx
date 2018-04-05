package userInterface.components;

import haxe.Constraints.Function;
import userInterface.components.TextButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.*;
import mx.controls.Image;

/**
	 * A text button containing text that may be very long, the button automatically scrolls from top to bottom and back up to allow reading
	 */
class ScrollingTextButton extends TextButton implements GeneralButton
{
    
    private var m_scroll_v : Int;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, _text : String, _click_callback : Function = null)
    {
        super(_x, _y, _width, _height, _text, _click_callback);
        name = "ScrollingTextButton:" + _text;
    }
    
    override public function buttonRollOver(e : Event) : Void
    {
        m_mouseOver = true;
        if (m_textField.textHeight > m_height)
        {
            m_textField.height = m_height;
            if (m_textField.scrollV == m_textField.maxScrollV)
            {
                m_textField.scrollV = 1;
            }
            else
            {
                m_textField.scrollV += 1;
            }
        }
        draw();
    }
    
    override public function buttonRollOut(e : Event) : Void
    //m_textField.scrollV = 1;
    {
        
        m_mouseOver = false;
        draw();
    }
}
