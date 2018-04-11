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
import cgs.fractionVisualization.constants.NumberlineConstants;
import cgs.fractionVisualization.util.EquationData;
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
class NumberlineAddAnimator implements IFractionAnimator
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
        return CgsFVConstants.NUMBERLINE_STANDARD_ADD;
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
//
//        // Create result fraction view
//        var result : CgsFractionView = first.clone();
//        resultFraction.simplify();  // Simplify now, because we bypass the simplification step by just showing the result at the end.
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
//        var midpointY : Float = -resultModule.unitHeight / 2 - (NumberlineConstants.TICK_EXTENSION_DISTANCE * 2) - (NumberRenderer.MAX_BOX_HEIGHT * (3 / 2)) - secondModule.unitHeight - NumberlineConstants.TICK_EXTENSION_DISTANCE - (NumberRenderer.MAX_BOX_HEIGHT / 2) - NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//        var midpointToFractionDist : Float = NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL + (NumberRenderer.MAX_BOX_HEIGHT / 2) + NumberlineConstants.TICK_EXTENSION_DISTANCE + firstModule.unitHeight;
//        var newFirstPosition : Point = new Point(-resultModule.totalWidth / 2 + firstModule.totalWidth / 2, midpointY - midpointToFractionDist);
//        var newSecondPosition : Point = new Point(-resultModule.totalWidth / 2 + secondModule.totalWidth / 2, midpointY + midpointToFractionDist);
//
//        // Setup alignment lines
//        var doShowAlignment : Bool = origFirstFraction.numerator != 0;
//        var secondAlignedX : Float = newSecondPosition.x + firstModule.valueWidth;
//        var firstAlignLine_startY : Float = -midpointToFractionDist + firstModule.valueNRPosition.y + NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var secondAlignLine_startY : Float = 0;
//        var secondAlignLine_endY : Float = midpointToFractionDist + NumberlineConstants.NUMBER_DISPLAY_MARGIN_INTEGER / 2;
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
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, eqCenter, origFirstFraction, " + ", origSecondFraction, resultFraction, textColor, textGlowColor);
//        eqData.equationCenter = new Point(eqData.equationCenter.x + eqData.secondValueNR.width / 2 + eqData.opSymbolText.width / 2, eqData.equationCenter.y);
//
//        // Setup drop line
//        var dropLine_startY : Float = midpointY + midpointToFractionDist + secondModule.valueNRPosition.y + NumberRenderer.MAX_BOX_HEIGHT / 2;
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
//        /*var doSimplify:Boolean = !resultFraction.isSimplified;
//			var simplifiedResultFraction:CgsFraction = resultFraction.clone();
//			simplifiedResultFraction.simplify();
//			var simplifiedResult:CgsFractionView = result.clone();
//			simplifiedResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//			simplifiedResult.visible = false;
//			simplifiedResult.redraw(true);
//			simplifiedResult.x = 0;
//			simplifiedResult.y = 0;
//			m_animHelper.trackFractionView(simplifiedResult)
//			m_animController.addChild(simplifiedResult);*/
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DURATION_POSITION);
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
//        positionStep.addTween(0, new GTween(firstModule, position_unitDuration, {
//                    unitNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, position_unitDuration, {
//                    unitNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        // Align second fraction
//        if (doShowAlignment)
//        {
//            var align_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DELAY_AFTER_ALIGN);
//            var align_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DURATION_ALIGN);
//            var alignStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_ALIGN, align_unitDelay, CgsFVConstants.STEP_TYPE_ALIGN);
//            alignStep.addCallback(0, prepForAlign, null, prepForAlign_reverse);
//
//            // Timing
//            var showFirstLineStartTime : Float = .1;
//            var showFirstLinePhaseTwoStart : Float = showFirstLineStartTime + align_unitDuration;
//            var pulseSecondValueStartTime : Float = showFirstLinePhaseTwoStart + align_unitDuration;
//            var showSecondLineStartTime : Float = pulseSecondValueStartTime + align_unitDuration;
//            var moveLineStartTime : Float = showSecondLineStartTime + align_unitDuration;
//            var hideLineStartTime : Float = moveLineStartTime + align_unitDuration;
//            var finalizeAlignTime : Float = hideLineStartTime + align_unitDuration / 2;
//
//            // Emphasize first's value, for alignment
//            alignStep.addTweenSet(showFirstLineStartTime, FVEmphasis.computePulseTweens(firstSegment, align_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//
//            // Drop alignment line
//            alignStep.addTween(showFirstLinePhaseTwoStart, new GTween(firstAlignLineMask, align_unitDuration, {
//                        y : firstAlignLineMask_finalY
//                    }));
//
//            // Show and Pulse second unit
//            alignStep.addTween(pulseSecondValueStartTime, new GTween(secondUnitAlignNR, align_unitDuration / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTweenSet(pulseSecondValueStartTime, FVEmphasis.computePulseTweens(secondUnitAlignNR, align_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL));
//
//            // Show second alignment line
//            alignStep.addTween(showSecondLineStartTime, new GTween(secondAlignLineMask, align_unitDuration, {
//                        y : secondAlignLineMask_finalY
//                    }));
//
//            // Move second
//            alignStep.addTween(moveLineStartTime, new GTween(second, align_unitDuration, {
//                        x : secondAlignedX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(moveLineStartTime, new GTween(secondAlignLine, align_unitDuration, {
//                        x : firstAlignLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(moveLineStartTime, new GTween(secondAlignLineMask, align_unitDuration, {
//                        x : firstAlignLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(moveLineStartTime, new GTween(secondUnitAlignNR, align_unitDuration, {
//                        x : firstAlignLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Hide lines
//            alignStep.addTween(hideLineStartTime, new GTween(firstAlignLine, align_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(hideLineStartTime, new GTween(secondAlignLine, align_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            alignStep.addTween(hideLineStartTime, new GTween(secondUnitAlignNR, align_unitDuration / 2, {
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
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DELAY_AFTER_DROP);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DURATION_DROP);
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, prepForDrop, null, prepForDrop_reverse);
//        var drop_showResult_startTime : Float = .1;
//        var drop_emphasis_startTime : Float = drop_showResult_startTime + drop_unitDuration;
//        var drop_dropLine_startTime : Float = drop_emphasis_startTime + drop_unitDuration;
//        var drop_dropSegment_startTime : Float = drop_dropLine_startTime + drop_unitDuration;
//        var drop_hideLine_startTime : Float = drop_dropSegment_startTime + drop_unitDuration;
//        var drop_doMerge_startTime : Float = drop_hideLine_startTime + drop_unitDuration;
//        var drop_moveFirstValue_startTime : Float = drop_doMerge_startTime + .1;
//        var drop_moveSecondValue_startTime : Float = drop_moveFirstValue_startTime + drop_unitDuration;
//        var drop_showOp_startTime : Float = drop_moveSecondValue_startTime + drop_unitDuration;
//        dropStep.addTween(drop_showResult_startTime, new GTween(result, drop_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTweenSet(drop_emphasis_startTime, FVEmphasis.computePulseTweens(secondSegment, drop_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//        dropStep.addTween(drop_dropLine_startTime, new GTween(dropLineMask, drop_unitDuration, {
//                    y : dropLineMask_finalY
//                }));
//        dropStep.addTween(drop_dropSegment_startTime, new GTween(resultSegmentHolder, drop_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_hideLine_startTime, new GTween(dropLine, drop_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addCallback(drop_doMerge_startTime, doMerge, null, doMerge_reverse);
//        dropStep.addTween(drop_moveFirstValue_startTime, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveFirstValue_startTime, new GTween(first, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveSecondValue_startTime, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveSecondValue_startTime, new GTween(second, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_showOp_startTime, new GTween(eqData.opSymbolText, drop_unitDuration / 2, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(dropStep);
//
//        // Simplification
//        /*if (doSimplify)
//			{
//				var simplificationStep:AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SIMPLIFICATION, NumberlineConstants.TIME_ADD_DELAY_AFTER_SIMPLIFICATION, CgsFVConstants.STEP_TYPE_SIMPLIFICATION);
//				simplificationStep.addCallback(0, prepForSimplification, null, prepForSimplification_reverse);
//				simplificationStep.addTween(.1, new GTween(result, NumberlineConstants.TIME_ADD_DURATION_SIMPLIFICATION, { alpha:0 }, { ease:Sine.easeInOut } ));
//				simplificationStep.addTween(.1, new GTween(simplifiedResult, NumberlineConstants.TIME_ADD_DURATION_SIMPLIFICATION, { alpha:1 }, { ease:Sine.easeInOut } ));
//				simplificationStep.addCallback(.1 + NumberlineConstants.TIME_ADD_DURATION_SIMPLIFICATION, finalizeSimplification, null, finalizeSimplification_reverse);
//				m_animHelper.appendStep(simplificationStep);
//			}*/
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_ADD_DURATION_UNPOSITION);
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween(result, unposition_unitDuration, {
//                    x : finalPosition.x,
//                    y : finalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(resultModule, unposition_unitDuration, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(eqData.firstValueNR, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(eqData.opSymbolText, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(eqData.secondValueNR, unposition_unitDuration, {
//                    alpha : 0
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
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
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
//            // Hide value displays on first and second
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
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
//            // Unpeel second
//            secondModule.unpeelValue();
//            secondSegmentHolder.visible = false;
//
//            // Hide the peeled result
//            resultSegmentHolder.visible = false;
//
//            // Show value displays on first and second
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
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
//        }  /**
//			 * Completion
//			**/    /*function prepForSimplification():void
//			{
//				// Show simplified result
//				simplifiedResult.visible = true;
//				simplifiedResult.alpha = 0;
//				simplifiedResult.x = result.x;
//				simplifiedResult.y = result.y;
//			}
//
//			function prepForSimplification_reverse():void
//			{
//				// Hide simplified result
//				simplifiedResult.visible = false;
//			}
//
//			// Finalizes simplification of result fraction
//			function finalizeSimplification():void
//			{
//				// Hidesimplified result
//				result.visible = false;
//			}
//
//			function finalizeSimplification_reverse():void
//			{
//				// Show simplified result
//				result.visible = true;
//			}*/    // Prepares for simplification of result fraction  ;
//
//
//
//
//
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
//                //resultViews.push(doSimplify?simplifiedResult:result);
//                resultViews.push(result);
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

