package scenes.game.display;

import flash.geom.Point;
import flash.geom.Rectangle;
import graph.PropDictionary;
import scenes.BaseComponent;
import starling.display.DisplayObjectContainer;

class GameComponent extends BaseComponent
{
    public var hidden(get, never) : Bool;

    private static var DEBUG_TRACE_IDS : Bool = true;
    public var m_id : String;
    
    public var isSelected : Bool;
    public var m_isDirty : Bool = false;
    
    public var boundingBox : Rectangle;
    
    //these are here in that they determine color, so all screen objects need them set
    public var m_isWide : Bool = false;
    public var m_hasError : Bool = false;
    public var m_isEditable : Bool;
    public var m_shouldShowError : Bool = true;
    public var isHoverOn : Bool = false;
    public var draggable : Bool = true;
    private var m_propertyMode : String = PropDictionary.PROP_NARROW;
    public var m_forceColor : Int = -1;
    private var m_hidden : Bool = false;
    
    public static inline var NARROW_COLOR : Int = 0x6ED4FF;
    public static inline var NARROW_COLOR_BORDER : Int = 0x1773B8;
    public static inline var WIDE_COLOR : Int = 0x0077FF;
    public static inline var WIDE_COLOR_BORDER : Int = 0x1B3C86;
    public static inline var UNADJUSTABLE_WIDE_COLOR : Int = 0x808184;
    public static inline var UNADJUSTABLE_WIDE_COLOR_BORDER : Int = 0x404144;
    public static inline var UNADJUSTABLE_NARROW_COLOR : Int = 0xD0D2D3;
    public static inline var UNADJUSTABLE_NARROW_COLOR_BORDER : Int = 0x0;
    public static inline var ERROR_COLOR : Int = 0xF05A28;
    public static inline var SCORE_COLOR : Int = 0x0;
    public static inline var SELECTED_COLOR : Int = 0xFF0000;
    
    public function new(_id : String)
    {
        super();
        
        m_id = _id;
        isSelected = false;
    }
    
    public function componentMoved(delta : Point) : Void
    {
        x += delta.x;
        y += delta.y;
        boundingBox.x += delta.x;
        boundingBox.y += delta.y;
    }
    
    public function hasError() : Bool
    {
        return m_hasError;
    }
    
    public function componentSelected(_isSelected : Bool) : Void
    {
        isSelected = _isSelected;
        m_isDirty = true;
    }
    
    public function hideComponent(hide : Bool) : Void
    {
        visible = !hide;
        m_hidden = hide;
        m_isDirty = true;
    }
    
    private function get_hidden() : Bool
    {
        return m_hidden;
    }
    
    public function getGlobalScaleFactor() : Point
    {
        var pt : Point = new Point(1, 1);
        var currentParent : DisplayObjectContainer = parent;
        while (currentParent != null)
        {
            pt.x *= currentParent.scaleX;
            pt.y *= currentParent.scaleY;
            
            currentParent = currentParent.parent;
        }
        
        return pt;
    }
    
    public function isEditable() : Bool
    {
        return m_isEditable;
    }
    
    //override this
    public function isWide() : Bool
    {
        return m_isWide;
    }
    
    public function setIsWide(b : Bool) : Void
    {
        m_isWide = b;
    }
    
    public function forceColor(color : Int) : Void
    {
        m_forceColor = color;
        m_isDirty = true;
    }
    
    //set children's color, based on incoming and outgoing component and error condition
    public function getColor() : Int
    {
        var color : Int;
        if (m_forceColor > -1)
        {
            color = m_forceColor;
        }
        else if (m_shouldShowError && hasError())
        {
            color = ERROR_COLOR;
        }
        else if (m_isEditable == true)
        {
            if (m_isWide == true)
            {
                color = WIDE_COLOR;
            }
            else
            {
                color = NARROW_COLOR;
            }
        }
        //not adjustable
        else
        {
            
            {
                if (m_isWide == true)
                {
                    color = UNADJUSTABLE_WIDE_COLOR;
                }
                else
                {
                    color = UNADJUSTABLE_NARROW_COLOR;
                }
            }
        }
        
        return color;
    }
    
    public function updateSize() : Void
    {
    }
    
    public function getProps() : PropDictionary
    // Implemented by children
    {
        
        return new PropDictionary();
    }
    
    public function setProps(props : PropDictionary) : Void
    // Implemented by children
    {
        
        m_isDirty = true;
    }
    
    public function setPropertyMode(prop : String) : Void
    {
        m_propertyMode = prop;
        m_isDirty = true;
    }
}
