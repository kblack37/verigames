package replay;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.geom.ColorTransform;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import cgs.server.logging.actions.ClientAction;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Dictionary;
import utilities.XSprite;
import flash.display.Bitmap;
import userInterface.components.BitmapButton;

class ReplayTimeline extends Sprite
{
    private var TICK_COLOR(default, never) : Int = 0x0000FF;
    private var TICK_NOSKIP_COLOR(default, never) : Int = 0xFF00FF;
    private var TICK_HIGHLIGHT_COLOR(default, never) : Int = 0x5555FF;
    
    private var TICK_CURRENT_NOPLAY_COLOR(default, never) : Int = 0xFF0000;
    private var TICK_CURRENT_PLAY_COLOR(default, never) : Int = 0x00FF00;
    
    private var m_timelineBack : Sprite;
    private var m_timelineTicks : Dictionary;
    private var m_timelineCurrent : Sprite;
    private var m_timelineTooltip : TextField;
    
    private var m_currentActionIndex : Int;
    private var m_maxActionIndex : Int;
    private var m_positionStepScale : Float;
    private var m_play : Bool;
    private var m_stepToIndex : Dictionary;
    
    private var m_toIndexCallback : Function;
    
    @:meta(Embed(source="../../lib/assets/run.png"))

    public var RunImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/stop.png"))

    private var StopImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/pause.png"))

    private var PauseImageClass : Class<Dynamic>;
    private var run_button : BitmapButton;
    private var pause_button : BitmapButton;
    private var stop_button : BitmapButton;
    
    public function new(actionObjects : Array<ClientAction>, skipCallback : Function, toIndexCallback : Function, desiredWidth : Float, y_pos : Float)
    {
        super();
        desiredWidth -= 100;
        x = 10;
        y = y_pos;
        m_maxActionIndex = as3hx.Compat.parseInt(actionObjects.length - 1);
        m_positionStepScale = desiredWidth / m_maxActionIndex;
        
        m_timelineBack = new Sprite();
        m_timelineBack.graphics.clear();
        
        m_timelineBack.graphics.beginFill(0xFFFFFF);
        m_timelineBack.graphics.drawRect(-3, -8, desiredWidth + 6, 16);
        m_timelineBack.graphics.endFill();
        
        m_timelineBack.graphics.lineStyle(3, 0x000000);
        m_timelineBack.graphics.moveTo(0.0, 0.0);
        m_timelineBack.graphics.lineTo(desiredWidth, 0.0);
        
        m_timelineBack.addEventListener(MouseEvent.ROLL_OVER, onLineMouseOver);
        m_timelineBack.addEventListener(MouseEvent.ROLL_OUT, onLineMouseOut);
        m_timelineBack.addEventListener(MouseEvent.MOUSE_MOVE, onLineMouseMove);
        addChild(m_timelineBack);
        
        var textFormat : TextFormat = new TextFormat();
        
        m_timelineTooltip = new TextField();
        m_timelineTooltip.defaultTextFormat = textFormat;
        m_timelineTooltip.antiAliasType = AntiAliasType.ADVANCED;
        
        m_timelineTooltip.selectable = false;
        m_timelineTooltip.background = true;
        m_timelineTooltip.autoSize = TextFieldAutoSize.CENTER;
        m_timelineTooltip.y = -30;
        m_timelineTooltip.text = "--";
        m_timelineTooltip.visible = false;
        addChild(m_timelineTooltip);
        
        m_stepToIndex = new Dictionary();
        var skips : Dictionary = new Dictionary();
        for (ii in 0...actionObjects.length)
        {
            var obj : ClientAction = actionObjects[ii];
            var thisStep : Int = ii;
            var thisSkip : Int = skipCallback(obj);
            
            if (thisSkip == 0 || skips[thisStep] == null)
            {
                skips[thisStep] = thisSkip;
                m_stepToIndex[thisStep] = ii;
            }
        }
        
        m_timelineTicks = new Dictionary();
        for (stepStr in Reflect.fields(skips))
        {
            var step : Int = as3hx.Compat.parseInt(stepStr);
            var index : Int = Reflect.field(m_stepToIndex, stepStr);
            var skip : Bool = Reflect.field(skips, stepStr);
            
            var tick : Sprite = new Sprite();
            tick.graphics.lineStyle(3, 0xFFFFFF);
            tick.graphics.moveTo(0, -5.0);
            tick.graphics.lineTo(0, 5.0);
            tick.x = m_positionStepScale * step;
            applyColorTransform(tick, (skip) ? TICK_COLOR : TICK_NOSKIP_COLOR);
            m_timelineBack.addChild(tick);
            
            tick.addEventListener(MouseEvent.ROLL_OVER, onTickMouseOver);
            tick.addEventListener(MouseEvent.ROLL_OUT, eventCallbackWrapper(onTickMouseOut, skip));
            tick.addEventListener(MouseEvent.MOUSE_MOVE, onLineMouseMove);
            tick.addEventListener(MouseEvent.MOUSE_DOWN, eventCallbackWrapper(onTickMouseDown, index));
        }
        
        m_timelineCurrent = new Sprite();
        m_timelineCurrent.graphics.lineStyle(3, 0xFFFFFF);
        m_timelineCurrent.graphics.moveTo(0, -2.0);
        m_timelineCurrent.graphics.lineTo(0, 2.0);
        applyColorTransform(m_timelineCurrent, (m_play) ? TICK_CURRENT_PLAY_COLOR : TICK_CURRENT_NOPLAY_COLOR);
        m_timelineBack.addChild(m_timelineCurrent);
        
        m_timelineCurrent.addEventListener(MouseEvent.MOUSE_MOVE, onLineMouseMove);
        
        m_toIndexCallback = toIndexCallback;
        
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        
        var run_button_image : Bitmap = Type.createInstance(RunImageClass, []);
        run_button = new BitmapButton(10, -5, 20, 20, run_button_image, run_button_image, onControlClick);
        run_button.name = "run_button";
        m_timelineBack.addChild(run_button);
        
        var pause_button_image : Bitmap = Type.createInstance(PauseImageClass, []);
        pause_button = new BitmapButton(25, -5, 20, 20, pause_button_image, pause_button_image, onControlClick);
        pause_button.name = "pause_button";
        m_timelineBack.addChild(pause_button);
        
        var stop_button_image : Bitmap = Type.createInstance(StopImageClass, []);
        stop_button = new BitmapButton(40, -5, 20, 20, stop_button_image, stop_button_image, onControlClick);
        stop_button.name = "stop_button";
        m_timelineBack.addChild(stop_button);
    }
    
