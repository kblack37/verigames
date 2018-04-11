package cgs.levelProgression.util;

import cgs.levelProgression.nodes.ICgsLevelNode;

/**
	 * ...
	 * @author Rich
	 */
interface ICgsLevelFactory
{
    
    /**
		 * Sets the defaultLevelType currently set in this ICgsLevelFactory.
		 */
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the defaultLevelType currently set in this ICgsLevelFactory.
		 */
    var defaultLevelType(get, set) : String;    
    /**
		 * Sets the defaultLevelPackType currently set in this ICgsLevelFactory.
		 */
    
    /**
		 * Returns the defaultLevelPackType currently set in this ICgsLevelFactory.
		 */
    var defaultLevelPackType(get, set) : String;

    /**
		 * 
		 * Node Management
		 * 
		**/
    
    /**
		 * Returns a node instance of the given type.
		 * @param	typeID - The type of level requested.
		 * @return
		 */
    function getNodeInstance(typeID : String) : ICgsLevelNode
    ;
    
    /**
		 * Recycles the provided node back into the factory
		 * @param	node - the node to be recycled
		 */
    function recycleNodeInstance(node : ICgsLevelNode) : Void
    ;
}

