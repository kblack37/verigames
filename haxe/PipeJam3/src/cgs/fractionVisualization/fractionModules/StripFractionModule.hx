package cgs.fractionVisualization.fractionModules;

import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.FractionSprite;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.constants.StripConstants;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.strip.StripChangeDenomData;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import flash.display.CapsStyle;
import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.geom.Matrix;
import openfl.geom.Point;

/**
	 * ...
	 * @author Rich
	 */
class StripFractionModule implements IFractionModule
{
    public var doShowSegment(get, set) : Bool;
    public var representationType(get, never) : String;
    public var fillAlpha(get, set) : Float;
    public var fillPercent(get, set) : Float;
    public var fillStartFraction(get, set) : CgsFraction;
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
    public var unitTickDisplayAlpha(get, set) : Float;
    public var valueNumDisplayAlpha(get, set) : Float;
    public var valueTickDisplayAlpha(get, set) : Float;
    public var valueIsAbove(get, set) : Bool;
    public var valueNRPosition(get, never) : Point;

    // State
    private var m_fractionSprite : FractionSprite;
    private var m_scaleX : Float = StripConstants.BASE_SCALE;
    private var m_scaleY : Float = StripConstants.BASE_SCALE;
    private var m_unitWidth : Float = StripConstants.BASE_UNIT_WIDTH;
    private var m_unitHeight : Float = StripConstants.BASE_UNIT_HEIGHT;
    
    public function new()
    {
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(fractionSprite : FractionSprite) : Void
    {
        m_fractionSprite = fractionSprite;
        m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY] = true;
        
        m_scaleX = StripConstants.BASE_SCALE;
        m_scaleY = StripConstants.BASE_SCALE;
        m_unitWidth = StripConstants.BASE_UNIT_WIDTH;
        m_unitHeight = StripConstants.BASE_UNIT_HEIGHT;
    }
    
