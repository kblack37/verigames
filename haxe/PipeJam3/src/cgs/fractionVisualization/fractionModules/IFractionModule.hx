package cgs.fractionVisualization.fractionModules;

import cgs.fractionVisualization.FractionSprite;

/**
	 * ...
	 * @author Rich
	 */
interface IFractionModule
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the representation type of this module.
		 */
    var representationType(get, never) : String;    
    
    var totalWidth(get, never) : Float;

    /**
		 * Initializes this fraction module.
		 * @param	fractionSprite
		 */
    function init(fractionSprite : FractionSprite) : Void
    ;
    
    /**
		 * Resets this fraction module to be as if it were freshly constructed.
		 */
    function reset() : Void
    ;
    
    /**
		 * 
		 * Clone
		 * 
		**/
    
    /**
		 * Clones the representation state from the fractionSprite of this module into the given cloneFS.
		 * @param	cloneFS
		 */
    function cloneToFractionSprite(cloneFS : FractionSprite) : Void
    ;
    
    /**
		 * 
		 * Display
		 * 
		**/
    
    /**
		 * Draws the CgsFractionView associated with this module to the components of the fractionSprite
		 */
    function draw() : Void
    ;
}

