package userInterface.components;

import userInterface.components.RectangularObject;
import utilities.Fonts;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.*;

/**
	 * An object useful for tutorials that is a horizontal black strip with white lettering, the left and right edges tapering off in alpha
	 */
class MessageStrip extends ClearLabel
{
    private var m_background_alpha : Float = 0.90;
    private var m_left_stop : Float = 0.2;
    private var m_right_stop : Float = 0.8;
    
    public function new(_x : Int, _y : Int, _width : Int, _height : Int, text : String, fSize : Float)
    {
        super(_x, _y, _width, _height, text, fSize);
        name = "MessageStrip:" + text;
        m_color = 0x000000;
        m_borderColor = 0xFFFFFF;
        
        m_textFormat = new TextFormat(Fonts.FONT_DEFAULT, fSize, 0xFFFFFF, null, null, null, null, 
                null, TextFormatAlign.CENTER, 10, 10, null, 6);
        m_textField.setTextFormat(m_textFormat);
        m_textField.width = width * (m_right_stop - m_left_stop);
        m_textField.height = height;
        m_textField.x = width / 2 - m_textField.width / 2;
        m_textField.y = height / 2 - m_textField.height / 2;
        centerVertically();
        draw();
    }
    
    override public function draw() : Void
    {
        graphics.clear();
        // gradient left to right
        var colors : Array<Dynamic> = new Array<Dynamic>(m_color, m_color, m_color, m_color);
        var alphas : Array<Dynamic> = new Array<Dynamic>(0.10, m_background_alpha, m_background_alpha, .10);
        var ratios : Array<Dynamic> = new Array<Dynamic>(0, 255 * m_left_stop, 255 * m_right_stop, 255);
        var matrix : Matrix = new Matrix();
        matrix.createGradientBox(m_width, m_height, 0, 0, 0);
        //var matrix:Object = {matrixType:"box", x:left, y:top, w:cw, h:cw, r:45/180*Math.PI};
        graphics.beginGradientFill("linear", colors, alphas, ratios, matrix);
        graphics.lineStyle(1, m_borderColor, 0.0);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
        
        addChild(m_textField);
        addChild(m_coverSprite);
    }
    
    override private function set_text(s : String) : String
    {
        m_textField.text = s;
        m_textField.setTextFormat(m_textFormat);
        centerVertically();
        draw();
        return s;
    }
}
