package cgs.fractionVisualization.fractionAnimators;

import haxe.Constraints.Function;
import cgs.engine.view.IRenderer;
import cgs.fractionVisualization.CgsFractionAnimationController;
import cgs.fractionVisualization.CgsFractionView;
import cgs.fractionVisualization.constants.CgsFVConstants;
import cgs.fractionVisualization.constants.GenConstants;
import cgs.fractionVisualization.util.EquationData;
import cgs.fractionVisualization.util.NumberRenderer;
import cgs.fractionVisualization.util.NumberRendererFactory;
import cgs.math.CgsFraction;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
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
class AnimationHelper
{
    public var currentDisplays(get, never) : Array<DisplayObject>;
    public var currentTime(get, never) : Float;
    public var isPaused(get, never) : Bool;
    public var stepDetailsList(get, never) : Array<Dynamic>;
    public var totalTime(get, set) : Float;
    public var endTime(get, never) : Float;

    private static var END_BUFFER : Float = 1 / 30;  // The amount of extra time at the end of the animation  
    private static inline var TIME_DELAY_START : Float = 1;
    private static inline var TIME_DELAY_COMPELTE : Float = 1;
    
    // State
    private var m_currentDisplays : Array<DisplayObject>;  // Private so that it can not be simply removed  
    private var m_fractionViews : Array<CgsFractionView>;
    private var m_numberRenderers : Array<NumberRenderer>;
    private var m_equationDatas : Array<EquationData>;
    private var m_steps : Array<AnimationStep>;
    
    // Init State
    private var m_animController : CgsFractionAnimationController;
    private var m_renderer : IRenderer;
    private var m_details : Dynamic;
    private var m_animationStepSettings : Dynamic;
    
    // State to be reset
    private var m_currentTimeline : GTweenTimeline;
    private var m_totalTime : Float = -1;
    
    public function new()
    {
        m_currentDisplays = new Array<DisplayObject>();
        m_fractionViews = new Array<CgsFractionView>();
        m_numberRenderers = new Array<NumberRenderer>();
        m_equationDatas = new Array<EquationData>();
        m_steps = new Array<AnimationStep>();
    }
    
    /**
		 * Initializes this animation helper with the animation controller and the renderer used for the animation.
		 * @param	animController
		 * @param	aRenderer
		 */
    public function init(animController : CgsFractionAnimationController, aRenderer : IRenderer, details : Dynamic) : Void
    {
        m_animController = animController;
        m_renderer = aRenderer;
        m_details = details;
        m_animationStepSettings = processForAnimationSettings(details);
    }
    
    /**
		 * Processes the given details for the step settings.
		 * @param	details
		 * @return
		 */
    private function processForAnimationSettings(details : Dynamic) : Dynamic
    {
        // Get the animation settings out of the details
        var animationSettings : Dynamic = null;
        if (Reflect.hasField(details, CgsFVConstants.STEP_SETTINGS_KEY))
        {
            animationSettings = Reflect.field(details, Std.string(CgsFVConstants.STEP_SETTINGS_KEY));
        }
        else
        {
            animationSettings = {};
        }
        
        // Check for all animation settings, set to default (true) if not existing
        for (aSetting/* AS3HX WARNING could not determine type for var: aSetting exp: EField(EIdent(CgsFVConstants),STEP_SETTINGS_LIST) type: null */ in CgsFVConstants.STEP_SETTINGS_LIST)
        {
            if (!Reflect.hasField(animationSettings, aSetting))
            {
                Reflect.setField(animationSettings, Std.string(aSetting), true);
            }
        }
        
        return animationSettings;
    }
    
    /**
		 * Clears out the animation variables for this animator. Override this if you add your own animation variables.
		 * @param	resultViews
		 */
    public function reset() : Void
    {
        endAnimation();
        m_animController = null;
        m_renderer = null;
    }
    
