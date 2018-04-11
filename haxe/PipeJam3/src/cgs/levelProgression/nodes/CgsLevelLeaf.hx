package cgs.levelProgression.nodes;

import cgs.engine.game.CGSObject;
import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.locks.ICgsLevelLock;
import cgs.levelProgression.util.CgsLevelProgressionTypes;
import cgs.levelProgression.util.ICgsLockFactory;
import cgs.user.ICgsUser;
import cgs.user.ICgsUserManager;
import cgs.utils.Error;

/**
	 * ...
	 * @author ...
	 */
class CgsLevelLeaf extends CGSObject implements ICgsLevelLeaf
{
    private var userManager(get, never) : ICgsUserManager;
    private var cacheSaveName(get, never) : String;
    public var fileName(get, never) : String;
    public var nodeName(get, never) : String;
    public var nodeLabel(get, never) : Int;
    public var nodeType(get, never) : String;
    public var nextLevel(get, set) : ICgsLevelLeaf;
    public var previousLevel(get, set) : ICgsLevelLeaf;
    public var completionValue(get, never) : Int;
    public var isLocked(get, never) : Bool;
    public var isPlayed(get, never) : Bool;
    public var isComplete(get, never) : Bool;

    public static inline var NODE_TYPE : String = "CgsLevelLeaf";
    
    // Perma-State (only clear on destroy)
    private var m_levelManager : ICgsLevelManager;
    private var m_userManager : ICgsUserManager;
    private var m_nodeLabel : Int;
    private var m_lockFactory : ICgsLockFactory;
    
    // Other State (clear on reset or destroy)
    private var m_playable : Bool = true;
    private var m_inherentlyPlayable : Bool = false;
    private var m_levelName : String;
    private var m_fileName : String;
    private var m_saveName : String;
    private var m_levelLocks : Array<ICgsLevelLock>;
    private var m_previousLevel : ICgsLevelLeaf;
    private var m_nextLevel : ICgsLevelLeaf;
    private var m_parent : ICgsStatusNode;
    
    // Status
    private var m_completionValue : Int;
    
