package cgs.fractionVisualization.util.strip;

import cgs.fractionVisualization.constants.StripConstants;
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.TweenSet;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import flash.display.Sprite;
import openfl.geom.Point;
import flash.text.TextField;

/**
	 * ...
	 * @author Rich
	 */
class StripChangeDenomData
{
    public var changeDenomCenter(get, set) : Point;
    public var multiplierHolder(get, set) : Sprite;
    public var multiplierText(get, set) : TextField;
    public var segmentHolder(get, set) : Sprite;
    public var segments(get, set) : Array<Sprite>;
    public var computedMultiplierPositions(get, never) : Array<Point>;
    public var rawMultiplierPositions(get, set) : Array<Point>;

    // Core state
    private var m_changeDenomCenter : Point;
    private var m_multiplierHolder : Sprite;
    private var m_multiplierText : TextField;
    private var m_segmentHolder : Sprite;
    private var m_segments : Array<Sprite>;
    
    // Positioning state
    private var m_rawMultiplierPositions : Array<Point>;  // One per grouping of segments, the grouping contants x segments where x is the muliplier value  
    private var m_computedMultiplierPositions : Array<Point>;  // One per grouping of segments, the grouping contants x segments where x is the muliplier value  
    
    
    public function reset() : Void
    {
    }
    
    /**
		 * 
		 * Core State
		 * 
		**/
    
    /**
		 * Returns the center position of the change denom.
		 */
    private function get_changeDenomCenter() : Point
    {
        return m_changeDenomCenter;
    }
    
    /**
		 * Sets the center position of the change denom to be the given value.
		 */
    private function set_changeDenomCenter(value : Point) : Point
    {
        m_changeDenomCenter = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns the multiplier holder sprite.
		 */
    private function get_multiplierHolder() : Sprite
    {
        return m_multiplierHolder;
    }
    
    /**
		 * Sets the multiplier holder sprite to be the given value.
		 */
    private function set_multiplierHolder(value : Sprite) : Sprite
    {
        m_multiplierHolder = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns the multiplier text sprite.
		 */
    private function get_multiplierText() : TextField
    {
        return m_multiplierText;
    }
    
    /**
		 * Sets the multiplier holder text to be the given value.
		 */
    private function set_multiplierText(value : TextField) : TextField
    {
        m_multiplierText = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns the segment holder sprite.
		 */
    private function get_segmentHolder() : Sprite
    {
        return m_segmentHolder;
    }
    
    /**
		 * Sets the segment holder sprite to be the given value.
		 */
    private function set_segmentHolder(value : Sprite) : Sprite
    {
        m_segmentHolder = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * Returns the list of segment sprites.
		 */
    private function get_segments() : Array<Sprite>
    {
        return m_segments;
    }
    
    /**
		 * Sets the list of segment sprites to be the given value.
		 */
    private function set_segments(value : Array<Sprite>) : Array<Sprite>
    {
        m_segments = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * 
		 * Positioning State
		 * 
		**/
    
    /**
		 * Returns the list of multiplier positions.
		 */
    private function get_computedMultiplierPositions() : Array<Point>
    {
        return m_computedMultiplierPositions;
    }
    
    /**
		 * Returns the list of raw multiplier positions.
		 */
    private function get_rawMultiplierPositions() : Array<Point>
    {
        return m_rawMultiplierPositions;
    }
    
    /**
		 * Sets the list of raw multiplier positions.
		 */
    private function set_rawMultiplierPositions(value : Array<Point>) : Array<Point>
    {
        m_rawMultiplierPositions = value;
        recomputePositions();
        return value;
    }
    
    /**
		 * 
		 * Reposition
		 * 
		**/
    
    /**
		 * Computes new positions of all change denom parts.
		 */
    private function recomputePositions() : Void
    {
        if (changeDenomCenter != null && segmentHolder != null && m_rawMultiplierPositions != null)
        {
            segmentHolder.x = changeDenomCenter.x;
            segmentHolder.y = changeDenomCenter.y;
            
            // Clear out old multiplier positions and replace with new ones
            if (m_computedMultiplierPositions == null)
            {
                m_computedMultiplierPositions = new Array<Point>();
            }
            while (m_computedMultiplierPositions.length > 0)
            {
                m_computedMultiplierPositions.pop();
            }
            for (aRawPos in m_rawMultiplierPositions)
            {
                var finalPos : Point = new Point(changeDenomCenter.x + aRawPos.x, changeDenomCenter.y + aRawPos.y);
                m_computedMultiplierPositions.push(finalPos);
            }
        }
    }
    
    /**
		 * 
		 * Animations
		 * 
		**/
    
    public static function animation_pulseInBlock(aBlock : Sprite, multiplier : Sprite, duration : Float) : TweenSet
    {
        var result : TweenSet = new TweenSet();
        
        // Show Block
        result.addTween(0, new GTween(aBlock, duration / 2, {
                    alpha : 1
                }, {
                    ease : Sine.easeInOut
                }));
        
        // Pulse Block
        result.addTweensFromOtherSet(FVEmphasis.computePulseTweens(aBlock, duration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
        
        // Pulse Multiplier
        result.addTweensFromOtherSet(FVEmphasis.computePulseTweens(multiplier, duration, 1, 1, StripConstants.PULSE_SCALE_GENERAL));
        
        return result;
    }

    public function new()
    {
    }
}

