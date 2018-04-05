package userInterface.components;

import userInterface.components.RectangularObject;
import utilities.Fonts;
import flash.display.Sprite;
import flash.events.TextEvent;
import flash.text.*;

/**
	 * Object that allows the user to enter text.
	 */
class InputBox extends RectangularObject
{
    public var fillColor(never, set) : Float;
    public var filled(never, set) : Bool;
    public var borderColor(never, set) : Float;
    public var label(never, set) : String;
    public var fontSize(never, set) : Float;
    public var passwordInput(never, set) : Bool;
    public var inputText(get, never) : String;

    private var m_textField : TextField;
    private var m_inputField : TextField;
    private var m_coverSprite : Sprite;
    private var m_filled : Bool = false;
    private var m_color : Float;
    private var m_inputWidth : Int;
    private var m_textFormat : TextFormat;
    private var m_inputFormat : TextFormat;
    private var m_borderColor : Float;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, text : String, fSize : Float, inputWidth : Int)
    {
        super(_x, _y, _width, _height);
        name = "InputBox" + instanceIndex;
        m_borderColor = 0x000000;
        m_color = 0x888888;
        m_inputWidth = inputWidth;
        
        m_textField = new TextField();
        m_textField.embedFonts = true;
        m_inputField = new TextField();
        m_inputField.embedFonts = true;
        m_textField.text = text;
        m_textFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, 0x000000, null, null, null, null, 
                null, TextFormatAlign.CENTER, 10, 10, null, 6);
        m_inputFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, 0x000000, null, null, null, null, 
                null, TextFormatAlign.CENTER, 10, 10, null, 6);
        m_textField.setTextFormat(m_textFormat);
        m_inputField.type = TextFieldType.INPUT;
        m_inputField.useRichTextClipboard = false;
        m_textField.wordWrap = true;
        m_textField.background = false;
        m_inputField.background = false;
        m_inputField.wordWrap = false;
        m_inputField.border = false;
        m_textField.width = width - inputWidth - 20;
        m_inputField.width = inputWidth;
        m_textField.height = height - 20;
        m_inputField.height = height - 20;
        m_textField.x = 0;
        m_textField.y = 10;
        m_inputField.x = width - inputWidth - 10;
        m_inputField.y = 10;
        m_inputField.defaultTextFormat = m_inputFormat;
        
        m_coverSprite = new Sprite();
        m_coverSprite.graphics.beginFill(0xFFFFFF, 0);
        m_coverSprite.graphics.drawRect(m_textField.x, m_textField.y, m_textField.width, m_textField.height);
        m_coverSprite.graphics.endFill();
        
        buttonMode = false;
        
        draw();
    }
    
    public function draw() : Void
    {
        graphics.clear();
        if (m_filled)
        {
            graphics.beginFill(m_color);
        }
        graphics.lineStyle(4, m_borderColor);
        graphics.drawRoundRect(0, 0, width, height, 30, 30);
        graphics.lineStyle(5, 0xFFFFFF);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRoundRect(m_inputField.x - 5, 5, m_inputWidth + 10, height - 10, 30, 30);
        graphics.endFill();
        while (numChildren)
        {
            removeChildAt(0);
        }
        m_inputField.defaultTextFormat = m_inputFormat;
        addChild(m_textField);
        addChild(m_inputField);
        addChild(m_coverSprite);
    }
    
    private function set_fillColor(n : Float) : Float
    {
        m_filled = true;
        m_color = n;
        draw();
        return n;
    }
    
    private function set_filled(b : Bool) : Bool
    {
        m_filled = b;
        return b;
    }
    
    private function set_borderColor(n : Float) : Float
    {
        m_borderColor = n;
        draw();
        return n;
    }
    
    private function set_label(s : String) : String
    {
        m_textField.text = s;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return s;
    }
    
    private function set_fontSize(n : Float) : Float
    {
        m_textFormat.size = n;
        m_inputFormat.size = n;
        m_textField.setTextFormat(m_textFormat);
        draw();
        return n;
    }
    
    private function set_passwordInput(b : Bool) : Bool
    {
        m_inputField.displayAsPassword = b;
        return b;
    }
    
    private function get_inputText() : String
    {
        return m_inputField.text;
    }
}
