package cgs.fractionVisualization.fractionAnimators.grid;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.GridFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.constants.GridConstants;
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import cgs.utils.CgsTuple;
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

/**
	 * ...
	 * @author Rich
	 */
class GridCompareTargetAnimator implements IFractionAnimator
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
        return CgsFVConstants.GRID_STANDARD_COMPARE_BENCHMARK;
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
		 * Control
		 * 
		**/
    
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
        //TODO fix animations

//        var comparisonType : String = Reflect.field(details, Std.string(CgsFVConstants.COMPARE_TYPE_DATA_KEY));
//        var benchmarkFraction : CgsFraction = Reflect.field(details, Std.string(CgsFVConstants.COMPARISON_BENCHMARK_DATA_KEY));
//        var textColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_COLOR)) : GenConstants.DEFAULT_TEXT_COLOR;
//        var textGlowColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_GLOW_COLOR)) : GenConstants.DEFAULT_TEXT_GLOW_COLOR;
//
//        /**
//			 * Setup
//			**/
//        var fractionViews : Array<CgsFractionView> = Reflect.field(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY));
//        var first : CgsFractionView = fractionViews[0];
//        var second : CgsFractionView = fractionViews[1];
//        var firstModule : GridFractionModule = (try cast(first.module, GridFractionModule) catch(e:Dynamic) null);
//        var secondModule : GridFractionModule = (try cast(second.module, GridFractionModule) catch(e:Dynamic) null);
//        var doCompare : Bool = benchmarkFraction.value != first.fraction.value && benchmarkFraction.value != second.fraction.value;
//        var isFirstLeftAligned : Bool = first.fraction.value >= benchmarkFraction.value;
//        var isSecondLeftAligned : Bool = second.fraction.value >= benchmarkFraction.value;
//        var isOverUnder : Bool = (isFirstLeftAligned && !isSecondLeftAligned) || (!isFirstLeftAligned && isSecondLeftAligned);
//
//        // Change Denominator Data
//        var fractionLcd : Int = CgsFractionMath.lcm(first.fraction.denominator, second.fraction.denominator);
//        var lcd : Int = CgsFractionMath.lcm(fractionLcd, benchmarkFraction.denominator);
//        var doChangeFirstDenom : Bool = first.fraction.denominator != lcd;
//        var doChangeSecondDenom : Bool = second.fraction.denominator != lcd;
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var origSecondFraction : CgsFraction = second.fraction.clone();
//        var firstMultiplier : Int = as3hx.Compat.parseInt(lcd / first.fraction.denominator);
//        var secondMultiplier : Int = as3hx.Compat.parseInt(lcd / second.fraction.denominator);
//        var benchmarkMultiplier : Int = as3hx.Compat.parseInt(lcd / benchmarkFraction.denominator);
//        var firstMultiplierFraction : CgsFraction = new CgsFraction(firstMultiplier, firstMultiplier);
//        var secondMultiplierFraction : CgsFraction = new CgsFraction(secondMultiplier, secondMultiplier);
//        var newFirstNumerator : Int = as3hx.Compat.parseInt(first.fraction.numerator * firstMultiplier);
//        var newSecondNumerator : Int = as3hx.Compat.parseInt(second.fraction.numerator * secondMultiplier);
//        var newBenchmarkNumerator : Int = as3hx.Compat.parseInt(benchmarkFraction.numerator * benchmarkMultiplier);
//        var finalFirstFraction : CgsFraction = new CgsFraction(newFirstNumerator, lcd);
//        var finalSecondFraction : CgsFraction = new CgsFraction(newSecondNumerator, lcd);
//        var finalBenchmarkFraction : CgsFraction = new CgsFraction(newBenchmarkNumerator, lcd);
//
//        // Set new denom on first
//        first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//        firstModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//        firstModule.resetLogicGrid();
//        first.redraw(true);
//
//        // Set new denom on second
//        second.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
//        secondModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//        secondModule.resetLogicGrid();
//        second.redraw(true);
//
//        // Create comparison fraction view
//        var compareView : CgsFractionView = first.clone();
//        var numCompareUnits : Int = Math.max(firstModule.numTotalUnits, secondModule.numTotalUnits);
//        if (isOverUnder)
//        {
//            var firstMaxDist : Int = Math.ceil(benchmarkFraction.value + Math.abs(benchmarkFraction.value - first.fraction.value));
//            var secondMaxDist : Int = Math.ceil(benchmarkFraction.value + Math.abs(benchmarkFraction.value - second.fraction.value));
//            numCompareUnits = Math.max(numCompareUnits, Math.max(firstMaxDist, secondMaxDist));
//        }
//        compareView.fraction.init(finalBenchmarkFraction.numerator, finalBenchmarkFraction.denominator);
//        var compareModule : GridFractionModule = (try cast(compareView.module, GridFractionModule) catch(e:Dynamic) null);
//        compareModule.valueNumDisplayAlpha = 0;
//        compareModule.doShowSegment = false;
//        compareModule.doShowTicks = false;
//        compareModule.numExtensionUnits = numCompareUnits - compareModule.numBaseUnits;
//        compareModule.gridSeparation = 0;
//        compareView.x = 0;
//        compareView.y = GridConstants.ANIMATION_MARGIN_VERTICAL_NORMAL;
//        compareView.alpha = 0;
//        compareModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//        compareModule.resetLogicGrid();
//        compareView.redraw(true);
//        m_animHelper.trackFractionView(compareView);
//        m_animController.addChild(compareView);
//
//        // Position data
//        var origFirstPosition : Point = new Point(first.x, first.y);
//        var origSecondPosition : Point = new Point(second.x, second.y);
//        var origFirstGridSeparation : Float = firstModule.gridSeparation;
//        var origSecondGridSeparation : Float = secondModule.gridSeparation;
//        var newFirstWidth : Float = (as3hx.Compat.parseFloat(firstModule.numTotalUnits) * firstModule.unitWidth);
//        var newSecondWidth : Float = (as3hx.Compat.parseFloat(secondModule.numTotalUnits) * secondModule.unitWidth);
//        var newCompareWidth : Float = (as3hx.Compat.parseFloat(compareModule.numTotalUnits) * compareModule.unitWidth);
//        var offsetX : Float = Math.max(Math.max(newFirstWidth / 2, newSecondWidth / 2), newCompareWidth / 2);
//        var offsetY : Float = firstModule.unitHeight / 2 + GridConstants.ANIMATION_MARGIN_VERTICAL_SMALL;
//        var newFirstPosition : Point = new Point(newFirstWidth / 2 - offsetX, compareView.y - firstModule.unitHeight / 2 - offsetY);
//        var newSecondPosition : Point = new Point(newSecondWidth / 2 - offsetX, compareView.y + secondModule.unitHeight / 2 + offsetY);
//        var benchmarkOffsetX : Float = firstModule.unitWidth * benchmarkFraction.value;
//
//        // Benchmark View
//        var benchmarkX : Float = newFirstPosition.x - (newFirstWidth / 2) + benchmarkOffsetX;
//        var benchmarkNR : NumberRenderer = m_animHelper.createNumberRenderer(benchmarkFraction, textColor, textGlowColor);
//        benchmarkNR.alpha = 0;
//        benchmarkNR.scaleX = 1.5;
//        benchmarkNR.scaleY = 1.5;
//        benchmarkNR.x = ((!isFirstLeftAligned && !isSecondLeftAligned)) ? benchmarkX + benchmarkNR.width / 2 + GridConstants.ANIMATION_MARGIN_HORIZONTAL_SMALL : benchmarkX - benchmarkNR.width / 2 - GridConstants.ANIMATION_MARGIN_HORIZONTAL_SMALL;
//        benchmarkNR.y = compareView.y;
//
//        // Benchmark Line
//        var benchmarkLine_startY : Float = newFirstPosition.y + firstModule.getValueNRPosition(true, first.fraction.denominator == 1).y + NumberRenderer.MAX_BOX_HEIGHT / 2;
//        var benchmarkLine_endY : Float = newSecondPosition.y + secondModule.getValueNRPosition(false, second.fraction.denominator == 1).y - NumberRenderer.MAX_BOX_HEIGHT / 2;
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
//            // Peel data
//            var firstSegmentHolder : Sprite = new Sprite();
//            var firstSegment : Sprite = new Sprite();
//            m_animController.addChild(firstSegmentHolder);
//            m_animHelper.trackDisplay(firstSegmentHolder);
//            firstSegmentHolder.addChild(firstSegment);
//            m_animHelper.trackDisplay(firstSegment);
//
//            var secondSegmentHolder : Sprite = new Sprite();
//            var secondSegment : Sprite = new Sprite();
//            m_animController.addChild(secondSegmentHolder);
//            m_animHelper.trackDisplay(secondSegmentHolder);
//            secondSegmentHolder.addChild(secondSegment);
//            m_animHelper.trackDisplay(secondSegment);
//
//            // Setup the container and fills of the first grid, we put the fills on a single sprite for smooth emphasis at the end
//            var firstFillAmount : Float = Math.abs(benchmarkFraction.value - first.fraction.value);
//            var firstCompareSprite : Sprite = new Sprite();
//            firstCompareSprite.visible = false;
//            m_animHelper.trackDisplay(firstCompareSprite);
//            // The registration point of the compare sprite is not at the center, but is at the benchmark line.
//            // It is also centered vertically on the whole grid, not on the compare segments that exist.
//            var firstCompareSpriteOffsetX : Float = -firstModule.totalWidth / 2 + benchmarkOffsetX;
//            firstCompareSprite.x = newFirstPosition.x + firstCompareSpriteOffsetX;
//            firstCompareSprite.y = newFirstPosition.y;
//            firstModule.gridSeparation = 0;
//            if (finalFirstFraction.numerator > finalBenchmarkFraction.numerator)
//            {
//                firstModule.peelPlainBlocksAsOne(firstCompareSprite, compareModule.computeBlockIndices(), -firstCompareSpriteOffsetX);
//            }
//            else
//            {
//                // Have to momentarially swap the benchmark and the first fraction values, and update the logic grids,
//                // to compute the peel blocks and their positions correctly. Basically, the first has to be the source
//                // and not the comapre view to make the positioning work out.
//                first.fraction.init(finalBenchmarkFraction.numerator, finalBenchmarkFraction.denominator);
//                firstModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                firstModule.resetLogicGrid();
//                compareView.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//                compareModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                compareModule.resetLogicGrid();
//
//                firstModule.peelPlainBlocksAsOne(firstCompareSprite, compareModule.computeBlockIndices(), -firstCompareSpriteOffsetX);
//
//                first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//                firstModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                firstModule.resetLogicGrid();
//                compareView.fraction.init(finalBenchmarkFraction.numerator, finalBenchmarkFraction.denominator);
//                compareModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                compareModule.resetLogicGrid();
//            }
//            firstModule.gridSeparation = origFirstGridSeparation;
//            // Setup first compare sprite mask
//            var firstComparisonSpriteMaskHeight : Float = firstModule.unitHeight + 6;
//            var firstComparisonSpriteMaskWidth : Float = firstCompareSprite.width + 6;
//            var firstComparisonSpriteMaskOffsetX : Float = firstComparisonSpriteMaskWidth + firstCompareSprite.width / 2 + 1;
//            var firstCompareMask : Sprite = m_animHelper.createMask(firstCompareSprite, firstComparisonSpriteMaskWidth, firstComparisonSpriteMaskHeight);
//            m_animController.addChild(firstCompareMask);
//            firstCompareMask.x = newFirstPosition.x - (newFirstWidth / 2) + benchmarkOffsetX + ((isFirstLeftAligned) ? firstComparisonSpriteMaskOffsetX : -firstComparisonSpriteMaskOffsetX);
//            firstCompareMask.y = newFirstPosition.y;
//            var firstCompareMask_finalX : Float = firstCompareMask.x + ((isFirstLeftAligned) ? -firstCompareMask.width - 1 : firstCompareMask.width + 1);
//
//            // Setup the container and fills of the second grid, we put the fills on a single sprite for smooth emphasis at the end
//            var secondFillAmount : Float = Math.abs(benchmarkFraction.value - second.fraction.value);
//            var secondCompareSprite : Sprite = new Sprite();
//            secondCompareSprite.visible = false;
//            m_animHelper.trackDisplay(secondCompareSprite);
//            // The registration point of the compare sprite is not at the center, but is at the benchmark line.
//            // It is also centered vertically on the whole grid, not on the compare segments that exist.
//            var secondCompareSpriteOffsetX : Float = -secondModule.totalWidth / 2 + benchmarkOffsetX;
//            secondCompareSprite.x = newSecondPosition.x + secondCompareSpriteOffsetX;
//            secondCompareSprite.y = newSecondPosition.y;
//            secondModule.gridSeparation = 0;
//            if (finalSecondFraction.numerator > finalBenchmarkFraction.numerator)
//            {
//                secondModule.peelPlainBlocksAsOne(secondCompareSprite, compareModule.computeBlockIndices(), -secondCompareSpriteOffsetX);
//            }
//            else
//            {
//                // Have to momentarially swap the benchmark and the second fraction values, and update the logic grids,
//                // to compute the peel blocks and their positions correctly. Basically, the second has to be the source
//                // and not the comapre view to make the positioning work out.
//                second.fraction.init(finalBenchmarkFraction.numerator, finalBenchmarkFraction.denominator);
//                secondModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                secondModule.resetLogicGrid();
//                compareView.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
//                compareModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                compareModule.resetLogicGrid();
//
//                secondModule.peelPlainBlocksAsOne(secondCompareSprite, compareModule.computeBlockIndices(), -secondCompareSpriteOffsetX);
//
//                second.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
//                secondModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                secondModule.resetLogicGrid();
//                compareView.fraction.init(finalBenchmarkFraction.numerator, finalBenchmarkFraction.denominator);
//                compareModule.setNumRowsAndColumns(lcd / benchmarkFraction.denominator, benchmarkFraction.denominator);
//                compareModule.resetLogicGrid();
//            }
//            secondModule.gridSeparation = origSecondGridSeparation;
//            // Setup second compare sprite mask
//            var secondComparisonSpriteMaskHeight : Float = secondModule.unitHeight + 6;
//            var secondComparisonSpriteMaskWidth : Float = secondCompareSprite.width + 6;
//            var secondComparisonSpriteMaskOffsetX : Float = secondComparisonSpriteMaskWidth + secondCompareSprite.width / 2 + 1;
//            var secondCompareMask : Sprite = m_animHelper.createMask(secondCompareSprite, secondComparisonSpriteMaskWidth, secondComparisonSpriteMaskHeight);
//            m_animController.addChild(secondCompareMask);
//            secondCompareMask.x = newSecondPosition.x - (newSecondWidth / 2) + benchmarkOffsetX + ((isSecondLeftAligned) ? secondComparisonSpriteMaskOffsetX : -secondComparisonSpriteMaskOffsetX);
//            secondCompareMask.y = newSecondPosition.y;
//            var secondCompareMask_finalX : Float = secondCompareMask.x + ((isSecondLeftAligned) ? -secondCompareMask.width - 1 : secondCompareMask.width + 1);
//
//            // Ensure smaller value is above the larger value
//            if (firstFillAmount >= secondFillAmount)
//            {
//                m_animController.addChild(firstCompareSprite);
//                m_animController.addChild(secondCompareSprite);
//            }
//            else
//            {
//                m_animController.addChild(secondCompareSprite);
//                m_animController.addChild(firstCompareSprite);
//            }
//
//            // Final positions
//            var isLeftAligned : Bool = (isFirstLeftAligned || isSecondLeftAligned);
//            var peelDestinationFraction : CgsFraction = new CgsFraction(numCompareUnits * finalBenchmarkFraction.denominator, finalBenchmarkFraction.denominator);
//            var peelDestinationExclusionList : Array<Int> = new Array<Int>();
//            if (isLeftAligned)
//            {
//                for (compareIndex in 0...finalBenchmarkFraction.numerator)
//                {
//                    peelDestinationExclusionList.push(compareIndex);
//                }
//            }
//            var peelDestinations : Array<Point> = compareModule.getBlockCenterPointsForFraction(peelDestinationFraction, peelDestinationExclusionList);
//
//            // Compare Positioning
//            var fillCompareOffsetPosition : Point = new Point(compareView.x, compareView.y);
//            var firstCompareOffsetX : Float = newFirstPosition.x + (((isLeftAligned && !isFirstLeftAligned)) ? compareModule.unitWidth * benchmarkFraction.value : 0);
//            var secondCompareOffsetX : Float = newSecondPosition.x + (((isLeftAligned && !isSecondLeftAligned)) ? compareModule.unitWidth * benchmarkFraction.value : 0);
//            var firstComparePosition : Point = new Point(firstCompareOffsetX, fillCompareOffsetPosition.y);
//            var secondComparePosition : Point = new Point(secondCompareOffsetX, fillCompareOffsetPosition.y);
//            var firstRotation : Float = ((isOverUnder && !isFirstLeftAligned)) ? 180 : 0;
//            var secondRotation : Float = ((isOverUnder && !isSecondLeftAligned)) ? 180 : 0;
//        }
//
//        // Ensure the benchmark parts are displayed above the compare segments
//        m_animController.addChild(benchmarkNR);
//        m_animController.addChild(benchmarkLine);
//        m_animController.addChild(benchmarkLineMask);
//
//        // Emphasis data
//        var winnerValue : Float = VisualizationUtilities.compareByComparisonType(comparisonType, first.fraction, second.fraction, details);
//        var winnerExists : Bool = winnerValue != 0;
//        var winningView : CgsFractionView;
//        var winningFraction : CgsFraction;
//        var winningModule : GridFractionModule;
//        var winningNR : NumberRenderer;
//        var winningGlowLine : Sprite;
//        var winningGlowFinalPosition : Point;
//        if (winnerExists)
//        {
//            // Setup winning view
//            winningView = ((winnerValue > 0)) ? first : second;
//            winningFraction = ((winnerValue > 0)) ? origFirstFraction : origSecondFraction;
//            winningModule = try cast(winningView.module, GridFractionModule) catch(e:Dynamic) null;
//            winningGlowFinalPosition = ((winnerValue > 0)) ? origFirstPosition : origSecondPosition;
//
//            // Glow
//            winningGlowLine = new Sprite();
//            var winningWidth : Float = (((winnerValue > 0)) ? newFirstWidth : newSecondWidth) + GridConstants.WINNING_GLOW_THICKNESS;
//            var winningHeight : Float = winningModule.unitHeight + GridConstants.WINNING_GLOW_THICKNESS;
//            var glowColor : Int = (Reflect.hasField(details, CgsFVConstants.WINNING_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.WINNING_GLOW_COLOR)) : CgsFVConstants.ANIMATION_WINNING_GLOW_COLOR;
//            winningGlowLine.graphics.beginFill(glowColor);
//            winningGlowLine.graphics.drawRoundRect(-winningWidth / 2, -winningHeight / 2, winningWidth, winningHeight, 10, 10);
//            winningGlowLine.graphics.endFill();
//            winningGlowLine.visible = false;
//            m_animHelper.trackDisplay(winningGlowLine);
//            m_animController.addChildAt(winningGlowLine, m_animController.getChildIndex(winningView));
//            var winningGlowBlur : BlurFilter = new BlurFilter(10, 10);
//            winningGlowLine.filters = [winningGlowBlur];
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
//        benchmarkText.y = newFirstPosition.y - firstModule.unitHeight / 2 - GridConstants.TICK_EXTENSION_DISTANCE - GridConstants.ANIMATION_MARGIN_TEXT - benchmarkText.height / 2;
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
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DURATION_POSITION);
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
//                    gridSeparation : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, position_unitDuration, {
//                    gridSeparation : 0
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
//        var showBenchmark_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_BENCHMARK);
//        var showBenchmark_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DURATION_SHOW_BENCHMARK);
//        var showBenchmarkStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_BENCHMARK, showBenchmark_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_BENCHMARK);
//        showBenchmarkStep.addCallback(0, prepForShowBenchmark, null, prepForShowBenchmark_reverse);
//        var showBenchmarkLineStart : Float = .1;
//        var showBenchmarkValueStart : Float = showBenchmarkLineStart + showBenchmark_unitDuration;
//        showBenchmarkStep.addTween(showBenchmarkValueStart, new GTween(benchmarkNR, showBenchmark_unitDuration / 2, {
//                    alpha : 1
//                }));
//        showBenchmarkStep.addTweenSet(showBenchmarkValueStart, FVEmphasis.computePulseTweens(benchmarkNR, showBenchmark_unitDuration, 1.5, 1.5, GridConstants.PULSE_SCALE_GENERAL));
//        showBenchmarkStep.addTween(showBenchmarkLineStart, new GTween(benchmarkLineMask, showBenchmark_unitDuration, {
//                    y : benchmarkLineMask_finalY
//                }));
//        m_animHelper.appendStep(showBenchmarkStep);
//
//        // Compare
//        if (doCompare)
//        {
//            var compare_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DELAY_AFTER_COMPARE);
//            var compare_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DURATION_COMPARE);
//            var compareStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_COMPARE, compare_unitDelay, CgsFVConstants.STEP_TYPE_COMPARE);
//            compareStep.addCallback(0, prepForCompare, null, prepForCompare_reverse);
//            var hideFirstSegment_startTime : Float = .1;
//            var showComparePartsOfFirst_startTime : Float = hideFirstSegment_startTime + compare_unitDuration / 2;
//            var removeMasksOfFirst_startTime : Float = showComparePartsOfFirst_startTime + compare_unitDuration;
//            var moveComparePartsOfFirst_startTime : Float = removeMasksOfFirst_startTime + .1;
//            var showFirstSegment_startTime : Float = moveComparePartsOfFirst_startTime + compare_unitDuration;
//            var hideSecondSegment_startTime : Float = showFirstSegment_startTime + compare_unitDuration / 2 + compare_unitDelay;
//            var showComparePartsOfSecond_startTime : Float = hideSecondSegment_startTime + compare_unitDuration / 2;
//            var removeMasksOfSecond_startTime : Float = showComparePartsOfSecond_startTime + compare_unitDuration;
//            var moveComparePartsOfSecond_startTime : Float = removeMasksOfSecond_startTime + .1;
//            var showSecondSegment_startTime : Float = moveComparePartsOfSecond_startTime + compare_unitDuration;
//            var finishCompareTime : Float = showSecondSegment_startTime + compare_unitDuration / 2;
//            compareStep.addTween(hideFirstSegment_startTime, new GTween(firstSegmentHolder, compare_unitDuration / 2, {
//                        alpha : 0
//                    }));
//            compareStep.addTween(showComparePartsOfFirst_startTime, new GTween(firstCompareMask, compare_unitDuration, {
//                        x : firstCompareMask_finalX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            compareStep.addCallback(removeMasksOfFirst_startTime, removeCompareMasksOfFirst, null, removeCompareMasksOfFirst_reverse);
//            compareStep.addTween(moveComparePartsOfFirst_startTime, new GTween(firstCompareSprite, compare_unitDuration, {
//                        alpha : GridConstants.FILL_ALPHA_COLORED,
//                        y : firstComparePosition.y,
//                        rotation : firstRotation
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            compareStep.addTween(showFirstSegment_startTime, new GTween(firstSegmentHolder, compare_unitDuration / 2, {
//                        alpha : 1
//                    }));
//            compareStep.addTween(hideSecondSegment_startTime, new GTween(secondSegmentHolder, compare_unitDuration / 2, {
//                        alpha : 0
//                    }));
//            compareStep.addTween(showComparePartsOfSecond_startTime, new GTween(secondCompareMask, compare_unitDuration, {
//                        x : secondCompareMask_finalX
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            compareStep.addCallback(removeMasksOfSecond_startTime, removeCompareMasksOfSecond, null, removeCompareMasksOfSecond_reverse);
//            compareStep.addTween(moveComparePartsOfSecond_startTime, new GTween(secondCompareSprite, compare_unitDuration, {
//                        alpha : GridConstants.FILL_ALPHA_COLORED,
//                        y : secondComparePosition.y,
//                        rotation : secondRotation
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            compareStep.addTween(showSecondSegment_startTime, new GTween(secondSegmentHolder, compare_unitDuration / 2, {
//                        alpha : 1
//                    }));
//            compareStep.addCallback(finishCompareTime, finishCompare, null, finishCompare_reverse);
//            m_animHelper.appendStep(compareStep);
//        }
//
//        // Show result, with emphasis
//        var showResult_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DELAY_AFTER_SHOW_RESULT);
//        var showResult_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DURATION_SHOW_RESULT);
//        var showResultStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SHOW_RESULT, showResult_unitDelay, CgsFVConstants.STEP_TYPE_SHOW_RESULT);
//        showResultStep.addCallback(0, prepForResult, null, prepForResult_reverse);
//        if (winnerExists)
//        {
//            var showResult_emphasizeWinner_startTime : Float = .1;
//            var showResult_winnerPulse_startTime : Float = showResult_emphasizeWinner_startTime + showResult_unitDuration / 2 + showResult_unitDelay;
//            var showResult_winnerMove_startTime : Float = showResult_winnerPulse_startTime + showResult_unitDuration;
//            showResultStep.addTween(showResult_emphasizeWinner_startTime, new GTween(winningGlowLine, showResult_unitDuration / 4, {
//                        alpha : .7
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            showResultStep.addTweenSet(showResult_emphasizeWinner_startTime, FVEmphasis.computePulseTweens(winningGlowLine, showResult_unitDuration / 2, 1, 1, GridConstants.PULSE_SCALE_GENERAL));
//            showResultStep.addTweenSet(showResult_winnerPulse_startTime, FVEmphasis.computePulseTweens(winningNR, showResult_unitDuration, 1, 1, GridConstants.PULSE_SCALE_GENERAL_LARGE));
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
//            showResultStep.addTweenSet(.1, FVEmphasis.computePulseTweens(equalTextHolder, showResult_unitDuration, 1, 1, GridConstants.PULSE_SCALE_GENERAL));
//        }
//        m_animHelper.appendStep(showResultStep);
//
//        // Fade Out
//        var fadeOut_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DELAY_AFTER_FADE);
//        var fadeOut_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DURATION_FADE);
//        var fadeOutStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_FADE_OUT, fadeOut_unitDelay, CgsFVConstants.STEP_TYPE_FADE);
//        fadeOutStep.addTween(0, new GTween(benchmarkLine, fadeOut_unitDuration / 2, {
//                    alpha : 0
//                }));
//        fadeOutStep.addTween(0, new GTween(benchmarkNR, fadeOut_unitDuration / 2, {
//                    alpha : 0
//                }));
//        if (doCompare)
//        {
//            fadeOutStep.addTween(0, new GTween(firstCompareSprite, fadeOut_unitDuration, {
//                        alpha : 0
//                    }));
//            fadeOutStep.addTween(0, new GTween(secondCompareSprite, fadeOut_unitDuration, {
//                        alpha : 0
//                    }));
//        }
//        fadeOutStep.addCallback(fadeOut_unitDuration, finishFade, null, finishFade_reverse);
//        m_animHelper.appendStep(fadeOutStep);
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_COMPARE_TARGET_DURATION_UNPOSITION);
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween(firstModule, unposition_unitDuration, {
//                    gridSeparation : origFirstGridSeparation
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(0, new GTween(secondModule, unposition_unitDuration, {
//                    gridSeparation : origSecondGridSeparation
//                }, {
//                    ease : Sine.easeInOut
//                }));
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
//        unpositionStep.addTween(0, new GTween(firstModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addCallback(unposition_unitDuration / 2, moveValueToBottom, null, moveValueToBottom_reverse);
//        unpositionStep.addTween(unposition_unitDuration * (2 / 3), new GTween(firstModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        if (winnerExists)
//        {
//            unpositionStep.addTween(0, new GTween(winningGlowLine, unposition_unitDuration, {
//                        alpha : 0,
//                        x : winningGlowFinalPosition.x,
//                        y : winningGlowFinalPosition.y
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
//        // Moves the location of the fraction value of the first module
//        function moveValueToTop() : Void
//        {
//            firstModule.valueIsAbove = true;
//            first.redraw(true);
//        };
//
//        function moveValueToTop_reverse() : Void
//        {
//            firstModule.valueIsAbove = false;
//            first.redraw(true);
//        }  // Makes the benchmark line visible  ;
//
//
//
//        var prepForShowBenchmark : Void->Void = function() : Void
//        {
//            benchmarkLine.visible = true;
//        }
//
//        function prepForShowBenchmark_reverse() : Void
//        {
//            benchmarkLine.visible = false;
//        }  // Peels the values of the first and second onto alphaed out segments to be compared  ;
//
//
//
//        var prepForCompare : Void->Void = function() : Void
//        {
//            // Peel (paint to new and hide old) the value onto the secondSegment
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
//            // Peel first
//            firstCompareSprite.visible = true;
//            firstCompareSprite.alpha = 1;
//            firstCompareSprite.mask = firstCompareMask;
//
//            // Peel second
//            secondCompareSprite.visible = true;
//            secondCompareSprite.alpha = 1;
//            secondCompareSprite.mask = secondCompareMask;
//        }
//
//        function prepForCompare_reverse() : Void
//        {
//            // Unpeel
//            firstModule.unpeelValue();
//            firstSegmentHolder.visible = false;
//
//            // Unpeel
//            secondModule.unpeelValue();
//            secondSegmentHolder.visible = false;
//
//            // Hide fill containers
//            firstCompareSprite.visible = false;
//            secondCompareSprite.visible = false;
//        }  // Removes the masks that revealed the compare sprites  ;
//
//
//
//        var removeCompareMasksOfFirst : Void->Void = function() : Void
//        {
//            // Remove first mask
//            firstCompareSprite.mask = null;
//            firstCompareMask.visible = false;
//        }
//
//        function removeCompareMasksOfFirst_reverse() : Void
//        {
//            // Restore first mask
//            firstCompareSprite.mask = firstCompareMask;
//            firstCompareMask.visible = true;
//        }  // Removes the masks that revealed the compare sprites  ;
//
//
//
//        var removeCompareMasksOfSecond : Void->Void = function() : Void
//        {
//            // Remove Second mask
//            secondCompareSprite.mask = null;
//            secondCompareMask.visible = false;
//        }
//
//        function removeCompareMasksOfSecond_reverse() : Void
//        {
//            // Restore second mask
//            secondCompareSprite.mask = secondCompareMask;
//            secondCompareMask.visible = true;
//        }  // Finalizes the compare step, puts everything back the way it was  ;
//
//
//
//        var finishCompare : Void->Void = function() : Void
//        {
//            // Unpeel
//            firstModule.unpeelValue();
//            firstSegmentHolder.visible = false;
//
//            // Unpeel
//            secondModule.unpeelValue();
//            secondSegmentHolder.visible = false;
//        }
//
//        var finishCompare_reverse : Void->Void = function() : Void
//        {
//            // Unpeel
//            firstModule.doShowSegment = false;
//            first.redraw(true);
//            firstSegmentHolder.visible = true;
//
//            // Unpeel
//            secondModule.doShowSegment = false;
//            second.redraw(true);
//            secondSegmentHolder.visible = true;
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
//        var finishFade : Void->Void = function() : Void
//        {
//            if (doCompare)
//            {
//                firstCompareSprite.visible = false;
//                secondCompareSprite.visible = false;
//            }
//        }
//
//        function finishFade_reverse() : Void
//        {
//            if (doCompare)
//            {
//                firstCompareSprite.visible = true;
//                secondCompareSprite.visible = true;
//            }
//        }  // Moves the location of the fraction value of the first module  ;
//
//
//
//        var moveValueToBottom : Void->Void = function() : Void
//        {
//            firstModule.valueIsAbove = false;
//            first.redraw(true);
//        }
//
//        function moveValueToBottom_reverse() : Void
//        {
//            firstModule.valueIsAbove = true;
//            first.redraw(true);
//        }  // Callback    /**
//			 // Completion
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

