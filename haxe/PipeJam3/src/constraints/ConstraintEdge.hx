package constraints;

import flash.errors.Error;

class ConstraintEdge extends Constraint
{
    public function new(_lhs : ConstraintSide, _rhs : ConstraintSide, _scoring : ConstraintScoringConfig)
    {
        super(Constraint.CLAUSE, _lhs, _rhs, _scoring);
        lhs.lhsConstraints.push(this);
        rhs.rhsConstraints.push(this);
    }
    
    override public function isSatisfied() : Bool
    {
        return isClauseSatisfied("", false);
    }
    
    public function isClauseSatisfied(varIdChanged : String, newPropValue : Bool) : Bool
    {
        var clause : ConstraintClause;
        if (Std.is(lhs, ConstraintClause))
        {
            return (try cast(lhs, ConstraintClause) catch(e:Dynamic) null).isSatisfied(varIdChanged, newPropValue);
        }
        else if (Std.is(rhs, ConstraintClause))
        {
            return (try cast(rhs, ConstraintClause) catch(e:Dynamic) null).isSatisfied(varIdChanged, newPropValue);
        }
        else
        {
            throw new Error("ConstraintEdge: Expecting Constraints with exactly one variable and one clause per edge");
        }
    }
}
