package cgs.fractionVisualization;

import cgs.engine.view.CGSSprite;
import cgs.fractionVisualization.fractionModules.IFractionModule;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.util.FractionModuleFactory;
import cgs.math.CgsFraction;
import flash.display.Sprite;

/**
	 * ...
	 * @author Rich
	 */
class CgsFractionView extends CGSSprite
{
    public var backgroundColor(get, set) : Int;
    public var borderColor(get, set) : Int;
    public var fillColor(get, set) : Int;
    public var foregroundColor(get, set) : Int;
    public var fraction(get, never) : CgsFraction;
    public var representationType(get, never) : String;
    public var showNumbers(get, set) : Bool;
    public var textColor(get, set) : Int;
    public var textGlowColor(get, set) : Int;
    public var tickColor(get, set) : Int;
    public var module(get, never) : IFractionModule;

    // State
    private var m_fractionSprite : FractionSprite;
    private var m_fractionModule : IFractionModule;
    private var m_fraction : CgsFraction;
    private var m_representationType : String;
    
    // Colors
    private var m_foregroundColor : Int = GenConstants.DEFAULT_FOREGROUND_COLOR;
    private var m_backgroundColor : Int = GenConstants.DEFAULT_BACKGROUND_COLOR;
    private var m_borderColor : Int = GenConstants.DEFAULT_BORDER_COLOR;
    private var m_tickColor : Int = GenConstants.DEFAULT_TICK_COLOR;
    private var m_fillColor : Int = GenConstants.DEFAULT_FILL_COLOR;
    private var m_textColor : Int = GenConstants.DEFAULT_TEXT_COLOR;
    private var m_textGlowColor : Int = GenConstants.DEFAULT_TEXT_GLOW_COLOR;
    
    public function new(startFraction : CgsFraction, startRepresentationType : String)
    {
        super();
        m_fractionSprite = new FractionSprite(this);
        addChild(m_fractionSprite);
        
        m_fraction = startFraction;
        m_representationType = startRepresentationType;
        
        m_fractionModule = FractionModuleFactory.getInstance().getModuleInstance(m_representationType);
        m_fractionModule.init(m_fractionSprite);
        redraw();
    }
    
    /**
		 * @inheritDoc
		 */
    override public function destroy() : Void
    {
        // Destroy module
        FractionModuleFactory.getInstance().recycleModuleInstance(m_fractionModule);
        m_fractionModule = null;
        
        // Destroy fraction sprite
        removeChild(m_fractionSprite);
        m_fractionSprite.destroy();
        m_fractionSprite = null;
        
        // Destroy fraction
        m_fraction = null;
        
        super.destroy();
    }
    
    /**
		 * 
		 * State
		 * 
		**/
#if !flash
    override
#end
    public function get_width() : Float
    {
        return m_fractionModule.totalWidth;
    }
    
    /**
		 * Returns the background color of this CgsFractionView.
		 */
    private function get_backgroundColor() : Int
    {
        return m_backgroundColor;
    }
    
    /**
		 * Sets the background color of this CgsFractionView to be the given value.
		 */
    private function set_backgroundColor(value : Int) : Int
    {
        m_backgroundColor = value;
        return value;
    }
    
    /**
		 * Returns the border color of this CgsFractionView.
		 */
    private function get_borderColor() : Int
    {
        return m_borderColor;
    }
    
    /**
		 * Sets the border color of this CgsFractionView to be the given value.
		 */
    private function set_borderColor(value : Int) : Int
    {
        m_borderColor = value;
        return value;
    }
    
    /**
		 * Returns the fill color of this CgsFractionView.
		 */
    private function get_fillColor() : Int
    {
        return m_fillColor;
    }
    
    /**
		 * Sets the fill color of this CgsFractionView to be the given value.
		 */
    private function set_fillColor(value : Int) : Int
    {
        m_fillColor = value;
        return value;
    }
    
    /**
		 * Returns the foreground color of this CgsFractionView.
		 */
    private function get_foregroundColor() : Int
    {
        return m_foregroundColor;
    }
    
    /**
		 * Sets the foreground color of this CgsFractionView to be the given value.
		 */
    private function set_foregroundColor(value : Int) : Int
    {
        m_foregroundColor = value;
        return value;
    }
    
    /**
		 * Returns the fraction of this CgsFractionView.
		 */
    private function get_fraction() : CgsFraction
    {
        return m_fraction;
    }
    
    /**
		 * Returns the representation type of this CgsFractionView.
		 */
    private function get_representationType() : String
    {
        return m_representationType;
    }
    
    /**
		 * Returns the background color of this CgsFractionView.
		 */
    private function get_showNumbers() : Bool
    {
        return m_fractionSprite.doShowNumberRenderers;
    }
    
    /**
		 * Sets the background color of this CgsFractionView to be the given value.
		 */
    private function set_showNumbers(value : Bool) : Bool
    {
        m_fractionSprite.doShowNumberRenderers = value;
        redraw();
        return value;
    }
    
    /**
		 * Returns the text color of this CgsFractionView.
		 */
    private function get_textColor() : Int
    {
        return m_textColor;
    }
    
    /**
		 * Sets the text color of this CgsFractionView to be the given value.
		 */
    private function set_textColor(value : Int) : Int
    {
        m_textColor = value;
        return value;
    }
    
    /**
		 * Returns the text glow color of this CgsFractionView.
		 */
    private function get_textGlowColor() : Int
    {
        return m_textGlowColor;
    }
    
    /**
		 * Sets the text glow color of this CgsFractionView to be the given value.
		 */
    private function set_textGlowColor(value : Int) : Int
    {
        m_textGlowColor = value;
        return value;
    }
    
    /**
		 * Returns the tick color of this CgsFractionView.
		 */
    private function get_tickColor() : Int
    {
        return m_tickColor;
    }
    
    /**
		 * Sets the tick color of this CgsFractionView to be the given value.
		 */
    private function set_tickColor(value : Int) : Int
    {
        m_tickColor = value;
        return value;
    }
    
    private function get_module() : IFractionModule
    {
        return m_fractionModule;
    }
    
    /**
		 * 
		 * Cloning
		 * 
		**/
    
    /**
		 * Clone this CgsFractionView.
		 * @return
		 */
    public function clone() : CgsFractionView
    {
        var result : CgsFractionView = new CgsFractionView(fraction.clone(), representationType);
        result.foregroundColor = foregroundColor;
        result.backgroundColor = backgroundColor;
        result.borderColor = borderColor;
        result.tickColor = tickColor;
        result.textColor = textColor;
        result.textGlowColor = textGlowColor;
        
        // Clone that fraction sprite
        m_fractionModule.cloneToFractionSprite(result.m_fractionSprite);
        
        return result;
    }
    
    /**
		 * 
		 * Rendering
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    override private function doRedraw() : Void
    {
        super.doRedraw();
        m_fractionModule.draw();
    }
}

