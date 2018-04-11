package cgs.fractionVisualization;

import openfl.utils.Dictionary;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.NumberRendererFactory;
import cgs.math.CgsFraction;
import flash.display.Sprite;

/**
	 * ...
	 * @author Rich
	 */
class FractionSprite extends Sprite
{
    public var parentView(get, never) : CgsFractionView;
    public var representationState(get, never) : Dictionary<String, Dynamic>;
    public var fillAlpha(get, set) : Float;
    public var fillPercent(get, set) : Float;
    public var fillStartFraction(get, set) : CgsFraction;
    public var numBaseUnits(get, never) : Int;
    public var numExtensionUnits(get, set) : Int;
    public var numTotalUnits(get, never) : Int;
    public var rotationRadians(get, set) : Float;
    public var doShowNumberRenderers(get, set) : Bool;
    public var unitNumDisplayAlpha(get, set) : Float;
    public var unitTickDisplayAlpha(get, set) : Float;
    public var valueNumDisplayAlpha(get, set) : Float;
    public var valueTickDisplayAlpha(get, set) : Float;
    public var backbone(get, never) : Sprite;
    public var segment(get, never) : Sprite;
    public var fill(get, never) : Sprite;
    public var ticks(get, never) : Sprite;
    public var numberDisplay(get, never) : Sprite;

    // State
    private var m_parentView : CgsFractionView;
    private var m_representationState : Dictionary<String, Dynamic>;
    private var m_fillAlpha : Float;
    private var m_fillPercent : Float;
    private var m_fillStartFraction : CgsFraction;
    private var m_doShowNumberRenderers : Bool;
    private var m_unitNumDisplayAlpha : Float;
    private var m_unitTickDisplayAlpha : Float;
    private var m_valueNumDisplayAlpha : Float;
    private var m_valueTickDisplayAlpha : Float;
    private var m_numExtenstionUnits : Int;
    private var m_rotationRadians : Float;
    
    // Display State
    private var m_backbone : Sprite;  // Also contains background ticks  
    private var m_segment : Sprite;
    private var m_fill : Sprite;
    private var m_ticks : Sprite;  // Foreground ticks  
    private var m_numberDisplay : Sprite;
    
    // Number Renderers
    private var m_numberRenderers_inUse : Array<NumberRenderer>;
    private var m_numberRenderers_extra : Array<NumberRenderer>;
    
    public function new(fractionView : CgsFractionView)
    {
        super();
        // State
        m_parentView = fractionView;
        m_representationState = new Dictionary<String, Dynamic>();
        m_fillAlpha = GenConstants.DEFAULT_FILL_ALPHA;
        m_doShowNumberRenderers = true;
        m_unitNumDisplayAlpha = 1;
        m_unitTickDisplayAlpha = 1;
        m_valueNumDisplayAlpha = 1;
        m_valueTickDisplayAlpha = 1;
        m_fillPercent = 0.0;
        m_numExtenstionUnits = 0;
        m_rotationRadians = 0;
        
        // Display State
        m_backbone = new Sprite();
        addChild(m_backbone);
        
        m_segment = new Sprite();
        addChild(m_segment);
        
        m_fill = new Sprite();
        addChild(m_fill);
        
        m_ticks = new Sprite();
        addChild(m_ticks);
        
        m_numberDisplay = new Sprite();
        addChild(m_numberDisplay);
        
        m_numberRenderers_inUse = new Array<NumberRenderer>();
        m_numberRenderers_extra = new Array<NumberRenderer>();
    }
    
