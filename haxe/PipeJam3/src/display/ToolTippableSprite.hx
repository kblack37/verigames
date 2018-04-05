package display;

import events.ToolTipEvent;
import flash.geom.Point;
import flash.utils.Timer;
import flash.events.TimerEvent;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class ToolTippableSprite extends Sprite
{
    private var m_hoverTimer : Timer;
    private var m_hoverPointGlobal : Point;
    private var m_hoverDisabled : Bool = false;
    
    public function new()
    {
        super();
        if (getToolTipEvent())
        {
            addEventListener(TouchEvent.TOUCH, onTouch);
        }
    }
    
    private function onTouch(event : TouchEvent) : Void
    {
        if (event.getTouches(this, TouchPhase.HOVER).length)
        {
            var touch : Touch = event.getTouches(this, TouchPhase.HOVER)[0];
            showToolTipDisplay(touch);
        }
        else
        {
            hideToolTipDisplay();
        }
    }
    
    private function showToolTipDisplay(touch : Touch) : Void
    {
        m_hoverPointGlobal = new Point(touch.globalX, touch.globalY);
        if (m_hoverTimer == null)
        {
            m_hoverTimer = new Timer(Constants.TOOL_TIP_DELAY_SEC * 1000, 0);
            m_hoverTimer.addEventListener(TimerEvent.TIMER, onHoverDetected);
            m_hoverTimer.start();
        }
    }
    
    private function hideToolTipDisplay() : Void
    {
        if (m_hoverTimer != null)
        {
            m_hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverDetected);
            m_hoverTimer.stop();
            m_hoverTimer = null;
        }
        m_hoverPointGlobal = null;
        onHoverEnd();
    }
    
    override public function dispose() : Void
    {
        super.dispose();
        if (m_hoverTimer != null)
        {
            m_hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverDetected);
            m_hoverTimer.stop();
            m_hoverTimer = null;
        }
        m_hoverPointGlobal = null;
        removeEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    private function getToolTipEvent() : ToolTipEvent
    {
        return null;
    }
    
    private function onHoverEnd() : Void
    {
        dispatchEvent(new ToolTipEvent(ToolTipEvent.CLEAR_TOOL_TIP, this));
    }
    
    public function disableHover() : Void
    {
        m_hoverDisabled = true;
        if (m_hoverTimer != null)
        {
            m_hoverTimer.removeEventListener(TimerEvent.TIMER, onHoverDetected);
            m_hoverTimer.stop();
            m_hoverTimer = null;
        }
        m_hoverPointGlobal = null;
    }
    
    public function enableHover() : Void
    {
        m_hoverDisabled = false;
    }
    
    private function onHoverDetected(evt : TimerEvent) : Void
    {
        if (m_hoverDisabled)
        {
            return;
        }
        var toolTipEvt : ToolTipEvent = getToolTipEvent();
        if (toolTipEvt != null)
        {
            if (m_hoverPointGlobal != null)
            {
                toolTipEvt.point = m_hoverPointGlobal.clone();
            }
            dispatchEvent(toolTipEvt);
        }
    }
}

