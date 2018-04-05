package constraints;


class Constraint
{
    public static inline var SUBTYPE : String = "subtype";
    public static inline var EQUALITY : String = "equality";
    public static inline var CLAUSE : String = "clause";
    public static inline var MAP_GET : String = "map.get";
    public static inline var IF_NODE : String = "selection_check";
    public static inline var GENERICS_NODE : String = "enabled_check";
    
    public var type : String;
    public var lhs : ConstraintSide;
    public var rhs : ConstraintSide;
    public var scoring : ConstraintScoringConfig;
    public var id : String;
    
    public function new(_type : String, _lhs : ConstraintSide, _rhs : ConstraintSide, _scoring : ConstraintScoringConfig)
    {
        type = _type;
        lhs = _lhs;
        rhs = _rhs;
        scoring = _scoring;
        id = lhs.id + " -> " + rhs.id;
    }
    
    public function isSatisfied() : Bool
    /* Implemented by children */
    {
        
        return false;
    }
}