    /**
		 * Destorys this FractionSprite so that it will be garbage collected.
		 */
    public function destroy() : Void
    {
        m_parentView = null;
        
        removeChild(m_backbone);
        m_backbone = null;
        
        removeChild(m_segment);
        m_segment = null;
        
        removeChild(m_fill);
        m_fill = null;
        
        removeChild(m_ticks);
        m_ticks = null;
        
        removeChild(m_numberDisplay);
        m_numberDisplay = null;
        
        m_fillStartFraction = null;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the parent view of this FractionSprite.
		 */
    private function get_parentView() : CgsFractionView
    {
        return m_parentView;
    }
    
    /**
		 * Returns the representation state of this FractionSprite.
		 * This holds the representation specific state of the FractionSprite as managed by any attached IFractionModule.
		 */
    private function get_representationState() : Dictionary<String, Dynamic>
    {
        return m_representationState;
    }
    
    /**
		 * Returns the alpha of the fill
		 */
    private function get_fillAlpha() : Float
    {
        return m_fillAlpha;
    }
    
    /**
		 * Sets the alpha of the fill to the value
		 * @param	val - the new value of fillAlpha
		 */
    private function set_fillAlpha(val : Float) : Float
    {
        m_fillAlpha = val;
        return val;
    }
    
    /**
		 * Returns the percentage of the segment that is filled
		 */
    private function get_fillPercent() : Float
    {
        return m_fillPercent;
    }
    
    /**
		 * Sets the percentage of the segment that is filled to the value
		 * @param	val - the new value of fillPercent
		 */
    private function set_fillPercent(val : Float) : Float
    {
        m_fillPercent = val;
        return val;
    }
    
    /**
		 * Returns the fill start fraction
		 */
    private function get_fillStartFraction() : CgsFraction
    {
        return m_fillStartFraction;
    }
    
    /**
		 * Sets the fill start fraction to the value
		 * @param	val - the new value of fillPercent
		 */
    private function set_fillStartFraction(val : CgsFraction) : CgsFraction
    {
        m_fillStartFraction = val;
        return val;
    }
    
    /**
		 * Returns the base number of units of this fraction sprite.
		 * For example, 9/4 has 3 units. 
		 */
    private function get_numBaseUnits() : Int
    {
        return CgsFraction.computeNumBaseUnits(parentView.fraction);
    }
    
    /**
		 * Returns the number of extension units.
		 */
    private function get_numExtensionUnits() : Int
    {
        return m_numExtenstionUnits;
    }
    
    /**
		 * Sets the number of extension units to the value
		 * @param	val - the new value of fillPercent
		 */
    private function set_numExtensionUnits(val : Int) : Int
    {
        m_numExtenstionUnits = val;
        return val;
    }
    
    /**
		 * Returns the number of total units (base units + extension units). 
		 */
    private function get_numTotalUnits() : Int
    {
        return as3hx.Compat.parseInt(numBaseUnits + numExtensionUnits);
    }
    
    /**
		 * Returns the rotation value
		 */
    private function get_rotationRadians() : Float
    {
        return m_rotationRadians;
    }
    
    /**
		 * Sets the rotation value to the value
		 * @param	val - the new value of fillAlpha
		 */
    private function set_rotationRadians(val : Float) : Float
    {
        m_rotationRadians = val;
        return val;
    }
    
    /**
		 * Returns whether or not number renderers should be shown.
		 */
    private function get_doShowNumberRenderers() : Bool
    {
        return m_doShowNumberRenderers;
    }
    
    /**
		 * Sets whether or not number renderers should be shown to the given value.
		 * @param	val - the new value of doShowNumberRenderers
		 */
    private function set_doShowNumberRenderers(val : Bool) : Bool
    {
        m_doShowNumberRenderers = val;
        return val;
    }
    
    /**
		 * Returns the alpha of the unit number displays.
		 */
    private function get_unitNumDisplayAlpha() : Float
    {
        return m_unitNumDisplayAlpha;
    }
    
    /**
		 * Sets the alpha of the unit number displays to the given value.
		 * @param	val - the new value of numDisplayAlpha
		 */
    private function set_unitNumDisplayAlpha(val : Float) : Float
    {
        m_unitNumDisplayAlpha = val;
        return val;
    }
    
    /**
		 * Returns the alpha of the unit ticks.
		 */
    private function get_unitTickDisplayAlpha() : Float
    {
        return m_unitTickDisplayAlpha;
    }
    
    /**
		 * Sets the alpha of the unit ticks to the given value.
		 * @param	val - the new value of numDisplayAlpha
		 */
    private function set_unitTickDisplayAlpha(val : Float) : Float
    {
        m_unitTickDisplayAlpha = val;
        return val;
    }
    
    /**
		 * Returns the alpha of the fraction value number display.
		 */
    private function get_valueNumDisplayAlpha() : Float
    {
        return m_valueNumDisplayAlpha;
    }
    
    /**
		 * Sets the alpha of the fraction value number display to the given value.
		 * @param	val - the new value of numDisplayAlpha
		 */
    private function set_valueNumDisplayAlpha(val : Float) : Float
    {
        m_valueNumDisplayAlpha = val;
        return val;
    }
    
    /**
		 * Returns the alpha of the fraction value tick.
		 */
    private function get_valueTickDisplayAlpha() : Float
    {
        return m_valueTickDisplayAlpha;
    }
    
    /**
		 * Sets the alpha of the fraction value tick to the given value.
		 * @param	val - the new value of numDisplayAlpha
		 */
    private function set_valueTickDisplayAlpha(val : Float) : Float
    {
        m_valueTickDisplayAlpha = val;
        return val;
    }
    
    /**
		 * 
		 * Display State
		 * 
		**/
    
    /**
		 * Returns the backbone sprite of this FractionSprite.
		 */
    private function get_backbone() : Sprite
    {
        return m_backbone;
    }
    
    /**
		 * Returns the segment sprite of this FractionSprite.
		 */
    private function get_segment() : Sprite
    {
        return m_segment;
    }
    
    /**
		 * Returns the fill sprite of this FractionSprite.
		 */
    private function get_fill() : Sprite
    {
        return m_fill;
    }
    
    /**
		 * Returns the ticks sprite of this FractionSprite.
		 */
    private function get_ticks() : Sprite
    {
        return m_ticks;
    }
    
    /**
		 * Returns the numberDisplay sprite of this FractionSprite.
		 */
    private function get_numberDisplay() : Sprite
    {
        return m_numberDisplay;
    }
    
    /**
		 * 
		 * Number Renderer Management
		 * 
		**/
    
    /**
		 * Prepares the currently used number renderers for reuse, or ultimate recycling.
		 * @return
		 */
    public function prepareNumberRendererForReuse() : Void
    {
        // Prepare all in-use number renderers for re-use
        while (m_numberRenderers_inUse.length > 0)
        {
            var aNumberRenderer : NumberRenderer = m_numberRenderers_inUse.pop();
            aNumberRenderer.reset();
            m_numberRenderers_extra.push(aNumberRenderer);
        }
    }
    
    /**
		 * Returns a number renderer.
		 * @return
		 */
    public function getNumberRenderer() : NumberRenderer
    {
        var result : NumberRenderer;  // Get a number renderer from the extras, if any  ;
        
        
        
        if (m_numberRenderers_extra.length > 0)
        {
            result = m_numberRenderers_extra.pop();
        }
        else
        {
            // Get a new one from the factory
            {
                result = NumberRendererFactory.getInstance().getNumberRendererInstance();
                result.setTextColor(parentView.textColor);
                result.lineColor = parentView.textColor;
                result.glowColor = parentView.textGlowColor;
                result.lineThickness = 2;
            }
        }
        
        // Store it as in use
        m_numberRenderers_inUse.push(result);
        
        return result;
    }
    
    /**
		 * Takes all the extra number renderers and recycles them.
		 */
    public function recycleExtraNumberRenderers() : Void
    {
        while (m_numberRenderers_extra.length > 0)
        {
            var aNumberRenderer : NumberRenderer = m_numberRenderers_extra.pop();
            
            // Remove it from the display list
            if (aNumberRenderer.parent != null)
            {
                aNumberRenderer.parent.removeChild(aNumberRenderer);
            }
            
            // Recycle
            NumberRendererFactory.getInstance().recycleNumberRendererInstance(aNumberRenderer);
        }
    }
}

