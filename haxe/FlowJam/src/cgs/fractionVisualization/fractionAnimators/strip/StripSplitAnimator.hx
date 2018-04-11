package cgs.fractionVisualization.fractionAnimators.strip;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.StripFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.StripConstants;
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.Sprite;
import openfl.geom.Point;

/**
	 * ...
	 * @author Rich
	 */
class StripSplitAnimator implements IFractionAnimator
{
    public var animationIdentifier(get, never) : String;
    public var currentTime(get, never) : Float;
    public var isPaused(get, never) : Bool;
    public var stepDetailsList(get, never) : Array<Dynamic>;
    public var totalTime(get, never) : Float;

    // State
    private var m_animHelper : AnimationHelper;
    
    // Initialized State
    private var m_animController : CgsFractionAnimationController;
    
    public function new()
    {
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(animController : CgsFractionAnimationController, animHelper : AnimationHelper) : Void
    {
        m_animController = animController;
        m_animHelper = animHelper;
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        endAnimation();
        m_animController = null;
        m_animHelper = null;
    }
    
    /**
		 * @inheritDoc
		 */
    public function killAnimator() : Void
    {
        endAnimation();
    }
    
    /**
		 * Ends the animation.
		 */
    private function endAnimation(resultViews : Array<CgsFractionView> = null) : Void
    {
        if (m_animHelper != null)
        {
            m_animHelper.endAnimation(resultViews);
        }
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_animationIdentifier() : String
    {
        return CgsFVConstants.STRIP_STANDARD_SPLIT;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_currentTime() : Float
    {
        return m_animHelper.currentTime;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isPaused() : Bool
    {
        return m_animHelper.isPaused;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_stepDetailsList() : Array<Dynamic>
    {
        return m_animHelper.stepDetailsList;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_totalTime() : Float
    {
        return m_animHelper.totalTime;
    }
    
    /**
		 * 
		 * Control
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function pause() : Void
    {
        m_animHelper.pause();
    }
    
    /**
		 * @inheritDoc
		 */
    public function resume() : Void
    {
        m_animHelper.resume();
    }
    
    /**
		 * @inheritDoc
		 */
    public function jumpToTime(time : Float) : Void
    {
        m_animHelper.jumpToTime(time);
    }
    
    /**
		 * 
		 * Animations
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function animate(details : Dynamic, completeCallback : Function) : Void
    {


        //TODO fix
//        var textColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_COLOR)) : GenConstants.DEFAULT_TEXT_COLOR;
//        var textGlowColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_GLOW_COLOR)) : GenConstants.DEFAULT_TEXT_GLOW_COLOR;
//
//        /**
//			 * Setup
//			**/
//
//        // Fraction Views
//        var fractionViews : Array<CgsFractionView> = Reflect.field(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY));
//        var first : CgsFractionView = fractionViews[0];
//        var firstModule : StripFractionModule = try cast(first.module, StripFractionModule) catch(e:Dynamic) null;
//        var destinationList : Array<Point> = try cast(Reflect.field(details, Std.string(CgsFVConstants.SPLIT_DESTINATIONS_KEY)), Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
//        var count : Int = destinationList.length;
//
//        // Compute new fraction(s)
//        var newDenominator : Int = ((first.fraction.numerator % count == 0)) ? first.fraction.denominator : first.fraction.denominator * count;
//        var doUpdateTicks : Bool = newDenominator != first.fraction.denominator;
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var newFirstNumerator : Int = first.fraction.numerator;
//        if (doUpdateTicks)
//        {
//            newFirstNumerator = as3hx.Compat.parseInt(first.fraction.numerator * (newDenominator / first.fraction.denominator));
//        }
//        var finalNumerator : Int = as3hx.Compat.parseInt(newFirstNumerator / count);
//
//        // Create result views
//        var resultViews : Array<CgsFractionView> = new Array<CgsFractionView>();
//        for (i in 0...count)
//        {
//            // Create a new view for each result to be created, make them clones of the first so they have the same length
//            var aResultView : CgsFractionView = first.clone();
//            aResultView.fraction.init(finalNumerator, newDenominator);
//            m_animHelper.trackFractionView(aResultView);
//            resultViews.push(aResultView);
//
//            // Making the segment and number displays invisible on these clones
//            var aModule : StripFractionModule = try cast(aResultView.module, StripFractionModule) catch(e:Dynamic) null;
//            aModule.doShowSegment = false;
//            aModule.unitNumDisplayAlpha = 0;
//            aModule.unitTickDisplayAlpha = 0;
//            aModule.valueNumDisplayAlpha = 0;
//            aModule.valueTickDisplayAlpha = 0;
//
//            // They go at the sameplace as (but underneath) the starting view
//            aResultView.x = first.x;
//            aResultView.y = first.y;
//            m_animController.addChildAt(aResultView, 0);
//            aResultView.redraw();
//        }
//
//        // Separate and split segment
//        var segmentSprites : Array<Sprite> = new Array<Sprite>();
//        var segmentSpriteHolders : Array<Sprite> = new Array<Sprite>();
//        for (aResultView in resultViews)
//        {
//            // Create a segment sprite for each result view
//            var aSegmentSplitSpriteHolder : Sprite = new Sprite();
//            var aSegmentSplitSprite : Sprite = new Sprite();
//            m_animHelper.trackDisplay(aSegmentSplitSpriteHolder);
//            m_animHelper.trackDisplay(aSegmentSplitSprite);
//            aModule = try cast(aResultView.module, StripFractionModule) catch(e:Dynamic) null;
//            aModule.peelValue(aSegmentSplitSprite);
//            aSegmentSplitSpriteHolder.visible = false;
//            m_animController.addChild(aSegmentSplitSpriteHolder);
//            aSegmentSplitSpriteHolder.addChild(aSegmentSplitSprite);
//            aSegmentSplitSprite.x = -aModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + aSegmentSplitSprite.width / 2;
//            segmentSpriteHolders.push(aSegmentSplitSpriteHolder);
//            segmentSprites.push(aSegmentSplitSprite);
//        }
//
//        // Tween out views each with a split segment
//        var moveDestinations : Array<Point> = new Array<Point>();
//        for (aPoint in destinationList)
//        {
//            moveDestinations.push(m_animController.globalToLocal(aPoint));
//        }
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Update ticks
//        if (doUpdateTicks)
//        {
//            var denominatorStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_DENOMINATOR, StripConstants.TIME_SPLIT_DELAY_AFTER_CHANGE_DENOM, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//            denominatorStep.addCallback(0, updateTicks, null, updateTicks_reverse);
//            m_animHelper.appendStep(denominatorStep);
//        }
//
//        // Move out split values
//        var moveStep : AnimationStep = new AnimationStep("Split and Move", StripConstants.TIME_SPLIT_DELAY_AFTER_POSITION, CgsFVConstants.STEP_TYPE_TBD);
//        moveStep.addCallback(0, doSplit, null, doSplit_reverse);
//        for (moveI in 0...count)
//        {
//            // Get a result, segment, and their destination
//            aResultView = resultViews[moveI];
//            aModule = try cast(aResultView.module, StripFractionModule) catch(e:Dynamic) null;
//            aSegmentSplitSpriteHolder = segmentSpriteHolders[moveI];
//            var aDestination : Point = moveDestinations[moveI];
//
//            // Setup and save the move tweens
//            moveStep.addTween(.1, new GTween(aResultView, StripConstants.TIME_SPLIT_DURATION_POSITION, {
//                        x : aDestination.x,
//                        y : aDestination.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            moveStep.addTween(.1, new GTween(aSegmentSplitSpriteHolder, StripConstants.TIME_SPLIT_DURATION_POSITION, {
//                        x : aDestination.x,
//                        y : aDestination.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            moveStep.addTween(.1, new GTween(aModule, StripConstants.TIME_SPLIT_DURATION_POSITION, {
//                        unitNumDisplayAlpha : 1,
//                        unitTickDisplayAlpha : 1,
//                        valueNumDisplayAlpha : 1,
//                        valueTickDisplayAlpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//        moveStep.addTween(.1, new GTween(first, StripConstants.TIME_SPLIT_DURATION_POSITION, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        moveStep.addCallback(.1 + StripConstants.TIME_SPLIT_DURATION_POSITION, finalizeViews, null, finalizeViews_reverse);
//        m_animHelper.appendStep(moveStep);
//
//        // Go
//        m_animHelper.animate(splitComplete);
//
//
//        /**
//			 * State Change Functions
//			**/
//
//        // Updates the ticks (instantly) for either fraction that needs it
//        function updateTicks() : Void
//        {
//            if (newFirstNumerator != first.fraction.numerator)
//            {
//                first.fraction.init(newFirstNumerator, newDenominator);
//                first.redraw(true);
//            }
//        }  // Updates the ticks (instantly) for either fraction that needs it  ;
//
//
//
//        var updateTicks_reverse : Void->Void = function() : Void
//        {
//            first.fraction.init(origFirstFraction.numerator, origFirstFraction.denominator);
//            first.redraw(true);
//        }
//
//        var doSplit : Void->Void = function() : Void
//        {
//            var startX : Float = first.x;
//            if (firstModule.numBaseUnits > 1)
//            {
//                // Shift the start back by half a base width for each unit beyond 1 for the background
//                var numExtraStartUnits : Int = as3hx.Compat.parseInt(firstModule.numBaseUnits - 1);
//                startX += -(numExtraStartUnits * firstModule.unitWidth) / 2;
//            }
//            if (finalNumerator > newDenominator)
//            {
//                // Shift the start forward by half a base width for each unit beyond 1 for the segments
//                var numExtraResultUnits : Int = Math.floor(finalNumerator / newDenominator);
//                startX += (numExtraResultUnits * firstModule.unitWidth) / 2;
//            }
//            var offset : Float = 0;
//            for (segmentSplitIndex in 0...segmentSprites.length)
//            {
//                aSegmentSplitSpriteHolder = segmentSpriteHolders[segmentSplitIndex];
//                aSegmentSplitSprite = segmentSprites[segmentSplitIndex];
//
//                aSegmentSplitSpriteHolder.visible = true;
//                aSegmentSplitSpriteHolder.x = startX + offset;
//                aSegmentSplitSpriteHolder.y = first.y;
//                offset += aSegmentSplitSprite.width - StripConstants.BACKBONE_BORDER_THICKNESS;
//            }
//        }
//
//        function doSplit_reverse() : Void
//        {
//            for (aSegmentSplitSpriteHolder in segmentSpriteHolders)
//            {
//                aSegmentSplitSpriteHolder.visible = false;
//            }
//        }  // Displays final fractions on the result views and removes segments  ;
//
//
//
//        function finalizeViews() : Void
//        {
//            // Turn off first
//            first.visible = false;
//
//            // Finalize result views
//            for (aResultView in resultViews)
//            {
//                aResultView.fraction.init(finalNumerator, newDenominator);
//                (try cast(aResultView.module, StripFractionModule) catch(e:Dynamic) null).doShowSegment = true;
//                aResultView.redraw(true);
//            }
//
//            // Remove segments
//            for (aSegmentSplitSpriteHolder in segmentSpriteHolders)
//            {
//                aSegmentSplitSpriteHolder.visible = false;
//            }
//        }  // Displays final fractions on the result views and removes segments  ;
//
//
//
//        function finalizeViews_reverse() : Void
//        {
//            // Turn on first
//            first.visible = true;
//
//            // Remove segments
//            for (aSegmentSplitSpriteHolder in segmentSpriteHolders)
//            {
//                aSegmentSplitSpriteHolder.visible = true;
//            }
//        }
//
//
//
//
//
//
//
//        var splitComplete : Void->Void = function() : Void
//        {
//            if (completeCallback != null)
//            {
//                endAnimation(resultViews);
//                completeCallback(resultViews);
//            }
//            else
//            {
//                endAnimation();
//            }
//        }
    }
}

