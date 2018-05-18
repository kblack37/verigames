package;

import engine.GameEngine;
import events.NavigationEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import starling.core.Starling;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
 * The static entry point for FlowJam
 * 
 * @author 
 */
class Main extends Sprite 
{

	private var m_starling : Starling;
	
	public function new() 
	{
		super();
		
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(e : Dynamic) {
		this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		initialize();
	}
	
	private function initialize() {
		m_starling = new Starling(GameEngine, stage);
		
		// set up the main controller
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
		
		// mostly just an annoyance in desktop mode, so turn off
		m_starling.simulateMultitouch = false;
        m_starling.enableErrorChecking = false;
        m_starling.start();
		
		// this event is dispatched when stage3D is set up
        m_starling.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated);
        
        stage.addEventListener(Event.RESIZE, updateSize);
        stage.dispatchEvent(new Event(Event.RESIZE));
		
		// Dispatch a navigation event to the splash screen
		//m_starling.root.dispatchEvent(new Event(NavigationEvent.CHANGE_SCREEN, SplashScreenState));
	}
	
	private function onContextCreated(event : flash.events.Event) : Void
    {
        // set framerate to 30 in software mode
        if (Starling.current.context.driverInfo.toLowerCase().indexOf("software") != -1)
        {
            Starling.current.nativeStage.frameRate = 30;
        }
    }
	
	public function updateSize(e : flash.events.Event) : Void
    {
        // Compute max view port size
        var fullViewPort : Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        var DES_WIDTH : Float = Constants.GameWidth;
        var DES_HEIGHT : Float = Constants.GameHeight;
        var scaleFactor : Float = Math.min(stage.stageWidth / DES_WIDTH, stage.stageHeight / DES_HEIGHT);
        
        // Compute ideal view port
		var idealWidth : Float = scaleFactor * DES_WIDTH;
		var idealHeight : Float = scaleFactor * DES_HEIGHT;
        var viewPort : Rectangle = new Rectangle(0.5 * (stage.stageWidth - idealWidth),  0.5 * (stage.stageHeight - idealHeight), idealWidth, idealHeight);
        
        // Ensure the ideal view port is not larger than the max view port (could cause a crash otherwise)
        viewPort = viewPort.intersection(fullViewPort);
        
        // Set the updated view port
        Starling.current.viewPort = viewPort;
    }
}
