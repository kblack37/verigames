package cgs.levelProgression.nodes;


/**
	 * Interface for Level Select Progressions (holders of level select nodes)
	 * @author Rich
	 */
interface ICgsLevelPack extends ICgsLevelNode
{    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the first leaf contained in this level pack
		 * @return the first leaf contained in this level pack.  Null if no leafs
		 */
    var firstLeaf(get, never) : ICgsLevelLeaf;    
    
    /**
		 * Returns the last leaf contained in this level pack
		 * @return the last leaf contained in this level pack.  Null if no leafs
		 */
    var lastLeaf(get, never) : ICgsLevelLeaf;    
    
    /**
		 * Returns the length of this progression (number of first children).
		 */
    var length(get, never) : Float;    
    
    /**
		 * Returns the names of the level leafs in this inner node and its children. The names are returned in the order in which they occur.
		 */
    var levelNames(get, never) : Array<String>;    
	
    /**
		 * Returns the nodes of this progression
		 */
    var nodes(get, never) : Array<ICgsLevelNode>;    
    
    /**
		 * 
		 * Level Leaf Status State
		 * 
		**/
    
    /**
		 * Returns the number of level leafs that have been completed.
		 */
    var numLevelLeafsCompleted(get, never) : Int;    
    
    /**
		 * Returns the number of level leafs that have been not been completed.
		 */
    var numLevelLeafsUncompleted(get, never) : Int;    
    
    /**
		 * Returns the number of level leafs that have been played.
		 */
    var numLevelLeafsPlayed(get, never) : Int;    
    
    /**
		 * Returns the number of level leafs that have not been played.
		 */
    var numLevelLeafsUnplayed(get, never) : Int;    
    
    /**
		 * Returns the number of level leafs that are locked.
		 */
    var numLevelLeafsLocked(get, never) : Int;    
    
    /**
		 * Returns the number of level leafs that are unlocked.
		 */
    var numLevelLeafsUnlocked(get, never) : Int;    
    
    /**
		 * Returns the total number of level leafs.
		 */
    var numTotalLevelLeafs(get, never) : Int;    
    
    /**
		 * 
		 * Level Pack Status State
		 * 
		**/
    
    /**
		 * Returns the number of level packs that have been completed.
		 */
    var numLevelPacksCompleted(get, never) : Int;    
    
    /**
		 * Returns the number of level packs that have been not been completed.
		 */
    var numLevelPacksUncompleted(get, never) : Int;    
    
    /**
		 * Returns the number of level packs that have been fully played.
		 */
    var numLevelPacksFullyPlayed(get, never) : Int;    
    
    /**
		 * Returns the number of level packs that have been (at least partially) played.
		 */
    var numLevelPacksPlayed(get, never) : Int;    
    
    /**
		 * Returns the number of level packs that have not been played at all.
		 */
    var numLevelPacksUnplayed(get, never) : Int;    
    
    /**
		 * Returns the number of level packs that are locked.
		 */
    var numLevelPacksLocked(get, never) : Int;    
    
    /**
		 * Returns the number of level packs that are unlocked.
		 */
    var numLevelPacksUnlocked(get, never) : Int;    
    
    /**
		 * Returns the total number of level packs.
		 */
    var numTotalLevelPacks(get, never) : Int;    
    
    /**
		 * 
		 * Status State
		 * 
		**/
    
    /**
		 * Checks that the level pack has been fully played.
		 * @return true if fully played, false if not
		 */
    var isFullyPlayed(get, never) : Bool;

    /**
		 * 
		 * Level Leaf Status Management - All
		 * 
		**/
    
    /**
		 * Marks all the levels as complete.
		 */
    function markAllLevelLeafsAsComplete() : Void
    ;
    
    /**
		 * Marks all the levels as played.
		 */
    function markAllLevelLeafsAsPlayed() : Void
    ;
    
    /**
		 * Marks all the levels as unplayed.
		 */
    function markAllLevelLeafsAsUnplayed() : Void
    ;
    
    /**
		 * Marks all the levels as the given completion value.
		 * @param	value - The completion value to be assigned.
		 */
    function markAllLevelLeafsAsCompletionValue(value : Float) : Void
    ;
    
    /**
		 * 
		 * Updating Progression
		 * 
		**/
    
    /**
		 * Creates the given node and adds it to the given parent at the given index. A negative index or an index 
		 * greater than the parent's number of children will add the node to the end of the parent's list of children. 
		 * Returns whether or not it was successful.
		 * @param	nodeData - data describing the new behaviour of the node.
		 * @param	parentPackName - Name of the parent pack to add the new node to.
		 * @param	index - Index at which to add the new node.
		 * @return
		 */
    function addNodeToProgression(nodeData : Dynamic, parentPackName : String = null, index : Int = -1) : Bool
    ;
    
    /**
		 * Removes the existing node of the given node name and adds a node with the given name/json in its place.
		 * If the node did no exist, nothing will happen. Returns whether or not it was successful.
		 * @param	nodeName - Name of the node to be edited.
		 * @param	newNodeData - data describing the new behaviour of the node.
		 * @return
		 */
    function editNodeInProgression(nameOfNode : String, newNodeData : Dynamic) : Bool
    ;
    
    /**
		 * Removes the given node, if any, from this level pack. Returns whether or not it was successful.
		 * @param	nodeName - Name of the node to be removed.
		 * @return
		 */
    function removeNodeFromProgression(nodeName : String) : Bool
    ;
    
    /**
		 * 
		 * Tree Functions - Level Advancement
		 * 
		**/
    
    /**
		 * Returns the level that comes after the node with the given label.
		 * @param	aNodeLabel
		 * @return
		 */
    function getNextLevel(aNodeLabel : Int = -1) : ICgsLevelLeaf
    ;
    /**
		 * Returns the level that comes before the node with the given label.
		 * @param	aNodeLabel
		 * @return
		 */
    function getPrevLevel(aNodeLabel : Int = -1) : ICgsLevelLeaf
    ;
}

