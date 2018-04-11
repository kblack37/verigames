package cgs.fractionVisualization.util;

import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.DisplayObject;
import flash.display.Sprite;
import openfl.geom.Point;


//TODO Fix tweens
/**
	 * ...
	 * @author Jack
	 */
class FVEmphasis
{
    
    /**
		 * Changes the size of the given target by the given scaleModifier and back to its original scale over the given duration.
		 * @param	target
		 * @param	duration
		 * @param	targetScale
		 * @param	callback
		 */
    public static function computePulseTweens(target : DisplayObject, duration : Float, startScaleX : Float, startScaleY : Float, scaleModifier : Float) : TweenSet
    {
        var result : TweenSet = new TweenSet();
        
        // Compute destination scale
        var destinationScaleX : Float = startScaleX * scaleModifier;
        var destinationScaleY : Float = startScaleY * scaleModifier;
        
        // Create tweens
        result.addTween(0, new GTween(target, duration / 2, {
                    scaleX : destinationScaleX,
                    scaleY : destinationScaleY
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(duration / 2, new GTween(target, duration / 2, {
                    scaleX : startScaleX,
                    scaleY : startScaleY
                }, {
                    ease : Sine.easeInOut
                }));
        
        return result;
    }
    
    /**
		 * Changes the size of the given target NR Numerator and/or Denominator by the given scaleModifier and back to its original scale over the given duration.
		 * @param	target
		 * @param	duration
		 * @param	startScale
		 * @param	scaleModifier
		 * @param	pulseNumerator
		 * @param	pulseDenominator
		 * @return
		 */
    public static function computeNRPulseTweens(target : NumberRenderer, duration : Float, startScale : Float, scaleModifier : Float, pulseNumerator : Bool = true, pulseDenominator : Bool = true) : TweenSet
    {
        var result : TweenSet = new TweenSet();
        
        // Compute destination scale
        var destinationScale : Float = startScale * scaleModifier;
        
        // Create tweens
        if (pulseNumerator)
        {
            result.addTween(0, new GTween(target, duration / 2, {
                        numeratorScale : destinationScale
                    }, {
                        ease : Sine.easeInOut
                    }));
            result.addTween(duration / 2, new GTween(target, duration / 2, {
                        numeratorScale : startScale
                    }, {
                        ease : Sine.easeInOut
                    }));
        }
        
        // Create tweens
        if (pulseDenominator)
        {
            result.addTween(0, new GTween(target, duration / 2, {
                        denominatorScale : destinationScale
                    }, {
                        ease : Sine.easeInOut
                    }));
            result.addTween(duration / 2, new GTween(target, duration / 2, {
                        denominatorScale : startScale
                    }, {
                        ease : Sine.easeInOut
                    }));
        }
        
        return result;
    }
    
    /**
		 * Changes the size of the given target to be a scale of 0, with a short pulse before hand.
		 * @param	target
		 * @param	duration
		 * @param	targetScale
		 * @param	callback
		 */
    public static function computeNullifyTweens(target : DisplayObject, duration : Float, startScaleX : Float, startScaleY : Float, pulseModifier : Float) : TweenSet
    {
        var result : TweenSet = new TweenSet();
        
        // Compute destination scale
        var intermediateScaleX : Float = startScaleX * pulseModifier;
        var intermediateScaleY : Float = startScaleY * pulseModifier;
        
        // Compute destination scale
        var destinationScaleX : Float = 0;
        var destinationScaleY : Float = 0;
        
        // Create tweens
        result.addTween(0, new GTween(target, duration / 4, {
                    scaleX : intermediateScaleX,
                    scaleY : intermediateScaleY
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(duration / 4, new GTween(target, duration * (3 / 4), {
                    scaleX : destinationScaleX,
                    scaleY : destinationScaleY
                }, {
                    ease : Sine.easeInOut
                }));
        result.addTween(duration / 2, new GTween(target, duration / 2, {
                    alpha : 0
                }, {
                    ease : Sine.easeInOut
                }));
        
        return result;
    }
    
    /**
		 * Changes the size of the given target to be a scale of 0, with a short pulse before hand.
		 * @param	target
		 * @param	duration
		 * @param	targetScale
		 * @param	callback
		 */
    public static function computeBounceTweens(target : DisplayObject, duration : Float, startPosition : Point, bouncePosition : Point, numBounces : Int) : TweenSet
    {
        var result : TweenSet = new TweenSet();
        
        // Compute
        var durationPerMove : Float = (duration / numBounces) / 2;
        var intermediatePosition : Point = new Point(startPosition.x + (bouncePosition.x - startPosition.x) / 2, startPosition.y + (bouncePosition.y - startPosition.y) / 2);
        
        // Create tweens
        var currentTime : Float = 0;
        for (i in 0...numBounces)
        {
            var currPosition : Point = ((i + 1 < numBounces)) ? intermediatePosition : startPosition;
            result.addTween(currentTime, new GTween(target, durationPerMove, {
                        x : bouncePosition.x,
                        y : bouncePosition.y
                    }, {
                        ease : Sine.easeInOut
                    }));
            result.addTween(currentTime + durationPerMove, new GTween(target, durationPerMove, {
                        x : currPosition.x,
                        y : currPosition.y
                    }, {
                        ease : Sine.easeInOut
                    }));
            currentTime += durationPerMove * 2;
        }
        
        return result;
    }

    public function new()
    {
    }
}

