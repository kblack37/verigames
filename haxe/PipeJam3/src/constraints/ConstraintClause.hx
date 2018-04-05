package constraints;

import flash.errors.Error;
import starling.events.EventDispatcher;
import utils.PropDictionary;

class ConstraintClause extends ConstraintSide
{
    
    public function new(_id : String, _scoringConfig : ConstraintScoringConfig)
    {
        super(_id, _scoringConfig);
    }
    
    public function isSatisfied(varIdChanged : String, newPropValue : Bool) : Bool
    {
        var i : Int;
        var thisConstr : Constraint;
        for (i in 0...lhsConstraints.length)
        {
            thisConstr = lhsConstraints[i];
            if (Std.is(thisConstr.rhs, ConstraintVar))
            
            // If rhs, true if wide{
                
                if (thisConstr.id == varIdChanged && !newPropValue)
                {
                    return true;
                }
                if (!(try cast(thisConstr.rhs, ConstraintVar) catch(e:Dynamic) null).getProps().hasProp(PropDictionary.PROP_NARROW))
                {
                    return true;
                }
            }
            else
            {
                throw new Error("Expecting Constraints with exactly one variable and one clause per edge");
            }
        }
        for (i in 0...rhsConstraints.length)
        {
            thisConstr = rhsConstraints[i];
            if (Std.is(thisConstr.lhs, ConstraintVar))
            
            // If lhs, true if narrow{
                
                if (thisConstr.id == varIdChanged && newPropValue)
                {
                    return true;
                }
                if ((try cast(thisConstr.lhs, ConstraintVar) catch(e:Dynamic) null).getProps().hasProp(PropDictionary.PROP_NARROW))
                {
                    return true;
                }
            }
            else
            {
                throw new Error("Expecting Constraints with exactly one variable and one clause per edge");
            }
        }
        
        return false;
    }
}

