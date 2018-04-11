package cgs.engine.game;


/**
	 * Interface for Updaters - classes that execute an update loop.
	 * @author Rich
	 */
interface IUpdater
{
    
    /**
		 * Returns whether of not this updater is running.
		 */
    var isRunning(get, never) : Bool;    
    
    /**
		 * Sets the timestep of this Updater to be the given value.
		 */
    
    
    /**
		 * Returns the timestep of this Updater.
		 */
    var timestep(get, set) : Float;    
    
    /**
		 * Sets whether or not the timestep of this Updater is in seconds or milliseconds to be the given value.
		 */
    
    
    /**
		 * Returns whether or not the timestep of this Updater is in seconds or milliseconds.
		 */
    var timestepInSeconds(get, set) : Bool;

    
    /**
		 * Initializes this Updater with the given delay and timestep. The delay cannot be lower than 20 ms (due to
		 * restrictions in flash). Delays of less than 20 ms will be rounded up to 20 ms. The default is 100 ms.
		 * The timestep is an optional value to determine the timestep between updates. If the timestep
		 * is 0, the time since the last update is used as the timestep between updates. If the timestep is non-0, 
		 * x number of updates will be called each with the given timestep, where x = timeSinceLastUpdate / timestep.
		 * @param	delay The attempted number of milliseconds between update calls.
		 * @param	timestep The set timestep between update calls.
		 * @param	timeInSeconds Whether or not the timestep of the Updater is in seconds.
		 */
    function init(delay : Int = 100, timestep : Float = 0, timeInSeconds : Bool = false) : Void
    ;
    
    /**
		 * Adds the given object to the list of Updating Objects at the given priority.
		 * @param	object The object to be added.
		 * @param	priority The priority of the object. Set to -1 by default, signifying lowest priority.
		 */
    function addUpdatableObject(object : IUpdatable, priority : Int = -1) : Void
    ;
    
    /**
		 * Removes the given object from the list of Updating Objects, if it exists.
		 * @param	object The object to be removed.
		 */
    function removeUpdatableObject(object : IUpdatable) : Void
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

