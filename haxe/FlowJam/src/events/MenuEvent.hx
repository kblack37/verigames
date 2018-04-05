package events;

import starling.events.Event;

class MenuEvent extends Event
{
    public static inline var SAVE_LAYOUT : String = "save_layout";
    public static inline var LAYOUT_SAVED : String = "layout_saved";
    public static inline var SET_NEW_LAYOUT : String = "set_new_layout";
    public static inline var SUBMIT_LEVEL : String = "submit_level";
    public static var LEVEL_SUBMITTED : String = "level_submitted";
    public static inline var SAVE_LEVEL : String = "save_level";
    public static var LEVEL_SAVED : String = "level_saved";
    public static inline var POST_SAVE_DIALOG : String = "post_save_dialog";
    public static inline var POST_SUBMIT_DIALOG : String = "post_submit_dialog";
    public static inline var ZOOM_IN : String = "zoom_in";
    public static inline var ZOOM_OUT : String = "zoom_out";
    public static inline var MAX_ZOOM_REACHED : String = "max_zoom";
    public static inline var MIN_ZOOM_REACHED : String = "min_zoom";
    public static inline var RESET_ZOOM : String = "reset_zoom";
    public static inline var RECENTER : String = "recenter";
    public static inline var ACHIEVEMENT_ADDED : String = "achievementAdded";
    public static inline var LOAD_BEST_SCORE : String = "LOAD_BEST_SCORE";
    public static inline var LOAD_HIGH_SCORE : String = "LOAD_HIGH_SCORE";
    public static inline var TOGGLE_SOUND_CONTROL : String = "toggle_sound_control";
    public static inline var LEVEL_LOADED : String = "level_loaded";
    
    public static inline var SOLVE_SELECTION : String = "SOLVE_SELECTION";
    public static inline var MAKE_SELECTION_WIDE : String = "MAKE_SELECTION_WIDE";
    public static inline var MAKE_SELECTION_NARROW : String = "MAKE_SELECTION_NARROW";
    
    
    public function new(_type : String, _eventData : Dynamic = null)
    {
        super(_type, true, _eventData);
    }
}

