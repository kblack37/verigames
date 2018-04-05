package constraints.events;

import constraints.ConstraintVar;
import flash.geom.Point;
import starling.events.Event;
import scenes.game.display.Node;

class VarChangeEvent extends Event
{
    public static inline var VAR_CHANGE_USER : String = "VAR_CHANGE_USER";  // change requested by user  
    public static inline var VAR_CHANGE_SOLVER : String = "VAR_CHANGE_SOLVER";  // change requested by solver  
    public static inline var VAR_CHANGED_IN_GRAPH : String = "VAR_CHANGED_IN_GRAPH";  // POST change event, after change was made in ConstraintsGraph  
    
    public var graphVar : ConstraintVar;
    public var prop : String;
    public var newValue : Bool;
    public var pt : Point;
    public var node : Node;
    
    public function new(_type : String, _graphVar : ConstraintVar, _prop : String, _newValue : Bool, _pt : Point = null, _node : Node = null)
    {
        super(_type, _type == VAR_CHANGE_USER);
        graphVar = _graphVar;
        prop = _prop;
        newValue = _newValue;
        pt = _pt;
        node = _node;
    }
}

