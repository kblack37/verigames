package cgs.logotos;

import haxe.Constraints.Function;
import cgs.server.logging.ICgsServerApi;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

/**
	 * Class used to display the standard CGS Logo and (optionally) a Terms of Sevice acceptance page afterwards
	 * before the game is loaded.
	 * 
	 * Sample usage:
	 * 
	 * <code>
	 * public class MyGame extends Sprite
	 * 
	 * 	private var m_logo:CGSLogoTOS;
	 * 
	 * 	public function MyGame() {
	 *		var custom_background:MovieClip = new MovieClip();
	 * 		m_logo = new CGSLogoTOS(onCGSLogoUnload, "My Game Name", 800, 600, true, custom_background);
	 *		addChild(m_logo);
	 *		m_logo.load();
	 * 		
	 * 		var my_game_props:CGSServerProps = new CGSServerProps(
	 *				MyGameServerConstants.SKEY,
	 *				IGameServerData.NO_SKEY_HASH,
	 *				MyGameServerConstants.GAME_NAME,
	 *				MyGameServerConstants.GAME_ID,
	 *				MyGameServerConstants.VERSION,
	 *				MyGameServerConstants.CATEGORY,
	 *				MyGameServerConstants.CGS_SERVER_URL
	 *				);
	 * 		CGSServer.initialize(my_game_props, true, onServerInit);
	 * 	}
	 * 
	 * 	private function onServerInit(failed:Boolean):void {
	 * 		if (!failed) {
	 * 			m_logo.onServerInit(CGSServer.instance);
	 * 		}
	 * 	}
	 * 
	 * 	private function onCGSLogoUnload():void {
	 * 		removeChild(m_logo);
	 * 		startMyGame();
	 * 	}
	 * </code>
	 * 
	 * @author pavlik
	 * 
	 */
class CGSLogoTOS extends Sprite
{
    private var includeTos(get, never) : Bool;

    public static var SERVER_TIMEOUT_DELAY_MS : Float = 10000.0;
    public static var ALLOW_SKIP_AHEAD : Bool = false;
    private static inline var STOP_FRAME : Int = 151;
    private static inline var END_FRAME : Int = 174;
    private var m_callback : Function;
    private var m_game_name : String;
    private var m_width : Float;
    private var m_height : Float;
    private var m_tos_terms : String;
    private var m_tos_handled : Bool;
    private var m_logo : MovieClip;
    private var m_tos : CGSTos;
    private var m_server_timeout_timer : Timer;
    private var m_cgs_server_instance : ICgsServerApi;
    private var m_stopped : Bool = false;
    private var m_unloaded : Bool = false;
    private var m_custom_background : DisplayObject;
    
    /**
		 * Intro screen to display the CGS animated logo. Also displays a Terms of Service acceptance page after the logo, if desired. 
		 * @param _callback Function to callback when animated logo has finished playing (or after Terms of Service are shown, if desired)
		 * @param _width Desired width of CGS logo and Terms of Service UI
		 * @param _height Desired height of CGS logo and Terms of Service UI
		 * @param _include_TOS True to show a Terms of Service acceptance UI after the logo animation
		 * @param _custom_background A game-specific background to be used with Terms of Service if _include_TOS is True
		 * 
		 */
    public function new(_callback : Function, _game_name : String,
            _width : Float = 800, _height : Float = 600, _tos_terms : String = null, _custom_background : DisplayObject = null)
    {
        super();
        m_callback = _callback;
        m_game_name = _game_name;
        m_width = _width;
        m_height = _height;
        m_tos_terms = _tos_terms;
        m_custom_background = _custom_background;
        graphics.clear();
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, m_width, m_height);
    }
    
    //Indicates if tos terms should be shown after the logo.
    private function get_includeTos() : Bool
    {
        return m_tos_terms != null;
    }
    
    /**
		 * Function called to load and begin playing the logo (and Terms of Service if specified) 
		 * 
		 */
    public function load() : Void
    {
        if (ALLOW_SKIP_AHEAD)
        {
            addEventListener(MouseEvent.CLICK, skipAhead);
        }
        m_logo = new ArtCGSAnimatedLogo();
        m_logo.x = 0.5 * m_width;
        m_logo.y = 0.5 * m_height;
        m_logo.addFrameScript(STOP_FRAME, checkServerStatus);
        m_logo.addFrameScript(END_FRAME, onEnd);
        m_logo.addFrameScript(m_logo.totalFrames - 1, onEnd);
        addChild(m_logo);
        m_logo.gotoAndPlay("Start");
    }
    
    private function onEnd() : Void
    {
        unload();
    }
    
    private function skipAhead(e : MouseEvent) : Void
    {
        if (m_logo != null && (m_logo.currentFrame < STOP_FRAME))
        {
            checkServerStatus();
            if (!m_stopped)
            {
                m_logo.gotoAndPlay("Fade");
            }
        }
    }
    
    private function checkServerStatus() : Void
    {
        if (includeTos && (m_cgs_server_instance == null) && !m_stopped)
        {
            m_logo.gotoAndStop("Fade");
            m_stopped = true;
            m_server_timeout_timer = new Timer(SERVER_TIMEOUT_DELAY_MS, 1);
            m_server_timeout_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onServerTimeout);
            m_server_timeout_timer.start();
        }
    }
    
    private function onServerTimeout(e : TimerEvent) : Void
    {
        m_server_timeout_timer.stop();
        m_server_timeout_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onServerTimeout);
        forceUnload();
    }
    
    /**
		 * This must be called once the server instance has been initialized in order to setup Terms of Service
		 * logging. If Terms of Service are not used, this function does not need to be called. 
		 * @param _cgs_server_instance Instance of initialized CGSServer object to be used for TOS logging
		 * 
		 */
    public function onServerInit(_cgs_server_instance : ICgsServerApi) : Void
    {
        m_cgs_server_instance = _cgs_server_instance;
        m_tos_handled = m_cgs_server_instance.tosResponseExists;
        if (m_logo != null && m_stopped)
        {
            m_stopped = false;
            m_logo.gotoAndPlay("Fade");
        }
    }
    
    /**
		 * Used to abort animation and immediately remove UI from stage, proceed to TOS if specified
		 * 
		 */
    public function forceUnload() : Void
    {
        if (!m_unloaded)
        {
            unload();
        }
    }
    
    private function unload() : Void
    {
        m_unloaded = true;
        m_logo.stop();
        graphics.clear();
        if (ALLOW_SKIP_AHEAD)
        {
            removeEventListener(MouseEvent.CLICK, skipAhead);
        }
        while (numChildren > 0)
        {
            var child : DisplayObject = getChildAt(0);
            removeChild(child);
        }
        if (m_tos_terms != null && m_cgs_server_instance != null && !m_tos_handled)
        {
            if (m_custom_background != null)
            {
                addChild(m_custom_background);
            }
            else
            {
                m_logo.gotoAndStop("Fade");
                m_logo.alpha = 0.6;
                addChild(m_logo);
            }
            m_tos = new CGSTos(m_cgs_server_instance, onTOSComplete, m_game_name, m_tos_terms, m_width, m_height);
            addChild(m_tos);
            m_tos.load();
        }
        else
        {
            m_callback();
        }
    }
    
    private function onTOSComplete() : Void
    {
        while (numChildren > 0)
        {
            var child : DisplayObject = getChildAt(0);
            removeChild(child);
            child = null;
        }
        m_custom_background = null;
        m_tos = null;
        m_callback();
    }
}

