package cgs.levelProgression.util;

import cgs.levelProgression.ICgsLevelManager;
import cgs.levelProgression.nodes.CgsLevelLeaf;
import cgs.levelProgression.nodes.CgsLevelPack;
import cgs.levelProgression.nodes.ICgsLevelNode;
import cgs.user.ICgsUserManager;

/**
	 * ...
	 * @author Rich
	 */
class CgsLevelFactory implements ICgsLevelFactory
{
    private var levelManager(get, never) : ICgsLevelManager;
    private var lockFactory(get, never) : ICgsLockFactory;
    private var userManager(get, never) : ICgsUserManager;
    public var defaultLevelType(get, set) : String;
    public var defaultLevelPackType(get, set) : String;

    // Internal State
    private var m_levelManager : ICgsLevelManager;
    private var m_lockFactory : ICgsLockFactory;
    private var m_userManager : ICgsUserManager;
    private var m_nextLabel : Int;
    private var m_levelNodeStorage : Dynamic;  //holds all the different types of levels & packs  
    
    // State
    private var m_defaultLevelType : String = CgsLevelLeaf.NODE_TYPE;
    private var m_defaultLevelPackType : String = CgsLevelPack.NODE_TYPE;
    
	@:keep
    public function new(levelManager : ICgsLevelManager, lockFactory : ICgsLockFactory, userManager : ICgsUserManager)
    {
        m_lockFactory = lockFactory;
        m_levelManager = levelManager;
        m_userManager = userManager;
        m_nextLabel = 1;
        m_levelNodeStorage = {};
    }
    
    /**
		 * 
		 * Internal State
		 * 
		**/
    
    /**
		 * Generates and returns a new unique level label.
		 * @return
		 */
    private function generateLevelLabel() : Int
    {
        var result : Int = m_nextLabel;
        m_nextLabel++;
        return (result);
    }
    
    /**
		 * Returns the levelManager instance used by this level factory.
		 */
    private function get_levelManager() : ICgsLevelManager
    {
        return m_levelManager;
    }
    
    /**
		 * Returns the lockFactory instance used by this level factory.
		 */
    private function get_lockFactory() : ICgsLockFactory
    {
        return m_lockFactory;
    }
    
    /**
		 * Returns the userManager instance used by this level factory.
		 */
    private function get_userManager() : ICgsUserManager
    {
        return m_userManager;
    }
    
    /**
		 * 
		 * State
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    private function get_defaultLevelType() : String
    {
        return m_defaultLevelType;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_defaultLevelType(value : String) : String
    {
        m_defaultLevelType = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_defaultLevelPackType() : String
    {
        return m_defaultLevelPackType;
    }
    
    /**
		 * @inheritDoc
		 */
    private function set_defaultLevelPackType(value : String) : String
    {
        m_defaultLevelPackType = value;
        return value;
    }
    
    /**
		 * 
		 * Node Management
		 * 
		**/
    
    /**
		 * @inheritDoc
		 */
    public function getNodeInstance(typeID : String) : ICgsLevelNode
    {
        var result : ICgsLevelNode;
        
        // Get the node storage for this type, creating the storage if this is a new type
        if (!Reflect.hasField(m_levelNodeStorage, typeID))
        {
            // create new array for this type id
            Reflect.setField(m_levelNodeStorage, typeID, new Array<Dynamic>());
        }
        var nodeStorage : Array<Dynamic> = Reflect.field(m_levelNodeStorage, typeID);
        
        // Get a node out of storage
        if (nodeStorage.length > 0)
        {
            result = nodeStorage.pop();
        }
        else
        {
            // Generate a new node
			var levelLabel : Int = generateLevelLabel();
			result = generateNodeInstance(typeID, levelLabel);
        }
        
        return result;
    }
    
    /**
		 * Creates and returns a new node instance of the given typeID and level label.
		 * @param	typeID They type of level to create.
		 * @param	levelLabel The label of the new node.
		 * @return
		 */
    private function generateNodeInstance(typeID : String, nodeLabel : Int) : ICgsLevelNode
    {
        var result : ICgsLevelNode = null;
        
        switch (typeID)
        {
            case CgsLevelLeaf.NODE_TYPE:
                result = new CgsLevelLeaf(levelManager, userManager, lockFactory, nodeLabel);
            case CgsLevelPack.NODE_TYPE:
                result = new CgsLevelPack(levelManager, this, lockFactory, nodeLabel);
        }
        
        return (result);
    }
    
    /**
		 * @inheritDoc
		 */
    public function recycleNodeInstance(node : ICgsLevelNode) : Void
    {
        node.reset();
        Reflect.field(m_levelNodeStorage, Std.string(node.nodeType)).push(node);
    }
}

