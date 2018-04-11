package cgs.fractionVisualization.util;

import cgs.assets.fonts.FontCabin;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.math.CgsFraction;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import openfl.geom.Point;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
	 * Renders a fraction, including a numerator, denominator, a line separating them, and a sign
	 * @author Dmitri
	 */
class NumberRenderer extends Sprite
{
    public var doShowGlow(never, set) : Bool;
    public var fraction(get, never) : CgsFraction;
    public var glowColor(get, set) : Int;
    public var lineColor(get, set) : Int;
    public var lineThickness(get, set) : Float;
    public var showIntegerAsFraction(get, set) : Bool;
    public var denominatorAlpha(get, set) : Float;
    public var denominatorScale(get, set) : Float;
    public var numeratorAlpha(get, set) : Float;
    public var numeratorScale(get, set) : Float;

    public static inline var MAX_BOX_WIDTH : Float = 50;
    public static inline var MAX_BOX_HEIGHT : Float = 50;
    
    // State
    private var m_fraction : CgsFraction;  // The fraction rendered by this NumberRenderer  
    private var m_showIntegerAsFraction : Bool = true;
    private var m_textContainer : Sprite;  // This exists so that we can scale the text to fit in a box with one modifier without touching the scale of the number renderer itself  
    
    // Glow
    private var m_doShowGlow : Bool;
    private var m_glow : GlowFilter;
    
    // TextFields and TextFormats
    private var m_numeratorText : TextField;  // Numerator field  
    private var m_denominatorText : TextField;  // Denominator field  
    private var m_signText : TextField;  // Sign field  
    private var m_numeratorFormat : TextFormat;  // Numerator format  
    private var m_denominatorFormat : TextFormat;  // Denominator format  
    private var m_signFormat : TextFormat;  // Sign format  
    
    // The line separating the numerator and denominator
    private var m_line : Shape;  // The line separating numerator and denominator  
    private var m_lineColor : Int;  // Line color  
    private var m_lineThickness : Float;  // Line size  
    
    /**
		 * Create a new NumberRenderer based on the provided fraction
		 * @param	fraction
		 */
    public function new()
    {
        super();
        Font.registerFont(FontCabin);
        
        // background - for debug
        //graphics.beginFill(0xffaaff);
        //graphics.drawRect( -MAX_BOX_WIDTH / 2, -MAX_BOX_HEIGHT / 2, MAX_BOX_WIDTH, MAX_BOX_HEIGHT);
        //graphics.endFill();
        
        // Container
        m_textContainer = new Sprite();
        addChild(m_textContainer);
        
        // Line
        m_line = new Shape();
        m_textContainer.addChild(m_line);
        
        // Numerator text
        m_numeratorText = new TextField();
        m_numeratorText.embedFonts = true;
        m_numeratorFormat = new TextFormat("Cabin", GenConstants.DEFAULT_NUMBER_RENDERER_FONT_SIZE, 0x000000, true);
        m_numeratorText.defaultTextFormat = m_numeratorFormat;
        m_numeratorText.selectable = false;
        m_numeratorText.border = false;
        m_numeratorText.background = false;
        m_numeratorText.multiline = false;
        m_numeratorText.autoSize = TextFieldAutoSize.LEFT;
        m_textContainer.addChild(m_numeratorText);
        
        // Denominator text
        m_denominatorText = new TextField();
        m_denominatorText.embedFonts = true;
        m_denominatorFormat = new TextFormat("Cabin", GenConstants.DEFAULT_NUMBER_RENDERER_FONT_SIZE, 0x000000, true);
        m_denominatorText.defaultTextFormat = m_denominatorFormat;
        m_denominatorText.selectable = false;
        m_denominatorText.border = false;
        m_denominatorText.background = false;
        m_denominatorText.multiline = false;
        m_denominatorText.autoSize = TextFieldAutoSize.LEFT;
        m_textContainer.addChild(m_denominatorText);
        
        // Sign text
        m_signText = new TextField();
        m_signText.embedFonts = true;
        m_signFormat = new TextFormat("Cabin", GenConstants.DEFAULT_NUMBER_RENDERER_FONT_SIZE, 0x000000, true);
        m_signText.defaultTextFormat = m_signFormat;
        m_signText.selectable = false;
        m_signText.border = false;
        m_signText.background = false;
        m_signText.multiline = false;
        m_signText.autoSize = TextFieldAutoSize.LEFT;
        m_textContainer.addChild(m_signText);
        
        // Glow
        m_glow = new GlowFilter(0xffffff, 0.8, 2.4, 2.4, 40);
    }
    
    /**
		 * Initializes this Number Renderer with the given fraction.
		 * @param	fraction
		 */
    public function init(fraction : CgsFraction, signValue : String = "") : Void
    {
        m_fraction = fraction;
        m_signText.text = signValue;
        m_signText.width = m_signText.textWidth + 3;
        m_signText.height = m_signText.textHeight + 3;
        render();
    }
    
