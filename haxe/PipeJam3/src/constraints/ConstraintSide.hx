package constraints;

import constraints.events.VarChangeEvent;
import utils.PropDictionary;
import starling.events.EventDispatcher;

class ConstraintSide extends EventDispatcher
{
    public var id : String;
    public var formattedId : String;
    public var groups : Array<String>;
    public var rank : Int = 0;
    public var scoringConfig : ConstraintScoringConfig;
    
    public var lhsConstraints : Array<Constraint> = new Array<Constraint>();  // constraints where this var appears on the left hand side (outgoing edge)  
    public var rhsConstraints : Array<Constraint> = new Array<Constraint>();  // constraints where this var appears on the right hand side (incoming edge)  
    
    public function new(_id : String, _scoringConfig : ConstraintScoringConfig)
    {
        super();
        id = _id;
        scoringConfig = _scoringConfig;
        var suffixParts : Array<Dynamic> = id.split("__");
        var prefixId : String = suffixParts[0];
        var idIndx : Int = prefixId.indexOf("_");
        if (idIndx == -1)
        {
            trace("WARNING! Expecting var ids of the form var_*** or type_#__var_*** FOUND: " + id);
        }
        formattedId = prefixId.substr(0, idIndx) + ":" + prefixId.substr(idIndx + 1, prefixId.length - idIndx - 1);
    }
    
    public function getGroupAt(depth : Int) : String
    {
        if (depth == 0)
        {
            return "";
        }  // depth = 0, always just self (ungrouped)  
        if (groups == null)
        {
            return "";
        }
        if (groups.length < depth)
        {
            return "";
        }
        return groups[depth - 1];
    }
    
    public function toString() : String
    {
        return id;
    }
}

