package cgs.fractionVisualization;

import haxe.Constraints.Function;
import cgs.engine.view.IRenderer;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.util.FractionAnimatorFactory;
import cgs.math.CgsFraction;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import openfl.geom.Point;

/**
	 * ...
	 * @author Rich
	 */
class CgsFractionAnimationController extends Sprite
{
    public var endType(get, set) : String;
    public var currentTime(get, never) : Float;
    public var isAnimating(get, never) : Bool;
    public var isPaused(get, never) : Bool;
    public var stepDetailsList(get, never) : Array<Dynamic>;
    public var totalTime(get, never) : Float;
    public var windowWidth(get, set) : Float;
    public var windowHeight(get, set) : Float;

    public static inline var ANIMATOR_KEY : String = "anAnimator";  // A key for accessing the animator  
    
    // State
    private var m_renderer : IRenderer;
    private var m_isAnimating : Bool;
    private var m_endType : String;
    private var m_windowWidth : Float;
    private var m_windowHeight : Float;
    
    // Animation state
    private var m_currentAnimator : IFractionAnimator;
    private var m_currentAnimationHelper : AnimationHelper;
    private var m_originalViews : Array<CgsFractionView>;
    private var m_cloneViews : Array<CgsFractionView>;
    private var m_currentCallback : Function;
    
    public function new(aRenderer : IRenderer, endType : String = "")
    {
        super();
        m_renderer = aRenderer;
        
        m_originalViews = new Array<CgsFractionView>();
        m_cloneViews = new Array<CgsFractionView>();
        
        m_endType = ((endType != null && endType != "")) ? endType : CgsFVConstants.END_TYPE_CLEAR;
        
        m_windowWidth = CgsFVConstants.ANIMATION_CONTROLLER_DEFAULT_WIDTH;
        m_windowHeight = CgsFVConstants.ANIMATION_CONTROLLER_DEFAULT_HEIGHT;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the current end type of the Animation Controller.
		 */
    private function get_endType() : String
    {
        return m_endType;
    }
    
    /**
		 * Sets the current end type of the Animation Controller to be the given value.
		 */
    private function set_endType(value : String) : String
    {
        m_endType = value;
        return value;
    }
    
    /**
		 * Returns the current time index of the animation.
		 */
    private function get_currentTime() : Float
    {
        var result : Float = -1;
        if (m_currentAnimator != null)
        {
            result = m_currentAnimator.currentTime;
        }
        return result;
    }
    
    /**
		 * Returns whether or not this Animation Controller is currently animating.
		 */
    private function get_isAnimating() : Bool
    {
        return m_isAnimating;
    }
    
    /**
		 * Returns whether or not this Animation Controller is currently paused.
		 */
    private function get_isPaused() : Bool
    {
        var result : Bool = true;
        if (m_currentAnimator != null)
        {
            result = m_currentAnimator.isPaused;
        }
        return result;
    }
    
    /**
		 * Returns the list of the details of each step in the current animation.
		 */
    private function get_stepDetailsList() : Array<Dynamic>
    {
        return m_currentAnimator.stepDetailsList;
    }
    
    /**
		 * Returns the total time (aka. duration) of the animation.
		 */
    private function get_totalTime() : Float
    {
        var result : Float = -1;
        if (m_currentAnimator != null)
        {
            result = m_currentAnimator.totalTime;
        }
        return result;
    }
    
    /**
		 * Returns the window width that all animations are required to fit in.
		 */
    private function get_windowWidth() : Float
    {
        return m_windowWidth;
    }
    
    /**
		 * Sets the window width that all animations are required to fit in.
		 */
    private function set_windowWidth(value : Float) : Float
    {
        m_windowWidth = value;
        return value;
    }
    
    /**
		 * Returns the window height that all animations are required to fit in.
		 */
    private function get_windowHeight() : Float
    {
        return m_windowHeight;
    }
    
    /**
		 * Sets the window height that all animations are required to fit in.
		 */
    private function set_windowHeight(value : Float) : Float
    {
        m_windowHeight = value;
        return value;
    }
    
    /**
		 * 
		 * Animations
		 * 
		**/
    
    /**
		 * Runs the given animation for the given representation using the given CgsFractionViews and details.
		 * Calls the given callback when the animation is complete (clears).
		 * Returns true if the animation successfully launches and false if it cannot be launched correctly with the given parameters (ie. a missing fraction view).
		 * @param	animation - The animation to be run. See CgsFvConstants for available animations.
		 * @param	representation - The representation of the fractions views. See CgsFvConstants for available representations.
		 * @param	fractionViews - The fractions views being acted upon. They must all be of the given representation type (with the exception of the convert animation).
		 * @param	completeCallback - The optional function to be called when the animation finishes (cleared). 
		 * @param	details - Optional dynamic object containing details about the animation. Some animations (ie. Benchmark) will require certain fields.
		 * @return
		 */
    public function animate(animation : String, representation : String, fractionViews : Array<CgsFractionView>, completeCallback : Function = null, details : Dynamic = null) : Bool
    {
        var result : Bool = false;
        if (details == null)
        {
            details = {};
        }
        
        // Prep for animation
        if (animatePrep(animation, representation, fractionViews, details))
        {
            // Animate
            m_currentCallback = completeCallback;
            if (!Reflect.hasField(details, CgsFVConstants.RESULT_DESTINATION))
            {
                Reflect.setField(details, Std.string(CgsFVConstants.RESULT_DESTINATION), new Point(0, 0));
            }
            Reflect.setField(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY), m_cloneViews);
            m_currentAnimator.animate(details, endAndCallback);
            result = true;
        }
        
        //completeCallback(null);
        return result;
    }
    
