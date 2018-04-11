package cgs.fractionVisualization.fractionModules;

import cgs.fractionVisualization.FractionSprite;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.constants.PieConstants;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import flash.display.DisplayObjectContainer;
import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import openfl.geom.Point;
//import mx.validators.NumberValidator;

/**
	 * ...
	 * @author Jack
	 * Modified/Finished by Mike (07/24/2014)
	 *
	 */
class PieFractionModule implements IFractionModule
{
    public var doShowSegment(get, set) : Bool;
    public var doShowTicks(get, set) : Bool;
    public var representationType(get, never) : String;
    public var fillAlpha(get, set) : Float;
    public var segmentAlpha(get, set) : Float;
    public var fillColor(get, set) : Int;
    public var fillPercent(get, set) : Float;
    public var fillStartFraction(get, set) : CgsFraction;
    public var numBaseUnits(get, never) : Int;
    public var numExtensionUnits(get, set) : Int;
    public var segmentColor(get, never) : Int;
    public var valueOffsetX(get, never) : Float;
    public var baseWidth(get, never) : Float;
    public var totalWidth(get, never) : Float;
    public var valueWidth(get, never) : Float;
    public var scaleX(get, set) : Float;
    public var scaleY(get, set) : Float;
    public var unitWidth(get, never) : Float;
    public var distanceBetweenPies(get, never) : Float;
    public var unitHeight(get, never) : Float;
    public var valueNumDisplayAlpha(get, set) : Float;
    public var backboneAlpha(get, set) : Float;
    public var ticksAlpha(get, set) : Float;
    public var unitNumDisplayAlpha(get, set) : Float;
    public var unitTickDisplayAlpha(get, set) : Float;
    public var valueTickDisplayAlpha(get, set) : Float;
    public var valueIsAbove(get, set) : Bool;
    public var valueNRPosition(get, never) : Point;

    // State
    private var m_fractionSprite : FractionSprite;
    private var m_scaleX : Float = 1;
    private var m_scaleY : Float = 1;
    private var m_unitWidth : Float = PieConstants.BASE_UNIT_DIAMETER;
    private var m_unitHeight : Float = PieConstants.BASE_UNIT_DIAMETER;
    private var m_distanceBetweenPies : Float = PieConstants.BASE_UNIT_SEPARATION;
    
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
        
        m_scaleX = 1;
        m_scaleY = 1;
        m_unitWidth = PieConstants.BASE_UNIT_DIAMETER;
        m_unitHeight = PieConstants.BASE_UNIT_DIAMETER;
        m_distanceBetweenPies = PieConstants.BASE_UNIT_SEPARATION;
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
    
