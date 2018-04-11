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
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.NumberRendererFactory;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import openfl.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
	 * ...
	 * @author Rich
	 */
class NumberlineCompareSizeAnimator implements IFractionAnimator
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
        return CgsFVConstants.NUMBERLINE_STANDARD_COMPARE_SIZE;
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
//        var comparisonType : String = Reflect.field(details, Std.string(CgsFVConstants.COMPARE_TYPE_DATA_KEY));
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
//        var second : CgsFractionView = fractionViews[1];
//        var firstModule : LineFractionModule = try cast(first.module, LineFractionModule) catch(e:Dynamic) null;
//        var secondModule : LineFractionModule = try cast(second.module, LineFractionModule) catch(e:Dynamic) null;
//
//        // Create comparison fraction view
//        var compareView : CgsFractionView = first.clone();
//        compareView.fraction.init(0, 1);
//        var compareModule : LineFractionModule = (try cast(compareView.module, LineFractionModule) catch(e:Dynamic) null);
//        compareModule.valueNumDisplayAlpha = 0;
//        compareModule.unitNumDisplayAlpha = 0;
//        compareModule.doShowSegment = false;
//        compareModule.numExtensionUnits = Math.max(firstModule.numTotalUnits, secondModule.numTotalUnits) - compareModule.numBaseUnits;
//        compareView.x = 0;
//        compareView.y = 0;
//        compareView.alpha = 0;
//        compareView.redraw(true);
//        m_animHelper.trackFractionView(compareView);
//        m_animController.addChild(compareView);
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2);
//        var offsetY : Float = compareModule.unitHeight / 2 + NumberlineConstants.TICK_EXTENSION_DISTANCE * 2 + NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL * 2;
//        var newFirstPosition : Point = new Point(firstModule.totalWidth / 2 - offsetX, -firstModule.unitHeight / 2 - offsetY);
//        var newSecondPosition : Point = new Point(secondModule.totalWidth / 2 - offsetX, secondModule.unitHeight / 2 + offsetY);
//
//        // Setup first value line
//        var firstValueLine_startY : Float = newFirstPosition.y + firstModule.valueNRPosition.y + NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var firstValueLine_endY : Float = compareView.y + compareModule.unitHeight / 2 + NumberlineConstants.TICK_EXTENSION_DISTANCE;
//        var firstValueLine : Sprite = m_animHelper.createDashedLine(firstValueLine_startY, firstValueLine_endY);
//        firstValueLine.x = newFirstPosition.x + firstModule.valueOffsetX;
//        firstValueLine.visible = false;
//        m_animController.addChild(firstValueLine);
//
//        // First value line mask
//        var firstValueLineMaskHeight : Float = firstValueLine.height + 6;
//        var firstValueLineMask : Sprite = m_animHelper.createMask(firstValueLine, 10, firstValueLineMaskHeight);
//        firstValueLineMask.x = firstValueLine.x;
//        firstValueLineMask.y = firstValueLine_startY - firstValueLineMaskHeight / 2 - 1;
//        var firstValueLineMask_finalY : Float = firstValueLineMask.y + firstValueLineMaskHeight;
//        m_animController.addChild(firstValueLineMask);
//
//        // Setup first value line
//        var secondValueLine_startY : Float = compareView.y - compareModule.unitHeight / 2 - NumberlineConstants.TICK_EXTENSION_DISTANCE;
//        var secondValueLine_endY : Float = newSecondPosition.y + secondModule.getValueNRPosition(false, second.fraction.denominator == 1).y - NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var secondValueLine : Sprite = m_animHelper.createDashedLine(secondValueLine_startY, secondValueLine_endY);
//        secondValueLine.x = newSecondPosition.x + secondModule.valueOffsetX;
//        secondValueLine.visible = false;
//        m_animController.addChild(secondValueLine);
//
//        // Second value line mask
//        var secondValueLineMaskHeight : Float = secondValueLine.height + 6;
//        var secondValueLineMask : Sprite = m_animHelper.createMask(secondValueLine, 10, secondValueLineMaskHeight);
//        secondValueLineMask.x = secondValueLine.x;
//        secondValueLineMask.y = secondValueLine_endY + secondValueLineMaskHeight / 2 + 1;
//        var secondValueLineMask_finalY : Float = secondValueLineMask.y - secondValueLineMaskHeight;
//        m_animController.addChild(secondValueLineMask);
//
//        // First's segment for alignment View
//        var firstSegmentHolder : Sprite = new Sprite();
//        var firstSegment : Sprite = new Sprite();
//        m_animController.addChild(firstSegmentHolder);
//        m_animHelper.trackDisplay(firstSegmentHolder);
//        firstSegmentHolder.addChild(firstSegment);
//        m_animHelper.trackDisplay(firstSegment);
//
//        // Second's segment for alignment View
//        var secondSegmentHolder : Sprite = new Sprite();
//        var secondSegment : Sprite = new Sprite();
//        m_animController.addChild(secondSegmentHolder);
//        m_animHelper.trackDisplay(secondSegmentHolder);
//        secondSegmentHolder.addChild(secondSegment);
//        m_animHelper.trackDisplay(secondSegment);
//
//        // Emphasis data
//        var winnerValue : Float = VisualizationUtilities.compareByComparisonType(comparisonType, first.fraction, second.fraction, details);
//        var winnerExists : Bool = winnerValue != 0;
//        var winningView : CgsFractionView;
//        var winningModule : LineFractionModule;
//        var winningSegmentHolder : Sprite;
//        var winningSegment : Sprite;
//        var winningGlowLine : Sprite;
//        var winningGlowDot : Sprite;
//        var winningGlowLineFinalPosition : Point;
//        var winningGlowDotFinalPosition : Point;
//        if (winnerExists)
//        {
//            // Setup winning view
//            winningView = ((winnerValue > 0)) ? first : second;
//            winningModule = try cast(winningView.module, LineFractionModule) catch(e:Dynamic) null;
//            winningGlowLineFinalPosition = ((winnerValue > 0)) ? oldFirstPosition : oldSecondPosition;
//            winningGlowDotFinalPosition = new Point(winningGlowLineFinalPosition.x + winningModule.valueOffsetX, winningGlowLineFinalPosition.y);
//
//            // Glow
//            winningGlowLine = new Sprite();
//            winningGlowDot = new Sprite();
//            var winningWidth : Float = winningModule.totalWidth;
//            var winningHeight : Float = winningModule.unitHeight + NumberlineConstants.TICK_EXTENSION_DISTANCE * 2;
//            var winningRadius : Float = NumberlineConstants.SEGMENT_RADIUS * 2;
//            var glowColor : Int = (Reflect.hasField(details, CgsFVConstants.WINNING_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.WINNING_GLOW_COLOR)) : CgsFVConstants.ANIMATION_WINNING_GLOW_COLOR;
//            winningGlowLine.graphics.beginFill(glowColor);
//            winningGlowLine.graphics.drawRoundRect(-winningWidth / 2, -winningHeight / 2, winningWidth, winningHeight, 10, 10);
//            winningGlowLine.graphics.endFill();
//            winningGlowDot.graphics.beginFill(glowColor);
//            winningGlowDot.graphics.drawCircle(0, 0, winningRadius);
//            winningGlowDot.graphics.endFill();
//            winningGlowLine.visible = false;
//            winningGlowDot.visible = false;
//            m_animHelper.trackDisplay(winningGlowLine);
//            m_animHelper.trackDisplay(winningGlowDot);
//            m_animController.addChildAt(winningGlowLine, m_animController.getChildIndex(winningView));
//            m_animController.addChildAt(winningGlowDot, m_animController.getChildIndex(winningView));
//            var winningGlowBlur : BlurFilter = new BlurFilter(10, 10);
//            winningGlowLine.filters = [winningGlowBlur];
//            winningGlowDot.filters = [winningGlowBlur];
//
//            // Setup winning segment
//            winningSegmentHolder = ((winnerValue > 0)) ? firstSegmentHolder : secondSegmentHolder;
//            winningSegment = ((winnerValue > 0)) ? firstSegment : secondSegment;
//        }
//
//        // Compare Symbol
//        var resultEndScale : Float = 1.5;
//        var compareSymbol : TextField = m_animHelper.createTextField((comparisonType == CgsFVConstants.COMPARE_TYPE_GREATER_THAN) ? " >?" : " <?", textColor, textGlowColor);
//        m_animController.addChild(compareSymbol);
//        compareSymbol.scaleX = resultEndScale;
//        compareSymbol.scaleY = resultEndScale;
//        compareSymbol.x = -compareSymbol.width / 2;
//        compareSymbol.y = newFirstPosition.y - firstModule.unitHeight / 2 - NumberlineConstants.TICK_EXTENSION_DISTANCE - NumberlineConstants.ANIMATION_MARGIN_TEXT_LARGE - compareSymbol.height / 2;
//        compareSymbol.alpha = 0;
//        compareSymbol.visible = true;
//
//        // Result Symbol
//        var resultText : String = " = ";
//        if (winnerExists)
//        {
//            if (comparisonType == CgsFVConstants.COMPARE_TYPE_GREATER_THAN)
//            {
//                resultText = " > ";
//            }
//            else
//            {
//                resultText = " < ";
//            }
//        }
//        var resultSymbolHolder : Sprite = new Sprite();
//        m_animHelper.trackDisplay(resultSymbolHolder);
//        m_animController.addChild(resultSymbolHolder);
//        resultSymbolHolder.x = 0;
//        resultSymbolHolder.y = newFirstPosition.y - firstModule.unitHeight / 2 - NumberlineConstants.TICK_EXTENSION_DISTANCE - NumberlineConstants.ANIMATION_MARGIN_TEXT_LARGE;
//        var resultSymbol : TextField = m_animHelper.createTextField(resultText, textColor, textGlowColor);
//        resultSymbolHolder.addChild(resultSymbol);
//        resultSymbol.x = -resultSymbol.width / 2;
//        resultSymbol.y = -resultSymbol.height / 2;
//        resultSymbol.alpha = 0;
//        resultSymbol.visible = false;
//
//        // Result Fraction of First
//        var firstResultFrac : NumberRenderer = m_animHelper.createNumberRenderer(first.fraction, textColor, textGlowColor);
//        firstResultFrac.visible = false;
//        m_animController.addChild(firstResultFrac);
//        var firstResultFracFinalPosition : Point = new Point(((winnerValue >= 0)) ? resultSymbolHolder.x - (resultSymbol.width * resultEndScale) / 2 - (firstResultFrac.width * resultEndScale) / 2 : resultSymbolHolder.x + (resultSymbol.width * resultEndScale) / 2 + (firstResultFrac.width * resultEndScale) / 2, resultSymbolHolder.y);
//
//        // Result Fraction of Second
//        var secondResultFrac : NumberRenderer = m_animHelper.createNumberRenderer(second.fraction, textColor, textGlowColor);
//        secondResultFrac.visible = false;
//        m_animController.addChild(secondResultFrac);
//        var secondResultFracFinalPosition : Point = new Point(((winnerValue >= 0)) ? resultSymbolHolder.x + (resultSymbol.width * resultEndScale) / 2 + (secondResultFrac.width * resultEndScale) / 2 : resultSymbolHolder.x - (resultSymbol.width * resultEndScale) / 2 - (secondResultFrac.width * resultEndScale) / 2, resultSymbolHolder.y);
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DURATION_POSITION);
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
//        positionStep.addTween(0, new GTween(secondModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(position_unitDuration / 2, moveValueToBottom, null, moveValueToBottom_reverse);
//        positionStep.addTween(position_unitDuration * (2 / 3), new GTween(secondModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(compareSymbol, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        // Drop lines for comparison
//        var compare_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DELAY_AFTER_COMPARE);
//        var compare_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DURATION_COMPARE);
//        var compareStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_COMPARE, compare_unitDelay, CgsFVConstants.STEP_TYPE_COMPARE);
//        var showCompare_startTime : Float = 0;
//        var prepForCompareTime : Float = showCompare_startTime + compare_unitDuration;
//        var pulseFirstValue_startTime : Float = prepForCompareTime + .1;
//        var dropFirstValueLine_startTime : Float = pulseFirstValue_startTime + compare_unitDuration;
//        var pulseSecondValue_startTime : Float = dropFirstValueLine_startTime + compare_unitDuration;
//        var dropSecondValueLine_startTime : Float = pulseSecondValue_startTime + compare_unitDuration;
//        compareStep.addTween(showCompare_startTime, new GTween(compareView, compare_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        compareStep.addCallback(prepForCompareTime, prepForCompare, null, prepForCompare_reverse);
//        compareStep.addTweenSet(pulseFirstValue_startTime, FVEmphasis.computePulseTweens(firstSegment, compare_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//        compareStep.addTween(dropFirstValueLine_startTime, new GTween(firstValueLineMask, compare_unitDuration, {
//                    y : firstValueLineMask_finalY
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        compareStep.addTweenSet(pulseSecondValue_startTime, FVEmphasis.computePulseTweens(secondSegment, compare_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//        compareStep.addTween(dropSecondValueLine_startTime, new GTween(secondValueLineMask, compare_unitDuration, {
//                    y : secondValueLineMask_finalY
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(compareStep);
//
//        // Show result, with emphasis
//        var showResult_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT);
//        var showResult_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DURATION_SHOW_RESULT);
//        var showResultStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_RESULT, showResult_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_RESULT);
//        showResultStep.addCallback(0, prepForResult, null, prepForResult_reverse);
//        var showResult_emphasizeWinner_startTime : Float = .1;
//        var showResult_winnerPulse_startTime : Float = (winnerExists) ? showResult_emphasizeWinner_startTime + showResult_unitDuration + showResult_unitDelay : .1;
//        var showResult_winnerMove_startTime : Float = showResult_winnerPulse_startTime + showResult_unitDuration;
//        var showResult_changeToResult_startTime : Float = showResult_winnerMove_startTime + showResult_unitDuration / 2 + showResult_unitDelay / 2;
//        var showResult_loserPulse_startTime : Float = showResult_changeToResult_startTime + showResult_unitDuration + showResult_unitDelay / 2;
//        var showResult_loserMove_startTime : Float = showResult_loserPulse_startTime + showResult_unitDuration;
//        var showResult_firstPulse_startTime : Float = ((winnerValue >= 0)) ? showResult_winnerPulse_startTime : showResult_loserPulse_startTime;
//        var showResult_firstMove_startTime : Float = ((winnerValue >= 0)) ? showResult_winnerMove_startTime : showResult_loserMove_startTime;
//        var showResult_secondPulse_startTime : Float = ((winnerValue < 0)) ? showResult_winnerPulse_startTime : showResult_loserPulse_startTime;
//        var showResult_secondMove_startTime : Float = ((winnerValue < 0)) ? showResult_winnerMove_startTime : showResult_loserMove_startTime;
//        if (winnerExists)
//        {
//            showResultStep.addTweenSet(showResult_emphasizeWinner_startTime, FVEmphasis.computePulseTweens(winningSegment, showResult_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//            showResultStep.addTween(showResult_emphasizeWinner_startTime, new GTween(winningGlowLine, showResult_unitDuration / 4, {
//                        alpha : .7
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTween(showResult_emphasizeWinner_startTime, new GTween(winningGlowDot, showResult_unitDuration / 4, {
//                        alpha : .7
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTweenSet(showResult_emphasizeWinner_startTime, FVEmphasis.computePulseTweens(winningGlowDot, showResult_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL));
//        }
//        showResultStep.addTweenSet(showResult_firstPulse_startTime, FVEmphasis.computePulseTweens(firstResultFrac, showResult_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL_LARGE));
//        showResultStep.addCallback(showResult_firstMove_startTime, reShowFirstValue, null, reShowFirstValue_reverse);
//        showResultStep.addTween(showResult_firstMove_startTime, new GTween(firstResultFrac, showResult_unitDuration / 2, {
//                    x : firstResultFracFinalPosition.x,
//                    y : firstResultFracFinalPosition.y,
//                    scaleX : resultEndScale,
//                    scaleY : resultEndScale
//                }));
//        showResultStep.addTweenSet(showResult_changeToResult_startTime, FVEmphasis.computePulseTweens(resultSymbolHolder, showResult_unitDuration, resultEndScale, resultEndScale, NumberlineConstants.PULSE_SCALE_GENERAL_LARGE));
//        showResultStep.addTween(showResult_changeToResult_startTime, new GTween(resultSymbol, showResult_unitDuration / 4, {
//                    alpha : 1
//                }));
//        showResultStep.addTween(showResult_changeToResult_startTime, new GTween(compareSymbol, showResult_unitDuration / 4, {
//                    alpha : 0
//                }));
//        showResultStep.addTweenSet(showResult_secondPulse_startTime, FVEmphasis.computePulseTweens(secondResultFrac, showResult_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL_LARGE));
//        showResultStep.addCallback(showResult_secondMove_startTime, reShowSecondValue, null, reShowSecondValue_reverse);
//        showResultStep.addTween(showResult_secondMove_startTime, new GTween(secondResultFrac, showResult_unitDuration / 2, {
//                    x : secondResultFracFinalPosition.x,
//                    y : secondResultFracFinalPosition.y,
//                    scaleX : resultEndScale,
//                    scaleY : resultEndScale
//                }));
//        m_animHelper.appendStep(showResultStep);
//
//
//        // Fade out
//        var fadeOut_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DELAY_AFTER_FADE);
//        var fadeOut_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DURATION_FADE);
//        var fadeOutStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, fadeOut_unitDelay, CgsFVConstants.STEP_TYPE_FADE);
//        fadeOutStep.addTween(0, new GTween(compareView, fadeOut_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeOutStep.addTween(0, new GTween(firstValueLine, fadeOut_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeOutStep.addTween(0, new GTween(secondValueLine, fadeOut_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeOutStep.addCallback(fadeOut_unitDuration, finishCompare, null, finishCompare_reverse);
//        m_animHelper.appendStep(fadeOutStep);
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_SIZE_DURATION_UNPOSITION);
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween(first, unposition_unitDuration, {
//                    x : oldFirstPosition.x,
//                    y : oldFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(second, unposition_unitDuration, {
//                    x : oldSecondPosition.x,
//                    y : oldSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(firstModule, unposition_unitDuration, {
//                    unitNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(secondModule, unposition_unitDuration, {
//                    unitNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(secondModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addCallback(unposition_unitDuration / 2, moveValueToTop, null, moveValueToTop_reverse);
//        unpositionStep.addTween(unposition_unitDuration * (2 / 3), new GTween(secondModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        if (winnerExists)
//        {
//            unpositionStep.addTween(0, new GTween(winningGlowLine, unposition_unitDuration, {
//                        alpha : 0,
//                        x : winningGlowLineFinalPosition.x,
//                        y : winningGlowLineFinalPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            unpositionStep.addTween(0, new GTween(winningGlowDot, unposition_unitDuration, {
//                        alpha : 0,
//                        x : winningGlowDotFinalPosition.x,
//                        y : winningGlowDotFinalPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//        unpositionStep.addTween(0, new GTween(resultSymbol, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(firstResultFrac, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(secondResultFrac, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(unpositionStep);
//
//        // Go
//        m_animHelper.animate(compareComplete, positionStep, unpositionStep);
//
//
//        /**
//			 * State Change Functions
//			**/
//
//        // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the numberline
//        function moveValueToBottom() : Void
//        {
//            secondModule.valueIsAbove = false;
//        };
//
//        function moveValueToBottom_reverse() : Void
//        {
//            secondModule.valueIsAbove = true;
//        }  // Prepares for the compare step, pulsing the numbers and dropping lines  ;
//
//
//
//        var prepForCompare : Void->Void = function() : Void
//        {
//            // Peel (paint to new and hide old) the value onto the firstSegment
//            firstModule.peelValue(firstSegment);
//            firstSegmentHolder.x = first.x;
//            firstSegmentHolder.y = first.y;
//            firstSegmentHolder.visible = true;
//
//            // Peel (paint to new and hide old) the value onto the secondSegment
//            secondModule.peelValue(secondSegment);
//            secondSegmentHolder.x = second.x;
//            secondSegmentHolder.y = second.y;
//            secondSegmentHolder.visible = true;
//
//            firstValueLine.visible = true;
//            firstValueLine.alpha = 1;
//            secondValueLine.visible = true;
//            secondValueLine.alpha = 1;
//        }
//
//        function prepForCompare_reverse() : Void
//        {
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            secondModule.doShowSegment = true;
//            second.redraw(true);
//            secondSegmentHolder.visible = false;
//
//            firstValueLine.visible = false;
//            secondValueLine.visible = false;
//        }  // Turns on the part of the result display  ;
//
//
//
//        var prepForResult : Void->Void = function() : Void
//        {
//            // Show winning glow
//            if (winnerExists)
//            {
//                winningGlowLine.x = winningView.x;
//                winningGlowLine.y = winningView.y;
//                winningGlowLine.alpha = 0;
//                winningGlowLine.visible = true;
//
//                winningGlowDot.x = winningView.x + winningModule.valueOffsetX;
//                winningGlowDot.y = winningView.y;
//                winningGlowDot.alpha = 0;
//                winningGlowDot.visible = true;
//            }
//
//            // Show result symbol
//            resultSymbol.visible = true;
//            resultSymbol.alpha = 0;
//
//            // Show first result fraction
//            firstResultFrac.visible = true;
//            firstResultFrac.alpha = 1;
//            firstResultFrac.x = first.x + firstModule.valueNRPosition.x;
//            firstResultFrac.y = first.y + firstModule.valueNRPosition.y;
//
//            // Hide value of first
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//
//            // Show second result fraction
//            secondResultFrac.visible = true;
//            secondResultFrac.alpha = 1;
//            secondResultFrac.x = second.x + secondModule.valueNRPosition.x;
//            secondResultFrac.y = second.y + secondModule.valueNRPosition.y;
//
//            // Hide value of second
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//        }
//
//        function prepForResult_reverse() : Void
//        {
//            // Hide winning glow
//            if (winnerExists)
//            {
//                winningGlowLine.visible = false;
//                winningGlowDot.visible = false;
//            }
//
//            // Hide result fractions
//            firstResultFrac.visible = false;
//            secondResultFrac.visible = false;
//
//            // Show value of fractions
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//        }  // Re shows the fraction value of the first  ;
//
//
//
//        var reShowFirstValue : Void->Void = function() : Void
//        {
//            // Show value of first
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//        }
//
//        function reShowFirstValue_reverse() : Void
//        {
//            // Hide value of first
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//        }  // Re shows the fraction value of the second  ;
//
//
//
//        var reShowSecondValue : Void->Void = function() : Void
//        {
//            // Show value of second
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//        }
//
//        function reShowSecondValue_reverse() : Void
//        {
//            // Hide value of second
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//        }  // Finalizes the compare step, puts everything back the way it was  ;
//
//
//
//        var finishCompare : Void->Void = function() : Void
//        {
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            secondModule.doShowSegment = true;
//            second.redraw(true);
//            secondSegmentHolder.visible = false;
//        }
//
//        function finishCompare_reverse() : Void
//        {
//            firstModule.doShowSegment = false;
//            first.redraw(true);
//            firstSegmentHolder.visible = true;
//
//            secondModule.doShowSegment = false;
//            second.redraw(true);
//            secondSegmentHolder.visible = true;
//        }  // Moves the location of the fraction value of the first module back to above the numberline  ;
//
//
//
//        var moveValueToTop : Void->Void = function() : Void
//        {
//            secondModule.valueIsAbove = true;
//        }
//
//        function moveValueToTop_reverse() : Void
//        {
//            secondModule.valueIsAbove = false;
//        }  // Callback    /**
//			 //* Completion
//			//**/  ;
//
//
//
//
//
//
//
//        var compareComplete : Void->Void = function() : Void
//        {
//            endAnimation();
//            if (completeCallback != null)
//            {
//                completeCallback();
//            }
//        }
    }
}

