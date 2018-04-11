package cgs.engine.game;


/**
	 * Interface defining the functions of an Updatable Object.
	 * @author miller
	 */
interface IUpdatable
{

    /**
		 * Destorys this IUpdatable so that it will be garbage collected.
		 */
    function destroy() : Void
    ;
    
    /**
		 * Registers this IUpdatable with the given IUpdater.
		 * @param	updater The IUpdater to be registered with.
		 */
    function registerForUpdater(updater : IUpdater) : Void
    ;
    
    /**
		 * Update function. Use this function to execute functionality you need at a regular interval,
		 * or that needs to happen often.
		 * @param	deltaT Time since the last update loop.
		 * @param	data Data this IUpdatable may need.
		 */
    function update(deltaT : Float, data : Dynamic = null) : Void
    ;
}

