package system;


class VerigameServerConstants
{
    public static inline var VERIGAME_GAME_ID : Int = 23;
    
    public static inline var VERIGAME_DEV_SKEY : String = "8847ab6e6908697ada1c8ac27287cd02";
    public static inline var VERIGAME_SKEY : String = "bde9564c55a99a60bf0deb0f5be44b6f";
    
    public static inline var VERIGAME_GAME_NAME : String = "pipejam";
    
    public static inline var VERIGAME_VERSION_SEEDLING_BETA : Int = 4;
    public static inline var VERIGAME_VERSION_GRID_WORLD_BETA : Int = 5;
    
    public static inline var VERIGAME_CATEGORY_SEEDLING_BETA : Int = 19;
    public static inline var VERIGAME_CATEGORY_DARPA_FRIENDS_FAMILY_BETA_JULY_1_2013 : Int = 20;
    public static inline var VERIGAME_CATEGORY_PARADOX_FRIENDS_FAMILY_BETA_MAY_15_2015 : Int = 21;
    public static inline var VERIGAME_CATEGORY_PARADOX_MTURK_JUNE_2015 : Int = 22;
    
    public static inline var VERIGAME_QUEST_ID_UNDEFINED_WORLD : Int = 66;
    
    public static inline var QUEST_PARAMETER_LEVEL_INFO : String = "levelInfo";
    
    // ACTIONS
    public static inline var VERIGAME_ACTION_PAINT_NARROW : Int = 1;
    public static inline var VERIGAME_ACTION_PAINT_WIDE : Int = 2;
    public static inline var VERIGAME_ACTION_PAINT_AUTOSOLVE : Int = 3;
    
    public static inline var VERIGAME_ACTION_AUTOSOLVE_COMPLETE : Int = 5;
    
    public static inline var VERIGAME_ACTION_UNDO : Int = 8;
    public static inline var VERIGAME_ACTION_REDO : Int = 9;
    public static inline var VERIGAME_ACTION_DISPLAY_HINT : Int = 10;
    
    public static inline var VERIGAME_ACTION_SUBMIT_SCORE : Int = 21;  //automatic on score increase  
    public static inline var VERIGAME_ACTION_LOAD_ASSIGNMENTS : Int = 22;
    public static inline var VERIGAME_ACTION_LOAD_BEST_ASSIGNMENTS : Int = 23;
    
    // ACTION PARAMS
    public static inline var ACTION_PARAMETER_START_INFO : String = "startInfo";
    public static inline var ACTION_PARAMETER_LEVEL_NAME : String = "levelName";
    public static inline var ACTION_PARAMETER_VAR_IDS : String = "varIds";
    public static inline var ACTION_PARAMETER_NARROW_VAR_IDS : String = "narrowIds";  // if only specifying narrow ids (others presumed wide)  
    public static inline var ACTION_PARAMETER_WIDE_VAR_IDS : String = "wideIds";  // if only specifying wide ids (others presumed narrow)  
    public static inline var ACTION_PARAMETER_VAR_VALUES : String = "values";
    public static inline var ACTION_PARAMETER_LAYOUT_NAME : String = "layoutName";
    public static inline var ACTION_PARAMETER_START_SCORE : String = "start_score";
    public static inline var ACTION_PARAMETER_TARGET_SCORE : String = "target_score";
    public static inline var ACTION_PARAMETER_SCORE : String = "score";
    public static inline var ACTION_PARAMETER_SCORE_CHANGE : String = "score_chg";
    public static inline var ACTION_PARAMETER_TYPE : String = "type";
    public static inline var ACTION_PARAMETER_TEXT : String = "txt";

    public function new()
    {
    }
}

