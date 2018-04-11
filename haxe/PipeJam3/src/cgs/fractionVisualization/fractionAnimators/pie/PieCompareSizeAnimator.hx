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
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.Sprite;
import openfl.geom.Point;
import flash.text.TextField;
import flash.filters.BlurFilter;

/**
	 * ...
	 * @author Mike
	 */
class PieCompareSizeAnimator implements IFractionAnimator
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
        m_animHelper = new AnimationHelper();
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
        return CgsFVConstants.PIE_STANDARD_COMPARE_SIZE;
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
//        // Create comparison fraction view
//        var compareView : CgsFractionView = first.clone();
//        compareView.fraction.init(0, 1);
//        var compareModule : PieFractionModule = (try cast(compareView.module, PieFractionModule) catch(e:Dynamic) null);
//        compareModule.valueNumDisplayAlpha = 0;
//        compareModule.unitNumDisplayAlpha = 0;
//        compareModule.valueTickDisplayAlpha = 0;
//        compareModule.unitTickDisplayAlpha = 0;
//        compareModule.doShowSegment = false;
//        compareView.x = PieConstants.COMPARE_SIZE_CENTER.x;
//        compareView.y = PieConstants.COMPARE_SIZE_CENTER.y;
//        compareView.alpha = 0;
//        compareView.redraw(true);
//        m_animHelper.trackFractionView(compareView);
//        m_animController.addChild(compareView);
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2);
//        var offsetY : Float = compareModule.unitHeight / 2 + PieConstants.TICK_EXTENSION_DISTANCE * 2 + PieConstants.ANIMATION_MARGIN_VERTICAL_SMALL * 2;
//        var newFirstPosition : Point = new Point(compareView.x + firstModule.totalWidth / 2 - offsetX, compareView.y - firstModule.unitHeight / 2 - offsetY);
//        var newSecondPosition : Point = new Point(compareView.x + secondModule.totalWidth / 2 - offsetX, compareView.y + secondModule.unitHeight / 2 + offsetY);
//
//        // Compare data
//        //			var firstSegment:Sprite = new Sprite();
//        //			firstModule.comparePeel(firstSegment, first.fraction, firstModule.numBaseUnits, first.foregroundColor);
//        //			firstSegment.visible = false;
//        var lastIndex : Float;
//        var firstSegmentsFirstIndex : Float;
//        var firstSegments : Array<Sprite> = firstModule.pulseSegments(first.foregroundColor);
//        for (fsIndex in 0...firstSegments.length)
//        {
//            firstSegments[fsIndex].visible = false;
//            m_animController.addChild(firstSegments[fsIndex]);
//            lastIndex = m_animController.getChildIndex(firstSegments[fsIndex]);
//            if (fsIndex == 0)
//            {
//                firstSegmentsFirstIndex = lastIndex;
//            }
//            m_animHelper.trackDisplay(firstSegments[fsIndex]);
//        }
//
//        var insertIndex : Float = firstSegmentsFirstIndex;
//        var secondSegments : Array<Sprite> = secondModule.pulseSegments(second.foregroundColor);
//        for (ssIndex in 0...secondSegments.length)
//        {
//            secondSegments[ssIndex].visible = false;
//            // If second is smaller, use lastIndex and update, otherwise use firstSegmentsFirstIndex
//            // so as to put this larger value under the first value
//            if (second.fraction.value <= first.fraction.value)
//            {
//                lastIndex++;
//                insertIndex = lastIndex;
//            }
//            m_animController.addChildAt(secondSegments[ssIndex], insertIndex);
//            m_animHelper.trackDisplay(secondSegments[ssIndex]);
//        }
//
//
//        // Emphasis data
//        var winnerValue : Float = VisualizationUtilities.compareByComparisonType(comparisonType, first.fraction, second.fraction, details);
//        var winnerExists : Bool = winnerValue != 0;
//        var winningView : CgsFractionView;
//        var winningModule : PieFractionModule;
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
//        }
//
//        // Compare Symbol
//        var resultEndScale : Float = 1.5;
//        var compareSymbol : TextField = m_animHelper.createTextField((comparisonType == CgsFVConstants.COMPARE_TYPE_GREATER_THAN) ? " >?" : " <?", textColor, textGlowColor);
//        m_animController.addChild(compareSymbol);
//        compareSymbol.scaleX = resultEndScale;
//        compareSymbol.scaleY = resultEndScale;
//        compareSymbol.x = -compareSymbol.width / 2;
//        compareSymbol.y = newFirstPosition.y - firstModule.unitHeight / 2 - PieConstants.ANIMATION_MARGIN_TEXT - compareSymbol.height / 2;
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
//        resultSymbolHolder.y = newFirstPosition.y - firstModule.unitHeight / 2 - PieConstants.ANIMATION_MARGIN_TEXT;
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
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DURATION_POSITION);
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
//                    unitNumDisplayAlpha : 0,
//                    unitTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, position_unitDuration, {
//                    unitNumDisplayAlpha : 0,
//                    unitTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0,
//                    valueTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(position_unitDuration / 2, moveValue, [firstModule, true], moveValue, [firstModule, false]);
//        positionStep.addTween(position_unitDuration * (2 / 3), new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1,
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(compareSymbol, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        // Compare
//        var compare_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_COMPARE);
//        var compare_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DURATION_COMPARE);
//        var compareStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_COMPARE, compare_unitDelay, CgsFVConstants.STEP_TYPE_COMPARE);
//        compareStep.addCallback(0, prepForCompare, null, prepForCompare_reverse);
//        var compare_showFirst_startTime : Float = .1;
//        var compare_moveFirst_startTime : Float = compare_showFirst_startTime + compare_unitDuration;
//        var compare_showSecond_startTime : Float = compare_moveFirst_startTime + compare_unitDuration;
//        var compare_moveSecond_startTime : Float = compare_showSecond_startTime + compare_unitDuration;
//        for (fsIndex in 0...firstSegments.length)
//        {
//            compareStep.addTween(compare_showFirst_startTime, new GTween(firstSegments[fsIndex], compare_unitDuration / 2, {
//                        alpha : PieConstants.FILL_ALPHA_COLORED
//                    }));
//            compareStep.addTweenSet(compare_showFirst_startTime, FVEmphasis.computePulseTweens(firstSegments[fsIndex], compare_unitDuration, 1, 1, PieConstants.COMPARE_PULSE_SCALE));
//            compareStep.addTween(compare_moveFirst_startTime, new GTween(firstSegments[fsIndex], compare_unitDuration, {
//                        y : compareView.y
//                    }));
//        }
//        for (ssIndex in 0...secondSegments.length)
//        {
//            compareStep.addTween(compare_showSecond_startTime, new GTween(secondSegments[ssIndex], compare_unitDuration / 2, {
//                        alpha : PieConstants.FILL_ALPHA_COLORED
//                    }));
//            compareStep.addTweenSet(compare_showSecond_startTime, FVEmphasis.computePulseTweens(secondSegments[ssIndex], compare_unitDuration, 1, 1, PieConstants.COMPARE_PULSE_SCALE));
//            compareStep.addTween(compare_moveSecond_startTime, new GTween(secondSegments[ssIndex], compare_unitDuration, {
//                        y : compareView.y
//                    }));
//        }
//        m_animHelper.appendStep(compareStep);
//
//        // Show result, with emphasis
//        var showResult_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT);
//        var showResult_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DURATION_SHOW_RESULT);
//
//        var showResultStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_RESULT, showResult_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_RESULT);
//        showResultStep.addCallback(0, prepForResult, null, prepForResult_reverse);
//        //var showResult_winnerPulse_startTime:Number = .1;
//        var showResult_emphasizeWinner_startTime : Float = .1;
//        var showResult_winnerPulse_startTime : Float = (winnerExists) ? showResult_emphasizeWinner_startTime + showResult_unitDuration / 2 + showResult_unitDelay : .1;
//        // second path is much longer so duration is twice as long as first.  If second goes first, must add in extra time to cumulative sequence
//        var adjustForLongerFlightOfSecond : Float = ((winnerValue >= 0)) ? 0 : showResult_unitDuration / 2;
//        var showResult_winnerMove_startTime : Float = showResult_winnerPulse_startTime + showResult_unitDuration;
//        var showResult_changeToResult_startTime : Float = showResult_winnerMove_startTime + showResult_unitDuration / 2 + PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT / 2 + adjustForLongerFlightOfSecond;
//        var showResult_loserPulse_startTime : Float = showResult_changeToResult_startTime + showResult_unitDuration + PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_SHOW_RESULT / 2 + adjustForLongerFlightOfSecond;
//        var showResult_loserMove_startTime : Float = showResult_loserPulse_startTime + showResult_unitDuration + adjustForLongerFlightOfSecond;
//        var showResult_firstPulse_startTime : Float = ((winnerValue >= 0)) ? showResult_winnerPulse_startTime : showResult_loserPulse_startTime;
//        var showResult_firstMove_startTime : Float = ((winnerValue >= 0)) ? showResult_winnerMove_startTime : showResult_loserMove_startTime;
//        var showResult_secondPulse_startTime : Float = ((winnerValue < 0)) ? showResult_winnerPulse_startTime : showResult_loserPulse_startTime;
//        var showResult_secondMove_startTime : Float = ((winnerValue < 0)) ? showResult_winnerMove_startTime : showResult_loserMove_startTime;
//        if (winnerExists)
//        {
//            for (wIndex in 0...winningGlowAreas.length)
//            {
//                showResultStep.addTween(showResult_emphasizeWinner_startTime, new GTween(winningGlowAreas[wIndex], showResult_unitDuration / 4, {
//                            alpha : .7
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//                showResultStep.addTweenSet(showResult_emphasizeWinner_startTime, FVEmphasis.computePulseTweens(winningGlowAreas[wIndex], showResult_unitDuration / 2, 1, 1, PieConstants.COMPARE_PULSE_SCALE));
//            }
//        }
//        showResultStep.addTweenSet(showResult_firstPulse_startTime, FVEmphasis.computePulseTweens(firstResultFrac, showResult_unitDuration, 1, 1, PieConstants.PULSE_SCALE_GENERAL_LARGE));
//        showResultStep.addCallback(showResult_firstMove_startTime, reShowFirstValue, null, reShowFirstValue_reverse);
//        showResultStep.addTween(showResult_firstMove_startTime, new GTween(firstResultFrac, showResult_unitDuration / 2, {
//                    x : firstResultFracFinalPosition.x,
//                    y : firstResultFracFinalPosition.y,
//                    scaleX : resultEndScale,
//                    scaleY : resultEndScale
//                }));
//        showResultStep.addTweenSet(showResult_changeToResult_startTime, FVEmphasis.computePulseTweens(resultSymbolHolder, showResult_unitDuration, resultEndScale, resultEndScale, PieConstants.PULSE_SCALE_GENERAL));
//        showResultStep.addTween(showResult_changeToResult_startTime, new GTween(resultSymbol, showResult_unitDuration / 4, {
//                    alpha : 1
//                }));
//        showResultStep.addTween(showResult_changeToResult_startTime, new GTween(compareSymbol, showResult_unitDuration / 4, {
//                    alpha : 0
//                }));
//        showResultStep.addTweenSet(showResult_secondPulse_startTime, FVEmphasis.computePulseTweens(secondResultFrac, showResult_unitDuration, 1, 1, PieConstants.PULSE_SCALE_GENERAL_LARGE));
//        showResultStep.addCallback(showResult_secondMove_startTime, reShowSecondValue, null, reShowSecondValue_reverse);
//        showResultStep.addTween(showResult_secondMove_startTime, new GTween(secondResultFrac, showResult_unitDuration / 1.5, {
//                    x : secondResultFracFinalPosition.x,
//                    y : secondResultFracFinalPosition.y,
//                    scaleX : resultEndScale,
//                    scaleY : resultEndScale
//                }));
//        m_animHelper.appendStep(showResultStep);
//
//        // Fade out
//        var fade_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_FADE);
//        var fade_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DURATION_FADE);
//
//        var fadeOutStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, fade_unitDelay, CgsFVConstants.STEP_TYPE_FADE);
//        for (fsIndex in 0...firstSegments.length)
//        {
//            fadeOutStep.addTween(0, new GTween(firstSegments[fsIndex], fade_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//        for (ssIndex in 0...secondSegments.length)
//        {
//            fadeOutStep.addTween(0, new GTween(secondSegments[ssIndex], fade_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//        }
//        m_animHelper.appendStep(fadeOutStep);
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_COMPARE_SIZE_DURATION_UNPOSITION);
//
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
//                    fillAlpha : 0,
//                    unitNumDisplayAlpha : 1,
//                    unitTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(secondModule, unposition_unitDuration, {
//                    fillAlpha : 0,
//                    unitNumDisplayAlpha : 1,
//                    unitTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(firstModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0,
//                    valueTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addCallback(unposition_unitDuration / 2, moveValue, [firstModule, false], moveValue, [firstModule, true]);
//        unpositionStep.addTween(unposition_unitDuration * (2 / 3), new GTween(firstModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1,
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        if (winnerExists)
//        {
//            for (wIndex in 0...winningGlowAreas.length)
//            {
//                unpositionStep.addTween(0, new GTween(winningGlowAreas[wIndex], unposition_unitDuration / 4, {
//                            alpha : 0
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//            }
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
//        // Moves the location of the fraction value
//        function moveValue(module : PieFractionModule, top : Bool) : Void
//        {
//            module.valueIsAbove = top;
//        }  // Peels the values of the first and second onto alphaed out segments to be compared  ;
//
//
//
//
//        var prepForCompare : Void->Void = function() : Void
//        {
//            for (fsIndex in 0...firstSegments.length)
//            {
//                firstSegments[fsIndex].x += first.x;
//                firstSegments[fsIndex].y = first.y;
//                firstSegments[fsIndex].visible = true;
//                firstSegments[fsIndex].alpha = 0;
//            }
//            for (ssIndex in 0...secondSegments.length)
//            {
//                secondSegments[ssIndex].x += second.x;
//                secondSegments[ssIndex].y = second.y;
//                secondSegments[ssIndex].visible = true;
//                secondSegments[ssIndex].alpha = 0;
//            }
//        }
//
//        function prepForCompare_reverse() : Void
//        {
//            for (fsIndex in 0...firstSegments.length)
//            {
//                firstSegments[fsIndex].x -= first.x;
//                firstSegments[fsIndex].visible = false;
//            }
//            for (ssIndex in 0...secondSegments.length)
//            {
//                secondSegments[ssIndex].x -= second.x;
//                secondSegments[ssIndex].visible = false;
//            }
//        }  // Turns on the part of the result display  ;
//
//
//
//        var prepForResult : Void->Void = function() : Void
//        {
//            // Show winning glows
//            if (winnerExists)
//            {
//                for (wIndex in 0...winningGlowAreas.length)
//                {
//                    winningGlowAreas[wIndex].alpha = 0;
//                    winningGlowAreas[wIndex].visible = true;
//                }
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
//            // Hide winning glows
//            if (winnerExists)
//            {
//                for (wIndex in 0...winningGlowAreas.length)
//                {
//                    winningGlowAreas[wIndex].visible = false;
//                }
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
//        }  // Callback    /**
//
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