    public function new(levelManager : ICgsLevelManager, userManager : ICgsUserManager, lockFactory : ICgsLockFactory, nodeLabel : Int)
    {
        super();
        m_levelManager = levelManager;
        m_userManager = userManager;
        m_nodeLabel = nodeLabel;
        m_levelLocks = new Array<ICgsLevelLock>();
        m_lockFactory = lockFactory;
        m_completionValue = -1;
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(parent : ICgsLevelPack, prevLevel : ICgsLevelLeaf, data : Dynamic = null) : ICgsLevelLeaf
    {
        if (data == null)
        {
            // Do nothing if no data provided
            return this;
        }
        
        // Save references to other objects
        m_parent = parent;
        
        // Init from data
        initFromData(prevLevel, data);
        
        // Load from cache
        if (m_userManager.numUsers > 0)
        {
            loadNodeFromCache(m_userManager.userList[0].userId);
        }
        return this;
    }
    
    /**
		 * This is the real init, override this if you need to add properties.
		 * @param	prevLevel
		 * @param	data
		 * @return
		 */
    private function initFromData(prevLevel : ICgsLevelLeaf, data : Dynamic) : Void
    {
        m_previousLevel = prevLevel;
        if (m_previousLevel != null)
        {
            m_previousLevel.nextLevel = this;
        }
        
        // Get the name
        m_fileName = data.fileName;
        
        // get the level name, which defaults to file name if no level name is provided
        m_levelName = (Reflect.hasField(data, "name")) ? data.name : null;
        if (m_levelName == null || m_levelName == "")
        {
            m_levelName = m_fileName;
        }
        
        // Get the save name, which defaults to the level name if no save name is provided
        m_saveName = (Reflect.hasField(data, "saveName")) ? data.saveName : null;
        if (m_saveName == null || m_saveName == "")
        {
            m_saveName = m_levelName;
        }
        
        // Get the locks, if any
        var lockArray : Array<Dynamic> = (Reflect.hasField(data, "locks")) ? data.locks : null;
        if (lockArray != null)
        {
            for (lockChild in lockArray)
            {
                var lockType : String = Reflect.field(lockChild, "lockType");
                var lockKeyData : Dynamic = Reflect.field(lockChild, "lockKey");
                var lvlLock : ICgsLevelLock = m_lockFactory.getLockInstance(lockType, lockKeyData);
                m_levelLocks.push(lvlLock);
            }
        }
    }
    
    /**
		 * @inheritDoc
		 */
    override public function destroy() : Void
    {
        reset();
        
        // Null out perma-state
        m_nodeLabel = -1;
        m_levelManager = null;
        m_userManager = null;
        m_lockFactory = null;
        
        // Null out reset state
        m_levelLocks = null;
        
        super.destroy();
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        while (m_levelLocks.length > 0)
        {
            var lock : ICgsLevelLock = m_levelLocks.pop();
            m_lockFactory.recycleLock(lock);
        }
        m_levelLocks = new Array<ICgsLevelLock>();
        m_playable = true;
        m_inherentlyPlayable = false;
        m_levelName = null;
        m_fileName = null;
        m_saveName = null;
        m_previousLevel = null;
        m_nextLevel = null;
        m_completionValue = -1;
    }
    
    /**
		 * 
		 * Internal state - ie. only for self and extending functions
		 * 
		**/
    
    private function get_userManager() : ICgsUserManager
    {
        return m_userManager;
    }
    
    /**
		 * Forms and returns the save name of this level leaf.
		 */
    private function get_cacheSaveName() : String
    {
        return "level_" + m_saveName + "_nodeCompletion";
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_fileName() : String
    {
        return m_fileName;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_nodeName() : String
    {
        return m_levelName;
    }
    
    /**
		 * 
		 * Factory state
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_nodeLabel() : Int
    {
        return m_nodeLabel;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_nodeType() : String
    {
        return NODE_TYPE;
    }
    
    /**
		 * 
		 * Linking State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_nextLevel() : ICgsLevelLeaf
    {
        return m_nextLevel;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_nextLevel(nextLevel : ICgsLevelLeaf) : ICgsLevelLeaf
    {
        m_nextLevel = nextLevel;
        return nextLevel;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_previousLevel() : ICgsLevelLeaf
    {
        return m_previousLevel;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_previousLevel(prevLevel : ICgsLevelLeaf) : ICgsLevelLeaf
    {
        m_previousLevel = prevLevel;
        return prevLevel;
    }
    
    /**
		 * 
		 * Status state
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_completionValue() : Int
    {
        return m_completionValue;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isLocked() : Bool
    {
        var result : Bool = false;
        if (m_levelManager.doCheckLocks)
        {
            result = m_parent != null && m_parent.isLocked;
            for (aLock in m_levelLocks)
            {
                result = result || aLock.isLocked;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isPlayed() : Bool
    {
        return completionValue >= 0;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isComplete() : Bool
    {
        return completionValue >= m_levelManager.isCompleteCompletionValue;
    }
    
    /**
		 * 
		 * Level Playing functions
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function launchLevel(data : Dynamic = null) : Void
    {  // To be filled in by implementing class  
        
    }
    
    /**
		 * 
		 * Lock functions
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function addLock(lockType : String, keyData : Dynamic) : Bool
    {
        // Do nothing if no lock type given
        if (lockType == null || lockType == "")
        {
            return false;
        }
        
        var aLock : ICgsLevelLock = m_lockFactory.getLockInstance(lockType, keyData);
        m_levelLocks.push(aLock);
        return true;
    }
    
    /**
		 * @inheritDoc
		 */
    public function hasLock(lockType : String, keyData : Dynamic) : Bool
    {
        var result : Bool = false;
        for (lock in m_levelLocks)
        {
            if (lock.lockType == lockType && lock.doesKeyMatch(keyData))
            {
                result = true;
                break;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function editLock(lockType : String, oldKeyData : Dynamic, newKeyData : Dynamic) : Bool
    {
        var result : Bool = false;
        if (removeLock(lockType, oldKeyData))
        {
            addLock(lockType, newKeyData);
            result = true;
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeLock(lockType : String, keyData : Dynamic) : Bool
    {
        var result : Bool = false;
        for (lock in m_levelLocks)
        {
            if (lock.lockType == lockType && lock.doesKeyMatch(keyData))
            {
                m_levelLocks.splice(Lambda.indexOf(m_levelLocks, lock), 1);
                m_lockFactory.recycleLock(lock);
                result = true;
                break;
            }
        }
        return result;
    }
    
    /**
		 * 
		 * Tree functions
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function containsNode(nodeLabel : Int) : Bool
    {
        return m_nodeLabel == nodeLabel;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNode(nodeLabel : Int) : ICgsLevelNode
    {
        if (m_nodeLabel == nodeLabel)
        {
            return this;
        }
        return null;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNodeByName(nodeName : String) : ICgsLevelNode
    {
        if (m_levelName == nodeName)
        {
            return this;
        }
        return null;
    }
    
    /**
		 * @inheritDoc
		 */
    public function loadNodeFromCache(userId : String) : Void
    {
        if (!m_userManager.userExistsByUserId(userId))
        {
            throw new Error("ERROR: Cannot load from Cache; User " + userId + " does not exist!");
        }
        
        m_completionValue = -1;
        var user : ICgsUser = m_userManager.getUserByUserId(userId);
        var nodeSaveName : String = cacheSaveName;
        if (user.saveExists(nodeSaveName) && user.getSave(nodeSaveName) != null)
        {
            m_completionValue = cast(user.getSave(nodeSaveName), Int);
        }
        else
        {
            user.setSave(nodeSaveName, m_completionValue);
        }
        
        // Notify observers
        var observeData : Dynamic = {
            type : CgsLevelProgressionTypes.NODE_COMPLETION_UPDATED_KEY,
            nodeCompletion : m_completionValue
        };
        notifyObservers(observeData);
    }
    
    /**
		 * @inheritDoc
		 */
    public function updateNode(nodeLabel : Int, data : Dynamic = null) : Bool
    {
        var result : Bool = false;
        if (m_nodeLabel == nodeLabel)
        {
            if (Reflect.field(data, Std.string(CgsLevelProgressionTypes.NODE_COMPLETION_KEY)) != null)
            {
                m_completionValue = Reflect.field(data, Std.string(CgsLevelProgressionTypes.NODE_COMPLETION_KEY));
            }
            
            // Update the levels of each user individually
            for (user in m_userManager.userList)
            {
                user.setSave(cacheSaveName, m_completionValue);
            }
            
            // Notify observers
            var observeData : Dynamic = {
                type : CgsLevelProgressionTypes.NODE_COMPLETION_UPDATED_KEY,
                nodeCompletion : m_completionValue
            };
            notifyObservers(observeData);
            result = true;
        }
        return result;
    }
}

