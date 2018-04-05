package system 
{
	public class VerigameServerConstants 
	{
		public static const VERIGAME_GAME_ID:int = 23;
		
		public static const VERIGAME_DEV_SKEY:String = "8847ab6e6908697ada1c8ac27287cd02";
		public static const VERIGAME_SKEY:String = "bde9564c55a99a60bf0deb0f5be44b6f";
		
		public static var MOCHI_GAME_ID:String = "953dee7d3049e1a3";
		
		public static const VERIGAME_GAME_NAME:String = "pipejam";
		
		public static const VERIGAME_VERSION_SEEDLING_BETA:int   = 4;
		public static const VERIGAME_VERSION_GRID_WORLD_BETA:int = 5;
		
		public static const VERIGAME_CATEGORY_SEEDLING_BETA:int                         = 19;
		public static const VERIGAME_CATEGORY_DARPA_FRIENDS_FAMILY_BETA_JULY_1_2013:int = 20;
		
		public static const VERIGAME_QUEST_ID_UNDEFINED_WORLD:int = 66;
		
		public static const VERIGAME_ACTION_START_LEVEL:int            = 1;
		public static const VERIGAME_ACTION_SWITCH_BOARDS:int          = 2;// deprecated
		public static const VERIGAME_ACTION_SAVE_LEVEL_PROGRESS:int    = 3;
		public static const VERIGAME_ACTION_CHANGE_EDGESET_WIDTH:int   = 4;
		public static const VERIGAME_ACTION_ADD_PIPE_BUZZSAW:int       = 5;// deprecated
		public static const VERIGAME_ACTION_REMOVE_PIPE_BUZZSAW:int    = 6;// deprecated
		public static const VERIGAME_ACTION_CHANGE_PIPE_STAMPS:int     = 7;
		// UI actions
		public static const VERIGAME_ACTION_SAVE_LAYOUT:int            = 20;
		public static const VERIGAME_ACTION_SUBMIT_SCORE:int           = 21;
		public static const VERIGAME_ACTION_LOAD_LAYOUT:int            = 22;
		
		public static const QUEST_PARAMETER_LEVEL_INFO:String          = "levelInfo";
		
		public static const ACTION_PARAMETER_START_INFO:String         = "startInfo";
		public static const ACTION_PARAMETER_BOARD_NAME:String         = "boardName";// deprecated
		public static const ACTION_PARAMETER_LEVEL_NAME:String         = "levelName";
		public static const ACTION_PARAMETER_EDGESET_WIDTH:String      = "edgeWidth";
		public static const ACTION_PARAMETER_PROP_CHANGED:String       = "propChanged";
		public static const ACTION_PARAMETER_PROP_VALUE:String         = "propValue";
		public static const ACTION_PARAMETER_EDGE_ID:String            = "edgeId";
		public static const ACTION_PARAMETER_VAR_ID:String             = "varId";
		public static const ACTION_PARAMETER_STAMP_DICTIONARY:String   = "stampDict";
		// UI action fields
		public static const ACTION_PARAMETER_LAYOUT_NAME:String        = "layoutName";
		public static const ACTION_PARAMETER_START_SCORE:String        = "start_score";
		public static const ACTION_PARAMETER_TARGET_SCORE:String       = "target_score";
		public static const ACTION_PARAMETER_SCORE:String              = "score";
		public static const ACTION_PARAMETER_SCORE_CHANGE:String       = "score_chg";
		public static const ACTION_VALUE_EDGE_WIDTH_WIDE:String        = "w";
		public static const ACTION_VALUE_EDGE_WIDTH_NARROW:String      = "n";
	}

}