    /**
		 * Resets this Number Renderer to its uninitialized state.
		 */
    public function reset() : Void
    {
        m_fraction = null;
        m_signText.text = "";
        visible = true;
        alpha = 1;
        scaleX = 1;
        scaleY = 1;
        m_denominatorText.scaleX = 1;
        m_denominatorText.scaleY = 1;
        m_numeratorText.scaleX = 1;
        m_numeratorText.scaleY = 1;
        this.filters = [];
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Sets whether or not this Number Render should glow.
		 */
    private function set_doShowGlow(value : Bool) : Bool
    {
        m_doShowGlow = value;
        return value;
    }
    
    private function updateGlow() : Void
    {
        if (m_doShowGlow)
        {
            this.filters = [m_glow];
        }
        else
        {
            this.filters = [];
        }
    }
    
    /**
		 * Gets the fraction
		 */
    private function get_fraction() : CgsFraction
    {
        return m_fraction.clone();
    }
    
    /**
		 * Gets the glow color
		 */
    private function get_glowColor() : Int
    {
        return m_glow.color;
    }
    
    /**
		 * Sets the glow color
		 */
    private function set_glowColor(val : Int) : Int
    {
        m_glow.color = val;
        updateGlow();
        render();
        return val;
    }
    
    /**
		 * Gets the line color
		 */
    private function get_lineColor() : Int
    {
        return m_lineColor;
    }
    
    /**
		 * Sets the line color
		 */
    private function set_lineColor(val : Int) : Int
    {
        m_lineColor = val;
        render();
        return val;
    }
    
    /**
		 * Gets the line thickness
		 */
    private function get_lineThickness() : Float
    {
        return m_lineThickness;
    }
    
    /**
		 * Sets the line thickness
		 */
    private function set_lineThickness(val : Float) : Float
    {
        m_lineThickness = val;
        return val;
    }
    
    /**
		 * Sets whether to show trivial fraction (that is, an integer) as a fraction (that is, with the denominator)
		 */
    private function get_showIntegerAsFraction() : Bool
    {
        return m_showIntegerAsFraction;
    }
    
    /**
		 * Sets whether to show trivial fraction (that is, an integer) as a fraction (that is, with the denominator)
		 */
    private function set_showIntegerAsFraction(val : Bool) : Bool
    {
        m_showIntegerAsFraction = val;
        return val;
    }
    
    public function setTextColor(value : Int) : Void
    {
        m_numeratorFormat.color = value;
        m_numeratorText.defaultTextFormat = m_numeratorFormat;
        m_denominatorFormat.color = value;
        m_denominatorText.defaultTextFormat = m_denominatorFormat;
        m_signFormat.color = value;
        m_signText.defaultTextFormat = m_signFormat;
        render();
    }
    
    /**
		 * 
		 * Animation State
		 * 
		**/
    
    /**
		 * Returns the alpha of the denominator of this Number Renderer.
		 */
    private function get_denominatorAlpha() : Float
    {
        return m_denominatorText.alpha;
    }
    
    /**
		 * Sets the alpha of the denominator of this Number Renderer to be the given value.
		 */
    private function set_denominatorAlpha(value : Float) : Float
    {
        m_denominatorText.alpha = value;
        return value;
    }
    
    /**
		 * Returns the scale of the denominator of this Number Renderer.
		 */
    private function get_denominatorScale() : Float
    {
        return m_denominatorText.scaleX;
    }
    
    /**
		 * Sets the scale of the denominator of this Number Renderer to be the given value.
		 */
    private function set_denominatorScale(value : Float) : Float
    {
        m_denominatorText.scaleX = value;
        m_denominatorText.scaleY = value;
        render();
        return value;
    }
    
    /**
		 * Returns the alpha of the numerator of this Number Renderer.
		 */
    private function get_numeratorAlpha() : Float
    {
        return m_numeratorText.alpha;
    }
    
    /**
		 * Sets the alpha of the numerator of this Number Renderer to be the given value.
		 */
    private function set_numeratorAlpha(value : Float) : Float
    {
        m_numeratorText.alpha = value;
        return value;
    }
    
    /**
		 * Returns the scale of the numerator of this Number Renderer.
		 */
    private function get_numeratorScale() : Float
    {
        return m_numeratorText.scaleX;
    }
    
    /**
		 * Sets the scale of the numerator of this Number Renderer to be the given value.
		 */
    private function set_numeratorScale(value : Float) : Float
    {
        m_numeratorText.scaleX = value;
        m_numeratorText.scaleY = value;
        render();
        return value;
    }
    
    /**
		 * 
		 * Clones
		 * 
		**/
    
    public function cloneNumerator() : TextField
    {
        // Create clone
        var result : TextField = new TextField();
        result.embedFonts = true;
        result.defaultTextFormat = m_numeratorFormat;
        result.selectable = false;
        result.border = false;
        result.background = false;
        result.multiline = false;
        result.autoSize = TextFieldAutoSize.LEFT;
        
        // Set text and reposition
        result.text = Std.string(m_fraction.numerator);
        result.width = result.textWidth + 3;
        result.height = result.textHeight + 3;
        result.x = -result.width / 2;
        result.y = m_lineThickness;
        
        // Set scale
        var finalScale : Float = computeFinalScale();
        result.scaleX = finalScale;
        result.scaleY = finalScale;
        
        return result;
    }
    
    public function cloneDenominator() : TextField
    {
        // Create clone
        var result : TextField = new TextField();
        result.embedFonts = true;
        result.defaultTextFormat = m_denominatorFormat;
        result.selectable = false;
        result.border = false;
        result.background = false;
        result.multiline = false;
        result.autoSize = TextFieldAutoSize.LEFT;
        
        // Set text and reposition
        result.text = Std.string(m_fraction.denominator);
        result.width = result.textWidth + 3;
        result.height = result.textHeight + 3;
        result.x = -result.width / 2;
        result.y = m_lineThickness;
        
        // Set scale
        var finalScale : Float = computeFinalScale();
        result.scaleX = finalScale;
        result.scaleY = finalScale;
        
        return result;
    }
    
    /**
		 * 
		 * Render
		 * 
		**/
    
    /**
		 * Renders this NumberRenderer
		 */
    public function render() : Void
    {
        // Do nothing if we have no fraction
        if (m_fraction == null)
        {
            return;
        }
        
        // Update text
        m_numeratorText.text = Std.string(m_fraction.numerator);
        m_numeratorText.width = m_numeratorText.textWidth + 3;
        m_numeratorText.height = m_numeratorText.textHeight + 3;
        m_denominatorText.text = Std.string(m_fraction.denominator);
        m_denominatorText.width = m_denominatorText.textWidth + 3;
        m_denominatorText.height = m_denominatorText.textHeight + 3;
        var hasSign : Bool = m_signText.text != null && m_signText.text != "";
        m_signText.visible = hasSign;
        var showDenom : Bool = m_fraction.denominator != 1 || m_showIntegerAsFraction;
        m_denominatorText.visible = showDenom;
        m_line.visible = showDenom;
        
        // Adjust positions
        m_numeratorText.x = -m_numeratorText.width / 2;
        m_numeratorText.y = (showDenom) ? (-m_lineThickness - m_numeratorText.height) : (-m_numeratorText.height / 2);
        m_denominatorText.x = -m_denominatorText.width / 2;
        m_denominatorText.y = m_lineThickness;
        var fracWidth : Float = Math.max(m_numeratorText.width / m_numeratorText.scaleX, (showDenom) ? m_denominatorText.width / m_denominatorText.scaleX : 0);
        redrawLine(fracWidth);
        m_line.x = 0;
        m_line.y = 0;
        m_signText.x = -fracWidth / 2 - m_signText.width;
        m_signText.y = -m_signText.height / 2;
        
        // Compute the new scale such that the display will fit in the prescribed area
        /*fracWidth = fracWidth + (hasSign?m_signText.width:0);
			var fracHeight:Number = m_numeratorText.height / m_numeratorText.scaleY + (showDenom?(m_lineThickness + m_denominatorText.height / m_denominatorText.scaleY):0);
			var xScale:Number = 1.0;
			if (fracWidth > MAX_BOX_WIDTH)
			{
				xScale = MAX_BOX_WIDTH / fracWidth;
			}
			var yScale:Number = 1.0;
			if (fracHeight > MAX_BOX_HEIGHT)
			{
				yScale = MAX_BOX_HEIGHT / fracHeight;
			}
			
			// Set scale of text container
			var finalScale:Number = Math.min(xScale, yScale);*/
        var finalScale : Float = computeFinalScale();
        m_textContainer.scaleX = finalScale;
        m_textContainer.scaleY = finalScale;
    }
    
    private function computeFinalScale() : Float
    {
        // Compute the new scale such that the display will fit in the prescribed area
        var hasSign : Bool = m_signText.text != null && m_signText.text != "";
        var showDenom : Bool = m_fraction.denominator != 1 || m_showIntegerAsFraction;
        var fracWidth : Float = Math.max(m_numeratorText.width / m_numeratorText.scaleX, (showDenom) ? m_denominatorText.width / m_denominatorText.scaleX : 0);
        fracWidth = fracWidth + ((hasSign) ? m_signText.width : 0);
        var fracHeight : Float = m_numeratorText.height / m_numeratorText.scaleY + ((showDenom) ? (m_lineThickness + m_denominatorText.height / m_denominatorText.scaleY) : 0);
        var xScale : Float = 1.0;
        if (fracWidth > MAX_BOX_WIDTH)
        {
            xScale = MAX_BOX_WIDTH / fracWidth;
        }
        var yScale : Float = 1.0;
        if (fracHeight > MAX_BOX_HEIGHT)
        {
            yScale = MAX_BOX_HEIGHT / fracHeight;
        }
        
        // Set scale of text container
        return Math.min(xScale, yScale);
    }
    
    /**
		 * Redraws the line to a new width
		 * @param	linLen - the new line width
		 */
    private function redrawLine(lineWidth : Float) : Void
    {
        var grfx : Graphics = m_line.graphics;
        grfx.clear();
        grfx.lineStyle(m_lineThickness, m_lineColor, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
        grfx.moveTo(-lineWidth / 2, 0);
        grfx.lineTo(lineWidth / 2, 0);
        grfx.endFill();
    }
}

