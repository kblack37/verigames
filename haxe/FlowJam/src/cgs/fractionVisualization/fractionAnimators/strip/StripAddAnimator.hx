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
import cgs.fractionVisualization.util.strip.StripChangeDenomData;
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.Sprite;
import openfl.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
	 * ...
	 * @author Rich
	 */
class StripAddAnimator implements IFractionAnimator
{
    public var animationIdentifier(get, never) : String;
    public var currentTime(get, never) : Float;
    public var isPaused(get, never) : Bool;
    public var stepDetailsList(get, never) : Array<Dynamic>;
    public var totalTime(get, never) : Float;

    // State
    
    // Initialized State
    private var m_animController : CgsFractionAnimationController;
    private var m_animHelper : AnimationHelper;
    
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
        return CgsFVConstants.STRIP_STANDARD_ADD;
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
//        var textColor : Int = Reflect.hasField(details, (CgsFVConstants.TEXT_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_COLOR)) : GenConstants.DEFAULT_TEXT_COLOR;
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
//
//        // Change Denominator Data
//        var doChangeDenom : Bool = first.fraction.denominator != second.fraction.denominator;
//        var commonDenominator : Float = (doChangeDenom) ? (first.fraction.denominator * second.fraction.denominator) : first.fraction.denominator;
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var origSecondFraction : CgsFraction = second.fraction.clone();
//        var firstMultiplier : Int = (doChangeDenom) ? second.fraction.denominator : 1;
//        var secondMultiplier : Int = (doChangeDenom) ? first.fraction.denominator : 1;
//        var firstMultiplierFraction : CgsFraction = new CgsFraction(firstMultiplier, firstMultiplier);
//        var secondMultiplierFraction : CgsFraction = new CgsFraction(secondMultiplier, secondMultiplier);
//        var newFirstNumerator : Int = as3hx.Compat.parseInt(first.fraction.numerator * firstMultiplier);
//        var newSecondNumerator : Int = as3hx.Compat.parseInt(second.fraction.numerator * secondMultiplier);
//        var resultFraction : CgsFraction = new CgsFraction(newFirstNumerator + newSecondNumerator, commonDenominator);
//        var finalFirstFraction : CgsFraction = new CgsFraction(newFirstNumerator, commonDenominator);
//        var finalSecondFraction : CgsFraction = new CgsFraction(newSecondNumerator, commonDenominator);
//
//        // Create result fraction view
//        var result : CgsFractionView = first.clone();
//        result.fraction.init(resultFraction.numerator, resultFraction.denominator);
//        result.foregroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) : first.foregroundColor;
//        result.backgroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) : first.backgroundColor;
//        result.borderColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) : first.borderColor;
//        result.tickColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) : first.tickColor;
//        var resultModule : StripFractionModule = (try cast(result.module, StripFractionModule) catch(e:Dynamic) null);
//        result.visible = false;
//        result.redraw(true);
//        m_animHelper.trackFractionView(result);
//        m_animController.addChild(result);
//        m_animController.addChild(first);
//        m_animController.addChild(second);
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2), resultModule.totalWidth / 2);
//        var offsetY : Float = resultModule.unitHeight / 2 + StripConstants.ANIMATION_MARGIN_VERTICAL_NORMAL * 2;
//        var newFirstPosition : Point = new Point(firstModule.totalWidth / 2 - offsetX, -offsetY - firstModule.unitHeight / 2);
//        var newSecondPosition : Point = new Point(secondModule.totalWidth / 2 - offsetX, offsetY + secondModule.unitHeight / 2);
//        result.x = resultModule.totalWidth / 2 - offsetX;
//
//        // Change First Denominator Data
//        var firstDenomData : StripChangeDenomData = firstModule.createChangeDenomData(m_animController, m_animHelper, newFirstPosition, origFirstFraction, finalFirstFraction, origSecondFraction, textColor, textGlowColor);
//        var numTicksPerFirstSegment : Float = firstMultiplier;
//        var numOtherFirstSegments : Float = (firstModule.numBaseUnits * finalFirstFraction.denominator) - numTicksPerFirstSegment;
//        var numOtherFirstSegmentGroups : Float = (firstModule.numBaseUnits * origFirstFraction.denominator) - 1;
//
//        // Change Second Denominator Data
//        var secondDenomData : StripChangeDenomData = secondModule.createChangeDenomData(m_animController, m_animHelper, newSecondPosition, origSecondFraction, finalSecondFraction, origFirstFraction, textColor, textGlowColor);
//        var numTicksPerSecondSegment : Float = secondMultiplier;
//        var numOtherSecondSegments : Float = (secondModule.numBaseUnits * finalSecondFraction.denominator) - numTicksPerSecondSegment;
//        var numOtherSecondSegmentGroups : Float = (secondModule.numBaseUnits * origSecondFraction.denominator) - 1;
//
//        // Change First Denominator Equation Data
//        var firstDenom_equationPosition : Point = new Point(newFirstPosition.x + firstModule.valueNRPosition.x, newFirstPosition.y + firstModule.valueNRPosition.y);
//        var firstDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, firstDenom_equationPosition, first.fraction, " × ", firstMultiplierFraction, finalFirstFraction, textColor, textGlowColor);
//        firstDenom_eqData.equationCenter = new Point(firstDenom_eqData.equationCenter.x + firstDenom_eqData.firstValueNR.width / 2 + firstDenom_eqData.opSymbolText.width + firstDenom_eqData.secondValueNR.width / 2, firstDenom_eqData.equationCenter.y);
//
//        // Get equation data for changing the second denomintor
//        var secondDenom_equationPosition : Point = new Point(newSecondPosition.x + secondModule.valueNRPosition.x, newSecondPosition.y + secondModule.valueNRPosition.y);
//        var secondDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, secondDenom_equationPosition, second.fraction, " × ", secondMultiplierFraction, finalSecondFraction, textColor, textGlowColor);
//        secondDenom_eqData.equationCenter = new Point(secondDenom_eqData.equationCenter.x + secondDenom_eqData.firstValueNR.width / 2 + secondDenom_eqData.opSymbolText.width + secondDenom_eqData.secondValueNR.width / 2, secondDenom_eqData.equationCenter.y);
//
//        // Peel data
//        var firstSegmentHolder : Sprite = new Sprite();
//        var firstSegment : Sprite = new Sprite();
//        m_animController.addChild(firstSegmentHolder);
//        m_animHelper.trackDisplay(firstSegmentHolder);
//        firstSegmentHolder.addChild(firstSegment);
//        m_animHelper.trackDisplay(firstSegment);
//
//        var secondSegmentHolder : Sprite = new Sprite();
//        var secondSegment : Sprite = new Sprite();
//        m_animController.addChild(secondSegmentHolder);
//        m_animHelper.trackDisplay(secondSegmentHolder);
//        secondSegmentHolder.addChild(secondSegment);
//        m_animHelper.trackDisplay(secondSegment);
//
//        // Drop data
//        var firstSegmentDropPosition : Point = new Point(result.x - resultModule.totalWidth / 2 + firstModule.totalWidth / 2, result.y);
//        var secondSegmentDropPosition : Point = new Point(firstSegmentDropPosition.x - firstModule.totalWidth / 2 + (firstModule.unitWidth * first.fraction.value) + secondModule.totalWidth / 2, firstSegmentDropPosition.y);
//
//        // Merge data
//        var resultSegmentHolder : Sprite = new Sprite();
//        var resultSegment : Sprite = new Sprite();
//        m_animController.addChild(resultSegmentHolder);
//        m_animHelper.trackDisplay(resultSegmentHolder);
//        resultSegmentHolder.addChild(resultSegment);
//        m_animHelper.trackDisplay(resultSegment);
//
//        // Equation Data
//        var equationCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, equationCenter, finalFirstFraction, " + ", finalSecondFraction, resultFraction, textColor, textGlowColor);
//        eqData.equationCenter = new Point(eqData.equationCenter.x - eqData.resultValueNR.width / 2 - eqData.equalsSymbolText.width - eqData.secondValueNR.width / 2, eqData.equationCenter.y);
//
//        // Simplification
//        var doSimplify : Bool = !resultFraction.isSimplified;
//        var simplifiedResultFraction : CgsFraction = resultFraction.clone();
//        simplifiedResultFraction.simplify();
//        var simplifiedResult : CgsFractionView = result.clone();
//        simplifiedResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//        simplifiedResult.visible = false;
//        simplifiedResult.redraw(true);
//        simplifiedResult.x = result.x;
//        simplifiedResult.y = result.y;
//        m_animHelper.trackFractionView(simplifiedResult);
//        m_animController.addChild(simplifiedResult);
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_POSITION);
//        var positionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_POSITION, position_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        positionStep.addTween(0, new GTween(first, position_unitDuration, {
//                    x : newFirstPosition.x,
//                    y : newFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(second, position_unitDuration, {
//                    x : newSecondPosition.x,
//                    y : newSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        if (doChangeDenom)
//        {
//            var changeDenom_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DELAY_AFTER_CHANGE_DENOM);
//            var changeDenom_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_CHANGE_DENOM);
//            var changeDenom_durationPerTick : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_CHANGE_DENOM_PER_TICK);
//            var changeDenom_maxDuration_firstSegment : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX);
//            var changeDenom_minDurationPerTick : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_CHANGE_DENOM_PER_TICK_MIN);
//
//            /**
//				 * Change first fraction's denominator
//				**/
//
//            var changeFirstDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_FIRST_DENOMINATOR, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//
//            // Setup callback
//            changeFirstDenomStep.addCallback(0, prepForChangeFirstDenominator, null, prepForChangeFirstDenominator_reverse);
//            changeFirstDenomStep.addCallback(0, prepForChangeSecondDenominator, null, prepForChangeSecondDenominator_reverse);
//
//            // Set timing values
//            var firstDenom_pulseMultiplier_startTime : Float = .1;  // A little delay to ensure the prepForChangeDenominator happens first
//            var firstDenom_showMultiplier_startTime : Float = firstDenom_pulseMultiplier_startTime + changeDenom_unitDuration / 2;
//            var firstDenom_moveMultiplier_startTime : Float = firstDenom_showMultiplier_startTime + .1;
//            var firstDenom_changeFirstSegment_startTime : Float = firstDenom_moveMultiplier_startTime + changeDenom_unitDuration / 2;
//            var firstDenom_changeFirstSegmentDuration : Float = Math.min(changeDenom_durationPerTick * numTicksPerFirstSegment, changeDenom_maxDuration_firstSegment);
//            var firstDenom_changeOtherSegments_startTime : Float = firstDenom_changeFirstSegment_startTime + firstDenom_changeFirstSegmentDuration + changeDenom_unitDuration / 2;
//            var firstDenom_changeOtherSegmentDuration : Float = Math.max(firstDenom_changeFirstSegmentDuration / 2, changeDenom_minDurationPerTick * numTicksPerFirstSegment) * (numOtherFirstSegmentGroups + 1);  // + 1 is for moving the roaming multiplier
//            var firstDenom_fadePartOne_startTime : Float = firstDenom_changeOtherSegments_startTime + firstDenom_changeOtherSegmentDuration;
//            var firstDenom_fadePartTwo_startTime : Float = firstDenom_fadePartOne_startTime + changeDenom_unitDuration / 2;
//
//            // Pulse and move roaming multiplier
//            changeFirstDenomStep.addTweenSet(firstDenom_pulseMultiplier_startTime, FVEmphasis.computeNRPulseTweens(secondDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, 1, 1.5, false, true));
//            var groupPoint : Point = firstDenomData.computedMultiplierPositions[0];
//            changeFirstDenomStep.addCallback(firstDenom_showMultiplier_startTime, showFirstMultiplier, null, showFirstMultiplier_reverse);
//            changeFirstDenomStep.addTween(firstDenom_moveMultiplier_startTime, new GTween(firstDenomData.multiplierHolder, changeDenom_unitDuration / 2, {
//                        x : groupPoint.x,
//                        y : groupPoint.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Handle changing ticks of the first segment rectangle
//            currTickStartTime = firstDenom_changeFirstSegment_startTime;
//            firstTicksFadeDuration = firstDenom_changeFirstSegmentDuration / numTicksPerFirstSegment;
//            for (tickIndex in 0...numTicksPerFirstSegment)
//            {
//                var tickAtIndex : Sprite = firstDenomData.segments[tickIndex];
//                changeFirstDenomStep.addTweenSet(currTickStartTime, StripChangeDenomData.animation_pulseInBlock(tickAtIndex, firstDenomData.multiplierHolder, firstTicksFadeDuration));
//                currTickStartTime += firstTicksFadeDuration;
//            }
//
//            // Handle changing ticks of all the other segment rectangles
//            currTickStartTime = firstDenom_changeOtherSegments_startTime;
//            otherTicksFadeDuration = firstDenom_changeOtherSegmentDuration / (numOtherFirstSegments + numOtherFirstSegmentGroups);  // + groups is for moving the roaming multiplier
//            currSegmentGroupIndex = 1;
//            for (tickIndex in numTicksPerFirstSegment...firstDenomData.segments.length)
//            {
//                // Move multiplier
//                if (tickIndex % numTicksPerFirstSegment == 0)
//                {
//                    groupPoint = firstDenomData.computedMultiplierPositions[currSegmentGroupIndex];
//                    changeFirstDenomStep.addTween(currTickStartTime, new GTween(firstDenomData.multiplierHolder, otherTicksFadeDuration, {
//                                x : groupPoint.x,
//                                y : groupPoint.y
//                            }, {
//                                ease : Sine.easeInOut
//                            }));
//                    currTickStartTime += otherTicksFadeDuration;
//                    currSegmentGroupIndex++;
//                }
//
//                // Pulse segment
//                tickAtIndex = firstDenomData.segments[tickIndex];
//                changeFirstDenomStep.addTweenSet(currTickStartTime, StripChangeDenomData.animation_pulseInBlock(tickAtIndex, firstDenomData.multiplierHolder, otherTicksFadeDuration));
//                currTickStartTime += otherTicksFadeDuration;
//            }
//
//            // Fade/pulse multiplier
//            changeFirstDenomStep.addTween(firstDenom_fadePartOne_startTime, new GTween(firstDenomData.multiplierHolder, changeDenom_unitDuration / 4, {
//                        alpha : 0,
//                        x : firstDenom_eqData.secondValueNR_equationPosition.x,
//                        y : firstDenom_eqData.secondValueNR_equationPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeFirstDenomStep.addTweenSet(firstDenom_fadePartOne_startTime, EquationData.animationEquationInline_phaseOne(firstDenom_eqData, changeDenom_unitDuration / 2));
//
//            // Fade/pulse result
//            changeFirstDenomStep.addTweenSet(firstDenom_fadePartTwo_startTime, EquationData.animationEquationInline_phaseTwo(firstDenom_eqData, changeDenom_unitDuration / 2));
//
//            /**
//				 * Change second fraction's denominator
//				**/
//
//            var changeSecondDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_SECOND_DENOMINATOR, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//
//            // Set timing values
//            var secondDenom_pulseMultiplier_startTime : Float = 0;
//            var secondDenom_showMultiplier_startTime : Float = secondDenom_pulseMultiplier_startTime + changeDenom_unitDuration / 2;
//            var secondDenom_moveMultiplier_startTime : Float = secondDenom_showMultiplier_startTime + .1;
//            var secondDenom_changeFirstSegment_startTime : Float = secondDenom_moveMultiplier_startTime + changeDenom_unitDuration / 2;
//            var secondDenom_changeFirstSegmentDuration : Float = Math.min(changeDenom_durationPerTick * numTicksPerSecondSegment, changeDenom_maxDuration_firstSegment);
//            var secondDenom_changeOtherSegments_startTime : Float = secondDenom_changeFirstSegment_startTime + secondDenom_changeFirstSegmentDuration + changeDenom_unitDuration / 2;
//            var secondDenom_changeOtherSegmentDuration : Float = Math.max(secondDenom_changeFirstSegmentDuration / 2, changeDenom_minDurationPerTick * numTicksPerSecondSegment) * (numOtherSecondSegmentGroups + 1);  // + 1 is for moving the roaming multiplier
//            var secondDenom_fadePartOne_startTime : Float = secondDenom_changeOtherSegments_startTime + secondDenom_changeOtherSegmentDuration;
//            var secondDenom_fadePartTwo_startTime : Float = secondDenom_fadePartOne_startTime + changeDenom_unitDuration / 2;
//
//            // Pulse and move roaming multiplier
//            changeSecondDenomStep.addTweenSet(secondDenom_pulseMultiplier_startTime, FVEmphasis.computeNRPulseTweens(firstDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, 1, 1.5, false, true));
//            groupPoint = secondDenomData.computedMultiplierPositions[0];
//            changeSecondDenomStep.addCallback(secondDenom_showMultiplier_startTime, showSecondMultiplier, null, showSecondMultiplier_reverse);
//            changeSecondDenomStep.addTween(secondDenom_moveMultiplier_startTime, new GTween(secondDenomData.multiplierHolder, changeDenom_unitDuration / 2, {
//                        x : groupPoint.x,
//                        y : groupPoint.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Handle changing ticks of the first segment rectangle
//            var currTickStartTime : Float = secondDenom_changeFirstSegment_startTime;
//            var firstTicksFadeDuration : Float = secondDenom_changeFirstSegmentDuration / numTicksPerSecondSegment;
//            for (tickIndex in 0...numTicksPerSecondSegment)
//            {
//                // Pulse segment
//                tickAtIndex = secondDenomData.segments[tickIndex];
//                changeSecondDenomStep.addTweenSet(currTickStartTime, StripChangeDenomData.animation_pulseInBlock(tickAtIndex, secondDenomData.multiplierHolder, firstTicksFadeDuration));
//                currTickStartTime += firstTicksFadeDuration;
//            }
//
//            // Handle changing ticks of all the other segment rectangles
//            currTickStartTime = secondDenom_changeOtherSegments_startTime;
//            var otherTicksFadeDuration : Float = secondDenom_changeOtherSegmentDuration / (numOtherSecondSegments + numOtherSecondSegmentGroups);  // + groups is for moving the roaming multiplier
//            var currSegmentGroupIndex : Int = 1;
//            for (tickIndex in numTicksPerSecondSegment...secondDenomData.segments.length)
//            {
//                // Move multiplier
//                if (tickIndex % numTicksPerSecondSegment == 0)
//                {
//                    groupPoint = secondDenomData.computedMultiplierPositions[currSegmentGroupIndex];
//                    changeSecondDenomStep.addTween(currTickStartTime, new GTween(secondDenomData.multiplierHolder, otherTicksFadeDuration, {
//                                x : groupPoint.x,
//                                y : groupPoint.y
//                            }, {
//                                ease : Sine.easeInOut
//                            }));
//                    currTickStartTime += otherTicksFadeDuration;
//                    currSegmentGroupIndex++;
//                }
//
//                // Pulse segment
//                tickAtIndex = secondDenomData.segments[tickIndex];
//                changeSecondDenomStep.addTweenSet(currTickStartTime, StripChangeDenomData.animation_pulseInBlock(tickAtIndex, secondDenomData.multiplierHolder, otherTicksFadeDuration));
//                currTickStartTime += otherTicksFadeDuration;
//            }
//
//            // Move roaming multiplier, Fade/pulse equation multiplier
//            changeSecondDenomStep.addTween(secondDenom_fadePartOne_startTime, new GTween(secondDenomData.multiplierHolder, changeDenom_unitDuration / 4, {
//                        alpha : 0,
//                        x : secondDenom_eqData.secondValueNR_equationPosition.x,
//                        y : secondDenom_eqData.secondValueNR_equationPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeSecondDenomStep.addTweenSet(secondDenom_fadePartOne_startTime, EquationData.animationEquationInline_phaseOne(secondDenom_eqData, changeDenom_unitDuration / 2));
//
//            // Fade/pulse result
//            changeSecondDenomStep.addTweenSet(secondDenom_fadePartTwo_startTime, EquationData.animationEquationInline_phaseTwo(secondDenom_eqData, changeDenom_unitDuration / 2));
//
//            /**
//				 * Consolidate fractions
//				**/
//
//            var consolidateDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CONSOLIDATE_DENOMINATORS, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//
//            /**
//				 * Consolidate first fraction
//				**/
//
//            // Set timing values
//            var firstDenom_emphasize_startTime : Float = 0;
//            var firstDenom_consolidateEquation_startTime : Float = firstDenom_emphasize_startTime + changeDenom_unitDuration / 2;
//            var firstDenom_finalize_startTime : Float = firstDenom_consolidateEquation_startTime + changeDenom_unitDuration / 2;
//
//            // Consolidate equation
//            consolidateDenomStep.addTweenSet(firstDenom_emphasize_startTime, FVEmphasis.computeNRPulseTweens(firstDenom_eqData.resultValueNR, changeDenom_unitDuration / 2, 1, 1.5));
//            consolidateDenomStep.addTweenSet(firstDenom_consolidateEquation_startTime, EquationData.consolidateEquation(firstDenom_eqData, changeDenom_unitDuration / 2, firstDenom_eqData.firstValueNR_equationPosition));
//
//            // Finalize
//            consolidateDenomStep.addCallback(firstDenom_finalize_startTime, changeFirstDenom, null, changeFirstDenom_reverse);
//
//            /**
//				 * Consolidate second fraction
//				**/
//
//            // Set timing values
//            var secondDenom_emphasize_startTime : Float = firstDenom_finalize_startTime + changeDenom_unitDuration / 2;
//            var secondDenom_consolidateEquation_startTime : Float = secondDenom_emphasize_startTime + changeDenom_unitDuration / 2;
//            var secondDenom_finalize_startTime : Float = secondDenom_consolidateEquation_startTime + changeDenom_unitDuration / 2;
//
//            // Consolidate equation
//            consolidateDenomStep.addTweenSet(secondDenom_emphasize_startTime, FVEmphasis.computeNRPulseTweens(secondDenom_eqData.resultValueNR, changeDenom_unitDuration / 2, 1, 1.5));
//            consolidateDenomStep.addTweenSet(secondDenom_consolidateEquation_startTime, EquationData.consolidateEquation(secondDenom_eqData, changeDenom_unitDuration / 2, secondDenom_eqData.firstValueNR_equationPosition));
//
//            // Finalize
//            consolidateDenomStep.addCallback(secondDenom_finalize_startTime, changeSecondDenom, null, changeSecondDenom_reverse);
//
//            m_animHelper.appendStep(changeFirstDenomStep);
//            m_animHelper.appendStep(changeSecondDenomStep);
//            m_animHelper.appendStep(consolidateDenomStep);
//        }
//
//        // Tween drop
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DELAY_AFTER_DROP);
//        var emphasis_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_EMPHASIS);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_DROP);
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, doPeel, null, doPeel_reverse);  // Do peel
//        var emphasizeFirst_startTime : Float = .1;
//        var dropFirst_startTime : Float = emphasizeFirst_startTime + emphasis_unitDuration;
//        var emphasizeSecond_startTime : Float = dropFirst_startTime + drop_unitDuration;
//        var dropSecond_startTime : Float = emphasizeSecond_startTime + emphasis_unitDuration;
//        var dropFirstValue_startTime : Float = dropSecond_startTime + drop_unitDuration;
//        var dropSecondValue_startTime : Float = dropFirstValue_startTime + drop_unitDuration;
//        var showOpStart : Float = dropSecondValue_startTime + drop_unitDuration;
//        dropStep.addTweenSet(emphasizeFirst_startTime, FVEmphasis.computePulseTweens(firstSegment, emphasis_unitDuration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//        dropStep.addTween(dropFirst_startTime, new GTween(firstSegmentHolder, drop_unitDuration, {
//                    x : firstSegmentDropPosition.x,
//                    y : firstSegmentDropPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTweenSet(emphasizeSecond_startTime, FVEmphasis.computePulseTweens(secondSegment, emphasis_unitDuration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//        dropStep.addTween(dropSecond_startTime, new GTween(secondSegmentHolder, drop_unitDuration, {
//                    x : secondSegmentDropPosition.x,
//                    y : secondSegmentDropPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropFirstValue_startTime, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropFirstValue_startTime, new GTween(first, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropSecondValue_startTime, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropSecondValue_startTime, new GTween(second, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(showOpStart, new GTween(eqData.opSymbolText, drop_unitDuration / 2, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(dropStep);
//
//        // Tween Merge
//        var merge_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DELAY_AFTER_MERGE);
//        var merge_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_MERGE);
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, merge_unitDelay, CgsFVConstants.STEP_TYPE_MERGE);
//        var fadeInResultBackboneStart : Float = .1;
//        var fadeInResultValueStart : Float = fadeInResultBackboneStart + merge_unitDuration;
//        var showResultStart : Float = fadeInResultValueStart + merge_unitDuration;
//        var consolidateEquationStart : Float = showResultStart + merge_unitDuration + merge_unitDelay;  // Includes a little delay after the result text is visible
//        var mergeTime : Float = consolidateEquationStart + merge_unitDuration;
//        mergeStep.addTween(fadeInResultBackboneStart, new GTween(result, merge_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTween(fadeInResultValueStart, new GTween(firstSegmentHolder, merge_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTween(fadeInResultValueStart, new GTween(secondSegmentHolder, merge_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTween(fadeInResultValueStart, new GTween(resultSegmentHolder, merge_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTweenSet(showResultStart, EquationData.animationEquationInline_phaseTwo(eqData, merge_unitDuration));
//        mergeStep.addTween(showResultStart, new GTween(resultModule, merge_unitDuration, {
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTweenSet(consolidateEquationStart, EquationData.consolidateEquation(eqData, merge_unitDuration, eqData.resultValueNR_equationPosition));
//        mergeStep.addCallback(mergeTime, doMerge, null, doMerge_reverse);
//        m_animHelper.appendStep(mergeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplification_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DELAY_AFTER_SIMPLIFICATION);
//            var simplification_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_SIMPLIFICATION);
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
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(StripConstants.TIME_ADD_DURATION_UNPOSITION);
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
//        m_animHelper.animate(addComplete, positionStep, unpositionStep);
//
//
//        /**
//			 * State Change Functions
//			**/
//
//        // Prepares for the change denominator step
//        function prepForChangeSecondDenominator() : Void
//        {
//            // Adjust locations for the second fraction equation parts
//            secondDenom_eqData.firstValueNR.x = secondDenom_eqData.firstValueNR_equationPosition.x;
//            secondDenom_eqData.firstValueNR.y = secondDenom_eqData.firstValueNR_equationPosition.y;
//            secondDenom_eqData.opSymbolText.x = secondDenom_eqData.opSymbolText_equationPosition.x;
//            secondDenom_eqData.opSymbolText.y = secondDenom_eqData.opSymbolText_equationPosition.y;
//            secondDenom_eqData.secondValueNR.x = secondDenom_eqData.secondValueNR_equationPosition.x;
//            secondDenom_eqData.secondValueNR.y = secondDenom_eqData.secondValueNR_equationPosition.y;
//            secondDenom_eqData.equalsSymbolText.x = secondDenom_eqData.equalsSymbolText_equationPosition.x;
//            secondDenom_eqData.equalsSymbolText.y = secondDenom_eqData.equalsSymbolText_equationPosition.y;
//            secondDenom_eqData.resultValueNR.x = secondDenom_eqData.resultValueNR_equationPosition.x;
//            secondDenom_eqData.resultValueNR.y = secondDenom_eqData.resultValueNR_equationPosition.y;
//
//            // Adjust visibility and alpha for the second fraction equation parts
//            secondDenom_eqData.firstValueNR.visible = true;
//            secondDenom_eqData.opSymbolText.visible = true;
//            secondDenom_eqData.secondValueNR.visible = true;
//            secondDenom_eqData.equalsSymbolText.visible = true;
//            secondDenom_eqData.resultValueNR.visible = true;
//            secondDenom_eqData.firstValueNR.alpha = 1;
//            secondDenom_eqData.opSymbolText.alpha = 0;
//            secondDenom_eqData.secondValueNR.alpha = 0;
//            secondDenom_eqData.equalsSymbolText.alpha = 0;
//            secondDenom_eqData.resultValueNR.alpha = 0;
//
//            // Adjust visibility of value on second fraction view
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//
//            // Adjust visibility of ticks and holders
//            secondDenomData.segmentHolder.visible = true;
//            for (tickIndex in 0...secondDenomData.segments.length)
//            {
//                tickAtIndex = secondDenomData.segments[tickIndex];
//                tickAtIndex.alpha = 0;
//            }
//        };
//
//        function prepForChangeSecondDenominator_reverse() : Void
//        {
//            // Adjust visibility and alpha for the second fraction
//            secondDenom_eqData.firstValueNR.visible = false;
//            secondDenom_eqData.opSymbolText.visible = false;
//            secondDenom_eqData.secondValueNR.visible = false;
//            secondDenom_eqData.equalsSymbolText.visible = false;
//            secondDenom_eqData.resultValueNR.visible = false;
//
//            // Adjust visibility of value on second fraction view
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//
//            // Adjust visibility of ticks and holders
//            secondDenomData.segmentHolder.visible = false;
//        }  // Shows the second multiplier  ;
//
//
//
//        var showSecondMultiplier : Void->Void = function() : Void
//        {
//            // Adjust location and visibility of second fraction multiplier
//            secondDenomData.multiplierHolder.visible = true;
//            secondDenomData.multiplierHolder.x = newFirstPosition.x + firstModule.valueNRPosition.x;
//            // TODO: Handle line thickness
//            secondDenomData.multiplierHolder.y = newFirstPosition.y + firstModule.valueNRPosition.y + 2 + secondDenomData.multiplierText.height / 2;
//        }
//
//        function showSecondMultiplier_reverse() : Void
//        {
//            secondDenomData.multiplierHolder.visible = false;
//        }  // Finalizes the changing of the denominator of the first fraction  ;
//
//
//
//        var changeSecondDenom : Void->Void = function() : Void
//        {
//            second.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
//
//            // Adjust visibility of second fraction multiplier
//            secondDenomData.multiplierHolder.visible = false;
//
//            // Adjust visibility and alpha for the second fraction equation parts
//            secondDenom_eqData.firstValueNR.visible = false;
//            secondDenom_eqData.opSymbolText.visible = false;
//            secondDenom_eqData.secondValueNR.visible = false;
//            secondDenom_eqData.equalsSymbolText.visible = false;
//            secondDenom_eqData.resultValueNR.visible = false;
//
//            // Adjust visibility of value on second fraction view
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//
//            // Adjust visibility of ticks and holders
//            secondDenomData.segmentHolder.visible = false;
//        }
//
//        function changeSecondDenom_reverse() : Void
//        {
//            second.fraction.init(origSecondFraction.numerator, origSecondFraction.denominator);
//
//            // Adjust visibility of second fraction multiplier
//            secondDenomData.multiplierHolder.visible = true;
//
//            // Adjust visibility and alpha for the second fraction equation parts
//            secondDenom_eqData.firstValueNR.visible = true;
//            secondDenom_eqData.opSymbolText.visible = true;
//            secondDenom_eqData.secondValueNR.visible = true;
//            secondDenom_eqData.equalsSymbolText.visible = true;
//            secondDenom_eqData.resultValueNR.visible = true;
//
//            // Adjust visibility of value on second fraction view
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//
//            // Adjust visibility of ticks and holders
//            secondDenomData.segmentHolder.visible = true;
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
//            firstDenom_eqData.firstValueNR.alpha = 1;
//            firstDenom_eqData.opSymbolText.alpha = 0;
//            firstDenom_eqData.secondValueNR.alpha = 0;
//            firstDenom_eqData.equalsSymbolText.alpha = 0;
//            firstDenom_eqData.resultValueNR.alpha = 0;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//
//            // Adjust visibility of ticks and holders
//            firstDenomData.segmentHolder.visible = true;
//            for (tickIndex in 0...firstDenomData.segments.length)
//            {
//                tickAtIndex = firstDenomData.segments[tickIndex];
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
//            // Adjust visibility of new ticks
//            firstDenomData.segmentHolder.visible = false;
//        }  // Shows the first multiplier  ;
//
//
//
//        var showFirstMultiplier : Void->Void = function() : Void
//        {
//            // Adjust location and visibility of first fraction multiplier
//            firstDenomData.multiplierHolder.visible = true;
//            firstDenomData.multiplierHolder.x = newSecondPosition.x + secondModule.valueNRPosition.x;
//            // TODO: Handle line thickness
//            firstDenomData.multiplierHolder.y = newSecondPosition.y + secondModule.valueNRPosition.y + 2 + firstDenomData.multiplierText.height / 2;
//        }
//
//        function showFirstMultiplier_reverse() : Void
//        {
//            firstDenomData.multiplierHolder.visible = false;
//        }  // Finalizes the changing of the denominator of the first fraction  ;
//
//
//
//        var changeFirstDenom : Void->Void = function() : Void
//        {
//            first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//
//            // Adjust visibility of first fraction multiplier
//            firstDenomData.multiplierHolder.visible = false;
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
//            // Adjust visibility of new ticks
//            firstDenomData.segmentHolder.visible = false;
//        }
//
//        function changeFirstDenom_reverse() : Void
//        {
//            first.fraction.init(origFirstFraction.numerator, origFirstFraction.denominator);
//
//            // Adjust visibility of first fraction multiplier
//            firstDenomData.multiplierHolder.visible = true;
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
//            // Adjust visibility of new ticks
//            firstDenomData.segmentHolder.visible = true;
//        }  // Peels the segment that is being dropped off of the second fraction view  ;
//
//
//
//        var doPeel : Void->Void = function() : Void
//        {
//            // Peel (paint to new and hide old) the value onto the secondSegment
//            firstModule.peelValue(firstSegment);
//            firstSegmentHolder.x = first.x;
//            firstSegmentHolder.y = first.y;
//            firstSegment.x = -firstModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + firstSegment.width / 2;
//            firstSegmentHolder.visible = true;
//
//            // Peel (paint to new and hide old) the value onto the secondSegment
//            secondModule.peelValue(secondSegment);
//            secondSegmentHolder.x = second.x;
//            secondSegmentHolder.y = second.y;
//            secondSegment.x = -secondModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + secondSegment.width / 2;
//            secondSegmentHolder.visible = true;
//
//            // Show result
//            result.visible = true;
//            result.alpha = 0;
//            resultModule.valueNumDisplayAlpha = 0;
//            resultModule.valueTickDisplayAlpha = 0;
//            result.redraw(true);
//
//            // Peel result
//            resultModule.peelValue(resultSegment);
//            resultSegmentHolder.x = result.x;
//            resultSegmentHolder.y = result.y;
//            resultSegment.x = -resultModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + resultSegment.width / 2;
//            resultSegmentHolder.visible = true;
//            resultSegmentHolder.alpha = 0;
//
//            // Hide value NRs of first and second
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//
//            // Adjust locations of fraction value NRs
//            eqData.firstValueNR.x = first.x + firstModule.valueNRPosition.x;
//            eqData.firstValueNR.y = first.y + firstModule.valueNRPosition.y;
//            eqData.opSymbolText.x = eqData.opSymbolText_equationPosition.x;
//            eqData.opSymbolText.y = eqData.opSymbolText_equationPosition.y;
//            eqData.secondValueNR.x = second.x + secondModule.valueNRPosition.x;
//            eqData.secondValueNR.y = second.y + secondModule.valueNRPosition.y;
//            eqData.equalsSymbolText.x = eqData.equalsSymbolText_equationPosition.x;
//            eqData.equalsSymbolText.y = eqData.equalsSymbolText_equationPosition.y;
//            eqData.resultValueNR.x = eqData.resultValueNR_equationPosition.x;
//            eqData.resultValueNR.y = eqData.resultValueNR_equationPosition.y;
//
//            // Adjust alphas and visibility of equation parts
//            eqData.firstValueNR.alpha = 1;
//            eqData.opSymbolText.alpha = 0;
//            eqData.secondValueNR.alpha = 1;
//            eqData.equalsSymbolText.alpha = 0;
//            eqData.resultValueNR.alpha = 0;
//            eqData.firstValueNR.visible = true;
//            eqData.opSymbolText.visible = true;
//            eqData.secondValueNR.visible = true;
//            eqData.equalsSymbolText.visible = true;
//            eqData.resultValueNR.visible = true;
//        }
//
//        function doPeel_reverse() : Void
//        {
//            // Unpeel
//            firstModule.unpeelValue();
//            firstSegmentHolder.visible = false;
//
//            // Unpeel
//            secondModule.unpeelValue();
//            secondSegmentHolder.visible = false;
//
//            // Hide result
//            result.visible = false;
//            resultSegmentHolder.visible = false;
//
//            // Show value NRs of first and second
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function doMerge() : Void
//        {
//            // Remove peeled value
//            firstSegmentHolder.visible = false;
//
//            // Remove peeled value
//            secondSegmentHolder.visible = false;
//
//            // Show result value
//            resultModule.valueNumDisplayAlpha = 1;
//            resultModule.doShowSegment = true;
//            result.redraw(true);
//            resultSegmentHolder.visible = false;
//
//            // Hide first and second
//            first.visible = false;
//            second.visible = false;
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function doMerge_reverse() : Void
//        {
//            // Add peeled value
//            firstSegmentHolder.visible = true;
//
//            // Add peeled value
//            secondSegmentHolder.visible = true;
//
//            // Hide result value
//            resultModule.valueNumDisplayAlpha = 0;
//            resultModule.doShowSegment = false;
//            result.redraw(true);
//            resultSegmentHolder.visible = true;
//
//            // Show first and second
//            first.visible = true;
//            second.visible = true;
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = true;
//            eqData.opSymbolText.visible = true;
//            eqData.secondValueNR.visible = true;
//            eqData.equalsSymbolText.visible = true;
//            eqData.resultValueNR.visible = true;
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
//        var addComplete : Void->Void = function() : Void
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

