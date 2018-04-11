package cgs.levelProgression.nodes;


/**
	 * Interface for Level Select Nodes
	 * @author Rich
	 */
interface ICgsLevelNode extends ICgsStatusNode
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the name of this node.
		 */
    var nodeName(get, never) : String;    
    
    /**
		 * 
		 * Factory state
		 * 
		**/
    
    /**
		 * Returns the level label of this node.
		 */
    var nodeLabel(get, never) : Int;    
    
    /**
		 * Returns the type of this node.
		 */
    var nodeType(get, never) : String;

    
    /**
		 * Initializes this node with the given data.
		 * @param	parent - parent ICgsStatusNode of this ICgsLevelNode
		 * @param	prevLevel - the previous level in the progression
		 * @param	data The data to describe this node.
		 */
    function init(parent : ICgsLevelPack, prevLevel : ICgsLevelLeaf, data : Dynamic = null) : ICgsLevelLeaf
    ;
    /**
		 * Destroys this ICgsLevelNode
		 */
    function destroy() : Void
    ;
    
    /**
		 * Resets all the main features of this node, such that when it is returned to and retrieved from the factory,
		 * it functions as a brand new node.
		 */
    function reset() : Void
    ;
    
    /**
		 * 
		 * Lock functions
		 * 
		**/
    
    /**
		 * Adds a lock to this node with the given lock type and key data.
		 * @param	lockType
		 * @param	keyData
		 */
    function addLock(lockType : String, keyData : Dynamic) : Bool
    ;
    
    /**
		 * Returns whether or not this node has a lock with the given type and key data.
		 * @param	lockType
		 * @param	keyData
		 */
    function hasLock(lockType : String, keyData : Dynamic) : Bool
    ;
    
    /**
		 * Removes a lock on this node with the given lock type and old key data, if any, and replaces it with a
		 * new lock with the same lock type and new key data.
		 * @param	lockType
		 * @param	oldKeyData
		 * @param	newKeyData
		 */
    function editLock(lockType : String, oldKeyData : Dynamic, newKeyData : Dynamic) : Bool
    ;
    
    /**
		 * Removes a lock with the given lock type and key data, if any. If multiple locks match this description, only
		 * one will be removed.
		 * @param	lockType
		 * @param	keyData
		 */
    function removeLock(lockType : String, keyData : Dynamic) : Bool
    ;
    
    /**
		 * 
		 * Tree functions
		 * 
		**/
    
    /**
		 * Returns whether or not this node contains a node with the node with the given nodeLabel.
		 * @param	nodeLabel The id of the node attempting to be found.
		 * @return
		 */
    function containsNode(nodeLabel : Int) : Bool
    ;
    /**
		 * Attempts to find and return the node of the given label.
		 * @param	nodeLabel - the id of the node to be returned
		 * @return
		 */
    function getNode(nodeLabel : Int) : ICgsLevelNode
    ;
    
    /**
		 * Attempts to find and return the node of the given name.
		 * @param	nodeName - the name of the node to be returned
		 * @return
		 */
    function getNodeByName(nodeName : String) : ICgsLevelNode
    ;
    
    /**
		 * Loads this node, and any children nodes, from the cache of the user with the given userId.
		 * @param	userId ID of user to load from
		 */
    function loadNodeFromCache(userId : String) : Void
    ;
    
    /**
		 * Attempt to mark the node with the given name as complete with the given data.
		 * @param	nodeLabel - the id of the node
		 * @param	data The data needed for the node to determine if it has been completed.
		 */
    function updateNode(nodeLabel : Int, data : Dynamic = null) : Bool
    ;
}

