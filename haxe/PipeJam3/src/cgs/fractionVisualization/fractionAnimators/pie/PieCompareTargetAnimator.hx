package cgs.fractionVisualization.fractionAnimators.pie;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.PieFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.PieConstants;
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.VisualizationUtilities;
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
import flash.filters.BlurFilter;

/**
	 * ...
	 * @author Mike
	 */
class PieCompareTargetAnimator implements IFractionAnimator
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
    private var m_addFractionViewCallback : Function;
    
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
        m_addFractionViewCallback = null;
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
    private function endAnimation() : Void
    {
        m_animHelper.reset();
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
        return CgsFVConstants.PIE_STANDARD_COMPARE_BENCHMARK;
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
//        var firstModule : PieFractionModule = try cast(first.module, PieFractionModule) catch(e:Dynamic) null;
//        var secondModule : PieFractionModule = try cast(second.module, PieFractionModule) catch(e:Dynamic) null;
//
//        firstModule.fillStartFraction = benchmarkFraction;
//        secondModule.fillStartFraction = benchmarkFraction;
//
//        // Position data
//        var spanBetweenPieCenters : Float = (firstModule.unitWidth + firstModule.distanceBetweenPies);
//        var origFirstPosition : Point = new Point(first.x, first.y);
//        var origSecondPosition : Point = new Point(second.x, second.y);
//
//        var newFirstPosition : Point = new Point(PieConstants.COMPARE_RESULT_LOCATION.x, PieConstants.COMPARE_RESULT_LOCATION.y - spanBetweenPieCenters);  // origFirstPosition;
//        var newSecondPosition : Point = new Point(PieConstants.COMPARE_RESULT_LOCATION.x, PieConstants.COMPARE_RESULT_LOCATION.y + spanBetweenPieCenters);  // origSecondPosition;
//
//        var adjustXalignment : Float = (secondModule.numBaseUnits - firstModule.numBaseUnits) * spanBetweenPieCenters / 2;
//
//        // Align based on larger one
//        ((secondModule.numBaseUnits > firstModule.numBaseUnits)) ?
//        newFirstPosition.x -= adjustXalignment :
//        newSecondPosition.x += adjustXalignment;
//
//        // Compare data
//        var firstSegment : Sprite = new Sprite();
//        firstModule.segmentTo(firstSegment, first.fraction, firstModule.numBaseUnits, first.foregroundColor, benchmarkFraction);
//        firstSegment.x = newFirstPosition.x;
//        firstSegment.y = newFirstPosition.y;
//        firstSegment.alpha = 0;
//
//        m_animHelper.trackDisplay(firstSegment);
//        var secondSegment : Sprite = new Sprite();
//        secondModule.segmentTo(secondSegment, second.fraction, secondModule.numBaseUnits, second.foregroundColor, benchmarkFraction);
//        secondSegment.x = newSecondPosition.x;
//        secondSegment.y = newSecondPosition.y;
//        secondSegment.alpha = 0;
//
//        m_animHelper.trackDisplay(secondSegment);
//
//        // Emphasis data
//        var winnerValue : Float = VisualizationUtilities.compareByComparisonType(comparisonType, first.fraction, second.fraction, details);
//        var winnerExists : Bool = winnerValue != 0;
//        var winningView : CgsFractionView;
//        var winningModule : PieFractionModule;
//        // var winningSegmentHolder:Sprite;
//        var winningSegment : Sprite;
//        var winningNR : NumberRenderer;
//        var winningPosition : Point;
//        var winningGlowFinalPosition : Point;
//        if (winnerExists)
//        {
//            // Setup winning view
//            winningView = ((winnerValue > 0)) ? first : second;
//            winningModule = try cast(winningView.module, PieFractionModule) catch(e:Dynamic) null;
//            winningGlowFinalPosition = ((winnerValue > 0)) ? newFirstPosition : newSecondPosition;
//
//            // Glow
//            var glowColor : Int = (Reflect.hasField(details, CgsFVConstants.WINNING_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.WINNING_GLOW_COLOR)) : CgsFVConstants.ANIMATION_WINNING_GLOW_COLOR;
//            var winningGlowAreas : Array<Sprite> = winningModule.emphasisBackbones(glowColor, PieConstants.COMPARE_GLOW_AREA_SCALING);
//            for (wIndex in 0...winningGlowAreas.length)
//            {
//                winningGlowAreas[wIndex].visible = true;
//                winningGlowAreas[wIndex].alpha = 0.0;
//                winningGlowAreas[wIndex].x += winningGlowFinalPosition.x;
//                winningGlowAreas[wIndex].y = winningGlowFinalPosition.y;
//                m_animHelper.trackDisplay(winningGlowAreas[wIndex]);
//                m_animController.addChildAt(winningGlowAreas[wIndex], m_animController.getChildIndex(winningView));
//                var winningGlowBlur : BlurFilter = new BlurFilter(PieConstants.COMPARE_GLOW_AREA_BLUR.x, PieConstants.COMPARE_GLOW_AREA_BLUR.y);
//                winningGlowAreas[wIndex].filters = [winningGlowBlur];
//            }
//
//            // Setup winning segment
//            winningSegment = ((winnerValue > 0)) ? firstSegment : secondSegment;
//
//            // Setup winning NR
//            winningNR = m_animHelper.createNumberRenderer(winningView.fraction, textColor, textGlowColor);
//            winningNR.visible = false;
//            m_animController.addChild(winningNR);
//        }
//
//        // Put the larger value underneath the smaller value
//        if (winnerValue > 0)
//        {
//            m_animController.addChild(secondSegment);
//            m_animController.addChild(firstSegment);
//        }
//        else
//        {
//            m_animController.addChild(firstSegment);
//            m_animController.addChild(secondSegment);
//        }
//
//        var movingBenchmarkView : NumberRenderer = m_animHelper.createNumberRenderer(benchmarkFraction, textColor, textGlowColor);
//        movingBenchmarkView.alpha = 0;
//        movingBenchmarkView.scaleX = 1.5;
//        movingBenchmarkView.scaleY = 1.5;
//        // set x and y
//        movingBenchmarkView.x = newFirstPosition.x - (firstModule.numBaseUnits * spanBetweenPieCenters / 2) - PieConstants.COMPARE_TARGET_MOVING_BENCHMARK_MARGIN;
//
//        m_animHelper.trackDisplay(movingBenchmarkView);
//        m_animController.addChild(movingBenchmarkView);
//
//        // Benchmark Line 1
//        var benchmarkLineMaskFinal1 : Point = new Point(0, 0);
//        var benchmark1Sprites : Array<Sprite> = buildBenchmarkLine(firstModule, newFirstPosition, benchmarkLineMaskFinal1);
//        var benchmarkLine1 : Sprite = benchmark1Sprites[0];
//        var benchmarkLineMask1 : Sprite = benchmark1Sprites[1];
//
//        // Benchmark Line 2
//        var benchmarkLineMaskFinal2 : Point = new Point(0, 0);
//        var benchmark2Sprites : Array<Sprite> = buildBenchmarkLine(secondModule, newSecondPosition, benchmarkLineMaskFinal2);
//        var benchmarkLine2 : Sprite = benchmark2Sprites[0];
//        var benchmarkLineMask2 : Sprite = benchmark2Sprites[1];
//        // Benchmark Line 3 (Result)
//
//        var benchmarkLineMaskFinal3 : Point = new Point(0, 0);
//        var averagePoint : Point = new Point(newFirstPosition.x, (newFirstPosition.y + newSecondPosition.y) / 2);
//        var benchmark3Sprites : Array<Sprite> = buildBenchmarkLine(firstModule, averagePoint, benchmarkLineMaskFinal3);
//        var benchmarkLine3 : Sprite = benchmark3Sprites[0];
//        var benchmarkLineMask3 : Sprite = benchmark3Sprites[1];
//        movingBenchmarkView.y = PieConstants.COMPARE_TARGET_RESULT_LOCATION.y;
//
//        // Benchmark Text
//        var resultEndScale : Float = 1.5;
//        var benchmarkText : TextField = m_animHelper.createTextField(" is closer to ", textColor, textGlowColor);
//        m_animController.addChild(benchmarkText);
//        benchmarkText.scaleX = resultEndScale;
//        benchmarkText.scaleY = resultEndScale;
//        benchmarkText.x = -benchmarkText.width / 2;
//        benchmarkText.y = newFirstPosition.y - firstModule.unitHeight / 2 - PieConstants.TICK_EXTENSION_DISTANCE - PieConstants.ANIMATION_MARGIN_TEXT - benchmarkText.height / 2;
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
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DURATION_POSITION);
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
//        //m_animHelper.appendStep(positionStep);  NOT NEEDED, Done on GO!
//        positionStep.addTween(0, new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(position_unitDuration / 2, moveValueToTop, null, moveValueToTop_reverse);
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
//
//        positionStep.addTween(position_unitDuration * (2 / 3), new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        // Show benchmark value, with emphasis
//        var showBenchmark_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK);
//        var showBenchmark_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK);
//        var cumulativeBenchmarkTime : Float = 0;
//
//        var showBenchmarkStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_BENCHMARK, showBenchmark_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_BENCHMARK);
//        showBenchmarkStep.addTween(cumulativeBenchmarkTime, new GTween(benchmarkLineMask1, showBenchmark_unitDuration, {
//                    x : benchmarkLineMaskFinal1.x,
//                    y : benchmarkLineMaskFinal1.y
//                }));
//        cumulativeBenchmarkTime += showBenchmark_unitDuration;
//        showBenchmarkStep.addTween(cumulativeBenchmarkTime, new GTween(benchmarkLineMask2, showBenchmark_unitDuration, {
//                    x : benchmarkLineMaskFinal2.x,
//                    y : benchmarkLineMaskFinal2.y
//                }));
//        cumulativeBenchmarkTime += showBenchmark_unitDuration;
//        showBenchmarkStep.addTween(cumulativeBenchmarkTime, new GTween(benchmarkLineMask3, showBenchmark_unitDuration, {
//                    x : benchmarkLineMaskFinal3.x,
//                    y : benchmarkLineMaskFinal3.y
//                }));
//        cumulativeBenchmarkTime += showBenchmark_unitDuration;
//        showBenchmarkStep.addTween(cumulativeBenchmarkTime, new GTween(movingBenchmarkView, showBenchmark_unitDuration / 2, {
//                    alpha : 1
//                }));
//        showBenchmarkStep.addTweenSet(cumulativeBenchmarkTime, FVEmphasis.computePulseTweens(movingBenchmarkView, showBenchmark_unitDuration, 1.5, 1.5, PieConstants.PULSE_SCALE_GENERAL));
//        cumulativeBenchmarkTime += showBenchmark_unitDuration;
//
//        m_animHelper.appendStep(showBenchmarkStep);
//
//        // Unless one of the segments is the same as the benchmark, compare them.
//        if (first.fraction.value != benchmarkFraction.value && second.fraction.value != benchmarkFraction.value)
//        {
//            var compare_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE);
//            var compare_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DURATION_COMPARE);
//
//            var compareStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_COMPARE, compare_unitDelay, CgsFVConstants.STEP_TYPE_COMPARE);
//            var fadeOutOriginalFirst : GTween = new GTween(firstModule, compare_unitDuration, {
//                segmentAlpha : 0
//            });
//            var fadeInOriginalFirst : GTween = new GTween(firstModule, compare_unitDuration, {
//                segmentAlpha : 1
//            });
//            var fadeInFirst : GTween = new GTween(firstSegment, compare_unitDuration, {
//                alpha : 1
//            });
//            var fadeOutOriginalSecond : GTween = new GTween(secondModule, compare_unitDuration, {
//                segmentAlpha : 0
//            });
//            var fadeInSecond : GTween = new GTween(secondSegment, compare_unitDuration, {
//                alpha : 1
//            });
//            var fadeInOriginalSecond : GTween = new GTween(secondModule, compare_unitDuration, {
//                segmentAlpha : 1
//            });
//            var firstCompareRotation : Float = 0;
//            var secondCompareRotation : Float = 0;
//
//            // if one is less than the benchmark and one is over, rotate under segment to benchmark
//            if ((first.fraction.value > benchmarkFraction.value && second.fraction.value < benchmarkFraction.value) ||
//                (first.fraction.value < benchmarkFraction.value && second.fraction.value > benchmarkFraction.value))
//            {
//                if (first.fraction.value < benchmarkFraction.value)
//                {
//                    firstCompareRotation = (first.fraction.value - benchmarkFraction.value) * 360;
//                }
//                else
//                {
//                    secondCompareRotation = (second.fraction.value - benchmarkFraction.value) * 360;
//                }
//            }
//
//            var moveFirst : GTween = new GTween(firstSegment, compare_unitDuration, {
//                y : PieConstants.COMPARE_TARGET_RESULT_LOCATION.y,
//                alpha : PieConstants.COMPARE_FILL_ALPHA,
//                rotation : firstCompareRotation
//            });
//            var moveSecond : GTween = new GTween(secondSegment, compare_unitDuration, {
//                y : PieConstants.COMPARE_TARGET_RESULT_LOCATION.y,
//                alpha : PieConstants.COMPARE_FILL_ALPHA,
//                rotation : secondCompareRotation
//            });
//
//            var cumulativeCompareTime : Float = 0;
//            compareStep.addCallback(cumulativeCompareTime, prepCompare, null, prepCompare_reverse);
//
//            compareStep.addTween(cumulativeCompareTime, fadeOutOriginalFirst);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, new GTween(firstModule, compare_unitDuration, {
//                        fillPercent : 1.0
//                    }));
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, fadeInFirst);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addCallback(cumulativeCompareTime, disappearFill, [firstModule], disappearFill_reverse, [firstModule]);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, moveFirst);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, fadeInOriginalFirst);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, fadeOutOriginalSecond);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, new GTween(secondModule, compare_unitDuration, {
//                        fillPercent : 1.0
//                    }));
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, fadeInSecond);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addCallback(cumulativeCompareTime, disappearFill, [secondModule], disappearFill_reverse, [secondModule]);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, moveSecond);
//            cumulativeCompareTime += compare_unitDuration;
//
//            compareStep.addTween(cumulativeCompareTime, fadeInOriginalSecond);
//            cumulativeCompareTime += compare_unitDuration;
//
//            m_animHelper.appendStep(compareStep);
//        }
//
//        // Show result, with emphasis
//        var showResult_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT);
//        var showResult_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DURATION_SHOW_RESULT);
//
//        var showResultStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_RESULT, showResult_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_RESULT);
//        showResultStep.addCallback(0, prepForResult, [true], prepForResult, [false]);
//        if (winnerExists)
//        {
//            //var showResult_winnerPulse_startTime:Number = .1;
//            var showResult_emphasizeWinner_startTime : Float = .1;
//            var showResult_winnerPulse_startTime : Float = showResult_emphasizeWinner_startTime + showResult_unitDuration / 2 + showResult_unitDelay;
//            var showResult_winnerMove_startTime : Float = showResult_winnerPulse_startTime + showResult_unitDuration;
//            for (wIndex in 0...winningGlowAreas.length)
//            {
//                showResultStep.addTween(showResult_emphasizeWinner_startTime, new GTween(winningGlowAreas[wIndex], showResult_unitDuration / 4, {
//                            alpha : .7
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//                showResultStep.addTweenSet(showResult_emphasizeWinner_startTime, FVEmphasis.computePulseTweens(winningGlowAreas[wIndex], showResult_unitDuration / 2, 1, 1, PieConstants.COMPARE_PULSE_SCALE));
//            }
//            showResultStep.addTweenSet(showResult_winnerPulse_startTime, FVEmphasis.computePulseTweens(winningNR, showResult_unitDuration, 1, 1, PieConstants.PULSE_SCALE_GENERAL_LARGE));
//            showResultStep.addCallback(showResult_winnerMove_startTime, reShowWinningValue, [1], reShowWinningValue, [0]);
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
//            showResultStep.addTweenSet(.1, FVEmphasis.computePulseTweens(equalTextHolder, showResult_unitDuration, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//        }
//
//        m_animHelper.appendStep(showResultStep);
//
//
//
//        // Fade out
//        var fade_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DELAY_AFTER_FADE);
//        var fade_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DURATION_FADE);
//
//        var fadeOutStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, fade_unitDelay, CgsFVConstants.STEP_TYPE_FADE);
//        var fadeOutFirstSegment : GTween = new GTween(firstSegment, fade_unitDuration, {
//            alpha : 0
//        });
//        var fadeOutSecondSegment : GTween = new GTween(secondSegment, fade_unitDuration, {
//            alpha : 0
//        });
//        var fadeOutBenchmarkLine1 : GTween = new GTween(benchmarkLine1, fade_unitDuration, {
//            alpha : 0
//        });
//        var fadeOutBenchmarkLine2 : GTween = new GTween(benchmarkLine2, fade_unitDuration, {
//            alpha : 0
//        });
//        var fadeOutBenchmarkLine3 : GTween = new GTween(benchmarkLine3, fade_unitDuration, {
//            alpha : 0
//        });
//        var fadeOutMovingBenchmark : GTween = new GTween(movingBenchmarkView, fade_unitDuration, {
//            alpha : 0
//        });
//        fadeOutStep.addTween(0, fadeOutFirstSegment);
//        fadeOutStep.addTween(0, fadeOutSecondSegment);
//        fadeOutStep.addTween(0, fadeOutBenchmarkLine1);
//        fadeOutStep.addTween(0, fadeOutBenchmarkLine2);
//        fadeOutStep.addTween(0, fadeOutBenchmarkLine3);
//        fadeOutStep.addTween(0, fadeOutMovingBenchmark);
//        m_animHelper.appendStep(fadeOutStep);
//
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_TARGET_DURATION_UNPOSITION);
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween(first, unposition_unitDuration, {
//                    x : origFirstPosition.x,
//                    y : origFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(second, unposition_unitDuration, {
//                    x : origSecondPosition.x,
//                    y : origSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        // fade out text results
//        unpositionStep.addTween(0, new GTween(benchmarkText, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(benchmarkFrac, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(questionText, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(equalText, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(winningNR, unposition_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        // fade out and move glow
//        if (winnerExists)
//        {
//            for (wIndex in 0...winningGlowAreas.length)
//            {
//                var deEmphasizeGlow : GTween = new GTween(winningGlowAreas[wIndex], unposition_unitDuration / 4, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                });
//                unpositionStep.addTween(0, deEmphasizeGlow);
//            }
//        }
//
//        // Go
//        m_animHelper.animate(compareComplete, positionStep, unpositionStep);
//
//        /**
//			 * Completion
//			**/
//
//        // Callback
//        function compareComplete() : Void
//        {
//            endAnimation();
//            if (completeCallback != null)
//            {
//                completeCallback();
//            }
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
//        var prepCompare : Void->Void = function() : Void
//        {
//            firstModule.fillAlpha = 1.0;
//            firstModule.fillColor = firstModule.segmentColor;
//            secondModule.fillAlpha = 1.0;
//            secondModule.fillColor = secondModule.segmentColor;
//        }
//
//        var prepCompare_reverse : Void->Void = function() : Void
//        {
//            firstModule.fillAlpha = 0;
//            secondModule.fillAlpha = 0;
//        }
//
//        var disappearFill : PieFractionModule->Void = function(module : PieFractionModule) : Void
//        {
//            module.fillAlpha = 0;
//        }
//
//        function disappearFill_reverse(module : PieFractionModule) : Void
//        {
//            module.fillAlpha = 1.0;
//        }  // Re shows the fraction value of the first  ;
//
//
//
//        var reShowWinningValue : Float->Void = function(alpha : Float) : Void
//        {
//            // Show value of first
//            winningModule.valueNumDisplayAlpha = alpha;  // 1;
//            winningView.redraw(true);
//        }
//
//
//        var prepForResult : Bool->Void = function(visible : Bool) : Void
//        {
//            if (winnerExists)
//            {
//                winningNR.x = winningView.x + winningModule.valueNRPosition.x;
//                winningNR.y = winningView.y + winningModule.valueNRPosition.y;
//                winningNR.visible = visible;  // true;
//
//                winningModule.valueNumDisplayAlpha = (visible) ? 0 : 1;
//                winningView.redraw(true);
//            }
//            else
//            {
//                equalText.alpha = (visible) ? 0 : 1;
//                equalText.visible = visible;
//            }
//        }
//
//
//        var buildBenchmarkLine : PieFractionModule->Point->Point->Array<Sprite> = function(module : PieFractionModule, newPosition : Point, benchmarkLineMaskFinal : Point) : Array<Sprite>
//        {
//            // Benchmark Line
//            var benchmarkLine_startY : Float = 0;  // newSecondPosition.y ;
//            var benchmarkLine_endY : Float = (module.unitWidth / 2 * PieConstants.COMPARE_TARGET_BENCHMARK_LINE_SCALING);
//            // new benchmarkLine returned
//            var benchmarkLine : Sprite = m_animHelper.createDashedLine(benchmarkLine_startY, benchmarkLine_endY);
//            //center of circle.  Line is registered from it's endpoint
//            benchmarkLine.x = newPosition.x - ((module.numBaseUnits - 1) * spanBetweenPieCenters / 2);
//            benchmarkLine.y = newPosition.y;
//            benchmarkLine.visible = true;
//            benchmarkLine.alpha = 1;
//            m_animController.addChild(benchmarkLine);
//
//            // Benchmark line mask
//            var benchmarkLineMaskHeight : Float = benchmarkLine.height + 6;
//            // new benchmarkLineMaske returned
//
//            var benchmarkLineMask : Sprite = m_animHelper.createMask(benchmarkLine, 10, benchmarkLineMaskHeight);
//            // center this prior to rotation
//            benchmarkLineMask.x = benchmarkLine.x;
//            benchmarkLineMask.y = benchmarkLine.y;
//            var benchmarkLineMask_startX : Float = benchmarkLineMask.x + (benchmarkLineMaskHeight / 2) * Math.cos(benchmarkFraction.value * 2 * Math.PI - Math.PI / 2);
//            var benchmarkLineMask_startY : Float = benchmarkLineMask.y - (benchmarkLineMaskHeight / 2) * Math.sin(benchmarkFraction.value * 2 * Math.PI - Math.PI / 2);
//            // position for mask altered
//            benchmarkLineMaskFinal.x = benchmarkLineMask.x - (benchmarkLineMaskHeight / 2) * Math.cos(benchmarkFraction.value * 2 * Math.PI - Math.PI / 2);
//            benchmarkLineMaskFinal.y = benchmarkLineMask.y + (benchmarkLineMaskHeight / 2) * Math.sin(benchmarkFraction.value * 2 * Math.PI - Math.PI / 2);
//            m_animController.addChild(benchmarkLineMask);
//            benchmarkLineMask.visible = true;
//            benchmarkLineMask.alpha = 1;
//            //line will go from center down.  Rotate to top then adjust for fraction
//            benchmarkLine.rotation = 180 - (benchmarkFraction.value * 360);
//            benchmarkLineMask.rotation = benchmarkLine.rotation;
//            // move in a backwards direction from movement of mask
//            benchmarkLineMask.x = benchmarkLineMask_startX;
//            benchmarkLineMask.y = benchmarkLineMask_startY;
//            var sprites : Array<Sprite> = new Array<Sprite>();
//            sprites.push(benchmarkLine);
//            sprites.push(benchmarkLineMask);
//            return sprites;
//        }
    }
}

