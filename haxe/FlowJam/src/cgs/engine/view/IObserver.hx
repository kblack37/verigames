package cgs.engine.view;

import cgs.engine.game.IObservable;

/**
	 * An interface for an Observer. More info on the observer pattern:
	 * http://en.wikipedia.org/wiki/Observer_pattern
	 * @author Alex
	 */
interface IObserver
{

    /**
		 * Responds to changes in the given CGSObject.
		 * @param	o The CGSObject the IObserver is Observing
		 * @param	argObject Arguments of what changed.
		 */
    function observeChange(o : IObservable, argObject : Dynamic) : Void
    ;
}

