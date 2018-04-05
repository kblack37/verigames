package userInterface.components;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import userInterface.components.RectangularObject;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.*;
import mx.controls.Image;

/**
	 * A generic clickable button that has an image icon in the center and a rectangular outer edge.
	 */
class ImageButton extends Sprite implements GeneralButton
{
    public var disabled(never, set) : Bool;
    public var padding(never, set) : Int;
    public var mouseOver(get, never) : Bool;

    private var m_image : DisplayObject;
    private var m_rollover_image : DisplayObject;
    private var m_coverSprite : Sprite;
    public var m_mouseOver : Bool = false;
    private var m_disabled : Bool = false;
    private var m_callback : Function;
    private var m_borderColor : Float;
    private var m_padding : Int = 12;
    public var displayBorder : Bool = true;
    public var background_color : Float = 0xFFFFFF;
    public var background_alpha : Float = 0.1;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, _image : DisplayObject, _rollover_image : DisplayObject = null, _click_callback : Function = null)
    {
        super();
        //super(_x, _y, _width, _height);
        x = _x;
        y = _y;
        name = "ImageButton";
        m_image = _image;
        m_image.x = 0;
        m_image.y = 0;
        m_image.width = _width;
        m_image.height = _height;
        
        m_rollover_image = _rollover_image;
        if (m_rollover_image != null)
        {
            m_rollover_image.x = 0;
            m_rollover_image.y = 0;
            m_rollover_image.width = _width;
            m_rollover_image.height = _height;
            background_alpha = 0;
            displayBorder = false;
        }
        
        m_borderColor = -1;
        
        if (_click_callback != null)
        {
            m_callback = _click_callback;
            addEventListener(MouseEvent.CLICK, _click_callback);
        }
        
        addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
        addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
        
        m_coverSprite = new Sprite();
        
        buttonMode = true;
        
        draw();
    }
    
    public function draw() : Void
    {
        graphics.clear();
        while (numChildren)
        {
            removeChildAt(0);
        }
        graphics.beginFill(background_color, background_alpha);
        if (buttonMode && m_mouseOver && displayBorder)
        {
            graphics.lineStyle(4, 0xFFFFFF);
            graphics.drawRoundRect(-m_padding, -m_padding, m_image.width + 2 * m_padding, m_image.height + 2 * m_padding, 24, 24);
        }
        else if (m_borderColor != -1)
        {
            graphics.lineStyle(4, m_borderColor);
            graphics.drawRoundRect(-m_padding, -m_padding, m_image.width + 2 * m_padding, m_image.height + 2 * m_padding, 24, 24);
        }
        else
        {
            graphics.drawRoundRect(-m_padding, -m_padding, m_image.width + 2 * m_padding, m_image.height + 2 * m_padding, 24, 24);
        }
        graphics.endFill();
        if (m_rollover_image != null && m_mouseOver)
        {
            addChild(m_rollover_image);
        }
        else
        {
            addChild(m_image);
        }
        m_coverSprite.graphics.clear();
        m_coverSprite.graphics.beginFill(background_alpha, 0);
        m_coverSprite.graphics.lineStyle(4, background_color, 0);
        m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, m_image.width + 2 * m_padding, m_image.height + 2 * m_padding, 24, 24);
        
        addChild(m_coverSprite);
    }
    
    public function buttonRollOver(e : Event) : Void
    {
        m_mouseOver = true;
        draw();
    }
    
    public function buttonRollOut(e : Event) : Void
    {
        m_mouseOver = false;
        draw();
    }
    
    private function set_disabled(b : Bool) : Bool
    {
        m_disabled = b;
        if (b)
        {
            m_image.alpha = 0.2;
            buttonMode = false;
            removeEventListener(MouseEvent.CLICK, m_callback);
        }
        else
        {
            m_image.alpha = 1.0;
            buttonMode = true;
            addEventListener(MouseEvent.CLICK, m_callback);
        }
        draw();
        return b;
    }
    
    public function select() : Void
    {
        if (displayBorder)
        {
            m_borderColor = 0x000000;
        }
        draw();
    }
    
    public function unselect() : Void
    {
        m_borderColor = -1;
        draw();
    }
    
    private function set_padding(p : Int) : Int
    {
        m_padding = p;
        return p;
    }
    
    private function get_mouseOver() : Bool
    {
        return m_mouseOver;
    }
}
