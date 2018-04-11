package cgs.fractionVisualization.fractionAnimators.numberline;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.LineFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
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
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import openfl.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
	 * ...
	 * @author Rich
	 */
class NumberlineCompareTargetAnimator implements IFractionAnimator
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
        return CgsFVConstants.NUMBERLINE_STANDARD_COMPARE_BENCHMARK;
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
        //TODO fix later
//        var comparisonType : String = Reflect.field(details, Std.string(CgsFVConstants.COMPARE_TYPE_DATA_KEY));
//        var benchmarkFraction : CgsFraction = Reflect.field(details, Std.string(CgsFVConstants.COMPARISON_BENCHMARK_DATA_KEY));
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
//        var doCompare : Bool = benchmarkFraction.value != first.fraction.value && benchmarkFraction.value != second.fraction.value;
//        var isFirstLeftAligned : Bool = first.fraction.value >= benchmarkFraction.value;
//        var isSecondLeftAligned : Bool = second.fraction.value >= benchmarkFraction.value;
//        //var isOverUnder:Boolean = (isFirstLeftAligned && !isSecondLeftAligned) || (!isFirstLeftAligned && isSecondLeftAligned);
//
//        // Compare Line Offsets
//        var firstCompareSprite_offsetY : Float = firstModule.unitHeight / 2 + NumberlineConstants.TICK_EXTENSION_DISTANCE + firstModule.unitHeight / 2 + NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//        var secondCompareSprite_offsetY : Float = -secondModule.unitHeight / 2 - NumberlineConstants.TICK_EXTENSION_DISTANCE - secondModule.unitHeight / 2 - NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2);
//        var offsetY : Float = Math.abs(firstCompareSprite_offsetY) + firstModule.unitHeight / 2 + NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL * 2 + NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var newFirstPosition : Point = new Point(firstModule.totalWidth / 2 - offsetX, -offsetY);
//        var newSecondPosition : Point = new Point(secondModule.totalWidth / 2 - offsetX, offsetY);
//        var benchmarkOffsetX : Float = -(firstModule.totalWidth / 2) + (firstModule.unitWidth * benchmarkFraction.value);
//
//        // Benchmark View
//        var benchmarkX : Float = newFirstPosition.x + benchmarkOffsetX;
//        var benchmarkNR : NumberRenderer = m_animHelper.createNumberRenderer(benchmarkFraction, textColor, textGlowColor);
//        benchmarkNR.alpha = 0;
//        benchmarkNR.scaleX = 1.5;
//        benchmarkNR.scaleY = 1.5;
//        benchmarkNR.x = ((!isFirstLeftAligned && !isSecondLeftAligned)) ? benchmarkX + benchmarkNR.width / 2 + NumberlineConstants.ANIMATION_MARGIN_HORIZONTAL_SMALL : benchmarkX - benchmarkNR.width / 2 - NumberlineConstants.ANIMATION_MARGIN_HORIZONTAL_SMALL;
//        benchmarkNR.y = 0;
//
//        // Benchmark Line
//        var benchmarkLine_startY : Float = newFirstPosition.y + firstModule.getValueNRPosition(true, first.fraction.denominator == 1).y + NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var benchmarkLine_endY : Float = newSecondPosition.y + secondModule.getValueNRPosition(false, first.fraction.denominator == 1).y - NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var benchmarkLine : Sprite = m_animHelper.createDashedLine(benchmarkLine_startY, benchmarkLine_endY);
//        benchmarkLine.x = benchmarkX;
//        benchmarkLine.y = 0;
//        benchmarkLine.visible = false;
//
//        // Benchmark line mask
//        var benchmarkLineMaskHeight : Float = benchmarkLine.height + 6;
//        var benchmarkLineMask : Sprite = m_animHelper.createMask(benchmarkLine, 10, benchmarkLineMaskHeight);
//        benchmarkLineMask.x = benchmarkLine.x;
//        benchmarkLineMask.y = benchmarkLine_startY - benchmarkLineMaskHeight / 2 - 1;
//        var benchmarkLineMask_finalY : Float = benchmarkLineMask.y + benchmarkLineMaskHeight;
//
//        // Compare data
//        if (doCompare)
//        {
//            // Setup first value line
//            var firstValueLine_startY : Float = newFirstPosition.y + firstModule.valueNRPosition.y + NumberRenderer.MAX_BOX_HEIGHT / 2;
//            var firstValueLine_endY : Float = newFirstPosition.y + firstCompareSprite_offsetY + NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//            var firstValueLine : Sprite = m_animHelper.createDashedLine(firstValueLine_startY, firstValueLine_endY);
//            firstValueLine.x = newFirstPosition.x + firstModule.valueOffsetX;
//            firstValueLine.visible = false;
//            m_animController.addChild(firstValueLine);
//
//            // First value line mask
//            var firstValueLineMaskHeight : Float = firstValueLine.height + 6;
//            var firstValueLineMask : Sprite = m_animHelper.createMask(firstValueLine, 10, firstValueLineMaskHeight);
//            firstValueLineMask.x = firstValueLine.x;
//            firstValueLineMask.y = firstValueLine_startY - firstValueLineMaskHeight / 2 - 1;
//            var firstValueLineMask_finalY : Float = firstValueLineMask.y + firstValueLineMaskHeight;
//            m_animController.addChild(firstValueLineMask);
//
//            // Setup first value line
//            var secondValueLine_startY : Float = newSecondPosition.y + secondCompareSprite_offsetY - NumberlineConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//            var secondValueLine_endY : Float = newSecondPosition.y + secondModule.getValueNRPosition(false, second.fraction.denominator == 1).y - NumberRenderer.MAX_BOX_HEIGHT / 2;
//            var secondValueLine : Sprite = m_animHelper.createDashedLine(secondValueLine_startY, secondValueLine_endY);
//            secondValueLine.x = newSecondPosition.x + secondModule.valueOffsetX;
//            secondValueLine.visible = false;
//            m_animController.addChild(secondValueLine);
//
//            // Second value line mask
//            var secondValueLineMaskHeight : Float = secondValueLine.height + 6;
//            var secondValueLineMask : Sprite = m_animHelper.createMask(secondValueLine, 10, secondValueLineMaskHeight);
//            secondValueLineMask.x = secondValueLine.x;
//            secondValueLineMask.y = secondValueLine_endY + secondValueLineMaskHeight / 2 + 1;
//            var secondValueLineMask_finalY : Float = secondValueLineMask.y - secondValueLineMaskHeight;
//            m_animController.addChild(secondValueLineMask);
//
//            // First Comparison Sprite
//            var firstFillAmount : Float = first.fraction.value;
//            firstModule.fillStartFraction = benchmarkFraction;
//            firstFillAmount = Math.abs(benchmarkFraction.value - firstFillAmount);
//            var firstCompareSprite : Sprite = new Sprite();
//            firstCompareSprite.visible = false;
//            m_animHelper.trackDisplay(firstCompareSprite);
//            m_animController.addChild(firstCompareSprite);
//            firstModule.paintColoredFillLine(firstCompareSprite);
//            firstCompareSprite.x = benchmarkLine.x + ((isFirstLeftAligned) ? firstCompareSprite.width / 2 : -firstCompareSprite.width / 2);
//            firstCompareSprite.y = newFirstPosition.y + firstCompareSprite_offsetY;
//
//            // First Comparison Sprite mask
//            var firstComparisonSpriteMaskWidth : Float = firstCompareSprite.width + 6;
//            var firstComparisonSpriteMask : Sprite = m_animHelper.createMask(firstCompareSprite, firstComparisonSpriteMaskWidth, 10);
//            firstComparisonSpriteMask.x = firstCompareSprite.x + ((isFirstLeftAligned) ? firstComparisonSpriteMaskWidth + 1 : -firstComparisonSpriteMaskWidth - 1);
//            firstComparisonSpriteMask.y = firstCompareSprite.y;
//            var firstComparisonSpriteMask_finalX : Float = firstComparisonSpriteMask.x + ((isFirstLeftAligned) ? -firstComparisonSpriteMaskWidth : firstComparisonSpriteMaskWidth);
//            m_animController.addChild(firstComparisonSpriteMask);
//
//            // Second Comparison Sprite
//            var secondFillAmount : Float = second.fraction.value;
//            secondModule.fillStartFraction = benchmarkFraction;
//            secondFillAmount = Math.abs(benchmarkFraction.value - secondFillAmount);
//            var secondCompareSprite : Sprite = new Sprite();
//            secondCompareSprite.visible = false;
//            m_animHelper.trackDisplay(secondCompareSprite);
//            m_animController.addChild(secondCompareSprite);
//            secondModule.paintColoredFillLine(secondCompareSprite);
//            secondCompareSprite.x = benchmarkLine.x + ((isSecondLeftAligned) ? secondCompareSprite.width / 2 : -secondCompareSprite.width / 2);
//            secondCompareSprite.y = newSecondPosition.y + secondCompareSprite_offsetY;
//
//            // Second Comparison Sprite mask
//            var secondComparisonSpriteMaskWidth : Float = secondCompareSprite.width + 6;
//            var secondComparisonSpriteMask : Sprite = m_animHelper.createMask(secondCompareSprite, secondComparisonSpriteMaskWidth, 10);
//            secondComparisonSpriteMask.x = secondCompareSprite.x + ((isSecondLeftAligned) ? secondComparisonSpriteMaskWidth + 1 : -secondComparisonSpriteMaskWidth - 1);
//            secondComparisonSpriteMask.y = secondCompareSprite.y;
//            var secondComparisonSpriteMask_finalX : Float = secondComparisonSpriteMask.x + ((isSecondLeftAligned) ? -secondComparisonSpriteMaskWidth : secondComparisonSpriteMaskWidth);
//            m_animController.addChild(secondComparisonSpriteMask);
//
//            // Compare Positioning
//            var isLeftAligned : Bool = (isFirstLeftAligned || isSecondLeftAligned);
//            var fillCompareOffsetPosition : Point = new Point(newFirstPosition.x + benchmarkOffsetX, 0);
//            var firstCompareOffsetX : Float = fillCompareOffsetPosition.x + ((isLeftAligned) ? firstCompareSprite.width / 2 : -firstCompareSprite.width / 2);
//            var secondCompareOffsetX : Float = fillCompareOffsetPosition.x + ((isLeftAligned) ? secondCompareSprite.width / 2 : -secondCompareSprite.width / 2);
//            var firstComparePosition : Point = new Point(firstCompareOffsetX, fillCompareOffsetPosition.y - firstCompareSprite.height / 2);
//            var secondComparePosition : Point = new Point(secondCompareOffsetX, fillCompareOffsetPosition.y + secondCompareSprite.height / 2);
//        }
//
//        // Ensure the benchmark parts are displayed above the compare segments
//        m_animController.addChild(benchmarkNR);
//        m_animController.addChild(benchmarkLine);
//        m_animController.addChild(benchmarkLineMask);
//
//        // First's segment for compare View
//        var firstSegmentHolder : Sprite = new Sprite();
//        var firstSegment : Sprite = new Sprite();
//        m_animController.addChild(firstSegmentHolder);
//        m_animHelper.trackDisplay(firstSegmentHolder);
//        firstSegmentHolder.addChild(firstSegment);
//        m_animHelper.trackDisplay(firstSegment);
//
//        // Second's segment for compare View
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
//        var winningNR : NumberRenderer;
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
//
//            // Setup winning NR
//            winningNR = m_animHelper.createNumberRenderer(winningView.fraction, textColor, textGlowColor);
//            winningNR.visible = false;
//            m_animController.addChild(winningNR);
//        }
//
//        // Benchmark Text
//        var resultEndScale : Float = 1.5;
//        var benchmarkText : TextField = m_animHelper.createTextField(" is closer to ", textColor, textGlowColor);
//        m_animController.addChild(benchmarkText);
//        benchmarkText.scaleX = resultEndScale;
//        benchmarkText.scaleY = resultEndScale;
//        benchmarkText.x = -benchmarkText.width / 2;
//        benchmarkText.y = newFirstPosition.y - firstModule.unitHeight / 2 - NumberlineConstants.TICK_EXTENSION_DISTANCE - NumberlineConstants.ANIMATION_MARGIN_TEXT_LARGE - benchmarkText.height / 2;
//        benchmarkText.alpha = 0;
//        benchmarkText.visible = true;
//
//        // Benchmark Fraction
//        var benchmarkFrac : NumberRenderer = m_animHelper.createNumberRenderer(benchmarkFraction, textColor, textGlowColor);
//        m_animController.addChild(benchmarkFrac);
//        benchmarkFrac.scaleX = resultEndScale;
//        benchmarkFrac.scaleY = resultEndScale;
//        benchmarkFrac.x = benchmarkText.x + benchmarkText.width + benchmarkFrac.width / 2;
//        benchmarkFrac.y = benchmarkText.y + benchmarkText.height / 2;
//        benchmarkFrac.alpha = 0;
//        benchmarkFrac.visible = true;
//
//        // Question Text
//        var questionText : TextField = m_animHelper.createTextField("?", textColor, textGlowColor);
//        m_animController.addChild(questionText);
//        questionText.scaleX = resultEndScale;
//        questionText.scaleY = resultEndScale;
//        questionText.x = benchmarkText.x - questionText.width;
//        questionText.y = benchmarkText.y;
//        questionText.alpha = 0;
//        questionText.visible = true;
//        var winningNRFinalPosition : Point = new Point(questionText.x + questionText.width / 2, questionText.y + questionText.height / 2);
//
//        // Equal Text
//        var equalTextHolder : Sprite = new Sprite();
//        m_animHelper.trackDisplay(equalTextHolder);
//        m_animController.addChild(equalTextHolder);
//        equalTextHolder.x = 0;
//        equalTextHolder.y = benchmarkText.y + benchmarkText.height / 2;
//        var equalText : TextField = m_animHelper.createTextField("Equal distance", textColor, textGlowColor);
//        equalTextHolder.addChild(equalText);
//        equalText.scaleX = resultEndScale;
//        equalText.scaleY = resultEndScale;
//        equalText.x = -equalText.width / 2;
//        equalText.y = -equalText.height / 2;
//        equalText.alpha = 0;
//        equalText.visible = false;
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DURATION_POSITION);
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
//        positionStep.addTween(0, new GTween(benchmarkText, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(benchmarkFrac, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(questionText, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        // Show benchmark value, with emphasis
//        var showBenchmark_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK);
//        var showBenchmark_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK);
//        var showBenchmarkStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_BENCHMARK, showBenchmark_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_BENCHMARK);
//        showBenchmarkStep.addCallback(0, prepForShowBenchmark, null, prepForShowBenchmark_reverse);
//        var showBenchmarkLineStart : Float = .1;
//        var showBenchmarkValueStart : Float = showBenchmarkLineStart + showBenchmark_unitDuration;
//        showBenchmarkStep.addTween(showBenchmarkLineStart, new GTween(benchmarkLineMask, showBenchmark_unitDuration, {
//                    y : benchmarkLineMask_finalY
//                }));
//        showBenchmarkStep.addTween(showBenchmarkValueStart, new GTween(benchmarkNR, showBenchmark_unitDuration / 2, {
//                    alpha : 1
//                }));
//        showBenchmarkStep.addTweenSet(showBenchmarkValueStart, FVEmphasis.computePulseTweens(benchmarkNR, showBenchmark_unitDuration, 1.5, 1.5, NumberlineConstants.PULSE_SCALE_GENERAL));
//        m_animHelper.appendStep(showBenchmarkStep);
//
//        // Compare
//        if (doCompare)
//        {
//            var compare_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE);
//            var compare_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DURATION_COMPARE);
//            var compareStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_COMPARE, compare_unitDelay, CgsFVConstants.STEP_TYPE_COMPARE);
//            compareStep.addCallback(0, prepForCompare, null, prepForCompare_reverse);
//            var emphasizeFirstValue_startTime : Float = .1;
//            var dropFirstLine_startTime : Float = emphasizeFirstValue_startTime + compare_unitDuration;
//            var showFirstCompareLine_startTime : Float = dropFirstLine_startTime + compare_unitDuration;
//            var moveFirstCompareLine_startTime : Float = showFirstCompareLine_startTime + compare_unitDuration + compare_unitDelay;
//            var hideFirstLine_startTime : Float = moveFirstCompareLine_startTime + compare_unitDuration;
//            var emphasizeSecondValue_startTime : Float = hideFirstLine_startTime + compare_unitDuration + compare_unitDelay;
//            var dropSecondLine_startTime : Float = emphasizeSecondValue_startTime + compare_unitDuration;
//            var showSecondCompareLine_startTime : Float = dropSecondLine_startTime + compare_unitDuration;
//            var moveSecondCompareLine_startTime : Float = showSecondCompareLine_startTime + compare_unitDuration + compare_unitDelay;
//            var hideSecondLine_startTime : Float = moveSecondCompareLine_startTime + compare_unitDuration;
//            compareStep.addTweenSet(emphasizeFirstValue_startTime, FVEmphasis.computePulseTweens(firstSegment, compare_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//            compareStep.addTween(dropFirstLine_startTime, new GTween(firstValueLineMask, compare_unitDuration, {
//                        y : firstValueLineMask_finalY
//                    }));
//            compareStep.addTween(showFirstCompareLine_startTime, new GTween(firstComparisonSpriteMask, compare_unitDuration, {
//                        x : firstComparisonSpriteMask_finalX
//                    }));
//            compareStep.addTween(moveFirstCompareLine_startTime, new GTween(firstCompareSprite, compare_unitDuration, {
//                        x : firstComparePosition.x,
//                        y : firstComparePosition.y
//                    }));
//            compareStep.addTween(moveFirstCompareLine_startTime, new GTween(firstComparisonSpriteMask, compare_unitDuration, {
//                        x : firstComparePosition.x,
//                        y : firstComparePosition.y
//                    }));
//            compareStep.addTween(hideFirstLine_startTime, new GTween(firstValueLine, compare_unitDuration, {
//                        alpha : 0
//                    }));
//            compareStep.addTweenSet(emphasizeSecondValue_startTime, FVEmphasis.computePulseTweens(secondSegment, compare_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_SEGMENT));
//            compareStep.addTween(dropSecondLine_startTime, new GTween(secondValueLineMask, compare_unitDuration, {
//                        y : secondValueLineMask_finalY
//                    }));
//            compareStep.addTween(showSecondCompareLine_startTime, new GTween(secondComparisonSpriteMask, compare_unitDuration, {
//                        x : secondComparisonSpriteMask_finalX
//                    }));
//            compareStep.addTween(moveSecondCompareLine_startTime, new GTween(secondCompareSprite, compare_unitDuration, {
//                        x : secondComparePosition.x,
//                        y : secondComparePosition.y
//                    }));
//            compareStep.addTween(moveSecondCompareLine_startTime, new GTween(secondComparisonSpriteMask, compare_unitDuration, {
//                        x : secondComparePosition.x,
//                        y : secondComparePosition.y
//                    }));
//            compareStep.addTween(hideSecondLine_startTime, new GTween(secondValueLine, compare_unitDuration, {
//                        alpha : 0
//                    }));
//            m_animHelper.appendStep(compareStep);
//        }
//
//        // Show result, with emphasis
//        var showResult_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT);
//        var showResult_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DURATION_SHOW_RESULT);
//        var showResultStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_RESULT, showResult_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_RESULT);
//        showResultStep.addCallback(0, prepForResult, null, prepForResult_reverse);
//        if (winnerExists)
//        {
//            var showResult_emphasizeWinner_startTime : Float = .1;
//            var showResult_winnerPulse_startTime : Float = showResult_emphasizeWinner_startTime + showResult_unitDuration + showResult_unitDelay;
//            var showResult_winnerMove_startTime : Float = showResult_winnerPulse_startTime + showResult_unitDuration;
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
//            showResultStep.addTweenSet(showResult_winnerPulse_startTime, FVEmphasis.computePulseTweens(winningNR, showResult_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL_LARGE));
//            showResultStep.addCallback(showResult_winnerMove_startTime, reShowWinningValue, null, reShowWinningValue_reverse);
//            showResultStep.addTween(showResult_winnerMove_startTime, new GTween(questionText, showResult_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTween(showResult_winnerMove_startTime, new GTween(winningNR, showResult_unitDuration, {
//                        x : winningNRFinalPosition.x,
//                        y : winningNRFinalPosition.y,
//                        scaleX : resultEndScale,
//                        scaleY : resultEndScale
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//        else
//        {
//            showResultStep.addTween(.1, new GTween(benchmarkText, showResult_unitDuration / 4, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTween(.1, new GTween(benchmarkFrac, showResult_unitDuration / 4, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTween(.1, new GTween(questionText, showResult_unitDuration / 4, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTween(.1, new GTween(equalText, showResult_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTweenSet(.1, FVEmphasis.computePulseTweens(equalTextHolder, showResult_unitDuration, 1, 1, NumberlineConstants.PULSE_SCALE_GENERAL));
//        }
//        m_animHelper.appendStep(showResultStep);
//
//        // Fade out
//        var fadeOut_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DELAY_AFTER_FADE);
//        var fadeOut_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DURATION_FADE);
//        var fadeOutStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, fadeOut_unitDelay, CgsFVConstants.STEP_TYPE_FADE);
//        if (doCompare)
//        {
//            fadeOutStep.addTween(0, new GTween(firstCompareSprite, fadeOut_unitDuration, {
//                        alpha : 0
//                    }));
//            fadeOutStep.addTween(0, new GTween(secondCompareSprite, fadeOut_unitDuration, {
//                        alpha : 0
//                    }));
//        }
//        fadeOutStep.addTween(0, new GTween(benchmarkLine, fadeOut_unitDuration, {
//                    alpha : 0
//                }));
//        fadeOutStep.addTween(0, new GTween(benchmarkNR, fadeOut_unitDuration, {
//                    alpha : 0
//                }));
//        fadeOutStep.addCallback(fadeOut_unitDuration, finishCompare, null, finishCompare_reverse);
//        m_animHelper.appendStep(fadeOutStep);
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(NumberlineConstants.TIME_COMPARE_TARGET_DURATION_UNPOSITION);
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
//            unpositionStep.addTween(unposition_unitDuration / 2, new GTween(benchmarkText, unposition_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            unpositionStep.addTween(unposition_unitDuration / 2, new GTween(benchmarkFrac, unposition_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            unpositionStep.addTween(unposition_unitDuration / 2, new GTween(winningNR, unposition_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//        else
//        {
//            unpositionStep.addTween(unposition_unitDuration / 2, new GTween(equalText, unposition_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
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
//        }  // Makes the benchmark line visible  ;
//
//
//
//        var prepForShowBenchmark : Void->Void = function() : Void
//        {
//            benchmarkLine.visible = true;
//
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
//        }
//
//        function prepForShowBenchmark_reverse() : Void
//        {
//            benchmarkLine.visible = false;
//
//            firstModule.doShowSegment = true;
//            first.redraw(true);
//            firstSegmentHolder.visible = false;
//
//            secondModule.doShowSegment = true;
//            second.redraw(true);
//            secondSegmentHolder.visible = false;
//        }  // Prepares for the compare step, pulsing the numbers and dropping lines  ;
//
//
//
//        var prepForCompare : Void->Void = function() : Void
//        {
//            firstValueLine.visible = true;
//            firstValueLine.alpha = 1;
//            secondValueLine.visible = true;
//            secondValueLine.alpha = 1;
//
//            firstCompareSprite.visible = true;
//            secondCompareSprite.visible = true;
//        }
//
//        var prepForCompare_reverse : Void->Void = function() : Void
//        {
//            firstValueLine.visible = false;
//            secondValueLine.visible = false;
//
//            firstCompareSprite.visible = false;
//            secondCompareSprite.visible = false;
//        }
//
//        var prepForResult : Void->Void = function() : Void
//        {
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
//
//                winningNR.x = winningView.x + winningModule.valueNRPosition.x;
//                winningNR.y = winningView.y + winningModule.valueNRPosition.y;
//                winningNR.visible = true;
//
//                winningModule.valueNumDisplayAlpha = 0;
//                winningView.redraw(true);
//            }
//            else
//            {
//                equalText.alpha = 0;
//                equalText.visible = true;
//            }
//        }
//
//        function prepForResult_reverse() : Void
//        {
//            if (winnerExists)
//            {
//                winningGlowLine.visible = false;
//                winningGlowDot.visible = false;
//
//                winningNR.visible = false;
//
//                winningModule.valueNumDisplayAlpha = 1;
//                winningView.redraw(true);
//            }
//            else
//            {
//                equalText.visible = false;
//            }
//        }  // Re shows the fraction value of the first  ;
//
//
//
//        var reShowWinningValue : Void->Void = function() : Void
//        {
//            // Show value of first
//            winningModule.valueNumDisplayAlpha = 1;
//            winningView.redraw(true);
//        }
//
//        function reShowWinningValue_reverse() : Void
//        {
//            // Hide value of first
//            winningModule.valueNumDisplayAlpha = 0;
//            winningView.redraw(true);
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
//
//            if (doCompare)
//            {
//                firstCompareSprite.visible = false;
//                secondCompareSprite.visible = false;
//            }
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
//
//            if (doCompare)
//            {
//                firstCompareSprite.visible = true;
//                secondCompareSprite.visible = true;
//            }
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
//
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

