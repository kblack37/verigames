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
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.NumberRendererFactory;
import cgs.fractionVisualization.util.VisualizationUtilities;
import cgs.fractionVisualization.util.EquationData;
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
class PieMultiplyAnimator implements IFractionAnimator
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
        return CgsFVConstants.PIE_STANDARD_MULTIPLY;
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
//        //generic counter for loops
//        var i : Int;
//
//        // for special placement of first fraction.  Assume width is 600 x 800
//        var assumedScreenSize : Point = new Point(800, 600);
//        // Fraction Views
//        var fractionViews : Array<CgsFractionView> = Reflect.field(details, Std.string(CgsFVConstants.CLONE_VIEWS_KEY));
//        var finalPosition : Point = Reflect.field(details, Std.string(CgsFVConstants.RESULT_DESTINATION));
//        var first : CgsFractionView = fractionViews[0];
//        var second : CgsFractionView = fractionViews[1];
//        var firstModule : PieFractionModule = try cast(first.module, PieFractionModule) catch(e:Dynamic) null;
//        var secondModule : PieFractionModule = try cast(second.module, PieFractionModule) catch(e:Dynamic) null;
//        var resultFraction : CgsFraction = CgsFraction.fMultiply(first.fraction, second.fraction);
//
//        // Create finalResults pie.  Backbone shown during re-assemble step then entire thing faded in during show answer step
//        var finalResult : CgsFractionView = first.clone();
//        finalResult.fraction.init(resultFraction.numerator, resultFraction.denominator);
//        finalResult.foregroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_FOREGROUND_COLOR)) : first.foregroundColor;
//        finalResult.backgroundColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BACKGROUND_COLOR)) : first.backgroundColor;
//        finalResult.borderColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_BORDER_COLOR)) : first.borderColor;
//        finalResult.tickColor = (Reflect.hasField(details, CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) ? Reflect.field(details, Std.string(CgsFVConstants.RESULT_FRACTION_TICK_COLOR)) : first.tickColor;
//
//        var finalResultModule : PieFractionModule = (try cast(finalResult.module, PieFractionModule) catch(e:Dynamic) null);
//        finalResult.visible = true;
//        finalResult.alpha = 0;
//        finalResultModule.doShowSegment = false;
//        finalResultModule.valueNumDisplayAlpha = 0;
//        finalResultModule.valueIsAbove = true;
//        m_animHelper.trackFractionView(finalResult);
//        m_animController.addChild(finalResult);
//
//        // when pies explode, this gives them the extra room to work.
//        // Make sure this step is done AFTER cloning first for result
//        firstModule.increasePieSpacing(2);
//
//        // Position data
//        // spanBetweenCenters now has two values because first fraction may need to be spaced out
//        var spanBetweenPieCentersFirst : Float = (firstModule.unitWidth + firstModule.distanceBetweenPies);
//        var spanBetweenPieCentersFinal : Float = (finalResultModule.unitWidth + finalResultModule.distanceBetweenPies);
//        var origFirstPosition : Point = new Point(first.x, first.y);
//        var origSecondPosition : Point = new Point(second.x, second.y);
//        var genericDistanceFromCenterForFirst : Float = assumedScreenSize.x / 4;
//        var newFirstPosition : Point = new Point(PieConstants.MULTIPLY_X_POSITION, 0 - PieConstants.MULTIPLY_TOP_FROM_CENTER_Y);
//        var secondPositionXadjustment : Float = (firstModule.numBaseUnits * spanBetweenPieCentersFirst) / 2 + spanBetweenPieCentersFirst;
//        var newSecondPosition : Point = new Point(newFirstPosition.x + secondPositionXadjustment, 0 - PieConstants.MULTIPLY_TOP_FROM_CENTER_Y);
//        var resultLocation : Point = new Point(PieConstants.MULTIPLY_X_POSITION, 0 + PieConstants.MULTIPLY_RESULT_Y_POSITION);
//        finalResult.x = resultLocation.x;
//        finalResult.y = resultLocation.y;
//
//        var equationCenter : Point = new Point(0, newFirstPosition.y - firstModule.unitHeight / 2 - PieConstants.ANIMATION_MARGIN_EQUATION);
//        var eqData : EquationData = m_animHelper.createEquationData(m_animController, equationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor, 1.5);
//        eqData.equationCenter = new Point(eqData.equationCenter.x + eqData.secondValueNR.width / 2 + eqData.opSymbolText.width / 2, eqData.equationCenter.y);
//
//        // Simplification
//        var doSimplify : Bool = !resultFraction.isSimplified;
//        var simplifiedResultFraction : CgsFraction = resultFraction.clone();
//        simplifiedResultFraction.simplify();
//        var simplifiedResult : CgsFractionView = finalResult.clone();
//        simplifiedResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//        var simplifiedResultModule : PieFractionModule = (try cast(simplifiedResult.module, PieFractionModule) catch(e:Dynamic) null);
//        simplifiedResultModule.valueIsAbove = true;
//        simplifiedResult.visible = false;
//        simplifiedResult.redraw(true);
//        simplifiedResult.x = 0;
//        simplifiedResult.y = 0;
//        m_animHelper.trackFractionView(simplifiedResult);
//        m_animController.addChild(simplifiedResult);
//
//
//
//        // parts of pulsing numerator and denominator
//        var secondValueNumeratorNR : TextField = m_animHelper.createTextField(Std.string(second.fraction.numerator), textColor, textGlowColor);
//        var secondValueDenominatorNR : TextField = m_animHelper.createTextField(Std.string(second.fraction.denominator), textColor, textGlowColor);
//        secondValueNumeratorNR.alpha = 0.0;
//        secondValueDenominatorNR.alpha = 0.0;
//
//        // Tween into position
//        var position_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DELAY_AFTER_POSITION);
//        var position_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_POSITION);
//
//        var positionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_POSITION, position_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        // make x 1/3 appear
//        positionStep.addCallback(0, prepEquation, null, prepEquation_reverse);
//        positionStep.addTween(0, new GTween(first, position_unitDuration, {
//                    x : newFirstPosition.x,
//                    y : newFirstPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(second, position_unitDuration, {
//                    x : eqData.secondValueNR_equationPosition.x,
//                    y : eqData.secondValueNR_equationPosition.y,
//                    alpha : 0.0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        // fade out and fade in of fraction label while moving the pies to the top of the screen
//        var moveStart : Float = .1;
//        positionStep.addTween(0, new GTween(firstModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        positionStep.addTween(0, new GTween(secondModule, position_unitDuration / 3, {
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
//        positionStep.addTween(position_unitDuration * (2 / 3), new GTween(secondModule, position_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
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
//
//        var changeDenom_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DELAY_AFTER_CHANGE_DENOM);
//        var changeDenom_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_CHANGE_DENOM);
//        var changeDenomStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_CHANGE_DENOMINATOR, changeDenom_unitDelay, CgsFVConstants.STEP_TYPE_CHANGE_DENOMINATOR);
//        var cumulativeDenominatorTiming : Float = 0;
//        changeDenomStep.addCallback(0, prepPrePartials, [true], prepPrePartials, [false]);
//
//        // fade fraction parts, but leave rest (label) of fraction
//        var fadeBackbone : GTween = new GTween(firstModule, 0.1, {
//            backboneAlpha : 0.0
//        }, {
//            ease : Sine.easeInOut
//        });
//        changeDenomStep.addTween(0, fadeBackbone);
//        var fadeTicks : GTween = new GTween(firstModule, 0.1, {
//            ticksAlpha : 0.0
//        }, {
//            ease : Sine.easeInOut
//        });
//        changeDenomStep.addTween(0, fadeTicks);
//        changeDenomStep.addTween(0, new GTween(firstModule, changeDenom_unitDuration, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        cumulativeDenominatorTiming += 0.1;
//
//
//        //***********
//        // Explode pie and prep values
//        //Moves used to start after equation was moved around but until they are added back in should start immediately
//        var prePartialSprites : Array<Sprite> = firstModule.duplicateAllSprites(1, null, true, true);
//        var prePartialSpritesFinalLocation : Array<Point> = new Array<Point>();
//        var prePartialSpritesDegreeLeadingEdgeDegrees : Array<Float> = new Array<Float>();
//        // Determines the location of the denominator pulse (middle of the original slice)
//
//        var widthFromPartialToPartial : Float = (firstModule.unitWidth / 2) + 10;
//        var widthOfPiecesAcross : Float = first.fraction.numerator * widthFromPartialToPartial;
//        var preY : Float = 0 - PieConstants.MULTIPLY_TOP_FROM_CENTER_Y;
//
//
//        var xGenericAlignmentAdjustment : Float = 300;
//        // explosion gets smaller as denominators get smaller
//        // The 36 below indicates that a denominator of 36 has been optimized
//        var explodePieDistance : Float = PieConstants.MULTIPLY_EXPLOSION_FACTOR * PieConstants.BASE_UNIT_DIAMETER * first.fraction.denominator / 36;
//        var pulsingNumberDistanceFromCenter : Float = explodePieDistance + PieConstants.BASE_UNIT_DIAMETER / 2 + PieConstants.MULT_ADDIITIONAL_SPACING_FOR_PULSED_NUMBERS;
//
//        for (i in 0...prePartialSprites.length)
//        {
//            m_animController.addChild(prePartialSprites[i]);  //Adds to display list, to be seen
//            m_animHelper.trackDisplay(prePartialSprites[i]);  //For garbage clean up
//            //Since these sprites all need (0,0) as center, must place them manually here.
//            prePartialSprites[i].x = newFirstPosition.x - ((firstModule.numBaseUnits - 1) * (spanBetweenPieCentersFirst / 2)) + Math.floor(i / first.fraction.denominator) * spanBetweenPieCentersFirst;
//            prePartialSprites[i].y = newFirstPosition.y;
//            // find the vector between the "left" side of the arc and the right side. (thus i + 1/2 of a distance)
//            // This will be the explode vector.
//            var degreeExplodePartialRadians : Float = (i + 0.5) * (2 * Math.PI / first.fraction.denominator);
//            prePartialSpritesDegreeLeadingEdgeDegrees.push(i * (360 / first.fraction.denominator));
//            var yPrePartialBounceTo : Float = prePartialSprites[i].y - Math.cos(degreeExplodePartialRadians) * explodePieDistance * PieConstants.MULTIPLY_EXPLOSION_BOUNCE_FACTOR;
//            var xPrePartialBounceTo : Float = prePartialSprites[i].x - Math.sin(degreeExplodePartialRadians) * explodePieDistance * PieConstants.MULTIPLY_EXPLOSION_BOUNCE_FACTOR;
//            var explodeOut_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_EXPLODE_OUT);
//            var prePartialSpritesBounceTween : GTween = new GTween(prePartialSprites[i], explodeOut_unitDuration, {
//                scaleX : 1,
//                scaleY : 1,
//                x : xPrePartialBounceTo,
//                y : yPrePartialBounceTo,
//                alpha : 1
//            }, {
//                ease : Sine.easeInOut
//            });
//            changeDenomStep.addTween(cumulativeDenominatorTiming, prePartialSpritesBounceTween);
//
//            var yPrePartialMoveTo : Float = prePartialSprites[i].y - Math.cos(degreeExplodePartialRadians) * explodePieDistance;
//            var xPrePartialMoveTo : Float = prePartialSprites[i].x - Math.sin(degreeExplodePartialRadians) * explodePieDistance;  //0 - xGenericAlignmentAdjustment + i * widthFromPartialToPartial;
//            // This is used later for next set of sprites to line them up on top of moved prePartials
//            prePartialSpritesFinalLocation.push(new Point(xPrePartialMoveTo, yPrePartialMoveTo));
//
//            // final Resting place
//            var explodeBack_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_EXPLODE_BACK);
//            var prePartialSpritesMoveTween : GTween = new GTween(prePartialSprites[i], explodeBack_unitDuration, {
//                scaleX : 1,
//                scaleY : 1,
//                x : xPrePartialMoveTo,
//                y : yPrePartialMoveTo,
//                alpha : 1
//            }, {
//                ease : Sine.easeIn
//            });
//            changeDenomStep.addTween(cumulativeDenominatorTiming + explodeOut_unitDuration, prePartialSpritesMoveTween);
//        }
//
//        cumulativeDenominatorTiming += explodeOut_unitDuration + explodeBack_unitDuration;
//
//        //***********
//        // Begin flying denominator and pulsing here
//        var paramsForSprites : Dynamic = null;  // example: {foregroundColor:0xffffff, tickColor: 0x6600cc };
//        var partialSprites : Array<Sprite> = firstModule.duplicateAllSprites(second.fraction.denominator, paramsForSprites, true, true);
//        var partitionFadeInTween : GTween;
//        var partitionFadeInAndPulseTween : GTween;
//        var partitionBackToSizeTween : GTween;
//
//        // this is for a single pulse
//        var durationOfPartition : Float = changeDenom_unitDuration / 4;
//
//        var pulseStationary_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_PULSE_STATIONARY_NUMBER);
//
//        changeDenomStep.addTween(cumulativeDenominatorTiming, new GTween(eqData.secondValueNR, pulseStationary_unitDuration, {
//                    denominatorScale : eqData.secondValueNR.denominatorScale * 1.5
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        cumulativeDenominatorTiming += pulseStationary_unitDuration;
//        changeDenomStep.addTween(cumulativeDenominatorTiming, new GTween(eqData.secondValueNR, pulseStationary_unitDuration, {
//                    denominatorScale : eqData.secondValueNR.denominatorScale
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        cumulativeDenominatorTiming += pulseStationary_unitDuration;
//
//        changeDenomStep.addCallback(cumulativeDenominatorTiming, prepPulserDenominator, null, prepPulserDenominator_reverse);
//        cumulativeDenominatorTiming += pulseStationary_unitDuration / 2;
//
//        // Find degrees for middle of sector in question
//        var adjustToMiddleOfSector : Float = prePartialSpritesDegreeLeadingEdgeDegrees[0] + (180 / first.fraction.denominator);
//        var locationAroundPieForPulsingDenominator : Point = new Point(prePartialSpritesFinalLocation[0].x - Math.sin(adjustToMiddleOfSector / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.x,
//        prePartialSpritesFinalLocation[0].y - Math.cos(adjustToMiddleOfSector / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.y);
//
//        //pulsing denominator
//        m_animController.addChild(secondValueDenominatorNR);
//        var indexOfPulsingDenominator : Float = m_animController.getChildIndex(secondValueDenominatorNR);
//
//        var moveDenominatorDurationFirst : Float = changeDenom_unitDuration / 2;
//        var moveDenominator : GTween = new GTween(secondValueDenominatorNR, moveDenominatorDurationFirst, {
//            x : locationAroundPieForPulsingDenominator.x,
//            y : locationAroundPieForPulsingDenominator.y
//        }, {
//            ease : Sine.easeInOut
//        });
//        changeDenomStep.addTween(cumulativeDenominatorTiming, moveDenominator);
//        cumulativeDenominatorTiming += moveDenominatorDurationFirst;
//
//        var moveDenominatorDurationAroundPie : Float = changeDenom_unitDuration / 4;
//        var timingForArrivalOfDenominator : Float = cumulativeDenominatorTiming;
//
//        for (i in 0...partialSprites.length)
//        {
//            // addChildAt used below so pulsingDenominator is above it.
//            m_animController.addChildAt(partialSprites[i], indexOfPulsingDenominator);  //Adds to display list, to be seen
//            m_animHelper.trackDisplay(partialSprites[i]);  //For garbage clean up
//            partialSprites[i].visible = false;
//            partialSprites[i].alpha = 0.0;
//
//            //Get coordiates from big sectors for little sectors
//            partialSprites[i].x = prePartialSpritesFinalLocation[Math.floor(i / second.fraction.denominator)].x;
//            partialSprites[i].y = prePartialSpritesFinalLocation[Math.floor(i / second.fraction.denominator)].y;
//
//            //do first set slowly, do next sets as a group
//            // move denominator after each cycle of pulsing on a section
//            if (i != 0 && (i % second.fraction.denominator) == 0)
//            {
//                //speed up duration SLIGHTLY after first set
//                durationOfPartition = changeDenom_unitDuration / 5;
//
//                var whichPrePartial : Int = Math.floor(i / second.fraction.denominator);
//                // Find degrees for middle of sector in question
//                adjustToMiddleOfSector = prePartialSpritesDegreeLeadingEdgeDegrees[whichPrePartial] + (180 / first.fraction.denominator);
//
//                locationAroundPieForPulsingDenominator = new Point(prePartialSpritesFinalLocation[whichPrePartial].x - Math.sin(adjustToMiddleOfSector / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.x,
//                        prePartialSpritesFinalLocation[whichPrePartial].y - Math.cos(adjustToMiddleOfSector / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.y);
//                // for very first partition, pause extra
//                if (i == second.fraction.denominator)
//                {
//                    timingForArrivalOfDenominator += durationOfPartition * 2;
//                }
//                moveDenominator = new GTween(secondValueDenominatorNR, moveDenominatorDurationAroundPie, {
//                            x : locationAroundPieForPulsingDenominator.x,
//                            y : locationAroundPieForPulsingDenominator.y,
//                            scaleX : 1.5,
//                            scaleY : 1.5
//                        }, {
//                            ease : Sine.easeInOut
//                        });
//                changeDenomStep.addTween(durationOfPartition * i + timingForArrivalOfDenominator, moveDenominator);
//                timingForArrivalOfDenominator += moveDenominatorDurationAroundPie;
//            }
//
//            changeDenomStep.addCallback(durationOfPartition * i + timingForArrivalOfDenominator, changeVisibility, [partialSprites[i], true],
//                    changeVisibility, [partialSprites[i], false]
//            );
//            var fadeInPartial : GTween = new GTween(partialSprites[i], durationOfPartition / 4, {
//                alpha : 1.0
//            }, {
//                ease : Sine.easeInOut
//            });
//            changeDenomStep.addTween(durationOfPartition * i + timingForArrivalOfDenominator, fadeInPartial);
//            changeDenomStep.addTweenSet(durationOfPartition * i + timingForArrivalOfDenominator, FVEmphasis.computePulseTweens(secondValueDenominatorNR, durationOfPartition, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//            changeDenomStep.addTweenSet(durationOfPartition * i + timingForArrivalOfDenominator, FVEmphasis.computePulseTweens(partialSprites[i], durationOfPartition, 1, 1, PieConstants.PULSE_SCALE_GENERAL));
//        }
//
//        m_animHelper.appendStep(changeDenomStep);
//
//
//        //*************** Drop new parts to middle (second numerators worth from each of the orginal larger partitions)
//        var drop_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DELAY_AFTER_DROP);
//        var drop_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_DROP);
//
//        var dropStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_DROP, drop_unitDelay, CgsFVConstants.STEP_TYPE_DROP);
//
//        // Make sure move doesn't take too long
//        var timingOfDrop : Float = drop_unitDuration / 4;
//        var cumulativeDropTiming : Float = 0;
//
//        // fade old denominator and de-emphasize in equation
//        var fadeDenominator : GTween = new GTween(secondValueDenominatorNR, drop_unitDuration / 4, {
//            alpha : 0.0
//        }, {
//            ease : Sine.easeInOut
//        });
//        dropStep.addTween(0, fadeDenominator);
//
//        // pulse numerator in equation
//        cumulativeDropTiming += drop_unitDuration / 4;
//        // if first is zero, do not take any, skip
//        if (first.fraction.value != 0)
//        {
//            dropStep.addTween(cumulativeDropTiming, new GTween(eqData.secondValueNR, pulseStationary_unitDuration, {
//                        numeratorScale : eqData.secondValueNR.denominatorScale * 1.5
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            cumulativeDropTiming += pulseStationary_unitDuration;
//            dropStep.addTween(cumulativeDropTiming, new GTween(eqData.secondValueNR, pulseStationary_unitDuration, {
//                        numeratorScale : eqData.secondValueNR.denominatorScale
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            cumulativeDropTiming += pulseStationary_unitDuration;
//            // very quickly make moving numerator appear
//            dropStep.addCallback(cumulativeDropTiming, prepPulserNumerator, null, prepPulserNumerator_reverse);
//
//            cumulativeDropTiming += pulseStationary_unitDuration / 2;
//        }
//        // Get leading degree of each sector from first fraction and then center it on the first new "sub" denominator by adding on 1/2 of one of these degrees.
//        var centerDegreeOfFirstNewDenonimatorInEachOldDenonimator : Float = prePartialSpritesDegreeLeadingEdgeDegrees[0] + (180 * 1 / (first.fraction.denominator * second.fraction.denominator));
//
//        // new points are the location of sprite adjusted to distance based on degrees (that have been turned into radians using /180 * Math.PI )
//        var locationAroundPieForPulsingNumerator : Point = new Point(prePartialSpritesFinalLocation[0].x - Math.sin(centerDegreeOfFirstNewDenonimatorInEachOldDenonimator / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.x,
//        prePartialSpritesFinalLocation[0].y - Math.cos(centerDegreeOfFirstNewDenonimatorInEachOldDenonimator / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.y);
//
//        // add these sprites first so pulsing numerator is on top.
//
//
//        m_animController.addChild(secondValueNumeratorNR);
//        var indexOfPulsingNumerator : Float = m_animController.getChildIndex(secondValueNumeratorNR);
//        var moveNumeratorDurationFirst : Float = drop_unitDuration / 2;
//
//        if (first.fraction.value != 0)
//        {
//            var moveNumerator : GTween = new GTween(secondValueNumeratorNR, moveNumeratorDurationFirst, {
//                x : locationAroundPieForPulsingNumerator.x,
//                y : locationAroundPieForPulsingNumerator.y
//            }, {
//                ease : Sine.easeInOut
//            });
//            dropStep.addTween(cumulativeDropTiming, moveNumerator);
//            cumulativeDropTiming += moveNumeratorDurationFirst;
//        }
//        var moveNumeratorDurationAroundPie : Float = drop_unitDuration / 4;
//
//        var totalSetupForNumeratorPulsing : Float = cumulativeDropTiming;
//
//        var getPartsAlignment : Point = new Point(0 - xGenericAlignmentAdjustment, newFirstPosition.y + spanBetweenPieCentersFirst);
//        var partialSpritesForMoving : Array<Sprite> = finalResultModule.duplicateAllSprites(1);
//
//        // NEW TO THIS VERSION.  From old re-assemble step
//        //Math.ceil(value) is equivalent to numBaseUnits. One Base Units means no adjustment of width.  Otherwise each additional unit means one more span.
//        var x : Float = resultLocation.x - ((Math.ceil(resultFraction.value) - 1) * spanBetweenPieCentersFinal / 2);
//
//
//        for (j in 0...first.fraction.numerator)
//        {
//            for (i in 0...second.fraction.numerator)
//            {
//                var offset : Float = i + j * second.fraction.numerator;
//                var partialSprite : Sprite = Reflect.field(partialSpritesForMoving, Std.string(offset));
//                // get the first sprite in each section
//                partialSprite.rotation = (offset * (1 / finalResult.fraction.denominator * 360)) - prePartialSpritesDegreeLeadingEdgeDegrees[j];
//                partialSprite.alpha = 0.0;
//                partialSprite.visible = true;
//                partialSprite.x = prePartialSpritesFinalLocation[j].x;
//                partialSprite.y = prePartialSpritesFinalLocation[j].y;
//                // addChildAt used below so pulsingNumerator is above it.
//                // value below is incremented so that last sprite will be on top.
//                m_animController.addChildAt(partialSprite, indexOfPulsingNumerator);  //Adds to display list, to be seen
//                indexOfPulsingNumerator++;
//                m_animHelper.trackDisplay(partialSprite);  //For garbage clean up
//
//                // fade-in all parts
//                var partialSpritesFadeInWhilePulsing : GTween = new GTween(partialSprite, pulseStationary_unitDuration, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                });
//                dropStep.addTween(totalSetupForNumeratorPulsing + timingOfDrop * offset, partialSpritesFadeInWhilePulsing);
//                // pulse before moving
//                dropStep.addTweenSet(totalSetupForNumeratorPulsing + timingOfDrop * offset, FVEmphasis.computePulseTweens(partialSprite, pulseStationary_unitDuration, 1, 1, PieConstants.PULSE_SCALE_SEGMENT));
//
//
//                //move to middle
//                var index : Float = i + j * second.fraction.numerator;
//                // Adjust x for multiple circles.
//                if (index != 0 && index % resultFraction.denominator == 0)
//                {
//                    x += spanBetweenPieCentersFinal;
//                }
//                var y : Float = resultLocation.y;
//                var reverseOriginalOrientation : Float = prePartialSpritesDegreeLeadingEdgeDegrees[j];
//                var orientationCCfromNoon : Float = -((360 / (first.fraction.denominator * second.fraction.denominator)) * index);
//                var partialSpritesReassembleTween : GTween = new GTween(partialSprite, drop_unitDuration, {
//                    scaleX : 1,
//                    scaleY : 1,
//                    x : x,
//                    y : y,
//                    rotation : 0
//                }, {
//                    ease : Sine.easeInOut
//                });
//                dropStep.addTween(totalSetupForNumeratorPulsing + (timingOfDrop * offset) + pulseStationary_unitDuration, partialSpritesReassembleTween);
//
//
//                var pulseNumerator : GTween = new GTween(secondValueNumeratorNR, timingOfDrop / 4, {
//                    scaleX : 1.5,
//                    scaleY : 1.5
//                }, {
//                    ease : Sine.easeInOut
//                });
//                dropStep.addTween(cumulativeDropTiming, pulseNumerator);
//                cumulativeDropTiming += timingOfDrop / 2;
//
//                var shrinkNumerator : GTween = new GTween(secondValueNumeratorNR, timingOfDrop / 4, {
//                    scaleX : 1.0,
//                    scaleY : 1.0
//                }, {
//                    ease : Sine.easeInOut
//                });
//                dropStep.addTween(cumulativeDropTiming, shrinkNumerator);
//                cumulativeDropTiming += timingOfDrop / 2;
//            }
//            // If not last step, move to next spot
//            if (j < first.fraction.numerator - 1)
//            {
//                // Get leading degree of each sector from first fraction and then center it on the first new "sub" denominator by adding on 1/2 of one of these degrees.
//                centerDegreeOfFirstNewDenonimatorInEachOldDenonimator = prePartialSpritesDegreeLeadingEdgeDegrees[j + 1] + (180 * 1 / (first.fraction.denominator * second.fraction.denominator));
//
//                // new points are the location of sprite adjusted to distance based on degrees (that have been turned into radians using /180 * Math.PI )
//                locationAroundPieForPulsingNumerator = new Point(prePartialSpritesFinalLocation[j + 1].x - Math.sin(centerDegreeOfFirstNewDenonimatorInEachOldDenonimator / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.x,
//                        prePartialSpritesFinalLocation[j + 1].y - Math.cos(centerDegreeOfFirstNewDenonimatorInEachOldDenonimator / 180 * Math.PI) * pulsingNumberDistanceFromCenter + PieConstants.MULT_PULSED_NUMBER_OFFSET.y);
//
//                // move Numerator and pulse
//                moveNumerator = new GTween(secondValueNumeratorNR, moveNumeratorDurationAroundPie, {
//                            x : locationAroundPieForPulsingNumerator.x,
//                            y : locationAroundPieForPulsingNumerator.y
//                        }, {
//                            ease : Sine.easeInOut
//                        });
//                dropStep.addTween(cumulativeDropTiming, moveNumerator);
//                cumulativeDropTiming += moveNumeratorDurationAroundPie;
//                // keep inner loop in sync
//                totalSetupForNumeratorPulsing += moveNumeratorDurationAroundPie;
//            }
//        }
//
//
//        var fadeNumerator : GTween = new GTween(secondValueNumeratorNR, drop_unitDuration / 4, {
//            alpha : 0.0
//        }, {
//            ease : Sine.easeInOut
//        });
//
//        dropStep.addTween(cumulativeDropTiming, fadeNumerator);
//
//        // fade in = #/# on equation
//        // TODO:  Is this even needed any more?
//        var fadeFirst : GTween = new GTween(first, drop_unitDuration, {
//            alpha : 0
//        }, {
//            ease : Sine.easeInOut
//        });
//        var fadeSecond : GTween = new GTween(second, drop_unitDuration, {
//            alpha : 0
//        }, {
//            ease : Sine.easeInOut
//        });
//        dropStep.addTween(cumulativeDropTiming, fadeFirst);
//        dropStep.addTween(cumulativeDropTiming, fadeSecond);
//
//        //fade partials (little slices in work area that are on top of big slices)
//        for (i in 0...partialSprites.length)
//        {
//            fade = new GTween(partialSprites[i], drop_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    });
//            dropStep.addTween(cumulativeDropTiming, fade);
//        }
//
//        // fade prePartials (big slices in work area)
//        for (i in 0...prePartialSprites.length)
//        {
//            fade = new GTween(prePartialSprites[i], drop_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    });
//            dropStep.addTween(cumulativeDropTiming, fade);
//        }
//
//        if (prePartialSprites.length > 0)
//        {
//            cumulativeDropTiming += drop_unitDuration;
//        }
//
//        // Move expression to middle
//        var finalEquationCenter : Point = new Point(finalResult.x + finalResultModule.valueNRPosition.x, finalResult.y + finalResultModule.valueNRPosition.y);
//        var finalEqData : EquationData = m_animHelper.createEquationData(m_animController, finalEquationCenter, first.fraction.clone(), " × ", second.fraction.clone(), resultFraction, textColor, textGlowColor);
//        finalEqData.equationCenter = new Point(finalEqData.equationCenter.x - finalEqData.secondValueNR.width / 2 - finalEqData.equalsSymbolText.width - finalEqData.resultValueNR.width / 2, finalEqData.equationCenter.y);
//
//        dropStep.addTween(cumulativeDropTiming, new GTween(eqData.firstValueNR, drop_unitDuration, {
//                    x : finalEqData.firstValueNR_equationPosition.x,
//                    y : finalEqData.firstValueNR_equationPosition.y,
//                    numeratorScale : 1,
//                    denominatorScale : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(cumulativeDropTiming, new GTween(eqData.opSymbolText, drop_unitDuration, {
//                    x : finalEqData.opSymbolText_equationPosition.x,
//                    y : finalEqData.opSymbolText_equationPosition.y,
//                    scaleX : 1,
//                    scaleY : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        dropStep.addTween(cumulativeDropTiming, new GTween(eqData.secondValueNR, drop_unitDuration, {
//                    x : finalEqData.secondValueNR_equationPosition.x,
//                    y : finalEqData.secondValueNR_equationPosition.y,
//                    numeratorScale : 1,
//                    denominatorScale : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        m_animHelper.appendStep(dropStep);
//
//        //* Merge Tween
//        var merge_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DELAY_AFTER_MERGE);
//        var merge_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_MERGE);
//        var cumulativeMergeTiming : Float = 0;
//
//        var mergeStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_MERGE, merge_unitDelay, CgsFVConstants.STEP_TYPE_MERGE);
//
//        // show backbone of finalResult pie
//        // if backbone not needed such as case 6/3, reduce timing
//        var backboneTiming : Float = merge_unitDuration;
//        if (finalResult.fraction.value == Math.floor(finalResult.fraction.value))
//        {
//            backboneTiming = 0.1;
//        }
//        mergeStep.addTween(cumulativeMergeTiming, new GTween(finalResult, backboneTiming, {
//                    alpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        cumulativeMergeTiming += backboneTiming;
//
//        mergeStep.addCallback(cumulativeMergeTiming, finalizeMerge, [true], finalizeMerge, [false]);
//        cumulativeMergeTiming += 0.1;
//
//        mergeStep.addTweenSet(cumulativeMergeTiming, EquationData.animationEquationInline_phaseTwo(finalEqData, merge_unitDuration));
//        cumulativeMergeTiming += merge_unitDuration;
//
//        mergeStep.addTweenSet(cumulativeMergeTiming, EquationData.consolidateEquation(finalEqData, merge_unitDuration, finalEqData.resultValueNR_equationPosition));
//        cumulativeMergeTiming += merge_unitDuration;
//
//        mergeStep.addCallback(cumulativeMergeTiming, finalizeEquation, [true], finalizeEquation, [false]);
//
//        var fade : GTween;
//        // fade or move flying daggers
//        if (!doSimplify)
//        {
//            //move partials instead of fading them
//            mergeStep.addCallback(cumulativeMergeTiming, removePartialSprites, null, removePartialSprites_reverse);
//        }
//
//        m_animHelper.appendStep(mergeStep);
//
//        // Simplification
//        if (doSimplify)
//        {
//            var simplification_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DELAY_AFTER_SIMPLIFICATION);
//            var simplification_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_SIMPLIFICATION);
//
//            var simplificationStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_SIMPLIFICATION, simplification_unitDelay, CgsFVConstants.STEP_TYPE_SIMPLIFICATION);
//            simplificationStep.addCallback(0, prepForSimplification, null, prepForSimplification_reverse);
//            simplificationStep.addTween(.1, new GTween(finalResult, simplification_unitDuration, {
//                        alpha : 0
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addTween(.1, new GTween(simplifiedResult, simplification_unitDuration, {
//                        alpha : 1
//                    }, {
//                        ease : Sine.easeInOut
//                    }));
//            simplificationStep.addCallback(.1 + simplification_unitDuration, finalizeSimplification, [true], finalizeSimplification, [false]);
//            m_animHelper.appendStep(simplificationStep);
//        }
//
//        // Final Position
//        var unposition_unitDelay : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DELAY_AFTER_UNPOSITION);
//        var unposition_unitDuration : Float = m_animHelper.computeScaledTime(PieConstants.TIME_MULT_DURATION_UNPOSITION);
//
//        var unpositionStep : AnimationStep = new AnimationStep(GenConstants.STEP_NAME_UNPOSITION, unposition_unitDelay, CgsFVConstants.STEP_TYPE_POSITION);
//        unpositionStep.addTween(0, new GTween(finalResult, unposition_unitDuration, {
//                    x : finalPosition.x,
//                    y : finalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(unposition_unitDuration + 0, new GTween(finalResultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addCallback(unposition_unitDuration + unposition_unitDuration / 2, moveToTop, [finalResultModule, false], moveToTop, [finalResultModule, true]);
//        unpositionStep.addTween(unposition_unitDuration + unposition_unitDuration * (2 / 3), new GTween(finalResultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        unpositionStep.addTween(0, new GTween(simplifiedResult, unposition_unitDuration, {
//                    x : finalPosition.x,
//                    y : finalPosition.y
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addTween(unposition_unitDuration + 0, new GTween(simplifiedResultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 0
//                }, {
//                    ease : Sine.easeInOut
//                }));
//        unpositionStep.addCallback(unposition_unitDuration + unposition_unitDuration / 2, moveToTop, [simplifiedResultModule, false], moveToTop, [simplifiedResultModule, true]);
//        unpositionStep.addTween(unposition_unitDuration + unposition_unitDuration * (2 / 3), new GTween(simplifiedResultModule, unposition_unitDuration / 3, {
//                    valueNumDisplayAlpha : 1
//                }, {
//                    ease : Sine.easeInOut
//                }));
//
//        //m_animHelper.appendStep(unpositionStep);
//        // unpositionStep is now added in animate at end of method
//
//
//        /**
//			 * Completion
//			**/
//
//
//        // Go
//        m_animHelper.animate(multComplete, positionStep, unpositionStep);
//
//        function multComplete() : Void
//        {
//            endAnimation();
//            if (completeCallback != null)
//            {
//                // Get result view and send it to the game
//                var resultViews : Array<CgsFractionView> = new Array<CgsFractionView>();
//                resultViews.push(first);
//
//                completeCallback(resultViews);
//            }
//        }  // Performs simplification of first (that is, the result) fraction  ;
//
//
//
//
//        var doSimplification : Void->Void = function() : Void
//        {
//            finalResult.fraction.init(simplifiedResultFraction.numerator, simplifiedResultFraction.denominator);
//            finalResultModule.doShowSegment = true;
//            finalResult.redraw(true);
//        }
//
//        function doSimplification_reverse() : Void
//        {
//            finalResult.fraction.init(resultFraction.numerator, resultFraction.denominator);
//            finalResultModule.doShowSegment = true;
//            finalResult.redraw(true);
//        }  // Performs redraw of result (previously backbone only)  ;
//
//
//
//        var removePartialSprites : Void->Void = function() : Void
//        {
//            for (i in 0...partialSpritesForMoving.length)
//            {
//                partialSpritesForMoving[i].visible = false;
//            }
//        }
//        function removePartialSprites_reverse() : Void
//        {
//            for (i in 0...partialSpritesForMoving.length)
//            {
//                partialSpritesForMoving[i].visible = true;
//            }
//        }  // Moves the location of the fraction value of the first module (the view on the bottom) to display underneath the strip  ;
//
//
//
//        var moveValueToTop : Void->Void = function() : Void
//        {
//            firstModule.valueIsAbove = true;
//            secondModule.valueIsAbove = true;
//        }
//
//        var moveValueToTop_reverse : Void->Void = function() : Void
//        {
//            firstModule.valueIsAbove = false;
//            secondModule.valueIsAbove = false;
//        }
//
//        var moveToTop : PieFractionModule->Bool->Void = function(module : PieFractionModule, above : Bool) : Void
//        {
//            module.valueIsAbove = above;
//        }
//
//        var prepEquation : Void->Void = function() : Void
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
//        }
//
//        var prepEquation_reverse : Void->Void = function() : Void
//        {
//            // Adjust visibility of equation parts
//            eqData.firstValueNR.visible = false;
//            eqData.opSymbolText.visible = false;
//            eqData.secondValueNR.visible = false;
//            eqData.equalsSymbolText.visible = false;
//            eqData.resultValueNR.visible = false;
//        }
//
//        var prepPrePartials : Bool->Void = function(visible : Bool) : Void
//        {
//            firstModule.doShowSegment = !visible;
//            for (i in 0...prePartialSprites.length)
//            {
//                prePartialSprites[i].visible = visible;
//            }
//        }
//
//        var prepPulserNumerator : Void->Void = function() : Void
//        {
//            // Adjust locations of fraction value NRs
//            secondValueNumeratorNR.x = eqData.secondValueNR.x - 8;
//            secondValueNumeratorNR.y = eqData.secondValueNR.y - 35;
//            // Adjust alphas and visibility of equation parts
//            secondValueNumeratorNR.alpha = 1;
//            secondValueNumeratorNR.visible = true;
//        }
//
//        var prepPulserNumerator_reverse : Void->Void = function() : Void
//        {
//            // Adjust alphas and visibility of equation parts
//            secondValueNumeratorNR.alpha = 0;
//            secondValueNumeratorNR.visible = false;
//        }
//
//        var prepPulserDenominator : Void->Void = function() : Void
//        {
//            // Adjust locations of fraction value NRs
//            secondValueDenominatorNR.x = eqData.secondValueNR.x - 8;
//            secondValueDenominatorNR.y = eqData.secondValueNR.y - 0;
//            // Adjust alphas and visibility of equation parts
//            secondValueDenominatorNR.alpha = 1;
//            secondValueDenominatorNR.visible = true;
//        }
//
//        function prepPulserDenominator_reverse() : Void
//        {
//            // Adjust alphas and visibility of equation parts
//            secondValueDenominatorNR.alpha = 0;
//            secondValueDenominatorNR.visible = false;
//        }  // Throw away peeled value, update first view with new fraction  ;
//
//
//
//        function finalizeMerge(visible : Bool) : Void
//        {
//            for (i in 0...partialSpritesForMoving.length)
//            {
//                partialSpritesForMoving[i].alpha = ((visible)) ? 0 : 1;
//            }
//            finalResultModule.doShowSegment = visible;  // true;
//            finalResult.redraw(true);
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
//            eqData.firstValueNR.visible = !visible;  // false;
//            eqData.opSymbolText.visible = !visible;  // false;
//            eqData.secondValueNR.visible = !visible;  // false;
//            finalEqData.firstValueNR.visible = visible;  // true;
//            finalEqData.opSymbolText.visible = visible;  // true;
//            finalEqData.secondValueNR.visible = visible;  // true;
//            finalEqData.equalsSymbolText.visible = visible;  // true;
//            finalEqData.resultValueNR.visible = visible;  // true;
//            finalEqData.firstValueNR.alpha = ((visible)) ? 1 : 0;  //1
//            finalEqData.opSymbolText.alpha = ((visible)) ? 1 : 0;  //1
//            finalEqData.secondValueNR.alpha = ((visible)) ? 1 : 0;  //1
//            finalEqData.equalsSymbolText.alpha = ((visible)) ? 0 : 1;  //0
//            finalEqData.resultValueNR.alpha = ((visible)) ? 0 : 1;
//        }  // Finalizes the consolidation of the equation  ;
//
//
//
//        function finalizeEquation(visible : Bool) : Void
//        {
//            // Show result value on result
//            finalResultModule.valueNumDisplayAlpha = ((visible)) ? 1 : 0;  // 1;
//            finalResult.redraw(true);
//
//            // Hide equation data
//            finalEqData.firstValueNR.visible = !visible;  // false;
//            finalEqData.opSymbolText.visible = !visible;  //
//            finalEqData.secondValueNR.visible = !visible;  //
//            finalEqData.equalsSymbolText.visible = !visible;  //
//            finalEqData.resultValueNR.visible = !visible;
//        }  // Prepares for simplification of result fraction  ;
//
//
//
//        var prepForSimplification : Void->Void = function() : Void
//        {
//            // Show simplified result
//            simplifiedResult.visible = true;
//            simplifiedResult.alpha = 0;
//            simplifiedResult.x = finalResult.x;
//            simplifiedResult.y = finalResult.y;
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
//        var finalizeSimplification : Bool->Void = function(visible : Bool) : Void
//        {
//            // Hidesimplified result
//            first.visible = !visible;
//        }
//
//        var changeVisibility : Sprite->Bool->Void = function(sprite : Sprite, value : Bool) : Void
//        {
//            sprite.visible = value;
//        }
    }
}

