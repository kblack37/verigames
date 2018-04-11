package cgs.levelProgression.nodes;

import cgs.engine.game.CGSObject;
import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.locks.CgsNodeLock;
import cgs.levelProgression.locks.ICgsLevelLock;
import cgs.levelProgression.util.CgsLevelProgressionTypes;
import cgs.levelProgression.util.ICgsLevelFactory;
import cgs.levelProgression.util.ICgsLockFactory;
import cgs.utils.MathUtils;
import haxe.Json;

/**
	 * ...
	 * @author ...
	 */
class CgsLevelPack extends CGSObject implements ICgsLevelPack
{
    public var firstLeaf(get, never) : ICgsLevelLeaf;
    public var lastLeaf(get, never) : ICgsLevelLeaf;
    public var length(get, never) : Float;
    public var levelNames(get, never) : Array<String>;
    public var nodeName(get, never) : String;
    public var nodes(get, never) : Array<ICgsLevelNode>;
    public var nodeLabel(get, never) : Int;
    public var nodeType(get, never) : String;
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
    public var completionValue(get, never) : Float;
    public var isLocked(get, never) : Bool;
    public var isFullyPlayed(get, never) : Bool;
    public var isPlayed(get, never) : Bool;
    public var isComplete(get, never) : Bool;

    public static inline var NODE_TYPE : String = "CgsLevelPack"; // Type.getClassName(ICgsLevelPack).split(".").pop(); ;
    
    // Perma-State (only clear on destroy)
    private var m_nodeLabel : Int;
    private var m_levelManager : ICgsLevelManager;
    private var m_levelFactory : ICgsLevelFactory;
    private var m_lockFactory : ICgsLockFactory;
    
    // Other State (clear on reset or destroy)
    private var m_currLevelIndex : Int;
    private var m_levelData : Array<ICgsLevelNode>;
    private var m_progressionName : String = "";
    private var m_packLocks : Array<ICgsLevelLock>;
    private var m_parent : ICgsLevelPack;
    private var m_playSequentially : Bool;
    
    public function new(levelManager : ICgsLevelManager, levelFactory : ICgsLevelFactory, lockFactory : ICgsLockFactory, nodeLabel : Int)
    {
        super();
        m_levelManager = levelManager;
        m_levelFactory = levelFactory;
        m_lockFactory = lockFactory;
        m_nodeLabel = nodeLabel;
        m_levelData = new Array<ICgsLevelNode>();
        m_currLevelIndex = -1;
        m_packLocks = new Array<ICgsLevelLock>();
    }
    
    /**
		 * @inheritDoc
		 */
    public function init(parent : ICgsLevelPack, prevLevel : ICgsLevelLeaf, data : Dynamic = null) : ICgsLevelLeaf
    {
        // If no data, do nothing
        if (data == null)
        {
            return prevLevel;
        }
        
        m_parent = parent;
        
        // Load from file, if needed
        if (Reflect.hasField(data, "fileName"))
        {
            var fileName : String = Reflect.field(data, "fileName");
            var file : String = m_levelManager.resourceManager.getResource(fileName);
            try
            {
                var newData : Dynamic = Json.parse(file);
                if (newData != null)
                {
                    data = newData;
                }
            }
            catch (err:Dynamic)
            {  // Do nothing  
                
            }
        }
        
        return initFromData(prevLevel, data);
    }
    
