package gameScenes;

import userInterface.components.*;
import flash.display.*;
import flash.events.MouseEvent;
import mx.core.UIComponent;

class TrafficJamSplashScreenScene extends GameScene
{
    
    /** Pipe Jam title screen */
    private var splash_image : Bitmap;
    
    /** Start button image */
    private var start_button : RectangularObject;
    
    
    /** Mouseover 'Start' button image */
    private var start_click_bmp : Bitmap;
    
    /** Mouseover 'Tutorial' button image */
    private var tutorial_click_bmp : Bitmap;
    
    /** Non-mouseover 'Start' button image */
    private var start_bmp : Bitmap;
    
    /** Non-mouseover 'Tutorial' button image */
    private var tutorial_bmp : Bitmap;
    
    /** Start button image */
    private var start_tutorial_button : RectangularObject;
    
    @:meta(Embed(source="../../lib/assets/TrafficSplashScreen.png"))

    private var TrafficJamTitlescreenImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/TrafficStartButtonUp.png"))

    private var StartButtonTrafficImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/TrafficStartButtonOver.png"))

    private var StartButtonTrafficClickImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/TutorialButtonUp.png"))

    private var TutorialButtonTrafficImageClass : Class<Dynamic>;
    
    @:meta(Embed(source="../../lib/assets/TutorialButtonOver.png"))

    private var TutorialButtonTrafficClickImageClass : Class<Dynamic>;
    
    public function new(controller : SceneController)
    {
        super(controller);
    }
    
    override public function loadScene() : Void
    {
        splash_image = Type.createInstance(TrafficJamTitlescreenImageClass, []);
        splash_image.x = 0;
        splash_image.y = 0;
        splash_image.width = 1024;
        splash_image.height = 768;
        
        start_bmp = Type.createInstance(StartButtonTrafficImageClass, []);
        start_button = new RectangularObject(0.5 * (1024 - start_bmp.width), 550, start_bmp.width, start_bmp.height);
        start_button.addChild(start_bmp);
        start_button.buttonMode = true;
        start_button.addEventListener(MouseEvent.CLICK, startClick);
        start_button.addEventListener(MouseEvent.ROLL_OVER, startRollover);
        start_button.addEventListener(MouseEvent.ROLL_OUT, startRollout);
        start_click_bmp = Type.createInstance(StartButtonTrafficClickImageClass, []);
        
        tutorial_bmp = Type.createInstance(TutorialButtonTrafficImageClass, []);
        start_tutorial_button = new RectangularObject(0.5 * (1024 - start_bmp.width), 650, tutorial_bmp.width, tutorial_bmp.height);
        start_tutorial_button.addChild(tutorial_bmp);
        start_tutorial_button.buttonMode = true;
        start_tutorial_button.addEventListener(MouseEvent.CLICK, startTutorialClick);
        start_tutorial_button.addEventListener(MouseEvent.ROLL_OVER, startTutorialRollover);
        start_tutorial_button.addEventListener(MouseEvent.ROLL_OUT, startTutorialRollout);
        tutorial_click_bmp = Type.createInstance(TutorialButtonTrafficClickImageClass, []);
    }
    
    override public function draw() : Void
    //		removeChildren();
    {
        
        addChild(splash_image);
        addChild(start_button);
        addChild(start_tutorial_button);
    }
    /**
		 * Called by clicking the start button, starts the game
		 * @param	e Associated mouseEvent
		 */
    public function startClick(e : MouseEvent) : Void
    {
        (try cast(m_controller, TrafficJamSceneController) catch(e:Dynamic) null).nextWorldIsFullView = false;
        loadNextScene(TrafficJamSceneController.LOAD_GAME);
    }
    
    /**
		 * Called by mousing over start button, adds highlighted start image.
		 * @param	e
		 */
    public function startRollover(e : MouseEvent) : Void
    {
        if (start_bmp.parent == start_button)
        {
            start_button.removeChild(start_bmp);
        }
        start_button.addChild(start_click_bmp);
    }
    
    /**
		 * Called by mousing out start button, adds non-highlighted start image.
		 * @param	e
		 */
    public function startRollout(e : MouseEvent) : Void
    {
        if (start_click_bmp.parent == start_button)
        {
            start_button.removeChild(start_click_bmp);
        }
        start_button.addChild(start_bmp);
    }
    
    /**
		 * Called by clicking the start button, removes title screen and starts the tutorial
		 * @param	e Associated mouseEvent
		 */
    public function startTutorialClick(e : MouseEvent) : Void
    {
        (try cast(m_controller, TrafficJamSceneController) catch(e:Dynamic) null).nextWorldIsFullView = true;
        loadNextScene(TrafficJamSceneController.LOAD_TUTORIAL);
    }
    
    /**
		 * Called by mousing over start button, adds highlighted start image.
		 * @param	e
		 */
    public function startTutorialRollover(e : MouseEvent) : Void
    {
        if (tutorial_click_bmp.parent == start_tutorial_button)
        {
            start_tutorial_button.removeChild(tutorial_click_bmp);
        }
        start_tutorial_button.addChild(tutorial_click_bmp);
    }
    
    /**
		 * Called by mousing out start button, adds non-highlighted start image.
		 * @param	e
		 */
    public function startTutorialRollout(e : MouseEvent) : Void
    {
        if (tutorial_bmp.parent == start_tutorial_button)
        {
            start_tutorial_button.removeChild(tutorial_bmp);
        }
        start_tutorial_button.addChild(tutorial_bmp);
    }
    
    //called by controller when scene is being unloaded
    override public function unloadScene() : Void
    {
        start_button.removeEventListener(MouseEvent.CLICK, startClick);
        start_button.removeEventListener(MouseEvent.ROLL_OVER, startRollover);
        start_button.removeEventListener(MouseEvent.ROLL_OUT, startRollout);
        
        start_tutorial_button.removeEventListener(MouseEvent.CLICK, startTutorialClick);
        start_tutorial_button.removeEventListener(MouseEvent.ROLL_OVER, startTutorialRollover);
        start_tutorial_button.removeEventListener(MouseEvent.ROLL_OUT, startTutorialRollout);
    }
}
