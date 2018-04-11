package cgs.fractionVisualization.fractionAnimators.numberline;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.LineFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.util.EquationData;
import cgs.fractionVisualization.constants.NumberlineConstants;
import cgs.fractionVisualization.util.FVEmphasis;
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

/**
	 * ...
	 * @author Rich
	 */
class NumberlineAddProceduralAnimator implements IFractionAnimator
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
        return CgsFVConstants.NUMBERLINE_PROCEDURAL_ADD;
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

        //TODO fix animation
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
//        var firstModule : LineFractionModule = try cast(first.module, LineFractionModule) catch(e:Dynamic) null;
//        var secondModule : LineFractionModule = try cast(second.module, LineFractionModule) catch(e:Dynamic) null;
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
//        var resultModule : LineFractionModule = (try cast(result.module, LineFractionModule) catch(e:Dynamic) null);
//        resultModule.valueNumDisplayAlpha = 0;
//        resultModule.doShowSegment = false;
//        result.x = 0;
//        result.y = 0;
//        result.visible = false;
//        result.redraw(true);
//        m_animHelper.trackFractionView(result);
//        m_animController.addChild(result);
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2);
//        var midpointY : Float = -resultModule.unitHeight / 2 - (NumberlineConstants.TICK_EXTENSION_DISTANCE * 2) - (NumberRenderer.MAX_BOX_HEIGHT * (3 / 2)) - secondModule.unitHeight - NumberlineConstants.TICK_EXTENSION_DISTANCE - NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//        var midpointToFractionDist : Float = NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL + NumberlineConstants.TICK_EXTENSION_DISTANCE + firstModule.unitHeight;
//        var newFirstPosition : Point = new Point(-resultModule.totalWidth / 2 + firstModule.totalWidth / 2, midpointY - midpointToFractionDist);
//        var newSecondPosition : Point = new Point(-resultModule.totalWidth / 2 + secondModule.totalWidth / 2, midpointY + midpointToFractionDist);
//
//        // Get equation data for changing the first denomintor
//        var firstDenom_equationPosition : Point = new Point(newFirstPosition.x + firstModule.valueNRPosition.x, newFirstPosition.y + firstModule.valueNRPosition.y);
//        var firstDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, firstDenom_equationPosition, first.fraction, " × ", firstMultiplierFraction, finalFirstFraction, textColor, textGlowColor);
//        firstDenom_eqData.equationCenter = new Point(firstDenom_eqData.equationCenter.x + firstDenom_eqData.firstValueNR.width / 2 + firstDenom_eqData.opSymbolText.width + firstDenom_eqData.secondValueNR.width / 2, firstDenom_eqData.equationCenter.y);
//
//        // Get equation data for changing the second denomintor
//        var secondValueNRPosition : Point = secondModule.getValueNRPosition(false, second.fraction.denominator == 1);
//        var secondDenom_equationPosition : Point = new Point(newSecondPosition.x + secondValueNRPosition.x, newSecondPosition.y + secondValueNRPosition.y);
//        var secondDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, secondDenom_equationPosition, second.fraction, " × ", secondMultiplierFraction, finalSecondFraction, textColor, textGlowColor);
//        secondDenom_eqData.equationCenter = new Point(secondDenom_eqData.equationCenter.x + secondDenom_eqData.firstValueNR.width / 2 + secondDenom_eqData.opSymbolText.width + secondDenom_eqData.secondValueNR.width / 2, secondDenom_eqData.equationCenter.y);
//
//        // Setup alignment lines
//        var doShowAlignment : Bool = origFirstFraction.numerator != 0;
//        var secondAlignedX : Float = newSecondPosition.x + firstModule.valueWidth;
//        var firstAlignLine_startY : Float = -midpointToFractionDist + firstModule.valueNRPosition.y + NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var secondAlignLine_startY : Float = 0;
//        var secondAlignLine_endY : Float = midpointToFractionDist * 2;
//        var firstAlignLine : Sprite = m_animHelper.createDashedLine(firstAlignLine_startY, secondAlignLine_endY);
//        var secondAlignLine : Sprite = m_animHelper.createDashedLine(secondAlignLine_startY, secondAlignLine_endY);
//        firstAlignLine.x = newFirstPosition.x + firstModule.valueOffsetX;
//        secondAlignLine.x = newSecondPosition.x - secondModule.totalWidth / 2;
//        firstAlignLine.y = midpointY;
//        secondAlignLine.y = midpointY;
//        firstAlignLine.visible = false;
//        secondAlignLine.visible = false;
//        m_animController.addChild(firstAlignLine);
//        m_animController.addChild(secondAlignLine);
//
//        // First alignment line mask
//        var firstAlignLineMaskHeight : Float = firstAlignLine.height + 6;
//        var firstAlignLineMask : Sprite = m_animHelper.createMask(firstAlignLine, 10, firstAlignLineMaskHeight);
//        firstAlignLineMask.x = firstAlignLine.x;
//        firstAlignLineMask.y = midpointY + firstAlignLine_startY - firstAlignLineMaskHeight / 2 - 1;
//        var firstAlignLineMask_finalY : Float = firstAlignLineMask.y + firstAlignLineMaskHeight;
//        m_animController.addChild(firstAlignLineMask);
//
//        // Second alignment line mask
//        var secondAlignLineMaskHeight : Float = secondAlignLine.height + 6;
//        var secondAlignLineMask : Sprite = m_animHelper.createMask(secondAlignLine, 10, secondAlignLineMaskHeight);
//        secondAlignLineMask.x = secondAlignLine.x;
//        secondAlignLineMask.y = midpointY + secondAlignLine_endY + secondAlignLineMaskHeight / 2 + 1;
//        var secondAlignLineMask_finalY : Float = secondAlignLineMask.y - secondAlignLineMaskHeight;
//        m_animController.addChild(secondAlignLineMask);
//
//        // First's segment for alignment View
//        var firstSegmentHolder : Sprite = new Sprite();
//        var firstSegment : Sprite = new Sprite();
//        m_animController.addChild(firstSegmentHolder);
//        m_animHelper.trackDisplay(firstSegmentHolder);
//        firstSegmentHolder.addChild(firstSegment);
//        m_animHelper.trackDisplay(firstSegment);
//
//        // Second's unit NR for scaling
//        var secondUnitAlignNR : NumberRenderer = m_animHelper.createNumberRenderer(new CgsFraction(0, 1), textColor, textGlowColor);
//        secondUnitAlignNR.visible = false;
//        var secondUnitPosition : Point = secondModule.getValueNRPosition(false, true);
//        secondUnitAlignNR.x = newSecondPosition.x - (secondModule.totalWidth / 2);
//        secondUnitAlignNR.y = newSecondPosition.y + secondUnitPosition.y;
//        m_animController.addChild(secondUnitAlignNR);
//
//        // Show Equation Data
//        var eqCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, eqCenter, finalFirstFraction, " + ", finalSecondFraction, resultFraction, textColor, textGlowColor);
//        eqData.equationCenter = new Point(eqData.equationCenter.x - eqData.resultValueNR.width / 2 - eqData.equalsSymbolText.width - eqData.secondValueNR.width / 2, eqData.equationCenter.y);
//
//        // Setup drop line
//        var dropLine_startY : Float = midpointY;
//        var dropLine_endY : Float = resultModule.unitHeight / 2 + NumberlineConstants.TICK_EXTENSION_DISTANCE * 2;
//        var dropLine : Sprite = m_animHelper.createDashedLine(dropLine_startY, dropLine_endY);
//        dropLine.x = result.x + resultModule.valueOffsetX;
//        dropLine.visible = false;
//        m_animController.addChild(dropLine);
//
//        // Drop line mask
//        var dropLineMaskHeight : Float = dropLine.height + 6;
//        var dropLineMask : Sprite = m_animHelper.createMask(dropLine, 10, dropLineMaskHeight);
//        dropLineMask.x = dropLine.x;
//        dropLineMask.y = dropLine_startY - dropLineMaskHeight / 2 - 1;
//        var dropLineMask_finalY : Float = dropLineMask.y + dropLineMaskHeight;
//        m_animController.addChild(dropLineMask);
//
//        // Peel data
//        var secondSegmentHolder : Sprite = new Sprite();
//        var secondSegment : Sprite = new Sprite();
//        m_animController.addChild(secondSegmentHolder);
//        m_animHelper.trackDisplay(secondSegmentHolder);
//        secondSegmentHolder.addChild(secondSegment);
//        m_animHelper.trackDisplay(secondSegment);
//
//        var resultSegmentHolder : Sprite = new Sprite();
//        var resultSegment : Sprite = new Sprite();
//        m_animController.addChild(resultSegmentHolder);
//        m_animHelper.trackDisplay(resultSegmentHolder);
//        resultSegmentHolder.addChild(resultSegment);
//        m_animHelper.trackDisplay(resultSegment);
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
//        var positionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_POSITION, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_POSITION, CgsFVConstants.STEP_TYPE_POSITION);
//        positionStep.addTween(0, new GTween(first, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION, {
//                    x : newFirstPosition.x,
//                    y : newFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(second, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION, {
//                    x : newSecondPosition.x,
//                    y : newSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(firstModule, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION, {
//                    unitNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION, {
//                    unitNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION / 2, moveValueToBottom, null, moveValueToBottom_reverse);
//        positionStep.addTween(NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION * (2 / 3), new GTween(secondModule, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_POSITION / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        // Change Denominator
//        if (doChangeDenom)
//        {
//            var changeDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_DENOMINATORS, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_CHANGE_DENOM, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//            changeDenomStep.addCallback(0, prepForChangeDenom, null, prepForChangeDenom_reverse);
//
//            var firstDenom_fadePartOne_startTime : Float = .1;
//            var firstDenom_fadePartTwo_startTime : Float = firstDenom_fadePartOne_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2;
//            var firstDenom_consolidateEquation_startTime : Float = firstDenom_fadePartTwo_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2;
//            var secondDenom_fadePartOne_startTime : Float = firstDenom_consolidateEquation_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2;
//            var secondDenom_fadePartTwo_startTime : Float = secondDenom_fadePartOne_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2;
//            var secondDenom_consolidateEquation_startTime : Float = secondDenom_fadePartTwo_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2;
//            var changeDenom_finalize_startTime : Float = secondDenom_consolidateEquation_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2;
//
//            // Change denom of first
//            changeDenomStep.addTweenSet(firstDenom_fadePartOne_startTime, EquationData.animationEquationInline_phaseOne(firstDenom_eqData, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2));
//            changeDenomStep.addTweenSet(firstDenom_fadePartTwo_startTime, EquationData.animationEquationInline_phaseTwo(firstDenom_eqData, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2));
//            changeDenomStep.addTweenSet(firstDenom_consolidateEquation_startTime, EquationData.consolidateEquation(firstDenom_eqData, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2, firstDenom_eqData.firstValueNR_equationPosition));
//
//            // Change denom of second
//            changeDenomStep.addTweenSet(secondDenom_fadePartOne_startTime, EquationData.animationEquationInline_phaseOne(secondDenom_eqData, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2));
//            changeDenomStep.addTweenSet(secondDenom_fadePartTwo_startTime, EquationData.animationEquationInline_phaseTwo(secondDenom_eqData, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2));
//            changeDenomStep.addTweenSet(secondDenom_consolidateEquation_startTime, EquationData.consolidateEquation(secondDenom_eqData, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_CHANGE_DENOM / 2, secondDenom_eqData.firstValueNR_equationPosition));
//
//            changeDenomStep.addCallback(changeDenom_finalize_startTime, finalizeChangeDenom, null, finalizeChangeDenom_reverse);
//            m_animHelper.appendStep(changeDenomStep);
//        }
//
//        // Align second fraction
//        if (doShowAlignment)
//        {
//            var alignStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_ALIGN, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_ALIGN, CgsFVConstants.STEP_TYPE_ALIGN);
//            alignStep.addCallback(0, prepForAlign, null, prepForAlign_reverse);
//
//            // Timing
//            var showFirstLineStartTime : Float = .1;
//            var showFirstLinePhaseTwoStart : Float = showFirstLineStartTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN;
//            var pulseSecondValueStartTime : Float = showFirstLinePhaseTwoStart + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN;
//            var showSecondLineStartTime : Float = pulseSecondValueStartTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN;
//            var moveLineStartTime : Float = showSecondLineStartTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN;
//            var hideLineStartTime : Float = moveLineStartTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN;
//            var finalizeAlignTime : Float = hideLineStartTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN / 2;
//
//            // Emphasize first's value, for alignment
//            alignStep.addTweenSet(showFirstLineStartTime, FVEmphasis.computePulseTweens(firstSegment, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//
//            // Drop alignment line
//            alignStep.addTween(showFirstLinePhaseTwoStart, new GTween(firstAlignLineMask, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, {
//                        y : firstAlignLineMask_finalY
//                    }));
//
//            // Show and Pulse second unit
//            alignStep.addTween(pulseSecondValueStartTime, new GTween(secondUnitAlignNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTweenSet(pulseSecondValueStartTime, FVEmphasis.computePulseTweens(secondUnitAlignNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL));
//
//            // Show second alignment line
//            alignStep.addTween(showSecondLineStartTime, new GTween(secondAlignLineMask, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, {
//                        y : secondAlignLineMask_finalY
//                    }));
//
//            // Move second
//            alignStep.addTween(moveLineStartTime, new GTween(second, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, {
//                        x : secondAlignedX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(moveLineStartTime, new GTween(secondAlignLine, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, {
//                        x : firstAlignLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(moveLineStartTime, new GTween(secondAlignLineMask, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, {
//                        x : firstAlignLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(moveLineStartTime, new GTween(secondUnitAlignNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN, {
//                        x : firstAlignLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Hide lines
//            alignStep.addTween(hideLineStartTime, new GTween(firstAlignLine, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(hideLineStartTime, new GTween(secondAlignLine, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(hideLineStartTime, new GTween(secondUnitAlignNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_ALIGN / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            alignStep.addCallback(finalizeAlignTime, finalizeAlign, null, finalizeAlign_reverse);
//            m_animHelper.appendStep(alignStep);
//        }
//
//        // Tween drop
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_DROP, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, prepForDrop, null, prepForDrop_reverse);  // Do peel
//        var drop_showResult_startTime : Float = .1;
//        var drop_moveFirstValue_startTime : Float = drop_showResult_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        var drop_moveSecondValue_startTime : Float = drop_moveFirstValue_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        var drop_emphasis_startTime : Float = drop_moveSecondValue_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        var drop_dropLine_startTime : Float = drop_emphasis_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        var drop_dropSegment_startTime : Float = drop_dropLine_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        var drop_hideLine_startTime : Float = drop_dropSegment_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        var mergeTime : Float = drop_hideLine_startTime + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP;
//        dropStep.addTween(drop_showResult_startTime, new GTween(result, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveFirstValue_startTime, new GTween(eqData.firstValueNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveSecondValue_startTime, new GTween(eqData.opSymbolText, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveSecondValue_startTime, new GTween(eqData.secondValueNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTweenSet(drop_emphasis_startTime, FVEmphasis.computePulseTweens(secondSegment, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//        dropStep.addTween(drop_dropLine_startTime, new GTween(dropLineMask, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    y : dropLineMask_finalY
//                }));
//        dropStep.addTween(drop_dropSegment_startTime, new GTween(resultSegmentHolder, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_hideLine_startTime, new GTween(eqData.equalsSymbolText, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_hideLine_startTime, new GTween(resultModule, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_hideLine_startTime, new GTween(dropLine, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_DROP, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addCallback(mergeTime, doMerge, null, doMerge_reverse);
//        m_animHelper.appendStep(dropStep);
//
//        // Tween fade
//        var fadeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_FADE, CgsFVConstants.STEP_TYPE_FADE);
//        fadeStep.addTween(0, new GTween(first, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(second, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(eqData.firstValueNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(eqData.opSymbolText, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(eqData.secondValueNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(eqData.equalsSymbolText, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(eqData.resultValueNR, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(fadeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplificationStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SIMPLIFICATION, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_SIMPLIFICATION, CgsFVConstants.STEP_TYPE_SIMPLIFICATION);
//            simplificationStep.addCallback(0, prepForSimplification, null, prepForSimplification_reverse);
//            simplificationStep.addTween(.1, new GTween(result, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_SIMPLIFICATION, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addTween(.1, new GTween(simplifiedResult, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_SIMPLIFICATION, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addCallback(.1 + NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_SIMPLIFICATION, finalizeSimplification, null, finalizeSimplification_reverse);
//            m_animHelper.appendStep(simplificationStep);
//        }
//
//        // Final Position
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, NumberlineConstants.TIME_ADD_PROCEDURAL_DELAY_AFTER_UNPOSITION, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween((doSimplify) ? simplifiedResult : result, NumberlineConstants.TIME_ADD_PROCEDURAL_DURATION_UNPOSITION, {
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
//        // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the strip
//        function moveValueToBottom() : Void
//        {
//            secondModule.valueIsAbove = false;
//        };
//
//        function moveValueToBottom_reverse() : Void
//        {
//            secondModule.valueIsAbove = true;
//        }  // Prepares for the change denominator step  ;
//
//
//
//        var prepForChangeDenom : Void->Void = function() : Void
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
//        var prepForChangeDenom_reverse : Void->Void = function() : Void
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
//        }
//
//        var finalizeChangeDenom : Void->Void = function() : Void
//        {
//            // Chagne first value
//            first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
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
//            // Change second value
//            second.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
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
//        function finalizeChangeDenom_reverse() : Void
//        {
//            // Chagne first value
//            first.fraction.init(origFirstFraction.numerator, origFirstFraction.denominator);
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
//            // Change second value
//            second.fraction.init(origSecondFraction.numerator, origSecondFraction.denominator);
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
//        }  // Preps for the scale animation  ;
//
//
//
//        var prepForAlign : Void->Void = function() : Void
//        {
//            // Peel (paint to new and hide old) the value onto the firstSegment
//            firstModule.peelValue(firstSegment);
//            firstSegmentHolder.x = first.x;
//            firstSegmentHolder.y = first.y;
//            firstSegmentHolder.visible = true;
//
//            // Prep NRs
//            secondUnitAlignNR.visible = true;
//            secondUnitAlignNR.alpha = 0;
//
//            // Prep lines
//            firstAlignLine.visible = true;
//            secondAlignLine.visible = true;
//        }
//
//        function prepForAlign_reverse() : Void
//        {
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            // Hide NRs
//            secondUnitAlignNR.visible = false;
//
//            // Hide lines
//            firstAlignLine.visible = false;
//            secondAlignLine.visible = false;
//        }  // Finalizes for the align animation  ;
//
//
//
//        var finalizeAlign : Void->Void = function() : Void
//        {
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            // Hide NRs
//            secondUnitAlignNR.visible = false;
//
//            // Hide lines
//            firstAlignLine.visible = false;
//            secondAlignLine.visible = false;
//        }
//
//        function finalizeAlign_reverse() : Void
//        {
//            firstModule.doShowSegment = false;
//            first.redraw(true);
//            firstSegmentHolder.visible = true;
//
//            // Show NRs
//            secondUnitAlignNR.visible = true;
//
//            // Show lines
//            firstAlignLine.visible = true;
//            secondAlignLine.visible = true;
//        }  // Peels the segment that is being dropped off of the second fraction view  ;
//
//
//
//        var prepForDrop : Void->Void = function() : Void
//        {
//            // Show result
//            result.visible = true;
//            result.alpha = 0;
//            resultModule.doShowSegment = false;
//            resultModule.valueNumDisplayAlpha = 0;
//            result.redraw(true);
//
//            // Adjust locations of equation parts
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
//
//            // Hide value displays on first and second
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//
//            // Peel (paint to new and hide old) the value onto the secondSegment
//            secondModule.peelValue(secondSegment);
//            secondSegmentHolder.x = second.x;
//            secondSegmentHolder.y = second.y;
//            secondSegmentHolder.visible = true;
//
//            // Peel (paint to new and hide old) the value onto the resultSegment
//            resultModule.peelValue(resultSegment);
//            resultSegmentHolder.alpha = 0;
//            resultSegmentHolder.x = result.x;
//            resultSegmentHolder.y = result.y;
//            resultSegmentHolder.visible = true;
//
//            // Show drop line
//            dropLine.visible = true;
//        }
//
//        function prepForDrop_reverse() : Void
//        {
//            // Hide result
//            result.visible = false;
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//
//            // Show value displays on first and second
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//
//            secondModule.unpeelValue();
//            secondSegmentHolder.visible = false;
//
//            resultSegmentHolder.visible = false;
//
//            // Hide drop line
//            dropLine.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function doMerge() : Void
//        {
//            // Remove peeled value
//            secondSegmentHolder.visible = false;
//            secondModule.doShowSegment = true;
//            second.redraw(true);
//
//            // Remove peeled value
//            resultSegmentHolder.visible = false;
//
//            // Update first value
//            resultModule.doShowSegment = true;
//            result.redraw(true);
//
//            // Hide drop line
//            dropLine.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function doMerge_reverse() : Void
//        {
//            // Add peeled value
//            secondSegmentHolder.visible = true;
//            secondModule.doShowSegment = false;
//            second.redraw(true);
//
//            // Add peeled value
//            resultSegmentHolder.visible = true;
//
//            // Update first value
//            resultModule.doShowSegment = false;
//            result.redraw(true);
//
//            // Show drop line
//            dropLine.visible = true;
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

