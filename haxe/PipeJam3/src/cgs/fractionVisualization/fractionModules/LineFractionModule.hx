package cgs.fractionVisualization.fractionModules;

import cgs.fractionVisualization.FractionSprite;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.constants.NumberlineConstants;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import openfl.geom.Point;

/**
	 * ...
	 * @author Jack
	 */
class LineFractionModule implements IFractionModule
{
    public var representationType(get, never) : String;
    public var fillAlpha(get, set) : Float;
    public var fillPercent(get, set) : Float;
    public var fillStartFraction(get, set) : CgsFraction;
    public var doShowSegment(get, set) : Bool;
    public var numBaseUnits(get, never) : Int;
    public var numExtensionUnits(get, set) : Int;
    public var numTotalUnits(get, never) : Int;
    public var valueOffsetX(get, never) : Float;
    public var scaleX(get, set) : Float;
    public var scaleY(get, set) : Float;
    public var unitWidth(get, never) : Float;
    public var unitHeight(get, never) : Float;
    public var baseWidth(get, never) : Float;
    public var totalWidth(get, never) : Float;
    public var valueWidth(get, never) : Float;
    public var unitNumDisplayAlpha(get, set) : Float;
    public var valueNumDisplayAlpha(get, set) : Float;
    public var valueIsAbove(get, set) : Bool;
    public var valueNRPosition(get, never) : Point;

    // State
    private var m_fractionSprite : FractionSprite;
    private var m_scaleX : Float = NumberlineConstants.BASE_SCALE;
    private var m_scaleY : Float = NumberlineConstants.BASE_SCALE;
    private var m_unitWidth : Float = NumberlineConstants.BASE_UNIT_WIDTH;
    private var m_unitHeight : Float = NumberlineConstants.BASE_UNIT_HEIGHT;
    
    public function new()
    {
    }
    
    /**
		 * Initializes this fraction module.
		 * @param	fractionSprite
		 */
    public function init(fractionSprite : FractionSprite) : Void
    {
        m_fractionSprite = fractionSprite;
        m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY] = true;
        
