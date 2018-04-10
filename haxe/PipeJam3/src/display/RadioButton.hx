package display;

import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class RadioButton extends SimpleButton
{
    private var mIsDown : Bool = false;
    
    public function new(up : DisplayObject, over : DisplayObject, down : DisplayObject, toolTipText : String, hitSubRect : Rectangle = null)
    {
        super(up, over, down, hitSubRect);
        m_toolTipText = toolTipText;
    }
    
    override private function onTouch(event : TouchEvent) : Void
    {
        var touch : Touch;
        if (event.getTouches(this, TouchPhase.HOVER).length)
        {
            touch = event.getTouches(this, TouchPhase.HOVER)[0];
            showToolTipDisplay(touch);
        }
        else
        {
            hideToolTipDisplay();
        }
        
        
        touch = event.getTouch(this);
        if (!m_enabled || touch == null)
        {
            if (m_current == null)
            {
                m_current = m_up;
            }
            toState(lastTouchState);
            lastTouchState = m_up;
            return;
        }
        
        if (touch.phase == TouchPhase.HOVER)
        {
            if (m_current != m_over)
            {
                lastTouchState = m_current;
                toState(m_over);
                dispatchEventWith(HOVER_OVER, true, dispatchEventWith);
            }
        }
        else if (touch.phase == TouchPhase.BEGAN)
        {
        //if down, leave down, else flip
            
            if (!mIsDown)
            {
                mIsDown = !mIsDown;
            }
            if (mIsDown)
            {
                toState(m_down);
                dispatchEventWith(Event.TRIGGERED, true);
            }
            else
            {
                toState(m_up);
            }
        }
    }
    
    public function setState(turnOn : Bool) : Void
    {
        mIsDown = turnOn;
        if (mIsDown)
        {
            toState(m_down);
        }
        else
        {
            toState(m_up);
        }
    }
}
