package events;

import haxe.Constraints.Function;
import starling.events.Event;

class NavigationEvent extends Event
{
    public static inline var CHANGE_SCREEN : String = "changeScreen";
    public static inline var SHOW_GAME_MENU : String = "show_game_menu";
    public static inline var SWITCH_TO_NEXT_LEVEL : String = "switch_to_next_level";
    public static inline var LOAD_LEVEL : String = "load_level";
    public static inline var FADE_SCREEN : String = "fade_screen";
    public static inline var START_OVER : String = "start_over";
    public static inline var GET_RANDOM_LEVEL : String = "get_random_level";
    public static var UPDATE_HIGH_SCORES : String = "update_high_scores";
    public var scene : String;
    public var info : String;
    public var fadeCallback : Function;
    
    public function new(type : String, _scene : String = "", _info : String = null, _fadeCallback : Function = null)
    {
        super(type, true);
        scene = _scene;
        info = _info;
        fadeCallback = _fadeCallback;
    }
}
