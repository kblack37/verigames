package cgs.engine.view;

import cgs.engine.game.CGSPriorityConstants;
import flash.display.Sprite;

/**
	 * Interface for Renderers - classes that execute a render loop.
	 * @author Rich
	 */
interface IRenderer
{
    
    /**
		 * Returns whether of not this Renderer is running.
		 */
    var isRunning(get, never) : Bool;    
    
    /**
		 * Sets the timestep of this Renderer to be the given value.
		 */
    
    
    /**
		 * Returns the timestep of this Renderer.
		 */
    var timestep(get, set) : Float;    
    
    /**
		 * Sets whether or not the timestep of this Renderer is in seconds or milliseconds to be the given value.
		 */
    
    
    /**
		 * Returns whether or not the timestep of this Renderer is in seconds or milliseconds.
		 */
    var timestepInSeconds(get, set) : Bool;

    
    /**
		 * Initializes the Renderer with the given Sprite.
		 * The timestep is an optional value to determine the timestep between updates. If the timestep
		 * is 0, the time since the last update is used as the timestep between updates. If the timestep is non-0, 
		 * x number of updates will be called each with the given timestep, where x = timeSinceLastUpdate / timestep.
		 * @param	main  The Sprite used to listen for ENTER_FRAME events.
		 * @param	timestep The set timestep between update calls.
		 * @param	timeInSeconds Whether or not the timestep of the Renderer is in seconds.
		 */
    function init(main : Sprite, timestep : Float = 0, timeInSeconds : Bool = false) : Void
    ;
    
    /**
		 * Adds the given object to the list of Rendering Objects at the given priority.
		 * @param	object The object to be added.
		 * @param	priority The priority of the object. Set to -1 by default, signifying lowest priority.
		 */
    function addRenderableObject(object : IRenderable, priority : Int = -1) : Void
    ;
    
    /**
		 * Removes the given object from the list of Rendering Objects, if it exists.
		 * @param	object The object to be removed.
		 */
    function removeRenderableObject(object : IRenderable) : Void
    ;
    
    /**
		 * After this call, the update() function for each IUpdatable will be called according to the specified delay.
		 */
    function start() : Void
    ;
    
    /**
		 * After this call, the update() function for each IUpdatable will no longer be called.
		 */
    function stop() : Void
    ;
}

