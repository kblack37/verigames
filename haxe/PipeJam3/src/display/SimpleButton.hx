package display;

import events.ToolTipEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import utils.XSprite;

@:meta(Event(name="triggered",type="starling.events.Event"))

@:meta(Event(name="hoverOver",type="starling.events.Event"))

class SimpleButton extends ToolTippableSprite
{
    public var enabled(get, set) : Bool;
    public var data(get, set) : Dynamic;

    private static var DEBUG_HIT : Bool = false;
    private static var DEBUG_STATE : Bool = false;
    
    public static inline var HOVER_OVER : String = "hoverOver";
    
    public static inline var UP_STATE : String = "upState";
    public static inline var OVER_STATE : String = "overState";
    public static inline var DOWN_STATE : String = "downState";
    
    private var m_up : DisplayObject;
    private var m_over : DisplayObject;
    private var m_down : DisplayObject;
    private var m_current : DisplayObject;
    
    private var m_hitSubRect : Rectangle;
    
    private var m_enabled : Bool;
    private var m_useHandCursor : Bool;
    
    private var m_data : Dynamic;
    private var m_toolTipText : String;
    
    public function new(up : DisplayObject, over : DisplayObject, down : DisplayObject, hitSubRect : Rectangle = null)
    {
        super();
        m_enabled = true;
        m_useHandCursor = false;
        
        m_hitSubRect = hitSubRect;
        
        var container : Sprite = new Sprite();
        addChild(container);
        
        m_up = up;
        m_up.visible = false;
        container.addChild(m_up);
        
        m_over = over;
        m_over.visible = false;
        container.addChild(m_over);
        
        m_down = down;
        m_down.visible = false;
        container.addChild(m_down);
        
        m_current = m_up;
        m_current.visible = true;
        
        addEventListener(TouchEvent.TOUCH, onTouch);
        
        if (DEBUG_HIT)
        {
            var hit : DisplayObject;
            if (m_hitSubRect != null)
            {
                hit = XSprite.createPolyRect(m_hitSubRect.width, m_hitSubRect.height, 0xFF00FF, 0, 0.25);
                hit.x = m_hitSubRect.x;
                hit.y = m_hitSubRect.y;
            }
            else
            {
                hit = XSprite.createPolyRect(width, height, 0xFF00FF, 0, 0.25);
            }
            container.addChild(hit);
        }
    }
    
    override public function dispose() : Void
    {
        removeEventListener(TouchEvent.TOUCH, onTouch);
        
        super.dispose();
    }
    
    private function get_enabled() : Bool
    {
        return m_enabled;
    }
    
    private function set_enabled(value : Bool) : Bool
    {
        if (m_enabled != value)
        {
            m_enabled = value;
            alpha = (m_enabled) ? 1.0 : 0.5;
            toState(m_up);
        }
        return value;
    }
    
    private function set_data(value : Dynamic) : Dynamic
    {
        m_data = value;
        return value;
    }
    
    private function get_data() : Dynamic
    {
        return m_data;
    }
    
    override public function hitTest(localPoint : Point, forTouch : Bool = false) : DisplayObject
    {
        var superHit : DisplayObject = super.hitTest(localPoint, forTouch);
        
        if (m_hitSubRect == null)
        {
            return superHit;
        }
        
        if (superHit == null)
        {
            return null;
        }
        
        return (m_hitSubRect.containsPoint(localPoint)) ? this : null;
    }
    
    private var lastTouchState : DisplayObject = m_up;
    override private function onTouch(event : TouchEvent) : Void
    {
        super.onTouch(event);
        
        Mouse.cursor = ((m_useHandCursor && m_enabled && event.interactsWith(this))) ? MouseCursor.BUTTON : MouseCursor.AUTO;
        
        var touch : Touch = event.getTouch(this);
        var isHovering : Bool = (event.getTouch(try cast(event.target, DisplayObject) catch(e:Dynamic) null, TouchPhase.HOVER) != null);
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
        else if (touch.phase == TouchPhase.MOVED)
        {
            if (hitTest(touch.getLocation(this)))
            {
                toState(m_down);
            }
            else
            {
                toState(m_up);
            }
        }
        else if (touch.phase == TouchPhase.BEGAN)
        {
            toState(m_down);
        }
        else if (touch.phase == TouchPhase.ENDED)
        {
            if (m_current == m_down)
            {
                if (m_data == null)
                {
                    m_data = {};
                }
                m_data.tapCount = touch.tapCount;
                toState(m_up);
                dispatchEventWith(Event.TRIGGERED, true, m_data);
            }
        }
    }
    
    public function toState(state : DisplayObject) : Void
    {
        if (DEBUG_STATE)
        {
            trace("Current: " + getState(m_current));
        }
        if (m_current != state)
        {
            if (DEBUG_STATE)
            {
                trace("To: " + getState(state));
            }
            m_current.visible = false;
            m_current = state;
            if (m_current == null)
            {
                m_current = m_up;
            }
            m_current.visible = true;
        }
    }
    
    private function getState(state : DisplayObject) : String
    {
        if (state == m_down)
        {
            return DOWN_STATE;
        }
        if (state == m_over)
        {
            return OVER_STATE;
        }
        if (state == m_up)
        {
            return UP_STATE;
        }
        if (state == null)
        {
            return "null";
        }
        return "unknown";
    }
    
    public function setStatePosition(stateString : String) : Void
    {
        if (stateString == UP_STATE)
        {
            toState(m_up);
        }
        else if (stateString == OVER_STATE)
        {
            toState(m_over);
        }
        else if (stateString == DOWN_STATE)
        {
            toState(m_down);
        }
    }
    
    override private function getToolTipEvent() : ToolTipEvent
    {
        if (m_toolTipText != null)
        {
            return new ToolTipEvent(ToolTipEvent.ADD_TOOL_TIP, this, m_toolTipText);
        }
        return null;
    }
}

