package display;

import haxe.Constraints.Function;
import flash.geom.Point;
import scenes.game.display.Level;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;

/**
	 * Text bubble that updates/follows a component based on the level it uses
	 */
class TextBubbleFollowComponent extends TextBubble
{
    private var m_pointAtFn : Function;
    private var m_level : Level;
    
    public function new(_pointAtFn : Function, _level : Level, _text : String,
            _fontSize : Float = 10, _fontColor : Int = 0xEEEEEE,
            _pointFrom : String = Constants.BOTTOM_LEFT,
            _pointTo : String = Constants.BOTTOM_LEFT,
            _size : Point = null, _arrowSz : Float = 10,
            _arrowBounce : Float = 2, _arrowBounceSpeed : Float = 0.5,
            _inset : Float = 3, _showBox : Bool = true,
            _arrowColor : Float = Math.NaN, _outlineWeight : Float = 0,
            _outlineColor : Int = 0x0)
    {
        m_pointAtFn = _pointAtFn;
        m_level = _level;
        
        var pointAtComponent : DisplayObject = ((m_pointAtFn != null)) ? m_pointAtFn(m_level) : null;
        
        var pointPosAlwaysUpdate : Bool = true;
        if (m_level.tutorialManager && !m_level.tutorialManager.getPanZoomAllowed() && m_level.tutorialManager.getLayoutFixed())
        {
            pointPosAlwaysUpdate = false;
        }
        
        super(_text, _fontSize, _fontColor, pointAtComponent, m_level, _pointFrom, _pointTo, _size, pointPosAlwaysUpdate, _arrowSz, _arrowBounce, _arrowBounceSpeed, _inset, _showBox, _arrowColor, _outlineWeight, _outlineColor);
    }
    
    override private function onEnterFrame(evt : Event) : Void
    {
        if ((m_pointAtFn != null) && ((m_pointAt == null) || (m_pointAt.parent == null)))
        {
            m_pointAt = m_pointAtFn(m_level);
            this.visible = (m_pointAt != null);
        }
        super.onEnterFrame(evt);
    }
}

