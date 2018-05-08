package cgs.fractionVisualization.fractionAnimators;

import haxe.Constraints.Function;
import cgs.fractionVisualization.util.TweenSet;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;

/**
	 * ...
	 * @author Rich
	 */
class AnimationStep
{
    public var name(get, never) : String;
    public var stepType(get, never) : String;
    public var duration(get, never) : Float;

    private var m_name : String;
    private var m_stepType : String;
    private var m_endingDelay : Float;
    private var m_tweens : Array<GTween>;
    private var m_tweenStartTimes : Array<Float>;
    private var m_callbackArgs : Array<Array<Dynamic>>;
    private var m_callbackTimes : Array<Float>;
    private var m_beginningDelay : Float = 1.0 / 30.0;  // For adding a single frame delay at the start to ensure there are no callbacks at the exact beginning of a step  
    
    public function new(aName : String, endingDelay : Float = 0, stepType : String = "")
    {
        m_name = aName;
        m_stepType = stepType;
        m_endingDelay = endingDelay;
        m_tweens = new Array<GTween>();
        m_tweenStartTimes = new Array<Float>();
        m_callbackArgs = new Array<Array<Dynamic>>();
        m_callbackTimes = new Array<Float>();
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the name of this step.
		 */
    private function get_name() : String
    {
        return m_name;
    }
    
    /**
		 * Returns the type of this step.
		 */
    private function get_stepType() : String
    {
        return m_stepType;
    }
    
    /**
		 * Computes and returns the duration of this step.
		 */
    private function get_duration() : Float
    {
        var result : Float = m_beginningDelay;
        
        // Compute the maximum duration of the tweens within this step
        for (i in 0...m_tweens.length)
        {
            var aTween : GTween = m_tweens[i];
            var aStartTime : Float = m_tweenStartTimes[i];
            var duration : Float = aStartTime + aTween.duration;
            result = Math.max(result, duration);
        }
        
        // Ensure none of the callbacks start after that
        for (j in 0...m_callbackArgs.length)
        {
            var aCallbackTime : Float = m_callbackTimes[j];
            result = Math.max(result, aCallbackTime);
        }
        
        // Add ending delay
        result += m_endingDelay;
        
        return result;
    }
    
    /**
		 * 
		 * Tween Management
		 * 
		**/
    
    /**
		 * Adds the given tween to the list of tweens being tracked.
		 * @param	relativeStartTime
		 * @param	aTween
		 */
    public function addTween(relativeStartTime : Float, aTween : GTween) : Void
    {
        m_tweens.push(aTween);
        m_tweenStartTimes.push(relativeStartTime);
    }
    
    /**
		 * Adds the tweens in the given data to this step.
		 * @param	relativeStartTime
		 * @param	tweenData
		 */
    public function addTweenSet(relativeStartTime : Float, tweenData : TweenSet) : Void
    {
        var tweens : Array<GTween> = tweenData.tweens;
        var times : Array<Float> = tweenData.times;
        
        // Do nothing if not valid data
        if (tweens == null || times == null || tweens.length != times.length)
        {
            return;
        }
        
        // Add each tween to the timeline at the appropriate time
        for (index in 0...tweens.length)
        {
            var aTween : GTween = tweens[index];
            var aTime : Float = times[index];
            addTween(relativeStartTime + aTime, aTween);
        }
    }
    
    /**
		 * Adds the given callback to the list of callbacks being tracked.
		 * @param	relativeStartTime
		 * @param	relativeStartTime
		 * @param	forwardCallback
		 * @param	forwardParameters
		 * @param	reverseCallback
		 * @param	reverseParameters
		 */
    public function addCallback(relativeStartTime : Float, forwardCallback : Function, forwardParameters : Array<Dynamic> = null, reverseCallback : Function = null, reverseParameters : Array<Dynamic> = null) : Void
    {
        if (relativeStartTime == 0)
        {
        }
        
        m_callbackArgs.push([forwardCallback, forwardParameters, reverseCallback, reverseParameters]);
        m_callbackTimes.push(relativeStartTime);
    }
    
    /**
		 * 
		 * Timeline Management
		 * 
		**/
    
    /**
		 * Adds this step to the given timeline starting at the given time index.
		 * @param	aTimeline
		 */
    public function addToTimeline(aTimeline : GTweenTimeline, timeIndex : Float) : Void
    {
        timeIndex += m_beginningDelay;
        
        // Compute the maximum duration of the tweens within this step
        for (i in 0...m_tweens.length)
        {
            var aTween : GTween = m_tweens[i];
            var aStartTime : Float = m_tweenStartTimes[i];
            aTimeline.addTween(timeIndex + aStartTime, aTween);
        }
        
        // Ensure none of the callbacks start after that
        for (j in 0...m_callbackArgs.length)
        {
            var aCallbackArgs : Array<Dynamic> = m_callbackArgs[j];
            var aCallbackTime : Float = m_callbackTimes[j];
            aTimeline.addCallback(timeIndex + aCallbackTime, aCallbackArgs[0], aCallbackArgs[1], aCallbackArgs[2], aCallbackArgs[3]);
        }
    }
    
    /**
		 * Adds this step to the given timeline starting at the given time index.
		 * @param	aTimeline
		 * @param	timeIndex
		 */
    public function skipOnTimeline(aTimeline : GTweenTimeline, timeIndex : Float) : Void
    {
        aTimeline.addCallback(timeIndex, skipCallback, null, skipCallback_reverse);
        cancelStep();
    }
    
    /**
		 * Immediately applies the tweens/callbacks of this step, in order.
		 */
    public function applyStepImmediately() : Void
    {
        skipCallback();
        cancelStep();
    }
    
    /**
		 * Prevents this step from running.
		 */
    public function cancelStep() : Void
    {
        for (aTween in m_tweens)
        {
            aTween.paused = true;
        }
    }
    
    /**
		 * Runs all the tweens and callbacks of this step instantaneously.
		 */
    private function skipCallback() : Void
    {
        var currTweenIndex : Int = 0;
        var currCallbackIndex : Int = 0;
        
        while (m_tweenStartTimes.length > currTweenIndex || m_callbackTimes.length > currCallbackIndex)
        {
            var nextTweenStartTime : Float = m_tweenStartTimes.length > currTweenIndex ? m_tweenStartTimes[currTweenIndex] : Math.POSITIVE_INFINITY;
            var nextCallbackStartTime : Float = m_callbackTimes.length > currCallbackIndex ? m_callbackTimes[currCallbackIndex] : Math.POSITIVE_INFINITY;
            
            // Tween is up next
            if (nextTweenStartTime < nextCallbackStartTime)
            {
                // Apply the tween completely
                var aTween : GTween = m_tweens[currTweenIndex];
                aTween.init();
                var tweenValues : Dynamic = aTween.getValues();
                for (aProp in Reflect.fields(tweenValues))
                {
                    Reflect.setField(aTween.target, aProp,  aTween.getValue(aProp));
                }
                currTweenIndex++;
            }
            else
            {
                // Callback is up next
                {
                    // Run the callback
                    var aCallbackArgs : Array<Dynamic> = m_callbackArgs[currCallbackIndex];
                    var callbackFn : Function = aCallbackArgs[0];
                    var callbackArgs : Array<Dynamic> = aCallbackArgs[1];
                    if (callbackFn != null)
                    {
                        Reflect.callMethod(null, callbackFn, callbackArgs);
                    }
                    currCallbackIndex++;
                }
            }
        }
    }
    
    /**
		 * Runs all the tweens and callbacks of this step instantaneously, in reverse.
		 */
    private function skipCallback_reverse() : Void
    {
        var currTweenIndex : Int = as3hx.Compat.parseInt(m_tweenStartTimes.length - 1);
        var currCallbackIndex : Int = as3hx.Compat.parseInt(m_callbackTimes.length - 1);
        
        while (currTweenIndex >= 0 || currCallbackIndex >= 0)
        {
            var nextTweenStartTime : Float = ((currTweenIndex >= 0)) ? m_tweenStartTimes[currTweenIndex] : -1;
            var nextCallbackStartTime : Float = ((currCallbackIndex >= 0)) ? m_callbackTimes[currCallbackIndex] : -1;
            
            // Tween is up next
            if (nextTweenStartTime >= nextCallbackStartTime)
            {
                // Undo the tween completely
                var aTween : GTween = m_tweens[currTweenIndex];
                var tweenValues : Dynamic = aTween.getValues();
                for (aProp in Reflect.fields(tweenValues))
                {
                    Reflect.setField(aTween.target, aProp, aTween.getInitValue(aProp));
                }
                currTweenIndex--;
            }
            else
            {
                // Callback is up next
                {
                    // Run the callback
                    var aCallbackArgs : Array<Dynamic> = m_callbackArgs[currCallbackIndex];
                    var callbackFn : Function = aCallbackArgs[2];
                    var callbackArgs : Array<Dynamic> = aCallbackArgs[3];
                    if (callbackFn != null)
                    {
                        Reflect.callMethod(null, callbackFn, callbackArgs);
                    }
                    currCallbackIndex--;
                }
            }
        }
    }
    
    /**
		 * Removes this step from the given timeline.
		 * @param	aTimeline
		 */
    public function removeFromTimeline(aTimeline : GTweenTimeline) : Void
    {
        while (m_tweens != null && m_tweens.length > 0)
        {
            var aTween : GTween = m_tweens.pop();
            aTween.target = null;
            if (aTimeline != null)
            {
                aTimeline.removeTween(aTween);
            }
        }
        m_tweens = null;
        while (m_tweenStartTimes != null && m_tweenStartTimes.length > 0)
        {
            m_tweenStartTimes.pop();
        }
        m_tweenStartTimes = null;
        while (m_callbackArgs  != null && m_callbackArgs.length > 0)
        {
            m_callbackArgs.pop();
        }
        m_callbackArgs = null;
        while (m_callbackTimes != null && m_callbackTimes.length > 0)
        {
            m_callbackTimes.pop();
        }
        m_callbackTimes = null;
    }
}