    /**
		 * This is the real init, override this if you need to add properties.
		 * @param	prevLevel
		 * @param	data
		 * @return
		 */
    private function initFromData(prevLevel : ICgsLevelLeaf, data : Dynamic) : ICgsLevelLeaf
    {
        // Node tracking
        var node : ICgsLevelNode;
        var previousLevel : ICgsLevelLeaf = prevLevel;
        var previousNode : ICgsLevelNode = null;  // The first node created by the level pack will never need a previousNode since it is locked by the level pack  
        
        // Level Pack data
        m_progressionName = data.progressionName;
        var children : Array<Dynamic> = data.children;
        var lockArray : Array<Dynamic> = Reflect.hasField(data, "locks") ? data.locks : [];
        m_playSequentially = (Reflect.hasField(data, "playSequentially")) ? data.playSequentially : true;
        
        // A levelPack contains a list of levels or more levelPacks
        for (childObj in children)
        {
            // Convert a child that is only a string to an object
            if (Std.is(childObj, String))
            {
                childObj = convertToData(Std.string(childObj));
            }
            
            // Create the node
            node = createNode(childObj, previousNode);
            
            // Save the newly created node and init it
            m_levelData.push(node);
            
            // Init the node
            previousLevel = node.init(this, previousLevel, childObj);
            
            // Set the previous node for the next loop
            previousNode = node;
        }
        
        // Process locks for this level pack
        for (lockChild in lockArray)
        {
            var lockType : String = Reflect.field(lockChild, "lockType");
            var lockKeyData : Dynamic = Reflect.field(lockChild, "lockKey");
            var levelLock : ICgsLevelLock = m_lockFactory.getLockInstance(lockType, lockKeyData);
            m_packLocks.push(levelLock);
        }
        
        return previousLevel;
    }
    
    /**
		 * Helper that turns a node data that is simply a string into an actual object that can be processed.
		 * @param	filename
		 * @return
		 */
    private function convertToData(filename : String) : Dynamic
    {
        var result : Dynamic = {};
        
        Reflect.setField(result, "fileName", filename);
        Reflect.setField(result, "nodeType", "level");
        
        return result;
    }
    
    /**
		 * Creates a new node with the given node data. If appropriate, will add a lock on the previous node.
		 * @param	nodeData
		 * @param	previousNode
		 * @return
		 */
    private function createNode(nodeData : Dynamic, previousNode : ICgsLevelNode) : ICgsLevelNode
    {
        var result : ICgsLevelNode;
        
        // Process node type
        var nodeType : String = Reflect.field(nodeData, "nodeType");
        
        // Add sequential locks, but not for the first node because it is unlocked by the level pack
        if (m_playSequentially && previousNode != null)
        {
            addSequentialLocks(nodeData, previousNode);
        }
        
        // Node type is levelPack, lets create a level pack!
        if (nodeType != null && nodeType.toLowerCase() == "levelpack")
        {
            result = createLevelPack(nodeData);
        }
        else
        {
            //If node is a level. Default is a level, therefore if nodeType field does not exist in JSON file, creates a level.  // If nodeType is anything else, even blank or null, we will assume we want a LevelLeaf  
            {
                result = createLevelLeaf(nodeData);
            }
        }
        
        return result;
    }
    
    /**
		 * Creates a new level pack using the properties defined in the given childObj.
		 * @param	childObj
		 * @return
		 */
    private function createLevelPack(childObj : Dynamic) : ICgsLevelNode
    {
        // Use default level pack type that the extending game can choose if no level pack type specified
        var levelPackType : String = Reflect.field(childObj, "packType");
        if (levelPackType == "" || levelPackType == null)
        {
            levelPackType = m_levelFactory.defaultLevelPackType;
        }
        
        // Create level pack
        var node : ICgsLevelNode = m_levelFactory.getNodeInstance(levelPackType);
        
        return node;
    }
    
    /**
		 * Creates a new level leaf using the properties defined in the given childObj.
		 * @param	childObj
		 * @return
		 */
    private function createLevelLeaf(childObj : Dynamic) : ICgsLevelNode
    {
        // Use default level type that the extending game can choose if no level type specified
        var levelType : String = Reflect.field(childObj, "levelType");
        if (levelType == "" || levelType == null)
        {
            levelType = m_levelFactory.defaultLevelType;
        }
        
        // Create level
        var node : ICgsLevelNode = m_levelFactory.getNodeInstance(levelType);
        
        return node;
    }
    