    public function playToggle() : Void
    {
        m_play = !m_play;
        applyColorTransform(m_timelineCurrent, (m_play) ? TICK_CURRENT_PLAY_COLOR : TICK_CURRENT_NOPLAY_COLOR);
    }
    
    public function toStep(step : Int) : Void
    {
        m_currentActionIndex = step;
        m_timelineCurrent.x = m_positionStepScale * m_currentActionIndex;
    }
    
    private function onEnterFrame(ev : Event) : Void
    {
        if (m_play)
        {
            if (m_currentActionIndex == m_maxActionIndex)
            {
                m_play = false;
                applyColorTransform(m_timelineCurrent, (m_play) ? TICK_CURRENT_PLAY_COLOR : TICK_CURRENT_NOPLAY_COLOR);
            }
            else
            {
                ++m_currentActionIndex;
                if (m_stepToIndex[m_currentActionIndex] != null)
                {
                    m_toIndexCallback(m_stepToIndex[m_currentActionIndex]);
                }
                m_timelineCurrent.x = m_positionStepScale * m_currentActionIndex;
            }
        }
    }
    
    private function onLineMouseOver(ev : MouseEvent) : Void
    {
        m_timelineTooltip.visible = true;
    }
    
    private function onLineMouseOut(ev : MouseEvent) : Void
    {
        m_timelineTooltip.visible = false;
    }
    
    private function onLineMouseMove(ev : MouseEvent) : Void
    {
        var localPt : Point = globalToLocal(new Point(ev.stageX, ev.stageY));
        var step : Int = clampInt(localPt.x / m_positionStepScale, 0, m_maxActionIndex);
        m_timelineTooltip.text = Std.string(step);
        m_timelineTooltip.x = m_positionStepScale * step - m_timelineTooltip.width / 2.0;
    }
    
    private function onTickMouseDown(ev : MouseEvent, index : Int) : Void
    {
        m_toIndexCallback(index);
    }
    
    private function onTickMouseOver(ev : MouseEvent) : Void
    {
        applyColorTransform(try cast(ev.target, Sprite) catch(e:Dynamic) null, TICK_HIGHLIGHT_COLOR);
    }
    
    private function onTickMouseOut(ev : MouseEvent, skip : Bool) : Void
    {
        applyColorTransform(try cast(ev.target, Sprite) catch(e:Dynamic) null, (skip) ? TICK_COLOR : TICK_NOSKIP_COLOR);
    }
    
    /**
		 * Help functions:
		 */
    
    public static function applyColorTransform(obj : DisplayObject, color : Int) : Void
    {
        var trans : ColorTransform = obj.transform.colorTransform;
        trans.redMultiplier = XSprite.extractRed(color) / 255.0;
        trans.greenMultiplier = XSprite.extractGreen(color) / 255.0;
        trans.blueMultiplier = XSprite.extractBlue(color) / 255.0;
        obj.transform.colorTransform = trans;
    }
    
    public static function eventCallbackWrapper(func : Function, arg : Dynamic) : Function
    {
        return function(ev : Event) : Void
        {
            Reflect.callMethod(null, func, [ev, arg]);
        };
    }
    
    /**
		 * Clamp an int value to lie in a given range.
		 * @param x Value to clamp.
		 * @param lo Lowest possible value.
		 * @param hi Highest possible value.
		 * @return Clamped value, will be in the range [lo, hi].
		 */
    public static function clampInt(x : Int, lo : Int, hi : Int) : Int
    {
        return ((x < lo) ? lo : ((x > hi) ? hi : x));
    }
    
    public function onControlClick(e : MouseEvent) : Void
    {  //m_gameScene.backToMainMenu();  
        
    }
}

