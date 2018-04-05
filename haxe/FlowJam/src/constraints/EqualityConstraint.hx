package constraints;


class EqualityConstraint extends Constraint
{
    public function new(_lhs : ConstraintVar, _rhs : ConstraintVar, _scoring : ConstraintScoringConfig)
    {
        super(Constraint.EQUALITY, _lhs, _rhs, _scoring);
    }
    
    override public function isSatisfied() : Bool
    //trace(lhs + " == " + rhs + " ? " + (lhs.getValue().intVal == rhs.getValue().intVal));
    {
        
        return lhs.getValue().intVal == rhs.getValue().intVal;
    }
}

