package userInterface.components;

import userInterface.components.RectangularObject;
import utilities.Fonts;
import flash.display.Sprite;
import flash.text.*;

/**
	 * A rectangular text box label (not clickable)
	 */
class ClearLabel extends RectangularObject
{
    public var color(never, set) : Float;
    public var backgroundAlpha(never, set) : Float;
    public var borderColor(never, set) : Float;
    public var blinking(never, set) : Bool;
    public var text(never, set) : String;
    public var fontSize(never, set) : Float;
    public var curvature(never, set) : Float;
    public var textColor(never, set) : Float;

    private var m_width : Int;
    private var m_height : Int;
    private var m_textField : TextField;
    private var m_coverSprite : Sprite;
    private var m_color : Float;
    private var m_text_color : Float = 0xFFFFFF;
    private var m_textFormat : TextFormat;
    private var m_borderColor : Float;
    private var m_blinking : Bool = false;
    private var m_alpha : Float = 0.85;
    private var m_curvature : Float = 30;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, text : String, fSize : Float)
    {
        super(_x, _y, _width, _height);
        name = "ClearLabel" + instanceIndex;
        m_width = _width;
        m_height = _height;
        m_color = 0x8B8B51;
        m_borderColor = 0x4A4A2B;
        
        m_textField = new TextField();
        m_textField.embedFonts = true;
        m_textField.selectable = false;
        m_textField.text = text;
        m_textFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, m_text_color, null, null, null, null, 
                null, TextFormatAlign.CENTER, 10, 10, null, 6);
        m_textField.setTextFormat(m_textFormat);
        m_textField.wordWrap = true;
        m_textField.background = false;
        
        m_textField.width = width;
        m_textField.height = height;
        m_textField.x = width / 2 - m_textField.width / 2;
        m_textField.y = height / 2 - m_textField.height / 2;
        
        m_coverSprite = new Sprite();
        m_coverSprite.graphics.beginFill(0xFFFFFF, 0.01);
        m_coverSprite.graphics.drawRoundRect(m_textField.x, m_textField.y, m_textField.width, m_textField.height, m_curvature, m_curvature);
        m_coverSprite.graphics.endFill();
        
        buttonMode = false;
        
        draw();
    }
    
    public function draw() : Void
    {
        graphics.clear();
        
        graphics.beginFill(m_color, m_alpha);
        graphics.lineStyle(4, m_borderColor);
        if (m_blinking)
        {
            graphics.lineStyle(4, 0xFFFFFF);
        }
        
        graphics.drawRoundRect(0, 0, width, height, m_curvature, m_curvature);
        graphics.endFill();
        
        addChild(m_textField);
        
        addChild(m_coverSprite);
    }
    
    private function set_color(n : Float) : Float
    {
        m_color = n;
        draw();
        return n;
    }
    
    private function set_backgroundAlpha(n : Float) : Float
    {
        m_alpha = n;
        draw();
        return n;
    }
    
    private function set_borderColor(n : Float) : Float
    {
        m_borderColor = n;
        draw();
        return n;
    }
    
    // use this to emphasize/blink label [e.g. during tutorial]
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
    
    private function set_blinking(b : Bool) : Bool
    {
        m_blinking = b;
        draw();
        return b;
    }
    
    private function set_text(s : String) : String
    {
        m_textField.text = s;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return s;
    }
    
    private function set_fontSize(n : Float) : Float
    {
        m_textFormat.size = n;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return n;
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
    
    public function centerVertically() : Void
    {
        m_textField.y = 0.5 * (m_height - m_textField.textHeight);
    }
}