    /**
		 * Add a sequential lock on the given previous level if we are adding sequential locks for this level pack.
		 * @param	childObj
		 * @param	previousLevel
		 */
    private function addSequentialLocks(childObj : Dynamic, previousNode : ICgsLevelNode) : Void
    {
        // Add locks if none exist
        if (!Reflect.hasField(childObj, "locks"))
        {
            Reflect.setField(childObj, "locks", new Array<Dynamic>());
        }
        var childLocks : Array<Dynamic> = try cast(Reflect.field(childObj, "locks"), Array<Dynamic>) catch(e:Dynamic) null;
        
        // Add lock on previous node
        var lockObj : Dynamic = {};
        Reflect.setField(lockObj, "lockType", CgsNodeLock.LOCK_TYPE);
        var lockKey : Dynamic = {};
        Reflect.setField(lockKey, Std.string(CgsNodeLock.NODE_NAME_KEY), previousNode.nodeName);
        Reflect.setField(lockObj, "lockKey", lockKey);
        childLocks.push(lockObj);
    }
    
    /**
		 * @inheritDoc
		 */
    override public function destroy() : Void
    {
        reset();
        
        // Null out perma-state
        m_levelManager = null;
        m_levelFactory = null;
        m_lockFactory = null;
        m_nodeLabel = -1;
        
        // Null out reset state
        m_levelData = null;
        m_packLocks = null;
        
        super.destroy();
    }
    
