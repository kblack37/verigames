package events;

import starling.events.Event;

class MenuEvent extends Event
{
    public static inline var SAVE_LEVEL : String = "save_level";
    public static inline var ZOOM_IN : String = "zoom_in";
    public static inline var ZOOM_OUT : String = "zoom_out";
    public static inline var MAX_ZOOM_REACHED : String = "max_zoom";
    public static inline var MIN_ZOOM_REACHED : String = "min_zoom";
    public static inline var RESET_ZOOM : String = "reset_zoom";
    public static inline var RECENTER : String = "recenter";
    public static inline var POST_DIALOG : String = "postDialog";
    public static inline var ACHIEVEMENT_ADDED : String = "achievementAdded";
    public static inline var LOAD_BEST_SCORE : String = "LOAD_BEST_SCORE";
    public static inline var LOAD_HIGH_SCORE : String = "LOAD_HIGH_SCORE";
    public static inline var TOGGLE_SOUND_CONTROL : String = "toggle_sound_control";
    public static inline var LEVEL_LOADED : String = "level_loaded";
    
    public static inline var SOLVE_SELECTION : String = "SOLVE_SELECTION";
    public static inline var STOP_SOLVER : String = "STOP_SOLVER";
    public static inline var MAKE_SELECTION_WIDE : String = "MAKE_SELECTION_WIDE";
    public static inline var MAKE_SELECTION_NARROW : String = "MAKE_SELECTION_NARROW";
    
    public static inline var MOUSE_OVER_CONTROL_PANEL : String = "MOUSE_OVER_CONTROL_PANEL";
    
    public static inline var TURK_FINISH : String = "TURK_FINISH";
    
    public function new(_type : String, _eventData : Dynamic = null)
    {
        super(_type, true, _eventData);
    }
}

