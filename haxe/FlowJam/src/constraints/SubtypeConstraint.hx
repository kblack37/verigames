package constraints;


class SubtypeConstraint extends Constraint
{
    public function new(_lhs : ConstraintVar, _rhs : ConstraintVar, _scoring : ConstraintScoringConfig)
    {
        super(Constraint.SUBTYPE, _lhs, _rhs, _scoring);
        lhs.lhsConstraints.push(this);
        rhs.rhsConstraints.push(this);
    }
    
    override public function isSatisfied() : Bool
    {
        return lhs.getValue().intVal <= rhs.getValue().intVal;
    }
}

