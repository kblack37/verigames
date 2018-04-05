package system;


class VerigameServerConstants
{
    public static inline var VERIGAME_GAME_ID : Int = 23;
    
    public static inline var VERIGAME_DEV_SKEY : String = "8847ab6e6908697ada1c8ac27287cd02";
    public static inline var VERIGAME_SKEY : String = "bde9564c55a99a60bf0deb0f5be44b6f";
    
    public static var MOCHI_GAME_ID : String = "953dee7d3049e1a3";
    
    public static inline var VERIGAME_GAME_NAME : String = "pipejam";
    
    public static inline var VERIGAME_VERSION_SEEDLING_BETA : Int = 4;
    public static inline var VERIGAME_VERSION_GRID_WORLD_BETA : Int = 5;
    
    public static inline var VERIGAME_CATEGORY_SEEDLING_BETA : Int = 19;
    public static inline var VERIGAME_CATEGORY_DARPA_FRIENDS_FAMILY_BETA_JULY_1_2013 : Int = 20;
    
    public static inline var VERIGAME_QUEST_ID_UNDEFINED_WORLD : Int = 66;
    
    public static inline var VERIGAME_ACTION_START_LEVEL : Int = 1;
    public static inline var VERIGAME_ACTION_SWITCH_BOARDS : Int = 2;  // deprecated  
    public static inline var VERIGAME_ACTION_SAVE_LEVEL_PROGRESS : Int = 3;
    public static inline var VERIGAME_ACTION_CHANGE_EDGESET_WIDTH : Int = 4;
    public static inline var VERIGAME_ACTION_ADD_PIPE_BUZZSAW : Int = 5;  // deprecated  
    public static inline var VERIGAME_ACTION_REMOVE_PIPE_BUZZSAW : Int = 6;  // deprecated  
    public static inline var VERIGAME_ACTION_CHANGE_PIPE_STAMPS : Int = 7;
    // UI actions
    public static inline var VERIGAME_ACTION_SAVE_LAYOUT : Int = 20;
    public static inline var VERIGAME_ACTION_SUBMIT_SCORE : Int = 21;
    public static inline var VERIGAME_ACTION_LOAD_LAYOUT : Int = 22;
    
    public static inline var QUEST_PARAMETER_LEVEL_INFO : String = "levelInfo";
    
    public static inline var ACTION_PARAMETER_START_INFO : String = "startInfo";
    public static inline var ACTION_PARAMETER_BOARD_NAME : String = "boardName";  // deprecated  
    public static inline var ACTION_PARAMETER_LEVEL_NAME : String = "levelName";
    public static inline var ACTION_PARAMETER_EDGESET_WIDTH : String = "edgeWidth";
    public static inline var ACTION_PARAMETER_PROP_CHANGED : String = "propChanged";
    public static inline var ACTION_PARAMETER_PROP_VALUE : String = "propValue";
    public static inline var ACTION_PARAMETER_EDGE_ID : String = "edgeId";
    public static inline var ACTION_PARAMETER_VAR_ID : String = "varId";
    public static inline var ACTION_PARAMETER_STAMP_DICTIONARY : String = "stampDict";
    // UI action fields
    public static inline var ACTION_PARAMETER_LAYOUT_NAME : String = "layoutName";
    public static inline var ACTION_PARAMETER_START_SCORE : String = "start_score";
    public static inline var ACTION_PARAMETER_TARGET_SCORE : String = "target_score";
    public static inline var ACTION_PARAMETER_SCORE : String = "score";
    public static inline var ACTION_PARAMETER_SCORE_CHANGE : String = "score_chg";
    public static inline var ACTION_VALUE_EDGE_WIDTH_WIDE : String = "w";
    public static inline var ACTION_VALUE_EDGE_WIDTH_NARROW : String = "n";

    public function new()
    {
    }
}

