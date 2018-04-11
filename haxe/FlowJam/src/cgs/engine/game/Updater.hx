package cgs.engine.game;

import openfl.events.Event;
import openfl.display.Sprite;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import cgs.engine.game.IUpdatable;

/**
	 * An Updater tracks IUpdatable objects and calls the update function on each of 
	 * them at a specified frequency. 
	 * @author Alex Miller, Rich Snider
	 */
class Updater implements IUpdater
{
    public var isRunning(get, never) : Bool;
    public var timestep(get, set) : Float;
    public var timestepInSeconds(get, set) : Bool;

    private static inline var MAX_STEPS_THRESHOLD : Int = 5;
    
    // State
    private var m_delay : Int;
    private var m_isStarted : Bool;
    private var m_lastTime : Float;
    private var m_lastStopTime : Float;
    private var m_removeList : Array<IUpdatable>;
    private var m_timestep : Float = 0;
    private var m_timestepInSeconds : Bool = false;
    private var m_updatableBuckets : Array<BucketOfUpdatables>;
    private var m_updateTimer : Timer;
    private var m_updating : Bool = false;
    
    public function new()
    {
        m_updatableBuckets = new Array<BucketOfUpdatables>();
        var lowestBucket : BucketOfUpdatables = new BucketOfUpdatables(CGSPriorityConstants.PRIORITY_LOWEST);
        m_updatableBuckets.push(lowestBucket);
        m_removeList = new Array<IUpdatable>();
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(delay : Int = 100, timestep : Float = 0, timeInSeconds : Bool = false) : Void
    {
        // Setup delay
        m_delay = delay;
        
        // Setup timestep
        m_timestep = timestep;
        m_timestepInSeconds = timeInSeconds;
        
        // A delay below 20 ms is not recommended by flash, so lets not let it go below that.
        if (m_delay < 20)
        {
            m_delay = 20;
        }
        
        // Setup the delay timer
        m_updateTimer = new Timer(m_delay, 0);
        m_updateTimer.addEventListener(TimerEvent.TIMER, updateAll);
        
        // Setup time tracking
        m_lastTime = Math.round(haxe.Timer.stamp() * 1000);
        if (m_lastTime != 0 && !Math.isNaN(m_lastTime))
        {
            m_lastTime = m_lastTime / 1000;
        }
        m_lastStopTime = m_lastTime;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isRunning() : Bool
    {
        return m_isStarted;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_timestep() : Float
    {
        return m_timestep;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_timestep(value : Float) : Float
    {
        m_timestep = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_timestepInSeconds() : Bool
    {
        return m_timestepInSeconds;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_timestepInSeconds(value : Bool) : Bool
    {
        if (m_timestepInSeconds != value && !m_isStarted)
        {
            m_timestepInSeconds = value;
            
            // Adjust last time and time step
            if (m_timestepInSeconds)
            {
                m_timestep = m_timestep / 1000;
                m_lastTime = m_lastTime / 1000;
                m_lastStopTime = m_lastStopTime / 1000;
            }
            else
            {
                m_timestep = m_timestep * 1000;
                m_lastTime = m_lastTime * 1000;
                m_lastStopTime = m_lastStopTime * 1000;
            }
        }
        return value;
    }
    
    /**
		 * 
		 * Object Registration
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function addUpdatableObject(object : IUpdatable, priority : Int = -1) : Void
    {
        // Cannot have a negative priority, set it to be lowest priority by default.
        if (priority < 0)
        {
            priority = CGSPriorityConstants.PRIORITY_LOWEST;
        }
        
        // Loop through the buckets to find one with the correct priority, or create one if needed
        var i : Int = m_updatableBuckets.length;
        while (--i >= 0)
        {
            var bucket : BucketOfUpdatables = m_updatableBuckets[i];
            // Found the right bucket, add the object
            if (bucket.priority == priority)
            {
                bucket.addUpdatableObject(object);
                break;
            }
            else
            {
                // Went too far, that means we need to create a new bucket
				if (bucket.priority < priority)
                {
                    var newBucket : BucketOfUpdatables = new BucketOfUpdatables(priority);
                    newBucket.addUpdatableObject(object);
                    as3hx.Compat.arraySplice(m_updatableBuckets, i + 1, 0, [newBucket]);
                    break;
                }
            }
        }
    }
    
    /**
		 * Removes the given object from the list of Updating Objects, if it exists.
		 * @param	object The object to be removed.
		 */
    private function removeUpdatableFromBuckets(object : IUpdatable) : Void
    {
        // Loop through the buckets and remove that object from that bucket.
        var i : Int = m_updatableBuckets.length;
        while (--i >= 0)
        {
            m_updatableBuckets[i].removeUpdatableObject(object);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeUpdatableObject(object : IUpdatable) : Void
    {
        if (m_updating)
        {
            // Only add objects that are not already on the list
            if (Lambda.indexOf(m_removeList, object) < 0)
            {
                m_removeList.push(object);
            }
        }
        else
        {
            removeUpdatableFromBuckets(object);
        }
    }
    
    /**
		 * Removes all the objects in the remove list from the list of Updating Objects, if they exist.
		 */
    private function removeUpdatablesOnRemoveList() : Void
    {
        // Make a clone of the list
        while (m_removeList.length > 0)
        {
            var object : IUpdatable = m_removeList.pop();
            removeUpdatableFromBuckets(object);
        }
    }
    
    /**
		 * 
		 * Start and Stop
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function start() : Void
    {
        if (!m_isStarted)
        {
            m_updateTimer.start();
            m_isStarted = true;
            
            // Update last time counter to account for paused time.
            var newTime : Float = Math.round(haxe.Timer.stamp() * 1000);
            if (m_timestepInSeconds)
            {
                newTime = newTime / 1000;
            }
            var pausedTime : Int = as3hx.Compat.parseInt(newTime - m_lastStopTime);
            var deltaT : Int = as3hx.Compat.parseInt(newTime - m_lastTime);
            m_lastTime = newTime - deltaT + pausedTime;
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function stop() : Void
    {
        if (m_isStarted)
        {
            m_updateTimer.stop();
            m_isStarted = false;
            m_lastStopTime = Math.round(haxe.Timer.stamp() * 1000);
            if (m_timestepInSeconds)
            {
                m_lastStopTime = m_lastStopTime / 1000;
            }
        }
    }
    
    /**
		 * 
		 * Update
		 * 
		**/
    
    /**
		 * Update all registered objects.
		 * @param	e
		 */
    private function updateAll(e : TimerEvent) : Void
    {
        if (!m_updating)
        {
            m_updating = true;
            
            // Compute the time since the last update loop
            var presentTime : Float = Math.round(haxe.Timer.stamp() * 1000);
            if (m_timestepInSeconds)
            {
                presentTime = presentTime / 1000;
            }
            var deltaT : Float = presentTime - m_lastTime;
            m_lastTime = presentTime;
            
            // Compute the number of time steps since the last update
            if (m_timestep > 0)
            {
                var tTimestep : Float = m_timestep;  // In case the time step changes in the middle of the update  
                var steps : Int = 0;
                while (deltaT > tTimestep && steps < MAX_STEPS_THRESHOLD)
                {
                    //Update all objects with timeStep
                    updateRegistered(tTimestep);
                    deltaT -= tTimestep;
                    ++steps;
                    
                    // Check for objects to be removed
                    removeUpdatablesOnRemoveList();
                }
                // Update the last recorded time to account for left over milliseconds
                m_lastTime = presentTime - deltaT;
            }
            else
            {
                updateRegistered(deltaT);
                
                // Check for objects to be removed
                removeUpdatablesOnRemoveList();
            }
            
            m_updating = false;
        }
    }
    
    /**
		 * Calls the update function on all registered Updatable Objects, in order of priority.
		 * @param	e Timer Event.
		 */
    private function updateRegistered(timestep : Float) : Void
    {
        // Loop through the buckets and call updates of the IUpdatables within.
        var i : Int = m_updatableBuckets.length;
        while (--i >= 0)
        {
            m_updatableBuckets[i].updateRegistered(timestep);
        }
    }
}




/**
 * A bucket of updatable objects, to be used exclusively by the Updater for prioritization.
 */
class BucketOfUpdatables
{
    public var priority(get, never) : Int;

    // State
    private var m_updatableObjects : Array<IUpdatable>;
    private var m_priority : Int;
    
    public function new(priority : Int = 0)
    {
        m_priority = priority;
        m_updatableObjects = new Array<IUpdatable>();
    }
    
    /**
	 * Returns the priority of this bucket.
	 */
    private function get_priority() : Int
    {
        return m_priority;
    }
    
    /**
	 * Adds the given obj to the list of objects in this bucket.
	 * @param	obj The IUpdatable object to be added.
	 */
    public function addUpdatableObject(obj : IUpdatable) : Void
    {
        m_updatableObjects.push(obj);
    }
    
    /**
	 * Removes all references to the given object in this bucket, if it exists at all.
	 * @param	obj The IUpdatable object to be removed.
	 */
    public function removeUpdatableObject(obj : IUpdatable) : Void
    {
        while (Lambda.indexOf(m_updatableObjects, obj) >= 0)
        {
            m_updatableObjects.splice(Lambda.indexOf(m_updatableObjects, obj), 1);
        }
    }
    
    /**
	 * Updates the IUpdatables of this bucket using the given arguments.
	 * @param	deltaT Time since last update.
	 * @param	data Other data for the IUpdatable.
	 */
    public function updateRegistered(deltaT : Float, data : Dynamic = null) : Void
    {
        // Call update on each IUpdatable within this bucket
        var i : Int = m_updatableObjects.length;
        while (--i >= 0)
        {
            m_updatableObjects[i].update(deltaT, data);
        }
    }
}
