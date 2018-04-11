package cgs.levelProgression;

import cgs.achievement.ICgsAchievementManager;
import cgs.levelProgression.nodes.ICgsLevelLeaf;
import cgs.levelProgression.nodes.ICgsLevelNode;
import cgs.levelProgression.nodes.ICgsLevelPack;
import cgs.levelProgression.util.ICgsLevelResourceManager;

/**
	 * ...
	 * @author Rich
	 */
interface ICgsLevelManager
{
    
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * Returns the current level being played.
		 */
    var currentLevel(get, never) : ICgsLevelLeaf;    
    
    /**
		 * Returns the current level progression being played.
		 */
    var currentLevelProgression(get, never) : ICgsLevelPack;    
    
    /**
		 * Returns the Resource Manager of this ICgsLevelManager.
		 */
    var resourceManager(get, never) : ICgsLevelResourceManager;    
    
    /**
		 * Returns an achievement manager
		 */
    var achievementManager(get, never) : ICgsAchievementManager;    
    
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
		 * Sets the completion value that a node needs to equal or surpass to be considered complete to be the given value.
		 */
    
    
    /**
		 * 
		 * Variable State
		 * 
		**/
    
    /**
		 * Returns the completion value that a node needs to equal or surpass to be considered complete.
		 */
    var isCompleteCompletionValue(get, set) : Float;    
    
    /**
		 * Sets whether or not the nodes in this level manager should check their locks. If set to true, locks will be checked
		 * to determine if the node is unlocked. If set to false, locks will not be checked and all nodes will be unlocked.
		 */
    
    
    /**
		 * Returns whether or not the nodes in this level manager should check their locks. If set to true, locks will be checked
		 * to determine if the node is unlocked. If set to false, locks will not be checked and all nodes will be unlocked.
		 */
    var doCheckLocks(get, set) : Bool;

    
    /**
		 * Initializes this level manager with the given level data.
		 * @param	levelData
		 */
    function init(levelData : Dynamic = null) : Void
    ;
    
    /**
		 * Resets the level manager to be empty.
		 */
    function reset() : Void
    ;
    
    /**
		 * 
		 * Node Status State
		 * 
		**/
    
    /**
		 * Returns the completion value of the given node.
		 * @param	nodeLabel The ID of the node to get the completion value of.
		 * @return
		 */
    function getCompletionValueOfNode(nodeLabel : Int) : Float
    ;
    /**
		 * 
		 * Completion
		 * 
		**/
    
    /**
		 * Ends the current level.
		 */
    function endCurrentLevel() : Void
    ;
    
    /**
		 * 
		 * Launching
		 * 
		**/
    
    /**
		 * Plays the level given by name, assuming it exists.
		 * @param	levelData
		 * @param	data
		 */
    function playLevel(levelData : ICgsLevelLeaf, data : Dynamic = null) : Void
    ;
    
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
		 */
    function markAllLevelLeafsAsCompletionValue(value : Float) : Void
    ;
    
    /**
		 * 
		 * Level Leaf Status Management - Current
		 * 
		**/
    
    /**
		 * Marks the current level with the given completion value.
		 * @param	value - The completion value to be assigned.
		 */
    function markCurrentLevelLeafAsCompletionValue(value : Float) : Void
    ;
    
    /**
		 * Marks the current level as complete.
		 */
    function markCurrentLevelLeafAsComplete() : Void
    ;
    
    /**
		 * Marks the current level as played.
		 */
    function markCurrentLevelLeafAsPlayed() : Void
    ;
    
    /**
		 * Marks the current level as unplayed.
		 */
    function markCurrentLevelLeafAsUnplayed() : Void
    ;
    
    /**
		 * 
		 * Level Leaf Status Management - By Label
		 * 
		**/
    
    /**
		 * Marks the given level leaf with the given completion value.
		 * @param	nodeLabel - The level leaf to marked with the given value.
		 * @param	value - The completion value to be assigned.
		 */
    function markLevelLeafAsCompletionValue(nodeLabel : Int, value : Float) : Void
    ;
    
    /**
		 * Marks the given level leaf as complete.
		 * @param	nodeLabel - The level leaf to mark as complete.
		 */
    function markLevelLeafAsComplete(nodeLabel : Int) : Void
    ;
    
    /**
		 * Marks the given level leaf as played
		 * @param	nodeLabel - The level leaf to mark as played.
		 **/
    function markLevelLeafAsPlayed(nodeLabel : Int) : Void
    ;
    
    /**
		 * Marks the given level leaf as unplayed.
		 * @param	nodeLabel - The level leaf to mark as unplayed.
		 */
    function markLevelLeafAsUnplayed(nodeLabel : Int) : Void
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
    function addNodeToProgression(nodeData : Dynamic, parentPackName : String = null, index : Int = -1) : Void
    ;
    
    /**
		 * Removes the existing node of the given node name and adds a node with the given name/json in its place.
		 * If the node did no exist, nothing will happen. Returns whether or not it was successful.
		 * @param	nodeName - Name of the node to be edited.
		 * @param	newNodeData - data describing the new behaviour of the node.
		 * @return
		 */
    function editNodeInProgression(nameOfNode : String, newNodeData : Dynamic) : Void
    ;
    
    /**
		 * Removes the given node, if any, from this level pack. Returns whether or not it was successful.
		 * @param	nodeName - Name of the node to be removed.
		 * @return
		 */
    function removeNodeFromProgression(nodeName : String) : Void
    ;
    
    /**
		 * 
		 * Tree Functions
		 * 
		**/
    
    /**
		 * Returns the given node.
		 * @param nodeLabel - the id of the node to return
		 * @return
		 */
    function getNode(nodeLabel : Int) : ICgsLevelNode
    ;
    
    /**
		 * Returns the given node.
		 * @param nodeName - the namne of the node to return
		 * @return
		 */
    function getNodeByName(nodeName : String) : ICgsLevelNode
    ;
    
    /**
		 * Return the next level of the presentLevel leaf in the progression.
		 * Returns null if no next level (ie. end of progression).
		 * @param	presentLevel
		 * @return
		 */
    function getNextLevel(presentLevel : ICgsLevelLeaf = null) : ICgsLevelLeaf
    ;
    
    /**
		 * Returns the next level of the node defined by aNodeLabel
		 * @param	aNodeLabel - the label of the node
		 * @return	ICgsLevelLeaf - the next level
		 */
    function getNextLevelById(aNodeLabel : Int = -1) : ICgsLevelLeaf
    ;
    
    /**
		 * Return the previous level available.
		 * Returns null if no previous level (ie. start of progression).
		 * @param	presentLevel
		 * @return
		 */
    function getPrevLevel(presentLevel : ICgsLevelLeaf = null) : ICgsLevelLeaf
    ;
    
    /**
		 * Returns the level previous to the node defined by aNodeLabel
		 * @param	aNodeLabel - the label of the node
		 * @return	ICgsLevelLeaf - the previous level
		 */
    function getPrevLevelById(aNodeLabel : Int = -1) : ICgsLevelLeaf
    ;
}

