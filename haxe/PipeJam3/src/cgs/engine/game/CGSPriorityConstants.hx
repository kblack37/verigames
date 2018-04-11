package cgs.engine.game;
import cgs.utils.MathUtils;


/**
	 * ...
	 * @author Rich
	 */
class CGSPriorityConstants
{
    // Updater priorities
    public static inline var PRIORITY_LOWEST : Int = 0;
    public static var PRIORITY_LOW : Int = Std.int(MathUtils.INT_MAX / 4);
    public static var PRIORITY_MEDIUM : Int = Std.int(MathUtils.INT_MAX / 2);
    public static var PRIORITY_HIGH : Int = Std.int((MathUtils.INT_MAX / 4) * 3);
    public static var PRIORITY_HIGHEST : Int = Std.int(MathUtils.INT_MAX - 1);

    public function new()
    {
    }
}

