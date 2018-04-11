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
import cgs.fractionVisualization.util.EquationData;
import cgs.fractionVisualization.constants.GridConstants;
import cgs.fractionVisualization.util.NumberRenderer;
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
class GridAddAnimator implements IFractionAnimator
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
        return CgsFVConstants.GRID_STANDARD_ADD;
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


        //TODO: fix animations
//        var textColor : Int = Reflect.hasField(details, CgsFVConstants.TEXT_COLOR) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_COLOR)) : GenConstants.DEFAULT_TEXT_COLOR;
//        var textGlowColor : Int = Reflect.hasField(details, CgsFVConstants.TEXT_GLOW_COLOR) ? Reflect.field(details, Std.string(CgsFVConstants.TEXT_GLOW_COLOR)) : GenConstants.DEFAULT_TEXT_GLOW_COLOR;
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
//
//        // Compute result fraction
//        var origFirstFraction : CgsFraction = first.fraction.clone();
//        var origSecondFraction : CgsFraction = second.fraction.clone();
//        var doChangeDenom : Bool = first.fraction.denominator != second.fraction.denominator;
//        var commonDenominator : Float = (doChangeDenom) ? (first.fraction.denominator * second.fraction.denominator) : first.fraction.denominator;
//        var firstMultiplier : Int = (doChangeDenom) ? second.fraction.denominator : 1;
//        var secondMultiplier : Int = (doChangeDenom) ? first.fraction.denominator : 1;
//        var firstMultiplierFraction : CgsFraction = new CgsFraction(firstMultiplier, firstMultiplier);
//        var secondMultiplierFraction : CgsFraction = new CgsFraction(secondMultiplier, secondMultiplier);
//        var newFirstNumerator : Int = as3hx.Compat.parseInt(first.fraction.numerator * firstMultiplier);
//        var newSecondNumerator : Int = as3hx.Compat.parseInt(second.fraction.numerator * secondMultiplier);
//        var resultFraction : CgsFraction = new CgsFraction(newFirstNumerator + newSecondNumerator, commonDenominator);
//        var finalFirstFraction : CgsFraction = new CgsFraction(newFirstNumerator, commonDenominator);
//        var finalSecondFraction : CgsFraction = new CgsFraction(newSecondNumerator, commonDenominator);
//        var resultRowCount : Int = (doChangeDenom) ? origSecondFraction.denominator : 1;
//        var resultColumnCount : Int = origFirstFraction.denominator;
//
//        // Create result fraction view - This makes computing the destinations of the blocks significantly easier
//        var result : CgsFractionView = first.clone();
//        result.fraction.init(resultFraction.numerator, resultFraction.denominator);
//        result.foregroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) : first.foregroundColor;
//        result.backgroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) : first.backgroundColor;
//        result.borderColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) : first.borderColor;
//        result.tickColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) : first.tickColor;
//        var resultModule : GridFractionModule = (try cast(result.module, GridFractionModule) catch(e:Dynamic) null);
//        resultModule.valueIsAbove = true;
//        resultModule.setNumRowsAndColumns(resultRowCount, resultColumnCount);
//        resultModule.resetLogicGrid();
//        result.visible = false;
//        result.redraw(true);
//        m_animHelper.trackFractionView(result);
//        m_animController.addChild(result);
//        m_animController.addChild(first);
//        m_animController.addChild(second);
//
//        // Make into elongated strip
//        firstModule.isElongatedStrip = true;
//        secondModule.isElongatedStrip = true;
//
//        // Position data
//        var oldFirstPosition : Point = new Point(first.x, first.y);
//        var oldSecondPosition : Point = new Point(second.x, second.y);
//        var offsetX : Float = Math.max(Math.max(firstModule.totalWidth / 2, secondModule.totalWidth / 2), resultModule.totalWidth / 2);
//        var offsetY : Float = resultModule.unitHeight / 2 + GridConstants.ANIMATION_MARGIN_VERTICAL_SMALL * 2;
//        var newFirstPosition : Point = new Point(firstModule.totalWidth / 2 - offsetX, -offsetY - firstModule.unitHeight / 2);
//        var newSecondPosition : Point = new Point(secondModule.totalWidth / 2 - offsetX, offsetY + secondModule.unitHeight / 2);
//        result.x = resultModule.totalWidth / 2 - offsetX;
//
//        // Rotate
//        var secondFractionRotationSegments : Array<Sprite> = new Array<Sprite>();
//        if (doChangeDenom)
//        {
//            for (secondUnitIndex in 0...secondModule.numTotalUnits)
//            {
//                var aSegment : Sprite = new Sprite();
//                m_animHelper.trackDisplay(aSegment);
//                m_animController.addChild(aSegment);
//                secondFractionRotationSegments.push(aSegment);
//            }
//        }
//
//        // Change Denominator Ticks
//        var segmentSpriteOfFirst : Sprite;
//        var segmentSpriteOfSecond : Sprite;
//        var combinedTickSprite : Sprite;
//        var tickSpritesForFirst : Array<Sprite>;
//        var tickSpritesForSecond : Array<Sprite>;
//        var tickMidpointLocation : Point = new Point(newFirstPosition.x - firstModule.totalWidth / 2 + firstModule.unitWidth / 2, newSecondPosition.y + ((newFirstPosition.y - newSecondPosition.y) / 2));
//        var aTickSprite : Sprite;
//        if (doChangeDenom)
//        {
//            // Create segment sprite to come off of the first
//            segmentSpriteOfFirst = new Sprite();
//            m_animHelper.trackDisplay(segmentSpriteOfFirst);
//            m_animController.addChild(segmentSpriteOfFirst);
//            segmentSpriteOfFirst.visible = false;
//
//            // Create segment sprite to come off of the second
//            segmentSpriteOfSecond = new Sprite();
//            m_animHelper.trackDisplay(segmentSpriteOfSecond);
//            m_animController.addChild(segmentSpriteOfSecond);
//            segmentSpriteOfSecond.visible = false;
//
//            // Create segment sprite to come off of the first
//            combinedTickSprite = new Sprite();
//            resultModule.drawTicksToSprite(combinedTickSprite);
//            m_animHelper.trackDisplay(combinedTickSprite);
//            m_animController.addChild(combinedTickSprite);
//            combinedTickSprite.visible = false;
//
//            // Make a tick sprite for each unit of the first
//            tickSpritesForFirst = new Array<Sprite>();
//            for (firstDenomUnitIndex in 0...firstModule.numBaseUnits)
//            {
//                aTickSprite = new Sprite();
//                resultModule.drawTicksToSprite(aTickSprite);
//                m_animHelper.trackDisplay(aTickSprite);
//                m_animController.addChild(aTickSprite);
//                aTickSprite.visible = false;
//                tickSpritesForFirst.push(aTickSprite);
//            }
//
//            // Make a tick sprite for each unit of the second
//            tickSpritesForSecond = new Array<Sprite>();
//            for (secondDenomUnitIndex in 0...secondModule.numBaseUnits)
//            {
//                aTickSprite = new Sprite();
//                resultModule.drawTicksToSprite(aTickSprite);
//                m_animHelper.trackDisplay(aTickSprite);
//                m_animController.addChild(aTickSprite);
//                aTickSprite.visible = false;
//                tickSpritesForSecond.push(aTickSprite);
//            }
//        }
//
//        // Get equation data for changing the second denomintor
//        var secondDenom_equationPosition : Point = new Point(newSecondPosition.x + secondModule.valueNRPosition.x, newSecondPosition.y + secondModule.valueNRPosition.y);
//        var secondDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, secondDenom_equationPosition, second.fraction, " × ", secondMultiplierFraction, finalSecondFraction, textColor, textGlowColor);
//        secondDenom_eqData.equationCenter = new Point(secondDenom_eqData.equationCenter.x + secondDenom_eqData.firstValueNR.width / 2 + secondDenom_eqData.opSymbolText.width + secondDenom_eqData.secondValueNR.width / 2, secondDenom_eqData.equationCenter.y);
//
//        // Get equation data for changing the first denomintor
//        var firstValueNRPosition : Point = firstModule.getValueNRPosition(true, first.fraction.denominator == 1);
//        var firstDenom_equationPosition : Point = new Point(newFirstPosition.x + firstValueNRPosition.x, newFirstPosition.y + firstValueNRPosition.y);
//        var firstDenom_eqData : EquationData = m_animHelper.createEquationData(m_animController, firstDenom_equationPosition, first.fraction, " × ", firstMultiplierFraction, finalFirstFraction, textColor, textGlowColor);
//        firstDenom_eqData.equationCenter = new Point(firstDenom_eqData.equationCenter.x + firstDenom_eqData.firstValueNR.width / 2 + firstDenom_eqData.opSymbolText.width + firstDenom_eqData.secondValueNR.width / 2, firstDenom_eqData.equationCenter.y);
//
//        // Drop Data
//        var dropSegmentDestinations : Array<Point> = resultModule.getBlockCenterPoints();
//        var aDropDestination:Point;
//        for (aDropDestination in dropSegmentDestinations)
//        {
//            aDropDestination.x += result.x;
//            aDropDestination.y += result.y;
//        }
//
//        // Setup Drop Segments of first
//        var dropSegmentsOfFirst : Array<Sprite> = new Array<Sprite>();
//        var dropSegmentDestinationsOfFirst : Array<Point> = new Array<Point>();
//        var aDropSegment : Sprite;
//
//        for (dropSegmentIndex in 0...finalFirstFraction.numerator)
//        {
//            // Create and add the segments to the display list
//            aDropSegment  = new Sprite();
//            m_animHelper.trackDisplay(aDropSegment);
//            m_animController.addChild(aDropSegment);
//            aDropSegment.visible = false;
//            dropSegmentsOfFirst.push(aDropSegment);
//
//            // Get its drop destination
//            aDropDestination = dropSegmentDestinations.shift();
//            dropSegmentDestinationsOfFirst.push(aDropDestination);
//        }
//        // Setup Drop Segments of second
//        var dropSegmentsOfSecond : Array<Sprite> = new Array<Sprite>();
//        var dropSegmentDestinationsOfSecond : Array<Point> = new Array<Point>();
//        for (dropSegmentIndex in 0...finalSecondFraction.numerator)
//        {
//            // Create and add the segments to the display list
//            aDropSegment = new Sprite();
//            m_animHelper.trackDisplay(aDropSegment);
//            m_animController.addChild(aDropSegment);
//            aDropSegment.visible = false;
//            dropSegmentsOfSecond.push(aDropSegment);
//
//            // Get its drop destination
//            aDropDestination = dropSegmentDestinations.shift();
//            dropSegmentDestinationsOfSecond.push(aDropDestination);
//        }
//
//        // Get equation data for changing the second denomintor
//        var equationCenter : Point = new Point(result.x + resultModule.valueNRPosition.x, result.y + resultModule.valueNRPosition.y);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, equationCenter, finalFirstFraction, " + ", finalSecondFraction, resultFraction, textColor, textGlowColor);
//        eqData.equationCenter = new Point(eqData.equationCenter.x - eqData.resultValueNR.width / 2 - eqData.equalsSymbolText.width - eqData.secondValueNR.width / 2, eqData.equationCenter.y);
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
//
//        // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the strip
//        function moveValueToTop() : Void
//        {
//            firstModule.valueIsAbove = true;
//        };
//
//        function moveValueToTop_reverse() : Void
//        {
//            firstModule.valueIsAbove = false;
//        }  // Draws to the secondSegments in preparation for rotation  ;
//
//
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_POSITION);
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
//        //m_animHelper.appendStep(positionStep);
//
//        // Change Denominator
//        if (doChangeDenom)
//        {
//            var changeDenom_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DELAY_AFTER_CHANGE_DENOM);
//            var changeDenom_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_CHANGE_DENOM);
//            var changeDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_DENOMINATORS, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//
//            // Timing
//            var rotateStartTime : Float = .1;
//            var finishRotateTime : Float = rotateStartTime + changeDenom_unitDuration;
//
//            var prepForChangeDenomTime : Float = finishRotateTime + .1;
//            var moveToMidpointStartTime : Float = prepForChangeDenomTime + .1;
//            var fadeToTicksStartTime : Float = moveToMidpointStartTime + changeDenom_unitDuration;
//            var switchToTickSpritesTime : Float = fadeToTicksStartTime + changeDenom_unitDuration;
//
//            var moveTicksToFirstFractionStartTime : Float = switchToTickSpritesTime + changeDenom_unitDuration / 2;
//            var moveTicksOfFirstDuration : Float = (changeDenom_unitDuration / 2) * ((tickSpritesForFirst.length * 2) - 1);
//            var showFirstEquationStartTime_partOne : Float = moveTicksToFirstFractionStartTime + moveTicksOfFirstDuration;
//            var showFirstEquationStartTime_partTwo : Float = showFirstEquationStartTime_partOne + changeDenom_unitDuration / 2;
//
//            var moveTicksToSecondFractionStartTime : Float = showFirstEquationStartTime_partTwo + changeDenom_unitDuration / 2;
//            var moveTicksOfSecondDuration : Float = (changeDenom_unitDuration / 2) * (tickSpritesForSecond.length * 2);
//            var showSecondEquationStartTime_partOne : Float = moveTicksToSecondFractionStartTime + moveTicksOfSecondDuration;
//            var showSecondEquationStartTime_partTwo : Float = showSecondEquationStartTime_partOne + changeDenom_unitDuration / 2;
//
//            var consolidateFirstEquationStartTime : Float = showSecondEquationStartTime_partTwo + changeDenom_unitDuration / 2;
//            var finalizeFirstDenomTime : Float = consolidateFirstEquationStartTime + changeDenom_unitDuration / 2;
//            var consolidateSecondEquationStartTime : Float = finalizeFirstDenomTime + changeDenom_unitDuration / 2;
//            var finalizeSecondDenomTime : Float = consolidateSecondEquationStartTime + changeDenom_unitDuration / 2;
//
//            // Do rotate
//            changeDenomStep.addCallback(0, prepForRotate, null, prepForRotate_reverse);
//            for (aSegment in secondFractionRotationSegments)
//            {
//                changeDenomStep.addTween(rotateStartTime, new GTween(aSegment, changeDenom_unitDuration, {
//                            rotation : 90
//                        }, {
//                            ease : Sine.easeInOut
//                        }));
//            }
//            changeDenomStep.addCallback(finishRotateTime, finalizeRotate, null, finalizeRotate_reverse);
//
//            // Prep for change denom
//            changeDenomStep.addCallback(prepForChangeDenomTime, prepForChangeDenom, null, prepForChangeDenom_reverse);
//
//            // Move to midpoint
//            changeDenomStep.addTween(moveToMidpointStartTime, new GTween(segmentSpriteOfFirst, changeDenom_unitDuration, {
//                        x : tickMidpointLocation.x,
//                        y : tickMidpointLocation.y
//                    }));
//            changeDenomStep.addTween(moveToMidpointStartTime, new GTween(segmentSpriteOfSecond, changeDenom_unitDuration, {
//                        x : tickMidpointLocation.x,
//                        y : tickMidpointLocation.y
//                    }));
//
//            // Fade to ticks
//            changeDenomStep.addTween(fadeToTicksStartTime, new GTween(segmentSpriteOfFirst, changeDenom_unitDuration, {
//                        alpha : 0
//                    }));
//            changeDenomStep.addTween(fadeToTicksStartTime, new GTween(segmentSpriteOfSecond, changeDenom_unitDuration, {
//                        alpha : 0
//                    }));
//            changeDenomStep.addTween(fadeToTicksStartTime, new GTween(combinedTickSprite, changeDenom_unitDuration, {
//                        alpha : 1
//                    }));
//
//            // Switch to tick sprites
//            changeDenomStep.addCallback(switchToTickSpritesTime, switchToTickSprites, null, switchToTickSprites_reverse);
//
//            // Move tick sprites onto first
//            var currentTickTime : Float = moveTicksToFirstFractionStartTime;
//            var isFirstTickSprite : Bool = true;
//            for (aTickSprite in tickSpritesForFirst)
//            {
//                // Alpha in tick sprite
//                if (!isFirstTickSprite)
//                {
//                    changeDenomStep.addTween(currentTickTime, new GTween(aTickSprite, changeDenom_unitDuration / 2, {
//                                alpha : 1
//                            }));
//                    currentTickTime += changeDenom_unitDuration / 2;
//                }
//                else
//                {
//                    isFirstTickSprite = false;
//                }
//
//                // Move into position
//                changeDenomStep.addTween(currentTickTime, new GTween(aTickSprite, changeDenom_unitDuration / 2, {
//                            y : newFirstPosition.y
//                        }));
//                currentTickTime += changeDenom_unitDuration / 2;
//            }
//
//            // Show First Denominator's equation
//            changeDenomStep.addTween(showFirstEquationStartTime_partOne, new GTween(firstDenom_eqData.opSymbolText, changeDenom_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showFirstEquationStartTime_partOne, new GTween(firstDenom_eqData.secondValueNR, changeDenom_unitDuration / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showFirstEquationStartTime_partOne + changeDenom_unitDuration / 4, new GTween(firstDenom_eqData.secondValueNR, changeDenom_unitDuration / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showFirstEquationStartTime_partTwo, new GTween(firstDenom_eqData.equalsSymbolText, changeDenom_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showFirstEquationStartTime_partTwo, new GTween(firstDenom_eqData.resultValueNR, changeDenom_unitDuration / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showFirstEquationStartTime_partTwo + changeDenom_unitDuration / 4, new GTween(firstDenom_eqData.resultValueNR, changeDenom_unitDuration / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Consolidate first equation
//            changeDenomStep.addTween(consolidateFirstEquationStartTime, new GTween(firstDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateFirstEquationStartTime, new GTween(firstDenom_eqData.opSymbolText, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateFirstEquationStartTime, new GTween(firstDenom_eqData.secondValueNR, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateFirstEquationStartTime, new GTween(firstDenom_eqData.equalsSymbolText, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateFirstEquationStartTime, new GTween(firstDenom_eqData.resultValueNR, changeDenom_unitDuration / 2, {
//                        x : firstDenom_eqData.firstValueNR_equationPosition.x,
//                        y : firstDenom_eqData.firstValueNR_equationPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Move tick sprites onto second
//            currentTickTime = moveTicksToSecondFractionStartTime;
//            for (aTickSprite in tickSpritesForSecond)
//            {
//                // Alpha in tick sprite
//                changeDenomStep.addTween(currentTickTime, new GTween(aTickSprite, changeDenom_unitDuration / 2, {
//                            alpha : 1
//                        }));
//                currentTickTime += changeDenom_unitDuration / 2;
//
//                // Move into position
//                changeDenomStep.addTween(currentTickTime, new GTween(aTickSprite, changeDenom_unitDuration / 2, {
//                            y : newSecondPosition.y
//                        }));
//                currentTickTime += changeDenom_unitDuration / 2;
//            }
//
//            // Show Second Denominator's equation
//            changeDenomStep.addTween(showSecondEquationStartTime_partOne, new GTween(secondDenom_eqData.opSymbolText, changeDenom_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showSecondEquationStartTime_partOne, new GTween(secondDenom_eqData.secondValueNR, changeDenom_unitDuration / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showSecondEquationStartTime_partOne + changeDenom_unitDuration / 4, new GTween(secondDenom_eqData.secondValueNR, changeDenom_unitDuration / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showSecondEquationStartTime_partTwo, new GTween(secondDenom_eqData.equalsSymbolText, changeDenom_unitDuration / 4, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showSecondEquationStartTime_partTwo, new GTween(secondDenom_eqData.resultValueNR, changeDenom_unitDuration / 4, {
//                        alpha : 1,
//                        numeratorScale : 1.5,
//                        denominatorScale : 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(showSecondEquationStartTime_partTwo + changeDenom_unitDuration / 4, new GTween(secondDenom_eqData.resultValueNR, changeDenom_unitDuration / 4, {
//                        numeratorScale : 1,
//                        denominatorScale : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Consolidate second equation
//            changeDenomStep.addTween(consolidateSecondEquationStartTime, new GTween(secondDenom_eqData.firstValueNR, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateSecondEquationStartTime, new GTween(secondDenom_eqData.opSymbolText, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateSecondEquationStartTime, new GTween(secondDenom_eqData.secondValueNR, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateSecondEquationStartTime, new GTween(secondDenom_eqData.equalsSymbolText, changeDenom_unitDuration / 2, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            changeDenomStep.addTween(consolidateSecondEquationStartTime, new GTween(secondDenom_eqData.resultValueNR, changeDenom_unitDuration / 2, {
//                        x : secondDenom_eqData.firstValueNR_equationPosition.x,
//                        y : secondDenom_eqData.firstValueNR_equationPosition.y
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//
//            // Finalize
//            changeDenomStep.addCallback(finalizeFirstDenomTime, finalizeChangeDenomOfFirst, null, finalizeChangeDenomOfFirst_reverse);
//            changeDenomStep.addCallback(finalizeSecondDenomTime, finalizeChangeDenomOfSecond, null, finalizeChangeDenomOfSecond_reverse);
//            m_animHelper.appendStep(changeDenomStep);
//        }
//
//        // Drop
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DELAY_AFTER_DROP);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_DROP);
//        var drop_durationPerBlock : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_DROP_PER_BLOCK);
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//        dropStep.addCallback(0, doPeel, null, doPeel_reverse);
//        var startDropMoveTime : Float = .1;
//        var nextBlockDelayModifier : Float = 1 / 2;  // Each block starts moving after the last block has gotten part way
//        var totalDropDuration : Float = (drop_durationPerBlock * nextBlockDelayModifier) * (dropSegmentsOfSecond.length + dropSegmentsOfFirst.length + 1);
//        var aDropMoveDuration : Float = (totalDropDuration / (dropSegmentsOfSecond.length + dropSegmentsOfFirst.length + 1)) / nextBlockDelayModifier;
//        var dropFirstValue_startTime : Float = startDropMoveTime + totalDropDuration;
//        var dropSecondValue_startTime : Float = dropFirstValue_startTime + drop_unitDuration;
//        var showOpStart : Float = dropSecondValue_startTime + drop_unitDuration;
//        var thisDropMoveTime : Float = startDropMoveTime;
//        for (dropSegmentIndex in 0...dropSegmentsOfFirst.length)
//        {
//            // Add the blocks to the display list
//            aDropSegment = dropSegmentsOfFirst[dropSegmentIndex];
//            aDropDestination = dropSegmentDestinationsOfFirst[dropSegmentIndex];
//            dropStep.addTween(thisDropMoveTime, new GTween(aDropSegment, aDropMoveDuration, {
//                        x : aDropDestination.x,
//                        y : aDropDestination.y
//                    }));
//            thisDropMoveTime += aDropMoveDuration * nextBlockDelayModifier;
//        }
//        for (dropSegmentIndex in 0...dropSegmentsOfSecond.length)
//        {
//            // Add the blocks to the display list
//            aDropSegment = dropSegmentsOfSecond[dropSegmentIndex];
//            aDropDestination = dropSegmentDestinationsOfSecond[dropSegmentIndex];
//            dropStep.addTween(thisDropMoveTime, new GTween(aDropSegment, aDropMoveDuration, {
//                        x : aDropDestination.x,
//                        y : aDropDestination.y
//                    }));
//            thisDropMoveTime += aDropMoveDuration * nextBlockDelayModifier;
//        }
//        dropStep.addTween(dropFirstValue_startTime, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                    x : eqData.firstValueNR_equationPosition.x,
//                    y : eqData.firstValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropFirstValue_startTime, new GTween(first, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropSecondValue_startTime, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(dropSecondValue_startTime, new GTween(second, drop_unitDuration / 2, {
//                    alpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(showOpStart, new GTween(eqData.opSymbolText, drop_unitDuration / 2, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        m_animHelper.appendStep(dropStep);
//
//        // Tween Merge
//        var merge_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DELAY_AFTER_MERGE);
//        var merge_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_MERGE);
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, merge_unitDelay, CgsFVConstants.STEP_TYPE_MERGE);
//        var fadeInResultBackboneStart : Float = .1;
//        var fadeInResultValueStart : Float = fadeInResultBackboneStart + merge_unitDuration;
//        var showResultStart : Float = fadeInResultValueStart + merge_unitDuration;
//        var consolidateEquationStart : Float = showResultStart + merge_unitDuration + merge_unitDelay;  // Includes a little delay after the result text is visible
//        var mergeTime : Float = consolidateEquationStart + merge_unitDuration;
//        mergeStep.addTween(fadeInResultBackboneStart, new GTween(result, merge_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        for (aDropSegment in dropSegmentsOfFirst)
//        {
//            mergeStep.addTween(fadeInResultValueStart, new GTween(aDropSegment, merge_unitDuration, {
//                        alpha : 0
//                    }));
//        }
//        for (aDropSegment in dropSegmentsOfSecond)
//        {
//            mergeStep.addTween(fadeInResultValueStart, new GTween(aDropSegment, merge_unitDuration, {
//                        alpha : 0
//                    }));
//        }
//        mergeStep.addTweenSet(showResultStart, EquationData.animationEquationInline_phaseTwo(eqData, merge_unitDuration));
//        mergeStep.addTweenSet(consolidateEquationStart, EquationData.consolidateEquation(eqData, merge_unitDuration, eqData.resultValueNR_equationPosition));
//        mergeStep.addCallback(mergeTime, doMerge, null, doMerge_reverse);
//        m_animHelper.appendStep(mergeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplification_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DELAY_AFTER_SIMPLIFICATION);
//            var simplification_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_SIMPLIFICATION);
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
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(GridConstants.TIME_ADD_DURATION_UNPOSITION);
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
//        m_animHelper.animate(addComplete, positionStep, unpositionStep);
//
//
//        /**
//			 * State Change Functions
//			**/
//
//
//
//
//        var prepForRotate : Void->Void = function() : Void
//        {
//            // Peel off the segment and ticks from the second fraction so we can rotate them freely
//            secondModule.peelSquaresToSprites(secondFractionRotationSegments);
//            var segmentOffsetX : Float = secondModule.unitWidth / 2;
//            for (aSegment in secondFractionRotationSegments)
//            {
//                aSegment.visible = true;
//                aSegment.x = newSecondPosition.x - secondModule.totalWidth / 2 + segmentOffsetX;
//                aSegment.y = newSecondPosition.y;
//                segmentOffsetX += (secondModule.unitWidth + secondModule.gridSeparation);
//            }
//
//            // Hide segment and ticks on the second fraction
//            secondModule.doShowSegment = false;
//            secondModule.doShowBorder = false;
//            secondModule.doShowTicks = false;
//        }
//
//        function prepForRotate_reverse() : Void
//        {
//            // Hide the rotating segments
//            for (aSegment in secondFractionRotationSegments)
//            {
//                aSegment.visible = false;
//            }
//
//            // Redraw segment and ticks on the second fraction
//            secondModule.doShowSegment = true;
//            secondModule.doShowBorder = true;
//            secondModule.doShowTicks = true;
//            second.redraw(true);
//        }  // Hides the secondSegments from the rotation and modifies the second fraction to be at the rotated setting  ;
//
//
//
//        var finalizeRotate : Void->Void = function() : Void
//        {
//            // Hide the rotating segments
//            for (aSegment in secondFractionRotationSegments)
//            {
//                aSegment.visible = false;
//            }
//
//            // Hide segment and ticks on the second fraction
//            secondModule.splitColumnBeforeRow = false;
//            secondModule.maxRowsToFill = origFirstFraction.numerator;
//            secondModule.maxColumnsToFill = 1;
//            secondModule.resetLogicGrid();
//            secondModule.doShowSegment = true;
//            secondModule.doShowBorder = true;
//            secondModule.doShowTicks = true;
//            second.redraw(true);
//        }
//
//        function finalizeRotate_reverse() : Void
//        {
//            // Show the rotating segments
//            for (aSegment in secondFractionRotationSegments)
//            {
//                aSegment.visible = true;
//            }
//
//            // Redraw segment and ticks on the second fraction
//            secondModule.splitColumnBeforeRow = true;
//            secondModule.maxRowsToFill = -1;
//            secondModule.maxColumnsToFill = -1;
//            secondModule.resetLogicGrid();
//            secondModule.doShowSegment = false;
//            secondModule.doShowBorder = false;
//            secondModule.doShowTicks = false;
//        }  // Prepares moving ticks for the changing denominator animation  ;
//
//
//
//        var prepForChangeDenom : Void->Void = function() : Void
//        {
//            // Draw segment of first onto the sprite
//            var firstSegmentSprites : Array<Sprite> = new Array<Sprite>();
//            firstSegmentSprites.push(segmentSpriteOfFirst);
//            firstModule.peelSquaresToSprites(firstSegmentSprites, firstSegmentSprites);
//            segmentSpriteOfFirst.x = first.x - firstModule.totalWidth / 2 + firstModule.unitWidth / 2;
//            segmentSpriteOfFirst.y = first.y;
//            segmentSpriteOfFirst.alpha = .7;
//            segmentSpriteOfFirst.visible = true;
//
//            // Draw segment of second onto the sprite
//            var secondSegmentSprites : Array<Sprite> = new Array<Sprite>();
//            secondSegmentSprites.push(segmentSpriteOfSecond);
//            secondModule.peelSquaresToSprites(secondSegmentSprites, secondSegmentSprites);
//            segmentSpriteOfSecond.x = second.x - secondModule.totalWidth / 2 + secondModule.unitWidth / 2;
//            segmentSpriteOfSecond.y = second.y;
//            segmentSpriteOfSecond.alpha = .7;
//            segmentSpriteOfSecond.visible = true;
//
//            // Show combined tick sprite
//            combinedTickSprite.x = tickMidpointLocation.x;
//            combinedTickSprite.y = tickMidpointLocation.y;
//            combinedTickSprite.visible = true;
//            combinedTickSprite.alpha = 0;
//
//            // Adjust positions of tick sprites for first
//            for (firstDenomUnitIndex in 0...firstModule.numBaseUnits)
//            {
//                aTickSprite = tickSpritesForFirst[firstDenomUnitIndex];
//                aTickSprite.visible = true;
//                aTickSprite.alpha = 0;
//                aTickSprite.x = first.x - firstModule.totalWidth / 2 + ((firstModule.unitHeight + firstModule.gridSeparation) * firstDenomUnitIndex) + (firstModule.unitHeight / 2);
//                aTickSprite.y = tickMidpointLocation.y;
//            }
//
//            // Adjust positions of tick sprites for second
//            for (secondDenomUnitIndex in 0...secondModule.numBaseUnits)
//            {
//                aTickSprite = tickSpritesForSecond[secondDenomUnitIndex];
//                aTickSprite.visible = true;
//                aTickSprite.alpha = 0;
//                aTickSprite.x = second.x - secondModule.totalWidth / 2 + ((secondModule.unitHeight + secondModule.gridSeparation) * secondDenomUnitIndex) + (secondModule.unitHeight / 2);
//                aTickSprite.y = tickMidpointLocation.y;
//            }
//
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
//            // Hide tick sprites of first
//            segmentSpriteOfFirst.visible = false;
//            for (aTickSprite in tickSpritesForFirst)
//            {
//                aTickSprite.visible = false;
//            }
//
//            // Hide tick sprites of second
//            segmentSpriteOfSecond.visible = false;
//            for (aTickSprite in tickSpritesForSecond)
//            {
//                aTickSprite.visible = false;
//            }
//
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
//            // Adjust visibility of value on first fraction view
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//        }
//
//        var switchToTickSprites : Void->Void = function() : Void
//        {
//            // Hide combined tick sprite
//            combinedTickSprite.visible = false;
//
//            // Show first tick sprite for first
//            aTickSprite = tickSpritesForFirst[0];
//            aTickSprite.visible = true;
//            aTickSprite.alpha = 1;
//        }
//
//        function switchToTickSprites_reverse() : Void
//        {
//            // Show combined tick sprite
//            combinedTickSprite.visible = true;
//
//            // Hide first tick sprite for first
//            aTickSprite = tickSpritesForFirst[0];
//            aTickSprite.visible = false;
//        }  // Removes the ticks and updates the displays of the first fraction  ;
//
//
//
//        var finalizeChangeDenomOfFirst : Void->Void = function() : Void
//        {
//            // Update first fraction
//            first.fraction.init(finalFirstFraction.numerator, finalFirstFraction.denominator);
//            firstModule.valueNumDisplayAlpha = 1;
//            firstModule.isElongatedStrip = false;
//            firstModule.setNumRowsAndColumns(resultRowCount, resultColumnCount);
//            firstModule.resetLogicGrid();
//            first.redraw(true);
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_eqData.firstValueNR.visible = false;
//            firstDenom_eqData.opSymbolText.visible = false;
//            firstDenom_eqData.secondValueNR.visible = false;
//            firstDenom_eqData.equalsSymbolText.visible = false;
//            firstDenom_eqData.resultValueNR.visible = false;
//
//            // Hide tick sprites of second (for first)
//            segmentSpriteOfFirst.visible = false;
//            for (aTickSprite in tickSpritesForFirst)
//            {
//                aTickSprite.visible = false;
//            }
//        }
//
//        function finalizeChangeDenomOfFirst_reverse() : Void
//        {
//            // Update first fraction
//            first.fraction.init(origFirstFraction.numerator, origFirstFraction.denominator);
//            firstModule.valueNumDisplayAlpha = 0;
//            firstModule.isElongatedStrip = true;
//            firstModule.setNumRowsAndColumns();
//            firstModule.resetLogicGrid();
//            first.redraw(true);
//
//            // Adjust visibility and alpha for the first fraction equation parts
//            firstDenom_eqData.firstValueNR.visible = true;
//            firstDenom_eqData.opSymbolText.visible = true;
//            firstDenom_eqData.secondValueNR.visible = true;
//            firstDenom_eqData.equalsSymbolText.visible = true;
//            firstDenom_eqData.resultValueNR.visible = true;
//
//            // Show tick sprites of second (for first)
//            segmentSpriteOfFirst.visible = true;
//            for (aTickSprite in tickSpritesForFirst)
//            {
//                aTickSprite.visible = true;
//            }
//        }  // Removes the ticks and updates the displays of the second fraction  ;
//
//
//
//        var finalizeChangeDenomOfSecond : Void->Void = function() : Void
//        {
//            // Update second fraction
//            second.fraction.init(finalSecondFraction.numerator, finalSecondFraction.denominator);
//            secondModule.valueNumDisplayAlpha = 1;
//            secondModule.isElongatedStrip = false;
//            secondModule.fillColumnBeforeRow = false;
//            secondModule.splitColumnBeforeRow = true;
//            secondModule.maxRowsToFill = finalSecondFraction.numerator;
//            secondModule.maxColumnsToFill = -1;
//            secondModule.setNumRowsAndColumns(resultRowCount, resultColumnCount);
//            secondModule.resetLogicGrid();
//            second.redraw(true);
//
//            // Adjust visibility and alpha for the second fraction equation parts
//            secondDenom_eqData.firstValueNR.visible = false;
//            secondDenom_eqData.opSymbolText.visible = false;
//            secondDenom_eqData.secondValueNR.visible = false;
//            secondDenom_eqData.equalsSymbolText.visible = false;
//            secondDenom_eqData.resultValueNR.visible = false;
//
//            // Hide tick sprites of first (for second)
//            segmentSpriteOfSecond.visible = false;
//            for (aTickSprite in tickSpritesForSecond)
//            {
//                aTickSprite.visible = false;
//            }
//        }
//
//        var finalizeChangeDenomOfSecond_reverse : Void->Void = function() : Void
//        {
//            // Update second fraction
//            second.fraction.init(origSecondFraction.numerator, origSecondFraction.denominator);
//            secondModule.valueNumDisplayAlpha = 0;
//            secondModule.isElongatedStrip = true;
//            secondModule.fillColumnBeforeRow = true;
//            secondModule.splitColumnBeforeRow = false;
//            secondModule.maxRowsToFill = origFirstFraction.numerator;
//            secondModule.maxColumnsToFill = 1;
//            secondModule.setNumRowsAndColumns();
//            secondModule.resetLogicGrid();
//            second.redraw(true);
//
//            // Adjust visibility and alpha for the second fraction equation parts
//            secondDenom_eqData.firstValueNR.visible = true;
//            secondDenom_eqData.opSymbolText.visible = true;
//            secondDenom_eqData.secondValueNR.visible = true;
//            secondDenom_eqData.equalsSymbolText.visible = true;
//            secondDenom_eqData.resultValueNR.visible = true;
//
//            // Show tick sprites of first (for second)
//            segmentSpriteOfSecond.visible = true;
//            for (aTickSprite in tickSpritesForSecond)
//            {
//                aTickSprite.visible = true;
//            }
//        }
//
//        var doPeel : Void->Void = function() : Void
//        {
//            // Setup drop segments of first
//            var dropSegmentTuple : CgsTuple = firstModule.peelBlocks(dropSegmentsOfFirst);
//            var dropSegmentLocations : Array<Point> = dropSegmentTuple.second;
//            for (dropSegmentIndex in 0...finalFirstFraction.numerator)
//            {
//                // Show the drop segments
//                aDropSegment = dropSegmentsOfFirst[dropSegmentIndex];
//                aDropSegment.visible = true;
//
//                // Adjust their locations
//                var aDropLocation : Point = dropSegmentLocations[dropSegmentIndex];
//                aDropSegment.x = first.x + aDropLocation.x;
//                aDropSegment.y = first.y + aDropLocation.y;
//            }
//
//            // Setup drop segments of second
//            dropSegmentTuple = secondModule.peelBlocks(dropSegmentsOfSecond);
//            dropSegmentLocations = dropSegmentTuple.second;
//            for (dropSegmentIndex in 0...finalSecondFraction.numerator)
//            {
//                // Show the drop segments
//                aDropSegment = dropSegmentsOfSecond[dropSegmentIndex];
//                aDropSegment.visible = true;
//
//                // Adjust their locations
//                aDropLocation = dropSegmentLocations[dropSegmentIndex];
//                aDropSegment.x = second.x + aDropLocation.x;
//                aDropSegment.y = second.y + aDropLocation.y;
//            }
//
//            // Hide segment of first
//            firstModule.doShowSegment = false;
//
//            // Hide segment of second
//            secondModule.doShowSegment = false;
//
//            // Show result
//            result.visible = true;
//            result.alpha = 0;
//            resultModule.valueNumDisplayAlpha = 0;
//            result.redraw(true);
//
//            // Hide value NRs of first and second
//            firstModule.valueNumDisplayAlpha = 0;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 0;
//            second.redraw(true);
//
//            // Adjust locations of fraction value NRs
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
//            eqData.secondValueNR.visible = true;
//            eqData.opSymbolText.visible = true;
//            eqData.equalsSymbolText.visible = true;
//            eqData.resultValueNR.visible = true;
//        }
//
//        function doPeel_reverse() : Void
//        {
//            // Hide drop segments
//            for (aDropSegment in dropSegmentsOfFirst)
//            {
//                aDropSegment.visible = false;
//            }
//
//            // Hide drop segments
//            for (aDropSegment in dropSegmentsOfSecond)
//            {
//                aDropSegment.visible = false;
//            }
//
//            // Show segment of first
//            firstModule.doShowSegment = true;
//
//            // Show segment of second
//            secondModule.doShowSegment = true;
//
//            // Hide result
//            result.visible = false;
//
//            // Show value NRs of first and second
//            firstModule.valueNumDisplayAlpha = 1;
//            first.redraw(true);
//            secondModule.valueNumDisplayAlpha = 1;
//            second.redraw(true);
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }  // Redraw the first as the result fraction  ;
//
//
//
//        var doMerge : Void->Void = function() : Void
//        {
//            // Hide drop segments
//            for (aDropSegment in dropSegmentsOfFirst)
//            {
//                aDropSegment.visible = false;
//            }
//
//            // Hide drop segments
//            for (aDropSegment in dropSegmentsOfSecond)
//            {
//                aDropSegment.visible = false;
//            }
//
//            // Show result value
//            resultModule.valueNumDisplayAlpha = 1;
//            //resultModule.doShowSegment = true;
//            result.redraw(true);
//
//            // Hide first and second
//            first.visible = false;
//            second.visible = false;
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }
//
//        function doMerge_reverse() : Void
//        {
//            // Hide drop segments
//            for (aDropSegment in dropSegmentsOfFirst)
//            {
//                aDropSegment.visible = true;
//            }
//
//            // Show drop segments
//            for (aDropSegment in dropSegmentsOfSecond)
//            {
//                aDropSegment.visible = true;
//            }
//
//            // Hide result value
//            resultModule.valueNumDisplayAlpha = 0;
//            result.redraw(true);
//
//            // Show first and second
//            first.visible = true;
//            second.visible = true;
//
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = true;
//            eqData.opSymbolText.visible = true;
//            eqData.secondValueNR.visible = true;
//            eqData.equalsSymbolText.visible = true;
//            eqData.resultValueNR.visible = true;
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
//        }  // Clean up the peeled sprites
//        //   /**
//		// Completion
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

