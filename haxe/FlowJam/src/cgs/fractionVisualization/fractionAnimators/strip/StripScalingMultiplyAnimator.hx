package cgs.fractionVisualization.fractionAnimators.strip;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.StripFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
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
class StripScalingMultiplyAnimator implements IFractionAnimator
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
        return CgsFVConstants.STRIP_SCALING_MULTIPLY;
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
//        var firstModule : StripFractionModule = try cast(first.module, StripFractionModule) catch(e:Dynamic) null;
//        var secondModule : StripFractionModule = try cast(second.module, StripFractionModule) catch(e:Dynamic) null;
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var resultFraction : CgsFraction = CgsFraction.fMultiply(first.fraction, second.fraction);
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2);
//        var newFirstPosition : Point = new Point(firstModule.totalWidth / 2 - offsetX, firstModule.unitHeight / 2);
//        var newSecondPosition : Point = new Point(secondModule.totalWidth / 2 - offsetX, -secondModule.unitHeight / 2);
//
//        // Scale X dimension
//        var doScaleChange : Bool = first.fraction.numerator != first.fraction.denominator;
//        var newScaleX : Float = first.fraction.value;
//        var newXPosition : Float = newSecondPosition.x - secondModule.totalWidth / 2 + ((secondModule.totalWidth / 2) * newScaleX);
//
//        // Setup scale lines
//        var firstLine : Sprite = new Sprite();
//        var secondLine : Sprite = new Sprite();
//        firstLine.graphics.lineStyle(GenConstants.DASHED_LINE_THICKNESS, GenConstants.DASHED_LINE_COLOR, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND);
//        secondLine.graphics.lineStyle(GenConstants.DASHED_LINE_THICKNESS, GenConstants.DASHED_LINE_COLOR, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND);
//        var secondLine_startY : Float = newSecondPosition.y - secondModule.unitHeight / 2 - StripConstants.TICK_EXTENSION_DISTANCE;
//        var secondLine_endY : Float = newSecondPosition.y + secondModule.unitHeight / 2 + StripConstants.TICK_EXTENSION_DISTANCE;
//        var firstLine_startY : Float = newFirstPosition.y - firstModule.unitHeight / 2 - StripConstants.TICK_EXTENSION_DISTANCE;
//        var firstLine_endY : Float = newFirstPosition.y + firstModule.unitHeight / 2 + StripConstants.TICK_EXTENSION_DISTANCE;
//        var currDashStartY : Float = secondLine_startY;
//        while (currDashStartY < firstLine_endY)
//        {
//            var currDashEndY : Float = Math.min(currDashStartY + GenConstants.DASHED_LINE_DASH_LENGTH, firstLine_endY);
//
//            // Draw on the first line
//            if (currDashEndY > firstLine_startY)
//            {
//                firstLine.graphics.moveTo(0, Math.max(currDashStartY, firstLine_startY));
//                firstLine.graphics.lineTo(0, currDashEndY);
//            }
//
//            // Draw on the second line
//            if (currDashStartY < secondLine_endY)
//            {
//                secondLine.graphics.moveTo(0, currDashStartY);
//                secondLine.graphics.lineTo(0, Math.min(currDashEndY, secondLine_endY));
//            }
//
//            currDashStartY += GenConstants.DASHED_LINE_DASH_LENGTH + GenConstants.DASHED_LINE_DASH_SPACING;
//        }
//        firstLine.graphics.endFill();
//        secondLine.graphics.endFill();
//        firstLine.x = newFirstPosition.x - firstModule.totalWidth / 2 + firstModule.valueWidth;
//        secondLine.x = newSecondPosition.x - secondModule.totalWidth / 2 + secondModule.unitWidth;
//        var lineGlow : GlowFilter = new GlowFilter(0xffffff, 0.8, 2.4, 2.4, 40);
//        firstLine.filters = [lineGlow];
//        secondLine.filters = [lineGlow];
//        firstLine.visible = false;
//        secondLine.visible = false;
//        m_animHelper.trackDisplay(firstLine);
//        m_animHelper.trackDisplay(secondLine);
//        m_animController.addChild(firstLine);
//        m_animController.addChild(secondLine);
//
//        // Peel data
//        var secondSegmentHolder : Sprite = new Sprite();
//        var secondSegment : Sprite = new Sprite();
//        m_animController.addChild(secondSegmentHolder);
//        m_animHelper.trackDisplay(secondSegmentHolder);
//        secondSegmentHolder.addChild(secondSegment);
//        m_animHelper.trackDisplay(secondSegment);
//
//        // Show Equation Data
//        var firstValueNR : NumberRenderer = m_animHelper.createNumberRenderer(first.fraction, textColor, textGlowColor);
//        var multSymbolText : TextField = m_animHelper.createTextField(" × ", textColor, textGlowColor);
//        var secondValueNR : NumberRenderer = m_animHelper.createNumberRenderer(second.fraction, textColor, textGlowColor);
//        var equalsSymbolText : TextField = m_animHelper.createTextField(" = ", textColor, textGlowColor);
//        var resultValueNR : NumberRenderer = m_animHelper.createNumberRenderer(resultFraction, textColor, textGlowColor);
//        // Add to display list
//        m_animController.addChild(firstValueNR);
//        m_animController.addChild(multSymbolText);
//        m_animController.addChild(secondValueNR);
//        m_animController.addChild(equalsSymbolText);
//        m_animController.addChild(resultValueNR);
//        // Adjust locations
//        var equationCenterX : Float = 0;
//        var equationCenterY : Float = newFirstPosition.y + firstModule.unitHeight / 2 + StripConstants.ANIMATION_MARGIN_EQUATION;
//        firstValueNR.x = 0;
//        firstValueNR.y = 0;
//        var firstValueNRFinalPosition : Point = new Point(equationCenterX - secondValueNR.width / 2 - multSymbolText.width - firstValueNR.width / 2, equationCenterY);
//        multSymbolText.x = equationCenterX - secondValueNR.width / 2 - multSymbolText.width;
//        multSymbolText.y = equationCenterY - multSymbolText.height / 2;
//        secondValueNR.x = 0;
//        secondValueNR.y = 0;
//        var secondValueNRFinalPosition : Point = new Point(equationCenterX, equationCenterY);
//        equalsSymbolText.x = equationCenterX + secondValueNR.width / 2;
//        equalsSymbolText.y = equationCenterY - equalsSymbolText.height / 2;
//        resultValueNR.x = equationCenterX + secondValueNR.width / 2 + equalsSymbolText.width + resultValueNR.width / 2;
//        resultValueNR.y = equationCenterY;
//        // Visibility
//        firstValueNR.visible = false;
//        multSymbolText.visible = false;
//        secondValueNR.visible = false;
//        equalsSymbolText.visible = false;
//        resultValueNR.visible = false;
//
//        // Change First Denominator Data
//        var doChangeFirstDenom : Bool = true;
//        var firstMultiplier : Int = second.fraction.denominator;
//        var firstMultiplierFraction : CgsFraction = new CgsFraction(firstMultiplier, firstMultiplier);
//        var finalFirstFraction : CgsFraction = new CgsFraction(first.fraction.numerator * firstMultiplier, first.fraction.denominator * firstMultiplier);
//        var firstDenom_firstValueNR : NumberRenderer;
//        var firstDenom_opSymbolText : TextField;
//        var firstDenom_secondValueNR : NumberRenderer;
//        var firstDenom_equalsSymbolText : TextField;
//        var firstDenom_resultValueNR : NumberRenderer;
//        var firstDenom_firstValueNR_startPosition : Point;
//        var firstDenom_opSymbolText_startPosition : Point;
//        var firstDenom_secondValueNR_startPosition : Point;
//        var firstDenom_equalsSymbolText_startPosition : Point;
//        var firstDenom_resultValueNR_startPosition : Point;
//        var firstDenom_resultValueNR_finalPosition : Point;
//        var newFirstSegmentHolder : Sprite;
//        var newFirstSegments : Array<Sprite>;
//        var newFirstSegmentHolders : Array<Sprite> = new Array<Sprite>();
//        var numTicksPerFirstSegment : Float = firstMultiplier;
//        var numOtherFirstSegments : Float = (firstModule.numBaseUnits * origFirstFraction.denominator) - 1;
//        if (doChangeFirstDenom)
//        {
//            // Get parts of the equations
//            firstDenom_firstValueNR = m_animHelper.createNumberRenderer(first.fraction, textColor, textGlowColor);
//            firstDenom_opSymbolText = m_animHelper.createTextField(" × ", textColor, textGlowColor);
//            firstDenom_secondValueNR = m_animHelper.createNumberRenderer(firstMultiplierFraction, textColor, textGlowColor);
//            firstDenom_equalsSymbolText = m_animHelper.createTextField(" = ", textColor, textGlowColor);
//            firstDenom_resultValueNR = m_animHelper.createNumberRenderer(finalFirstFraction, textColor, textGlowColor);
//
//            // Add to display list
//            m_animController.addChild(firstDenom_firstValueNR);
//            m_animController.addChild(firstDenom_opSymbolText);
//            m_animController.addChild(firstDenom_secondValueNR);
//            m_animController.addChild(firstDenom_equalsSymbolText);
//            m_animController.addChild(firstDenom_resultValueNR);
//
//            // Visibility
//            firstDenom_firstValueNR.visible = false;
//            firstDenom_opSymbolText.visible = false;
//            firstDenom_secondValueNR.visible = false;
//            firstDenom_equalsSymbolText.visible = false;
//            firstDenom_resultValueNR.visible = false;
//
//            // Compute positioning
//            var firstValuePosition : Point = firstModule.getValueNRPosition(false, origFirstFraction.denominator == 1);
//            firstDenom_firstValueNR_startPosition = new Point(newFirstPosition.x + firstValuePosition.x,
//                    newFirstPosition.y + firstValuePosition.y);
//            firstDenom_opSymbolText_startPosition = new Point(firstDenom_firstValueNR_startPosition.x + firstDenom_firstValueNR.width / 2,
//                    firstDenom_firstValueNR_startPosition.y - firstDenom_opSymbolText.height / 2);
//            firstDenom_secondValueNR_startPosition = new Point(firstDenom_opSymbolText_startPosition.x + firstDenom_opSymbolText.width + firstDenom_secondValueNR.width / 2,
//                    firstDenom_firstValueNR_startPosition.y);
//            firstDenom_equalsSymbolText_startPosition = new Point(firstDenom_secondValueNR_startPosition.x + firstDenom_secondValueNR.width / 2,
//                    firstDenom_firstValueNR_startPosition.y - firstDenom_equalsSymbolText.height / 2);
//            firstDenom_resultValueNR_startPosition = new Point(firstDenom_equalsSymbolText_startPosition.x + firstDenom_equalsSymbolText.width + firstDenom_resultValueNR.width / 2,
//                    firstDenom_firstValueNR_startPosition.y);
//            var firstResultNRPosition : Point = firstModule.getValueNRPosition(false, firstDenom_resultValueNR.fraction.denominator == 1);
//            firstDenom_resultValueNR_finalPosition = new Point(newFirstPosition.x + firstResultNRPosition.x,
//                    newFirstPosition.y + firstResultNRPosition.y);
//
//            // Setup the new segments
//            var firstBlockGroupWidth : Float = (firstModule.unitWidth / origFirstFraction.denominator);
//            newFirstSegmentHolder = new Sprite();
//            newFirstSegmentHolder.x = newFirstPosition.x;
//            newFirstSegmentHolder.y = newFirstPosition.y;
//            newFirstSegmentHolder.visible = false;
//            m_animHelper.trackDisplay(newFirstSegmentHolder);
//            m_animController.addChild(newFirstSegmentHolder);
//            newFirstSegments = firstModule.drawSegmentsForChangingDenominator(finalFirstFraction, firstModule.numBaseUnits);
//            for (tickIndex in 0...numTicksPerFirstSegment)
//            {
//                var tickAtIndex : Sprite = newFirstSegments[tickIndex];
//                m_animHelper.trackDisplay(tickAtIndex);
//                newFirstSegmentHolder.addChild(tickAtIndex);
//            }
//            for (segmentIndex in 1...numOtherFirstSegments + 1)
//            {
//                // Setup holder for segments, so they can scale nicely when emphasized
//                var aTickHolder : Sprite = new Sprite();
//                aTickHolder.x = -((firstModule.totalWidth + (numExtensionUnits * firstModule.unitWidth)) / 2) + (firstBlockGroupWidth * segmentIndex) + firstBlockGroupWidth / 2;
//                aTickHolder.y = 0;
//                m_animHelper.trackDisplay(aTickHolder);
//                newFirstSegmentHolder.addChild(aTickHolder);
//                newFirstSegmentHolders.push(aTickHolder);
//
//                // Add segments for this holder to this holder
//                var thisSegmentStartIndex : Float = segmentIndex * numTicksPerFirstSegment;
//                var thisSegmentEndIndex : Float = thisSegmentStartIndex + numTicksPerFirstSegment;
//                for (tickIndex in thisSegmentStartIndex...thisSegmentEndIndex)
//                {
//                    tickAtIndex = newFirstSegments[tickIndex];
//                    tickAtIndex.x -= aTickHolder.x;
//                    m_animHelper.trackDisplay(tickAtIndex);
//                    aTickHolder.addChild(tickAtIndex);
//                }
//            }
//        }
//
//        // Extension Mask data
//        var numTotalUnits : Int = CgsFraction.computeNumBaseUnits(resultFraction);
//        var numFirstUnits : Int = CgsFraction.computeNumBaseUnits(first.fraction);
//        var numExtensionUnits : Int = Math.max(numTotalUnits - numFirstUnits, 0);
//        var extensionWidthIncrease : Float = numExtensionUnits * firstModule.unitWidth;
//        var doExtension : Bool = numExtensionUnits > 0;
//        var extensionView : CgsFractionView;
//        var extensionMask : Sprite;
//        var extensionFinalX : Float;
//        if (doExtension)
//        {
//            extensionView = first.clone();
//            m_animHelper.trackFractionView(extensionView);
//            m_animController.addChildAt(extensionView, 0);
//            extensionView.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//            var extensionModule : StripFractionModule = try cast(extensionView.module, StripFractionModule) catch(e:Dynamic) null;
//            extensionModule.numExtensionUnits = numExtensionUnits;
//
//            extensionView.x = newFirstPosition.x - extensionModule.totalWidth / 2 + firstModule.totalWidth / 2;
//            extensionView.y = newFirstPosition.y;
//            extensionFinalX = extensionView.x + extensionWidthIncrease;
//            extensionView.visible = false;
//            extensionView.redraw();
//
//            // Mask
//            extensionMask = extensionModule.createExtensionMask(extensionWidthIncrease);
//            m_animHelper.trackDisplay(extensionMask);
//            extensionMask.x = newFirstPosition.x + firstModule.totalWidth / 2 + extensionWidthIncrease / 2;
//            extensionMask.y = newFirstPosition.y;
//            first.parent.addChildAt(extensionMask, 0);
//            extensionView.mask = extensionMask;
//        }
//
//        // Drop data
//        var dropFinalY : Float = newFirstPosition.y;
//
//        // Merge data
//        var firstSegmentHolder : Sprite = new Sprite();
//        var firstSegment : Sprite = new Sprite();
//        var indexOfSecondSegment : Int = m_animController.getChildIndex(secondSegmentHolder);
//        m_animController.addChildAt(firstSegmentHolder, indexOfSecondSegment);
//        m_animHelper.trackDisplay(firstSegmentHolder);
//        firstSegmentHolder.addChild(firstSegment);
//        m_animHelper.trackDisplay(firstSegment);
//
//        var resultSegmentHolder : Sprite = new Sprite();
//        var resultSegment : Sprite = new Sprite();
//        m_animController.addChildAt(resultSegmentHolder, indexOfSecondSegment);
//        m_animHelper.trackDisplay(resultSegmentHolder);
//        resultSegmentHolder.addChild(resultSegment);
//        m_animHelper.trackDisplay(resultSegment);
//
//        // Reduction Mask data
//        var numReductionUnits : Int = Math.max(numFirstUnits - numTotalUnits, 0);
//        var reductionWidthDecrease : Float = numReductionUnits * firstModule.unitWidth;
//        var doReduction : Bool = numReductionUnits > 0;
//        var reductionView : CgsFractionView;
//        var reductionMask : Sprite;
//        var reductionFinalX : Float;
//        if (doReduction)
//        {
//            reductionView = first.clone();
//            reductionView.fraction.init(resultFraction.numerator, resultFraction.denominator);
//            m_animHelper.trackFractionView(reductionView);
//            m_animController.addChildAt(reductionView, 0);
//            var reductionModule : StripFractionModule = try cast(reductionView.module, StripFractionModule) catch(e:Dynamic) null;
//            reductionModule.numExtensionUnits = numReductionUnits;
//            reductionView.x = newFirstPosition.x - reductionModule.totalWidth / 2 + firstModule.totalWidth / 2;
//            reductionView.y = newFirstPosition.y;
//            reductionFinalX = reductionView.x - reductionWidthDecrease;
//            reductionView.visible = false;
//            reductionView.redraw();
//
//            // Mask
//            reductionMask = reductionModule.createExtensionMask(reductionWidthDecrease);
//            m_animHelper.trackDisplay(reductionMask);
//            reductionMask.x = newFirstPosition.x + (firstModule.unitWidth * numTotalUnits) / 2;
//            reductionMask.y = newFirstPosition.y;
//            first.parent.addChildAt(reductionMask, 0);
//            reductionView.mask = reductionMask;
//        }
//
//        // Simplification
//        var doSimplify : Bool = !resultFraction.isSimplified;
//        var simplifiedResultFraction : CgsFraction = resultFraction.clone();
//        simplifiedResultFraction.simplify();
//        var simplifiedResult : CgsFractionView = first.clone();
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
//        var positionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_POSITION, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_POSITION, CgsFVConstants.STEP_TYPE_POSITION);
//        positionStep.addTween(0, new GTween(first, StripConstants.TIME_MULT_SCALING_DURATION_POSITION, {
//                    x : newFirstPosition.x,
//                    y : newFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(second, StripConstants.TIME_MULT_SCALING_DURATION_POSITION, {
//                    x : newSecondPosition.x,
//                    y : newSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_POSITION, {
//                    unitNumDisplayAlpha : 0,
//                    unitTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, StripConstants.TIME_MULT_SCALING_DURATION_POSITION, {
//                    unitNumDisplayAlpha : 0,
//                    unitTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_POSITION / 3, {
//                    valueNumDisplayAlpha : 0,
//                    valueTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(StripConstants.TIME_MULT_SCALING_DURATION_POSITION / 2, moveValueToBottom, null, moveValueToBottom_reverse);
//        positionStep.addTween(StripConstants.TIME_MULT_SCALING_DURATION_POSITION * (2 / 3), new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_POSITION / 3, {
//                    valueNumDisplayAlpha : 1,
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        // Show Equation
//        var showEquationStep : AnimationStep = new AnimationStep("Show Equation", StripConstants.TIME_MULT_SCALING_DELAY_AFTER_SHOW_EQUATION, CgsFVConstants.STEP_TYPE_TBD);
//        showEquationStep.addCallback(0, prepEquation, null, prepEquation_reverse);
//        var moveFirstStart : Float = .1;
//        var moveSecondStart : Float = moveFirstStart + StripConstants.TIME_MULT_SCALING_DURATION_SHOW_EQUATION;
//        showEquationStep.addTween(moveFirstStart, new GTween(firstValueNR, StripConstants.TIME_MULT_SCALING_DURATION_SHOW_EQUATION, {
//                    x : firstValueNRFinalPosition.x,
//                    y : firstValueNRFinalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        showEquationStep.addTween(moveSecondStart, new GTween(secondValueNR, StripConstants.TIME_MULT_SCALING_DURATION_SHOW_EQUATION, {
//                    x : secondValueNRFinalPosition.x,
//                    y : secondValueNRFinalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        showEquationStep.addTween(moveSecondStart, new GTween(multSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_SHOW_EQUATION, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(showEquationStep);
//
//        // Scale X Dimension
//        if (doScaleChange)
//        {
//            var scaleStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_ALIGN, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_SCALE, CgsFVConstants.STEP_TYPE_TBD);
//            scaleStep.addCallback(0, prepForScale, null, prepForScale_reverse);
//
//            // Timing
//            var showLineStartTime : Float = .1;
//            var changeScaleStartTime : Float = showLineStartTime + StripConstants.TIME_MULT_SCALING_DURATION_SCALE;
//            var hideLineStartTime : Float = changeScaleStartTime + StripConstants.TIME_MULT_SCALING_DURATION_SCALE;
//            var finalizeScaleTime : Float = hideLineStartTime + StripConstants.TIME_MULT_SCALING_DURATION_SCALE / 2;
//
//            // Show lines
//            scaleStep.addTween(showLineStartTime, new GTween(firstLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTween(showLineStartTime, new GTween(secondLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE / 2, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTweenSet(showLineStartTime, FVEmphasis.computePulseTweens(firstLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE, 1, 1, StripConstants.PULSE_SCALE_GENERAL));
//            scaleStep.addTweenSet(showLineStartTime, FVEmphasis.computePulseTweens(secondLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE, 1, 1, StripConstants.PULSE_SCALE_GENERAL));
//
//            // Change scale
//            scaleStep.addTween(changeScaleStartTime, new GTween(secondModule, StripConstants.TIME_MULT_SCALING_DURATION_SCALE, {
//                        scaleX : newScaleX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTween(changeScaleStartTime, new GTween(second, StripConstants.TIME_MULT_SCALING_DURATION_SCALE, {
//                        x : newXPosition
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTween(changeScaleStartTime, new GTween(secondLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE, {
//                        x : firstLine.x
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Hide lines
//            scaleStep.addTween(hideLineStartTime, new GTween(firstLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            scaleStep.addTween(hideLineStartTime, new GTween(secondLine, StripConstants.TIME_MULT_SCALING_DURATION_SCALE / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            scaleStep.addCallback(finalizeScaleTime, finalizeScale, null, finalizeScale_reverse);
//            m_animHelper.appendStep(scaleStep);
//        }
//
//        // Change denominator of first fraction
//        if (doChangeFirstDenom)
//        {
//            var firstDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_FIRST_DENOMINATOR, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_CHANGE_DENOM, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//            firstDenomStep.addCallback(0, prepForChangeFirstDenominator, null, prepForChangeFirstDenominator_reverse);
//
//            // Set timing values
//            var firstDenom_fadePartOne_startTime : Float = .1;  // A little delay to ensure the prepForChangeFirstDenominator happens first
//            var firstDenom_changeFirstSegment_startTime : Float = firstDenom_fadePartOne_startTime + StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2;
//            var firstDenom_changeFirstSegmentDuration : Float = Math.min(StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM_PER_TICK * numTicksPerFirstSegment, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM_FIRST_SEGMENT_MAX);
//            var firstDenom_fadePartTwo_startTime : Float = firstDenom_changeFirstSegment_startTime + firstDenom_changeFirstSegmentDuration + StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2;
//            var firstDenom_changeOtherSegments_startTime : Float = firstDenom_fadePartTwo_startTime + StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2;
//            var firstDenom_changeOtherSegmentDuration : Float = Math.min(StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM_PER_TICK * numOtherFirstSegments, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM_OTHER_SEGMENT_MAX);
//            var firstDenom_consolidateEquation_startTime : Float = firstDenom_changeOtherSegments_startTime + firstDenom_changeOtherSegmentDuration;
//            var firstDenom_finalize_startTime : Float = firstDenom_consolidateEquation_startTime + StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2;
//
//            // Fade/pulse multiplier
//            firstDenomStep.addTween(firstDenom_fadePartOne_startTime, new GTween(firstDenom_opSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_fadePartOne_startTime, new GTween(firstDenom_secondValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_fadePartOne_startTime + StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, new GTween(firstDenom_secondValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Handle changing ticks of the first segment rectangle
//            var currTickStartTime : Float = firstDenom_changeFirstSegment_startTime;
//            var firstTicksFadeDuration : Float = firstDenom_changeFirstSegmentDuration / numTicksPerFirstSegment;
//            for (tickIndex in 0...numTicksPerFirstSegment)
//            {
//                tickAtIndex = newFirstSegments[tickIndex];
//                firstDenomStep.addTween(currTickStartTime, new GTween(tickAtIndex, firstTicksFadeDuration / 2, {
//                            alpha : 1
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//                firstDenomStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(tickAtIndex, firstTicksFadeDuration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//                currTickStartTime += firstTicksFadeDuration;
//            }
//
//            // Fade/pulse result
//            firstDenomStep.addTween(firstDenom_fadePartTwo_startTime, new GTween(firstDenom_equalsSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_fadePartTwo_startTime, new GTween(firstDenom_resultValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_fadePartTwo_startTime + StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, new GTween(firstDenom_resultValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Handle changing ticks of all the other segment rectangles
//            currTickStartTime = firstDenom_changeOtherSegments_startTime;
//            var otherTicksFadeDuration : Float = firstDenom_changeOtherSegmentDuration / numOtherFirstSegments;
//            for (segmentIndex in 1...numOtherFirstSegments + 1)
//            {
//                // Since we have holders, we just need to alpha in and emphasize those holders
//                aTickHolder = newFirstSegmentHolders[segmentIndex - 1];
//                firstDenomStep.addTween(currTickStartTime, new GTween(aTickHolder, otherTicksFadeDuration, {
//                            alpha : 1
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//                firstDenomStep.addTweenSet(currTickStartTime, FVEmphasis.computePulseTweens(aTickHolder, otherTicksFadeDuration, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//                currTickStartTime += otherTicksFadeDuration;
//            }
//
//            // Consolidate equation
//            firstDenomStep.addTween(firstDenom_consolidateEquation_startTime, new GTween(firstDenom_firstValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_consolidateEquation_startTime, new GTween(firstDenom_opSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_consolidateEquation_startTime, new GTween(firstDenom_secondValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_consolidateEquation_startTime, new GTween(firstDenom_equalsSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            firstDenomStep.addTween(firstDenom_consolidateEquation_startTime, new GTween(firstDenom_resultValueNR, StripConstants.TIME_MULT_SCALING_DURATION_CHANGE_DENOM / 2, {
//                        x : firstDenom_resultValueNR_finalPosition.x,
//                        y : firstDenom_resultValueNR_finalPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Finalize
//            firstDenomStep.addCallback(firstDenom_finalize_startTime, changeFirstDenom, null, changeFirstDenom_reverse);
//            m_animHelper.appendStep(firstDenomStep);
//        }
//
//        // Tween extension
//        if (doExtension)
//        {
//            var extensionStep : AnimationStep = new AnimationStep("Extension", StripConstants.TIME_MULT_SCALING_DELAY_AFTER_EXTENSION, CgsFVConstants.STEP_TYPE_TBD);
//            extensionStep.addCallback(0, startExtend, null, startExtend_reverse);
//            extensionStep.addTween(0, new GTween(extensionView, StripConstants.TIME_MULT_SCALING_DURATION_EXTENSION, {
//                        x : extensionFinalX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            extensionStep.addCallback(StripConstants.TIME_MULT_SCALING_DURATION_EXTENSION, finishExtend, null, finishExtend_reverse);
//            m_animHelper.appendStep(extensionStep);
//        }
//
//        // Tween drop
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_DROP, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, doPeel, null, doPeel_reverse);  // Do peel
//        var emphasisStartTime : Float = .1;
//        var dropPrepTime : Float = emphasisStartTime + StripConstants.TIME_MULT_SCALING_DURATION_EMPHASIS;
//        var dropStartTime : Float = dropPrepTime + .1;
//        var mergeTime : Float = dropStartTime + StripConstants.TIME_MULT_SCALING_DURATION_EMPHASIS;
//        dropStep.addTweenSet(emphasisStartTime, FVEmphasis.computePulseTweens(secondSegment, StripConstants.TIME_MULT_SCALING_DURATION_EMPHASIS, 1, 1, StripConstants.PULSE_SCALE_SEGMENT));
//        dropStep.addCallback(dropPrepTime, prepForDrop, null, prepForDrop_reverse);
//        dropStep.addTween(dropStartTime, new GTween(secondSegmentHolder, StripConstants.TIME_MULT_SCALING_DURATION_DROP, {
//                    y : dropFinalY
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(dropStep);
//
//        // Merge
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_MERGE, CgsFVConstants.STEP_TYPE_MERGE);
//        mergeStep.addTween(0, new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_MERGE / 3, {
//                    valueNumDisplayAlpha : 0,
//                    valueTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addCallback(StripConstants.TIME_MULT_SCALING_DURATION_MERGE / 2, doMerge, null, doMerge_reverse);
//        mergeStep.addTween(StripConstants.TIME_MULT_SCALING_DURATION_MERGE * (2 / 3), new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_MERGE / 3, {
//                    valueNumDisplayAlpha : 1,
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTween(StripConstants.TIME_MULT_SCALING_DURATION_MERGE * (2 / 3), new GTween(secondSegmentHolder, StripConstants.TIME_MULT_SCALING_DURATION_MERGE / 3, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTween(StripConstants.TIME_MULT_SCALING_DURATION_MERGE * (2 / 3), new GTween(firstSegmentHolder, StripConstants.TIME_MULT_SCALING_DURATION_MERGE / 3, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addTween(StripConstants.TIME_MULT_SCALING_DURATION_MERGE * (2 / 3), new GTween(resultSegmentHolder, StripConstants.TIME_MULT_SCALING_DURATION_MERGE / 3, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        mergeStep.addCallback(StripConstants.TIME_MULT_SCALING_DURATION_MERGE, finalizeMerge, null, finalizeMerge_reverse);
//        m_animHelper.appendStep(mergeStep);
//
//        // Show Result
//        var showResultStep : AnimationStep = new AnimationStep("Show Result", StripConstants.TIME_MULT_SCALING_DELAY_AFTER_SHOW_RESULT, CgsFVConstants.STEP_TYPE_TBD);
//        showResultStep.addTween(0, new GTween(resultValueNR, StripConstants.TIME_MULT_SCALING_DURATION_SHOW_RESULT, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        showResultStep.addTween(0, new GTween(equalsSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_SHOW_RESULT, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(showResultStep);
//
//        // Tween reduction
//        if (doReduction)
//        {
//            var reductionStep : AnimationStep = new AnimationStep("Reduction", StripConstants.TIME_MULT_SCALING_DELAY_AFTER_REDUCTION, CgsFVConstants.STEP_TYPE_TBD);
//            reductionStep.addCallback(0, startReduce, null, startReduce_reverse);
//            reductionStep.addTween(0, new GTween(reductionView, StripConstants.TIME_MULT_SCALING_DURATION_REDUCTION, {
//                        x : reductionFinalX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            reductionStep.addCallback(StripConstants.TIME_MULT_SCALING_DURATION_REDUCTION, finishReduce, null, finishReduce_reverse);
//            m_animHelper.appendStep(reductionStep);
//        }
//
//        // Tween fade
//        var fadeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_FADE, CgsFVConstants.STEP_TYPE_FADE);
//        fadeStep.addTween(0, new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    unitNumDisplayAlpha : 1,
//                    unitTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_FADE / 3, {
//                    valueNumDisplayAlpha : 0,
//                    valueTickDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addCallback(StripConstants.TIME_MULT_SCALING_DURATION_FADE / 2, moveValueToTop, null, moveValueToTop_reverse);
//        fadeStep.addTween(StripConstants.TIME_MULT_SCALING_DURATION_FADE * (2 / 3), new GTween(firstModule, StripConstants.TIME_MULT_SCALING_DURATION_FADE / 3, {
//                    valueNumDisplayAlpha : 1,
//                    valueTickDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(second, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(firstValueNR, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(multSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(secondValueNR, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(equalsSymbolText, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        fadeStep.addTween(0, new GTween(resultValueNR, StripConstants.TIME_MULT_SCALING_DURATION_FADE, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(fadeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplificationStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SIMPLIFICATION, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_SIMPLIFICATION, CgsFVConstants.STEP_TYPE_SIMPLIFICATION);
//            simplificationStep.addCallback(0, prepForSimplification, null, prepForSimplification_reverse);
//            simplificationStep.addTween(.1, new GTween(first, StripConstants.TIME_MULT_SCALING_DURATION_SIMPLIFICATION, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addTween(.1, new GTween(simplifiedResult, StripConstants.TIME_MULT_SCALING_DURATION_SIMPLIFICATION, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addCallback(.1 + StripConstants.TIME_MULT_SCALING_DURATION_SIMPLIFICATION, finalizeSimplification, null, finalizeSimplification_reverse);
//            m_animHelper.appendStep(simplificationStep);
//        }
//
//        // Final Position
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, StripConstants.TIME_MULT_SCALING_DELAY_AFTER_UNPOSITION, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween((doSimplify) ? simplifiedResult : first, StripConstants.TIME_MULT_SCALING_DURATION_UNPOSITION, {
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
//        // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the strip
//        function moveValueToBottom() : Void
//        {
//            firstModule.valueIsAbove = false;
//        };
//
//        function moveValueToBottom_reverse() : Void
//        {
//            firstModule.valueIsAbove = true;
//        }  // Preps for the extension animation  ;
//
//
//
//        var startExtend : Void->Void = function() : Void
//        {
//            extensionView.visible = true;
//            extensionView.redraw();
//            first.parent.addChildAt(extensionMask, 0);
//        }
//
//        function startExtend_reverse() : Void
//        {
//            extensionView.visible = false;
//            extensionMask.parent.removeChild(extensionMask);
//        }  // Removes the extension clone and updates the first fraction view to be extended  ;
//
//
//
//        var finishExtend : Void->Void = function() : Void
//        {
//            // Remove extension
//            extensionView.visible = false;
//            extensionMask.visible = false;
//            extensionMask.parent.removeChild(extensionMask);
//
//            // Extend first
//            firstModule.numExtensionUnits = numExtensionUnits;
//            first.redraw(true);
//            first.x = first.x + extensionWidthIncrease / 2;
//        }
//
//        function finishExtend_reverse() : Void
//        {
//            // Show extension
//            extensionView.visible = true;
//            extensionMask.visible = true;
//            first.parent.addChildAt(extensionMask, 0);
//
//            // Extend first
//            firstModule.numExtensionUnits = 0;
//            first.redraw(true);
//            first.x = first.x - extensionWidthIncrease / 2;
//        }  // Preps for the scale animation  ;
//
//
//
//        var prepForScale : Void->Void = function() : Void
//        {
//            firstLine.visible = true;
//            firstLine.alpha = 0;
//            secondLine.visible = true;
//            secondLine.alpha = 0;
//        }
//
//        function prepForScale_reverse() : Void
//        {
//            firstLine.visible = false;
//            secondLine.visible = false;
//        }  // Preps for the scale animation  ;
//
//
//
//        var finalizeScale : Void->Void = function() : Void
//        {
//            firstLine.visible = false;
//            secondLine.visible = false;
//        }
//
//        var finalizeScale_reverse : Void->Void = function() : Void
//        {
//            firstLine.visible = true;
//            secondLine.visible = true;
//        }
//
//        var prepEquation : Void->Void = function() : Void
//        {
//            // Adjust locations of fraction value NRs
//            firstValueNR.x = first.x + firstModule.valueNRPosition.x;
//            firstValueNR.y = first.y + firstModule.valueNRPosition.y;
//            secondValueNR.x = second.x + secondModule.valueNRPosition.x;
//            secondValueNR.y = second.y + secondModule.valueNRPosition.y;
//
//            // Adjust alphas and visibility of equation parts
//            firstValueNR.alpha = 1;
//            multSymbolText.alpha = 0;
//            secondValueNR.alpha = 1;
//            equalsSymbolText.alpha = 0;
//            resultValueNR.alpha = 0;
//            firstValueNR.visible = true;
//            secondValueNR.visible = true;
//            multSymbolText.visible = true;
//            equalsSymbolText.visible = true;
//            resultValueNR.visible = true;
//        }
//
//        function prepEquation_reverse() : Void
//        {
//            // Adjust visibility of equation parts
//            firstValueNR.visible = false;
//            secondValueNR.visible = false;
//            multSymbolText.visible = false;
//            equalsSymbolText.visible = false;
//            resultValueNR.visible = false;
//        }  // Prepares for the change denominator step  ;
//
//
//
//        var prepForChangeFirstDenominator : Void->Void = function() : Void
//        {
//            // Adjust locations for the second fraction equation parts
//            firstDenom_firstValueNR.x = firstDenom_firstValueNR_startPosition.x;
//            firstDenom_firstValueNR.y = firstDenom_firstValueNR_startPosition.y;
//            firstDenom_opSymbolText.x = firstDenom_opSymbolText_startPosition.x;
//            firstDenom_opSymbolText.y = firstDenom_opSymbolText_startPosition.y;
//            firstDenom_secondValueNR.x = firstDenom_secondValueNR_startPosition.x;
//            firstDenom_secondValueNR.y = firstDenom_secondValueNR_startPosition.y;
//            firstDenom_equalsSymbolText.x = firstDenom_equalsSymbolText_startPosition.x;
//            firstDenom_equalsSymbolText.y = firstDenom_equalsSymbolText_startPosition.y;
//            firstDenom_resultValueNR.x = firstDenom_resultValueNR_startPosition.x;
//            firstDenom_resultValueNR.y = firstDenom_resultValueNR_startPosition.y;
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_firstValueNR.visible = true;
//            firstDenom_opSymbolText.visible = true;
//            firstDenom_secondValueNR.visible = true;
//            firstDenom_equalsSymbolText.visible = true;
//            firstDenom_resultValueNR.visible = true;
//            firstDenom_firstValueNR.alpha = 1;
//            firstDenom_opSymbolText.alpha = 0;
//            firstDenom_secondValueNR.alpha = 0;
//            firstDenom_equalsSymbolText.alpha = 0;
//            firstDenom_resultValueNR.alpha = 0;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//
//            // Adjust visibility of ticks and holders
//            newFirstSegmentHolder.visible = true;
//            for (tickIndex in 0...numTicksPerFirstSegment)
//            {
//                tickAtIndex = newFirstSegments[tickIndex];
//                tickAtIndex.alpha = 0;
//            }
//            for (segmentIndex in 1...numOtherFirstSegments + 1)
//            {
//                aTickHolder = newFirstSegmentHolders[segmentIndex - 1];
//                aTickHolder.alpha = 0;
//            }
//        }
//
//        function prepForChangeFirstDenominator_reverse() : Void
//        {
//            // Adjust visibility and alpha for the first fraction
//            firstDenom_firstValueNR.visible = false;
//            firstDenom_opSymbolText.visible = false;
//            firstDenom_secondValueNR.visible = false;
//            firstDenom_equalsSymbolText.visible = false;
//            firstDenom_resultValueNR.visible = false;
//            first.redraw(true);
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//
//            // Adjust visibility of new ticks
//            newFirstSegmentHolder.visible = false;
//        }  // Finalizes the changing of the denominator of the first fraction  ;
//
//
//
//        var changeFirstDenom : Void->Void = function() : Void
//        {
//            first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_firstValueNR.visible = false;
//            firstDenom_opSymbolText.visible = false;
//            firstDenom_secondValueNR.visible = false;
//            firstDenom_equalsSymbolText.visible = false;
//            firstDenom_resultValueNR.visible = false;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//
//            // Adjust visibility of new ticks
//            newFirstSegmentHolder.visible = false;
//        }
//
//        var changeFirstDenom_reverse : Void->Void = function() : Void
//        {
//            first.fraction.init(origFirstFraction.numerator, origFirstFraction.denominator);
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_firstValueNR.visible = true;
//            firstDenom_opSymbolText.visible = true;
//            firstDenom_secondValueNR.visible = true;
//            firstDenom_equalsSymbolText.visible = true;
//            firstDenom_resultValueNR.visible = true;
//
//            // Adjust visibility of value on first fraction view
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//
//            // Adjust visibility of new ticks
//            newFirstSegmentHolder.visible = true;
//        }
//
//        var doPeel : Void->Void = function() : Void
//        {
//            // Peel (paint to new and hide old) the value onto the secondSegment
//            secondModule.peelValue(secondSegment);
//            secondSegmentHolder.x = second.x;
//            secondSegmentHolder.y = second.y;
//            secondSegment.x = -secondModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + secondSegment.width / 2;
//            secondSegmentHolder.visible = true;
//        }
//
//        var doPeel_reverse : Void->Void = function() : Void
//        {
//            secondModule.unpeelValue();
//            secondSegmentHolder.visible = false;
//        }
//
//        var prepForDrop : Void->Void = function() : Void
//        {
//            secondModule.doShowSegment = true;
//            secondSegmentHolder.alpha = .7;
//        }
//
//        function prepForDrop_reverse() : Void
//        {
//            secondModule.doShowSegment = false;
//            secondSegmentHolder.alpha = 1;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        var doMerge : Void->Void = function() : Void
//        {
//            // Peel the first's start value onto the first segment
//            firstModule.peelValue(firstSegment);
//            firstSegmentHolder.x = first.x;
//            firstSegmentHolder.y = first.y;
//            firstSegment.x = -firstModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + firstSegment.width / 2;
//            firstSegmentHolder.visible = true;
//            firstSegmentHolder.alpha = 1;
//
//            // Update first value
//            first.fraction.init(resultFraction.numerator, resultFraction.denominator);
//            firstModule.numExtensionUnits = numReductionUnits;
//            first.redraw(true);
//
//            // Peel the first's start value onto the first segment
//            firstModule.peelValue(resultSegment);
//            resultSegmentHolder.x = first.x;
//            resultSegmentHolder.y = first.y;
//            resultSegment.x = -firstModule.totalWidth / 2 - StripConstants.TICK_THICKNESS / 2 + resultSegment.width / 2;
//            resultSegmentHolder.visible = true;
//            resultSegmentHolder.alpha = 0;
//        }
//
//        function doMerge_reverse() : Void
//        {
//            // Update first value
//            first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//            firstModule.numExtensionUnits = numExtensionUnits;
//            first.redraw(true);
//
//            // Hide segments
//            firstModule.unpeelValue();
//            firstSegmentHolder.visible = false;
//            resultSegmentHolder.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        var finalizeMerge : Void->Void = function() : Void
//        {
//            // Remove peeled value
//            secondSegmentHolder.visible = false;
//            firstModule.unpeelValue();
//            firstSegmentHolder.visible = false;
//            resultSegmentHolder.visible = false;
//        }
//
//        function finalizeMerge_reverse() : Void
//        {
//            // Unremove peeled value
//            firstModule.doShowSegment = false;
//            secondSegmentHolder.visible = true;
//            firstSegmentHolder.visible = true;
//            resultSegmentHolder.visible = true;
//        }  // Preps for the reduction animation  ;
//
//
//
//        var startReduce : Void->Void = function() : Void
//        {
//            reductionView.visible = true;
//            reductionView.redraw();
//            first.parent.addChildAt(reductionMask, 0);
//
//            // Reduce first
//            firstModule.numExtensionUnits = 0;
//            first.redraw(true);
//            first.x = first.x - reductionWidthDecrease / 2;
//        }
//
//        function startReduce_reverse() : Void
//        {
//            reductionView.visible = false;
//            reductionMask.parent.removeChild(reductionMask);
//
//            // Reduce first
//            firstModule.numExtensionUnits = numReductionUnits;
//            first.redraw(true);
//            first.x = first.x + reductionWidthDecrease / 2;
//        }  // Removes the reduction clone and updates the first fraction view to be reduced  ;
//
//
//
//        var finishReduce : Void->Void = function() : Void
//        {
//            // Remove extension
//            reductionView.visible = false;
//            reductionMask.visible = false;
//            reductionMask.parent.removeChild(reductionMask);
//        }
//
//        function finishReduce_reverse() : Void
//        {
//            // Show extension
//            reductionView.visible = true;
//            reductionMask.visible = true;
//            first.parent.addChildAt(reductionMask, 0);
//        }  // Moves the location of the fraction value of the first module back to above the strip  ;
//
//
//
//        var moveValueToTop : Void->Void = function() : Void
//        {
//            firstModule.valueIsAbove = true;
//        }
//
//        function moveValueToTop_reverse() : Void
//        {
//            firstModule.valueIsAbove = false;
//        }  // Prepares for simplification of result fraction  ;
//
//
//
//        var prepForSimplification : Void->Void = function() : Void
//        {
//            // Show simplified result
//            simplifiedResult.visible = true;
//            simplifiedResult.alpha = 0;
//            simplifiedResult.x = first.x;
//            simplifiedResult.y = first.y;
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
//                resultViews.push((doSimplify) ? simplifiedResult : first);
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

