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
class NumberlineMultiplyAnimator implements IFractionAnimator
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
        return CgsFVConstants.NUMBERLINE_STANDARD_MULTIPLY;
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
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var resultFraction : CgsFraction = CgsFraction.fMultiply(first.fraction, second.fraction);
//
//        // Create result fraction view
//        var result : CgsFractionView = first.clone();
//        resultFraction.simplify();
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
//        var equationCenter : Point = new Point(0, newFirstPosition.y - firstModule.unitHeight / 2 - NumberlineConstants.ANIMATION_MARGIN_EQUATION);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, equationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor, 1.5);
//        eqData.equationCenter = new Point(eqData.equationCenter.x + eqData.secondValueNR.width / 2 + eqData.opSymbolText.width / 2, eqData.equationCenter.y);
//
//        // Scale X dimension
//        var doScaleChange : Bool = first.fraction.numerator != first.fraction.denominator;
//        var newScaleX : Float = first.fraction.value;
//        var newXPosition : Float = newSecondPosition.x - secondModule.totalWidth / 2 + ((secondModule.totalWidth / 2) * newScaleX);
//
//        // Setup scale lines
//        var firstLine_startY : Float = -NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL * 2 - firstModule.unitHeight - NumberlineConstants.TICK_EXTENSION_DISTANCE * 2;
//        var firstLine_endY : Float = NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//        var secondLine_startY : Float = -NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//        var secondLine_endY : Float = NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL * 2 + secondModule.unitHeight + NumberlineConstants.TICK_EXTENSION_DISTANCE * 2;
//        var firstScaleLine : Sprite = m_animHelper.createDashedLine(firstLine_startY, firstLine_endY);
//        var secondScaleLine : Sprite = m_animHelper.createDashedLine(secondLine_startY, secondLine_endY);
//        firstScaleLine.x = newFirstPosition.x - firstModule.totalWidth / 2 + firstModule.valueWidth;
//        secondScaleLine.x = newSecondPosition.x - secondModule.totalWidth / 2 + secondModule.unitWidth;
//        firstScaleLine.y = midpointY;
//        secondScaleLine.y = midpointY;
//        firstScaleLine.visible = false;
//        secondScaleLine.visible = false;
//        m_animController.addChild(firstScaleLine);
//        m_animController.addChild(secondScaleLine);
//
//        // First scale line mask
//        var firstScaleLineMaskHeight : Float = firstScaleLine.height + 6;
//        var firstScaleLineMask : Sprite = m_animHelper.createMask(firstScaleLine, 10, firstScaleLineMaskHeight);
//        firstScaleLineMask.x = firstScaleLine.x;
//        firstScaleLineMask.y = midpointY + firstLine_startY - firstScaleLineMaskHeight / 2 - 1;
//        var firstScaleLineMask_finalY : Float = firstScaleLineMask.y + firstScaleLineMaskHeight;
//        m_animController.addChild(firstScaleLineMask);
//
//        // Second scale line mask
//        var secondScaleLineMaskHeight : Float = secondScaleLine.height + 6;
//        var secondScaleLineMask : Sprite = m_animHelper.createMask(secondScaleLine, 10, secondScaleLineMaskHeight);
//        secondScaleLineMask.x = secondScaleLine.x;
//        secondScaleLineMask.y = midpointY + secondLine_endY + secondScaleLineMaskHeight / 2 + 1;
//        var secondScaleLineMask_finalY : Float = secondScaleLineMask.y - secondScaleLineMaskHeight;
//        m_animController.addChild(secondScaleLineMask);
//
//        // First's segment for scale View
//        var firstSegmentHolder : Sprite = new Sprite();
//        var firstSegment : Sprite = new Sprite();
//        m_animController.addChild(firstSegmentHolder);
//        m_animHelper.trackDisplay(firstSegmentHolder);
//        firstSegmentHolder.addChild(firstSegment);
//        m_animHelper.trackDisplay(firstSegment);
//
//        // Second's unit NR for scaling
//        var secondUnitScaleNR : NumberRenderer = m_animHelper.createNumberRenderer(new CgsFraction(1, 1), textColor, textGlowColor);
//        secondUnitScaleNR.visible = false;
//        var secondUnitPosition : Point = secondModule.getValueNRPosition(false, true);
//        secondUnitScaleNR.x = newSecondPosition.x - (secondModule.totalWidth / 2) + secondModule.unitWidth;
//        secondUnitScaleNR.y = newSecondPosition.y + secondUnitPosition.y;
//        m_animController.addChild(secondUnitScaleNR);
//
//        // Setup drop line
//        var dropLine_startY : Float = midpointY;
//        var dropLine_endY : Float = resultModule.unitHeight / 2 + NumberlineConstants.TICK_EXTENSION_DISTANCE * 2;
//        var dropLine : Sprite = m_animHelper.createDashedLine(dropLine_startY, dropLine_endY);
//        dropLine.x = result.x - resultModule.totalWidth / 2 + resultModule.valueWidth;
//        dropLine.visible = false;
//        m_animController.addChild(dropLine);
//
//        // Drop line mask
//        var dropLineMaskHeight : Float = dropLine.height;
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
//        // Merge data
//        var resultSegmentHolder : Sprite = new Sprite();
//        var resultSegment : Sprite = new Sprite();
//        m_animController.addChild(resultSegmentHolder);
//        m_animHelper.trackDisplay(resultSegmentHolder);
//        resultSegmentHolder.addChild(resultSegment);
//        m_animHelper.trackDisplay(resultSegment);
//
//        // Merge data
//        var finalEquationCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var finalEqData : EquationData = m_animHelper.createEquationData(m_animController, finalEquationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor);
//        finalEqData.equationCenter = new Point(finalEqData.equationCenter.x + finalEqData.secondValueNR.width / 2 + finalEqData.opSymbolText.width / 2, finalEqData.equationCenter.y);
//
//        // Simplification
//        /*var doSimplify:Boolean = !resultFraction.isSimplified;
//			var simplifiedResultFraction:CgsFraction = resultFraction.clone();
//			simplifiedResultFraction.simplify();
//			var simplifiedResult:CgsFractionView = reuslt.clone();
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
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DURATION_POSITION);
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
//                    x : newSecondPosition.x,
//                    y : newSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(firstModule, position_unitDuration, {
//                    unitNumDisplayAlpha : 0,
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(moveStart, new GTween(secondModule, position_unitDuration, {
//                    unitNumDisplayAlpha : 0,
//                    valueNumDisplayAlpha : 0
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
//        // Scale X Dimension
//        if (doScaleChange)
//        {
//            var scale_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DELAY_AFTER_SCALE);
//            var scale_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DURATION_SCALE);
//            var scaleStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_ALIGN, scale_unitDelay, CgsFVConstants.STEP_TYPE_ALIGN);
//            scaleStep.addCallback(0, prepForScale, null, prepForScale_reverse);
//
//            // Timing
//            var pulseFirstValueStartTime : Float = .1;
//            var showFirstLineStartTime : Float = pulseFirstValueStartTime + scale_unitDuration;
//            var pulseSecondValueStartTime : Float = showFirstLineStartTime + scale_unitDuration;
//            var showSecondLineStartTime : Float = pulseSecondValueStartTime + scale_unitDuration;
//            var changeScaleStartTime : Float = showSecondLineStartTime + scale_unitDuration;
//            var hideLineStartTime : Float = changeScaleStartTime + scale_unitDuration;
//            var finalizeScaleTime : Float = hideLineStartTime + scale_unitDuration / 2;
//
//            // Pulse first value
//            scaleStep.addTweenSet(pulseFirstValueStartTime, FVEmphasis.computePulseTweens(firstSegment, scale_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//
//            // Show first line
//            scaleStep.addTween(showFirstLineStartTime, new GTween(firstScaleLineMask, scale_unitDuration, {
//                        y : firstScaleLineMask_finalY
//                    }));
//
//            // Show and Pulse second unit
//            scaleStep.addTween(pulseSecondValueStartTime, new GTween(secondUnitScaleNR, scale_unitDuration / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTweenSet(pulseSecondValueStartTime, FVEmphasis.computePulseTweens(secondUnitScaleNR, scale_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL));
//
//            // Show second line
//            scaleStep.addTween(showSecondLineStartTime, new GTween(secondScaleLineMask, scale_unitDuration, {
//                        y : secondScaleLineMask_finalY
//                    }));
//
//            // Change scale
//            scaleStep.addTween(changeScaleStartTime, new GTween(secondModule, scale_unitDuration, {
//                        scaleX : newScaleX
//                    }));  //, { ease:Sine.easeInOut } ));
//            scaleStep.addTween(changeScaleStartTime, new GTween(second, scale_unitDuration, {
//                        x : newXPosition
//                    }));  //, { ease:Sine.easeInOut } ));
//            scaleStep.addTween(changeScaleStartTime, new GTween(secondScaleLine, scale_unitDuration, {
//                        x : firstScaleLine.x
//                    }));  //, { ease:Sine.easeInOut } ));
//            scaleStep.addTween(changeScaleStartTime, new GTween(secondScaleLineMask, scale_unitDuration, {
//                        x : firstScaleLine.x
//                    }));  //, { ease:Sine.easeInOut } ));
//            scaleStep.addTween(changeScaleStartTime, new GTween(secondUnitScaleNR, scale_unitDuration, {
//                        x : firstScaleLine.x
//                    }));  //, { ease:Sine.easeInOut } ));
//
//            // Hide lines
//            scaleStep.addTween(hideLineStartTime, new GTween(firstScaleLine, scale_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTween(hideLineStartTime, new GTween(secondScaleLine, scale_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTween(hideLineStartTime, new GTween(secondUnitScaleNR, scale_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            scaleStep.addCallback(finalizeScaleTime, finalizeScale, null, finalizeScale_reverse);
//            m_animHelper.appendStep(scaleStep);
//        }
//
//        // Tween drop
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DELAY_AFTER_DROP);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DURATION_DROP);
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, prepForDrop, null, prepForDrop_reverse);  // Do peel
//        var drop_showResult_startTime : Float = .1;
//        var drop_emphasis_startTime : Float = drop_showResult_startTime + drop_unitDuration;
//        var drop_dropLine_startTime : Float = drop_emphasis_startTime + drop_unitDuration;
//        var drop_dropSegment_startTime : Float = drop_dropLine_startTime + drop_unitDuration;
//        var drop_hideLine_startTime : Float = drop_dropSegment_startTime + drop_unitDuration;
//        var drop_showDropCount_startTime : Float = drop_hideLine_startTime + drop_unitDuration;
//        var drop_doMerge_startTime : Float = drop_hideLine_startTime + drop_unitDuration;
//        var drop_moveEquation_startTime : Float = drop_doMerge_startTime + .1;
//        var drop_finalizeMerge_startTime : Float = drop_moveEquation_startTime + drop_unitDuration;
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
//        dropStep.addTween(drop_moveEquation_startTime, new GTween(first, drop_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveEquation_startTime, new GTween(second, drop_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveEquation_startTime, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                    x : finalEqData.firstValueNR_equationPosition.x,
//                    y : finalEqData.firstValueNR_equationPosition.y,
//                    numeratorScale : 1,
//                    denominatorScale : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveEquation_startTime, new GTween(eqData.opSymbolText, drop_unitDuration, {
//                    x : finalEqData.opSymbolText_equationPosition.x,
//                    y : finalEqData.opSymbolText_equationPosition.y,
//                    scaleX : 1,
//                    scaleY : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_moveEquation_startTime, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                    x : finalEqData.secondValueNR_equationPosition.x,
//                    y : finalEqData.secondValueNR_equationPosition.y,
//                    numeratorScale : 1,
//                    denominatorScale : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addCallback(drop_finalizeMerge_startTime, finalizeMerge, null, finalizeMerge_reverse);
//        m_animHelper.appendStep(dropStep);
//
//        // Simplification
//        /*if (doSimplify)
//			{
//				var simplificationStep:AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SIMPLIFICATION, NumberlineConstants.TIME_MULT_DELAY_AFTER_SIMPLIFICATION, CgsFVConstants.STEP_TYPE_SIMPLIFICATION);
//				simplificationStep.addCallback(0, prepForSimplification, null, prepForSimplification_reverse);
//				simplificationStep.addTween(.1, new GTween(result, NumberlineConstants.TIME_MULT_DURATION_SIMPLIFICATION, { alpha:0 }, { ease:Sine.easeInOut } ));
//				simplificationStep.addTween(.1, new GTween(simplifiedResult, NumberlineConstants.TIME_MULT_DURATION_SIMPLIFICATION, { alpha:1 }, { ease:Sine.easeInOut } ));
//				simplificationStep.addCallback(.1 + NumberlineConstants.TIME_MULT_DURATION_SIMPLIFICATION, finalizeSimplification, null, finalizeSimplification_reverse);
//				m_animHelper.appendStep(simplificationStep);
//			}*/
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_MULT_DURATION_UNPOSITION);
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
//        unpositionStep.addTween(0, new GTween(finalEqData.firstValueNR, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(finalEqData.opSymbolText, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(finalEqData.secondValueNR, unposition_unitDuration, {
//                    alpha : 0
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
//        }  // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the numberline  ;
//
//
//
//        var moveValueToBottom : Void->Void = function() : Void
//        {
//            secondModule.valueIsAbove = false;
//        }
//
//        function moveValueToBottom_reverse() : Void
//        {
//            secondModule.valueIsAbove = true;
//        }  // Preps for the scale animation  ;
//
//
//
//        var prepForScale : Void->Void = function() : Void
//        {
//            // Peel (paint to new and hide old) the value onto the firstSegment
//            firstModule.peelValue(firstSegment);
//            firstSegmentHolder.x = first.x;
//            firstSegmentHolder.y = first.y;
//            firstSegmentHolder.visible = true;
//
//            // Prep NRs
//            secondUnitScaleNR.visible = true;
//            secondUnitScaleNR.alpha = 0;
//
//            // Prep lines
//            firstScaleLine.visible = true;
//            secondScaleLine.visible = true;
//        }
//
//        function prepForScale_reverse() : Void
//        {
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            // Hide NRs
//            secondUnitScaleNR.visible = false;
//
//            // Hide lines
//            firstScaleLine.visible = false;
//            secondScaleLine.visible = false;
//        }  // Preps for the scale animation  ;
//
//
//
//        var finalizeScale : Void->Void = function() : Void
//        {
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            // Hide NRs
//            secondUnitScaleNR.visible = false;
//
//            // Hide lines
//            firstScaleLine.visible = false;
//            secondScaleLine.visible = false;
//        }
//
//        var finalizeScale_reverse : Void->Void = function() : Void
//        {
//            firstModule.doShowSegment = false;
//            first.redraw(true);
//            firstSegmentHolder.visible = true;
//
//            // Show NRs
//            secondUnitScaleNR.visible = true;
//
//            // Show lines
//            firstScaleLine.visible = true;
//            secondScaleLine.visible = true;
//        }
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
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        var finalizeMerge : Void->Void = function() : Void
//        {
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
//				first.visible = false;
//			}
//
//			function finalizeSimplification_reverse():void
//			{
//				// Show simplified result
//				first.visible = true;
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
//        var multComplete : Void->Void = function() : Void
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

