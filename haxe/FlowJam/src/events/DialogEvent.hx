package events;

import starling.events.Event;


/**
 * ...
 * @author ...
 */
class DialogEvent extends Event 
{
	public static var LEVEL_SAVED : String = "level_saved";
	public static inline var LAYOUT_SAVED : String = "layout_saved";
	public static inline var POST_SAVE_DIALOG : String = "post_save_dialog";
    public static inline var POST_SUBMIT_DIALOG : String = "post_submit_dialog";
	public static var LEVEL_SUBMITTED : String = "level_submitted";
	public static inline var SAVE_LAYOUT : String = "save_layout"; 
    public static inline var ACHIEVEMENT_ADDED : String = "achievementAdded";
	
	public function new(type:String, bubbles:Bool=false, data:Dynamic=null) 
	{
		super(type, bubbles, data);
	}
	
}