package cgs.fractionVisualization.fractionAnimators.pie;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.PieFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.constants.PieConstants;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.NumberRendererFactory;
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
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.EquationData;

/**
	 * 
	 * @author Mike
	 */
class PieSubtractAnimator implements IFractionAnimator
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
        killAnimator();
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
        return CgsFVConstants.PIE_STANDARD_SUBTRACT;
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
//        // generic counter
//        var i : Int;
//
//        // Fraction Views
//        var fractionViews : Array<CgsFractionView> = Reflect.field(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY));
//        var finalPosition : Point = Reflect.field(details, Std.string(CgsFVConstants.RESULT_DESTINATION));
//        var first : CgsFractionView = fractionViews[0];
//        var second : CgsFractionView = fractionViews[1];
//        var firstModule : PieFractionModule = try cast(first.module, PieFractionModule) catch(e:Dynamic) null;
//        var secondModule : PieFractionModule = try cast(second.module, PieFractionModule) catch(e:Dynamic) null;
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
//        var resultFraction : CgsFraction = new CgsFraction(newFirstNumerator - newSecondNumerator, commonDenominator);
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
//        var resultModule : PieFractionModule = (try cast(result.module, PieFractionModule) catch(e:Dynamic) null);
//        resultModule.valueIsAbove = true;
//        result.visible = false;
//        result.redraw(true);
//        m_animHelper.trackFractionView(result);
//        m_animController.addChild(result);
//        m_animController.addChild(first);
//        m_animController.addChild(second);
//
//        // Position data
//        var spanBetweenPieCenters : Float = (firstModule.unitWidth + firstModule.distanceBetweenPies);
//        var origFirstPosition : Point = new Point(first.x, first.y);
//        var origSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2), resultModule.totalWidth / 2);
//        var offsetY : Float = resultModule.unitHeight / 2 + PieConstants.ANIMATION_MARGIN_VERTICAL_NORMAL;
//        var newFirstPosition : Point = new Point(firstModule.totalWidth / 2 - offsetX, -offsetY - firstModule.unitHeight / 2);
//        var newSecondPosition : Point = new Point(secondModule.totalWidth / 2 - offsetX, offsetY + secondModule.unitHeight / 2);
//        result.x = resultModule.totalWidth / 2 - offsetX;
//
//        // Change First Denominator Data
//        var firstDenom_multiplierHolder : Sprite;
//        var firstDenom_multiplier : TextField;
//
//        // Change Second Denominator Data
//        var secondDenom_multiplierHolder : Sprite;
//        var secondDenom_multiplier : TextField;
//
//        // Show Equation Data
//        var showEqData : Array<Dynamic> = getEquationData(finalFirstFraction, " - ", finalSecondFraction, resultFraction, textColor, textGlowColor);
//        var firstValueNR : NumberRenderer = showEqData[0];
//        var minusSymbolText : TextField = showEqData[1];
//        var secondValueNR : NumberRenderer = showEqData[2];
//        var equalsSymbolText : TextField = showEqData[3];
//        var resultValueNR : NumberRenderer = showEqData[4];
//        // Adjust locations
//        var equationCenterX : Float = 0;
//        var equationCenterY : Float = newFirstPosition.y - spanBetweenPieCenters - 40;
//        firstValueNR.x = 0;
//        firstValueNR.y = 0;
//        var firstValueNRFinalPosition : Point = new Point(equationCenterX - secondValueNR.width / 2 - minusSymbolText.width - firstValueNR.width / 2, equationCenterY);
//        minusSymbolText.x = equationCenterX - secondValueNR.width / 2 - minusSymbolText.width;
//        minusSymbolText.y = equationCenterY - minusSymbolText.height / 2;
//        secondValueNR.x = 0;
//        secondValueNR.y = 0;
//        var secondValueNRFinalPosition : Point = new Point(equationCenterX, equationCenterY);
//        equalsSymbolText.x = equationCenterX + secondValueNR.width / 2;
//        equalsSymbolText.y = equationCenterY - equalsSymbolText.height / 2;
//        resultValueNR.x = equationCenterX + secondValueNR.width / 2 + equalsSymbolText.width + resultValueNR.width / 2;
//        resultValueNR.y = equationCenterY;
//
//        // Update ticks - Notice:  No LCD, either multiplies by each other or remains the same
//        var firstScale : Float = ((first.fraction.denominator == second.fraction.denominator)) ? 1 : second.fraction.denominator;
//        var secondScale : Float = ((first.fraction.denominator == second.fraction.denominator)) ? 1 : first.fraction.denominator;
//        var delayOfConsolidation : Float = 1.0;
//
//        // **** END OF PARTIAL SPRITE CALCUATIONS *******************************
//
//        // Drop data
//        var firstFractionRemainder : Float = first.fraction.value - Math.floor(first.fraction.value);
//        var rotationAligningSegments : Float = (1 - firstFractionRemainder) * 360;
//
//        var dropFinalY : Float = newFirstPosition.y;
//
//        // Equation Data
//        var equationCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, equationCenter, finalFirstFraction, " - ", finalSecondFraction, resultFraction, textColor, textGlowColor);
//        eqData.equationCenter = new Point(eqData.equationCenter.x - eqData.resultValueNR.width / 2 - eqData.equalsSymbolText.width - eqData.secondValueNR.width / 2, eqData.equationCenter.y);
//
//        // Simplification
//        var doSimplify : Bool = !resultFraction.isSimplified;
//        var simplifiedResultFraction : CgsFraction = resultFraction.clone();
//        simplifiedResultFraction.simplify();
//        var simplifiedResult : CgsFractionView = result.clone();
//        simplifiedResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//        var simplifiedResultModule : PieFractionModule = (try cast(simplifiedResult.module, PieFractionModule) catch(e:Dynamic) null);
//        simplifiedResult.visible = false;
//        simplifiedResultModule.valueIsAbove = true;
//        simplifiedResult.redraw(true);
//        simplifiedResult.x = result.x;
//        simplifiedResult.y = result.y;
//        m_animHelper.trackFractionView(simplifiedResult);
//        m_animController.addChild(simplifiedResult);
//
//        /*******************************************************************************
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_POSITION);
//
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
//        positionStep.addTween(0, new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(position_unitDuration / 2, moveValueToTop, null, moveValueToTop_reverse);
//        positionStep.addTween(position_unitDuration * (2 / 3), new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//
//        // Change denominator of second fraction
//        if (doChangeDenom)
//        {
//            var changeDenom_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DELAY_AFTER_CHANGE_DENOM);
//
//            var changeDenom_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_CHANGE_DENOM);
//
//            /**
//				 * Consolidate first fraction
//				**/
//            // Change First Denominator Equation Data
//            var firstValueNRPosition : Point = firstModule.getValueNRPosition(true, first.fraction.denominator == 1);
//            var firstDenom_equationPosition : Point = new Point(newFirstPosition.x + firstValueNRPosition.x, newFirstPosition.y + firstValueNRPosition.y);
//            var firstDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, firstDenom_equationPosition, first.fraction, " × ", firstMultiplierFraction, finalFirstFraction, textColor, textGlowColor);
//            firstDenom_eqData.equationCenter = new Point(firstDenom_eqData.equationCenter.x + firstDenom_eqData.firstValueNR.width / 2 + firstDenom_eqData.opSymbolText.width + firstDenom_eqData.secondValueNR.width / 2, firstDenom_eqData.equationCenter.y);
//
//
//            // Get equation data for changing the second denomintor
//            var secondDenom_equationPosition : Point = new Point(newSecondPosition.x + secondModule.valueNRPosition.x, newSecondPosition.y + secondModule.valueNRPosition.y);
//            var secondDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, secondDenom_equationPosition, second.fraction, " × ", secondMultiplierFraction, finalSecondFraction, textColor, textGlowColor);
//            secondDenom_eqData.equationCenter = new Point(secondDenom_eqData.equationCenter.x + secondDenom_eqData.firstValueNR.width / 2 + secondDenom_eqData.opSymbolText.width + secondDenom_eqData.secondValueNR.width / 2, secondDenom_eqData.equationCenter.y);
//
//
//            // Change denominator of first fraction
//
//            // Get multiplier
//            firstDenom_multiplierHolder = new Sprite();
//            var firstDenom_cloneOfSecondValue : NumberRenderer = m_animHelper.createNumberRenderer(second.fraction, textColor, textGlowColor);
//            firstDenom_multiplier = firstDenom_cloneOfSecondValue.cloneDenominator();
//            m_animHelper.trackDisplay(firstDenom_multiplierHolder);
//            m_animHelper.trackDisplay(firstDenom_multiplier);
//            m_animController.addChild(firstDenom_multiplierHolder);
//            var indexOfFirstDenom_multiplierHolder : Float = m_animController.getChildIndex(firstDenom_multiplierHolder);
//
//            firstDenom_multiplierHolder.addChild(firstDenom_multiplier);
//            firstDenom_multiplier.x = -firstDenom_multiplier.width / 2;
//            firstDenom_multiplier.y = -firstDenom_multiplier.height / 2;
//            firstDenom_multiplierHolder.visible = false;
//
//            var firstDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_FIRST_DENOMINATOR, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//
//            // Setup callback
//            firstDenomStep.addCallback(0, prepMovingDenominators, null, prepMovingDenominators);
//            firstDenomStep.addCallback(0, prepForChangeFirstDenominator, null, prepForChangeFirstDenominator_reverse);
//            firstDenomStep.addCallback(0, prepForChangeSecondDenominator, null, prepForChangeSecondDenominator_reverse);
//
//            // Set timing values
//            var firstDenom_pulseMultiplier_startTime : Float = .1;  // A little delay to ensure the prepForChangeDenominator happens first
//            var firstDenom_circumnavigate_startTime : Float = firstDenom_pulseMultiplier_startTime + changeDenom_unitDuration / 2;
//
//            // Pulse and move roaming multiplier
//            firstDenomStep.addTweenSet(firstDenom_pulseMultiplier_startTime, FVEmphasis.computeNRPulseTweens(secondDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, 1, 1.5, false, true));
//            firstDenomStep.addCallback(firstDenom_pulseMultiplier_startTime + (changeDenom_unitDuration / 2), changeVisibility, [firstDenom_multiplierHolder, true], changeVisibility, [firstDenom_multiplierHolder, false]);
//
//            var firstPulseArgs : Array<Dynamic> = pulseNewDenominators(firstModule, firstDenomStep, newFirstPosition, origFirstFraction.denominator, commonDenominator / origFirstFraction.denominator, firstDenom_multiplierHolder, indexOfFirstDenom_multiplierHolder, firstDenom_circumnavigate_startTime, changeDenom_unitDuration);
//            var firstPulseDenominatorsTime : Float = firstPulseArgs[0];
//            var firstPulseSprites : Array<Sprite> = firstPulseArgs[1];
//
//            var firstDenominatorLanding : Point = new Point(firstDenom_eqData.secondValueNR_equationPosition.x, firstDenom_eqData.secondValueNR_equationPosition.y);  // new Point(newSecondPosition.x + secondModule.valueNRPosition.x + secondEquationPositions[2].x, newSecondPosition.y + secondModule.valueNRPosition.y)
//
//            // move denominator into expression
//            firstDenomStep.addTween(firstPulseDenominatorsTime, new GTween(firstDenom_multiplierHolder, changeDenom_unitDuration / 4, {
//                        x : firstDenominatorLanding.x,
//                        y : firstDenominatorLanding.y,
//                        alpha : 0.0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            firstDenomStep.addTweenSet(firstPulseDenominatorsTime + changeDenom_unitDuration / 8, EquationData.animationEquationInline_phaseOne(firstDenom_eqData, changeDenom_unitDuration / 2));
//            firstDenomStep.addTweenSet(firstPulseDenominatorsTime + changeDenom_unitDuration / 8 + changeDenom_unitDuration, EquationData.animationEquationInline_phaseTwo(firstDenom_eqData, changeDenom_unitDuration / 2));
//
//            m_animHelper.appendStep(firstDenomStep);
//
//
//            // Get multiplier
//            secondDenom_multiplierHolder = new Sprite();
//            var secondDenom_cloneOfFirstValue : NumberRenderer = m_animHelper.createNumberRenderer(first.fraction, textColor, textGlowColor);
//            secondDenom_multiplier = secondDenom_cloneOfFirstValue.cloneDenominator();
//            m_animHelper.trackDisplay(secondDenom_multiplierHolder);
//            m_animHelper.trackDisplay(secondDenom_multiplier);
//            m_animController.addChild(secondDenom_multiplierHolder);
//
//            var indexOfSecondDenom_multiplierHolder : Float = m_animController.getChildIndex(secondDenom_multiplierHolder);
//            secondDenom_multiplierHolder.addChild(secondDenom_multiplier);
//            secondDenom_multiplier.x = -secondDenom_multiplier.width / 2;
//            secondDenom_multiplier.y = -secondDenom_multiplier.height / 2;
//            secondDenom_multiplierHolder.visible = false;
//            var secondDenom_pulseMultiplier_startTime : Float = .1;  // A little delay to ensure the prepForChangeDenominator happens first
//            var secondDenom_circumnavigate_startTime : Float = secondDenom_pulseMultiplier_startTime + changeDenom_unitDuration / 2;
//
//            var secondDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_SECOND_DENOMINATOR, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//
//            // Pulse and move roaming multiplier
//            secondDenomStep.addTweenSet(secondDenom_pulseMultiplier_startTime, FVEmphasis.computeNRPulseTweens(firstDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, 1, 1.5, false, true));
//            secondDenomStep.addCallback(secondDenom_pulseMultiplier_startTime + (changeDenom_unitDuration / 2), changeVisibility, [secondDenom_multiplierHolder, true], changeVisibility, [secondDenom_multiplierHolder, false]);
//
//            var secondPulseArgs : Array<Dynamic> = pulseNewDenominators(secondModule, secondDenomStep, newSecondPosition, origSecondFraction.denominator, commonDenominator / origSecondFraction.denominator, secondDenom_multiplierHolder, indexOfSecondDenom_multiplierHolder, secondDenom_circumnavigate_startTime, changeDenom_unitDuration);
//            var secondPulseDenominatorsTime : Float = secondPulseArgs[0];
//            var secondPulseSprites : Array<Sprite> = secondPulseArgs[1];
//
//            var secondDenominatorLanding : Point = new Point(secondDenom_eqData.secondValueNR_equationPosition.x, secondDenom_eqData.secondValueNR_equationPosition.y);  // new Point(newSecondPosition.x + secondModule.valueNRPosition.x + secondEquationPositions[2].x, newSecondPosition.y + secondModule.valueNRPosition.y)
//
//            // move denominator into expression, this one travels farther so not quite as fast (/3 instead of /4)
//            secondDenomStep.addTween(secondPulseDenominatorsTime, new GTween(secondDenom_multiplierHolder, changeDenom_unitDuration / 3, {
//                        x : secondDenominatorLanding.x,
//                        y : secondDenominatorLanding.y,
//                        alpha : 0.0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            secondDenomStep.addTweenSet(secondPulseDenominatorsTime + changeDenom_unitDuration / 6, EquationData.animationEquationInline_phaseOne(secondDenom_eqData, changeDenom_unitDuration / 4));
//            secondDenomStep.addTweenSet(secondPulseDenominatorsTime + changeDenom_unitDuration / 6 + changeDenom_unitDuration, EquationData.animationEquationInline_phaseTwo(secondDenom_eqData, changeDenom_unitDuration / 2));
//
//            m_animHelper.appendStep(secondDenomStep);
//
//
//            /**
//				 * Consolidate fractions
//				**/
//
//            var consolidateDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CONSOLIDATE_DENOMINATORS, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
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
//            // fade out pulsed denonimators
//            consolidateDenomStep.addCallback(secondDenom_finalize_startTime, changeVisibilities, [firstPulseSprites, false], changeVisibilities, [firstPulseSprites, true]);
//            consolidateDenomStep.addCallback(secondDenom_finalize_startTime, changeVisibilities, [secondPulseSprites, false], changeVisibilities, [secondPulseSprites, true]);
//
//            m_animHelper.appendStep(consolidateDenomStep);
//        }  //END doChangeDenom
//
//
//
//        // Parts to drop
//        var firstAllSectors : Array<Sprite> = firstModule.duplicateAllSprites(firstScale);
//        var firstStartSectorIndex : Array<Float> = new Array<Float>();
//        for (i in 0...first.fraction.value)
//        {
//            var index : Float = i * resultFraction.denominator;
//            firstStartSectorIndex.push(index);
//        }
//        // if the fraction is not an integer the number of left over sectors is the total number of sectors minus the last index of a circle start
//        var firstSectorsPartial : Float = ((first.fraction.value == Math.floor(first.fraction.value))) ? 0 : firstAllSectors.length - firstStartSectorIndex[firstStartSectorIndex.length - 1];
//        var firstNumFullCircles : Float = ((firstSectorsPartial == 0)) ? firstStartSectorIndex.length : firstStartSectorIndex.length - 1;
//        //			var firstFullCircles:Vector.<Sprite> = firstModule.duplicateFullCircles( firstScale );
//        var secondFullCircles : Array<Sprite> = secondModule.duplicateFullCircles(secondScale);
//        //			var firstSectors:Vector.<Sprite> = firstModule.duplicatePartialSprites( firstScale );
//        var secondSectors : Array<Sprite> = secondModule.duplicatePartialSprites(secondScale);
//
//
//
//        // Tween drop
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DELAY_AFTER_DROP);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_DROP);
//        var drop_nullifyDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_EMPHASIS);
//
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, doPeel, null, doPeel_reverse);  // Do peel
//        dropStep.addCallback(0, prepFinalEquation, null, prepFinalEquation_reverse);  // Do peel
//        var runningDropTime : Float = 0.1;
//        var runningCenterValue : Float = result.x - ((resultModule.numBaseUnits - 1) / 2 * spanBetweenPieCenters);
//        for (i in 0...firstNumFullCircles)
//        {
//            for (j in 0...resultFraction.denominator)
//            {
//                var indexOfSector : Float = i * resultFraction.denominator + j;
//                m_animController.addChild(Reflect.field(firstAllSectors, Std.string(indexOfSector)));
//                m_animHelper.trackDisplay(Reflect.field(firstAllSectors, Std.string(indexOfSector)));
//                var moveFirstCircles : GTween = new GTween(Reflect.field(firstAllSectors, Std.string(indexOfSector)), drop_unitDuration, {
//                    x : runningCenterValue,
//                    y : result.y,
//                    alpha : 1.0
//                });
//                dropStep.addTween(runningDropTime, moveFirstCircles);
//            }
//            runningCenterValue += spanBetweenPieCenters;
//        }
//        ((runningDropTime != 0 && !Math.isNaN(runningDropTime)) += firstNumFullCircles != 0 && !Math.isNaN(firstNumFullCircles)) ? drop_unitDuration : 0;
//
//        //back up so that second circles co-incide with first circles
//        runningCenterValue -= (spanBetweenPieCenters * secondFullCircles.length);
//
//        for (i in 0...secondFullCircles.length)
//        {
//            m_animController.addChild(secondFullCircles[i]);
//            m_animHelper.trackDisplay(secondFullCircles[i]);
//            var moveSecondCircles : GTween = new GTween(secondFullCircles[i], drop_unitDuration, {
//                x : runningCenterValue,
//                y : result.y,
//                alpha : 1.0
//            });
//            dropStep.addTween(runningDropTime, moveSecondCircles);
//            //Null them out after the move
//            // the outer sprite starts to nullify a split second later than than it's corresponding piece.  This will cause a chase effect.
//            for (j in 0...resultFraction.denominator)
//            {
//                indexOfSector = (firstNumFullCircles - i - 1) * resultFraction.denominator + j;
//                dropStep.addTween(runningDropTime + drop_unitDuration, new GTween(firstAllSectors[indexOfSector], 0.1, {
//                            alpha : 0.0
//                        }));
//            }
//            dropStep.addTweenSet(runningDropTime + drop_unitDuration, FVEmphasis.computeNullifyTweens(secondFullCircles[i], drop_nullifyDuration, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//            runningCenterValue += spanBetweenPieCenters;
//        }
//
//
//        // back up if the second circles have wiped out a bunch of circles
//        runningCenterValue -= (spanBetweenPieCenters * secondFullCircles.length);
//
//        ((runningDropTime != 0 && !Math.isNaN(runningDropTime)) += (secondFullCircles.length)) ? drop_unitDuration * 2 : 0;
//
//        var timingOfFirstSectors : Float = drop_unitDuration / 4;
//        // should start next one before getting previous one
//        var durationOfFirstSectors : Float = timingOfFirstSectors * 2;
//
//        var timingCounter : Float = -1;
//        // do this check for the zero case
//        var startingIndex : Float = ((firstStartSectorIndex.length > 0)) ? firstStartSectorIndex[firstStartSectorIndex.length - 1] : 0;
//        // go from the index of the first circle with partial sectors to the end of the list
//        for (i in  startingIndex ... firstAllSectors.length)
//        {
//            if (firstSectorsPartial == 0)
//            {
//                break;
//            }
//            timingCounter++;
//            var layerIndexOfFirstSector : Float;
//            // establish insertion point for first sector then all other are
//            // inserted at that point (so below each previous)
//            // This prevents sectors from passing under each other
//            if (timingCounter == 0)
//            {
//                m_animController.addChild(firstAllSectors[i]);
//                layerIndexOfFirstSector = m_animController.getChildIndex(firstAllSectors[i]);
//            }
//            else
//            {
//                m_animController.addChildAt(firstAllSectors[i], layerIndexOfFirstSector);
//            }
//            m_animHelper.trackDisplay(firstAllSectors[i]);
//            var moveFirstPartials : GTween = new GTween(firstAllSectors[i], durationOfFirstSectors, {
//                x : runningCenterValue,
//                y : result.y,
//                alpha : 1.0
//            });
//            dropStep.addTween(runningDropTime, moveFirstPartials);
//            runningDropTime += timingOfFirstSectors;
//        }
//        // adjust for the sector that is still moving
//        ((runningDropTime != 0 && !Math.isNaN(runningDropTime)) += (firstAllSectors.length)) ? durationOfFirstSectors : 0;
//
//
//        var timingOfSecondSectors : Float = drop_unitDuration / 4;
//        var durationOfSecondSectors : Float = timingOfSecondSectors * 2;
//
//        var forwardCounter : Float = -1;
//        var layerIndexOfSecondSector : Float;
//        var indexOfFirstSectorToBeNulled : Float = firstAllSectors.length;
//
//        //Exception if first is all whole numbers, Running center has shifted over one.  Need to shift back
//        if (first.fraction.value == Math.ceil(first.fraction.value))
//        {
//            runningCenterValue -= spanBetweenPieCenters;
//        }
//        i = as3hx.Compat.parseInt(secondSectors.length - 1);
//        while (i >= 0)
//        {
//            forwardCounter++;
//            indexOfFirstSectorToBeNulled--;
//            // establish insertion point for first sector then all other are
//            // inserted at that point (so below each previous)
//            // This prevents sectors from passing under each other
//            if (i == secondSectors.length - 1)
//            {
//                m_animController.addChild(secondSectors[i]);
//                layerIndexOfSecondSector = m_animController.getChildIndex(secondSectors[i]);
//            }
//            else
//            {
//                m_animController.addChildAt(secondSectors[i], layerIndexOfSecondSector);
//            }
//            m_animHelper.trackDisplay(secondSectors[i]);
//            var currentRotation : Float = -i * (1 / resultFraction.denominator * 360);
//            var matchingFirstSectorRotation : Float = -((firstAllSectors.length - 1) - forwardCounter) * (1 / resultFraction.denominator * 360);
//            // mod 360 prevents wild spinnning for 19/4 - 1/3
//            var adjustedRotation : Float = (matchingFirstSectorRotation - currentRotation) % 360;
//            var moveSectors : GTween = new GTween(secondSectors[i], durationOfSecondSectors, {
//                x : runningCenterValue,
//                y : result.y,
//                alpha : 1.0,
//                rotation : adjustedRotation
//            });
//            dropStep.addTween(runningDropTime, moveSectors);
//            dropStep.addTween(runningDropTime + durationOfSecondSectors, new GTween(Reflect.field(firstAllSectors, Std.string(indexOfFirstSectorToBeNulled)), 0.1, {
//                        alpha : 0.0
//                    }));
//            dropStep.addTweenSet(runningDropTime + durationOfSecondSectors, FVEmphasis.computeNullifyTweens(secondSectors[i], PieConstants.TIME_SUB_DURATION_EMPHASIS, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//
//            // if you reach the first sector in the last circle, move back one
//            if (firstStartSectorIndex[firstStartSectorIndex.length - 1] == firstAllSectors.length - forwardCounter - 1)
//            {
//                runningCenterValue -= spanBetweenPieCenters;
//                // must skip backwards to proper first Circle Sector to be nulled
//                indexOfFirstSectorToBeNulled -= secondFullCircles.length * result.fraction.denominator;
//            }
//            runningDropTime += timingOfSecondSectors;
//            i--;
//        }
//        // adjust for the sector that is still moving / nullifying
//        ((runningDropTime != 0 && !Math.isNaN(runningDropTime)) += (secondSectors.length)) ? (durationOfSecondSectors + drop_nullifyDuration) : 0;
//
//
//
//        //This ensures that the Fractions travelling across the stage are on top of everything else
//        m_animController.removeChild(eqData.firstValueNR);
//        m_animController.addChild(eqData.firstValueNR);
//        m_animController.removeChild(eqData.secondValueNR);
//        m_animController.addChild(eqData.secondValueNR);
//
//        dropStep.addTween(runningDropTime, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(runningDropTime, new GTween(first, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        runningDropTime += drop_unitDuration;
//        dropStep.addTween(runningDropTime, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(runningDropTime, new GTween(second, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        runningDropTime += drop_unitDuration;
//        dropStep.addTween(runningDropTime, new GTween(eqData.opSymbolText, drop_unitDuration / 2, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        runningDropTime += drop_unitDuration / 2;
//        m_animHelper.appendStep(dropStep);
//
//        // Tween Merge
//        var merge_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DELAY_AFTER_MERGE);
//        var merge_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_MERGE);
//
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, merge_unitDelay, CgsFVConstants.STEP_TYPE_MERGE);
//        var fadeInResultBackboneStart : Float = .1;
//        var fadeInResultSectorsStart : Float = fadeInResultBackboneStart + merge_unitDuration;
//        var fadeInResultValueStart : Float = fadeInResultSectorsStart + merge_unitDuration;
//        var consolidateEquationStart : Float = fadeInResultValueStart + merge_unitDuration;
//        var mergeTime : Float = consolidateEquationStart + merge_unitDuration;
//        mergeStep.addCallback(0, prepMerge, null, prepMerge_reverse);
//
//        mergeStep.addTween(fadeInResultBackboneStart, new GTween(result, merge_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        // fade out everything (whether Full circles or partials)
//        for (i in 0...firstAllSectors.length)
//        {
//            var fadeFirstCircles : GTween = new GTween(firstAllSectors[i], merge_unitDuration, {
//                alpha : 0.0
//            });
//            mergeStep.addTween(fadeInResultSectorsStart, fadeFirstCircles);
//        }
//
//
//        for (i in 0...secondFullCircles.length)
//        {
//            var fadeSecondCircles : GTween = new GTween(secondFullCircles[i], merge_unitDuration, {
//                alpha : 0.0
//            });
//            mergeStep.addTween(fadeInResultSectorsStart, fadeSecondCircles);
//        }
//
//        for (i in 0...secondSectors.length)
//        {
//            var fadeSectors : GTween = new GTween(secondSectors[i], merge_unitDuration, {
//                alpha : 0.0
//            });
//            mergeStep.addTween(fadeInResultSectorsStart, fadeSectors);
//        }
//        mergeStep.addTweenSet(fadeInResultValueStart, EquationData.animationEquationInline_phaseTwo(eqData, drop_unitDuration * (3 / 4)));
//        mergeStep.addTweenSet(consolidateEquationStart, EquationData.consolidateEquation(eqData, merge_unitDuration, eqData.resultValueNR_equationPosition));
//        mergeStep.addCallback(mergeTime, doMerge, null, doMerge_reverse);
//
//        m_animHelper.appendStep(mergeStep);
//
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplification_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_ADD_DELAY_AFTER_SIMPLIFICATION);
//            var simplification_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_ADD_DURATION_SIMPLIFICATION);
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
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_UNPOSITION);
//
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween((doSimplify) ? simplifiedResult : result, unposition_unitDuration, {
//                    x : finalPosition.x,
//                    y : finalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween((doSimplify) ? simplifiedResultModule : resultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addCallback(unposition_unitDuration / 2, moveValueToTop_reverse, null, moveValueToTop);
//        unpositionStep.addCallback(unposition_unitDuration / 2, moveValueToBottom, null, moveValueToBottom_reverse);
//        unpositionStep.addTween(unposition_unitDuration * (2 / 3), new GTween((doSimplify) ? simplifiedResultModule : resultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(unpositionStep);
//        // unpositionStep is now added in animate at end of method
//
//
//        /**
//			 * Completion
//			**/
//
//
//        // Go
//        m_animHelper.animate(addComplete, positionStep, unpositionStep);
//
//
//        /**
//			 * State Change Functions
//			**/
//        // Moves the location of the fraction value of the result module (the view on the bottom) to display underneath the strip
//        function moveValueToBottom() : Void
//        {
//            var aModule : PieFractionModule = (doSimplify) ? simplifiedResultModule : resultModule;
//            aModule.valueIsAbove = false;
//        };
//
//        function moveValueToBottom_reverse() : Void
//        {
//            var aModule : PieFractionModule = (doSimplify) ? simplifiedResultModule : resultModule;
//            aModule.valueIsAbove = true;
//        }  // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the strip  ;
//
//
//
//        var moveValueToTop : Void->Void = function() : Void
//        {
//            firstModule.valueIsAbove = true;
//        }
//
//        var moveValueToTop_reverse : Void->Void = function() : Void
//        {
//            firstModule.valueIsAbove = false;
//        }
//
//        var doPeel : Void->Void = function() : Void
//        {
//            secondModule.doShowSegment = false;
//            firstModule.doShowSegment = false;
//            secondModule.valueNumDisplayAlpha = 0;
//            firstModule.valueNumDisplayAlpha = 0;
//
//            // Place all the first circle sectors (whether part of a full circle or not)
//            // This is a little more complicated because they have to go in the right place
//            var startingFirstCircle : Float = newFirstPosition.x - ((firstModule.numBaseUnits - 1) / 2 * spanBetweenPieCenters);
//            for (i in 0...firstStartSectorIndex.length)
//            {
//                for (j in 0...resultFraction.denominator)
//                {
//                    indexOfSector = i * resultFraction.denominator + j;
//                    // because of this attempts to fill up FULL circles, this breaks out once the last partial circle is fill;
//                    if (indexOfSector >= firstAllSectors.length)
//                    {
//                        break;
//                    }
//                    firstAllSectors[indexOfSector].visible = true;
//                    // Use (firstModule.numBaseUnits-1) instead of math floor to catch when exactly 1 base unit (0 backing adjustments)
//                    firstAllSectors[indexOfSector].x = startingFirstCircle + (spanBetweenPieCenters * i);
//                    firstAllSectors[indexOfSector].y = newFirstPosition.y;
//                }
//            }
//
//
//            var startingSecondCircle : Float = newSecondPosition.x - ((secondModule.numBaseUnits - 1) / 2 * spanBetweenPieCenters);
//            for (i in 0...secondFullCircles.length)
//            {
//                secondFullCircles[i].visible = true;
//                // Use (firstModule.numBaseUnits-1) instead of math floor to catch when exactly 1 base unit (0 backing adjustments)
//                secondFullCircles[i].x = startingSecondCircle + (spanBetweenPieCenters * i);
//                secondFullCircles[i].y = newSecondPosition.y;
//            }
//
//            for (i in 0...secondSectors.length)
//            {
//                secondSectors[i].visible = true;
//                // If no partials, this should not run so edge case of exactly Math.floor( 1.0 ) or 2.0 should not occur.
//                secondSectors[i].x = newSecondPosition.x + Math.floor(second.fraction.value) * (spanBetweenPieCenters / 2);
//                secondSectors[i].y = newSecondPosition.y;
//            }
//        }
//
//        var doPeel_reverse : Void->Void = function() : Void
//        {
//            secondModule.doShowSegment = true;
//            firstModule.doShowSegment = true;
//            secondModule.valueNumDisplayAlpha = 1;
//            firstModule.valueNumDisplayAlpha = 1;
//
//
//            //	For full circles and partials
//
//            for (i in 0...firstAllSectors.length)
//            {
//                firstAllSectors[i].visible = false;
//            }
//
//            for (i in 0...secondFullCircles.length)
//            {
//                secondFullCircles[i].visible = false;
//            }
//
//            //	For Partial Sprites fraction 2
//            for (i in 0...secondSectors.length)
//            {
//                secondSectors[i].visible = false;
//            }
//        }
//
//        var prepFinalEquation : Void->Void = function() : Void
//        {
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
//        function prepFinalEquation_reverse() : Void
//        {
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
//        }  // Place the moving denominators  ;
//
//
//
//
//        function prepMovingDenominators() : Void
//        {
//            // Adjust locations of fraction value NRs
//            firstDenom_multiplierHolder.x = newSecondPosition.x + secondModule.valueNRPosition.x;
//            firstDenom_multiplierHolder.y = newSecondPosition.y + secondModule.valueNRPosition.y + firstDenom_cloneOfSecondValue.lineThickness + firstDenom_multiplier.height / 2;
//
//            secondDenom_multiplierHolder.x = newFirstPosition.x + firstModule.valueNRPosition.x;
//            secondDenom_multiplierHolder.y = newFirstPosition.y + firstModule.valueNRPosition.y + secondDenom_cloneOfFirstValue.lineThickness + secondDenom_multiplier.height / 2;
//
//            // Adjust alphas and visibility of equation parts
//            firstDenom_multiplierHolder.alpha = 1;
//            secondDenom_multiplierHolder.alpha = 1;
//        }  // Show the equation  ;
//
//
//
//        var doEquation : Void->Void = function() : Void
//        {
//            // Adjust locations of fraction value NRs
//            firstValueNR.x = first.x + firstModule.valueNRPosition.x;
//            firstValueNR.y = first.y + firstModule.valueNRPosition.y;
//            secondValueNR.x = second.x + secondModule.valueNRPosition.x;
//            secondValueNR.y = second.y + secondModule.valueNRPosition.y;
//
//            // Adjust alphas and visibility of equation parts
//            firstValueNR.alpha = 1;
//            minusSymbolText.alpha = 0;
//            secondValueNR.alpha = 1;
//            equalsSymbolText.alpha = 0;
//            resultValueNR.alpha = 0;
//            firstValueNR.visible = true;
//            secondValueNR.visible = true;
//            minusSymbolText.visible = true;
//            equalsSymbolText.visible = true;
//            resultValueNR.visible = true;
//        }
//
//        function doEquation_reverse() : Void
//        {
//            // Adjust visibility of equation parts
//            firstValueNR.visible = false;
//            secondValueNR.visible = false;
//            minusSymbolText.visible = false;
//            equalsSymbolText.visible = false;
//            resultValueNR.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function doMerge() : Void
//        {
//            // Hide first and second
//            first.visible = false;
//            second.visible = false;
//
//            // Show result value
//            resultModule.valueNumDisplayAlpha = 1;
//            result.redraw(true);
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
//            // Hide result value
//            resultModule.valueNumDisplayAlpha = 0;
//            result.redraw(true);
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
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function prepMerge() : Void
//        {
//            result.visible = true;
//            // Show result value
//            result.alpha = 0;
//            resultModule.valueNumDisplayAlpha = 0;
//            resultModule.doShowSegment = true;
//            result.redraw(true);
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function prepMerge_reverse() : Void
//        {
//            // Hide result value
//            result.visible = false;
//            resultModule.doShowSegment = false;
//            result.redraw(true);
//        }  // Prepares for the change denominator step  ;
//
//
//
//        var prepForChangeSecondDenominator : Void->Void = function() : Void
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
//        }
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
//        }  // Finalizes the changing of the denominator of the first fraction  ;
//
//
//
//
//        var changeSecondDenom : Void->Void = function() : Void
//        {
//            second.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
//
//            // Adjust visibility of second fraction multiplier
//            secondDenom_multiplierHolder.visible = false;
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
//        }
//
//        function changeSecondDenom_reverse() : Void
//        {
//            second.fraction.init(origSecondFraction.numerator, origSecondFraction.denominator);
//
//            // Adjust visibility of second fraction multiplier
//            secondDenom_multiplierHolder.visible = true;
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
//        }  // Prepares for simplification of result fraction  ;
//
//
//
//        var prepForSimplification : Void->Void = function() : Void
//        {
//            // Show simplified result
//            simplifiedResult.visible = true;
//            simplifiedResult.alpha = 0;
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
//            result.visible = false;
//        }
//
//        function finalizeSimplification_reverse() : Void
//        {
//            // Show simplified result
//            result.visible = true;
//        }  /**
//			 * Completion
//			**/  ;
//
//
//
//
//
//        function addComplete() : Void
//        {
//            if (completeCallback != null)
//            {
//                // Get result view and send it to the game
//                var resultViews : Array<CgsFractionView> = new Array<CgsFractionView>();
//                resultViews.push((doSimplify) ? simplifiedResult : first);
//                endAnimation(resultViews);
//
//                completeCallback(resultViews);
//            }
//            else
//            {
//                endAnimation();
//            }
//        }  // UTIL  ;
//
//
//
//
//
//        var changeEquationVisibility : Array<Dynamic>->Bool->Void = function(equationData : Array<Dynamic>, value : Bool) : Void
//        {
//            var denom_firstValueNR : NumberRenderer = equationData[0];
//            var denom_opSymbolText : TextField = equationData[1];
//            var denom_secondValueNR : NumberRenderer = equationData[2];
//            var denom_equalsSymbolText : TextField = equationData[3];
//            var denom_resultValueNR : NumberRenderer = equationData[4];
//
//            // Adjust visibility and alpha for the second fraction
//            denom_firstValueNR.visible = value;
//            denom_opSymbolText.visible = value;
//            denom_secondValueNR.visible = value;
//            denom_equalsSymbolText.visible = value;
//            denom_resultValueNR.visible = value;
//        }
//
//        var changeVisibility : Sprite->Bool->Void = function(sprite : Sprite, value : Bool) : Void
//        {
//            sprite.visible = value;
//        }
//
//        var changeDenominatorEquation : AnimationStep->Float->Array<Dynamic>->Float->Void = function(step : AnimationStep, multiplier : Float, equationSprites : Array<Dynamic>, startTime : Float) : Void
//        {
//            // Gen variables
//            var ticksPerSegment : Float = multiplier;
//            var denom_firstValueNR : NumberRenderer = equationSprites[0];
//            var denom_opSymbolText : TextField = equationSprites[1];
//            var denom_secondValueNR : NumberRenderer = equationSprites[2];
//            var denom_equalsSymbolText : TextField = equationSprites[3];
//            var denom_resultValueNR : NumberRenderer = equationSprites[4];
//
//            // Set timing values
//            var denom_fadePartOne_startTime : Float = .1;  // A little delay to ensure the prepForChangeSecondDenominator happens first
//            var denom_changeFirstSegment_startTime : Float = denom_fadePartOne_startTime + changeDenom_unitDuration / 2;
//            var denom_changeFirstSegmentDuration : Float = Math.min(m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_CHANGE_DENOM_PER_TICK) * ticksPerSegment,
//                    m_animHelper.computeScaledTime(PieConstants.TIME_SUB_DURATION_CHANGE_DENOM_TICKS_MAX)
//            );
//            var denom_fadePartTwo_startTime : Float = denom_changeFirstSegment_startTime + denom_changeFirstSegmentDuration + changeDenom_unitDuration;
//
//            // Fade/pulse multiplier
//            step.addTween(denom_fadePartOne_startTime, new GTween(denom_opSymbolText, changeDenom_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            step.addTween(denom_fadePartOne_startTime, new GTween(denom_secondValueNR, changeDenom_unitDuration / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            step.addTween(denom_fadePartOne_startTime + changeDenom_unitDuration / 4, new GTween(denom_secondValueNR, changeDenom_unitDuration / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Fade/pulse result in equation
//            step.addTween(startTime, new GTween(denom_equalsSymbolText, changeDenom_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            step.addTween(startTime, new GTween(denom_resultValueNR, changeDenom_unitDuration / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            step.addTween(startTime + changeDenom_unitDuration / 4, new GTween(denom_resultValueNR, changeDenom_unitDuration / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//
//        var pulseNewDenominators : PieFractionModule->AnimationStep->Point->Float->Float->Sprite->Float->Float->Float->Array<Dynamic> = function(module : PieFractionModule, step : AnimationStep, position : Point, currentDenom : Float, partitionsPerDenom : Float, movingDenominator : Sprite, indexMovingDenominator : Float, startAtTime : Float = 0, unitDuration : Float = 1) : Array<Dynamic>
//        {
//            var paramsForSprites : Dynamic = null;  // example: {foregroundColor:0xffffff, tickColor: 0x6600cc };
//            var allSprites : Array<Sprite> = module.duplicateAllSprites(partitionsPerDenom, paramsForSprites, true, true);
//            var partitionFadeInAndPulseTween : GTween;
//            var partitionBackToSizeTween : GTween;
//
//            var partitionTime : Float = unitDuration / 4;
//            var moveTime : Float = unitDuration / 4;
//            var whichSet : Float = 0;
//            var cumulativeTime : Float = startAtTime;
//            for (i in 0...allSprites.length)
//            {
//                // index below is incremented so that last sprite will be on top but below pulsing denominator
//                m_animController.addChildAt(allSprites[i], indexMovingDenominator);  //Adds to display list, to be seen
//                indexMovingDenominator++;
//                m_animHelper.trackDisplay(allSprites[i]);  //For garbage clean up
//                allSprites[i].visible = false;
//                allSprites[i].alpha = 1.0;
//
//                allSprites[i].x = position.x + module.centerOffsetFor((i + 1) / (partitionsPerDenom * currentDenom));
//                allSprites[i].y = position.y;
//
//                whichSet = Math.floor(i / partitionsPerDenom);
//                // pause at each grouping to move
//                if (i % partitionsPerDenom == 0)
//                {
//                    // this will land at the middle of the original denominator
//                    var locationForDenominator : Point = module.labelLocation(whichSet + 1, currentDenom, new Point(allSprites[i].x, allSprites[i].y), 1.3);
//                    // On very first pass, expand movement delay to allow the denominator to get to the pie.
//                    var extraTimeFactor : Float = 1;
//                    var extraWaitTime : Float = 0;
//                    if (i == 0)
//                    {
//                        extraTimeFactor = 3;
//                    }
//                    // after the first sets of pulses, provide another short pause, and double up the speed
//                    if (i == partitionsPerDenom)
//                    {
//                        extraWaitTime = moveTime;
//                        partitionTime = partitionTime / 2;
//                    }
//                    var moveDenominator : GTween = new GTween(movingDenominator, moveTime * extraTimeFactor, {
//                        x : locationForDenominator.x,
//                        y : locationForDenominator.y
//                    }, {
//                        ease : Sine.easeInOut
//                    });
//                    step.addTween(cumulativeTime + extraWaitTime, moveDenominator);
//                    cumulativeTime += (moveTime * extraTimeFactor) + extraWaitTime;
//                }
//                // for rest of partitions, make it just a little bit faster
//                if (i == partitionsPerDenom)
//                {
//                    partitionTime = unitDuration / 5;
//                }
//
//                step.addCallback(cumulativeTime, changeVisibility, [allSprites[i], true],
//                        changeVisibility, [allSprites[i], false]
//            );
//
//                step.addTweenSet(cumulativeTime, FVEmphasis.computePulseTweens(movingDenominator, partitionTime, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//                step.addTweenSet(cumulativeTime, FVEmphasis.computePulseTweens(allSprites[i], partitionTime, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//                cumulativeTime += partitionTime;
//            }
//            var timeNeededForCallback : Float = cumulativeTime;
//
//
//            return [timeNeededForCallback, allSprites];
//        }
//
//        var changeVisibilities : Array<Sprite>->Bool->Void = function(sprites : Array<Sprite>, visible : Bool) : Void
//        {
//            for (i in 0...sprites.length)
//            {
//                sprites[i].visible = visible;
//            }
//        }
//    }
//    private function createNumberRenderer(aFraction : CgsFraction, textColor : Int, textGlowColor : Int) : NumberRenderer
//    {
//        var result : NumberRenderer = NumberRendererFactory.getInstance().getNumberRendererInstance();
//        result.lineThickness = 2;
//        result.init(aFraction);
//        result.setTextColor(textColor);
//        result.lineColor = textColor;
//        result.glowColor = textGlowColor;
//        result.showIntegerAsFraction = false;
//        m_animHelper.trackDisplay(result);
//        result.render();
//        return result;
//    }
//
//    private function createTextField(aText : String, textColor : Int, textGlowColor : Int) : TextField
//    {
//        var resultTextFormat : TextFormat = new TextFormat("Cabin", GenConstants.DEFAULT_TEXT_FONT_SIZE, textColor, true);
//        var resultText : TextField = new TextField();
//        resultText.embedFonts = true;
//        resultText.defaultTextFormat = resultTextFormat;
//        resultText.text = aText;
//        resultText.width = resultText.textWidth + 3;
//        resultText.height = resultText.textHeight + 3;
//        resultText.selectable = false;
//        resultText.border = false;
//        resultText.background = false;
//        resultText.multiline = false;
//        resultText.autoSize = TextFieldAutoSize.CENTER;
//        m_animHelper.trackDisplay(resultText);
//        return resultText;
//    }
//
//    private function getEquationData(firstFracton : CgsFraction, operationText : String, secondFraction : CgsFraction, resultFraction : CgsFraction, textColor : Int, textGlowColor : Int) : Array<Dynamic>
//    {
//        // Setup Number Renderer for first fraction
//        var firstValueNR : NumberRenderer = createNumberRenderer(firstFracton, textColor, textGlowColor);
//        m_animController.addChild(firstValueNR);
//        // Setup text field for op
//        var opSymbolText : TextField = createTextField(operationText, textColor, textGlowColor);
//        m_animController.addChild(opSymbolText);
//        // Setup Number Renderer for second fraction
//        var secondValueNR : NumberRenderer = createNumberRenderer(secondFraction, textColor, textGlowColor);
//        m_animController.addChild(secondValueNR);
//        // Setup text field for =
//        var equalsSymbolText : TextField = createTextField(" = ", textColor, textGlowColor);
//        m_animController.addChild(equalsSymbolText);
//        // Setup Number Renderer for result fraction
//        var resultValueNR : NumberRenderer = createNumberRenderer(resultFraction, textColor, textGlowColor);
//        m_animController.addChild(resultValueNR);
//
//        // Visibility
//        firstValueNR.visible = false;
//        opSymbolText.visible = false;
//        secondValueNR.visible = false;
//        equalsSymbolText.visible = false;
//        resultValueNR.visible = false;
//
//        return [firstValueNR, opSymbolText, secondValueNR, equalsSymbolText, resultValueNR];
//    }
//
//    private function positionEquationData(equationData : Array<Dynamic>, frac : CgsFractionView, fractionPosition : Point) : Array<Point>
//    {
//        var fracModule : PieFractionModule = try cast(frac.module, PieFractionModule) catch(e:Dynamic) null;
//        // Change First Denominator Data
//        var denom_firstValueNR : NumberRenderer;
//        var denom_opSymbolText : TextField;
//        var denom_secondValueNR : NumberRenderer;
//        var denom_equalsSymbolText : TextField;
//        var denom_resultValueNR : NumberRenderer;
//        var denom_firstValueNR_startPosition : Point;
//        var denom_opSymbolText_startPosition : Point;
//        var denom_secondValueNR_startPosition : Point;
//        var denom_equalsSymbolText_startPosition : Point;
//        var denom_resultValueNR_startPosition : Point;
//        var denom_resultValueNR_finalPosition : Point;
//
//        // Get parts of the equations
//        denom_firstValueNR = equationData[0];
//        denom_opSymbolText = equationData[1];
//        denom_secondValueNR = equationData[2];
//        denom_equalsSymbolText = equationData[3];
//        denom_resultValueNR = equationData[4];
//
//        // Compute positioning
//        denom_firstValueNR_startPosition = new Point(fractionPosition.x + fracModule.valueNRPosition.x,
//                fractionPosition.y + fracModule.valueNRPosition.y);
//        denom_opSymbolText_startPosition = new Point(denom_firstValueNR_startPosition.x + denom_firstValueNR.width / 2,
//                denom_firstValueNR_startPosition.y - denom_opSymbolText.height / 2);
//        denom_secondValueNR_startPosition = new Point(denom_opSymbolText_startPosition.x + denom_opSymbolText.width + denom_secondValueNR.width / 2,
//                denom_firstValueNR_startPosition.y);
//        denom_equalsSymbolText_startPosition = new Point(denom_secondValueNR_startPosition.x + denom_secondValueNR.width / 2,
//                denom_firstValueNR_startPosition.y - denom_equalsSymbolText.height / 2);
//        denom_resultValueNR_startPosition = new Point(denom_equalsSymbolText_startPosition.x + denom_equalsSymbolText.width + denom_resultValueNR.width / 2,
//                denom_firstValueNR_startPosition.y);
//        var firstResultNRPosition : Point = fracModule.getValueNRPosition(fracModule.valueIsAbove, denom_resultValueNR.fraction.denominator == 1);
//        denom_resultValueNR_finalPosition = new Point(fractionPosition.x + firstResultNRPosition.x,
//                fractionPosition.y + firstResultNRPosition.y);
//
//        var points : Array<Point> = new Array<Point>();
//        points.push(denom_firstValueNR_startPosition);
//        points.push(denom_opSymbolText_startPosition);
//        points.push(denom_secondValueNR_startPosition);
//        points.push(denom_equalsSymbolText_startPosition);
//        points.push(denom_resultValueNR_startPosition);
//        points.push(denom_resultValueNR_finalPosition);
//        return points;
    }
}
