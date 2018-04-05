package events;

import flash.events.Event;
import graph.Edge;
import graph.PropDictionary;

class EdgePropChangeEvent extends Event
{
    public static inline var ENTER_BALL_TYPE_CHANGED : String = "ENTER_BALL_TYPE_CHANGED";
    public static inline var EXIT_BALL_TYPE_CHANGED : String = "EXIT_BALL_TYPE_CHANGED";
    public static inline var ENTER_PROPS_CHANGED : String = "ENTER_PROPS_CHANGED";
    public static inline var EXIT_PROPS_CHANGED : String = "EXIT_PROPS_CHANGED";
    
    public var oldProps : PropDictionary;
    public var newProps : PropDictionary;
    public var oldBallType : Int;
    public var newBallType : Int;
    public var edge : Edge;
    
    public function new(eventType : String, _edge : Edge, _oldProps : PropDictionary = null, _newProps : PropDictionary = null, _oldType : Int = 0, _newType : Int = 0)
    {
        super(eventType);
        edge = _edge;
        oldProps = _oldProps;
        newProps = _newProps;
        oldBallType = _oldType;
        newBallType = _newType;
    }
    
    override public function toString() : String
    {
        return "[BallTypeChangeEvent:" + type + " edgeId:" + edge.edge_id + " oldType:" + oldBallType + " newType:" + newBallType + "]";
    }
}

