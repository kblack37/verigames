package cgs.engine.view;

import cgs.engine.game.CGSPriorityConstants;
import cgs.engine.game.IObservable;
import cgs.engine.game.IUpdatable;
import cgs.engine.game.IUpdater;
import cgs.engine.game.Updater;
import flash.display.Sprite;

/**
	 * A CGSSprite is the root of all objects that will be displayed to the screen.
	 * It updates, renders, and observes CGSObjects. A CGSSprite is intended to be the
	 * 'view' of a corresponding CGSObject, but this is not required. 
	 * 
	 * The CGSSprite is also setup to draw a pink box, by default, so that you can 
	 * see something drawn to the screen once the CGSSprite is created and registered 
	 * properly.
	 * @author Rich
	 */
class CGSSprite extends Sprite implements IUpdatable implements IRenderable implements IObserver
{
    private var priority(get, never) : Int;

    // Events
    private var m_registeredForEvents : Bool = false;
    
    // Render
    private var m_redraw : Bool = false;
    private var m_renderers : Array<IRenderer>;
    
    // Update
    private var m_updaters : Array<IUpdater>;
    
    public function new()
    {
        super();
        registerForEvents();
        m_updaters = new Array<IUpdater>();
        m_renderers = new Array<IRenderer>();
    }
    
    /**
		 * @inheritDoc
		 */
    public function destroy() : Void
    {
        while (m_renderers.length > 0)
        {
            m_renderers.pop().removeRenderableObject(this);
        }
        while (m_updaters.length > 0)
        {
            m_updaters.pop().removeUpdatableObject(this);
        }
        unregisterForEvents();
    }
    
    /**
		 *
		 * State
		 *
		**/
    
    /**
		 * Returns the priority of this Game Sprite.
		 */
    private function get_priority() : Int
    {
        return CGSPriorityConstants.PRIORITY_LOWEST;
    }
    
    /**
		 *
		 * Event Registration
		 *
		**/
    
    /**
		 * Registers this CGSSprite for events.
		 */
    private function registerForEvents() : Void
    {
        if (!m_registeredForEvents)
        {
            m_registeredForEvents = true;
        }
    }
    
    /**
		 * Unregisters this CGSSprite for events.
		 */
    private function unregisterForEvents() : Void
    {
        if (m_registeredForEvents)
        {
            m_registeredForEvents = false;
        }
    }
    
    /**
		 *
		 * Observation
		 *
		**/
    
    /**
		 * @inheritDoc
		 */
    public function observeChange(o : IObservable, argObject : Dynamic) : Void
    {  // To be filled in by extending class.  
        
    }
    
    /**
		 *
		 * Render
		 *
		**/
    
    /**
		 * Redraws this CGSSprite.
		 */
    private function doRedraw() : Void
    {  // To be filled in by extending class.  
        
    }
    
    /**
		 * Marks this CGSSprite for redraw.
		 * @param	force Whether or not the redraw should happen right away.
		 */
    public function redraw(force : Bool = false) : Void
    {
        m_redraw = !force;
        if (force)
        {
            doRedraw();
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function registerForRenderer(renderer : IRenderer) : Void
    {
        renderer.addRenderableObject(this, priority);
        m_renderers.push(renderer);
    }
    
    /**
		 * @inheritDoc
		 */
    public function render(deltaT : Float, data : Dynamic = null) : Void
    {
        // Redraw if needed
        if (m_redraw && visible)
        {
            doRedraw();
        }
        m_redraw = false;
    }
    
    /**
		 *
		 * Update
		 *
		**/
    
    /**
		 * @inheritDoc
		 */
    public function registerForUpdater(updater : IUpdater) : Void
    {
        updater.addUpdatableObject(this, priority);
        m_updaters.push(updater);
    }
    
    /**
		 * @inheritDoc
		 */
    public function update(deltaT : Float, data : Dynamic = null) : Void
    {
        // Register for events
        if (!m_registeredForEvents)
        {
            registerForEvents();
        }
    }
}