    /**
		 * 
		 * Control
		 * 
		**/
    
    /**
		 * Pauses the currently running animation, if any.
		 */
    public function pause() : Void
    {
        if (m_currentAnimator != null)
        {
            m_currentAnimator.pause();
        }
    }
    
    /**
		 * Resumes the currently running animation, if any.
		 */
    public function resume() : Void
    {
        if (m_currentAnimator != null)
        {
            m_currentAnimator.resume();
        }
    }
    
    /**
		 * Jumps the currently running animation, if any, to the given time.
		 * @param	time
		 */
    public function jumpToTime(time : Float) : Void
    {
        if (m_currentAnimator != null)
        {
            m_currentAnimator.jumpToTime(time);
        }
    }
    
    /**
		 * 
		 * Animaton Ending
		 * 
		**/
    
    /**
		 * Kills the currently running animation, if any.
		 */
    public function killCurrentAnimation() : Void
    {
        if (m_isAnimating && m_currentAnimator != null)
        {
            m_currentAnimator.killAnimator();
            endAnimation();
            m_currentCallback = null;
        }
    }
    
    /**
		 * End the currently running animation and calls the current callback.
		 * @param	resultViews
		 */
    private function endAndCallback(resultViews : Array<CgsFractionView> = null) : Void
    {
        if (!m_isAnimating)
        {
            return;
        }
        
        var result : Dynamic = endAnimation(resultViews);
        
        // Callback with the result data
        if (m_currentCallback != null)
        {
            var callback : Function = m_currentCallback;
            m_currentCallback = null;
            callback(result);
        }
    }
    
    /**
		 * End the currently running animation.
		 */
    private function endAnimation(resultViews : Array<CgsFractionView> = null) : Dynamic
    {
        // Note: The animator is already cleaned up (but not reset) by the time this is called.
        // Either it ended itself and called back or we killed it.
        // Either way, now we are cleaning ourselves up too.
        // Note: The animator is responsible for cleaning up the animation helper.
        
        // Make sure the result exists
        var result : Dynamic = {};
        if (resultViews == null)
        {
            resultViews = new Array<CgsFractionView>();
        }
        Reflect.setField(result, "resultViews", resultViews);
        
        // Clear out original views and make them visible again
        while (m_originalViews.length > 0)
        {
            var origView : CgsFractionView = m_originalViews.shift();
            origView.visible = true;
        }
        
        // Clear out clone views
        while (m_cloneViews.length > 0)
        {
            var cloneView : CgsFractionView = m_cloneViews.pop();
        }
        
        // Other state
        FractionAnimatorFactory.getInstance().recycleAnimatorInstance(m_currentAnimator);
        m_currentAnimator = null;
        m_currentAnimationHelper.reset();
        m_currentAnimationHelper = null;
        m_isAnimating = false;
        
        return result;
    }
    
    /**
		 * 
		 * Type specific checks
		 * 
		**/
    
    /**
		 * Returns whether or not this is valid comparison data
		 * @param	comparisonType
		 * @param	data
		 */
    private function isValidCompare(comparisonType : String, data : Dynamic = null) : Bool
    {
        var result : Bool = true;
        
        // Check specific data values for each comparision type
        if (comparisonType == CgsFVConstants.COMPARE_TYPE_CLOSEST_TO_BENCHMARK)
        {
            // Ensuring data for target comparison is valid
            result = data != null && Reflect.hasField(data, CgsFVConstants.COMPARISON_BENCHMARK_DATA_KEY);
        }
        else
        {
            if (comparisonType == CgsFVConstants.COMPARE_TYPE_GREATER_THAN)
            {  // Nothing to check  
                
            }
            else
            {
                if (comparisonType == CgsFVConstants.COMPARE_TYPE_LESS_THAN)
                {  // Nothing to check  
                    
                }
                else
                {
                    // Not one of the valid comparison types, fail!
                    result = false;
                }
            }
        }
        
        return result;
    }
    
    /**
		 * 
		 * Animaton Prep
		 * 
		**/
    
