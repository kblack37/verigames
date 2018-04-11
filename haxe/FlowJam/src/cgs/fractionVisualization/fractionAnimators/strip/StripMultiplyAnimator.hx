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
import cgs.fractionVisualization.util.EquationData;
import cgs.fractionVisualization.constants.StripConstants;
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.NumberRendererFactory;
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import openfl.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
	 * ...
	 * @author Rich
	 */
class StripMultiplyAnimator implements IFractionAnimator
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
        return CgsFVConstants.STRIP_STANDARD_MULTIPLY;
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

        //TODO fix animations
//        var textColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_COLOR)) : GenConstants.DEFAULT_TEXT_COLOR;
//        var textGlowColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_GLOW_COLOR)) : GenConstants.DEFAULT_TEXT_GLOW_COLOR;
//
//        /**
//			 * Setup
//			**/
//
//        // Fraction Views
//        var fractionViews : Array<CgsFractionView> = Reflect.field(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY));
//        var finalPosition : Point = Reflect.field(details, Std.string(CgsFVConstants.RESULT_DESTINATION));
//        var first : CgsFractionView = fractionViews[0];
//        var second : CgsFractionView = fractionViews[1];
//        var firstModule : StripFractionModule = try cast(first.module, StripFractionModule) catch(e:Dynamic) null;
//        var secondModule : StripFractionModule = try cast(second.module, StripFractionModule) catch(e:Dynamic) null;
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var origSecondFraction : CgsFraction = second.fraction.clone();
//        var resultFraction : CgsFraction = CgsFraction.fMultiply(first.fraction, second.fraction);
//
//        // Create result fraction view
//        var result : CgsFractionView = first.clone();
//        result.fraction.init(resultFraction.numerator, resultFraction.denominator);
//        result.foregroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) : first.foregroundColor;
//        result.backgroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) : first.backgroundColor;
//        result.borderColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) : first.borderColor;
//        result.tickColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) : first.tickColor;
//        var resultModule : StripFractionModule = (try cast(result.module, StripFractionModule) catch(e:Dynamic) null);
//        result.x = 0;
//        result.y = 50;
//        result.visible = false;
//        result.redraw(true);
//        m_animHelper.trackFractionView(result);
//        m_animController.addChild(result);
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var cutoffWidth : Float = m_animController.windowWidth / 2 - StripConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL * 2;
//        var offsetY : Float = resultModule.unitHeight / 2 + firstModule.unitHeight / 2 + NumberRenderer.MAX_BOX_HEIGHT * 2;
//        var newFirstPosition : Point = new Point(0, result.y - offsetY);
//        var equationCenter : Point = new Point(0, newFirstPosition.y - firstModule.unitHeight / 2 - StripConstants.ANIMATION_MARGIN_EQUATION);
//        var newSecondPosition : Point = new Point(equationCenter.x + StripConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL + secondModule.totalWidth / 2, equationCenter.y);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, equationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor, 1.5);
//        eqData.equationCenter = new Point(eqData.equationCenter.x + eqData.secondValueNR.width / 2 + eqData.opSymbolText.width / 2, eqData.equationCenter.y);
//
//        // Change Denominator Data
//        var firstMultiplier : Int = second.fraction.denominator;
//        var firstMultiplierFraction : CgsFraction = new CgsFraction(firstMultiplier, firstMultiplier);
//        var newFirstNumerator : Int = as3hx.Compat.parseInt(first.fraction.numerator * firstMultiplier);
//        var newFirstDenominator : Int = as3hx.Compat.parseInt(first.fraction.denominator * firstMultiplier);
//        var finalFirstFraction : CgsFraction = new CgsFraction(newFirstNumerator, newFirstDenominator);
//
//        // Change First Denominator Data
//        var firstDenom_multiplierHolder : Sprite;
//        var firstDenom_multiplier : TextField;
//        var newFirstSegmentHolder : Sprite;
//        var newFirstSegments : Array<Sprite>;
//        var newFirstSegmentGroupPositions : Array<Point>;
//        var numTicksPerFirstSegment : Float = firstMultiplier;
//        var numOtherFirstSegments : Float = (firstModule.numBaseUnits * finalFirstFraction.denominator) - numTicksPerFirstSegment;
//        var numOtherFirstSegmentGroups : Float = (firstModule.numBaseUnits * origFirstFraction.denominator) - 1;
//
//        // Get multiplier
//        firstDenom_multiplierHolder = new Sprite();
//        var firstDenom_cloneOfSecondValue : NumberRenderer = m_animHelper.createNumberRenderer(second.fraction, textColor, textGlowColor);
//        firstDenom_multiplier = firstDenom_cloneOfSecondValue.cloneDenominator();
//        m_animHelper.trackDisplay(firstDenom_multiplierHolder);
//        m_animHelper.trackDisplay(firstDenom_multiplier);
//        firstDenom_multiplierHolder.addChild(firstDenom_multiplier);
//        firstDenom_multiplier.x = -firstDenom_multiplier.width / 2;
//        firstDenom_multiplier.y = -firstDenom_multiplier.height / 2;
//        firstDenom_multiplierHolder.visible = false;
//
//        // Change First Denominator Equation Data
//        var firstDenom_equationPosition : Point = new Point(newFirstPosition.x, newFirstPosition.y + firstModule.valueNRPosition.y);
//        var firstDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, firstDenom_equationPosition, first.fraction, " × ", firstMultiplierFraction, finalFirstFraction, textColor, textGlowColor);
//        firstDenom_eqData.equationCenter = new Point(firstDenom_eqData.equationCenter.x + firstDenom_eqData.firstValueNR.width / 2 + firstDenom_eqData.opSymbolText.width + firstDenom_eqData.secondValueNR.width / 2, firstDenom_eqData.equationCenter.y);
//
//        // Exploding segments
//        var explodedSegmentHolder : Sprite = new Sprite();
//        explodedSegmentHolder.x = newFirstPosition.x;
//        explodedSegmentHolder.y = newFirstPosition.y;
//        explodedSegmentHolder.visible = false;
//        m_animHelper.trackDisplay(explodedSegmentHolder);
//        m_animController.addChild(explodedSegmentHolder);
//        var firstExplodedSegments : Array<Sprite> = firstModule.drawSegmentsForChangingDenominator(first.fraction, firstModule.numBaseUnits);
//        var firstExplodedSegment_finalPositions : Array<Point> = new Array<Point>();
//        var oddNumExplodedSegments : Bool = firstExplodedSegments.length % 2 == 1;
//        var explosionCenterOffset : Float = ((oddNumExplodedSegments) ? firstExplodedSegments.length - 1 : firstExplodedSegments.length) / 2;
//        var explosionCenterUnitIndex : Int = Math.floor(explosionCenterOffset / first.fraction.denominator);
//        for (explodedSegmentIndex in 0...firstExplodedSegments.length)
//        {
//            var explodedSegment : Sprite = firstExplodedSegments[explodedSegmentIndex];
//            m_animHelper.trackDisplay(explodedSegment);
//            explodedSegmentHolder.addChild(explodedSegment);
//
//            // Compute explosion position according to segment index and the unit index from the center of the explosion
//            var explodedSegmentIndexFromCenter : Int = as3hx.Compat.parseInt(explodedSegmentIndex - explosionCenterOffset);  // For computing distance between segments
//            var explodedUnitIndex : Int = Math.floor(explodedSegmentIndex / first.fraction.denominator);
//            var explodedUnitIndexFromCenter : Float;  // For computing distance between units
//            if (firstModule.numTotalUnits % 2 == 0)
//            {
//                // Even number of units, center is between to units
//                explodedUnitIndexFromCenter = explodedUnitIndex - explosionCenterUnitIndex + .5;
//            }
//            else
//            {
//                // Odd number of units, center is in the middle of a unit
//                explodedUnitIndexFromCenter = explodedUnitIndex - explosionCenterUnitIndex;
//            }
//            var explosionDistance : Float = (explodedSegmentIndexFromCenter * StripConstants.SEGMENT_MARGIN_HORIZONTAL_SMALL) + (explodedUnitIndexFromCenter * StripConstants.SEGMENT_MARGIN_HORIZONTAL_MEDIUM);
//            var aFirstExplodedSegment_finalPosition : Point = new Point(explodedSegment.x + explosionDistance, 0);
//            firstExplodedSegment_finalPositions.push(aFirstExplodedSegment_finalPosition);
//        }
//
//        // Setup the new segments
//        var firstBlockGroupWidth : Float = (firstModule.unitWidth / origFirstFraction.denominator);
//        newFirstSegmentHolder = new Sprite();
//        newFirstSegmentHolder.x = newFirstPosition.x;
//        newFirstSegmentHolder.y = newFirstPosition.y;
//        newFirstSegmentHolder.visible = false;
//        m_animHelper.trackDisplay(newFirstSegmentHolder);
//        m_animController.addChild(newFirstSegmentHolder);
//        newFirstSegmentGroupPositions = new Array<Point>();
//        var firstSegmentGroupWidth : Float = firstModule.unitWidth * (1 / origFirstFraction.denominator);
//        newFirstSegments = firstModule.drawSegmentsForChangingDenominator(finalFirstFraction, firstModule.numBaseUnits);
//        for (tickIndex in 0...newFirstSegments.length)
//        {
//            var tickAtIndex : Sprite = newFirstSegments[tickIndex];
//            m_animHelper.trackDisplay(tickAtIndex);
//            newFirstSegmentHolder.addChild(tickAtIndex);
//
//            // Adjust location of the tick, so that it is in the location of the exploded segment it will be for
//            var currSegmentIndexOfFirst : Int = Math.floor(tickIndex / firstMultiplier);
//            explodedSegment = firstExplodedSegments[currSegmentIndexOfFirst];
//            aFirstExplodedSegment_finalPosition = firstExplodedSegment_finalPositions[currSegmentIndexOfFirst];
//            var tickOffsetX : Float = tickAtIndex.x - explodedSegment.x;
//            var tickOffsetY : Float = tickAtIndex.y - explodedSegment.y;
//            tickAtIndex.x = aFirstExplodedSegment_finalPosition.x + tickOffsetX;
//            tickAtIndex.y = aFirstExplodedSegment_finalPosition.y + tickOffsetY;
//
//            // Compute the center point of each segment grouping
//            if (tickIndex % numTicksPerFirstSegment == 0)
//            {
//                var groupPoint : Point = new Point(newFirstPosition.x + aFirstExplodedSegment_finalPosition.x, newFirstPosition.y + aFirstExplodedSegment_finalPosition.y + (firstModule.unitHeight / 2) + firstDenom_multiplier.height);
//                newFirstSegmentGroupPositions.push(groupPoint);
//            }
//        }
//
//        // The multiplier goes above the segments
//        m_animController.addChild(firstDenom_multiplierHolder);
//
//        // Drop Data
//        var doDrop : Bool = first.fraction.numerator != 0;
//        if (doDrop)
//        {
//            var firstDenom_dropCountHolder : Sprite = new Sprite();
//            var firstDenom_dropCount : TextField = firstDenom_cloneOfSecondValue.cloneNumerator();
//            m_animHelper.trackDisplay(firstDenom_dropCountHolder);
//            m_animHelper.trackDisplay(firstDenom_dropCount);
//            firstDenom_dropCountHolder.addChild(firstDenom_dropCount);
//            firstDenom_dropCount.x = -firstDenom_dropCount.width / 2;
//            firstDenom_dropCount.y = -firstDenom_dropCount.height / 2;
//            firstDenom_dropCountHolder.visible = false;
//            m_animController.addChild(firstDenom_dropCountHolder);
//
//            // Setup drop count positions
//            var dropCountPositions : Array<Point> = new Array<Point>();
//            for (explodedSegmentIndex in 0...first.fraction.numerator)
//            {
//                aFirstExplodedSegment_finalPosition = firstExplodedSegment_finalPositions[explodedSegmentIndex];
//                groupPoint = new Point(newFirstPosition.x + aFirstExplodedSegment_finalPosition.x, newFirstPosition.y + aFirstExplodedSegment_finalPosition.y + (firstModule.unitHeight / 2) + firstDenom_multiplier.height);
//                dropCountPositions.push(groupPoint);
//            }
//
//            // Setup the drop segments
//            var dropSegments : Array<Sprite>;
//            var dropSegmentDestinations : Array<Point> = new Array<Point>();
//            var dropSegmentWidth : Float = resultModule.unitWidth / resultFraction.denominator;
//            dropSegments = firstModule.drawSegmentsForDrop(resultFraction, resultModule.numBaseUnits, result.foregroundColor);
//            for (dropIndex in 0...dropSegments.length)
//            {
//                var dropSegmentAtIndex : Sprite = dropSegments[dropIndex];
//                dropSegmentAtIndex.visible = false;
//                m_animHelper.trackDisplay(dropSegmentAtIndex);
//                m_animController.addChild(dropSegmentAtIndex);
//
//                // Adjust location of the tick, so that it is in the location of the exploded segment it will be for
//                var firstSegmentIndex : Int = as3hx.Compat.parseInt(dropIndex / origSecondFraction.numerator);
//                explodedSegment = firstExplodedSegments[firstSegmentIndex];
//                aFirstExplodedSegment_finalPosition = firstExplodedSegment_finalPositions[firstSegmentIndex];
//                dropSegmentAtIndex.x = newFirstPosition.x + aFirstExplodedSegment_finalPosition.x - explodedSegment.width / 2 + dropSegmentWidth / 2;
//                dropSegmentAtIndex.y = newFirstPosition.y + aFirstExplodedSegment_finalPosition.y;
//
//                // Compute end points for each drop segment
//                var aDropSegmentDestination : Point = new Point(result.x - resultModule.totalWidth / 2 + dropIndex * dropSegmentWidth + dropSegmentWidth / 2, result.y);
//                dropSegmentDestinations.push(aDropSegmentDestination);
//            }
//        }
//
//        // Merge data
//        var finalEquationCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var finalEqData : EquationData = m_animHelper.createEquationData(m_animController, finalEquationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor);
//        finalEqData.equationCenter = new Point(finalEqData.equationCenter.x - finalEqData.secondValueNR.width / 2 - finalEqData.equalsSymbolText.width - finalEqData.resultValueNR.width / 2, finalEqData.equationCenter.y);
//
//        // Simplification
//        var doSimplify : Bool = !resultFraction.isSimplified;
//        var simplifiedResultFraction : CgsFraction = resultFraction.clone();
//        simplifiedResultFraction.simplify();
//        var simplifiedResult : CgsFractionView = result.clone();
//        simplifiedResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//        simplifiedResult.visible = false;
//        simplifiedResult.redraw(true);
//        simplifiedResult.x = 0;
//        simplifiedResult.y = 0;
//        m_animHelper.trackFractionView(simplifiedResult);
//        m_animController.addChild(simplifiedResult);
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_POSITION);
//        var positionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_POSITION, position_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        positionStep.addCallback(0, prepEquation, null, prepEquation_reverse);
//        var moveStart : Float = .1;
//        positionStep.addTween(moveStart, new GTween(first, position_unitDuration, {
//                    x : newFirstPosition.x,
//                    y : newFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(second, position_unitDuration, {
//                    alpha : 0,
//                    x : newSecondPosition.x,
//                    y : newSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(eqData.firstValueNR, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(eqData.firstValueNR, position_unitDuration, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(eqData.opSymbolText, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(eqData.opSymbolText, position_unitDuration, {
//                    x : eqData.opSymbolText_equationPosition.x,
//                    y : eqData.opSymbolText_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(eqData.secondValueNR, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(eqData.secondValueNR, position_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        /**
//			 * Change first fraction's denominator
//			**/
//
//        var changeDenom_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DELAY_AFTER_CHANGE_DENOM);
//        var changeDenom_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_CHANGE_DENOM);
//        var changeDenom_durationPerTick : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_CHANGE_DENOM_PER_TICK);
//        var changeDenom_maxDuration_firstSegment : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX);
//        var changeDenom_minDurationPerTick : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_CHANGE_DENOM_PER_TICK_MIN);
//        var changeFirstDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_DENOMINATOR, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//        changeFirstDenomStep.addCallback(0, prepForChangeFirstDenominator, null, prepForChangeFirstDenominator_reverse);
//
//        // Set timing values
//        var firstDenom_explode_startTime : Float = .1;
//        var firstDenom_pulseMultiplier_startTime : Float = firstDenom_explode_startTime + changeDenom_unitDuration;
//        var firstDenom_showMultiplier_startTime : Float = firstDenom_pulseMultiplier_startTime + changeDenom_unitDuration / 2;
//        var firstDenom_moveMultiplier_startTime : Float = firstDenom_showMultiplier_startTime + .1;
//        var firstDenom_changeFirstSegment_startTime : Float = firstDenom_moveMultiplier_startTime + changeDenom_unitDuration / 2;
//        var firstDenom_changeFirstSegmentDuration : Float = Math.min(changeDenom_durationPerTick * numTicksPerFirstSegment, changeDenom_maxDuration_firstSegment);
//        var firstDenom_changeOtherSegments_startTime : Float = firstDenom_changeFirstSegment_startTime + firstDenom_changeFirstSegmentDuration + changeDenom_unitDuration / 2;
//        var firstDenom_changeOtherSegmentDuration : Float = Math.max(firstDenom_changeFirstSegmentDuration / 2, changeDenom_minDurationPerTick * numTicksPerFirstSegment) * (numOtherFirstSegmentGroups + 1);  // + 1 is for moving the roaming multiplier
//        var firstDenom_hideMultiplier_startTime : Float = firstDenom_changeOtherSegments_startTime + firstDenom_changeOtherSegmentDuration;
//        var firstDenom_finalize_startTime : Float = firstDenom_hideMultiplier_startTime + changeDenom_unitDuration / 2;
//
//        // Explode first
//        changeFirstDenomStep.addTween(firstDenom_explode_startTime, new GTween(first, changeDenom_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        changeFirstDenomStep.addTween(firstDenom_explode_startTime, new GTween(firstDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, {
//                    x : firstDenom_eqData.firstValueNR_equationPosition.x,
//                    y : firstDenom_eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        for (explodedSegmentIndex in 0...firstExplodedSegments.length)
//        {
//            explodedSegment = firstExplodedSegments[explodedSegmentIndex];
//            aFirstExplodedSegment_finalPosition = firstExplodedSegment_finalPositions[explodedSegmentIndex];
//            changeFirstDenomStep.addTween(firstDenom_explode_startTime, new GTween(explodedSegment, changeDenom_unitDuration, {
//                        x : aFirstExplodedSegment_finalPosition.x,
//                        y : aFirstExplodedSegment_finalPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//
//        // Pulse and move roaming multiplier
//        var currSecondDenominatorScale : Float = eqData.secondValueNR.denominatorScale;
//        changeFirstDenomStep.addTween(firstDenom_pulseMultiplier_startTime, new GTween(eqData.secondValueNR, changeDenom_unitDuration / 4, {
//                    denominatorScale : currSecondDenominatorScale * 1.5
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        changeFirstDenomStep.addTween(firstDenom_pulseMultiplier_startTime + changeDenom_unitDuration / 4, new GTween(eqData.secondValueNR, changeDenom_unitDuration / 4, {
//                    denominatorScale : currSecondDenominatorScale
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        groupPoint = newFirstSegmentGroupPositions[0];
//        changeFirstDenomStep.addCallback(firstDenom_showMultiplier_startTime, showFirstMultiplier, null, showFirstMultiplier_reverse);
//        changeFirstDenomStep.addTween(firstDenom_moveMultiplier_startTime, new GTween(firstDenom_multiplierHolder, changeDenom_unitDuration / 2, {
//                    x : groupPoint.x,
//                    y : groupPoint.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        // Handle changing ticks of the first segment rectangle
//        var currTickStartTime : Float = firstDenom_changeFirstSegment_startTime;
//        var firstTicksFadeDuration : Float = firstDenom_changeFirstSegmentDuration / numTicksPerFirstSegment;
//        for (tickIndex in 0...numTicksPerFirstSegment)
//        {
//            tickAtIndex = newFirstSegments[tickIndex];
//            changeFirstDenomStep.addTween(currTickStartTime, new GTween(tickAtIndex, firstTicksFadeDuration / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeFirstDenomStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(tickAtIndex, firstTicksFadeDuration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//            changeFirstDenomStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(firstDenom_multiplierHolder, firstTicksFadeDuration, 1, 1, StripConstants.PULSE_SCALE_GENERAL));
//            currTickStartTime += firstTicksFadeDuration;
//        }
//
//        // Handle changing ticks of all the other segment rectangles
//        currTickStartTime = firstDenom_changeOtherSegments_startTime;
//        var otherTicksFadeDuration : Float = firstDenom_changeOtherSegmentDuration / (numOtherFirstSegments + numOtherFirstSegmentGroups);  // + groups is for moving the roaming multiplier
//        var currSegmentGroupIndex : Int = 1;
//        for (tickIndex in numTicksPerFirstSegment...newFirstSegments.length)
//        {
//            // Move multiplier
//            if (tickIndex % numTicksPerFirstSegment == 0)
//            {
//                groupPoint = newFirstSegmentGroupPositions[currSegmentGroupIndex];
//                changeFirstDenomStep.addTween(currTickStartTime, new GTween(firstDenom_multiplierHolder, otherTicksFadeDuration, {
//                            x : groupPoint.x,
//                            y : groupPoint.y
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//                currTickStartTime += otherTicksFadeDuration;
//                currSegmentGroupIndex++;
//            }
//
//            // Pulse segment
//            tickAtIndex = newFirstSegments[tickIndex];
//            changeFirstDenomStep.addTween(currTickStartTime, new GTween(tickAtIndex, firstTicksFadeDuration / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeFirstDenomStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(tickAtIndex, otherTicksFadeDuration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//            changeFirstDenomStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(firstDenom_multiplierHolder, otherTicksFadeDuration, 1, 1, StripConstants.PULSE_SCALE_GENERAL));
//            currTickStartTime += otherTicksFadeDuration;
//        }
//
//        // Finalize
//        changeFirstDenomStep.addTween(firstDenom_hideMultiplier_startTime, new GTween(firstDenom_multiplierHolder, changeDenom_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        changeFirstDenomStep.addCallback(firstDenom_finalize_startTime, changeFirstDenom, null, changeFirstDenom_reverse);
//        m_animHelper.appendStep(changeFirstDenomStep);
//
//        // Tween drop
//        if (doDrop)
//        {
//            var drop_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DELAY_AFTER_DROP);
//            var drop_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_DROP);
//            var drop_pulseDurationPerTick : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_DROP_PULSE_PER_TICK);
//            var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//            dropStep.addCallback(0, prepForDrop, null, prepForDrop_reverse);
//
//            // Timing
//            var drop_pulseDropCount_startTime : Float = .1;
//            var drop_showDropCount_startTime : Float = drop_pulseDropCount_startTime + drop_unitDuration / 2;
//            var drop_dropSegment_startTime : Float = drop_showDropCount_startTime + .1;
//            var drop_dropSegmentDuration : Float = (drop_pulseDurationPerTick * dropSegments.length) +
//            (drop_pulseDurationPerTick * 2) +
//            ((drop_unitDuration / 2) * (dropCountPositions.length));
//            var drop_hideDropCount_startTime : Float = drop_dropSegment_startTime + drop_dropSegmentDuration;
//            var drop_moveEquation_startTime : Float = drop_hideDropCount_startTime + drop_unitDuration / 2;
//
//            // Pulse and move roaming drop count
//            var currSecondNumeratorScale : Float = eqData.secondValueNR.numeratorScale;
//            dropStep.addTween(drop_pulseDropCount_startTime, new GTween(eqData.secondValueNR, drop_unitDuration / 4, {
//                        numeratorScale : currSecondNumeratorScale * 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            dropStep.addTween(drop_pulseDropCount_startTime + drop_unitDuration / 4, new GTween(eqData.secondValueNR, drop_unitDuration / 4, {
//                        numeratorScale : currSecondNumeratorScale
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            dropStep.addCallback(drop_showDropCount_startTime, showDropCount, null, showDropCount_reverse);
//
//            // Move drop count and drop segments
//            dropIndex = 0;
//            currTickStartTime = drop_dropSegment_startTime;
//            for (dropCountPositionIndex in 0...dropCountPositions.length)
//            {
//                // Move drop count
//                groupPoint = dropCountPositions[dropCountPositionIndex];
//                dropStep.addTween(currTickStartTime, new GTween(firstDenom_dropCountHolder, drop_unitDuration / 2, {
//                            x : groupPoint.x,
//                            y : groupPoint.y
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//                currTickStartTime += drop_unitDuration / 2;
//
//                // Drop segments
//                while (dropIndex < (dropCountPositionIndex + 1) * origSecondFraction.numerator)
//                {
//                    // Pulse segment
//                    dropSegmentAtIndex = dropSegments[dropIndex];
//                    dropStep.addTween(currTickStartTime, new GTween(dropSegmentAtIndex, drop_pulseDurationPerTick / 2, {
//                                alpha : 1
//                            }, {
//                                ease : Sine.easeInOut
//                            }));
//                    dropStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(dropSegmentAtIndex, drop_pulseDurationPerTick, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//                    dropStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(firstDenom_dropCountHolder, drop_pulseDurationPerTick, 1, 1, StripConstants.PULSE_SCALE_GENERAL));
//                    currTickStartTime += drop_pulseDurationPerTick;
//
//                    // Move segment
//                    aDropSegmentDestination = dropSegmentDestinations[dropIndex];
//                    dropStep.addTween(currTickStartTime, new GTween(dropSegmentAtIndex, drop_pulseDurationPerTick * 2, {
//                                x : aDropSegmentDestination.x,
//                                y : aDropSegmentDestination.y
//                            }, {
//                                ease : Sine.easeInOut
//                            }));
//
//                    // Increment index
//                    dropIndex++;
//                }
//            }
//
//            // Hide drop count
//            dropStep.addTween(drop_hideDropCount_startTime, new GTween(firstDenom_dropCountHolder, drop_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Move Equation
//            dropStep.addTween(drop_moveEquation_startTime, new GTween(newFirstSegmentHolder, drop_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            dropStep.addTween(drop_moveEquation_startTime, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                        x : finalEqData.firstValueNR_equationPosition.x,
//                        y : finalEqData.firstValueNR_equationPosition.y,
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            dropStep.addTween(drop_moveEquation_startTime, new GTween(eqData.opSymbolText, drop_unitDuration, {
//                        x : finalEqData.opSymbolText_equationPosition.x,
//                        y : finalEqData.opSymbolText_equationPosition.y,
//                        scaleX : 1,
//                        scaleY : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            dropStep.addTween(drop_moveEquation_startTime, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                        x : finalEqData.secondValueNR_equationPosition.x,
//                        y : finalEqData.secondValueNR_equationPosition.y,
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            m_animHelper.appendStep(dropStep);
//        }
//
//        // Tween Merge
//        var merge_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DELAY_AFTER_MERGE);
//        var merge_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_MERGE);
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, merge_unitDelay, CgsFVConstants.STEP_TYPE_MERGE);
//        mergeStep.addCallback(0, doMerge, null, doMerge_reverse);
//        var merge_showResultBackbone_startTime : Float = .1;
//        var merge_finalizeMergeTime : Float = merge_showResultBackbone_startTime + merge_unitDuration;
//        var merge_showResult_startTime : Float = merge_finalizeMergeTime + .1;
//        var merge_consolidateResult_startTime : Float = merge_showResult_startTime + merge_unitDuration + merge_unitDelay;  // Includes a little delay after the result text is visible
//        var merge_finalizeEquationTime : Float = merge_consolidateResult_startTime + merge_unitDuration;
//        mergeStep.addTween(merge_showResultBackbone_startTime, new GTween(result, merge_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addCallback(merge_finalizeMergeTime, finalizeMerge, null, finalizeMerge_reverse);
//        mergeStep.addTweenSet(merge_showResult_startTime, EquationData.animationEquationInline_phaseTwo(finalEqData, merge_unitDuration));
//        mergeStep.addTween(merge_showResult_startTime, new GTween(resultModule, merge_unitDuration, {
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTweenSet(merge_consolidateResult_startTime, EquationData.consolidateEquation(finalEqData, merge_unitDuration, finalEqData.resultValueNR_equationPosition));
//        mergeStep.addCallback(merge_finalizeEquationTime, finalizeEquation, null, finalizeEquation_reverse);
//        m_animHelper.appendStep(mergeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplification_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DELAY_AFTER_SIMPLIFICATION);
//            var simplification_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_SIMPLIFICATION);
//            var simplificationStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SIMPLIFICATION, simplification_unitDelay, CgsFVConstants.STEP_TYPE_SIMPLIFICATION);
//            simplificationStep.addCallback(0, prepForSimplification, null, prepForSimplification_reverse);
//            simplificationStep.addTween(.1, new GTween(result, simplification_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addTween(.1, new GTween(simplifiedResult, simplification_unitDuration, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addCallback(.1 + simplification_unitDuration, finalizeSimplification, null, finalizeSimplification_reverse);
//            m_animHelper.appendStep(simplificationStep);
//        }
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_MULT_DURATION_UNPOSITION);
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween((doSimplify) ? simplifiedResult : result, unposition_unitDuration, {
//                    x : finalPosition.x,
//                    y : finalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(unpositionStep);
//
//        // Go
//        m_animHelper.animate(multComplete, positionStep, unpositionStep);
//
//
//        /**
//			 * State Change Functions
//			**/
//
//        function prepEquation() : Void
//        {
//            // Adjust locations of fraction value NRs
//            eqData.firstValueNR.x = first.x;
//            eqData.firstValueNR.y = first.y;
//            eqData.opSymbolText.x = 0;
//            eqData.opSymbolText.y = 0;
//            eqData.secondValueNR.x = second.x;
//            eqData.secondValueNR.y = second.y;
//
//            // Adjust alphas and visibility of equation parts
//            eqData.firstValueNR.visible = true;
//            eqData.opSymbolText.visible = true;
//            eqData.secondValueNR.visible = true;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//            eqData.firstValueNR.alpha = 0;
//            eqData.opSymbolText.alpha = 0;
//            eqData.secondValueNR.alpha = 0;
//        };
//
//        function prepEquation_reverse() : Void
//        {
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }  // Prepares for the change denominator step  ;
//
//
//
//        var prepForChangeFirstDenominator : Void->Void = function() : Void
//        {
//            // Adjust locations for the first fraction equation parts
//            firstDenom_eqData.firstValueNR.x = firstDenom_eqData.firstValueNR_equationPosition.x;
//            firstDenom_eqData.firstValueNR.y = firstDenom_eqData.firstValueNR_equationPosition.y;
//            firstDenom_eqData.opSymbolText.x = firstDenom_eqData.opSymbolText_equationPosition.x;
//            firstDenom_eqData.opSymbolText.y = firstDenom_eqData.opSymbolText_equationPosition.y;
//            firstDenom_eqData.secondValueNR.x = firstDenom_eqData.secondValueNR_equationPosition.x;
//            firstDenom_eqData.secondValueNR.y = firstDenom_eqData.secondValueNR_equationPosition.y;
//            firstDenom_eqData.equalsSymbolText.x = firstDenom_eqData.equalsSymbolText_equationPosition.x;
//            firstDenom_eqData.equalsSymbolText.y = firstDenom_eqData.equalsSymbolText_equationPosition.y;
//            firstDenom_eqData.resultValueNR.x = firstDenom_eqData.resultValueNR_equationPosition.x;
//            firstDenom_eqData.resultValueNR.y = firstDenom_eqData.resultValueNR_equationPosition.y;
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_eqData.firstValueNR.visible = true;
//            firstDenom_eqData.opSymbolText.visible = true;
//            firstDenom_eqData.secondValueNR.visible = true;
//            firstDenom_eqData.equalsSymbolText.visible = true;
//            firstDenom_eqData.resultValueNR.visible = true;
//            firstDenom_eqData.firstValueNR.alpha = 0;
//            firstDenom_eqData.opSymbolText.alpha = 0;
//            firstDenom_eqData.secondValueNR.alpha = 0;
//            firstDenom_eqData.equalsSymbolText.alpha = 0;
//            firstDenom_eqData.resultValueNR.alpha = 0;
//
//            // Adjust visibility of value on first fraction view
//            //firstModule.valueNumDisplayAlpha = 0;
//            //first.redraw(true);
//
//            // Adjust visibility of explosion parts
//            explodedSegmentHolder.visible = true;
//            for (explodedSegmentIndex in 0...firstExplodedSegments.length)
//            {
//                explodedSegment = firstExplodedSegments[explodedSegmentIndex];
//            }
//
//            // Adjust visibility of ticks and holders
//            newFirstSegmentHolder.visible = true;
//            for (tickIndex in 0...newFirstSegments.length)
//            {
//                tickAtIndex = newFirstSegments[tickIndex];
//                tickAtIndex.alpha = 0;
//            }
//        }
//
//        function prepForChangeFirstDenominator_reverse() : Void
//        {
//            // Adjust visibility and alpha for the first fraction
//            firstDenom_eqData.firstValueNR.visible = false;
//            firstDenom_eqData.opSymbolText.visible = false;
//            firstDenom_eqData.secondValueNR.visible = false;
//            firstDenom_eqData.equalsSymbolText.visible = false;
//            firstDenom_eqData.resultValueNR.visible = false;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//
//            // Adjust visibility of explosion parts
//            explodedSegmentHolder.visible = false;
//
//            // Adjust visibility of new ticks
//            newFirstSegmentHolder.visible = false;
//        }  // Shows the first multiplier  ;
//
//
//
//        var showFirstMultiplier : Void->Void = function() : Void
//        {
//            // Adjust location and visibility of first fraction multiplier
//            firstDenom_multiplierHolder.visible = true;
//            firstDenom_multiplierHolder.x = eqData.secondValueNR_equationPosition.x;
//            firstDenom_multiplierHolder.y = eqData.secondValueNR_equationPosition.y + firstDenom_cloneOfSecondValue.lineThickness + firstDenom_multiplier.height / 2;
//        }
//
//        function showFirstMultiplier_reverse() : Void
//        {
//            firstDenom_multiplierHolder.visible = false;
//        }  // Finalizes the changing of the denominator of the first fraction  ;
//
//
//
//        var changeFirstDenom : Void->Void = function() : Void
//        {
//            first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//
//            // Adjust visibility of first fraction multiplier
//            firstDenom_multiplierHolder.visible = false;
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_eqData.firstValueNR.visible = false;
//            firstDenom_eqData.opSymbolText.visible = false;
//            firstDenom_eqData.secondValueNR.visible = false;
//            firstDenom_eqData.equalsSymbolText.visible = false;
//            firstDenom_eqData.resultValueNR.visible = false;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//
//            // Adjust visibility of explosion parts
//            explodedSegmentHolder.visible = false;
//        }
//
//        function changeFirstDenom_reverse() : Void
//        {
//            first.fraction.init(origFirstFraction.numerator, origFirstFraction.denominator);
//
//            // Adjust visibility of first fraction multiplier
//            firstDenom_multiplierHolder.visible = true;
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_eqData.firstValueNR.visible = true;
//            firstDenom_eqData.opSymbolText.visible = true;
//            firstDenom_eqData.secondValueNR.visible = true;
//            firstDenom_eqData.equalsSymbolText.visible = true;
//            firstDenom_eqData.resultValueNR.visible = true;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//
//            // Adjust visibility of explosion parts
//            explodedSegmentHolder.visible = true;
//        }  // Shows the first multiplier  ;
//
//
//
//        var showDropCount : Void->Void = function() : Void
//        {
//            // Adjust location and visibility of first fraction multiplier
//            firstDenom_dropCountHolder.visible = true;
//            firstDenom_dropCountHolder.x = eqData.secondValueNR_equationPosition.x;
//            firstDenom_dropCountHolder.y = eqData.secondValueNR_equationPosition.y - firstDenom_cloneOfSecondValue.lineThickness - firstDenom_dropCount.height / 2;
//        }
//
//        var showDropCount_reverse : Void->Void = function() : Void
//        {
//            firstDenom_dropCountHolder.visible = false;
//        }
//
//        var prepForDrop : Void->Void = function() : Void
//        {
//            // Show drop segments
//            for (dropIndex in 0...dropSegments.length)
//            {
//                dropSegmentAtIndex = dropSegments[dropIndex];
//                dropSegmentAtIndex.visible = true;
//                dropSegmentAtIndex.alpha = 0;
//            }
//        }
//
//        function prepForDrop_reverse() : Void
//        {
//            // Hide drop segments
//            for (dropIndex in 0...dropSegments.length)
//            {
//                dropSegmentAtIndex = dropSegments[dropIndex];
//                dropSegmentAtIndex.visible = false;
//            }
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        var doMerge : Void->Void = function() : Void
//        {
//            // Show result
//            result.visible = true;
//            result.alpha = 0;
//            resultModule.doShowSegment = false;
//            resultModule.valueNumDisplayAlpha = 0;
//            resultModule.valueTickDisplayAlpha = 0;
//        }
//
//        function doMerge_reverse() : Void
//        {
//            // Hide result
//            result.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        var finalizeMerge : Void->Void = function() : Void
//        {
//            // Show actual result
//            resultModule.doShowSegment = true;
//
//            // Hide drop segments
//            if (doDrop)
//            {
//                for (dropIndex in 0...dropSegments.length)
//                {
//                    dropSegmentAtIndex = dropSegments[dropIndex];
//                    dropSegmentAtIndex.visible = false;
//                }
//            }
//
//            // Adjust locations for the final equation parts
//            finalEqData.firstValueNR.x = finalEqData.firstValueNR_equationPosition.x;
//            finalEqData.firstValueNR.y = finalEqData.firstValueNR_equationPosition.y;
//            finalEqData.opSymbolText.x = finalEqData.opSymbolText_equationPosition.x;
//            finalEqData.opSymbolText.y = finalEqData.opSymbolText_equationPosition.y;
//            finalEqData.secondValueNR.x = finalEqData.secondValueNR_equationPosition.x;
//            finalEqData.secondValueNR.y = finalEqData.secondValueNR_equationPosition.y;
//            finalEqData.equalsSymbolText.x = finalEqData.equalsSymbolText_equationPosition.x;
//            finalEqData.equalsSymbolText.y = finalEqData.equalsSymbolText_equationPosition.y;
//            finalEqData.resultValueNR.x = finalEqData.resultValueNR_equationPosition.x;
//            finalEqData.resultValueNR.y = finalEqData.resultValueNR_equationPosition.y;
//
//            // Adjust visibility and alpha for the equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            finalEqData.firstValueNR.visible = true;
//            finalEqData.opSymbolText.visible = true;
//            finalEqData.secondValueNR.visible = true;
//            finalEqData.equalsSymbolText.visible = true;
//            finalEqData.resultValueNR.visible = true;
//            finalEqData.firstValueNR.alpha = 1;
//            finalEqData.opSymbolText.alpha = 1;
//            finalEqData.secondValueNR.alpha = 1;
//            finalEqData.equalsSymbolText.alpha = 0;
//            finalEqData.resultValueNR.alpha = 0;
//        }
//
//        function finalizeMerge_reverse() : Void
//        {
//            // Hide actual result
//            resultModule.doShowSegment = false;
//
//            // Show drop segments
//            if (doDrop)
//            {
//                for (dropIndex in 0...dropSegments.length)
//                {
//                    dropSegmentAtIndex = dropSegments[dropIndex];
//                    dropSegmentAtIndex.visible = true;
//                }
//            }
//
//            // Adjust visibility and alpha for the equation parts
//            eqData.firstValueNR.visible = true;
//            eqData.opSymbolText.visible = true;
//            eqData.secondValueNR.visible = true;
//            finalEqData.firstValueNR.visible = false;
//            finalEqData.opSymbolText.visible = false;
//            finalEqData.secondValueNR.visible = false;
//            finalEqData.equalsSymbolText.visible = false;
//            finalEqData.resultValueNR.visible = false;
//        }  // Finalizes the consolidation of the equation  ;
//
//
//
//        var finalizeEquation : Void->Void = function() : Void
//        {
//            // Show result value on result
//            resultModule.valueNumDisplayAlpha = 1;
//            result.redraw(true);
//
//            // Hide equation data
//            finalEqData.firstValueNR.visible = false;
//            finalEqData.opSymbolText.visible = false;
//            finalEqData.secondValueNR.visible = false;
//            finalEqData.equalsSymbolText.visible = false;
//            finalEqData.resultValueNR.visible = false;
//        }
//
//        function finalizeEquation_reverse() : Void
//        {
//            // Hide result value on result
//            resultModule.valueNumDisplayAlpha = 0;
//            result.redraw(true);
//
//            // Show equation data
//            finalEqData.firstValueNR.visible = true;
//            finalEqData.opSymbolText.visible = true;
//            finalEqData.secondValueNR.visible = true;
//            finalEqData.equalsSymbolText.visible = true;
//            finalEqData.resultValueNR.visible = true;
//        }  // Prepares for simplification of result fraction  ;
//
//
//
//        var prepForSimplification : Void->Void = function() : Void
//        {
//            // Show simplified result
//            simplifiedResult.visible = true;
//            simplifiedResult.alpha = 0;
//            simplifiedResult.x = result.x;
//            simplifiedResult.y = result.y;
//        }
//
//        function prepForSimplification_reverse() : Void
//        {
//            // Hide simplified result
//            simplifiedResult.visible = false;
//        }  // Finalizes simplification of result fraction  ;
//
//
//
//        var finalizeSimplification : Void->Void = function() : Void
//        {
//            // Hidesimplified result
//            first.visible = false;
//        }
//
//        function finalizeSimplification_reverse() : Void
//        {
//            // Show simplified result
//            first.visible = true;
//        }  /**
//			 * Completion
//			**/  ;
//
//
//
//
//
//        var multComplete : Void->Void = function() : Void
//        {
//            if (completeCallback != null)
//            {
//                // Get result view and send it to the game
//                var resultViews : Array<CgsFractionView> = new Array<CgsFractionView>();
//                resultViews.push((doSimplify) ? simplifiedResult : result);
//                endAnimation(resultViews);
//
//                completeCallback(resultViews);
//            }
//            else
//            {
//                endAnimation();
//            }
//        }
    }
}

