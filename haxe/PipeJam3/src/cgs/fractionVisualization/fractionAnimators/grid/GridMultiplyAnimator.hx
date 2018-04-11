package cgs.fractionVisualization.fractionAnimators.grid;

import haxe.Constraints.Function;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.fractionAnimators.AnimationHelper;
import cgs.fractionVisualization.fractionAnimators.AnimationStep;
import cgs.fractionVisualization.fractionAnimators.IFractionAnimator;
import cgs.fractionVisualization.fractionModules.GridFractionModule;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GridConstants;
import cgs.fractionVisualization.util.EquationData;
import cgs.fractionVisualization.util.FVEmphasis;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.math.CgsFraction;
import cgs.math.CgsFractionMath;
import cgs.utils.CgsTuple;
import com.gskinner.motion.easing.Sine;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.Sprite;
import openfl.geom.Point;
import flash.text.TextField;

/**
	 * ...
	 * @author Rich
	 */
class GridMultiplyAnimator implements IFractionAnimator
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
        return CgsFVConstants.GRID_STANDARD_MULTIPLY;
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


        // TODO fix animations
//        var textColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_COLOR)) : GenConstants.DEFAULT_TEXT_COLOR;
//        var textGlowColor : Int = (Reflect.hasField(details, CgsFVConstants.TEXT_GLOW_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_GLOW_COLOR)) : GenConstants.DEFAULT_TEXT_GLOW_COLOR;
//
//        /**
//			 * Setup
//			**/
//
//        var fractionViews : Array<CgsFractionView> = Reflect.field(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY));
//        var finalPosition : Point = Reflect.field(details, Std.string(CgsFVConstants.RESULT_DESTINATION));
//        var first : CgsFractionView = fractionViews[0];
//        var second : CgsFractionView = fractionViews[1];
//        var firstModule : GridFractionModule = (try cast(first.module, GridFractionModule) catch(e:Dynamic) null);
//        var secondModule : GridFractionModule = (try cast(second.module, GridFractionModule) catch(e:Dynamic) null);
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var origSecondFraction : CgsFraction = second.fraction.clone();
//        var resultFraction : CgsFraction = CgsFraction.fMultiply(origFirstFraction, origSecondFraction);
//        var firstIsLarger : Bool = origFirstFraction.value > origSecondFraction.value;
//        var bottomFrac : CgsFractionView = (firstIsLarger) ? second : first;
//        var topFrac : CgsFractionView = (firstIsLarger) ? first : second;
//        var bottomFracModule : GridFractionModule = (try cast(bottomFrac.module, GridFractionModule) catch(e:Dynamic) null);
//        var topFracModule : GridFractionModule = (try cast(topFrac.module, GridFractionModule) catch(e:Dynamic) null);
//        var origBottomFraction : CgsFraction = bottomFrac.fraction.clone();
//        var origTopFraction : CgsFraction = topFrac.fraction.clone();
//
//        // Create result fraction view - Creating this before the intermediates so that it is underneath them in the display list
//        var result : CgsFractionView = bottomFrac.clone();
//        result.fraction.init(resultFraction.numerator, resultFraction.denominator);
//        result.foregroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) : bottomFrac.foregroundColor;
//        result.backgroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) : bottomFrac.backgroundColor;
//        result.borderColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) : bottomFrac.borderColor;
//        result.tickColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) : bottomFrac.tickColor;
//        var resultModule : GridFractionModule = (try cast(result.module, GridFractionModule) catch(e:Dynamic) null);
//        if (bottomFrac.fraction.value < 1 && resultFraction.value < 1)
//        {
//            // Want to fill by row first since both first and result are less than 1
//            {
//                resultModule.fillColumnBeforeRow = false;
//                resultModule.maxRowsToFill = bottomFrac.fraction.numerator;
//                resultModule.maxColumnsToFill = topFrac.fraction.numerator;
//            }
//        }
//        var resultRowCount : Int = origBottomFraction.denominator;
//        var resultColumnCount : Int = origTopFraction.denominator;
//        resultModule.valueIsAbove = true;
//        resultModule.setNumRowsAndColumns(resultRowCount, resultColumnCount);
//        resultModule.resetLogicGrid();
//        result.visible = false;
//        result.redraw(true);
//        m_animHelper.trackFractionView(result);
//        m_animController.addChild(result);
//
//        // Core positioning
//        var maxResultWidth : Float = Math.max(topFracModule.totalWidth, resultModule.totalWidth);
//        var sideWidth : Float = GridConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL + bottomFracModule.unitHeight;
//        // The smaller the result, the less the side width matters. The larger, the more.
//        // This is for centering nicely at both extremes, trying to keep the result as close to the center as possible.
//        var sideContribution : Float = Math.min(1, maxResultWidth / CgsFVConstants.ANIMATION_CONTROLLER_DEFAULT_WIDTH);
//        var totalWidth : Float = maxResultWidth + sideWidth * sideContribution;
//        var centerX : Float = -totalWidth / 2 + (sideWidth * sideContribution) + resultModule.unitWidth / 2;
//        var maxResultHeight : Float = bottomFracModule.totalWidth;
//        var topHeight : Float = GridConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL + topFracModule.unitHeight;
//        // The smaller the result, the less the top height matters. The larger, the more.
//        // This is for centering nicely at both extremes, trying to keep the result as close to the center as possible.
//        var topContribution : Float = Math.min(1, maxResultHeight / CgsFVConstants.ANIMATION_CONTROLLER_DEFAULT_HEIGHT);
//        var totalHeight : Float = maxResultHeight + topHeight * topContribution;
//        var centerY : Float = -totalHeight / 2 + ((topHeight + resultModule.unitHeight / 2) * topContribution) + resultModule.unitHeight / 2;
//        var centerPosition : Point = new Point(centerX, centerY);
//        // Need to normalize result X but not Y, because we can have multiple grids wide but not tall
//        var resultPosition : Point = new Point(centerPosition.x + resultModule.totalWidth / 2 - resultModule.unitWidth / 2, centerPosition.y);
//        result.x = resultPosition.x;
//        result.y = resultPosition.y;
//
//        // Create intermediate results
//        var numIntermediates : Int = as3hx.Compat.parseInt(bottomFracModule.numBaseUnits * topFracModule.numBaseUnits);
//        var intermediateResults : Array<CgsFractionView> = new Array<CgsFractionView>();
//        var intermediatePositions : Array<Point> = new Array<Point>();
//        for (intermediateIndex in 0...numIntermediates)
//        {
//            // Compute the numberator of this intermediate result
//            var secondIndex : Int = as3hx.Compat.parseInt(intermediateIndex % topFracModule.numBaseUnits);
//            var firstIndex : Int = Math.floor(intermediateIndex / topFracModule.numBaseUnits);
//            var numeratorOfFirst : Int = VisualizationUtilities.getNumeratorSubsetOfFraction(bottomFrac.fraction, firstIndex);
//            var numeratorOfSecond : Int = VisualizationUtilities.getNumeratorSubsetOfFraction(topFrac.fraction, secondIndex);
//            var numeratorOfIntermediate : Int = as3hx.Compat.parseInt(numeratorOfFirst * numeratorOfSecond);
//
//            // Setup intermediate result
//            var anIntermediateResult : CgsFractionView = result.clone();
//            anIntermediateResult.fraction.init(numeratorOfIntermediate, resultFraction.denominator);
//            var anIntermediateModule : GridFractionModule = (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null);
//            anIntermediateModule.maxRowsToFill = numeratorOfFirst;
//            anIntermediateModule.maxColumnsToFill = numeratorOfSecond;
//            anIntermediateModule.setNumRowsAndColumns(resultRowCount, resultColumnCount);
//            anIntermediateModule.resetLogicGrid();
//            anIntermediateResult.visible = false;
//            anIntermediateResult.redraw(true);
//            m_animHelper.trackFractionView(anIntermediateResult);
//            m_animController.addChild(anIntermediateResult);
//            intermediateResults.push(anIntermediateResult);
//
//            // Setup intermediate position
//            var anIntermediatePosition : Point = new Point(centerPosition.x + secondIndex * (topFracModule.unitWidth + topFracModule.gridSeparation),
//            centerPosition.y + firstIndex * (bottomFracModule.unitWidth + bottomFracModule.gridSeparation));
//            intermediatePositions.push(anIntermediatePosition);
//            anIntermediateResult.x = anIntermediatePosition.x;
//            anIntermediateResult.y = anIntermediatePosition.y;
//        }
//
//        // Make into elongated strip
//        bottomFracModule.isElongatedStrip = true;
//        topFracModule.isElongatedStrip = true;
//
//        // Position data
//        var oldFirstPosition : Point = new Point(bottomFrac.x, bottomFrac.y);
//        var oldSecondPosition : Point = new Point(topFrac.x, topFrac.y);
//        var newFirstPosition : Point = new Point(centerPosition.x - GridConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL - bottomFracModule.unitHeight, centerPosition.y + bottomFracModule.totalWidth / 2 - bottomFracModule.unitWidth / 2);
//        var newSecondPosition : Point = new Point(centerPosition.x + topFracModule.totalWidth / 2 - topFracModule.unitWidth / 2, centerPosition.y - GridConstants.ANIMATION_MARGIN_VERTICAL_NORMAL - topFracModule.unitHeight);
//        var newMultiplicationPosition : Point = new Point(newFirstPosition.x, newSecondPosition.y);
//
//        // Get equation data
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, newMultiplicationPosition, first.fraction, " × ", second.fraction, resultFraction, textColor, textGlowColor, 1.5);
//        eqData.equationCenter = new Point(eqData.equationCenter.x + eqData.secondValueNR.width / 2 + eqData.equalsSymbolText.width / 2, eqData.equationCenter.y);
//        var eqData_startScale : Float = 1 / 1.5;
//
//        // Black lines
//        var tableBorder : Sprite = new Sprite();
//        tableBorder.graphics.lineStyle(GridConstants.MULTIPLICATION_TABLE_BORDER_THICKNESS, GridConstants.MULTIPLICATION_TABLE_BORDER_COLOR);
//        tableBorder.graphics.moveTo(centerPosition.x + topFracModule.totalWidth, centerPosition.y - GridConstants.ANIMATION_MARGIN_VERTICAL_NORMAL / 2 - topFracModule.unitWidth / 2);
//        tableBorder.graphics.lineTo(centerPosition.x - GridConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL / 2 - topFracModule.unitWidth / 2, centerPosition.y - GridConstants.ANIMATION_MARGIN_VERTICAL_NORMAL / 2 - bottomFracModule.unitWidth / 2);
//        tableBorder.graphics.lineTo(centerPosition.x - GridConstants.ANIMATION_MARGIN_HORIZONTAL_NORMAL / 2 - topFracModule.unitWidth / 2, centerPosition.y + bottomFracModule.totalWidth);
//        tableBorder.graphics.endFill();
//        tableBorder.alpha = 0;
//        m_animHelper.trackDisplay(tableBorder);
//        m_animController.addChild(tableBorder);
//
//        // Tick Sprites for each intermediate result
//        var tickSpritesOfFirst : Array<Sprite> = new Array<Sprite>();
//        var tickDestinationsOfFirst : Array<Point> = new Array<Point>();
//        var furthestFirstTickDistance : Float = 0;
//        var tickSpritesOfSecond : Array<Sprite> = new Array<Sprite>();
//        var tickDestinationsOfSecond : Array<Point> = new Array<Point>();
//        var furthestSecondTickDistance : Float = 0;
//        for (intermediateIndex in 0...numIntermediates)
//        {
//            // Create a tick sprite for the first
//            var aTickSprite : Sprite = new Sprite();
//            m_animHelper.trackDisplay(aTickSprite);
//            m_animController.addChild(aTickSprite);
//            aTickSprite.visible = false;
//            tickSpritesOfFirst.push(aTickSprite);
//
//            // Set its position
//            var aTickDestination : Point = intermediatePositions[intermediateIndex].clone();
//            aTickSprite.x = newFirstPosition.x;
//            aTickSprite.y = aTickDestination.y;
//            tickDestinationsOfFirst.push(aTickDestination);
//
//            // Check for furthest distance a tick moves
//            var aTickDist : Float = aTickDestination.x - aTickSprite.x;
//            if (aTickDist > furthestFirstTickDistance)
//            {
//                furthestFirstTickDistance = aTickDist;
//            }
//
//            // Create a tick sprite for the second
//            aTickSprite = new Sprite();
//            m_animHelper.trackDisplay(aTickSprite);
//            m_animController.addChild(aTickSprite);
//            aTickSprite.visible = false;
//            tickSpritesOfSecond.push(aTickSprite);
//
//            // Set its position
//            aTickDestination = aTickDestination.clone();
//            aTickSprite.x = aTickDestination.x;
//            aTickSprite.y = newSecondPosition.y;
//            tickDestinationsOfSecond.push(aTickDestination);
//
//            // Check for furthest distance a tick moves
//            aTickDist = aTickDestination.y - aTickSprite.y;
//            if (aTickDist > furthestSecondTickDistance)
//            {
//                furthestSecondTickDistance = aTickDist;
//            }
//        }
//
//        // Drop
//        var dropSegmentsOfFirst : Array<Sprite> = new Array<Sprite>();
//        var dropBackbonesOfFirst : Array<Sprite> = new Array<Sprite>();
//        var dropSegmentDestinationsOfFirst : Array<Point> = new Array<Point>();
//        var furthestFirstDropSegmentDistance : Float = 0;
//        var dropSegmentsOfSecond : Array<Sprite> = new Array<Sprite>();
//        var dropBackbonesOfSecond : Array<Sprite> = new Array<Sprite>();
//        var dropSegmentDestinationsOfSecond : Array<Point> = new Array<Point>();
//        var furthestSecondDropSegmentDistance : Float = 0;
//        var dropResults : Array<Sprite> = new Array<Sprite>();
//        var dropResultMasks : Array<Sprite> = new Array<Sprite>();
//        for (intermediateIndex in 0...numIntermediates)
//        {
//            // Create a backbone for each drop segment of the first
//            var aDropBackbone : Sprite = new Sprite();
//            m_animHelper.trackDisplay(aDropBackbone);
//            aDropBackbone.visible = false;
//            dropBackbonesOfFirst.push(aDropBackbone);
//
//            // Create drop segment for first fraction
//            var aDropSegment : Sprite = new Sprite();
//            m_animHelper.trackDisplay(aDropSegment);
//            aDropSegment.visible = false;
//            dropSegmentsOfFirst.push(aDropSegment);
//
//            // Set its position
//            var aDropSegmentDestination : Point = intermediatePositions[intermediateIndex].clone();
//            aDropBackbone.x = newFirstPosition.x;
//            aDropBackbone.y = aDropSegmentDestination.y;
//            aDropSegment.x = newFirstPosition.x;
//            aDropSegment.y = aDropSegmentDestination.y;
//            dropSegmentDestinationsOfFirst.push(aDropSegmentDestination);
//
//            // Check for furthest distance a tick moves
//            var aDropSegmentDist : Float = aDropSegmentDestination.x - aDropSegment.x;
//            if (aDropSegmentDist > furthestFirstDropSegmentDistance)
//            {
//                furthestFirstDropSegmentDistance = aDropSegmentDist;
//            }
//
//            // Create a backbone for each drop segment of the second
//            aDropBackbone = new Sprite();
//            m_animHelper.trackDisplay(aDropBackbone);
//            aDropBackbone.visible = false;
//            dropBackbonesOfSecond.push(aDropBackbone);
//
//            // Create drop segment for second fraction
//            aDropSegment = new Sprite();
//            m_animHelper.trackDisplay(aDropSegment);
//            aDropSegment.visible = false;
//            dropSegmentsOfSecond.push(aDropSegment);
//
//            // Set its position
//            aDropSegmentDestination = aDropSegmentDestination.clone();
//            aDropBackbone.x = aDropSegmentDestination.x;
//            aDropBackbone.y = newSecondPosition.y;
//            aDropSegment.x = aDropSegmentDestination.x;
//            aDropSegment.y = newSecondPosition.y;
//            dropSegmentDestinationsOfSecond.push(aDropSegmentDestination);
//
//            // Check for furthest distance a tick moves
//            aDropSegmentDist = aDropSegmentDestination.y - aDropSegment.y;
//            if (aDropSegmentDist > furthestSecondDropSegmentDistance)
//            {
//                furthestSecondDropSegmentDistance = aDropSegmentDist;
//            }
//
//            // Create drop segment for first fraction
//            var aDropResult : Sprite = new Sprite();
//            m_animHelper.trackDisplay(aDropResult);
//            aDropResult.x = aDropSegmentDestination.x;
//            aDropResult.y = aDropSegmentDestination.y;
//            aDropResult.visible = false;
//            dropResults.push(aDropResult);
//
//            // Create a mask for each drop segment
//            var aDropResultMask : Sprite = m_animHelper.createMask(aDropResult, resultModule.unitWidth, resultModule.unitHeight);
//            aDropResultMask.x = aDropSegmentDestination.x;
//            aDropResultMask.y = newSecondPosition.y;
//            dropResultMasks.push(aDropResultMask);
//        }
//
//        // Add all the drop parts in a particular order
//        for (aDropBackbone in dropBackbonesOfFirst)
//        {
//            m_animController.addChild(aDropBackbone);
//        }
//        for (aDropBackbone in dropBackbonesOfSecond)
//        {
//            m_animController.addChild(aDropBackbone);
//        }
//        for (aDropSegment in dropSegmentsOfFirst)
//        {
//            m_animController.addChild(aDropSegment);
//        }
//        for (aDropSegment in dropSegmentsOfSecond)
//        {
//            m_animController.addChild(aDropSegment);
//        }
//        for (aDropResult in dropResults)
//        {
//            m_animController.addChild(aDropResult);
//        }
//        for (aDropResultMask in dropResultMasks)
//        {
//            m_animController.addChild(aDropResultMask);
//        }
//
//        // Merge data
//        var finalEquationCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var finalEqData : EquationData = m_animHelper.createEquationData(m_animController, finalEquationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor);
//        finalEqData.equationCenter = new Point(finalEqData.equationCenter.x - finalEqData.secondValueNR.width / 2 - finalEqData.equalsSymbolText.width - finalEqData.resultValueNR.width / 2, finalEqData.equationCenter.y);
//
//        // Merge - also known as rearranging and switching
//        var doMoveBlocks : Bool = (bottomFrac.fraction.value < 1 && topFrac.fraction.value > 1) || (bottomFrac.fraction.value > 1);
//        var mergeBlocks : Array<Sprite> = new Array<Sprite>();
//        var mergeBlockDestinations : Array<Point> = new Array<Point>();
//        // If first fraction is > 1, then whole first row does not need to move; otherwise, just first square is ok to stay
//        var mergeStartIndex : Int = ((bottomFrac.fraction.value < 1)) ? 1 : topFracModule.numBaseUnits;
//        var mergeOverlapIndex : Int = ((bottomFrac.fraction.value < 1)) ? Math.min(resultModule.numBaseUnits, topFracModule.numBaseUnits) : topFracModule.numBaseUnits;
//        var doHideIntermediates : Bool = numIntermediates > mergeOverlapIndex;
//        var doShowResultBackbone : Bool = resultModule.numBaseUnits > topFracModule.numBaseUnits;
//
//        // Form exclusion list with intermediate results that will not have their blocks moved
//        var exclusionList : Array<Int> = new Array<Int>();
//        for (intermediateIndex in 0...mergeStartIndex)
//        {
//            anIntermediateResult = intermediateResults[intermediateIndex];
//            anIntermediateModule = (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null);
//
//            // Compute by row then column fill
//            if (bottomFrac.fraction.value < 1)
//            {
//                // Compute the list of indicies to be removed
//                for (rIndex in 0...resultRowCount)
//                {
//                    for (cIndex in 0...resultColumnCount)
//                    {
//                        var aBlockIndex : Int = as3hx.Compat.parseInt(rIndex + (cIndex * resultRowCount));
//                        exclusionList.push(aBlockIndex);
//                        // Break out once we have found all the indices of the intermediate result
//                        if (exclusionList.length >= anIntermediateResult.fraction.numerator)
//                        {
//                            break;
//                        }
//                    }
//                    // Break out once we have found all the indices of the intermediate result
//                    if (exclusionList.length >= anIntermediateResult.fraction.numerator)
//                    {
//                        break;
//                    }
//                }
//            }
//            else
//            {
//                // Compute with normal fill
//                {
//                    for (eIndex in 0...anIntermediateResult.fraction.numerator)
//                    {
//                        var indexOffset : Int = as3hx.Compat.parseInt(anIntermediateResult.fraction.denominator * intermediateIndex);
//                        exclusionList.push(indexOffset + eIndex);
//                    }
//                }
//            }
//        }
//        // Sort the list, for good measure
//        exclusionList.sort(function(sortFirst : Int, sortSecond : Int) : Float
//                {
//                    return sortFirst - sortSecond;
//                });
//
//        // Get result block locations (that are not in the exculsion list)
//        var resultBlockLocations : Array<Point> = resultModule.getBlockCenterPoints(exclusionList);
//
//        // Create blocks and set destinations for all blocks that will move
//        for (intermediateIndex in mergeStartIndex...numIntermediates)
//        {
//            anIntermediateResult = intermediateResults[intermediateIndex];
//            anIntermediateModule = (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null);
//
//            // Create all the blocks for this intermediate result
//            var intermediateMergeTuple : CgsTuple = anIntermediateModule.peelBlocks();
//            var intermediateMergeBlocks : Array<Sprite> = intermediateMergeTuple.first;
//            var intermediateMergeLocations : Array<Point> = intermediateMergeTuple.second;
//            for (intermediateMergeIndex in 0...anIntermediateResult.fraction.numerator)
//            {
//                // Add the blocks to the display list
//                var aMergeBlock : Sprite = intermediateMergeBlocks[intermediateMergeIndex];
//                m_animHelper.trackDisplay(aMergeBlock);
//                m_animController.addChild(aMergeBlock);
//                aMergeBlock.visible = false;
//
//                // Adjust their locations
//                var aMergeLocation : Point = intermediateMergeLocations[intermediateMergeIndex];
//                aMergeBlock.x = anIntermediateResult.x + aMergeLocation.x;
//                aMergeBlock.y = anIntermediateResult.y + aMergeLocation.y;
//
//                // Save to storage
//                mergeBlocks.push(aMergeBlock);
//                var aMergeDestination : Point = resultBlockLocations.shift();
//                aMergeDestination.x += result.x;
//                aMergeDestination.y += result.y;
//                mergeBlockDestinations.push(aMergeDestination);
//            }
//        }
//
//        // Simplification
//        var doSimplify : Bool = !resultFraction.isSimplified;
//        var simplifiedResultFraction : CgsFraction = resultFraction.clone();
//        simplifiedResultFraction.simplify();
//        var simplifiedResult : CgsFractionView = result.clone();
//        simplifiedResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//        var simplifiedResultModule : GridFractionModule = (try cast(simplifiedResult.module, GridFractionModule) catch(e:Dynamic) null);
//        simplifiedResultModule.valueIsAbove = true;
//        simplifiedResultModule.setNumRowsAndColumns();
//        simplifiedResultModule.resetLogicGrid();
//        simplifiedResult.visible = false;
//        simplifiedResult.redraw(true);
//        simplifiedResult.x = resultPosition.x;
//        simplifiedResult.y = resultPosition.y;
//        m_animHelper.trackFractionView(simplifiedResult);
//        m_animController.addChild(simplifiedResult);
//
//
//        /**
//			 * Tweens
//			**/
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_POSITION);
//        var positionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_POSITION, position_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        positionStep.addCallback(0, prepMultiplicationSymbol, null, prepMultiplicationSymbol_reverse);
//        var position_moveFractions_startTime : Float = .1;
//        var position_showTableBorder : Float = position_moveFractions_startTime + position_unitDuration;
//        var position_prepEquation : Float = position_showTableBorder + position_unitDuration;
//        var position_showFirstNR_startTime : Float = position_prepEquation + .1;
//        var position_moveFirstNR_startTime : Float = position_showFirstNR_startTime + position_unitDuration / 2;
//        var position_showSecondNR_startTime : Float = position_moveFirstNR_startTime + position_unitDuration;
//        var position_moveSecondNR_startTime : Float = position_showSecondNR_startTime + position_unitDuration / 2;
//        positionStep.addTween(position_moveFractions_startTime, new GTween(bottomFrac, position_unitDuration, {
//                    x : newFirstPosition.x,
//                    y : newFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_moveFractions_startTime, new GTween(topFrac, position_unitDuration, {
//                    x : newSecondPosition.x,
//                    y : newSecondPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_moveFractions_startTime, new GTween(eqData.opSymbolText, position_unitDuration, {
//                    alpha : 1,
//                    x : eqData.opSymbolText_equationPosition.x,
//                    y : eqData.opSymbolText_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_moveFractions_startTime, new GTween(bottomFracModule, position_unitDuration, {
//                    rotationRadians : Math.PI / 2
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_moveFractions_startTime, new GTween(topFracModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(position_moveFractions_startTime + position_unitDuration / 2, moveValueToTop, null, moveValueToTop_reverse);
//        positionStep.addTween(position_moveFractions_startTime + position_unitDuration * (2 / 3), new GTween(topFracModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_showTableBorder, new GTween(tableBorder, position_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addCallback(position_prepEquation, prepEquation, null, prepEquation_reverse);
//        positionStep.addTween(position_showFirstNR_startTime, new GTween(firstModule, position_unitDuration / 4, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_showFirstNR_startTime, new GTween(eqData.firstValueNR, position_unitDuration / 4, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTweenSet(position_showFirstNR_startTime, FVEmphasis.computePulseTweens(eqData.firstValueNR, position_unitDuration / 2, 1, 1, GridConstants.PULSE_SCALE_GENERAL));
//        positionStep.addTween(position_moveFirstNR_startTime, new GTween(eqData.firstValueNR, position_unitDuration, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_showSecondNR_startTime, new GTween(secondModule, position_unitDuration / 4, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(position_showSecondNR_startTime, new GTween(eqData.secondValueNR, position_unitDuration / 4, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTweenSet(position_showSecondNR_startTime, FVEmphasis.computePulseTweens(eqData.secondValueNR, position_unitDuration / 2, 1, 1, GridConstants.PULSE_SCALE_GENERAL));
//        positionStep.addTween(position_moveSecondNR_startTime, new GTween(eqData.secondValueNR, position_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        //m_animHelper.appendStep(positionStep);
//
//        // Drop
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DELAY_AFTER_DROP);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_DROP);
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, prepForDrop, null, prepForDrop_reverse);
//        dropStep.addCallback(0, prepForShowIntermediates, null, prepForShowIntermediates_reverse);
//        var firstDropSegmentTime : Float = .1;
//        var secondDropSegmentTime : Float = firstDropSegmentTime + drop_unitDuration * (3 / 2);
//        var fadeToResultTime : Float = secondDropSegmentTime + drop_unitDuration * (3 / 2);
//        var finishDropTime : Float = fadeToResultTime + drop_unitDuration;
//        var drop_fadeOutOriginals_startTime : Float = finishDropTime + .1;
//        var drop_moveEquation_startTime : Float = drop_fadeOutOriginals_startTime + drop_unitDuration;
//        var firstDropSegmentTravelTime : Float = drop_unitDuration / furthestFirstDropSegmentDistance;  // Want all the segments to move at the same rate, which will be the rate of the one that has to travel the furthest
//        var secondDropSegmentTravelTime : Float = drop_unitDuration / furthestSecondDropSegmentDistance;  // Want all the segments to move at the same rate, which will be the rate of the one that has to travel the furthest
//        for (intermediateIndex in 0...numIntermediates)
//        {
//            // Tween drop segment and backbone of the first
//            aDropBackbone = dropBackbonesOfFirst[intermediateIndex];
//            aDropSegment = dropSegmentsOfFirst[intermediateIndex];
//            aDropSegmentDestination = dropSegmentDestinationsOfFirst[intermediateIndex];
//            aDropSegmentDist = aDropSegmentDestination.x - aDropSegment.x;
//            dropStep.addTween(firstDropSegmentTime, new GTween(aDropBackbone, aDropSegmentDist * firstDropSegmentTravelTime, {
//                        x : aDropSegmentDestination.x,
//                        y : aDropSegmentDestination.y
//                    }));
//            dropStep.addTween(firstDropSegmentTime, new GTween(aDropSegment, aDropSegmentDist * firstDropSegmentTravelTime, {
//                        x : aDropSegmentDestination.x,
//                        y : aDropSegmentDestination.y
//                    }));
//            dropStep.addTween(fadeToResultTime, new GTween(aDropBackbone, drop_unitDuration, {
//                        alpha : 0
//                    }));
//            dropStep.addTween(fadeToResultTime, new GTween(aDropSegment, drop_unitDuration, {
//                        alpha : 0
//                    }));
//
//            // Tween drop segment and backbone of the second
//            aDropBackbone = dropBackbonesOfSecond[intermediateIndex];
//            aDropSegment = dropSegmentsOfSecond[intermediateIndex];
//            aDropSegmentDestination = dropSegmentDestinationsOfSecond[intermediateIndex];
//            aDropSegmentDist = aDropSegmentDestination.y - aDropSegment.y;
//            dropStep.addTween(secondDropSegmentTime, new GTween(aDropBackbone, aDropSegmentDist * secondDropSegmentTravelTime, {
//                        x : aDropSegmentDestination.x,
//                        y : aDropSegmentDestination.y
//                    }));
//            dropStep.addTween(secondDropSegmentTime, new GTween(aDropSegment, aDropSegmentDist * secondDropSegmentTravelTime, {
//                        x : aDropSegmentDestination.x,
//                        y : aDropSegmentDestination.y
//                    }));
//            dropStep.addTween(fadeToResultTime, new GTween(aDropBackbone, drop_unitDuration, {
//                        alpha : 0
//                    }));
//            dropStep.addTween(fadeToResultTime, new GTween(aDropSegment, drop_unitDuration, {
//                        alpha : 0
//                    }));
//
//            // Tween drop result masks
//            aDropResultMask = dropResultMasks[intermediateIndex];
//            dropStep.addTween(secondDropSegmentTime, new GTween(aDropResultMask, aDropSegmentDist * secondDropSegmentTravelTime, {
//                        x : aDropSegmentDestination.x,
//                        y : aDropSegmentDestination.y
//                    }));
//
//            // Tween in results
//            aDropResult = dropResults[intermediateIndex];
//            dropStep.addTween(fadeToResultTime, new GTween(aDropResult, drop_unitDuration, {
//                        alpha : 1
//                    }));
//            for (anIntermediateResult in intermediateResults)
//            {
//                dropStep.addTween(fadeToResultTime, new GTween(anIntermediateResult, drop_unitDuration, {
//                            alpha : 1
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//            }
//        }
//        dropStep.addCallback(finishDropTime, finishDrop, null, finishDrop_reverse);
//        dropStep.addTween(drop_fadeOutOriginals_startTime, new GTween(bottomFrac, drop_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_fadeOutOriginals_startTime, new GTween(topFrac, drop_unitDuration, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(drop_fadeOutOriginals_startTime, new GTween(tableBorder, drop_unitDuration, {
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
//        m_animHelper.appendStep(dropStep);
//
//        // Merge - also known as rearranging and switching
//        var merge_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DELAY_AFTER_MERGE);
//        var merge_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_MERGE);
//        var merge_durationPerBlock : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_MERGE_PER_BLOCK);
//        var merge_maxBlockDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_MERGE_BLOCKS_MAX);
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, merge_unitDelay, CgsFVConstants.STEP_TYPE_MERGE);
//        var merge_moveBlocks_startTime : Float = 0;
//        var merge_finishMoveBlocks_startTime : Float = merge_moveBlocks_startTime;
//        if (doMoveBlocks)
//        {
//            mergeStep.addCallback(0, prepForMoveBlocks, null, prepForMoveBlocks_reverse);
//            merge_moveBlocks_startTime = .1;
//            var merge_moveBlocks_totalDuration : Float = Math.min((merge_durationPerBlock / 2) * (mergeBlocks.length + 1), merge_maxBlockDuration);
//            var aMergeMoveDuration : Float = (merge_moveBlocks_totalDuration / (mergeBlocks.length + 1)) * 2;  // Each block starts moving after the last block has gotten half way
//            var merge_hideIntermediates_startTime : Float = merge_moveBlocks_startTime + merge_moveBlocks_totalDuration;
//            var merge_showResultFraction_startTime : Float = (doHideIntermediates) ? merge_hideIntermediates_startTime + merge_unitDuration : merge_hideIntermediates_startTime;
//            merge_finishMoveBlocks_startTime = (doShowResultBackbone) ? merge_showResultFraction_startTime + merge_unitDuration : merge_showResultFraction_startTime;
//            var thisMergeMoveTime : Float = merge_moveBlocks_startTime;
//            for (mergeBlockIndex in 0...mergeBlocks.length)
//            {
//                // Add the blocks to the display list
//                aMergeBlock = mergeBlocks[mergeBlockIndex];
//                aMergeDestination = mergeBlockDestinations[mergeBlockIndex];
//                mergeStep.addTween(thisMergeMoveTime, new GTween(aMergeBlock, aMergeMoveDuration, {
//                            x : aMergeDestination.x,
//                            y : aMergeDestination.y
//                        }));
//                thisMergeMoveTime += aMergeMoveDuration / 2;
//            }
//            // Hide the intermediates that are not overlaping with the result
//            if (doHideIntermediates)
//            {
//                for (intermediateIndex in mergeOverlapIndex...numIntermediates)
//                {
//                    // Hide segments on intermediate result
//                    anIntermediateResult = intermediateResults[intermediateIndex];
//                    mergeStep.addTween(merge_hideIntermediates_startTime, new GTween(anIntermediateResult, merge_unitDuration, {
//                                alpha : 0
//                            }, {
//                                ease : Sine.easeInOut
//                            }));
//                }
//            }
//            // Show the result segments, but only need to take time to do this if there are extra backbones beyond the intermediates
//            if (doShowResultBackbone)
//            {
//                mergeStep.addTween(merge_showResultFraction_startTime, new GTween(result, merge_unitDuration, {
//                            alpha : 1
//                        }));
//            }
//            mergeStep.addCallback(merge_finishMoveBlocks_startTime, finishMoveBlocks, null, finishMoveBlocks_reverse);
//        }
//        // Handle Equation
//        var merge_finalizeMerge_startTime : Float = merge_finishMoveBlocks_startTime + ((doMoveBlocks) ? .1 : 0);
//        var merge_showResultValue_startTime : Float = merge_finalizeMerge_startTime + .1;
//        var merge_consolidateResult_startTime : Float = merge_showResultValue_startTime + merge_unitDuration + merge_unitDelay;  // Includes a little delay after the result text is visible
//        var merge_finalizeEquationTime : Float = merge_consolidateResult_startTime + merge_unitDuration;
//        mergeStep.addCallback(merge_finalizeMerge_startTime, finalizeMerge, null, finalizeMerge_reverse);
//        mergeStep.addTweenSet(merge_showResultValue_startTime, EquationData.animationEquationInline_phaseTwo(finalEqData, merge_unitDuration));
//        mergeStep.addTweenSet(merge_consolidateResult_startTime, EquationData.consolidateEquation(finalEqData, merge_unitDuration, finalEqData.resultValueNR_equationPosition));
//        mergeStep.addCallback(merge_finalizeEquationTime, finalizeEquation, null, finalizeEquation_reverse);
//        m_animHelper.appendStep(mergeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplification_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DELAY_AFTER_SIMPLIFICATION);
//            var simplification_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_SIMPLIFICATION);
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
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_MULT_DURATION_UNPOSITION);
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
//        unpositionStep.addCallback(unposition_unitDuration / 2, moveValueToBottom, null, moveValueToBottom_reverse);
//        unpositionStep.addTween(unposition_unitDuration * (2 / 3), new GTween((doSimplify) ? simplifiedResultModule : resultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
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
//        // Prepares the multiplication symbol of the equation for animation
//        function prepMultiplicationSymbol() : Void
//        {
//            // Adjust location
//            eqData.opSymbolText.x = -eqData.opSymbolText.width / 2;
//            eqData.opSymbolText.y = bottomFrac.y - eqData.opSymbolText.height / 2;
//
//            // Adjust alpha and visibility
//            eqData.opSymbolText.alpha = 0;
//            eqData.opSymbolText.visible = true;
//        };
//
//        function prepMultiplicationSymbol_reverse() : Void
//        {
//            // Adjust visibility
//            eqData.opSymbolText.visible = false;
//        }  // Prepares the equation for animation  ;
//
//
//
//        var prepEquation : Void->Void = function() : Void
//        {
//            // Adjust locations of fraction value NRs
//            eqData.firstValueNR.x = first.x + firstModule.valueNRPosition.x;
//            eqData.firstValueNR.y = first.y + firstModule.valueNRPosition.y;
//            eqData.secondValueNR.x = second.x + secondModule.valueNRPosition.x;
//            eqData.secondValueNR.y = second.y + secondModule.valueNRPosition.y;
//            eqData.equalsSymbolText.x = eqData.equalsSymbolText_equationPosition.x;
//            eqData.equalsSymbolText.y = eqData.equalsSymbolText_equationPosition.y;
//            eqData.resultValueNR.x = eqData.resultValueNR_equationPosition.x;
//            eqData.resultValueNR.y = eqData.resultValueNR_equationPosition.y;
//
//            // Adjust alphas and visibility of equation parts
//            eqData.firstValueNR.alpha = 0;
//            eqData.secondValueNR.alpha = 0;
//            eqData.equalsSymbolText.alpha = 0;
//            eqData.resultValueNR.alpha = 0;
//            eqData.firstValueNR.visible = true;
//            eqData.secondValueNR.visible = true;
//            eqData.equalsSymbolText.visible = true;
//            eqData.resultValueNR.visible = true;
//
//            // Set scales of first and second NRs
//            eqData.firstValueNR.scaleX = eqData_startScale;
//            eqData.firstValueNR.scaleY = eqData_startScale;
//            eqData.secondValueNR.scaleX = eqData_startScale;
//            eqData.secondValueNR.scaleY = eqData_startScale;
//        }
//
//        function prepEquation_reverse() : Void
//        {
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }  // Moves the location of the fraction value of the second module back to above the grid  ;
//
//
//
//        var moveValueToTop : Void->Void = function() : Void
//        {
//            topFracModule.valueIsAbove = true;
//        }
//
//        function moveValueToTop_reverse() : Void
//        {
//            topFracModule.valueIsAbove = false;
//        }  // Moves the location of the fraction value of the second module back to above the grid  ;
//
//
//
//        var prepForShowIntermediates : Void->Void = function() : Void
//        {
//            // Show intermediate results, reset their positions
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                anIntermediateModule = (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null);
//                anIntermediatePosition = intermediatePositions[intermediateIndex];
//                anIntermediateResult.visible = true;
//                anIntermediateResult.alpha = 0;
//                anIntermediateModule.valueNumDisplayAlpha = 0;
//                anIntermediateModule.doShowSegment = false;
//                anIntermediateModule.doShowTicks = false;
//                anIntermediateResult.x = anIntermediatePosition.x;
//                anIntermediateResult.y = anIntermediatePosition.y;
//            }
//        }
//
//        function prepForShowIntermediates_reverse() : Void
//        {
//            // Hide intermediate results
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                anIntermediateResult.visible = false;
//            }
//        }  // Draws to the tickSprite in preparation for dropping the ticks  ;
//
//
//
//        var drawToTickSprites : Void->Void = function() : Void
//        {
//            // Show tick sprites
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Update tick sprite of the first
//                aTickSprite = tickSpritesOfFirst[intermediateIndex];
//                bottomFracModule.drawTicksToSprite(aTickSprite);
//                aTickSprite.visible = true;
//
//                // Update tick sprite of the second
//                aTickSprite = tickSpritesOfSecond[intermediateIndex];
//                topFracModule.drawTicksToSprite(aTickSprite);
//                aTickSprite.visible = true;
//            }
//        }
//
//        function drawToTickSprites_reverse() : Void
//        {
//            // Hide tick sprites
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Hide tick sprite of the first
//                aTickSprite = tickSpritesOfFirst[intermediateIndex];
//                aTickSprite.visible = false;
//
//                // Hide tick sprite of the second
//                aTickSprite = tickSpritesOfSecond[intermediateIndex];
//                aTickSprite.visible = false;
//            }
//        }  // Updates the first fraction's value to be the new changed value (with updated denominator)  ;
//
//
//
//        var finishShowDenom : Void->Void = function() : Void
//        {
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Show ticks on intermediate result
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).doShowTicks = true;
//
//                // Hide tick sprite of the first
//                aTickSprite = tickSpritesOfFirst[intermediateIndex];
//                aTickSprite.visible = false;
//
//                // Hide tick sprite of the second
//                aTickSprite = tickSpritesOfSecond[intermediateIndex];
//                aTickSprite.visible = false;
//            }
//        }
//
//        var finishShowDenom_reverse : Void->Void = function() : Void
//        {
//            // Show tick sprites
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Hide ticks on intermediate result
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).doShowTicks = false;
//
//                // Show tick sprite of the first
//                aTickSprite = tickSpritesOfFirst[intermediateIndex];
//                aTickSprite.visible = true;
//
//                // Show tick sprite of the second
//                aTickSprite = tickSpritesOfSecond[intermediateIndex];
//                aTickSprite.visible = true;
//            }
//        }
//
//        var prepForDrop : Void->Void = function() : Void
//        {
//            // Peel segments - need to handle all sorts of combinations
//            for (numSecondUnit in 0...topFracModule.numBaseUnits)
//            {
//                var aSetOfFirstDropSegments : Array<Sprite> = new Array<Sprite>();
//                var aSetOfFirstDropBackbones : Array<Sprite> = new Array<Sprite>();
//                for (numFirstUnit in 0...bottomFracModule.numBaseUnits)
//                {
//                    // number of segments to skip, then the segment we want
//                    aSetOfFirstDropSegments.push(dropSegmentsOfFirst[(numFirstUnit * topFracModule.numBaseUnits) + numSecondUnit]);
//                    aSetOfFirstDropBackbones.push(dropBackbonesOfFirst[(numFirstUnit * topFracModule.numBaseUnits) + numSecondUnit]);
//                }
//                bottomFracModule.peelSquaresToSprites(aSetOfFirstDropSegments, aSetOfFirstDropBackbones);
//            }
//            for (numFirstUnit in 0...bottomFracModule.numBaseUnits)
//            {
//                var aSetOfSecondDropSegments : Array<Sprite> = new Array<Sprite>();
//                var aSetOfSecondDropBackbones : Array<Sprite> = new Array<Sprite>();
//                for (numSecondUnit in 0...topFracModule.numBaseUnits)
//                {
//                    // number of segments to skip, then the segment we want
//                    aSetOfSecondDropSegments.push(dropSegmentsOfSecond[(numFirstUnit * topFracModule.numBaseUnits) + numSecondUnit]);
//                    aSetOfSecondDropBackbones.push(dropBackbonesOfSecond[(numFirstUnit * topFracModule.numBaseUnits) + numSecondUnit]);
//                }
//                topFracModule.peelSquaresToSprites(aSetOfSecondDropSegments, aSetOfSecondDropBackbones);
//            }
//
//            // Show drop segments
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Update drop backbones of the first
//                aDropBackbone = dropBackbonesOfFirst[intermediateIndex];
//                aDropBackbone.visible = true;
//                aDropBackbone.alpha = .7;
//
//                // Update drop segment of the first
//                aDropSegment = dropSegmentsOfFirst[intermediateIndex];
//                aDropSegment.visible = true;
//                aDropSegment.alpha = .7;
//
//                // Update drop backbones of the second
//                aDropBackbone = dropBackbonesOfSecond[intermediateIndex];
//                aDropBackbone.visible = true;
//                aDropBackbone.alpha = .7;
//
//                // Update drop segment of the second
//                aDropSegment = dropSegmentsOfSecond[intermediateIndex];
//                aDropSegment.visible = true;
//                aDropSegment.alpha = .7;
//
//                // Update drop results
//                aDropResult = dropResults[intermediateIndex];
//                var dropResultList : Array<Sprite> = new Array<Sprite>();
//                dropResultList.push(aDropResult);
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).peelSquaresToSprites(dropResultList, dropResultList);
//                aDropResult.visible = true;
//                aDropResult.alpha = .7;
//            }
//        }
//
//        var prepForDrop_reverse : Void->Void = function() : Void
//        {
//            // Hide drop segments
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Hide drop backbones of the first
//                aDropBackbone = dropBackbonesOfFirst[intermediateIndex];
//                aDropBackbone.visible = false;
//
//                // Hide drop segment of the first
//                aDropSegment = dropSegmentsOfFirst[intermediateIndex];
//                aDropSegment.visible = false;
//
//                // Hide drop backbones of the second
//                aDropBackbone = dropBackbonesOfSecond[intermediateIndex];
//                aDropBackbone.visible = false;
//
//                // Hide drop segment of the second
//                aDropSegment = dropSegmentsOfSecond[intermediateIndex];
//                aDropSegment.visible = false;
//
//                // Hide drop results
//                aDropResult = dropResults[intermediateIndex];
//                aDropResult.visible = false;
//            }
//        }
//
//        var finishDrop : Void->Void = function() : Void
//        {
//            // Hide drop segments, show intermediate result segments
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Show segments on intermediate result
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).doShowSegment = true;
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).doShowTicks = true;
//                anIntermediateResult.redraw(true);
//
//                // Hide drop backbones of the first
//                aDropBackbone = dropBackbonesOfFirst[intermediateIndex];
//                aDropBackbone.visible = false;
//
//                // Hide drop segment of the first
//                aDropSegment = dropSegmentsOfFirst[intermediateIndex];
//                aDropSegment.visible = false;
//
//                // Hide drop backbones of the second
//                aDropBackbone = dropBackbonesOfSecond[intermediateIndex];
//                aDropBackbone.visible = false;
//
//                // Hide drop segment of the second
//                aDropSegment = dropSegmentsOfSecond[intermediateIndex];
//                aDropSegment.visible = false;
//
//                // Hide drop results
//                aDropResult = dropResults[intermediateIndex];
//                aDropResult.visible = false;
//            }
//        }
//
//        var finishDrop_reverse : Void->Void = function() : Void
//        {
//            // Show drop segments, hide intermediate result segments
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                // Hide segments on intermediate result
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).doShowSegment = false;
//                (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null).doShowTicks = false;
//                anIntermediateResult.redraw(true);
//
//                // Hide drop backbones of the first
//                aDropBackbone = dropBackbonesOfFirst[intermediateIndex];
//                aDropBackbone.visible = true;
//
//                // Show drop segment of the first
//                aDropSegment = dropSegmentsOfFirst[intermediateIndex];
//                aDropSegment.visible = true;
//
//                // Hide drop backbones of the second
//                aDropBackbone = dropBackbonesOfSecond[intermediateIndex];
//                aDropBackbone.visible = true;
//
//                // Show drop segment of the second
//                aDropSegment = dropSegmentsOfSecond[intermediateIndex];
//                aDropSegment.visible = true;
//
//                // Show drop results
//                aDropResult = dropResults[intermediateIndex];
//                aDropResult.visible = true;
//            }
//        }
//
//        var prepForMoveBlocks : Void->Void = function() : Void
//        {
//            // Prep result to tween in, as the background
//            result.visible = true;
//            result.alpha = 0;
//            result.x = resultPosition.x;
//            result.y = resultPosition.y;
//            resultModule.doShowSegment = false;
//            resultModule.valueNumDisplayAlpha = 0;
//            result.redraw(true);
//
//            // Hide values of intermediates that are having their blocks moved
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                if (intermediateIndex >= mergeStartIndex)
//                {
//                    anIntermediateResult = intermediateResults[intermediateIndex];
//                    anIntermediateModule = (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null);
//                    anIntermediateModule.doShowSegment = false;
//                }
//            }
//
//            // Show merge blocks
//            for (aMergeBlock in mergeBlocks)
//            {
//                aMergeBlock.visible = true;
//            }
//        }
//
//        var prepForMoveBlocks_reverse : Void->Void = function() : Void
//        {
//            result.visible = false;
//
//            // Show values of intermediates that are having their blocks moved
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                if (intermediateIndex >= mergeStartIndex)
//                {
//                    anIntermediateResult = intermediateResults[intermediateIndex];
//                    anIntermediateModule = (try cast(anIntermediateResult.module, GridFractionModule) catch(e:Dynamic) null);
//                    anIntermediateModule.doShowSegment = true;
//                }
//            }
//
//            // Hide merge blocks
//            for (aMergeBlock in mergeBlocks)
//            {
//                aMergeBlock.visible = false;
//            }
//        }
//
//        var finishMoveBlocks : Void->Void = function() : Void
//        {
//            // Turn on the result segment
//            resultModule.doShowSegment = true;
//            result.alpha = 1;
//            result.redraw(true);
//
//            // Hide intermediates
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                anIntermediateResult.visible = false;
//            }
//
//            // Hide merge blocks
//            for (aMergeBlock in mergeBlocks)
//            {
//                aMergeBlock.visible = false;
//            }
//        }
//
//        function finishMoveBlocks_reverse() : Void
//        {
//            // Turn on the result segment
//            resultModule.doShowSegment = false;
//            result.redraw(true);
//
//            // Show intermediates
//            for (intermediateIndex in 0...numIntermediates)
//            {
//                anIntermediateResult = intermediateResults[intermediateIndex];
//                anIntermediateResult.visible = true;
//            }
//
//            // Show merge blocks
//            for (aMergeBlock in mergeBlocks)
//            {
//                aMergeBlock.visible = true;
//            }
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        var finalizeMerge : Void->Void = function() : Void
//        {
//            // Only need to do anything if there was no moving of blocks
//            if (!doMoveBlocks)
//            {
//                // Show result
//                result.visible = true;
//                result.alpha = 1;
//                result.x = resultPosition.x;
//                result.y = resultPosition.y;
//                resultModule.doShowSegment = true;
//                resultModule.valueNumDisplayAlpha = 0;
//                result.redraw(true);
//
//                // Hide intermediates
//                for (anIntermediateResult in intermediateResults)
//                {
//                    anIntermediateResult.visible = false;
//                }
//            }
//
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
//            // Only need to do anything if there was no moving of blocks
//            if (!doMoveBlocks)
//            {
//                // Hide result
//                result.visible = false;
//
//                // Show intermediates
//                for (anIntermediateResult in intermediateResults)
//                {
//                    anIntermediateResult.visible = true;
//                }
//            }
//
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
//        }  // Prepares for simplification of result fraction  ;
//
//
//
//        var prepForSimplification : Void->Void = function() : Void
//        {
//            // Show simplified result
//            simplifiedResultModule.valueIsAbove = true;
//            simplifiedResult.visible = true;
//            simplifiedResult.alpha = 0;
//            simplifiedResult.x = result.x;
//            simplifiedResult.y = result.y;
//            simplifiedResult.redraw(true);
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
//        }  // Moves the location of the fraction value of the result module (the view on the bottom) to display underneath the strip  ;
//
//
//
//        var moveValueToBottom : Void->Void = function() : Void
//        {
//            var aModule : GridFractionModule = (doSimplify) ? simplifiedResultModule : resultModule;
//            aModule.valueIsAbove = false;
//        }
//
//        function moveValueToBottom_reverse() : Void
//        {
//            var aModule : GridFractionModule = (doSimplify) ? simplifiedResultModule : resultModule;
//            aModule.valueIsAbove = true;
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

