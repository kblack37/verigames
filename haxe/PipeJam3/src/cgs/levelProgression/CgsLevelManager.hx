package cgs.levelProgression;

import cgs.achievement.ICgsAchievementManager;
import cgs.levelProgression.nodes.ICgsLevelLeaf;
import cgs.levelProgression.nodes.ICgsLevelNode;
import cgs.levelProgression.nodes.ICgsLevelPack;
import cgs.levelProgression.util.CgsLevelFactory;
import cgs.levelProgression.util.CgsLevelProgressionTypes;
import cgs.levelProgression.util.CgsLevelResourceManager;
import cgs.levelProgression.util.CgsLockFactory;
import cgs.levelProgression.util.ICgsLevelFactory;
import cgs.levelProgression.util.ICgsLevelResourceManager;
import cgs.levelProgression.util.ICgsLockFactory;
import cgs.user.ICgsUserManager;

/**
	 * ...
	 * @author ...
	 */
class CgsLevelManager implements ICgsLevelManager
{
    public var currentLevel(get, never) : ICgsLevelLeaf;
    public var currentLevelProgression(get, never) : ICgsLevelPack;
    public var resourceManager(get, never) : ICgsLevelResourceManager;
    public var achievementManager(get, never) : ICgsAchievementManager;
    public var numLevelLeafsCompleted(get, never) : Int;
    public var numLevelLeafsUncompleted(get, never) : Int;
    public var numLevelLeafsPlayed(get, never) : Int;
    public var numLevelLeafsUnplayed(get, never) : Int;
    public var numLevelLeafsLocked(get, never) : Int;
    public var numLevelLeafsUnlocked(get, never) : Int;
    public var numTotalLevelLeafs(get, never) : Int;
    public var numLevelPacksCompleted(get, never) : Int;
    public var numLevelPacksUncompleted(get, never) : Int;
    public var numLevelPacksFullyPlayed(get, never) : Int;
    public var numLevelPacksPlayed(get, never) : Int;
    public var numLevelPacksUnplayed(get, never) : Int;
    public var numLevelPacksLocked(get, never) : Int;
    public var numLevelPacksUnlocked(get, never) : Int;
    public var numTotalLevelPacks(get, never) : Int;
    public var isCompleteCompletionValue(get, set) : Float;
    public var doCheckLocks(get, set) : Bool;

    // State
    private var m_rootLevelProgression : ICgsLevelPack;
    private var m_currentLevelProgression : ICgsLevelPack;
    private var m_currentLevel : ICgsLevelLeaf;
    private var m_lockFactory : ICgsLockFactory;
    private var m_levelFactory : ICgsLevelFactory;
    private var m_resourceManager : ICgsLevelResourceManager;
    private var m_userManager : ICgsUserManager;
    
    // Level Manager Variables
    private var m_isCompleteCompletionValue : Float = 1;
    private var m_doCheckLocks : Bool = true;
    
    public function new(userManager : ICgsUserManager)
    {
        m_lockFactory = createLockFactory();
        m_levelFactory = createLevelFactory(userManager);
        m_resourceManager = createResourceManager();
        m_userManager = userManager;
    }
    
    /**
		 * Creates and returns a new Lock Factory instance for use in the Level Manager.
		 * @return
		 */
    private function createLockFactory() : ICgsLockFactory
    {
        return new CgsLockFactory(this);
    }
    
    /**
		 * Creates and returns a new Level Factory instance for use in the Level Manager.
		 * @param	userManager
		 * @return
		 */
    private function createLevelFactory(userManager : ICgsUserManager) : ICgsLevelFactory
    {
        return new CgsLevelFactory(this, m_lockFactory, userManager);
    }
    
