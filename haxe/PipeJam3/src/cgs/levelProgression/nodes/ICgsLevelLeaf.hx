package cgs.levelProgression.nodes;


/**
	 * Interface for a Level Select Levels (a leaf node is a playable level, as opposed to a progression).
	 * @author Rich
	 */
interface ICgsLevelLeaf extends ICgsLevelNode
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the file name of this leaf node (the json file that defines the properties of the level).
		 */
    var fileName(get, never) : String;    
    
    /**
		 * Sets the next level in the progression
		 */
    
    
    /**
		 * 
		 * Linking State
		 * 
		**/
    
    /**
		 * Returns the next level in the progression
		 */
    var nextLevel(get, set) : ICgsLevelLeaf;    
    
    /**
		 * sets the previous level in the progression
		 */
    
    
    /**
		 * Returns the previous level in the progression
		 */
    var previousLevel(get, set) : ICgsLevelLeaf;

    
    /**
		 * 
		 * Level Playing functions
		 * 
		**/
    
    /**
		 * Launches this level.
		 * @param	data 
		 */
    function launchLevel(data : Dynamic = null) : Void
    ;
}

