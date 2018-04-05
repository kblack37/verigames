package system 
{
	public class VerigameServerConstants 
	{
		public static const VERIGAME_GAME_ID:int = 23;
		
		public static const VERIGAME_DEV_SKEY:String = "8847ab6e6908697ada1c8ac27287cd02";
		public static const VERIGAME_SKEY:String = "bde9564c55a99a60bf0deb0f5be44b6f";
		
		public static const VERIGAME_GAME_NAME:String = "pipejam";
		
		public static const VERIGAME_VERSION_SEEDLING_BETA:int   = 4;
		public static const VERIGAME_VERSION_GRID_WORLD_BETA:int = 5;
		
		public static const VERIGAME_CATEGORY_SEEDLING_BETA:int                           = 19;
		public static const VERIGAME_CATEGORY_DARPA_FRIENDS_FAMILY_BETA_JULY_1_2013:int   = 20;
		public static const VERIGAME_CATEGORY_PARADOX_FRIENDS_FAMILY_BETA_MAY_15_2015:int = 21;
		public static const VERIGAME_CATEGORY_PARADOX_MTURK_JUNE_2015:int                 = 22;
		
		public static const VERIGAME_QUEST_ID_UNDEFINED_WORLD:int = 66;
		
		public static const QUEST_PARAMETER_LEVEL_INFO:String          = "levelInfo";
		
		// ACTIONS
		public static const VERIGAME_ACTION_PAINT_NARROW:int           = 1;
		public static const VERIGAME_ACTION_PAINT_WIDE:int             = 2;
		public static const VERIGAME_ACTION_PAINT_AUTOSOLVE:int        = 3;
		
		public static const VERIGAME_ACTION_AUTOSOLVE_COMPLETE:int     = 5;
		
		public static const VERIGAME_ACTION_UNDO:int                   = 8;
		public static const VERIGAME_ACTION_REDO:int                   = 9;
		public static const VERIGAME_ACTION_DISPLAY_HINT:int           = 10;
		
		public static const VERIGAME_ACTION_SUBMIT_SCORE:int           = 21; //automatic on score increase
		public static const VERIGAME_ACTION_LOAD_ASSIGNMENTS:int       = 22;
		public static const VERIGAME_ACTION_LOAD_BEST_ASSIGNMENTS:int  = 23;
		
		// ACTION PARAMS
		public static const ACTION_PARAMETER_START_INFO:String         = "startInfo";
		public static const ACTION_PARAMETER_LEVEL_NAME:String         = "levelName";
		public static const ACTION_PARAMETER_VAR_IDS:String            = "varIds";
		public static const ACTION_PARAMETER_NARROW_VAR_IDS:String     = "narrowIds"; // if only specifying narrow ids (others presumed wide)
		public static const ACTION_PARAMETER_WIDE_VAR_IDS:String       = "wideIds";   // if only specifying wide ids (others presumed narrow)
		public static const ACTION_PARAMETER_VAR_VALUES:String         = "values";
		public static const ACTION_PARAMETER_LAYOUT_NAME:String        = "layoutName";
		public static const ACTION_PARAMETER_START_SCORE:String        = "start_score";
		public static const ACTION_PARAMETER_TARGET_SCORE:String       = "target_score";
		public static const ACTION_PARAMETER_SCORE:String              = "score";
		public static const ACTION_PARAMETER_SCORE_CHANGE:String       = "score_chg";
		public static const ACTION_PARAMETER_TYPE:String               = "type";
		public static const ACTION_PARAMETER_TEXT:String               = "txt";
	}

}