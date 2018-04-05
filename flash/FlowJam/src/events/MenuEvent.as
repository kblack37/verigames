package events 
{
	import starling.events.Event;
	
	public class MenuEvent extends Event 
	{
		public static const SAVE_LAYOUT:String = "save_layout";
		public static const LAYOUT_SAVED:String = "layout_saved";
		public static const SET_NEW_LAYOUT:String = "set_new_layout";
		public static const SUBMIT_LEVEL:String = "submit_level";
		public static var LEVEL_SUBMITTED:String = "level_submitted";
		public static const SAVE_LEVEL:String = "save_level";
		public static var LEVEL_SAVED:String = "level_saved";
		public static const POST_SAVE_DIALOG:String = "post_save_dialog";
		public static const POST_SUBMIT_DIALOG:String = "post_submit_dialog";
		public static const ZOOM_IN:String = "zoom_in";
		public static const ZOOM_OUT:String = "zoom_out";
		public static const MAX_ZOOM_REACHED:String = "max_zoom";
		public static const MIN_ZOOM_REACHED:String = "min_zoom";
		public static const RESET_ZOOM:String = "reset_zoom";
		public static const RECENTER:String = "recenter";
		public static const ACHIEVEMENT_ADDED:String = "achievementAdded";
		public static const LOAD_BEST_SCORE:String = "LOAD_BEST_SCORE";
		public static const LOAD_HIGH_SCORE:String = "LOAD_HIGH_SCORE";
		public static const TOGGLE_SOUND_CONTROL:String = "toggle_sound_control";
		public static const LEVEL_LOADED:String = "level_loaded";
		
		public static const SOLVE_SELECTION:String = "SOLVE_SELECTION";
		public static const MAKE_SELECTION_WIDE:String = "MAKE_SELECTION_WIDE";
		public static const MAKE_SELECTION_NARROW:String = "MAKE_SELECTION_NARROW";

		
		public function MenuEvent(_type:String, _eventData:Object = null) 
		{
			super(_type, true, _eventData);
		}
		
	}

}