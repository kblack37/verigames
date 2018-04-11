package cgs.engine.game;

import cgs.engine.view.IObserver;

/**
	 * A base class for updatable objects in a game. Supports the "Observable"
	 * pattern. Observer objects can be added to the GameObject. When notifyObservers()
	 * is called, the Observers which have been added will update their state.
	 * 
	 * More info on the observer pattern: http://en.wikipedia.org/wiki/Observer_pattern
	 * 
	 * Example:
	 * 
	 *	var myGameObject:GameObject = new GameObject();
	 * 
	 *	// assuming you have written a CustomObserver class that implements Observer
	 *	// this will usually be a "view" class, such as a game Sprite
	 *	var myObserver:Observer = new CustomObserver();
	 * 
	 *	myGameObject.addObserver(myObserver);
	 * 
	 *	// now subsequent calls by myGameObject to notifyObservers() will in turn call
	 *	// myObserver.render().
	 * @author Alex
	 */
class CGSObject implements IUpdatable implements IObservable
{
    private var priority(get, never) : Int;

    // Observers
    private var m_observers : Array<IObserver>;
    
    // Update
    private var m_updaters : Array<IUpdater>;
    
    public function new()
    {
        m_observers = new Array<IObserver>();
        m_updaters = new Array<IUpdater>();
    }
    
    /**
		 * @inheritDoc
		 */
    public function destroy() : Void
    {
        while (m_updaters.length > 0)
        {
            m_updaters.pop().removeUpdatableObject(this);
        }
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
		 * Observer Management
		 *
		**/
    
    /**
		 * Adds the passed observer to the list of observers.
		 * @param	observer The Observer to be added.
		 */
    public function addObserver(observer : IObserver) : Void
    {
        if (Lambda.indexOf(m_observers, observer) < 0)
        {
            m_observers.push(observer);
        }
    }
    
    /**
		 * Removes the passed observer from the list of observers.
		 * @param	observer The Observer to be removed.
		 */
    public function removeObserver(observer : IObserver) : Void
    {
        var removeIndex : Int = Lambda.indexOf(m_observers, observer);
        if (removeIndex >= 0 && removeIndex < m_observers.length)
        {
            m_observers.splice(removeIndex, 1);
        }
    }
    
    /**
		 * Calls the observeChange() function on the observers of the CGSObject.
		 * @param	arg Arguments to be forwarded to observerChange.
		 */
    public function notifyObservers(arg : Dynamic = null) : Void
    {
        var i : Int = m_observers.length - 1;
        while (i >= 0)
        {
            m_observers[i].observeChange(this, arg);
            i--;
        }
    }
    
    /**
		 * Adds the observers of the other CGSObject to this CGSObject.
		 * @param	other Another CGSObject.
		 */
    public function cloneObserversFrom(other : CGSObject) : Void
    {
        m_observers = other.m_observers.copy();
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
    }
}