    /**
		 * Ends the current animation and cleans everything up. If any resultViews are provided, does not clean them up
		 * so that they can be returned.
		 * @param	resultViews
		 */
    public function endAnimation(resultViews : Array<CgsFractionView> = null) : Void
    {
        // Pause the timeline
        if (m_currentTimeline != null)
        {
            m_currentTimeline.paused = true;
        }
        
        // Remove any steps
        while (m_steps.length > 0)
        {
            var aStep : AnimationStep = m_steps.pop();
            aStep.removeFromTimeline(m_currentTimeline);
        }
        
        // Remove the timeline
        m_currentTimeline = null;
        m_totalTime = -1;
        
        // Remove any displays still laying around
        while (m_currentDisplays.length > 0)
        {
            var aDisplay : DisplayObject = m_currentDisplays.pop();
            if (aDisplay.parent != null)
            {
                aDisplay.parent.removeChild(aDisplay);
            }
        }
        
        // Remove any fraction views still laying around
        while (m_fractionViews.length > 0)
        {
            var aFracView : CgsFractionView = m_fractionViews.pop();
            if (resultViews == null || Lambda.indexOf(resultViews, aFracView) < 0)
            {
                if (aFracView.parent != null)
                {
                    aFracView.parent.removeChild(aFracView);
                }
                aFracView.destroy();
            }
        }
        
        // Remove any number renderes still laying around
        while (m_numberRenderers.length > 0)
        {
            var aNumRenderer : NumberRenderer = m_numberRenderers.pop();
            if (aNumRenderer.parent != null)
            {
                aNumRenderer.parent.removeChild(aNumRenderer);
            }
            NumberRendererFactory.getInstance().recycleNumberRendererInstance(aNumRenderer);
        }
        
        // Remove any equation datas still laying around
        while (m_equationDatas.length > 0)
        {
            var anEquationData : EquationData = m_equationDatas.pop();
            anEquationData.reset();
        }
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the list of current displays.
		 */
    private function get_currentDisplays() : Array<DisplayObject>
    {
        return m_currentDisplays;
    }
    
    /**
		 * Returns the current time index of the animation.
		 */
    private function get_currentTime() : Float
    {
        var result : Float = -1;
        if (m_currentTimeline != null)
        {
            result = m_currentTimeline.position;
        }
        return result;
    }
    
    /**
		 * Returns whether or not this animation is paused.
		 */
    private function get_isPaused() : Bool
    {
        var result : Bool = true;
        if (m_currentTimeline != null)
        {
            result = m_currentTimeline.paused;
        }
        return result;
    }
    
    /**
		 * Returns the list of the details of each step tracked by this animation helper.
		 */
    private function get_stepDetailsList() : Array<Dynamic>
    {
        var result : Array<Dynamic> = new Array<Dynamic>();
        
        var aStepStartTime : Float = 0;
        for (aStep in m_steps)
        {
            // A step, for the purposes of this details list, is a name and a time index.
            if (doShowStep(aStep))
            {
                result.push({
                            name : aStep.name,
                            timeIndex : aStepStartTime
                        });
                aStepStartTime += aStep.duration;
            }
            else
            {
                aStepStartTime += (1 / 30);
            }
        }
        result.push({
                    name : "End",
                    timeIndex : totalTime
                });
        
        return result;
    }
    
    /**
		 * Returns the total time (aka. duration) of the animation.
		 */
    private function get_totalTime() : Float
    {
        return m_totalTime;
    }
    
    /**
		 * Returns the total time (aka. duration) of the animation.
		 */
    private function set_totalTime(value : Float) : Float
    {
        m_totalTime = value;
        return value;
    }
    
    private function get_endTime() : Float
    {
        return totalTime + END_BUFFER;
    }
    
    /**
		 * 
		 * Control
		 * 
		**/
    
    /**
		 * Creates the timeline, adds all the steps to the timeline, and begins the animation.
		 * @param	completeCallback - Required callback which will be called when completed. Note, this will not be called if looping or reflecting the animation.
		 * @param	positionStep
		 * @param	unpositionStep
		 */
    public function animate(completeCallback : Function, positionStep : AnimationStep = null, unpositionStep : AnimationStep = null) : Void
    {
        // Add or skip positioning step
        if (positionStep != null)
        {
            if (doShowPositioning())
            {
                // Add the positioning step to the animation
                m_steps.unshift(positionStep);
            }
            else
            {
                // Skip the positioning step by applything it immediately
                positionStep.applyStepImmediately();
            }
        }
        
        // Add or skip unpositioning step
        if (unpositionStep != null)
        {
            if (doShowPositioning())
            {
                // Add the unpositioning step to the animation
                m_steps.push(unpositionStep);
            }
            else
            {
                // Skip the unpositioning step by canceling it, so it never runs
                unpositionStep.cancelStep();
            }
        }
        
        // Adding a start step for all animations - for a little delay at the beginning
        var startStep : AnimationStep = new AnimationStep("Start", TIME_DELAY_START);
        m_steps.unshift(startStep);
        
        // Adding a complete step for all animations - for a little delay at the end
        var completeStep : AnimationStep = new AnimationStep("Complete", TIME_DELAY_COMPELTE);
        m_steps.push(completeStep);
        
        // Compute the total time
        computeTotalTime();
        
        // Create timeline
        m_currentTimeline = new GTweenTimeline(null, endTime + END_BUFFER, null, {
                    repeatCount : 0,
                    reflect : true
                });  // End Buffer added again so that GTweenTimeline end process does not run  
        
        // Add the contents of all the steps to the timeline
        var currentStepTime : Float = 1 / 30;
        for (aStep in m_steps)
        {
            if (doShowStep(aStep))
            {
                aStep.addToTimeline(m_currentTimeline, currentStepTime);
                currentStepTime += aStep.duration;
            }
            else
            {
                aStep.skipOnTimeline(m_currentTimeline, currentStepTime);
                currentStepTime += (1 / 30);
            }
        }
        
        // Add end callback
        m_currentTimeline.addCallback(endTime, onEnd, [completeCallback]);
    }
    
    /**
		 * Returns whether or not the given step is supposed to be shown, according to the animation step settings.
		 * @param	aStep
		 * @return
		 */
    private function doShowStep(aStep : AnimationStep) : Bool
    {
        var result : Bool = true;
        if (aStep != null && Reflect.hasField(m_animationStepSettings, aStep.stepType))
        {
            result = Reflect.field(m_animationStepSettings, Std.string(aStep.stepType));
        }
        return result;
    }
    
    /**
		 * Returns whether or not positioning steps should be shown.
		 * @return
		 */
    private function doShowPositioning() : Bool
    {
        var result : Bool = true;
        if (Reflect.hasField(m_details, CgsFVConstants.SHOW_POSITIONING_SETTING_KEY))
        {
            result = Reflect.field(m_details, Std.string(CgsFVConstants.SHOW_POSITIONING_SETTING_KEY));
        }
        return result;
    }
    
    private function onEnd(completeCallback : Function) : Void
    {
        var _sw0_ = (m_animController.endType);        

        switch (_sw0_)
        {
            case CgsFVConstants.END_TYPE_PAUSE:
                pause();
            case CgsFVConstants.END_TYPE_LOOP:
                jumpToTime(0);
                resume();
            case CgsFVConstants.END_TYPE_REFLECT, CgsFVConstants.END_TYPE_CLEAR:

            //TODO: check logic
//                switch (_sw0_)
//                {
//                    case CgsFVConstants.END_TYPE_REFLECT:
//                    // Do nothing, because we are already set to reflect
//                    break;
//                }
                pause();
                if (completeCallback != null)
                {
                    completeCallback();
                }
                else
                {
                    reset();
                }
            default:
        }
    }
    
    /**
		 * Computes the total time for the animation from the animations steps involved.
		 */
    private function computeTotalTime() : Void
    {
        var result : Float = 0;
        
        for (aStep in m_steps)
        {
            if (doShowStep(aStep))
            {
                result += aStep.duration;
            }
            else
            {
                result += (1 / 30);
            }
        }
        
        m_totalTime = result;
    }
    
    public static var UNIT_TIME : Float = 1.0 / 30.0;
    
    /**
		 * Jumps the currently running animation, if any, to the given time.
		 * @param	time
		 */
    public function jumpToTime(time : Float) : Void
    {
        if (m_currentTimeline != null)
        {
            // Ensure time is valid time
            time = Math.min(time, totalTime);
            time = Math.max(time, 0);
            
            // Compute the current time. Ensuring the current time is NOT the end time, otherwise we can get an endless loop.
            var currentTime : Float = m_currentTimeline.position;
            if (time < currentTime && currentTime >= endTime)
            {
                currentTime = endTime - UNIT_TIME;
            }
            
            // Step through every frame from the current time to the destination time.
            // This is to ensure all tweens are updated in the correct order.
            // The bug in GTween is, if there are two tweens that update the same value (ie. alpha)
            // and they are both updated by the jump in time, then only one (the one that starts closer to 0)
            // will be applied and the other one will not be applied.
            // This could be more efficient if we only did this over time sections that have this property.
            var timeDifference : Float = time - currentTime;
            var timeScale : Float = ((timeDifference < 0)) ? -1 : 1;
            var stepCount : Float = Math.abs(timeDifference / UNIT_TIME);
            for (i in 0...Std.int(stepCount))
            {
                var stepTime : Float = currentTime + (timeScale * (i * UNIT_TIME));
                m_currentTimeline.gotoAndStop(stepTime);
            }
            
            // GTWEEN-BUG-NOTE: When in REFLECT_ON_END and at least one reflection has occured, this will likely cause incorrect results.
            // GTweenTimeline.checkCallbacks() will call all callbacks when changing from one repeatIndex to another when reflect is on.
            // This means that, assuming the destination repeatIndex is less than the starting repeatIndex (most likely case),
            // all callbacks in the animation will be called in reverse, then forwards, then in reverse again to the position in question.
            // However, the tweens in between will NOT be run; only the callbacks are run. Therefore, changes made by all callbacks are applied
            // but no changes from the tweens will be applied in this process. This will likely cause incorrect displays.
            
            m_currentTimeline.gotoAndStop(time);
        }
    }
    
    /**
		 * Pauses the currently running animation, if any.
		 */
    public function pause() : Void
    {
        if (m_currentTimeline != null)
        {
            m_currentTimeline.paused = true;
        }
    }
    
    /**
		 * Resumes the currently running animation, if any.
		 */
    public function resume() : Void
    {
        if (m_currentTimeline != null)
        {
            if (currentTime >= totalTime && m_animController.endType != CgsFVConstants.END_TYPE_REFLECT)
            {
                jumpToTime(0);
                m_currentTimeline.paused = false;
            }
            else
            {
                m_currentTimeline.paused = false;
            }
        }
    }
    
    /**
		 * 
		 * Standardized Displays
		 * 
		**/
    
    /**
		 * Creates and returns a dashed line that starts and ends at the given values. startY MUST be less than endY.
		 * The resulting dashed line will be centered at 0 (that is, the middle of a gap will be at 0).
		 * @param	startY
		 * @param	endY
		 * @return
		 */
    public function createDashedLine(startY : Float, endY : Float) : Sprite
    {
        if (startY > endY)
        {
            return null;
        }
        
        // Create line
        var resultLine : Sprite = new Sprite();
        resultLine.graphics.lineStyle(GenConstants.DASHED_LINE_THICKNESS, GenConstants.DASHED_LINE_COLOR, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND);
        
        // Find the relative starting point, that is, the starting point of the first dashed line.
        // The resulting dashed line will be centered at 0 (that is, the middle of a gap will be at 0).
        // If the startY is less than 0, then we need to extrapolate back to find the start of what will be the first (likely partial) dashed line.
        // We will then start our dashed line at this point and iterate forward until we hit the end.
        var relativeStartY : Float = GenConstants.DASHED_LINE_DASH_SPACING / 2;
        while (relativeStartY > startY)
        {
            relativeStartY -= GenConstants.DASHED_LINE_DASH_SPACING + GenConstants.DASHED_LINE_DASH_LENGTH;
        }
        
        // Draw line - essentially looping over the number of dashed lines
        var currentY : Float = relativeStartY;
        while (currentY < endY)
        {
            // If the start of, or at least part of, this dash is to be drawn, draw it
            if (currentY > startY || currentY + GenConstants.DASHED_LINE_DASH_LENGTH > startY)
            {
                var currDashStartY : Float = Math.max(currentY, startY);  // Math.max in case only part of this dashed line is showing (starting dash)  
                var currDashEndY : Float = Math.min(currentY + GenConstants.DASHED_LINE_DASH_LENGTH, endY);  // Math.min in case only part of this dashed line is showing (ending dash)  
                
                // Draw on the line
                resultLine.graphics.moveTo(0, currDashStartY);
                resultLine.graphics.lineTo(0, currDashEndY);
            }
            
            currentY += GenConstants.DASHED_LINE_DASH_LENGTH + GenConstants.DASHED_LINE_DASH_SPACING;
        }
        resultLine.graphics.endFill();
        
        // Apply glow
        var lineGlow : GlowFilter = new GlowFilter(0xffffff, 0.8, 2.4, 2.4, 40);
        resultLine.filters = [lineGlow];
        
        // Track
        trackDisplay(resultLine);
        
        return resultLine;
    }
    
    /**
		 * Returns an Equation Data object containing the parts of the equation described.
		 * @param	parent
		 * @param	equationCenter
		 * @param	firstFraction
		 * @param	operationText
		 * @param	secondFraction
		 * @param	resultFraction
		 * @return
		 */
    public function createEquationData(parent : DisplayObjectContainer, equationCenter : Point, firstFraction : CgsFraction, operationText : String, secondFraction : CgsFraction, resultFraction : CgsFraction, textColor : Int, textGlowColor : Int, scale : Float = 1) : EquationData
    {
        var resultData : EquationData = new EquationData();
        
        // Show Equation Data
        resultData.firstValueNR = createNumberRenderer(firstFraction, textColor, textGlowColor);
        resultData.opSymbolText = createTextField(operationText, textColor, textGlowColor, GenConstants.DEFAULT_TEXT_FONT_SIZE);
        resultData.secondValueNR = createNumberRenderer(secondFraction, textColor, textGlowColor);
        resultData.equalsSymbolText = createTextField(" = ", textColor, textGlowColor, GenConstants.DEFAULT_TEXT_FONT_SIZE);
        resultData.resultValueNR = createNumberRenderer(resultFraction, textColor, textGlowColor);
        
        // Adjust scales or number renderers
        resultData.firstValueNR.numeratorScale = scale;
        resultData.firstValueNR.denominatorScale = scale;
        resultData.opSymbolText.scaleX = scale;
        resultData.opSymbolText.scaleY = scale;
        resultData.secondValueNR.numeratorScale = scale;
        resultData.secondValueNR.denominatorScale = scale;
        resultData.equalsSymbolText.scaleX = scale;
        resultData.equalsSymbolText.scaleY = scale;
        resultData.resultValueNR.numeratorScale = scale;
        resultData.resultValueNR.denominatorScale = scale;
        
        // Adjust locations
        resultData.equationCenter = equationCenter;
        
        // Visibility
        resultData.firstValueNR.visible = false;
        resultData.opSymbolText.visible = false;
        resultData.secondValueNR.visible = false;
        resultData.equalsSymbolText.visible = false;
        resultData.resultValueNR.visible = false;
        
        // Add to display list
        parent.addChild(resultData.firstValueNR);
        parent.addChild(resultData.opSymbolText);
        parent.addChild(resultData.secondValueNR);
        parent.addChild(resultData.equalsSymbolText);
        parent.addChild(resultData.resultValueNR);
        
        m_equationDatas.push(resultData);
        return resultData;
    }
    
    /**
		 * Creates and returns a mask (pink box) of the given width an height. The mask is automatically applied to
		 * the given target.
		 * @param	target
		 * @param	width
		 * @param	height
		 * @return
		 */
    public function createMask(target : DisplayObject, width : Float, height : Float) : Sprite
    {
        // Create mask
        var resultMask : Sprite = new Sprite();
        
        // Draw mask
        resultMask.graphics.beginFill(0xffaaff);
        resultMask.graphics.drawRect(-width / 2, -height / 2, width, height);
        resultMask.graphics.endFill();
        
        // Track
        trackDisplay(resultMask);
        if (target != null)
        {
            target.mask = resultMask;
        }
        return resultMask;
    }
    
    /**
		 * Returns a new standard Number Renderer initialized with the given fraction.
		 * @param	aFraction
		 * @return
		 */
    public function createNumberRenderer(aFraction : CgsFraction, textColor : Int, textGlowColor : Int) : NumberRenderer
    {
        var result : NumberRenderer = NumberRendererFactory.getInstance().getNumberRendererInstance();
        trackNumberRenderer(result);
        result.init(aFraction);
        result.setTextColor(textColor);
        result.lineColor = textColor;
        result.glowColor = textGlowColor;
        result.visible = true;
        result.alpha = 1;
        result.lineThickness = 2;
        result.showIntegerAsFraction = false;
        result.render();
        return result;
    }
    
    /**
		 * Returns a new standard Text Field initialized with the given text.
		 * @param	aText
		 * @return
		 */
    public function createTextField(aText : String, textColor : Int, textGlowColor : Int, fontSize : Int = -1) : TextField
    {
        if (fontSize < 0)
        {
            fontSize = GenConstants.DEFAULT_TEXT_FONT_SIZE;
        }
        
        var resultTextFormat : TextFormat = new TextFormat("Cabin", fontSize, textColor, true);
        var resultText : TextField = new TextField();
        resultText.embedFonts = true;
        resultText.defaultTextFormat = resultTextFormat;
        resultText.text = aText;
        resultText.width = resultText.textWidth + 3;
        resultText.height = resultText.textHeight + 3;
        resultText.selectable = false;
        resultText.border = false;
        resultText.background = false;
        resultText.multiline = false;
        resultText.autoSize = TextFieldAutoSize.CENTER;
        trackDisplay(resultText);
        return resultText;
    }
    
    /**
		 * 
		 * Tracking
		 * 
		**/
    
    /**
		 * 
		 * Displays - display children that will need to be removed when the animation ends
		 * 
		**/
    
    /**
		 * Adds the given display to the list of displays tracked within this helper.
		 * @param	value
		 */
    public function trackDisplay(value : DisplayObject) : Void
    {
        m_currentDisplays.push(value);
    }
    
    /**
		 * Removes the given display from tracking and removes it from the display list.
		 * @param	value
		 */
    public function removeTrackedDisplay(value : DisplayObject) : Void
    {
        if (Lambda.indexOf(m_currentDisplays, value) >= 0)
        {
            m_currentDisplays.splice(Lambda.indexOf(m_currentDisplays, value), 1);
            if (value.parent != null)
            {
                value.parent.removeChild(value);
            }
        }
    }
    
    /**
		 * 
		 * Fraction Views - fraction views that will need to be removed when the animation ends
		 * 
		**/
    
    /**
		 * Adds the given fraction view to the list of displays tracked within this helper.
		 * @param	value
		 */
    public function trackFractionView(value : CgsFractionView) : Void
    {
        value.registerForRenderer(m_renderer);
        m_fractionViews.push(value);
    }
    
    /**
		 * Removes the given fraction view from tracking and removes it from the display list.
		 * @param	value
		 */
    public function removeTrackedFractionView(value : CgsFractionView) : Void
    {
        if (Lambda.indexOf(m_fractionViews, value) >= 0)
        {
            m_fractionViews.splice(Lambda.indexOf(m_fractionViews, value), 1);
            value.visible = false;
            if (value.parent != null)
            {
                value.parent.removeChild(value);
            }
            value.destroy();
        }
    }
    
    /**
		 * 
		 * Number Renderes - number renderers views that will need to be removed when the animation ends
		 * 
		**/
    
    /**
		 * Adds the given number renderer to the list of displays tracked within this helper.
		 * @param	value
		 */
    public function trackNumberRenderer(value : NumberRenderer) : Void
    {
        m_numberRenderers.push(value);
    }
    
    /**
		 * Removes the given number renderer from tracking and removes it from the display list.
		 * @param	value
		 */
    public function removeTrackedNumberRenderer(value : NumberRenderer) : Void
    {
        if (Lambda.indexOf(m_numberRenderers, value) >= 0)
        {
            m_numberRenderers.splice(Lambda.indexOf(m_numberRenderers, value), 1);
            value.visible = false;
            if (value.parent != null)
            {
                value.parent.removeChild(value);
            }
            NumberRendererFactory.getInstance().recycleNumberRendererInstance(value);
        }
    }
    
    /**
		 * 
		 * Speed
		 * 
		**/
    
    /**
		 * Computes and returns the scaled result of the given time, uses the speed scaler provided by the caller of the animation.
		 * @param	time
		 * @return
		 */
    public function computeScaledTime(time : Float) : Float
    {
        var speedScaler : Float = (Reflect.hasField(m_details, CgsFVConstants.SPEED_SCALER_KEY)) ? Reflect.field(m_details, Std.string(CgsFVConstants.SPEED_SCALER_KEY)) : 1.0;
        var result : Float = time * speedScaler;
        return result;
    }
    
    /**
		 * 
		 * Steps
		 * 
		**/
    
    /**
		 * Adds the given step to the list of steps tracked within this helper.
		 * @param	value
		 */
    public function appendStep(value : AnimationStep) : Void
    {
        //if (value.name != GenConstants.STEP_NAME_POSITION && value.name != GenConstants.STEP_NAME_UNPOSITION)
        //{
        m_steps.push(value);
    }
}