    /**
		 * @inheritDoc
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
		 * @inheritDoc
		 */
    private function get_representationType() : String
    {
        return CgsFVConstants.STRIP_REPRESENTATION;
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
        m_unitWidth = StripConstants.BASE_UNIT_WIDTH * m_scaleX;
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
        m_unitHeight = StripConstants.BASE_UNIT_HEIGHT * m_scaleY;
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
    private function get_unitTickDisplayAlpha() : Float
    {
        return m_fractionSprite.unitTickDisplayAlpha;
    }
    
    /**
		 * Sets the unitTickDisplayAlpha on the fractionSprite
		 */
    private function set_unitTickDisplayAlpha(val : Float) : Float
    {
        m_fractionSprite.unitTickDisplayAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
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
    private function get_valueTickDisplayAlpha() : Float
    {
        return m_fractionSprite.valueTickDisplayAlpha;
    }
    
    /**
		 * Sets the valueTickDisplayAlpha on the fractionSprite
		 */
    private function set_valueTickDisplayAlpha(val : Float) : Float
    {
        m_fractionSprite.valueTickDisplayAlpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Returns whether the fraction value is displayed above (or below) the strip.
		 */
    private function get_valueIsAbove() : Bool
    {
        return m_fractionSprite.representationState[GenConstants.VALUE_IS_ABOVE_KEY];
    }
    
    /**
		 * Sets whether the fraction value is displayed above (or below) the strip to be the given value.
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
        var marginDist : Float = ((isInteger) ? StripConstants.NUMBER_DISPLAY_MARGIN_INTEGER : StripConstants.NUMBER_DISPLAY_MARGIN_FRACTION);
        if (isAbove)
        {
            result.y = 0 - unitHeight / 2 - marginDist;
        }
        else
        {
            result.y = 0 + unitHeight / 2 + marginDist;
        }
        return result;
    }
    
    /**
		 * 
		 * Clone
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function cloneToFractionSprite(cloneFS : FractionSprite) : Void
    {  // Do something, but probably not for strips  
        
    }
    
    /**
		 * 
		 * Display
		 * 
		**/
    
    /**
		 * @inheritDoc
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
        var backgroundColor : Int = m_fractionSprite.parentView.backgroundColor;
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
        drawSegment(segment, m_fractionSprite.parentView.fraction, numTotalUnits, foregroundColor);
        
        // Draw Fill
        drawFill(fill, m_fractionSprite.parentView.fraction, numTotalUnits, fillColor, fillAlpha, fillStartFraction, fillPercent);
        
        // Draw Ticks
        drawTicksAndBorder(ticks, m_fractionSprite.parentView.fraction, numTotalUnits, borderColor, tickColor);
        
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
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var g : Graphics = backbone.graphics;
        
        // Draw a rectangle
        g.clear();
        g.beginFill(backgroundColor);
        g.drawRect(-totalWidth / 2, -totalHeight / 2, totalWidth, totalHeight);
        g.endFill();
    }
    
    /**
		 * Draws a segment 
		 */
    private function drawSegment(segment : Sprite, frac : CgsFraction, numUnits : Int, foregroundColor : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var g : Graphics = segment.graphics;
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Computing block parameters
        var blockWidth : Float = unitWidth / frac.denominator;
        var blockHeight : Float = unitHeight;
        var blockX : Float = -totalWidth / 2 + blockWidth / 2;
        var blockY : Float = 0;
        
        // Draw all the blocks with a gradient
        g.clear();
        for (i in 0...frac.numerator)
        {
            // Draw this block
            drawSegmentBlock(g, blockX, blockY, blockWidth, blockHeight, colors, alphas, ratios);
            
            // Compute next block center point
            blockX += blockWidth;
        }
    }
    
    /**
		 * Draws a segment 
		 */
    private function drawSegmentForPeel(segment : Sprite, frac : CgsFraction, numUnits : Int, foregroundColor : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var g : Graphics = segment.graphics;
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Computing block parameters
        var blockWidth : Float = unitWidth / frac.denominator;
        var blockHeight : Float = unitHeight;
        //var blockX:Number = -totalWidth/2 + blockWidth/2;
        var segmentWidth : Float = blockWidth * frac.numerator;
        var blockX : Float = -segmentWidth / 2 + blockWidth / 2;  // Adding half a block width because drawSegmentBlock uses blockX and blockY as the center point, not the corner  
        var blockY : Float = 0;
        
        // Draw all the blocks with a gradient
        g.clear();
        for (i in 0...frac.numerator)
        {
            // Draw this block
            drawSegmentBlock(g, blockX, blockY, blockWidth, blockHeight, colors, alphas, ratios);
            
            // Compute next block center point
            blockX += blockWidth;
        }
    }
    
    /**
		 * Draws a segment block with the given properties to the target graphics object.
		 * @param	targetG
		 * @param	blockX
		 * @param	blockY
		 * @param	blockWidth
		 * @param	blockHeight
		 * @param	colors
		 * @param	alphas
		 * @param	ratios
		 */
    private function drawSegmentBlock(targetG : Graphics, blockX : Float, blockY : Float, blockWidth : Float,
                                      blockHeight : Float, colors : Array<UInt>, alphas : Array<Float>, ratios : Array<Int>) : Void
    {
        // Compute corner of this block - used to compute the location of this gradient
        var cornerX : Float = blockX - blockWidth / 2;
        var cornerY : Float = blockY - blockHeight / 2;
        
        // Create the gradient matrix
        var mtx : Matrix = new Matrix();
        mtx.createGradientBox(blockWidth, blockHeight, Math.PI / 4, cornerX, cornerY);
        targetG.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mtx);
        
        // Draw this block
        targetG.drawRect(cornerX, cornerY, blockWidth, blockHeight);
        targetG.endFill();
    }
    
    /**
		 * Draws a segment block with the given properties to the target graphics object.
		 * @param	targetG
		 * @param	blockX
		 * @param	blockY
		 * @param	blockWidth
		 * @param	blockHeight
		 * @param	colors
		 * @param	alphas
		 * @param	ratios
		 */
    private function drawBackboneBlock(targetG : Graphics, blockX : Float, blockY : Float, blockWidth : Float, blockHeight : Float, backgroundColor : Int) : Void
    {
        // Compute corner of this block - used to compute the location of this gradient
        var cornerX : Float = blockX - blockWidth / 2;
        var cornerY : Float = blockY - blockHeight / 2;
        
        // Draw this block
        targetG.beginFill(backgroundColor);
        targetG.drawRect(cornerX, cornerY, blockWidth, blockHeight);
        targetG.endFill();
    }
    
    /**
		 * Draws a fill 
		 */
    private function drawFill(fill : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, fillAlpha : Float, fillStartFraction : CgsFraction, fillPercent : Float) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var startValue : Float = (fillStartFraction != null) ? fillStartFraction.value : 0;
        var fillWidth : Float = unitWidth * (fraction.value - startValue);
        var g : Graphics = fill.graphics;
        
        // Computing fill parameters
        var startX : Float = (unitWidth * startValue) - totalWidth / 2;
        var startY : Float = -unitHeight / 2;
        var endX : Float = startX + (fillWidth * fillPercent);
        var distanceX : Float = endX - startX;
        
        // Draw the fill
        g.clear();
        g.beginFill(fillColor, fillAlpha);
        g.drawRect(startX, startY, distanceX, totalHeight);
        g.endFill();
    }
    
    /**
		 * Draws a fill 
		 */
    private function drawCenteredFill(fill : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, fillAlpha : Float, fillStartFraction : CgsFraction, fillPercent : Float) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var startValue : Float = (fillStartFraction != null) ? fillStartFraction.value : 0;
        var fillWidth : Float = unitWidth * (fraction.value - startValue);
        var g : Graphics = fill.graphics;
        
        // Computing fill parameters
        var startX : Float = (unitWidth * startValue) - totalWidth / 2;
        var startY : Float = -unitHeight / 2;
        var endX : Float = startX + (fillWidth * fillPercent);
        var distanceX : Float = endX - startX;
        
        // Draw the fill
        g.clear();
        g.beginFill(fillColor, fillAlpha);
        g.drawRect(-distanceX / 2, -totalHeight / 2, distanceX, totalHeight);
        g.endFill();
    }
    
