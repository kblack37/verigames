package cgs.engine.game;

import cgs.engine.view.IObserver;

/**
	 * An interface for an Observable. More info on the observer pattern:
	 * http://en.wikipedia.org/wiki/Observer_pattern
	 * @author Rich
	 */
interface IObservable
{

    /**
		 * Adds the passed observer to the list of observers.
		 * @param	observer The Observer to be added.
		 */
    function addObserver(observer : IObserver) : Void
    ;
    
    /**
		 * Removes the passed observer from the list of observers.
		 * @param	observer The Observer to be removed.
		 */
    function removeObserver(observer : IObserver) : Void
    ;
    
    /**
		 * Calls the observeChange() function on the observers of the CGSObject.
		 * @param	arg Arguments to be forwarded to observerChange.
		 */
    function notifyObservers(arg : Dynamic = null) : Void
    ;
    
    /**
		 * Adds the observers of the other CGSObject to this CGSObject.
		 * @param	other Another CGSObject.
		 */
    function cloneObserversFrom(other : CGSObject) : Void
    ;
}
