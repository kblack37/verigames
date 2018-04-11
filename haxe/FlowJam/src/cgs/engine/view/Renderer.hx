package cgs.engine.view;

import cgs.engine.game.CGSPriorityConstants;
import openfl.events.Event;
import openfl.display.Sprite;
import cgs.engine.view.IRenderable;

/**
	 * A Renderer tracks IRenderable objects and calls the render function on each of 
	 * them at a specified frequency. 
	 * @author Alex Miller, Rich Snider
	 */
class Renderer implements IRenderer
{
    public var isRunning(get, never) : Bool;
    public var timestep(get, set) : Float;
    public var timestepInSeconds(get, set) : Bool;

    private static inline var MAX_STEPS_THRESHOLD : Int = 5;
    
    // State
    private var m_isStarted : Bool;
    private var m_lastTime : Float;
    private var m_lastStopTime : Float;
    private var m_main : Sprite;
    private var m_removeList : Array<IRenderable>;
    private var m_renderableBuckets : Array<BucketOfRenderables>;
    private var m_rendering : Bool = false;
    private var m_timestep : Float = 0;
    private var m_timestepInSeconds : Bool = false;
    
    public function new()
    {
        m_renderableBuckets = new Array<BucketOfRenderables>();
        var lowestBucket : BucketOfRenderables = new BucketOfRenderables(CGSPriorityConstants.PRIORITY_LOWEST);
        m_renderableBuckets.push(lowestBucket);
        m_removeList = new Array<IRenderable>();
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(main : Sprite, timestep : Float = 0, timeInSeconds : Bool = false) : Void
    {
        // Setup main
        if (m_main != null)
        {
            return;
        }
        m_main = main;
        
        // Setup timestep
        m_timestep = timestep;
        m_timestepInSeconds = timeInSeconds;
        
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
    public function addRenderableObject(object : IRenderable, priority : Int = -1) : Void
    {
        // Cannot have a negative priority, set it to be lowest priority by default.
        if (priority < 0)
        {
            priority = CGSPriorityConstants.PRIORITY_LOWEST;
        }
        
        // Loop through the buckets to find one with the correct priority, or create one if needed
        var i : Int = m_renderableBuckets.length;
        while (--i >= 0)
        {
            var bucket : BucketOfRenderables = m_renderableBuckets[i];
            // Found the right bucket, add the object
            if (bucket.priority == priority)
            {
                bucket.addRenderableObject(object);
                break;
            }
            else
            {
                // Went too far, that means we need to create a new bucket
				if (bucket.priority < priority)
                {
                    var newBucket : BucketOfRenderables = new BucketOfRenderables(priority);
                    newBucket.addRenderableObject(object);
                    as3hx.Compat.arraySplice(m_renderableBuckets, i + 1, 0, [newBucket]);
                    break;
                }
            }
        }
    }
    
    /**
		 * Removes the given object from the list of Rendering Objects, if it exists.
		 * @param	object The object to be removed.
		 */
    public function removeRenderableFromBuckets(object : IRenderable) : Void
    {
        // Loop through the buckets and remove that object from that bucket.
        var i : Int = m_renderableBuckets.length;
        while (--i >= 0)
        {
            m_renderableBuckets[i].removeRenderableObject(object);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeRenderableObject(object : IRenderable) : Void
    {
        if (m_rendering)
        {
            // Only add objects that are not already on the list
            if (Lambda.indexOf(m_removeList, object) < 0)
            {
                m_removeList.push(object);
            }
        }
        else
        {
            removeRenderableFromBuckets(object);
        }
    }
    
    /**
		 * Removes all the objects in the remove list from the list of Rendering Objects, if they exist.
		 */
    private function removeRenderablesOnRemoveList() : Void
    {
        // Make a clone of the list
        while (m_removeList.length > 0)
        {
            var object : IRenderable = m_removeList.pop();
            removeRenderableFromBuckets(object);
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
            m_main.addEventListener(Event.ENTER_FRAME, renderAll);
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
            m_main.removeEventListener(Event.ENTER_FRAME, renderAll);
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
		 * Render
		 * 
		**/
    
    /**
		 * Render all registered objects.
		 * @param	e
		 */
    private function renderAll(e : Event) : Void
    {
        if (!m_rendering)
        {
            m_rendering = true;
            
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
                    renderRegistered(tTimestep);
                    deltaT -= tTimestep;
                    ++steps;
                    
                    // Check for objects to be removed
                    removeRenderablesOnRemoveList();
                }
                // Update the last recorded time to account for left over milliseconds
                m_lastTime = presentTime - deltaT;
            }
            else
            {
                renderRegistered(deltaT);
                
                // Check for objects to be removed
                removeRenderablesOnRemoveList();
            }
            
            m_rendering = false;
        }
    }
    
    /**
		 * Calls the render function on all registered Renderable Objects, in order of priority.
		 * @param	e ENTER_FRAME Event.
		 */
    private function renderRegistered(timestep : Float) : Void
    {
        // Loop through the buckets and call renders of the IRenderables within.
        var i : Int = m_renderableBuckets.length;
        while (--i >= 0)
        {
            m_renderableBuckets[i].renderRegistered(timestep);
        }
    }
}




/**
 * A bucket of renderable objects, to be used exclusively by the Renderer for prioritization.
 */
class BucketOfRenderables
{
    public var priority(get, never) : Int;
    public var renderables(get, never) : Array<IRenderable>;

    // State
    private var m_renderableObjects : Array<IRenderable>;
    private var m_priority : Int;
    
    public function new(priority : Int = 0)
    {
        m_priority = priority;
        m_renderableObjects = new Array<IRenderable>();
    }
    
    /**
	 * Returns the priority of this bucket.
	 */
    private function get_priority() : Int
    {
        return m_priority;
    }
    
    private function get_renderables() : Array<IRenderable>
    {
        return m_renderableObjects;
    }
    
    /**
	 * Adds the given obj to the list of objects in this bucket.
	 * @param	obj The IRenderable object to be added.
	 */
    public function addRenderableObject(obj : IRenderable) : Void
    {
        m_renderableObjects.push(obj);
    }
    
    /**
	 * Removes all references to the given object in this bucket, if it exists at all.
	 * @param	obj The IRenderable object to be removed.
	 */
    public function removeRenderableObject(obj : IRenderable) : Void
    {
        while (Lambda.indexOf(m_renderableObjects, obj) >= 0)
        {
            var moo : Float = Lambda.indexOf(m_renderableObjects, obj);
            m_renderableObjects.splice(Lambda.indexOf(m_renderableObjects, obj), 1);
        }
    }
    
    /**
	 * Renders the IRenderables of this bucket using the given arguments.
	 * @param	deltaT Time since last render.
	 * @param	data Other data for the IRenderable.
	 */
    public function renderRegistered(deltaT : Float, data : Dynamic = null) : Void
    {
        // Call render on each IRenderable within this bucket
        var i : Int = m_renderableObjects.length;
        while (--i >= 0)
        {
            m_renderableObjects[i].render(deltaT, data);
        }
    }
}
