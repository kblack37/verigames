package cgs.fractionVisualization.fractionAnimators;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;

/**
	 * ...
	 * @author Rich
	 */
interface IFractionAnimator
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the representation type of this module.
		 */
    var animationIdentifier(get, never) : String;    
    
    /**
		 * Returns the current time index of the animation.
		 */
    var currentTime(get, never) : Float;    
    
    /**
		 * Returns whether or not this animation is paused.
		 */
    var isPaused(get, never) : Bool;    
    
    /**
		 * Returns the list of the details of each step in the current animation.
		 */
    var stepDetailsList(get, never) : Array<Dynamic>;    
    
    /**
		 * Returns the total time (aka. duration) of the animation.
		 */
    var totalTime(get, never) : Float;

    /**
		 * Initializes this animator.
		 * @param	animController
		 * @param	animHelper
		 */
    function init(animController : CgsFractionAnimationController, animHelper : AnimationHelper) : Void
    ;
    
    /**
		 * Resets this fraction module to be as if it were freshly constructed.
		 */
    function reset() : Void
    ;
    
    /**
		 * Ends the animation this animator is running. 
		 */
    function killAnimator() : Void
    ;
    
    /**
		 * 
		 * Control
		 * 
		**/
    
    /**
		 * Pauses the currently running animation, if any.
		 */
    function pause() : Void
    ;
    
    /**
		 * Resumes the currently running animation, if any.
		 */
    function resume() : Void
    ;
    
    /**
		 * Jumps the currently running animation, if any, to the given time.
		 * @param	time
		 */
    function jumpToTime(time : Float) : Void;
    
    /**
		 * 
		 * Animations
		 * 
		**/
    
    /**
		 * Animates the animation the animator is responsible for.
		 * @param	details - dynamic object containing any parameters needed by the animator to run the animation (ie. the CFVs)
		 * @param	completeCallback - callback to be used when the animation is complete
		 */
    function animate(details : Dynamic, completeCallback : Function) : Void;

}

