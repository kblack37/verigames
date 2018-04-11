package cgs.levelProgression.util;


/**
	 * ...
	 * @author Rich
	 */
class CgsLevelProgressionTypes
{
    // Status types
    public static inline var NODE_COMPLETION_KEY : String = "completionOfNode";
    public static inline var NODE_LOCKING_KEY : String = "isNodeLocked";
    public static inline var NODE_COMPLETION_UPDATED_KEY : String = "completionUpdated";
    
    // Derived status
    public static inline var NODE_LOCKED : String = "nodeLocked";
    public static inline var NODE_UNLOCKED : String = "nodeUnlocked";
    public static inline var NODE_PLAYED : String = "nodePlayed";
    public static inline var NODE_UNPLAYED : String = "nodeUnplayed";
    public static inline var NODE_COMPLETE : String = "nodeComplete";
    public static inline var NODE_UNCOMPLETE : String = "nodeUncomplete";

    public function new()
    {
    }
}