    /**
		 * @inheritDoc
		 */
    public function reset() : Void
    {
        while (m_levelData.length > 0)
        {
            var node : ICgsLevelNode = m_levelData.pop();
            m_levelFactory.recycleNodeInstance(node);
        }
        m_levelData = new Array<ICgsLevelNode>();
        m_currLevelIndex = -1;
        m_progressionName = "";
        m_playSequentially = false;
        while (m_packLocks.length > 0)
        {
            var lock : ICgsLevelLock = m_packLocks.pop();
            m_lockFactory.recycleLock(lock);
        }
        m_packLocks = new Array<ICgsLevelLock>();
        m_parent = null;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_firstLeaf() : ICgsLevelLeaf
    {
        var result : ICgsLevelLeaf = null;
        if (m_levelData.length > 0)
        {
            var firstNode : ICgsLevelNode = m_levelData[0];
            if (Std.is(firstNode, ICgsLevelLeaf))
            {
                result = try cast(firstNode, ICgsLevelLeaf) catch(e:Dynamic) null;
            }
            else
            {
                if (Std.is(firstNode, ICgsLevelPack))
                {
                    result = (try cast(firstNode, ICgsLevelPack) catch(e:Dynamic) null).firstLeaf;
                }
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_lastLeaf() : ICgsLevelLeaf
    {
        var result : ICgsLevelLeaf = null;
        if (m_levelData.length > 0)
        {
            var lastNode : ICgsLevelNode = m_levelData[m_levelData.length - 1];
            if (Std.is(lastNode, ICgsLevelLeaf))
            {
                result = try cast(lastNode, ICgsLevelLeaf) catch(e:Dynamic) null;
            }
            else
            {
                if (Std.is(lastNode, ICgsLevelPack))
                {
                    result = (try cast(lastNode, ICgsLevelPack) catch(e:Dynamic) null).lastLeaf;
                }
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_length() : Float
    {
        return m_levelData.length;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_levelNames() : Array<String>
    {
        var result : Array<String> = new Array<String>();
        
        // Collect the names of our children
        for (node in nodes)
        {
            if (Std.is(node, ICgsLevelPack))
            {
                result = result.concat((try cast(node, ICgsLevelPack) catch(e:Dynamic) null).levelNames);
            }
            else
            {
                if (Std.is(node, ICgsLevelLeaf))
                {
                    result.push(node.nodeName);
                }
            }
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_nodeName() : String
    {
        return m_progressionName;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_nodes() : Array<ICgsLevelNode>
    {
        return m_levelData;
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
        return Type.getClassName(Type.getClass(this)).split(".").pop(); // NODE_TYPE;
    }
    
    /**
		 * 
		 * Level Leaf Status State
		 * 
		**/
    
		
	private function walkLevelData(levelPackCB : ICgsLevelPack -> Void, levelLeafCB : ICgsLevelLeaf -> Void = null) : Void
	{
        for (childNode in m_levelData)
        {
            if (Std.is(childNode, ICgsLevelPack))
            {
				if (levelPackCB != null)
				{
					var cn : ICgsLevelPack = cast childNode;
					levelPackCB(cn);
				}
            }
			else if (Std.is(childNode, ICgsLevelLeaf))
			{
				if (levelLeafCB != null)
				{
					var cn : ICgsLevelLeaf = cast childNode;

					levelLeafCB(cn);
				}
			}
        }
	}
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsCompleted() : Int
    {
        var result : Int = 0;
		
		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelLeafsCompleted;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				if (levelLeaf.isComplete)
				{
					result++;
				}
			});
		
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsUncompleted() : Int
    {
        var result : Int = 0;

		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelLeafsUncompleted;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				if (!levelLeaf.isComplete)
				{
					result++;
				}
			});
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsPlayed() : Int
    {
        var result : Int = 0;

		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelLeafsPlayed;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				if (levelLeaf.isPlayed)
				{
					result++;
				}
			}
		);

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsUnplayed() : Int
    {
        var result : Int = 0;

		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelLeafsUnplayed;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				if (!levelLeaf.isPlayed)
				{
					result++;
				}
			}
		);

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsLocked() : Int
    {
        var result : Int = 0;

		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelLeafsLocked;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				if (levelLeaf.isLocked)
				{
					result++;
				}
			}
		);

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelLeafsUnlocked() : Int
    {
        var result : Int = 0;

		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelLeafsUnlocked;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				if (!levelLeaf.isLocked)
				{
					result++;
				}
			}
		);

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numTotalLevelLeafs() : Int
    {
        var result : Int = 0;

		walkLevelData(
			function(levelPack : ICgsLevelPack)
			{
				result += levelPack.numTotalLevelLeafs;
			},
			function(levelLeaf : ICgsLevelLeaf)
			{
				result++;
			}
		);

        return result;
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
        // Dont forget self
        var result : Int = (isComplete) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksCompleted;
			});

		return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksUncompleted() : Int
    {
        // Dont forget self
        var result : Int = !(isComplete) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksUncompleted;
			});

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksFullyPlayed() : Int
    {
        // Dont forget self
        var result : Int = (isFullyPlayed) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksFullyPlayed;
			});

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksPlayed() : Int
    {
        // Dont forget self
        var result : Int = (isPlayed) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksPlayed;
			});

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksUnplayed() : Int
    {
        // Dont forget self
        var result : Int = !(isPlayed) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksUnplayed;
			});

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksLocked() : Int
    {
        // Dont forget self
        var result : Int = (isLocked) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksLocked;
			});

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numLevelPacksUnlocked() : Int
    {
        // Dont forget self
        var result : Int = !(isLocked) ? 1 : 0;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numLevelPacksUnlocked;
			});

        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_numTotalLevelPacks() : Int
    {
        // Dont forget self
        var result : Int = 1;
		
		walkLevelData( function (levelPack : ICgsLevelPack)
			{
				result += levelPack.numTotalLevelPacks;
			});

        return result;
    }
    
    /**
		 * 
		 * Status state
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_completionValue() : Float
    {
        // Completion value for a level pack is the average of the completions of its children
        var result : Float = -1;
        for (childNode in m_levelData)
        {
            // Only add completion values for played nodes. Unplayed nodes contribute a completion value of 0 for this calculation.
            if (childNode.isPlayed)
            {
                // This level pack is only partly complete (played) if at least one level in it has been played
                if (result < 0)
                {
                    result = 0;
                }
                
                // Sum child completions
                result = result + childNode.completionValue;
            }
        }
        if (result >= 0)
        {
            result = result / m_levelData.length;
        }
        return result;
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
            for (aLock in m_packLocks)
            {
                result = result || aLock.isLocked;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_isFullyPlayed() : Bool
    {
        var result : Bool = true;
        for (childNode in m_levelData)
        {
            // All children need to have been played to be "fully" played
            if (Std.is(childNode, ICgsLevelPack))
            {
                result = result && (try cast(childNode, ICgsLevelPack) catch(e:Dynamic) null).isFullyPlayed;
            }
            else
            {
                if (Std.is(childNode, ICgsLevelLeaf))
                {
                    result = result && childNode.isPlayed;
                }
            }
			if (!result)
			{
				return result;
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
		 * Level Leaf Status Management - All
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsComplete() : Void
    {
        markAllLevelLeafsAsCompletionValue(m_levelManager.isCompleteCompletionValue);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsPlayed() : Void
    {
        markAllLevelLeafsAsCompletionValue(0);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsUnplayed() : Void
    {
        markAllLevelLeafsAsCompletionValue(-1);
    }
    
    /**
		 * @inheritDoc
		 */
    public function markAllLevelLeafsAsCompletionValue(value : Float) : Void
    {
		walkLevelData(
			function (levelPack : ICgsLevelPack){ levelPack.markAllLevelLeafsAsCompletionValue(value); },
			function (levelLeaf : ICgsLevelLeaf){ markLevelLeafAsCompletionValue(levelLeaf, value); }
		);
    }
    
    /**
		 * Marks the given level leaf with the given completion value.
		 * @param	nodeLabel - The level leaf to marked with the given value.
		 * @param	value - The completion value to be assigned.
		 */
    private function markLevelLeafAsCompletionValue(levelLeaf : ICgsLevelLeaf, value : Float) : Void
    {
        var data : Dynamic = {};
        Reflect.setField(data, Std.string(CgsLevelProgressionTypes.NODE_COMPLETION_KEY), value);
        levelLeaf.updateNode(levelLeaf.nodeLabel, data);
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
        m_packLocks.push(aLock);
        return true;
    }
    
    /**
		 * @inheritDoc
		 */
    public function hasLock(lockType : String, keyData : Dynamic) : Bool
    {
        var result : Bool = false;
        for (lock in m_packLocks)
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
        for (lock in m_packLocks)
        {
            if (lock.lockType == lockType && lock.doesKeyMatch(keyData))
            {
                m_packLocks.splice(Lambda.indexOf(m_packLocks, lock), 1);
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
        // Check if we are the desired node
        if (m_nodeLabel == nodeLabel)
        {
            return true;
        }
        
        // Check if the desired node is one of our children
        var result : Bool = false;
        for (i in 0...m_levelData.length)
        {
            result = m_levelData[i].containsNode(nodeLabel);
            if (result)
            {
                break;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNode(nodeLabel : Int) : ICgsLevelNode
    {
        // Check if we are the desired node
        if (m_nodeLabel == nodeLabel)
        {
            return this;
        }
        
        // Check if the desired node is one of our children
        var result : ICgsLevelNode = null;
        for (i in 0...m_levelData.length)
        {
            result = m_levelData[i].getNode(nodeLabel);
            if (result != null)
            {
                break;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getNodeByName(nodeName : String) : ICgsLevelNode
    {
        // Check if we are the desired node
        if (m_progressionName == nodeName)
        {
            return this;
        }
        
        // Check if the desired node is one of our children
        var result : ICgsLevelNode = null;
        for (i in 0...m_levelData.length)
        {
            result = m_levelData[i].getNodeByName(nodeName);
            if (result != null)
            {
                break;
            }
        }
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function loadNodeFromCache(userId : String) : Void
    {
        for (i in 0...m_levelData.length)
        {
            m_levelData[i].loadNodeFromCache(userId);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    public function updateNode(nodeLabel : Int, data : Dynamic = null) : Bool
    {
        var result : Bool = false;
        
        // Check if we are the desired node
        if (m_nodeLabel == nodeLabel)
        {
            // Do not currently accept any updates to level packs
            result = true;
        }
        
        // Check if the desired node is one of our children
        for (i in 0...m_levelData.length)
        {
            // If we found the right node, break
            if (m_levelData[i].updateNode(nodeLabel, data))
            {
                result = true;
                break;
            }
        }
        return result;
    }
    
    /**
		 * 
		 * Updating Progression
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function addNodeToProgression(nodeData : Dynamic, parentPackName : String = null, index : Int = -1) : Bool
    {
        var result : Bool = false;
        
        // We are the parent, time to add a new node
        if (nodeName == parentPackName)
        {
            // Convert the nodeData to a data object if it is in fact only a String.
            if (Std.is(nodeData, String))
            {
                nodeData = convertToData(Std.string(nodeData));
            }
            
            // Decide what the previous node, and next node, are
            var previousNode : ICgsLevelNode = getPreviousNodeFromIndex(index);
            
            // Create the node
            var node : ICgsLevelNode = createNode(nodeData, previousNode);
            
            // Add new node to nodes
            if (index < 0 || index >= nodes.length)
            {
                nodes.push(node);
            }
            else
            {
				nodes.insert(index, node);
            }
            
            // Find the previous level
            var previousLevel : ICgsLevelLeaf = getPrevLevel(node.nodeLabel);
            
            // Next level is the level that comes after the previous level, or the first level in ourselves
            // if the previous level is null (that is, index == 0)
            var nextLevel : ICgsLevelLeaf = getNextLevel(node.nodeLabel);
            
            // Init the node
            node.init(this, previousLevel, nodeData);
            
            // Adjust leaf linked list
            if (Std.is(node, ICgsLevelPack))
            {
                var lastLevel : ICgsLevelLeaf = (try cast(node, ICgsLevelPack) catch(e:Dynamic) null).lastLeaf;
                
                // Adjust linked list
                if (nextLevel != null)
                {
                    nextLevel.previousLevel = lastLevel;
                }
                if (lastLevel != null)
                {
                    lastLevel.nextLevel = nextLevel;
                }
            }
            else
            {
                if (Std.is(node, ICgsLevelLeaf))
                {
                    // Adjust linked list
                    if (nextLevel != null)
                    {
                        nextLevel.previousLevel = (try cast(node, ICgsLevelLeaf) catch(e:Dynamic) null);
                    }
                    (try cast(node, ICgsLevelLeaf) catch(e:Dynamic) null).nextLevel = nextLevel;
                }
            }
            
            // Adjust any sequential locks
            if (m_playSequentially)
            {
                // Get next node
                var nextNode : ICgsLevelNode = getNextNodeFromIndex(index);
                
                if (nextNode != null)
                {
                    // Data for new sequential lock
                    var newLockData : Dynamic = {};
                    Reflect.setField(newLockData, Std.string(CgsNodeLock.NODE_NAME_KEY), node.nodeName);
                    
                    if (previousNode != null)
                    {
                        // Data for old sequential lock, which should be removed
                        var previousLockData : Dynamic = {};
                        Reflect.setField(previousLockData, Std.string(CgsNodeLock.NODE_NAME_KEY), previousNode.nodeName);
                        
                        // Change locks
                        nextNode.editLock(CgsNodeLock.LOCK_TYPE, previousLockData, newLockData);
                    }
                    else
                    {
                        nextNode.addLock(CgsNodeLock.LOCK_TYPE, newLockData);
                    }
                }
            }
            
            result = true;
        }
        else
        {
            // We are not the parent, but one of our children might be
            {
                for (childNode in nodes)
                {
                    // Child is a level pack, do the recursive case
                    if (Std.is(childNode, ICgsLevelPack))
                    {
                        result = (try cast(childNode, ICgsLevelPack) catch(e:Dynamic) null).addNodeToProgression(nodeData, parentPackName, index);
                        if (result)
                        {
                            break;
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    /**
		 * Finds and returns the node that comes before the given index.
		 * @param	index
		 * @return
		 */
    private function getPreviousNodeFromIndex(index : Int) : ICgsLevelNode
    {
        var result : ICgsLevelNode = null;
        
        if (index < 0 || index > nodes.length)
        {
            // Unspecified index, or index out of bounds, puts the new node at the end of the node list
            result = nodes[nodes.length - 1];
        }
        else
        {
            if (index > 0)
            {
                // A non-zero index puts the new node after another node
                result = nodes[index - 1];
            }
        }
        
        return result;
    }
    
    /**
		 * Finds and returns the node that comes before the given index.
		 * @param	index
		 * @return
		 */
    private function getNextNodeFromIndex(index : Int) : ICgsLevelNode
    {
        var result : ICgsLevelNode = null;
        
        if (index < 0 || index + 1 >= nodes.length || index == MathUtils.INT_MAX)
        {
            // Unspecified index, or index out of bounds, puts the new node at the end of the node list
            result = null;
        }
        else
        {
            if (index >= 0)
            {
                // A non-zero index puts the new node after another node
                result = nodes[index + 1];
            }
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function editNodeInProgression(nameOfNode : String, newNodeData : Dynamic) : Bool
    {
        var result : Bool = false;
        
        for (childNode in nodes)
        {
            // We found the node being edited
            if (childNode.nodeName == nameOfNode)
            {
                var index : Int = Lambda.indexOf(nodes, childNode);
                if (removeNodeFromProgression(childNode.nodeName))
                {
                    addNodeToProgression(newNodeData, nodeName, index);
                }
                result = true;
                break;
            }
            else
            {
                // Recurse
				if (Std.is(childNode, ICgsLevelPack))
                {
                    result = (try cast(childNode, ICgsLevelPack) catch(e:Dynamic) null).editNodeInProgression(nameOfNode, newNodeData);
                    if (result)
                    {
                        break;
                    }
                }
            }
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeNodeFromProgression(nodeName : String) : Bool
    {
        var result : Bool = false;
        
        // Search for the node within our children
        for (childNode in nodes)
        {
            // Found the node, now remove it and recycle it
            if (childNode.nodeName == nodeName)
            {
                // Get index of the node
                var index : Int = Lambda.indexOf(nodes, childNode);  // Adjust level linked-list  ;
                
                
                
                if (Std.is(childNode, ICgsLevelPack))
                {
                    var firstLevel : ICgsLevelLeaf = (try cast(childNode, ICgsLevelPack) catch(e:Dynamic) null).firstLeaf;
                    var lastLevel : ICgsLevelLeaf = (try cast(childNode, ICgsLevelPack) catch(e:Dynamic) null).lastLeaf;
                    
                    // Adjust linked list
                    if (firstLevel != null && firstLevel.previousLevel != null)
                    {
                        firstLevel.previousLevel.nextLevel = ((lastLevel != null)) ? lastLevel.nextLevel : null;
                    }
                    if (lastLevel != null && lastLevel.nextLevel != null)
                    {
                        lastLevel.nextLevel.previousLevel = ((firstLevel != null)) ? firstLevel.previousLevel : null;
                    }
                }
                else
                {
                    if (Std.is(childNode, ICgsLevelLeaf))
                    {
                        var previousLevel : ICgsLevelLeaf = (try cast(childNode, ICgsLevelLeaf) catch(e:Dynamic) null).previousLevel;
                        var nextLevel : ICgsLevelLeaf = (try cast(childNode, ICgsLevelLeaf) catch(e:Dynamic) null).nextLevel;
                        
                        if (previousLevel != null)
                        {
                            previousLevel.nextLevel = nextLevel;
                        }
                        if (nextLevel != null)
                        {
                            nextLevel.previousLevel = previousLevel;
                        }
                    }
                }
                
                // Adjust locks
                if (m_playSequentially)
                {
                    var previousNode : ICgsLevelNode = getPreviousNodeFromIndex(index);
                    var nextNode : ICgsLevelNode = getNextNodeFromIndex(index);
                    
                    if (nextNode != null)
                    {
                        // Data for old sequential lock, which should be removed
                        var previousLockData : Dynamic = {};
                        Reflect.setField(previousLockData, Std.string(CgsNodeLock.NODE_NAME_KEY), childNode.nodeName);
                        
                        if (previousNode != null)
                        {
                            // Data for new sequential lock
                            var newLockData : Dynamic = {};
                            Reflect.setField(newLockData, Std.string(CgsNodeLock.NODE_NAME_KEY), previousNode.nodeName);
                            
                            // Change locks
                            nextNode.editLock(CgsNodeLock.LOCK_TYPE, previousLockData, newLockData);
                        }
                        else
                        {
                            nextNode.removeLock(CgsNodeLock.LOCK_TYPE, previousLockData);
                        }
                    }
                }
                
                // Remove node
                nodes.splice(index, 1);
                m_levelFactory.recycleNodeInstance(childNode);
                result = true;
                break;
            }
            else
            {
                // Recurse until we find the node to be removed
				if (Std.is(childNode, ICgsLevelPack))
                {
                    result = (try cast(childNode, ICgsLevelPack) catch(e:Dynamic) null).removeNodeFromProgression(nodeName);
                    if (result)
                    {
                        break;
                    }
                }
            }
        }
        
        return result;
    }
    
    /**
		 * 
		 * Tree Functions - Level Advancement
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function getNextLevel(aNodeLabel : Int = -1) : ICgsLevelLeaf
    {
        var result : ICgsLevelLeaf = null;
        
        // Find the node with the given label, get the level that comes after it (if any).
        if (aNodeLabel >= 0)
        {
            // Recursively search for the node and get the level that comes after it
            for (node in nodes)
            {
                // We contain the node, time to find the next node and get the level from it
                if (node.nodeLabel == aNodeLabel)
                {
                    var nodeIndex : Int = Lambda.indexOf(nodes, node);
                    
                    // We do not contain the next node
                    if (nodeIndex == nodes.length - 1)
                    {
                        // We do not contain the level that comes after the desired node, so check our parent for it
                        if (m_parent != null)
                        {
                            result = m_parent.getNextLevel(nodeLabel);
                        }
                    }
                    else
                    {
                        // We contain the next node
                        {
                            var nextNode : ICgsLevelNode = nodes[nodeIndex + 1];
                            if (Std.is(nextNode, ICgsLevelPack))
                            {
                                // The next node is a level pack, get the first leaf
                                result = (try cast(nextNode, ICgsLevelPack) catch(e:Dynamic) null).firstLeaf;
                            }
                            else
                            {
                                if (Std.is(nextNode, ICgsLevelLeaf))
                                {
                                    // The next node is a leaf, return it
                                    result = try cast(nextNode, ICgsLevelLeaf) catch(e:Dynamic) null;
                                }
                            }
                        }
                    }
                    
                    // We found the node we want the next level for, no more searching needed
                    break;
                }
                else
                {
                    if (Std.is(node, ICgsLevelPack))
                    {
                        // Recursive case
                        result = (try cast(node, ICgsLevelPack) catch(e:Dynamic) null).getNextLevel(aNodeLabel);
                        if (result != null)
                        {
                            break;
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    /**
		 * @inheritDoc
		 */
    public function getPrevLevel(aNodeLabel : Int = -1) : ICgsLevelLeaf
    {
        var result : ICgsLevelLeaf = null;
        
        // Find the node with the given label, get the level that comes before it (if any).
        if (aNodeLabel >= 0)
        {
            // Recursively search for the node and get the level that comes before it
            for (node in nodes)
            {
                // We contain the node, time to find the next node and get the level from it
                if (node.nodeLabel == aNodeLabel)
                {
                    var nodeIndex : Int = Lambda.indexOf(nodes, node);
                    
                    // We do not contain the previous node
                    if (nodeIndex == 0)
                    {
                        // We do not contain the level that comes before the desired node, so check our parent for it
                        if (m_parent != null)
                        {
                            result = m_parent.getPrevLevel(nodeLabel);
                        }
                    }
                    else
                    {
                        // We contain the previous node
                        {
                            var previousNode : ICgsLevelNode = nodes[nodeIndex - 1];
                            if (Std.is(previousNode, ICgsLevelPack))
                            {
                                // The previous node is a level pack, get the last leaf
                                result = (try cast(previousNode, ICgsLevelPack) catch(e:Dynamic) null).lastLeaf;
                            }
                            else
                            {
                                if (Std.is(previousNode, ICgsLevelLeaf))
                                {
                                    // The previous node is a leaf, return it
                                    result = try cast(previousNode, ICgsLevelLeaf) catch(e:Dynamic) null;
                                }
                            }
                        }
                    }
                    
                    // We found the node we want the next level for, no more searching needed
                    break;
                }
                else
                {
                    if (Std.is(node, ICgsLevelPack))
                    {
                        // Recursive case
                        result = (try cast(node, ICgsLevelPack) catch(e:Dynamic) null).getPrevLevel(aNodeLabel);
                        if (result != null)
                        {
                            break;
                        }
                    }
                }
            }
        }
        
        return result;
    }
}
