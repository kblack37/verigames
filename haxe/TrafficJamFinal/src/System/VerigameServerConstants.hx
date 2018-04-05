package system;


/**
	 * ...
	 * @author Tim Pavlik
	 */
class VerigameServerConstants
{
    public static inline var VERIGAME_GAME_ID : Int = 23;
    
    public static inline var VERIGAME_DEV_SKEY : String = "8847ab6e6908697ada1c8ac27287cd02";
    public static inline var VERIGAME_SKEY : String = "bde9564c55a99a60bf0deb0f5be44b6f";
    
    public static inline var VERIGAME_GAME_NAME : String = "pipejam";
    
    public static inline var VERIGAME_VERSION_SEEDLING_BETA : Int = 4;
    
    public static inline var VERIGAME_CATEGORY_SEEDLING_BETA : Int = 19;
    
    public static inline var VERIGAME_QUEST_ID_UNDEFINED_WORLD : Int = 66;
    
    public static inline var VERIGAME_ACTION_START : Int = 1;
    public static inline var VERIGAME_ACTION_SWITCH_BOARDS : Int = 2;
    public static inline var VERIGAME_ACTION_SAVE_WORLD_PROGRESS : Int = 3;
    public static inline var VERIGAME_ACTION_CHANGE_PIPE_WIDTH : Int = 4;
    public static inline var VERIGAME_ACTION_ADD_PIPE_BUZZSAW : Int = 5;
    public static inline var VERIGAME_ACTION_REMOVE_PIPE_BUZZSAW : Int = 6;
    public static inline var VERIGAME_ACTION_CHANGE_PIPE_STAMPS : Int = 7;
    
    public static inline var ACTION_PARAMETER_START_INFO : String = "startInfo";
    public static inline var ACTION_PARAMETER_BOARD_NAME : String = "boardName";
    public static inline var ACTION_PARAMETER_LEVEL_NAME : String = "levelName";
    public static inline var ACTION_PARAMETER_PIPE_WIDTH : String = "pipeWidth";
    public static inline var ACTION_PARAMETER_PIPE_EDGE_ID : String = "edgeId";
    public static inline var ACTION_PARAMETER_STAMP_DICTIONARY : String = "stampDict";
    
    public static inline var ACTION_VALUE_PIPE_WIDTH_WIDE : String = "W";
    public static inline var ACTION_VALUE_PIPE_WIDTH_NARROW : String = "N";

    public function new()
    {
    }
}