    /**
		 * Creates and returns a new Resource Manager instance for use in the Level Manager.
		 * @return
		 */
    private function createResourceManager() : ICgsLevelResourceManager
    {
        return new CgsLevelResourceManager();
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(levelData : Dynamic = null) : Void
    {
        // Level Progression
        m_rootLevelProgression = cast m_levelFactory.getNodeInstance(m_levelFactory.defaultLevelPackType);
        m_rootLevelProgression.init(null, null, levelData);
        
        // Current Level
        m_currentLevelProgression = m_rootLevelProgression;
        m_currentLevel = null;
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        m_levelFactory.recycleNodeInstance(m_rootLevelProgression);
        m_rootLevelProgression = null;
        m_currentLevelProgression = null;
        m_currentLevel = null;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_currentLevel() : ICgsLevelLeaf
    {
        return m_currentLevel;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_currentLevelProgression() : ICgsLevelPack
    {
        return m_currentLevelProgression;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_resourceManager() : ICgsLevelResourceManager
    {
        return m_resourceManager;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_achievementManager() : ICgsAchievementManager
    {
        return m_userManager.userList[0];
    }
    
    /**
		 * 
		 * Level Leaf Status State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsCompleted() : Int
    {
        return m_currentLevelProgression.numLevelLeafsCompleted;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsUncompleted() : Int
    {
        return m_currentLevelProgression.numLevelLeafsUncompleted;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsPlayed() : Int
    {
        return m_currentLevelProgression.numLevelLeafsPlayed;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsUnplayed() : Int
    {
        return m_currentLevelProgression.numLevelLeafsUnplayed;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsLocked() : Int
    {
        return m_currentLevelProgression.numLevelLeafsLocked;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsUnlocked() : Int
    {
        return m_currentLevelProgression.numLevelLeafsUnlocked;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numTotalLevelLeafs() : Int
    {
        return m_currentLevelProgression.numTotalLevelLeafs;
    }
    
    /**
		 * 
		 * Level Pack Status State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksCompleted() : Int
    {
        return m_currentLevelProgression.numLevelPacksCompleted;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksUncompleted() : Int
    {
        return m_currentLevelProgression.numLevelPacksUncompleted;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksFullyPlayed() : Int
    {
        return m_currentLevelProgression.numLevelPacksFullyPlayed;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksPlayed() : Int
    {
        return m_currentLevelProgression.numLevelPacksPlayed;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksUnplayed() : Int
    {
        return m_currentLevelProgression.numLevelPacksUnplayed;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksLocked() : Int
    {
        return m_currentLevelProgression.numLevelPacksLocked;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksUnlocked() : Int
    {
        return m_currentLevelProgression.numLevelPacksUnlocked;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numTotalLevelPacks() : Int
    {
        return m_currentLevelProgression.numTotalLevelPacks;
    }
    
    /**
		 * 
		 * Node Status State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function getCompletionValueOfNode(nodeLabel : Int) : Float
    {
        return m_currentLevelProgression.getNode(nodeLabel).completionValue;
    }
    
    /**
		 * 
		 * Variable State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_isCompleteCompletionValue() : Float
    {
        return m_isCompleteCompletionValue;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_isCompleteCompletionValue(value : Float) : Float
    {
        m_isCompleteCompletionValue = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_doCheckLocks() : Bool
    {
        return m_doCheckLocks;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_doCheckLocks(value : Bool) : Bool
    {
        m_doCheckLocks = value;
        return value;
    }
    
    /**
		 * 
		 * Completion
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function endCurrentLevel() : Void
    {
        m_currentLevel = null;
    }
    
    /**
		 * 
		 * Launching
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function playLevel(levelData : ICgsLevelLeaf, data : Dynamic = null) : Void
    {
        if (levelData != null)
        {
            m_currentLevel = levelData;
            m_currentLevel.launchLevel(data);
        }
    }
    
    /**
		 * 
		 * Level Leaf Status Management - All
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsComplete() : Void
    {
        m_currentLevelProgression.markAllLevelLeafsAsComplete();
    }
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsPlayed() : Void
    {
        m_currentLevelProgression.markAllLevelLeafsAsPlayed();
    }
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsUnplayed() : Void
    {
        m_currentLevelProgression.markAllLevelLeafsAsUnplayed();
    }
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsCompletionValue(value : Float) : Void
    {
        m_currentLevelProgression.markAllLevelLeafsAsCompletionValue(value);
    }
    
    /**
		 * 
		 * Level Leaf Status Management - Current
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function markCurrentLevelLeafAsCompletionValue(value : Float) : Void
    {
        if (currentLevel != null)
        {
            var data : Dynamic = {};
            Reflect.setField(data, Std.string(CgsLevelProgressionTypes.NODE_COMPLETION_KEY), value);
            m_currentLevel.updateNode(currentLevel.nodeLabel, data);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function markCurrentLevelLeafAsComplete() : Void
    {
        markCurrentLevelLeafAsCompletionValue(isCompleteCompletionValue);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markCurrentLevelLeafAsPlayed() : Void
    {
        markCurrentLevelLeafAsCompletionValue(0);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markCurrentLevelLeafAsUnplayed() : Void
    {
        markCurrentLevelLeafAsCompletionValue(-1);
    }
    
    /**
		 * 
		 * Level Leaf Status Management - By Label
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function markLevelLeafAsCompletionValue(nodeLabel : Int, value : Float) : Void
    {
        var data : Dynamic = {};
        Reflect.setField(data, Std.string(CgsLevelProgressionTypes.NODE_COMPLETION_KEY), value);
        m_currentLevelProgression.updateNode(nodeLabel, data);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markLevelLeafAsComplete(nodeLabel : Int) : Void
    {
        markLevelLeafAsCompletionValue(nodeLabel, isCompleteCompletionValue);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markLevelLeafAsPlayed(nodeLabel : Int) : Void
    {
        markLevelLeafAsCompletionValue(nodeLabel, 0);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markLevelLeafAsUnplayed(nodeLabel : Int) : Void
    {
        markLevelLeafAsCompletionValue(nodeLabel, -1);
    }
    
    /**
		 * 
		 * Updating Progression
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function addNodeToProgression(nodeData : Dynamic, parentPackName : String = null, index : Int = -1) : Void
    {
        // Add the given node to the progression.
        if (!m_rootLevelProgression.addNodeToProgression(nodeData, parentPackName, index))
        {
            // The add failed, so add it to the root itself.
            m_rootLevelProgression.addNodeToProgression(nodeData, m_rootLevelProgression.nodeName);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function editNodeInProgression(nameOfNode : String, newNodeData : Dynamic) : Void
    {
        if (m_rootLevelProgression.nodeName == nameOfNode)
        {
            reset();
            init(newNodeData);
        }
        else
        {
            m_rootLevelProgression.editNodeInProgression(nameOfNode, newNodeData);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeNodeFromProgression(nodeName : String) : Void
    {
        m_rootLevelProgression.removeNodeFromProgression(nodeName);
    }
    
    /**
		 * 
		 * Tree Functions
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function getNode(nodeLabel : Int) : ICgsLevelNode
    {
        return m_currentLevelProgression.getNode(nodeLabel);
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNodeByName(nodeName : String) : ICgsLevelNode
    {
        return m_currentLevelProgression.getNodeByName(nodeName);
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNextLevel(presentLevel : ICgsLevelLeaf = null) : ICgsLevelLeaf
    {
        var result : ICgsLevelLeaf;
        if (presentLevel == null)
        {
            result = m_currentLevelProgression.firstLeaf;
        }
        else
        {
            result = presentLevel.nextLevel;
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNextLevelById(aNodeLabel : Int = -1) : ICgsLevelLeaf
    {
        return m_currentLevelProgression.getNextLevel(aNodeLabel);
    }
    
    /**
		 * @inheritDoc
		 */
    public function getPrevLevel(presentLevel : ICgsLevelLeaf = null) : ICgsLevelLeaf
    {
        var result : ICgsLevelLeaf;
        if (presentLevel == null)
        {
            result = m_currentLevelProgression.firstLeaf;
        }
        else
        {
            result = presentLevel.previousLevel;
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getPrevLevelById(aNodeLabel : Int = -1) : ICgsLevelLeaf
    {
        return m_currentLevelProgression.getPrevLevel(aNodeLabel);
    }
}