    /**
		 * Do all common boiler plate code to prepare for an animation.
		 * @param	origViews
		 * @param	callback
		 * @return
		 */
    private function animatePrep(animation : String, representation : String, fractionViews : Array<CgsFractionView>, details : Dynamic) : Bool
    {
        var result : Bool = false;
        
        // If they are not the same representation, do nothing
        if (!m_isAnimating && animationIsForRepresentation(animation, representation) &&
            areAllViewsValid(fractionViews) && areAllViewGivenRepresentation(representation, fractionViews))
        {
            m_isAnimating = true;
            
            // Create animation helper
            m_currentAnimationHelper = new AnimationHelper();
            m_currentAnimationHelper.init(this, m_renderer, details);
            
            // Make clones
            saveAndCloneAllViews(fractionViews);
            
            // Create animator
            m_currentAnimator = FractionAnimatorFactory.getInstance().getAnimatorInstance(animation);
            m_currentAnimator.init(this, m_currentAnimationHelper);
            
            result = true;
        }
        
        return result;
    }
    
    /**
		 * Returns whether or not all views are valid. There has to be at least one view to be valid.
		 * @param	views
		 * @return
		 */
    private function areAllViewsValid(views : Array<CgsFractionView>) : Bool
    {
        var result : Bool = views.length > 0;
        
        // Check that all views have that type
        for (aView in views)
        {
            if (aView == null)
            {
                result = false;
                break;
            }
        }
        
        return result;
    }
    
    /**
		 * Returns whether or not all the views in the given list are all of the same representation.
		 * @param	views
		 * @return
		 */
    private function areAllViewGivenRepresentation(representation : String, views : Array<CgsFractionView>) : Bool
    {
        var result : Bool = true;
        
        // A list of views that is 0 or 1 in length is by definition the same representation
        if (views.length > 1)
        {
            // Check that all views have that type
            for (aView in views)
            {
                if (aView.representationType != representation)
                {
                    result = false;
                    break;
                }
            }
        }
        
        return result;
    }
    
    /**
		 * Returns whether or not the given animation is valid for the given representation.
		 * @param	animation
		 * @param	representation
		 * @return
		 */
    private function animationIsForRepresentation(animation : String, representation : String) : Bool
    {
        var result : Bool = false;
        if (representation == CgsFVConstants.STRIP_REPRESENTATION)
        {
            result = CgsFVConstants.STRIP_ANIMATION_LIST.indexOf(animation) >= 0;
        }
        else
        {
            if (representation == CgsFVConstants.GRID_REPRESENTATION)
            {
                result = CgsFVConstants.GRID_ANIMATION_LIST.indexOf(animation) >= 0;
            }
            else
            {
                if (representation == CgsFVConstants.PIE_REPRESENTATION)
                {
                    result = CgsFVConstants.PIE_ANIMATION_LIST.indexOf(animation) >= 0;
                }
                else
                {
                    if (representation == CgsFVConstants.NUMBERLINE_REPRESENTATION)
                    {
                        result = CgsFVConstants.NUMBERLINE_ANIMATION_LIST.indexOf(animation) >= 0;
                    }
                }
            }
        }
        return result;
    }
    
    /**
		 * Clones all the views in the given list, places them on the display list, and returns the lot of them.
		 * @param	views
		 * @return
		 */
    private function saveAndCloneAllViews(views : Array<CgsFractionView>) : Void
    {
        while (views.length > 0)
        {
            var aView : CgsFractionView = views.shift();
            m_originalViews.push(aView);
            var aClone : CgsFractionView = cloneAndPlaceFractionView(aView);
            aClone.foregroundColor = aView.foregroundColor;
            aClone.backgroundColor = aView.backgroundColor;
            aClone.fillColor = aView.fillColor;
            m_cloneViews.push(aClone);
            m_currentAnimationHelper.trackFractionView(aClone);
        }
    }
    
    /**
		 * Clones the given CgsFractionView, makes the original invisible, places the clone on this controller in the place of the original.
		 * The result is a clone that is the child of this controller that is in the same place on the screen as the original CgsFractionView.
		 * @param	orig
		 * @return
		 */
    private function cloneAndPlaceFractionView(orig : CgsFractionView) : CgsFractionView
    {
        // Clone
        var clone : CgsFractionView = orig.clone();
        clone.registerForRenderer(m_renderer);
        
        // Position the clone and make the orig invisible
        var origPt : Point = orig.localToGlobal(new Point());
        var localPt : Point = globalToLocal(origPt);
        clone.x = localPt.x;
        clone.y = localPt.y;
        orig.visible = false;
        addChild(clone);
        
        return clone;
    }
    
    /**
		 * 
		 * Animator Callbacks
		 * 
		**/
    
    private function addFractionView(aView : CgsFractionView) : Void
    {
        aView.registerForRenderer(m_renderer);
        m_cloneViews.push(aView);
    }
}