    /**
		 * Draws a fill 
		 */
    private function drawFillLine(fill : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, fillAlpha : Float, fillStartFraction : CgsFraction, fillPercent : Float) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var startValue : Float = (fillStartFraction != null) ? fillStartFraction.value : 0;
        var fillWidth : Float = unitWidth * (fraction.value - startValue);
        var g : Graphics = fill.graphics;
        
        // Computing fill parameters
        var startX : Float = (unitWidth * startValue) - totalWidth / 2;
        var startY : Float = -unitHeight / 2;
        var endX : Float = startX + (fillWidth * fillPercent);
        var distanceX : Float = endX - startX;
        
        // Draw the fill
        g.clear();
        //g.lineStyle(0, 0, 1);
        g.beginFill(fillColor, fillAlpha);
        g.drawRect(-distanceX / 2, startY, distanceX, totalHeight);
        g.endFill();
    }
    
    /**
		 * Draws a ticks 
		 */
    private function drawTicksAndBorder(ticks : Sprite, frac : CgsFraction, numUnits : Int, borderColor : Int, tickColor : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var g : Graphics = ticks.graphics;
        
        // Computing parameters
        var blockWidth : Float = unitWidth / frac.denominator;
        var startTickX : Float = -totalWidth / 2;
        var tickX : Float = startTickX;
        var tickY : Float = 0;
        
        // Draw ticks
        g.clear();
        g.lineStyle(StripConstants.BACKBONE_BORDER_THICKNESS, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        for (i in 0...(frac.denominator * numUnits) + 1)
        {
            g.moveTo(tickX, tickY - totalHeight / 2);
            g.lineTo(tickX, tickY + totalHeight / 2);
            
            // Compute next tick location
            tickX += blockWidth;
        }
        
        // Start in top left, go around clockwise
        g.moveTo(-totalWidth / 2, -totalHeight / 2);
        g.lineTo(totalWidth / 2, -totalHeight / 2);
        g.lineTo(totalWidth / 2, totalHeight / 2);
        g.lineTo(-totalWidth / 2, totalHeight / 2);
        g.lineTo(-totalWidth / 2, -totalHeight / 2);
        g.endFill();


        /** Draws a unit's tick (the part that protrudes from the strip itself). */
        function drawUnitTick(numBlocksFromStart : Float, isAbove : Bool) : Void
        {
            // Start position of tick
            var tickPosX : Float = startTickX + (blockWidth * numBlocksFromStart);
            var tickPosY : Float = tickY + ((isAbove) ? (-totalHeight / 2) : (totalHeight / 2));

            // Draw tick
            g.moveTo(tickPosX, tickPosY);
            g.lineTo(tickPosX, tickPosY + ((isAbove) ? -StripConstants.TICK_EXTENSION_DISTANCE : StripConstants.TICK_EXTENSION_DISTANCE));
        };


        // Only draw ticks for number renderers if number renderers are set to visible.
        if (m_fractionSprite.doShowNumberRenderers)
        {
            // Draw extra ticks for units (with a different alpha than the other ticks, hence why it has to be different)
            g.lineStyle(StripConstants.TICK_THICKNESS, tickColor, unitTickDisplayAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            for (j in 0...numUnits + 1)
            {
                // Ticks for units
                {
                    drawUnitTick(j * frac.denominator, false);
                }
            }
            g.endFill();
            
            
            // Draw extra tick for fraction value (with a different alpha than the other ticks, hence why it has to be different)
            g.lineStyle(StripConstants.TICK_THICKNESS, tickColor, valueTickDisplayAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            drawUnitTick(frac.numerator, valueIsAbove);  // Tick for fraction  
            g.endFill();
        }
        

    }
    
    /**
		 * Draws a ticks 
		 */
    private function drawTicksForPeel(ticks : Sprite, frac : CgsFraction, numUnits : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var g : Graphics = ticks.graphics;
        
        // Computing parameters
        var blockWidth : Float = unitWidth / frac.denominator;
        var valueWidth : Float = blockWidth * frac.numerator;
        var valueX : Float = -totalWidth / 2 + valueWidth;
        var segmentWidth : Float = blockWidth *frac.numerator;  //var tickX:Number = -totalWidth/2 + blockWidth;  ;
        
        var tickX : Float = -segmentWidth / 2 + blockWidth;
        var tickY : Float = 0;
        
        // Prepare for drawing
        //g.clear();
        var tickColor : Int = m_fractionSprite.parentView.tickColor;
        g.lineStyle(StripConstants.TICK_THICKNESS, tickColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        
        // Draw border
        g.moveTo(-segmentWidth / 2, -totalHeight / 2);
        g.lineTo(segmentWidth / 2, -totalHeight / 2);
        g.lineTo(segmentWidth / 2, totalHeight / 2);
        g.lineTo(-segmentWidth / 2, totalHeight / 2);
        g.lineTo(-segmentWidth / 2, -totalHeight / 2);
        
        // Draw ticks
        for (i in 1...frac.numerator)
        {
            g.moveTo(tickX, tickY - totalHeight / 2);
            g.lineTo(tickX, tickY + totalHeight / 2);
            
            // Compute next tick location
            tickX += blockWidth;
        }
    }
    
    /**
		 * Draws a ticks 
		 */
    public function drawSegmentsForChangingDenominator(newFrac : CgsFraction, numUnits : Int) : Array<Sprite>
    {
        var results : Array<Sprite> = new Array<Sprite>();
        
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var backgroundColor : Int = m_fractionSprite.parentView.backgroundColor;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(m_fractionSprite.parentView.foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Computing block parameters
        var blockWidth : Float = unitWidth / newFrac.denominator;
        var blockHeight : Float = unitHeight;
        var blockX : Float = -totalWidth / 2 + blockWidth / 2;
        var blockY : Float = 0;
        
        // Draw all the blocks with a gradient
        for (i in 0...(newFrac.denominator * numUnits))
        {
            // Create a block
            var aBlock : Sprite = new Sprite();
            aBlock.x = blockX;
            aBlock.y = blockY;
            results.push(aBlock);
            
            // Draw this block for values up to the numerator
            if (i < newFrac.numerator)
            {
                drawSegmentBlock(aBlock.graphics, 0, 0, blockWidth, blockHeight, colors, alphas, ratios);
            }
            else
            {
                drawBackboneBlock(aBlock.graphics, 0, 0, blockWidth, blockHeight, backgroundColor);
            }
            
            // Draw Border of the block for all blocks
            aBlock.graphics.lineStyle(StripConstants.BACKBONE_BORDER_THICKNESS, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            aBlock.graphics.moveTo(-blockWidth / 2, -blockHeight / 2);
            aBlock.graphics.lineTo(blockWidth / 2, -blockHeight / 2);
            aBlock.graphics.lineTo(blockWidth / 2, blockHeight / 2);
            aBlock.graphics.lineTo(-blockWidth / 2, blockHeight / 2);
            aBlock.graphics.lineTo(-blockWidth / 2, -blockHeight / 2);
            aBlock.graphics.endFill();
            
            // Compute next block center point
            blockX += blockWidth;
        }
        
        return results;
    }
    
    /**
		 * Draws a ticks 
		 */
    public function drawSegmentsForDrop(newFrac : CgsFraction, numUnits : Int, foregroundColor : Int) : Array<Sprite>
    {
        var results : Array<Sprite> = new Array<Sprite>();
        
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Computing block parameters
        var blockWidth : Float = unitWidth / newFrac.denominator;
        var blockHeight : Float = unitHeight;
        var blockX : Float = -totalWidth / 2 + blockWidth / 2;
        var blockY : Float = 0;
        
        // Draw all the blocks with a gradient
        for (i in 0...(newFrac.denominator * numUnits))
        {
            if (i >= newFrac.numerator)
            {
                break;
            }
            
            // Create a block
            var aBlock : Sprite = new Sprite();
            aBlock.x = blockX;
            aBlock.y = blockY;
            results.push(aBlock);
            
            // Draw this block for values up to the numerator
            drawSegmentBlock(aBlock.graphics, 0, 0, blockWidth, blockHeight, colors, alphas, ratios);
            
            // Draw Border of the block for all blocks
            aBlock.graphics.lineStyle(StripConstants.BACKBONE_BORDER_THICKNESS, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            aBlock.graphics.moveTo(-blockWidth / 2, -blockHeight / 2);
            aBlock.graphics.lineTo(blockWidth / 2, -blockHeight / 2);
            aBlock.graphics.lineTo(blockWidth / 2, blockHeight / 2);
            aBlock.graphics.lineTo(-blockWidth / 2, blockHeight / 2);
            aBlock.graphics.lineTo(-blockWidth / 2, -blockHeight / 2);
            aBlock.graphics.endFill();
            
            // Compute next block center point
            blockX += blockWidth;
        }
        
        return results;
    }
    
    /**
		 * Draws a number display 
		 */
    private function drawNumberDisplay(numberDisplay : Sprite, frac : CgsFraction, numUnits : Int, textColor : Int, textGlowColor : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * unitWidth;
        var totalHeight : Float = unitHeight;
        
        // Computing parameters
        var blockWidth : Float = unitWidth / frac.denominator;
        var unitX : Float = -totalWidth / 2;
        var unitY : Float = 0;
        
        // Prepare in-use number renderers for re-use
        m_fractionSprite.prepareNumberRendererForReuse();
        
        // Add number displays for units (all integers)
        if (m_fractionSprite.doShowNumberRenderers)
        {
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
                unitDisplay.y = unitY + totalHeight / 2 + StripConstants.NUMBER_DISPLAY_MARGIN_INTEGER;
                unitDisplay.alpha = unitNumDisplayAlpha;
                unitDisplay.showIntegerAsFraction = false;
                numberDisplay.addChild(unitDisplay);
                unitDisplay.render();
                
                // Compute next unit location
                unitX += blockWidth * frac.denominator;
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
        var totalHeight : Float = unitHeight;
        var g : Graphics = result.graphics;
        
        // Draw a rectangle
        g.clear();
        g.beginFill(0xffaaff);
        var borderThickness : Float = StripConstants.BACKBONE_BORDER_THICKNESS;
        g.drawRect(-maskWidth / 2 - borderThickness / 2, -totalHeight / 2 - borderThickness, maskWidth + borderThickness, totalHeight + (borderThickness * 2));
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
    
    public function paintColoredFill(fill : Sprite, fillAlpha : Float) : Void
    {
        var fillFraction : CgsFraction = m_fractionSprite.parentView.fraction;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        var fillColor : Int = m_fractionSprite.parentView.foregroundColor;
        var fillStartFraction : CgsFraction = m_fractionSprite.fillStartFraction;
        var fillPercent : Float = 1;
        
        drawCenteredFill(fill, fillFraction, numTotalUnits, fillColor, fillAlpha, fillStartFraction, fillPercent);
    }
    
    public function paintColoredFillLine(fill : Sprite, fillAlpha : Float = 1) : Void
    {
        var fillFraction : CgsFraction = m_fractionSprite.parentView.fraction;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        var fillColor : Int = m_fractionSprite.parentView.foregroundColor;
        var fillStartFraction : CgsFraction = m_fractionSprite.fillStartFraction;
        var fillPercent : Float = 1;
        
        drawFillLine(fill, fillFraction, numTotalUnits, fillColor, fillAlpha, fillStartFraction, fillPercent);
    }
    
    public function paintValue(secondSegment : Sprite) : Void
    {
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var numTotalUnits : Int = m_fractionSprite.numTotalUnits;
        secondSegment.graphics.clear();
        
        // Draw Segment
        drawSegmentForPeel(secondSegment, m_fractionSprite.parentView.fraction, numTotalUnits, foregroundColor);
        
        // Draw Ticks
        drawTicksForPeel(secondSegment, m_fractionSprite.parentView.fraction, numTotalUnits);
        
        secondSegment.x = -totalWidth / 2 + secondSegment.width / 2;
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
    
    /**
		 * 
		 * Peeling value
		 * 
		**/
    
    public function createChangeDenomData(parent : DisplayObjectContainer, animHelper : AnimationHelper, changeDenomCenter : Point, startFraction : CgsFraction, finalFraction : CgsFraction, otherFraction : CgsFraction, textColor : Int, textGlowColor : Int) : StripChangeDenomData
    {
        var changeDenomData : StripChangeDenomData = new StripChangeDenomData();
        
        // Change Denom Data - Multiplier
        changeDenomData.multiplierHolder = new Sprite();
        animHelper.trackDisplay(changeDenomData.multiplierHolder);
        var cloneOfOtherValue : NumberRenderer = animHelper.createNumberRenderer(otherFraction, textColor, textGlowColor);
        changeDenomData.multiplierText = cloneOfOtherValue.cloneDenominator();
        animHelper.trackDisplay(changeDenomData.multiplierText);
        changeDenomData.multiplierHolder.addChild(changeDenomData.multiplierText);
        changeDenomData.multiplierText.x = -changeDenomData.multiplierText.width / 2;
        changeDenomData.multiplierText.y = -changeDenomData.multiplierText.height / 2;
        
        // Change Denom Data - Segments
        var numTicksPerSegment : Float = otherFraction.denominator;
        
        // Setup the new segments
        var firstBlockGroupWidth : Float = (unitWidth / startFraction.denominator);
        changeDenomData.segmentHolder = new Sprite();
        animHelper.trackDisplay(changeDenomData.segmentHolder);
        var rawMultiplierPositions : Array<Point> = new Array<Point>();
        var segmentGroupWidth : Float = unitWidth * (1 / startFraction.denominator);
        changeDenomData.segments = drawSegmentsForChangingDenominator(finalFraction, numBaseUnits);
        for (tickIndex in 0...changeDenomData.segments.length)
        {
            var tickAtIndex : Sprite = changeDenomData.segments[tickIndex];
            animHelper.trackDisplay(tickAtIndex);
            changeDenomData.segmentHolder.addChild(tickAtIndex);
            
            // Compute the center point of each segment grouping
            if (tickIndex % numTicksPerSegment == 0)
            {
                var aGroupPoint : Point = new Point(-totalWidth / 2 + (segmentGroupWidth * rawMultiplierPositions.length) + (segmentGroupWidth / 2), 
                (unitHeight / 2) + changeDenomData.multiplierText.height);
                rawMultiplierPositions.push(aGroupPoint);
            }
        }
        changeDenomData.rawMultiplierPositions = rawMultiplierPositions;
        
        // Adjust locations
        changeDenomData.changeDenomCenter = changeDenomCenter;
        
        // Visibility
        changeDenomData.segmentHolder.visible = false;
        changeDenomData.multiplierHolder.visible = false;
        
        // Add to display list
        parent.addChild(changeDenomData.segmentHolder);
        parent.addChild(changeDenomData.multiplierHolder);
        
        return changeDenomData;
    }
}
