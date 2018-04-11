package cgs.fractionVisualization.util;

import com.gskinner.motion.GTween;

/**
	 * ...
	 * @author Rich
	 */
class TweenSet
{
    public var tweens(get, never) : Array<GTween>;
    public var times(get, never) : Array<Float>;

    // State
    private var m_tweens : Array<GTween>;
    private var m_times : Array<Float>;
    
    public function new()
    {
        m_tweens = new Array<GTween>();
        m_times = new Array<Float>();
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the list of tweens in this tween set.
		 */
    private function get_tweens() : Array<GTween>
    {
        return m_tweens;
    }
    
    /**
		 * Returns the list of times in this tween set.
		 */
    private function get_times() : Array<Float>
    {
        return m_times;
    }
    
    /**
		 * 
		 * Management
		 * 
		**/
    
    /**
		 * Adds the given tween at the given time to this tween set.
		 * @param	aTime
		 * @param	aTween
		 */
    public function addTween(aTime : Float, aTween : GTween) : Void
    {
        m_tweens.push(aTween);
        m_times.push(aTime);
    }
    
    /**
		 * Adds the tweens and times from the given tween set to this tween set.
		 * @param	otherSet
		 */
    public function addTweensFromOtherSet(otherSet : TweenSet) : Void
    {
        m_tweens = m_tweens.concat(otherSet.tweens);
        m_times = m_times.concat(otherSet.times);
    }
    
    /**
		 * Removes the given tween, and its time, from this tween set.
		 * @param	aTween
		 */
    public function removeTween(aTween : GTween) : Void
    {
        var indexOfTween : Int = Lambda.indexOf(m_tweens, aTween);
        if (indexOfTween >= 0)
        {
            m_tweens.splice(indexOfTween, 1);
            m_times.splice(indexOfTween, 1);
        }
    }
}

