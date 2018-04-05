package system;

import flash.events.Event;
import mx.core.UIComponent;
import mx.events.ResizeEvent;
import userInterface.*;

/**
	 * Wrapper function to apply to any generic game
	 */
class GenericSystem extends UIComponent
{
    /** Width the game was designed to use */
    private var m_nativeWidth : Int;
    
    /** Height the game was designed to use */
    private var m_nativeHeight : Int;
    
    /**
		 * Wrapper function to apply to any generic game
		 * @param	_width Desired width to display game at
		 * @param	_height Desired height to display game at
		 */
    public function new(_width : Int, _height : Int)
    {
        super();
        m_nativeWidth = _width;
        m_nativeHeight = _height;
        addEventListener(Event.ADDED_TO_STAGE, initResize);
        var initResize : Event->Void = function(e : Event) : Void
        {
            resize(new ResizeEvent("start"));
            parent.addEventListener(ResizeEvent.RESIZE, resize);
            removeEventListener(Event.ADDED_TO_STAGE, initResize);
        }
    }
    
    /**
		 * Initializes the game
		 * @param	gameName Name of game class to initialize
		 */
    public function start(gameName : Class<Dynamic>) : Void
    {
        var game : Game = try cast(Type.createInstance(gameName, [0, 0, m_nativeWidth, m_nativeHeight]), Game) catch(e:Dynamic) null;
        addChild(game);
        game.init();
    }
    
    /**
		 * Function to resize the game to the new desired dimensions
		 * @param	e Associated ResizeEvent
		 */
    public function resize(e : ResizeEvent) : Void
    {
        var hScale : Float = parent.width / m_nativeWidth;
        var vScale : Float = parent.height / m_nativeHeight;
        
        var scale : Float = Math.min(hScale, vScale);
    }
}