    public function increasePieSpacing(scale : Float) : Void
    {
        m_distanceBetweenPies = PieConstants.BASE_UNIT_SEPARATION * scale;
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
    
    private function get_doShowTicks() : Bool
    {
        return m_fractionSprite.ticks.visible;
    }
    
    private function set_doShowTicks(value : Bool) : Bool
    {
        m_fractionSprite.ticks.visible = value;
        return value;
    }
    
    
    /**
		 * 
		 * Utility
		 * 
		**/
    
    
    /**
		 * @inheritDoc
		 */
    
    /**
		 * Returns the representation type of this module.
		 */
    private function get_representationType() : String
    {
        return CgsFVConstants.PIE_REPRESENTATION;
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
		 * Gets the segmentAlpha on the fractionSprite
		 */
    private function get_segmentAlpha() : Float
    {
        return m_fractionSprite.segment.alpha;
    }
    
    /**
		 * Sets the segmentAlpha on the fractionSprite
		 */
    private function set_segmentAlpha(val : Float) : Float
    {
        m_fractionSprite.segment.alpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the fillColor on the fractionSprite
		 */
    private function get_fillColor() : Int
    {
        return m_fractionSprite.parentView.fillColor;
    }
    
    /**
		 * Sets the fillColor on the fractionSprite
		 */
    private function set_fillColor(val : Int) : Int
    {
        m_fractionSprite.parentView.fillColor = val;
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
		 * Gets the segmentColor
		 */
    private function get_segmentColor() : Int
    {
        return m_fractionSprite.parentView.foregroundColor;
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
		 * Returns the angle for a particular sector WITHIN its circle.
		 * It is always in a clockwise manner from the top
		 * 
		 * So 5/4 would return 0 or 45 degrees depending on whether the option is center edge or leading edge
		 * 
		 * The center option returns the angle of the center of this fraction otherwise it does the leading edge.
		 * For instance 2/3 would yield 120 by default but 150 with center = true
		 * 
		 */
    private function angleFor(whichSector : Int, denominator : Int, center : Bool = false) : Float
    {
        if (whichSector <= 0 || denominator <= 0)
        {
            return 0;
        }
        
        // adjust for circle that it is in
        whichSector = as3hx.Compat.parseInt(whichSector % denominator);
        var angleSize : Float = 360 / denominator;
        var endOfAngle : Float = whichSector * angleSize;
        return ((center)) ? (endOfAngle - angleSize / 2) : (endOfAngle - angleSize);
    }
    
    // calculate location around the circle for a label
    // center needs to have already been calculated
    // denominator is the denominator for whatever the adjusted fraction is (for instance 1/3 x 1/4 would be 12ths)
    public function labelLocation(whichSector : Int, denominator : Int, center : Point, scaleRadius : Float) : Point
    {
        // Find degrees for middle of sector in question
        var labelDistanceFromCenter : Float = m_unitWidth / 2 * scaleRadius;
        var adjustToMiddleOfSector : Float = angleFor(whichSector, denominator, true);
        var location : Point = new Point(center.x - Math.sin(adjustToMiddleOfSector / 180 * Math.PI) * labelDistanceFromCenter, 
        center.y - Math.cos(adjustToMiddleOfSector / 180 * Math.PI) * labelDistanceFromCenter);
        return location;
    }
    
    
    /**
		 * Returns the x value of the circle for a particular value (for example 0.5 is in circle 1 and has a center at...)
		 * This number should be added on to the center of the overall sprite
		 */
    public function centerOffsetFor(value : Float) : Float
    {
        // Start at the center, subtract half the total width to get to the left hand side
        var whichCircle : Float = Math.ceil(value);  // 0.00001 to 1.0 is circle 1  
        // Half the total width back + one radius will be center of first circle
        var centerFirstCircle : Float = 0 - totalWidth / 2 + m_unitWidth / 2;
        // add in another span for each circle
        return centerFirstCircle + (whichCircle - 1) * (m_unitWidth + m_distanceBetweenPies);
    }
    
    /**
		 * Returns the base width (ie. not including extensions) of this module.
		 */
    private function get_baseWidth() : Float
    {
        return as3hx.Compat.parseFloat(m_fractionSprite.numBaseUnits) * m_unitWidth;
    }
    
    /**
		 * Returns the total width (including extensions) of this module.
		 */
    private function get_totalWidth() : Float
    {
        return as3hx.Compat.parseFloat(m_fractionSprite.numTotalUnits) * m_unitWidth + (as3hx.Compat.parseFloat(m_fractionSprite.numTotalUnits) - 1) * m_distanceBetweenPies;
    }
    
    /**
		 * Returns the total width (including extensions) of this module.
		 */
    private function get_valueWidth() : Float
    {
        return m_unitWidth * m_fractionSprite.parentView.fraction.value;
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
        m_unitWidth = PieConstants.BASE_UNIT_DIAMETER * m_scaleX;
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
        m_unitHeight = PieConstants.BASE_UNIT_DIAMETER * m_scaleY;
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
    
    private function get_distanceBetweenPies() : Float
    {
        return m_distanceBetweenPies;
    }
    
    /**
		 * Returns the unit height (the height of a value of 1) of this module.
		 */
    private function get_unitHeight() : Float
    {
        return m_unitHeight;
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
		 * Gets the alpha on the backbone
		 */
    private function get_backboneAlpha() : Float
    {
        return m_fractionSprite.backbone.alpha;
    }
    
    /**
		 * Sets the alpha on the backbone
		 */
    private function set_backboneAlpha(val : Float) : Float
    {
        m_fractionSprite.backbone.alpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
    }
    
    /**
		 * Gets the alpha on the ticks
		 */
    private function get_ticksAlpha() : Float
    {
        return m_fractionSprite.ticks.alpha;
    }
    
    /**
		 * Sets the alpha on the ticks
		 */
    private function set_ticksAlpha(val : Float) : Float
    {
        m_fractionSprite.ticks.alpha = val;
        m_fractionSprite.parentView.redraw();
        return val;
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
        var result : Point = new Point(0, 0);
        if (isAbove)
        {
            result.y = 0 - unitHeight / 2 - ((isInteger) ? PieConstants.NUMBER_DISPLAY_MARGIN_INTEGER : PieConstants.NUMBER_DISPLAY_MARGIN_FRACTION);
        }
        else
        {
            result.y = 0 + unitHeight / 2 + ((isInteger) ? PieConstants.NUMBER_DISPLAY_MARGIN_INTEGER : PieConstants.NUMBER_DISPLAY_MARGIN_FRACTION);
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
        drawTicks(ticks, m_fractionSprite.parentView.fraction, numTotalUnits, borderColor, tickColor);
        
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
		 * scalePieBy is used to draw slightly larger backbones but with same spacing (used for compare glow)
		 */
    private function drawBackbone(backbone : Sprite, numUnits : Int, backgroundColor : Int, scalePieBy : Float = 1.0) : Void
    {
        var totalWidth : Float = m_unitWidth * numUnits + (numUnits - 1) * m_distanceBetweenPies;
        var startX : Float = -totalWidth / 2 + m_unitWidth / 2;
        var g : Graphics = backbone.graphics;
        
        // Draw some circles
        g.clear();
        g.beginFill(backgroundColor);
        for (i in 0...numUnits)
        {
            g.drawCircle(startX, 0, (m_unitWidth * scalePieBy) / 2);
            startX += m_unitWidth + m_distanceBetweenPies;
        }
        g.endFill();
    }
    
    /**
		 * Draws a segment
		 */
    private function drawSegment(segment : Sprite, frac : CgsFraction, numUnits : Int, foregroundColor : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * (m_unitWidth) + as3hx.Compat.parseFloat(numUnits - 1) * m_distanceBetweenPies;
        var totalHeight : Float = m_unitWidth / 2;
        var g : Graphics = segment.graphics;
        
        // Prepping variables for gradient
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Center of First Circle relative to this sprite.  (0,0) if only one circle
        var centerX : Float = -totalWidth / 2 + m_unitWidth / 2;
        var centerY : Float = 0;
        
        var circleR : Float = m_unitWidth / 2;
        
        // Draw all the arcs with a gradient
        g.clear();
        var degreesPerSegment : Float = 360 / frac.denominator;
        var cornerX : Float = 0;
        var cornerY : Float = 0;
        
        for (i in 0...frac.numerator)
        {
            // Create the gradient matrix
            // Compute corner of this circle - used to compute the location of this gradient
            cornerX = centerX - (m_unitWidth / 2) * 1.25;  //1.25 shifts center of gradient to NW corner  
            cornerY = centerY - (m_unitWidth / 2) * 1.25;
            
            var mtx : Matrix = new Matrix();
            mtx.createGradientBox(m_unitWidth, m_unitWidth, 0, cornerX, cornerY);
            g.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
            g.moveTo(centerX, centerY);
            
            var startDegrees : Int = as3hx.Compat.parseInt(i * degreesPerSegment);
            var endDegrees : Int = as3hx.Compat.parseInt((i + 1) * degreesPerSegment);
            
            // The loop draws tiny lines between points on the circle one
            // separated from each other by one degree.
            for (d in startDegrees...endDegrees + 1)
            {
                var xAlongCircle : Float = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                var yAlongCircle : Float = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            
            g.endFill();
            //				}
            // if circle is full, Compute next center point for next circle
            if ((i + 1) % frac.denominator == 0)
            {
                centerX += (m_unitWidth) + m_distanceBetweenPies;
            }
        }
    }
    
    // Placing a sprite in for segment, this essentially creates a copy of the segment.
    public function comparePeel(segment : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int) : Void
    {
        drawFill(segment, fraction, numUnits, fillColor, 1.0, new CgsFraction(0, 1), 1.0);
    }
    
    // Return array of sprites to be used as emphasis (array needed so each can pulse from own center)
    public function pulseSegments(fillColor : Int) : Array<Sprite>
    {
        // get WHOLE circles for all of the segments
        var pulseSegments : Array<Sprite> = emphasisBackbones(fillColor, 1.0);
        
        // get remainder of fraction if it exists
        var partialCircleValue : Float = m_fractionSprite.parentView.fraction.value - Math.floor(m_fractionSprite.parentView.fraction.value);
        if (partialCircleValue != 0)
        {
            // remove last whole circle
            var unneededWholeCircle : Sprite = pulseSegments.pop();
            var lastSprite : Sprite = new Sprite();
            var g : Graphics = lastSprite.graphics;
            g.beginFill(fillColor);
            g.moveTo(0, 0);
            // The loop draws tiny lines between points on the circle one
            // separated from each other by one degree.
            var circleR : Float = (m_unitWidth / 2);
            for (d in 0...Std.int(partialCircleValue * 360 + 1))
            {
                var xAlongCircle : Float = -circleR * Math.sin(d * Math.PI / 180);
                var yAlongCircle : Float = -circleR * Math.cos(d * Math.PI / 180);
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            g.endFill();
            lastSprite.x = unneededWholeCircle.x;
            pulseSegments.push(lastSprite);
        }
        
        return pulseSegments;
    }
    
    // Placing a sprite in for segment, this makes a segment from the benchmark to the end of the fraction
    public function segmentTo(segment : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, benchmark : CgsFraction) : Void
    {
        drawFill(segment, fraction, numUnits, fillColor, 1.0, benchmark, 1.0);
    }
    
    // Return array of sprites to be used as glow (array needed so each can pulse from own center)
    public function emphasisBackbones(backgroundColor : Int, scalePieBy : Float = 1) : Array<Sprite>
    {
        var emphasisBackbones : Array<Sprite> = new Array<Sprite>();
        
        var totalWidth : Float = m_unitWidth * numBaseUnits + (numBaseUnits - 1) * m_distanceBetweenPies;
        var startX : Float = -totalWidth / 2 + m_unitWidth / 2;
        var j : Int = 0;
        while (j < numBaseUnits && m_fractionSprite.parentView.fraction.value != 0)
        {
            var workingBackbone : Sprite = new Sprite();
            var g : Graphics = workingBackbone.graphics;
            // Draw a circle
            g.clear();
            g.beginFill(backgroundColor);
            g.drawCircle(0, 0, (m_unitWidth * scalePieBy) / 2);
            g.endFill();
            workingBackbone.x = startX;
            startX += m_unitWidth + m_distanceBetweenPies;
            emphasisBackbones.push(workingBackbone);
            j++;
        }
        
        return emphasisBackbones;
    }
    
    
    /**
		 * Draws a fill
		 * 
		 * fillStartFraction allows you to begin at a certain place within the fraction and continue the fill from that point.
		 */
    private function drawFill(fill : Sprite, fraction : CgsFraction, numUnits : Int, fillColor : Int, fillAlpha : Float, fillStartFraction : CgsFraction, fillPercent : Float) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * (m_unitWidth) + as3hx.Compat.parseFloat(numUnits - 1) * m_distanceBetweenPies;
        var totalHeight : Float = m_unitWidth;
        var startValue : Float = fraction.value;
        var endValue : Float = (fillStartFraction != null) ? fillStartFraction.value : 0;
        var smaller : Float = Math.min(startValue, endValue);
        var larger : Float = Math.max(startValue, endValue);
        // always going from fraction(start) to benchmark(end), but if fraction is smaller, then direction is reverse
        var direction : Float = ((startValue < endValue)) ? 1 : -1;
        
        var largerDegrees : Float = 360 * larger;
        var smallerDegrees : Float = 360 * smaller;
        
        // Set up Vectors for entire fill
        var circleStartDegrees : Array<Float> = new Array<Float>();
        var circleEndDegrees : Array<Float> = new Array<Float>();
        var circleCenter : Array<Point> = new Array<Point>();
        
        // Leftmost circle location, (0,0) if only one circle
        var centerX : Float = -totalWidth / 2 + (m_unitWidth / 2);
        var centerY : Float = 0;
        
        // it is assumed the smaller cannot be greater than 1
        circleStartDegrees.push(smallerDegrees);
        circleCenter.push(new Point(centerX, centerY));
        //Case 1, both <=360
        if (largerDegrees <= 360)
        {
            circleEndDegrees.push(largerDegrees);
        }
        else
        {
            circleEndDegrees.push(360);
            // example if larger is 3.4 there are 2 full circles between first and last
            var numberOfInBetweenCircles : Float = Math.floor(largerDegrees / 360) - 1;
            // for Integer, reduce by one, if larger is 2.0, reduce 1 to 0
            numberOfInBetweenCircles = ((Math.floor(largerDegrees / 360) == (largerDegrees / 360))) ? numberOfInBetweenCircles - 1 : numberOfInBetweenCircles;
            while (numberOfInBetweenCircles > 0)
            {
                centerX += (m_unitWidth + m_distanceBetweenPies);
                circleStartDegrees.push(0);
                circleCenter.push(new Point(centerX, centerY));
                circleEndDegrees.push(360);
                numberOfInBetweenCircles--;
            }
            // Last circle
            centerX += (m_unitWidth + m_distanceBetweenPies);
            circleStartDegrees.push(0);
            circleCenter.push(new Point(centerX, centerY));
            var largerDegreesRelativeToItsCircle : Float = largerDegrees - (circleEndDegrees.length * 360);
            circleEndDegrees.push(largerDegreesRelativeToItsCircle);
        }
        
        
        //For fill only go up to currentFillWidth
        
        var currentFillWidth : Float = (largerDegrees - smallerDegrees) * fillPercent;
        
        // At 100% this will be the same as endDegrees.  As the fill is filling, it changes.
        var currentEndDegrees : Float = smallerDegrees + currentFillWidth;
        
        var fillCounter : Float = 0;
        var circleCounter : Float = 0;
        
        //clear graphics
        var g : Graphics = fill.graphics;
        g.clear();
        
        if (direction == 1)
        {
            while (fillCounter < currentFillWidth)
            {
                var endOfThisCircle : Float = Reflect.field(circleEndDegrees, Std.string(circleCounter));
                var actualDegreesForEndOfThisCircle : Float = endOfThisCircle + (360 * circleCounter);
                // because fill is changing, it's possible we don't fill the whole circle, just up to currentEndDegrees
                if (currentEndDegrees < actualDegreesForEndOfThisCircle)
                {
                    endOfThisCircle = currentEndDegrees - (360 * circleCounter);
                }
                //Draw Circle
                drawSingleCircleFill(g, fillColor, fillAlpha, Reflect.field(circleStartDegrees, Std.string(circleCounter)), endOfThisCircle, Reflect.field(circleCenter, Std.string(circleCounter)));
                fillCounter += (Reflect.field(circleEndDegrees, Std.string(circleCounter)) - Reflect.field(circleStartDegrees, Std.string(circleCounter)));
                circleCounter += 1;
            }
        }
        else
        {
            currentEndDegrees = largerDegrees - currentFillWidth;
            while (fillCounter < currentFillWidth)
            {
                var backwardsCircleCounter : Float = circleStartDegrees.length - 1 - circleCounter;
                var startOfThisCircle : Float = Reflect.field(circleStartDegrees, Std.string(backwardsCircleCounter));
                var actualDegreesForStartOfThisCircle : Float = startOfThisCircle + (360 * backwardsCircleCounter);
                // because fill is changing, it's possible we don't fill the whole circle, just up to currentEndDegrees
                if (currentEndDegrees > actualDegreesForStartOfThisCircle)
                {
                    startOfThisCircle = currentEndDegrees - (360 * backwardsCircleCounter);
                }
                //Draw Circle
                drawSingleCircleFill(g, fillColor, fillAlpha, startOfThisCircle, Reflect.field(circleEndDegrees, Std.string(backwardsCircleCounter)), Reflect.field(circleCenter, Std.string(backwardsCircleCounter)));
                fillCounter += (Reflect.field(circleEndDegrees, Std.string(backwardsCircleCounter)) - Reflect.field(circleStartDegrees, Std.string(backwardsCircleCounter)));
                circleCounter += 1;
            }
        }
    }
    
    private function drawSingleCircleFill(g : Graphics, fillColor : Int, fillAlpha : Float, startDegrees : Float, endDegrees : Float, circleCenter : Point) : Void
    {
        var circleR : Float = (m_unitWidth / 2);
        
        g.beginFill(fillColor, fillAlpha);
        
        g.moveTo(circleCenter.x, circleCenter.y);
        // The loop draws tiny lines between points on the circle one
        // separated from each other by one degree.
        
        for (d in Std.int(startDegrees)...Std.int(endDegrees + 1))
        {
            var xAlongCircle : Float = -circleR * Math.sin(d * Math.PI / 180) + circleCenter.x;
            var yAlongCircle : Float = -circleR * Math.cos(d * Math.PI / 180) + circleCenter.y;
            g.lineTo(xAlongCircle, yAlongCircle);
        }
        
        g.endFill();
    }
    
    
    /**
		 * Draws a ticks
		 */
    private function drawTicks(ticks : Sprite, frac : CgsFraction, numUnits : Int, borderColor : Int, tickColor : Int, drawAllTicks : Bool = true) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * (m_unitWidth) + as3hx.Compat.parseFloat(numUnits - 1) * m_distanceBetweenPies;
        var totalHeight : Float = (m_unitWidth / 2);
        var g : Graphics = ticks.graphics;
        
        // Center of Circle relative to this sprite.  (0,0) if only one circle
        var centerX : Float = -totalWidth / 2 + (m_unitWidth / 2);
        var centerY : Float = 0;
        
        var circleR : Float = (m_unitWidth / 2);
        
        // Draw all the arcs with a gradient
        g.clear();
        var degreesPerSegment : Float = 360 / frac.denominator;
        g.lineStyle(PieConstants.TICK_THICKNESS, tickColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
        
        var ticksToDraw : Float = (drawAllTicks) ? (frac.denominator * numUnits) : frac.numerator;
        
        for (i in 0...Std.int(ticksToDraw))
        {
            // for whole circles, do not draw like a sector with radius at 12 o'clock.  Instead, just draw a circle
            if (frac.denominator == 1)
            {
                g.drawCircle(centerX, centerY, circleR);
                centerX += (m_unitWidth) + m_distanceBetweenPies;
                continue;
            }
            
            g.moveTo(centerX, centerY);
            
            var startDegrees : Int = as3hx.Compat.parseInt(i * degreesPerSegment);
            var endDegrees : Int = as3hx.Compat.parseInt((i + 1) * degreesPerSegment);
            
            // The loop draws tiny lines between points on the circle one
            // separated from each other by one degree.
            for (d in startDegrees...endDegrees + 1)
            {
                var xAlongCircle : Float = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                var yAlongCircle : Float = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            g.lineTo(centerX, centerY);
            
            g.endFill();
            // if circle is full, Compute next center point for next circle
            if ((i + 1) % frac.denominator == 0)
            {
                centerX += (m_unitWidth) + m_distanceBetweenPies;
            }
        }
    }
    
    /**
		 * Draws a number display
		 */
    private function drawNumberDisplay(numberDisplay : Sprite, frac : CgsFraction, numUnits : Int, textColor : Int, textGlowColor : Int) : Void
    {
        // Get the total width/height
        var totalWidth : Float = numUnits * (m_unitWidth) + as3hx.Compat.parseFloat(numUnits - 1) * m_distanceBetweenPies;
        var totalHeight : Float = (m_unitWidth / 2);
        
        
        // Prepare in-use number renderers for re-use
        m_fractionSprite.prepareNumberRendererForReuse();
        
        // Add number display for the fraction value of the strip
        if (m_fractionSprite.doShowNumberRenderers)
        {
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
        var totalHeight : Float = m_unitWidth;
        var g : Graphics = result.graphics;
        
        // Draw a rectangle
        g.clear();
        g.beginFill(0xffaaff);
        var borderThickness : Float = PieConstants.BACKBONE_BORDER_THICKNESS;
        //g.drawRect(-totalWidth / 2 + baseWidth + borderThickness/2, -totalHeight / 2 - borderThickness, totalWidth - baseWidth + borderThickness, totalHeight + (borderThickness * 2));
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
    
    
    public function duplicateFullCircles(scale : Float) : Array<Sprite>
    {
        var result : Array<Sprite> = new Array<Sprite>();
        var frac : CgsFraction = m_fractionSprite.parentView.fraction;
        
        // Prepping variables for gradient
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Center of First Circle relative to this sprite.  (0,0) if only one circle
        var centerX : Float = 0;  // -totalWidth / 2 + CgsFVConstants.PIE_RADIUS;  
        var centerY : Float = 0;
        
        var circleR : Float = (m_unitWidth / 2);
        
        // Draw all the arcs with a gradient
        var degreesPerSegment : Float = 360 / (frac.denominator * scale);
        var cornerX : Float = 0;
        var cornerY : Float = 0;
        
        //outer loop is per full circle
        for (c in 0...Math.floor(frac.value))
        {
            var sprite : Sprite = new Sprite();
            var g : Graphics = sprite.graphics;
            var xAlongCircle : Float;
            var yAlongCircle : Float;
            //inner loop creates one whole circle sprite marked up appropriately
            for (i in 0...Std.int(frac.denominator * scale))
            {
                // Create the gradient matrix
                // Compute corner of this circle - used to compute the location of this gradient
                cornerX = centerX - (m_unitWidth / 2) * 1.25;  //1.25 shifts center of gradient to NW corner  
                cornerY = centerY - (m_unitWidth / 2) * 1.25;
                
                
                var mtx : Matrix = new Matrix();
                mtx.createGradientBox(m_unitWidth, m_unitWidth, 0, cornerX, cornerY);
                g.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
                g.moveTo(centerX, centerY);
                
                var startDegrees : Int = as3hx.Compat.parseInt(i * degreesPerSegment);
                var endDegrees : Int = as3hx.Compat.parseInt((i + 1) * degreesPerSegment);
                
                // The loop draws tiny lines between points on the circle one
                // separated from each other by one degree.
                for (d in startDegrees...endDegrees + 1)
                {
                    xAlongCircle  = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                    yAlongCircle  = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                    g.lineTo(xAlongCircle, yAlongCircle);
                }
                
                g.endFill();
                
                //  TICKS FOR SPRITES
                
                g.lineStyle(PieConstants.BACKBONE_BORDER_THICKNESS, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
                // for whole circles, do not draw like a sector with radius at 12 o'clock.  Instead, just draw a circle
                if (frac.denominator == 1)
                {
                    g.drawCircle(centerX, centerY, circleR);
                    continue;
                }
                
                g.moveTo(centerX, centerY);
                
                for (d in startDegrees...endDegrees + 1)
                {
                    xAlongCircle = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                    yAlongCircle = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                    g.lineTo(xAlongCircle, yAlongCircle);
                }
                g.lineTo(centerX, centerY);
                
                g.endFill();
            }
            result.push(sprite);
            sprite.x = 0;  //m_fractionSprite.parentView.x;  
            sprite.y = 0;  // m_fractionSprite.parentView.y;  
            sprite.visible = false;
        }
        // does not include drop shadow
        return result;
    }
    
    // This is used (normally by first circle) to peel an entire partial circle (instead of it's parts)
    public function duplicatePartialCircle(scale : Float) : Sprite
    {
        var sprite : Sprite = new Sprite();
        var g : Graphics = sprite.graphics;
        var frac : CgsFraction = m_fractionSprite.parentView.fraction;
        
        // Prepping variables for gradient
        var foregroundColor : Int = m_fractionSprite.parentView.foregroundColor;
        var borderColor : Int = m_fractionSprite.parentView.borderColor;
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Center of First Circle relative to this sprite.  (0,0) if only one circle
        var centerX : Float = 0;  // -totalWidth / 2 + CgsFVConstants.PIE_RADIUS;  
        var centerY : Float = 0;
        
        var circleR : Float = (m_unitWidth / 2);
        
        // Draw all the arcs with a gradient
        var degreesPerSegment : Float = 360 / (frac.denominator * scale);
        var cornerX : Float = 0;
        var cornerY : Float = 0;
        var xAlongCircle : Float;
        var yAlongCircle : Float;
        
        // Math.floor below in case scale is a decimal and there are rounding issues.
        var numeratorsInLastCircle : Int = Math.floor((frac.numerator % frac.denominator) * scale);
        
        for (i in 0...numeratorsInLastCircle)
        {
            // Create the gradient matrix
            // Compute corner of this circle - used to compute the location of this gradient
            cornerX = centerX - (m_unitWidth / 2) * 1.25;  //1.25 shifts center of gradient to NW corner  
            cornerY = centerY - (m_unitWidth / 2) * 1.25;
            
            var mtx : Matrix = new Matrix();
            mtx.createGradientBox(m_unitWidth, m_unitWidth, 0, cornerX, cornerY);
            g.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
            g.moveTo(centerX, centerY);
            
            var startDegrees : Int = as3hx.Compat.parseInt(i * degreesPerSegment);
            var endDegrees : Int = as3hx.Compat.parseInt((i + 1) * degreesPerSegment);
            
            // The loop draws tiny lines between points on the circle one
            // separated from each other by one degree.
            for (d in startDegrees...endDegrees + 1)
            {
                xAlongCircle  = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                yAlongCircle  = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            
            g.endFill();
            
            //  TICKS FOR SPRITES
            
            g.lineStyle(PieConstants.BACKBONE_BORDER_THICKNESS, borderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            g.moveTo(centerX, centerY);
            
            for (d in startDegrees...endDegrees + 1)
            {
                xAlongCircle = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                yAlongCircle = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            g.lineTo(centerX, centerY);
            
            g.endFill();
        }
        // does not include drop shadow
        
        sprite.x = 0;  //m_fractionSprite.parentView.x;  
        sprite.y = 0;  // m_fractionSprite.parentView.y;  
        sprite.visible = false;
        return sprite;
    }
    
    // turns off the local version of these sprites and attach them to another sprite
    public function duplicatePartialSprites(scale : Float, params : Dynamic = null) : Array<Sprite>
    {
        var result : Array<Sprite> = new Array<Sprite>();
        var frac : CgsFraction = m_fractionSprite.parentView.fraction;
        
        // Prepping variables for gradient
        var foregroundColor : Int = ((params != null && params.foregroundColor)) ? params.foregroundColor : m_fractionSprite.parentView.foregroundColor;
        var tickColor : Int = ((params != null && params.tickColor)) ? params.tickColor : m_fractionSprite.parentView.tickColor;
        
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Center of First Circle relative to this sprite.  (0,0) if only one circle
        var centerX : Float = 0;  // -totalWidth / 2 + CgsFVConstants.PIE_RADIUS;  
        var centerY : Float = 0;
        
        var circleR : Float = (m_unitWidth / 2);
        
        // Draw all the arcs with a gradient
        var degreesPerSegment : Float = 360 / (frac.denominator * scale);
        var cornerX : Float = 0;
        var cornerY : Float = 0;
        
        // Math.floor below in case scale is a decimal and there are rounding issues.
        var numeratorsInLastCircle : Int = Math.floor((frac.numerator % frac.denominator) * scale);
        var xAlongCircle : Float;
        var yAlongCircle : Float;
        for (i in 0...numeratorsInLastCircle)
        {
            var sprite : Sprite = new Sprite();
            var g : Graphics = sprite.graphics;
            // Create the gradient matrix
            // Compute corner of this circle - used to compute the location of this gradient
            cornerX = centerX - (m_unitWidth / 2) * 1.25;  //1.25 shifts center of gradient to NW corner  
            cornerY = centerY - (m_unitWidth / 2) * 1.25;
            
            var mtx : Matrix = new Matrix();
            mtx.createGradientBox(m_unitWidth, m_unitWidth, 0, cornerX, cornerY);
            g.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
            g.moveTo(centerX, centerY);
            
            var startDegrees : Int = as3hx.Compat.parseInt(i * degreesPerSegment);
            var endDegrees : Int = as3hx.Compat.parseInt((i + 1) * degreesPerSegment);
            
            // The loop draws tiny lines between points on the circle one
            // separated from each other by one degree.
            for (d in startDegrees...endDegrees + 1)
            {
                xAlongCircle  = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                yAlongCircle  = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            
            g.endFill();
            
            //  TICKS FOR SPRITES
            
            g.lineStyle(PieConstants.BACKBONE_BORDER_THICKNESS, tickColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            g.moveTo(centerX, centerY);
            
            for (d in startDegrees...endDegrees + 1)
            {
                xAlongCircle = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                yAlongCircle = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                g.lineTo(xAlongCircle, yAlongCircle);
            }
            g.lineTo(centerX, centerY);
            
            g.endFill();
            // END TICKS
            
            result.push(sprite);
            sprite.x = 0;  // m_fractionSprite.x;  
            sprite.y = m_fractionSprite.y;
            sprite.visible = false;
        }
        // does not include drop shadow
        return result;
    }
    
    
    /**
		 * This duplicates all the sprites for the fraction centered around (0,0)
		 * The (0,0) is important as rotations will likely be done with these and they need to spin around
		 * a central point (as opposed to the the center of the fraction - which is different if f>1).
		 */
    
    // turns off the local version of these sprites and attach them to another sprite
    public function duplicateAllSprites(subSections : Float = 1, params : Dynamic = null, includeTicksForEmptySectors : Bool = false, fillEmptySectors : Bool = false) : Array<Sprite>
    {
        var result : Array<Sprite> = new Array<Sprite>();
        var frac : CgsFraction = m_fractionSprite.parentView.fraction;
        
        // Prepping variables for gradient
        var foregroundColor : Int = ((params != null && params.foregroundColor)) ? params.foregroundColor : m_fractionSprite.parentView.foregroundColor;
        var tickColor : Int = ((params != null && params.tickColor)) ? params.tickColor : m_fractionSprite.parentView.tickColor;
        
        var colors : Array<UInt> = VisualizationUtilities.computeColorArray(foregroundColor, GenConstants.LIGHTEN_FOREGROUND_FACTOR, GenConstants.DARKEN_FOREGROUND_FACTOR);
        var alphas : Array<Float> = [1, 1, 1];
        var ratios : Array<Int> = [GenConstants.INNER_POINT, GenConstants.MIDDLE_POINT, GenConstants.OUTER_POINT];
        
        // Center of First Circle relative to this sprite.  (0,0) if only one circle
        var centerX : Float = 0;
        var centerY : Float = 0;
        
        var circleR : Float = (m_unitWidth / 2);
        
        // Draw all the arcs with a gradient
        var degreesPerSegment : Float = 360 / (frac.denominator * subSections);
        var cornerX : Float = 0;
        var cornerY : Float = 0;
        
        var howManySprites : Float = frac.numerator * subSections;
        var excludeFillAfterThisNumberOfSprites : Float = howManySprites;

        var xAlongCircle : Float;
        var yAlongCircle : Float;

        if (includeTicksForEmptySectors)
        {
            // weird case for denominator = 0, otherwise just round up to nearest whole
            howManySprites = ((frac.value == 0)) ? frac.denominator * subSections : Math.ceil(frac.value) * frac.denominator * subSections;
        }
        
        for (i in 0...Std.int(howManySprites))
        {
            var sprite : Sprite = new Sprite();
            var g : Graphics = sprite.graphics;
            // Create the gradient matrix
            // Compute corner of this circle - used to compute the location of this gradient
            cornerX = centerX - (m_unitWidth / 2) * 1.25;  //1.25 shifts center of gradient to NW corner  
            cornerY = centerY - (m_unitWidth / 2) * 1.25;
            
            var startDegrees : Int = as3hx.Compat.parseInt(i * degreesPerSegment);
            var endDegrees : Int = as3hx.Compat.parseInt((i + 1) * degreesPerSegment);
            
            if (i < excludeFillAfterThisNumberOfSprites)
            {
                var mtx : Matrix = new Matrix();
                mtx.createGradientBox(m_unitWidth, m_unitWidth, 0, cornerX, cornerY);
                g.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mtx);
                g.moveTo(centerX, centerY);
                
                // The loop draws tiny lines between points on the circle one
                // separated from each other by one degree.
                for (d in startDegrees...endDegrees + 1)
                {
                    xAlongCircle  = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                    yAlongCircle  = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                    g.lineTo(xAlongCircle, yAlongCircle);
                }
                
                g.endFill();
            }
            else
            {
                if (fillEmptySectors)
                {
                    g.beginFill(m_fractionSprite.parentView.backgroundColor);
                    g.moveTo(centerX, centerY);
                    for (d1 in startDegrees...endDegrees + 1)
                    {
                        var x1AlongCircle : Float = -circleR * Math.sin(d1 * Math.PI / 180) + centerX;
                        var y1AlongCircle : Float = -circleR * Math.cos(d1 * Math.PI / 180) + centerY;
                        g.lineTo(x1AlongCircle, y1AlongCircle);
                    }
                    g.endFill();
                }
            }
            
            //  TICKS FOR SPRITES
            g.lineStyle(PieConstants.BACKBONE_BORDER_THICKNESS, tickColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND);
            
            // for whole circles, do not draw like a sector with radius at 12 o'clock.  Instead, just draw a circle
            if (frac.denominator * subSections == 1)
            {
                g.drawCircle(centerX, centerY, circleR);
            }
            else
            {
                g.moveTo(centerX, centerY);
                
                for (d in startDegrees...endDegrees + 1)
                {
                    xAlongCircle = -circleR * Math.sin(d * Math.PI / 180) + centerX;
                    yAlongCircle = -circleR * Math.cos(d * Math.PI / 180) + centerY;
                    g.lineTo(xAlongCircle, yAlongCircle);
                }
                g.lineTo(centerX, centerY);
                
                g.endFill();
            }
            // END TICKS
            
            result.push(sprite);
            sprite.x = 0;  // m_fractionSprite.x;  
            sprite.y = 0;  // m_fractionSprite.y;  
            sprite.visible = false;
        }
        // does not include drop shadow
        return result;
    }
}
