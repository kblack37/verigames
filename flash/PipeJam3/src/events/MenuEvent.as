package events 
{
	import starling.events.Event;
	
	public class MenuEvent extends Event 
	{
		public static const SAVE_LEVEL:String = "save_level";
		public static const ZOOM_IN:String = "zoom_in";
		public static const ZOOM_OUT:String = "zoom_out";
		public static const MAX_ZOOM_REACHED:String = "max_zoom";
		public static const MIN_ZOOM_REACHED:String = "min_zoom";
		public static const RESET_ZOOM:String = "reset_zoom";
		public static const RECENTER:String = "recenter";
		public static const POST_DIALOG:String = "postDialog";
		public static const ACHIEVEMENT_ADDED:String = "achievementAdded";
		public static const LOAD_BEST_SCORE:String = "LOAD_BEST_SCORE";
		public static const LOAD_HIGH_SCORE:String = "LOAD_HIGH_SCORE";
		public static const TOGGLE_SOUND_CONTROL:String = "toggle_sound_control";
		public static const LEVEL_LOADED:String = "level_loaded";
		
		public static const SOLVE_SELECTION:String = "SOLVE_SELECTION";
		public static const STOP_SOLVER:String = "STOP_SOLVER";
		public static const MAKE_SELECTION_WIDE:String = "MAKE_SELECTION_WIDE";
		public static const MAKE_SELECTION_NARROW:String = "MAKE_SELECTION_NARROW";
		
		public static const MOUSE_OVER_CONTROL_PANEL:String = "MOUSE_OVER_CONTROL_PANEL";
		
		public static const TURK_FINISH:String = "TURK_FINISH";
		
		public function MenuEvent(_type:String, _eventData:Object = null) 
		{
			super(_type, true, _eventData);
		}
	}

}