        m_scaleX = NumberlineConstants.BASE_SCALE;
        m_scaleY = NumberlineConstants.BASE_SCALE;
        m_unitWidth = NumberlineConstants.BASE_UNIT_WIDTH;
        m_unitHeight = NumberlineConstants.BASE_UNIT_HEIGHT;
        adjustDisplayList();
    }
    
    /**
		 * Resets this fraction module to be as if it were freshly constructed.
		 */
    public function reset() : Void
    {
        // Recycle number renderers
        m_fractionSprite.prepareNumberRendererForReuse();
        m_fractionSprite.recycleExtraNumberRenderers();
        
        m_fractionSprite = null;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the representation type of this module.
		 */
    private function get_representationType() : String
    {
        return CgsFVConstants.NUMBERLINE_REPRESENTATION;
    }
    
    public function adjustDisplayList() : Void
    {
        var backbone : Sprite = m_fractionSprite.backbone;
        var segment : Sprite = m_fractionSprite.segment;
        var fill : Sprite = m_fractionSprite.fill;
        var ticks : Sprite = m_fractionSprite.ticks;
        var number : Sprite = m_fractionSprite.numberDisplay;
        
        m_fractionSprite.addChild(backbone);
        m_fractionSprite.addChild(fill);
        m_fractionSprite.addChild(ticks);
        m_fractionSprite.addChild(segment);
        m_fractionSprite.addChild(number);
    }
    
    /**
		 * Gets the fillAlpha on the fractionSprite
		 */
    private function get_fillAlpha() : Float
    {
        return m_fractionSprite.fillAlpha;
    }
    
    /**
		 * Sets the fillAlpha on the fractionSprite
		 */
    private function set_fillAlpha(val : Float) : Float
    {
        m_fractionSprite.fillAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the fillPercent on the fractionSprite
		 */
    private function get_fillPercent() : Float
    {
        return m_fractionSprite.fillPercent;
    }
    
    /**
		 * Sets the fillPercent on the fractionSprite
		 */
    private function set_fillPercent(val : Float) : Float
    {
        m_fractionSprite.fillPercent = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the fillStartFraction on the fractionSprite
		 */
    private function get_fillStartFraction() : CgsFraction
    {
        return m_fractionSprite.fillStartFraction;
    }
    
    /**
		 * Sets the fillStartFraction on the fractionSprite
		 */
    private function set_fillStartFraction(val : CgsFraction) : CgsFraction
    {
        m_fractionSprite.fillStartFraction = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    private function get_doShowSegment() : Bool
    {
        return m_fractionSprite.segment.visible;
    }
    
    private function set_doShowSegment(value : Bool) : Bool
    {
        m_fractionSprite.segment.visible = value;
        return value;
    }
    
    /**
		 * Gets the numBaseUnits on the fractionSprite
		 */
    private function get_numBaseUnits() : Int
    {
        return m_fractionSprite.numBaseUnits;
    }
    
    /**
		 * Gets the fillStartFraction on the fractionSprite
		 */
    private function get_numExtensionUnits() : Int
    {
        return m_fractionSprite.numExtensionUnits;
    }
    
    /**
		 * Sets the fillStartFraction on the fractionSprite
		 */
    private function set_numExtensionUnits(val : Int) : Int
    {
        m_fractionSprite.numExtensionUnits = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Returns the number of total units (base units + extension units). 
		 */
    private function get_numTotalUnits() : Int
    {
        return m_fractionSprite.numTotalUnits;
    }
    
    /**
		 * Returns the offset X of the fraction value of this module.
		 */
    private function get_valueOffsetX() : Float
    {
        // Start at the center, subtract half the total width to get to the left hand side, add to the fraction value
        return 0 - totalWidth / 2 + valueWidth;
    }
    
    /**
		 * Returns the current scaleX of this module.
		 * The module handles the scaling of the view so that it can ensure the Number Renderers are NOT scaled.
		 */
    private function get_scaleX() : Float
    {
        return m_scaleX;
    }
    
    /**
		 * Sets the current scaleX of this module to be the given value.
		 * The module handles the scaling of the view so that it can ensure the Number Renderers are NOT scaled.
		 */
    private function set_scaleX(value : Float) : Float
    {
        m_scaleX = value;
        m_unitWidth = NumberlineConstants.BASE_UNIT_WIDTH * m_scaleX;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns the current scaleY of this module.
		 * The module handles the scaling of the view so that it can ensure the Number Renderers are NOT scaled.
		 */
    private function get_scaleY() : Float
    {
        return m_scaleY;
    }
    
    /**
		 * Sets the current scaleY of this module to be the given value.
		 * The module handles the scaling of the view so that it can ensure the Number Renderers are NOT scaled.
		 */
    private function set_scaleY(value : Float) : Float
    {
        m_scaleY = value;
        m_unitHeight = NumberlineConstants.BASE_UNIT_HEIGHT * m_scaleY;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns the unit width (the width of a value of 1) of this module.
		 */
    private function get_unitWidth() : Float
    {
        return m_unitWidth;
    }
    
    /**
		 * Returns the unit height (the height of a value of 1) of this module.
		 */
    private function get_unitHeight() : Float
    {
        return m_unitHeight;
    }
    
    /**
		 * Returns the base width (ie. not including extensions) of this module.
		 */
    private function get_baseWidth() : Float
    {
        return as3hx.Compat.parseFloat(m_fractionSprite.numBaseUnits) * unitWidth;
    }
    
    /**
		 * Returns the total width (including extensions) of this module.
		 */
    private function get_totalWidth() : Float
    {
        return as3hx.Compat.parseFloat(m_fractionSprite.numTotalUnits) * unitWidth;
    }
    
    /**
		 * Returns the total width (including extensions) of this module.
		 */
    private function get_valueWidth() : Float
    {
        return unitWidth * m_fractionSprite.parentView.fraction.value;
    }
    
    /**
		 * Gets the unitNumDisplayAlpha on the fractionSprite
		 */
    private function get_unitNumDisplayAlpha() : Float
    {
        return m_fractionSprite.unitNumDisplayAlpha;
    }
    
    /**
		 * Sets the unitNumDisplayAlpha on the fractionSprite
		 */
    private function set_unitNumDisplayAlpha(val : Float) : Float
    {
        m_fractionSprite.unitNumDisplayAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the unitTickDisplayAlpha on the fractionSprite
		 */
    /*public function get unitTickDisplayAlpha():Number
		{
			return m_fractionSprite.unitTickDisplayAlpha;
		}*/
    
    /**
		 * Sets the unitTickDisplayAlpha on the fractionSprite
		 */
    /*public function set unitTickDisplayAlpha(val:Number):void
		{
			m_fractionSprite.unitTickDisplayAlpha = val;
			m_fractionSprite.parentView.redraw();
		}*/
    
    /**
		 * Gets the valueNumDisplayAlpha on the fractionSprite
		 */
    private function get_valueNumDisplayAlpha() : Float
    {
        return m_fractionSprite.valueNumDisplayAlpha;
    }
    
    /**
		 * Sets the valueNumDisplayAlpha on the fractionSprite
		 */
    private function set_valueNumDisplayAlpha(val : Float) : Float
    {
        m_fractionSprite.valueNumDisplayAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the valueTickDisplayAlpha on the fractionSprite
		 */
    /*public function get valueTickDisplayAlpha():Number
		{
			return m_fractionSprite.valueTickDisplayAlpha;
		}*/
    
    /**
		 * Sets the valueTickDisplayAlpha on the fractionSprite
		 */
    /*public function set valueTickDisplayAlpha(val:Number):void
		{
			m_fractionSprite.valueTickDisplayAlpha = val;
			m_fractionSprite.parentView.redraw();
		}*/
    
    /**
		 * Returns whether the fraction value is displayed above (or below) the numberline.
		 */
    private function get_valueIsAbove() : Bool
    {
        return m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY];
    }
    
    /**
		 * Sets whether the fraction value is displayed above (or below) the numberline to be the given value.
		 */
    private function set_valueIsAbove(value : Bool) : Bool
    {
        m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY] = value;
        m_fractionSprite.parentView.redraw();
        return value;
    }
    
    /**
		 * Returns the position of the value Number Render (relative to the center of the fraction view) of this module.
		 */
    private function get_valueNRPosition() : Point
    {
        var showIntegerAsFraction : Bool = false;  // TODO: standardize showIntegerAsFraction  
        var fracIsInteger : Bool = m_fractionSprite.parentView.fraction.denominator == 1 && !showIntegerAsFraction;
        var result : Point = getValueNRPosition(valueIsAbove, fracIsInteger);
        return result;
    }
    
    public function getValueNRPosition(isAbove : Bool, isInteger : Bool) : Point
    {
        var result : Point = new Point(valueWidth - totalWidth / 2, 0);
        var marginDist : Float = ((isInteger) ? NumberlineConstants.NUMBER_DISPLAY_MARGIN_INTEGER : NumberlineConstants.NUMBER_DISPLAY_MARGIN_FRACTION);
        if (isAbove)
        {
            result.y = 0 - unitHeight / 2 - NumberlineConstants.TICK_EXTENSION_DISTANCE - marginDist;
        }
        else
        {
            result.y = 0 + unitHeight / 2 + NumberlineConstants.TICK_EXTENSION_DISTANCE + marginDist;
        }
        return result;
    }
    
    /**
		 * 
		 * Clone
		 * 
		**/
    
    /**
		 * Clones the representation state from the fractionSprite of this module into the given cloneFS.
		 * @param	cloneFS
		 */
    public function cloneToFractionSprite(cloneFS : FractionSprite) : Void
    {
    }
    
    /**
		 * 
		 * Display
		 * 
		**/
    
    /**
		 * Draws the CgsFractionView associated with this module to the components of the fractionSprite
		 */
    public function draw() : Void
    {
        // Get sprites of CFV
        var backbone : Sprite = m_fractionSprite.backbone;
        var segment : Sprite = m_fractionSprite.segment;
        var fill : Sprite = m_fractionSprite.fill;
        var ticks : Sprite = m_fractionSprite.ticks;
        var number : Sprite = m_fractionSprite.numberDisplay;
        
        // Colors
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        //var backgroundColor:uint = m_fractionSprite.parentView.backgroundColor;
        var backgroundColor : Int = m_fractionSprite.parentView.borderColor;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var tickColor : Int = m_fractionSprite.parentView.tickColor;
        var textColor : Int = m_fractionSprite.parentView.textColor;
        var textGlowColor : Int = m_fractionSprite.parentView.textGlowColor;
        
        // Fill data
        var fillColor : Int = m_fractionSprite.parentView.fillColor;
        var fillAlpha : Float = m_fractionSprite.fillAlpha;
        var fillPercent : Float = m_fractionSprite.fillPercent;
        var fillStartFraction : CgsFraction = m_fractionSprite.fillStartFraction;
        
        // Other data
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        
        // Draw Backbone
        drawBackbone(backbone, numTotalUnits, backgroundColor);
        
        // Draw Segment
        drawSegment(segment, m_fractionSprite.parentView.fraction, numTotalUnits, foregroundColor, borderColor);
        
        // Draw Fill
        drawFill(fill, m_fractionSprite.parentView.fraction, numTotalUnits, fillColor, fillAlpha, fillStartFraction, fillPercent);
        
        // Draw Ticks
        drawTicks(ticks, m_fractionSprite.parentView.fraction, numTotalUnits, tickColor);
        
        // Draw Number
        drawNumberDisplay(number, m_fractionSprite.parentView.fraction, numTotalUnits, textColor, textGlowColor);
    }
    
    /**
		 * 
		 * Draw Parts
		 * 
		**/
    
    /**
		 * Draws a backbone 
		 */
    private function drawBackbone(backbone : Sprite, numUnits : Int, backgroundColor : Int) : Void
    {
        // Get the total width/height
        var computedWidth : Float = numUnits * unitWidth;
        var computedHeight : Float = unitHeight;
        var g : Graphics = backbone.graphics;
        
        // Draw a rectangle
        g.clear();
        //g.lineStyle(NumberlineConstants.BACKBONE_BORDER_THICKNESS, NumberlineConstants.BACKBONE_BORDER_COLOR, 1);
        g.lineStyle(computedHeight, backgroundColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
        //g.beginFill(backgroundColor);
        //g.drawRect(-computedWidth / 2, -computedHeight / 2, computedWidth, computedHeight);
        g.moveTo(-computedWidth / 2, 0);
        g.lineTo(computedWidth / 2, 0);
        g.endFill();
    }
    
    /**
		 * Draws a segment 
		 */
    private function drawSegment(segment : Sprite, frac : CgsFraction, numUnits : Int, foregroundColor : Int, borderColor : Int) : Void
    {
        var computedWidth : Float = numUnits * unitWidth;
        
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        var circleX : Float = -computedWidth / 2 + unitWidth * frac.value;
        
        var mtx : Matrix = new Matrix();
        var boxDim : Float = NumberlineConstants.SEGMENT_RADIUS * 2;
        var tx : Float = -NumberlineConstants.SEGMENT_RADIUS;
        var ty : Float = -NumberlineConstants.SEGMENT_RADIUS;
        mtx.createGradientBox(boxDim, boxDim, 0, tx, ty);
        
        segment.graphics.clear();
        segment.graphics.lineStyle(NumberlineConstants.SEGMENT_STROKE_THICKNESS, borderColor, 1);
        segment.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
        segment.graphics.drawCircle(0, 0, NumberlineConstants.SEGMENT_RADIUS);
        segment.graphics.endFill();
        segment.x = circleX;
        segment.y = 0;
    }
    
    /**
		 * Draws a fill 
		 */
    private function drawFill(fill : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, fillAlpha : Float, fillStartFraction : CgsFraction, fillPercent : Float) : Void
    {
        // Get the total width/height
        var computedWidth : Float = numUnits * unitWidth;
        var computedHeight : Float = unitHeight;
        var startValue : Float = (fillStartFraction != null) ? fillStartFraction.value : 0;
        var fillWidth : Float = unitWidth * (fraction.value - startValue);
        var g : Graphics = fill.graphics;
        
        // Computing fill parameters
        var startX : Float = unitWidth * startValue - computedWidth / 2;
        var startY : Float = -unitHeight / 2;
        var endX : Float = startX + (fillWidth * fillPercent);
        var distanceX : Float = endX - startX;
        
        // Draw the fill
        g.clear();
        g.beginFill(fillColor, fillAlpha);
        g.drawRect(startX, startY, distanceX, computedHeight);
        g.endFill();
    }
    
    /**
		 * Draws a thin fill line
		 */
    private function drawFillLine(fillLine : Sprite, fraction : CgsFraction, numUnits : Int, lineThickness : Float, lineColor : Int, lineStartFraction : CgsFraction, linePercent : Float) : Void
    {
        // Get the total width/height
        var computedWidth : Float = numUnits * unitWidth;
        var computedHeight : Float = unitHeight;
        var startValue : Float = (lineStartFraction != null) ? lineStartFraction.value : 0;
        var fillWidth : Float = unitWidth * (fraction.value - startValue);
        var g : Graphics = fillLine.graphics;
        
        // Invert the values if the fraction is to the left of the lineStartFraction on the numberline (lineStartFraction is larger)
        // If we do not invert, the stroke around the rounded rectangle will look bad (like it is inside-out)
        if (fraction.value < startValue)
        {
            startValue = fraction.value;
            fillWidth = -fillWidth;
        }
        
        // Computing fill parameters
        var startX : Float = unitWidth * startValue - computedWidth / 2;
        var startY : Float = -lineThickness / 2;
        var endX : Float = startX + (fillWidth * linePercent);
        var distanceX : Float = endX - startX;
        
        // Draw the fill
        g.clear();
        g.lineStyle(0, 0, 1);  // Makes super thin black line around the fill  
        g.beginFill(lineColor);
        g.drawRoundRect(-distanceX / 2, startY, distanceX, lineThickness, 1);
        g.endFill();
    }
    
    /**
		 * Draws a ticks 
		 */
    private function drawTicks(ticks : Sprite, frac : CgsFraction, numUnits : Int, tickColor : Int) : Void
    {
        var computedWidth : Float = numUnits * unitWidth;
        var tickHeight : Float = unitHeight + NumberlineConstants.TICK_EXTENSION_DISTANCE * 2;
        
        var startX : Float = -computedWidth / 2;
        var g : Graphics = ticks.graphics;
        g.clear();
        
        for (i in 0...numUnits + 1)
        {
            g.lineStyle(NumberlineConstants.TICK_THICKNESS, tickColor, 1);
            g.moveTo(startX, -tickHeight / 2);
            g.lineTo(startX, tickHeight / 2);
            g.endFill();
            startX += unitWidth;
        }
    }
    
    /**
		 * Draws a number display 
		 */
    private function drawNumberDisplay(numberDisplay : Sprite, frac : CgsFraction, numUnits : Int, textColor : Int, textGlowColor : Int) : Void
    {
        // Get the total width/height
        var computedWidth : Float = numUnits * unitWidth;
        var computedHeight : Float = unitHeight;
        
        // Computing parameters
        var unitX : Float = -computedWidth / 2;
        var unitY : Float = 0;
        
        // Prepare in-use number renderers for re-use
        m_fractionSprite.prepareNumberRendererForReuse();
        
        if (m_fractionSprite.doShowNumberRenderers)
        {
            // Add number displays for units (all integers)
            for (i in 0...numUnits + 1)
            {
                // Create CgsFraction for this unit
                var aFraction : CgsFraction = new CgsFraction();
                aFraction.init(i, 1);
                
                // Create Number Display to display this unit
                var unitDisplay : NumberRenderer = m_fractionSprite.getNumberRenderer();
                unitDisplay.init(aFraction);
                unitDisplay.setTextColor(textColor);
                unitDisplay.lineColor = textColor;
                unitDisplay.glowColor = textGlowColor;
                unitDisplay.x = unitX;
                unitDisplay.y = unitY + computedHeight / 2 + NumberlineConstants.NUMBER_DISPLAY_MARGIN_INTEGER;
                unitDisplay.alpha = unitNumDisplayAlpha;
                unitDisplay.showIntegerAsFraction = false;
                numberDisplay.addChild(unitDisplay);
                unitDisplay.render();
                
                // Compute next unit location
                unitX += unitWidth;
            }
            
            // Add number display for the fraction value of the strip
            var fracDisplay : NumberRenderer = m_fractionSprite.getNumberRenderer();
            fracDisplay.showIntegerAsFraction = false;
            fracDisplay.init(frac);
            fracDisplay.setTextColor(textColor);
            fracDisplay.lineColor = textColor;
            fracDisplay.glowColor = textGlowColor;
            var fracDisplayPos : Point = valueNRPosition;
            fracDisplay.x = fracDisplayPos.x;
            fracDisplay.y = fracDisplayPos.y;
            fracDisplay.alpha = valueNumDisplayAlpha;
            numberDisplay.addChild(fracDisplay);
            fracDisplay.render();
        }
        
        // Recycle any extra number renders
        m_fractionSprite.recycleExtraNumberRenderers();
    }
    
    /**
		 * 
		 * Extension Mask
		 * 
		**/
    
    public function createExtensionMask(maskWidth : Float) : Sprite
    {
        var result : Sprite = new Sprite();
        
        // Get the total width/height
        var computedHeight : Float = unitHeight;
        var g : Graphics = result.graphics;
        
        // Draw a rectangle
        g.clear();
        g.beginFill(0xffaaff);
        var borderThickness : Float = NumberlineConstants.BACKBONE_BORDER_THICKNESS;
        g.drawRect(-maskWidth / 2 - borderThickness / 2, -computedHeight / 2 - borderThickness, maskWidth + borderThickness, computedHeight + (borderThickness * 2));
        g.endFill();
        
        //m_fractionSprite.addChild(result);
        //m_fractionSprite.mask = result;
        
        return result;
    }
    
    /**
		 * 
		 * Peeling value
		 * 
		**/
    
    public function paintColoredFillLine(fillLine : Sprite) : Void
    {
        var lineFraction : CgsFraction = m_fractionSprite.parentView.fraction;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        var lineThickness : Float = NumberlineConstants.COMPARE_LINE_THICKNESS;
        var lineColor : Int = m_fractionSprite.parentView.foregroundColor;
        var lineStartFraction : CgsFraction = m_fractionSprite.fillStartFraction;
        var linePercent : Float = 1;
        
        drawFillLine(fillLine, lineFraction, numTotalUnits, lineThickness, lineColor, lineStartFraction, linePercent);
    }
    
    public function paintValue(secondSegment : Sprite) : Void
    {
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        secondSegment.graphics.clear();
        
        // Draw Segment
        drawSegment(secondSegment, m_fractionSprite.parentView.fraction, numTotalUnits, foregroundColor, borderColor);
    }
    
    public function peelValue(secondSegment : Sprite) : Void
    {
        paintValue(secondSegment);
        doShowSegment = false;
    }
    
    public function unpeelValue() : Void
    {
        doShowSegment = true;
    }
}

