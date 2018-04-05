package events
{
	import starling.events.Event;
	
	public class NavigationEvent extends Event
	{
		public static const CHANGE_SCREEN:String = "changeScreen";
		public static const SHOW_GAME_MENU:String = "show_game_menu";
		public static const SWITCH_TO_NEXT_LEVEL:String = "switch_to_next_level";
		public static const FADE_SCREEN:String = "fade_screen";
		public static const START_OVER:String = "start_over";
		public static const GET_RANDOM_LEVEL:String = "get_random_level";
		public static const GET_SAVED_LEVEL:String = "get_saved_level";
		
		public var scene:String;
		public var menuShowing:Boolean;
		public var fadeCallback:Function;
		
		public function NavigationEvent(type:String, _scene:String = "", _menuShowing:Boolean = false, _fadeCallback:Function = null)
		{
			super(type, true);
			scene = _scene;
			menuShowing = _menuShowing;
			fadeCallback = _fadeCallback
		}
		
	}
}