package cgs.levelProgression.nodes;


/**
	 * Contains statuses and returns them
	 * @author Jack
	 */
interface ICgsStatusNode
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the completionValue of this node.
		 */
    var completionValue(get, never) : Float;    
    
    /**
		 * Checks that the node is locked.
		 * @return true if locked, false if not
		 */
    var isLocked(get, never) : Bool;    
    
    /**
		 * Checks that the node has been played.
		 * @return true if played, false if not
		 */
    var isPlayed(get, never) : Bool;    
    
    /**
		 * Returns whether or not this node has passed the level manager's definition of complete.
		 */
    var isComplete(get, never) : Bool;

}

