package userInterface.components;

import haxe.Constraints.Function;
import flash.geom.Rectangle;
import userInterface.components.RectangularObject;
import utilities.Fonts;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.text.*;
import mx.controls.Image;

/**
	 * A clickable button containing text (such as "OK" Button) that has a highlighted border when moused over
	 */
class TextButton extends RectangularObject implements GeneralButton
{
    public var padding(never, set) : Int;
    public var text(get, set) : String;
    public var fontSize(never, set) : Float;
    public var backgroundColor(get, set) : Float;
    public var backgroundAlpha(never, set) : Float;
    public var curvature(never, set) : Float;
    public var textColor(never, set) : Float;
    public var borderColor(never, set) : Float;
    public var rolloverBorderColor(never, set) : Float;
    public var disabled(never, set) : Bool;
    public var mouseOver(get, never) : Bool;
    public var coverAlpha(never, set) : Float;

    
    private var m_textField : TextField;
    private var m_height : Int;
    private var m_width : Int;
    private var m_textFormat : TextFormat = new TextFormat(Fonts.FONT_DEFAULT, 18, 0x000, true, false, false, null, null, TextFormatAlign.CENTER);
    private var m_coverSprite : Sprite;
    public var m_mouseOver : Bool = false;
    private var m_borderColor : Float;
    private var m_rolloverBorderColor : Float;
    private var m_backgroundColor : Float;
    private var m_alpha : Float = 1.0;
    private var m_padding : Int = 12;
    private var m_disabled : Bool = false;
    private var m_callback : Function;
    private var m_blinking : Bool = false;
    private var m_cover_alpha : Float = 0.1;
    private var m_curvature : Float = 24;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, _text : String, _click_callback : Function = null)
    {
        super(_x, _y, _width, _height);
        name = "TextButton:" + _text;
        m_width = _width;
        m_height = _height;
        m_borderColor = -1;
        m_rolloverBorderColor = 0xFFFFFF;
        m_backgroundColor = -1;
        
        m_callback = _click_callback;
        m_textField = new TextField();
        m_textField.embedFonts = true;
        m_textField.text = _text;
        m_textField.setTextFormat(m_textFormat);
        m_textField.wordWrap = true;
        
        m_textField.width = width;
        m_textField.x = 0;
        m_textField.autoSize = TextFieldAutoSize.CENTER;
        m_textField.y = Math.max(0, height / 2 - (try cast(m_textField.getBounds(this), Rectangle) catch(e:Dynamic) null).height / 2);
        
        m_coverSprite = new Sprite();
        m_coverSprite.graphics.beginFill(0xFFFFFF, m_cover_alpha);
        m_coverSprite.graphics.lineStyle(4, 0xFFFFFF, m_cover_alpha);
        m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, width + 2 * m_padding, height + 2 * m_padding, m_curvature, m_curvature);
        m_coverSprite.graphics.endFill();
        
        if (_click_callback != null)
        {
            addEventListener(MouseEvent.CLICK, _click_callback);
        }
        
        addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
        addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
        
        m_textField.selectable = false;
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
        if (m_backgroundColor != -1)
        {
            graphics.beginFill(m_backgroundColor, m_alpha);
        }
        else
        {
            graphics.beginFill(0xFFFFFF, 0);
        }
        if ((buttonMode && m_mouseOver && !m_disabled) || m_blinking)
        {
            graphics.lineStyle(4, m_rolloverBorderColor);
            graphics.drawRoundRect(-m_padding, -m_padding, width + 2 * m_padding, height + 2 * m_padding, m_curvature, m_curvature);
        }
        else
        {
            if (m_borderColor != -1)
            {
                graphics.lineStyle(4, m_borderColor);
            }
            graphics.drawRoundRect(-m_padding, -m_padding, width + 2 * m_padding, height + 2 * m_padding, m_curvature, m_curvature);
        }
        addChild(m_textField);
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
    
    private function set_padding(p : Int) : Int
    {
        m_padding = p;
        m_coverSprite = new Sprite();
        m_coverSprite.graphics.beginFill(0xFFFFFF, 0.1);
        m_coverSprite.graphics.lineStyle(4, 0xFFFFFF, 0.1);
        m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, width + 2 * m_padding, height + 2 * m_padding, m_curvature, m_curvature);
        draw();
        return p;
    }
    
    private function set_text(s : String) : String
    {
        m_textField.text = s;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return s;
    }
    
    private function get_text() : String
    {
        return m_textField.text;
    }
    
    private function set_fontSize(n : Float) : Float
    {
        m_textFormat.size = n;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return n;
    }
    
    private function set_backgroundColor(c : Float) : Float
    {
        m_backgroundColor = c;
        draw();
        return c;
    }
    
    private function get_backgroundColor() : Float
    {
        return m_backgroundColor;
    }
    
    private function set_backgroundAlpha(a : Float) : Float
    {
        m_alpha = a;
        draw();
        return a;
    }
    
    private function set_curvature(n : Float) : Float
    {
        m_curvature = n;
        draw();
        return n;
    }
    
    private function set_textColor(n : Float) : Float
    {
        m_textFormat.color = n;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return n;
    }
    
    private function set_borderColor(n : Float) : Float
    {
        m_borderColor = n;
        draw();
        return n;
    }
    
    private function set_rolloverBorderColor(n : Float) : Float
    {
        m_rolloverBorderColor = n;
        draw();
        return n;
    }
    
    private function set_disabled(b : Bool) : Bool
    {
        m_disabled = b;
        if (b)
        {
            m_textField.alpha = 0.2;
            buttonMode = false;
            removeEventListener(MouseEvent.CLICK, m_callback);
        }
        else
        {
            m_textField.alpha = 1.0;
            buttonMode = true;
            addEventListener(MouseEvent.CLICK, m_callback);
        }
        draw();
        return b;
    }
    
    public function toggleBlink() : Void
    {
        if (m_blinking)
        {
            m_blinking = false;
        }
        else
        {
            m_blinking = true;
        }
        draw();
    }
    
    public function unblink() : Void
    {
        m_blinking = false;
        draw();
    }
    
    public function centerVertically() : Void
    {
        m_textField.y = 0.5 * (m_height - m_textField.textHeight);
    }
    
    private function get_mouseOver() : Bool
    {
        return m_mouseOver;
    }
    
    private function set_coverAlpha(n : Float) : Float
    {
        m_cover_alpha = n;
        m_coverSprite = new Sprite();
        m_coverSprite.graphics.beginFill(0xFFFFFF, m_cover_alpha);
        m_coverSprite.graphics.lineStyle(4, 0xFFFFFF, m_cover_alpha);
        m_coverSprite.graphics.drawRoundRect(-m_padding, -m_padding, width + 2 * m_padding, height + 2 * m_padding, m_curvature, m_curvature);
        m_coverSprite.graphics.endFill();
        return n;
    }
}
