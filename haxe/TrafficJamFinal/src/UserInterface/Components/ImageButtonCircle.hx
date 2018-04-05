package userInterface.components;

import haxe.Constraints.Function;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import userInterface.components.RectangularObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.text.*;
import mx.controls.Image;

/**
	 * A clickable button that displays an image in the center and a circle around the outside.
	 */
class ImageButtonCircle extends Sprite implements GeneralButton
{
    public var borderWidth(never, set) : Float;
    public var mouseOver(get, never) : Bool;

    public var m_image : DisplayObject;
    public var m_rollover_image : DisplayObject;
    private var m_radius : Int;
    private var m_border_width : Float;
    private var m_coverSprite : Sprite;
    public var m_mouseOver : Bool = false;
    private var m_borderColor : Float;
    private var m_callback : Function;
    private var m_enabled : Bool = true;
    
    public function new(_x : Int, _y : Int, _radius : Int, _image : DisplayObject, _rollover_image : DisplayObject = null, _click_callback : Function = null)
    {
        super();
        m_borderColor = -1;
        m_radius = _radius;
        m_callback = _click_callback;
        m_image = _image;
        m_image.width = 2 * _radius;
        m_image.height = 2 * _radius;
        m_image.x = -0.5 * m_image.width;
        m_image.y = -0.5 * m_image.height;
        name = "ImageButtonCircle";
        if (_click_callback != null)
        {
            addEventListener(MouseEvent.CLICK, _click_callback);
        }
        
        m_border_width = 0.1 * m_radius;
        
        addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
        addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
        
        m_coverSprite = new Sprite();
        m_coverSprite.graphics.beginFill(0xFFFFFF, 0.1);
        m_coverSprite.graphics.lineStyle(m_border_width, 0xFFFFFF, 0.1);
        m_coverSprite.graphics.drawCircle(0, 0, _radius);
        
        buttonMode = true;
    }
    
    public function draw() : Void
    {
        graphics.clear();
        while (numChildren)
        {
            removeChildAt(0);
        }
        if (buttonMode && m_mouseOver)
        {
            graphics.lineStyle(m_border_width, 0xFFFFFF);
            graphics.drawCircle(0, 0, m_radius);
        }
        else if (m_borderColor != -1)
        {
            graphics.lineStyle(m_border_width, m_borderColor);
            graphics.drawCircle(0, 0, m_radius);
        }
        if (m_rollover_image != null && m_mouseOver)
        {
            addChild(m_rollover_image);
        }
        else
        {
            addChild(m_image);
        }
        addChild(m_coverSprite);
    }
    
    public function buttonRollOver(e : Event) : Void
    {
        m_mouseOver = true;
        draw();
    }
    
    private function set_borderWidth(_n : Float) : Float
    {
        m_border_width = _n;
        draw();
        return _n;
    }
    
    public function buttonRollOut(e : Event) : Void
    {
        m_mouseOver = false;
        draw();
    }
    
    
    public function disable() : Void
    {
        if (!m_enabled)
        {
            return;
        }
        m_enabled = false;
        buttonMode = false;
        if (m_callback != null)
        {
            removeEventListener(MouseEvent.CLICK, m_callback);
        }
        
        m_border_width = 0.1 * m_radius;
        
        removeEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
        removeEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
        
        m_mouseOver = false;
    }
    
    public function enable() : Void
    {
        if (m_enabled)
        {
            return;
        }
        m_enabled = true;
        buttonMode = true;
        if (m_callback != null)
        {
            addEventListener(MouseEvent.CLICK, m_callback);
        }
        
        addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
        addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
    }
    
    public function select() : Void
    {
        m_borderColor = 0x000000;
        draw();
    }
    
    public function unselect() : Void
    {
        m_borderColor = -1;
        draw();
    }
    
    private function get_mouseOver() : Bool
    {
        return m_mouseOver;
    }
}
