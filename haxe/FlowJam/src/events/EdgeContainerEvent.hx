package events;

import scenes.game.display.GameComponent;
import scenes.game.display.GameEdgeContainer;
import scenes.game.display.GameEdgeJoint;
import scenes.game.display.GameEdgeSegment;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.Touch;

class EdgeContainerEvent extends Event
{
    public static inline var CREATE_JOINT : String = "CREATE_JOINT";
    public static inline var RUBBER_BAND_SEGMENT : String = "RUBBER_BAND_SEGMENT";
    public static inline var SEGMENT_MOVED : String = "SEGMENT_MOVED";
    public static inline var SEGMENT_DELETED : String = "SEGMENT_DELETED";
    public static inline var SAVE_CURRENT_LOCATION : String = "SAVE_CURRENT_LOCATION";
    public static inline var RESTORE_CURRENT_LOCATION : String = "RESTORE_CURRENT_LOCATION";
    public static inline var INNER_SEGMENT_CLICKED : String = "INNER_SEGMENT_CLICKED";
    public static inline var HOVER_EVENT_OVER : String = "HOVER_EVENT_OVER";
    public static inline var HOVER_EVENT_OUT : String = "HOVER_EVENT_OUT";
    
    public var segment : GameEdgeSegment;
    public var joint : GameEdgeJoint;
    public var container : GameEdgeContainer;
    public var segmentIndex : Int;
    public var jointIndex : Int;
    public var touches : Array<Touch>;
    
    public function new(type : String, _segment : GameEdgeSegment = null, _joint : GameEdgeJoint = null, _touches : Array<Touch> = null)
    {
        super(type, true);
        segment = _segment;
        joint = _joint;
        container = getEdgeContainerParent(segment);
        if (container == null)
        {
            container = getEdgeContainerParent(joint);
        }  //try joint if segment/parent null  
        if (container != null)
        {
            if (segment != null)
            {
                segmentIndex = container.getSegmentIndex(segment);
            }
            if (joint != null)
            {
                jointIndex = container.getJointIndex(joint);
            }
        }
        else
        {
            trace("WARNING: Event expects edge segment or joint with a parent edge container.");
        }
        touches = _touches;
        if (touches == null)
        {
            touches = new Array<Touch>();
        }
    }
    
    private static function getEdgeContainerParent(comp : GameComponent) : GameEdgeContainer
    {
        if (comp == null)
        {
            return null;
        }
        if (comp.parent == null)
        {
            return null;
        }
        var currentParent : DisplayObjectContainer = comp.parent;
        while (currentParent)
        {
            if (Std.is(currentParent, GameEdgeContainer))
            {
                return try cast(currentParent, GameEdgeContainer) catch(e:Dynamic) null;
            }
            currentParent = currentParent.parent;
        }
        return null;
    }
}
