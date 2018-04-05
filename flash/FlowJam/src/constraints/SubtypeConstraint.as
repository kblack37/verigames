package constraints 
{

	public class SubtypeConstraint extends Constraint 
	{
		public function SubtypeConstraint(_lhs:ConstraintVar, _rhs:ConstraintVar, _scoring:ConstraintScoringConfig) 
		{
			super(Constraint.SUBTYPE, _lhs, _rhs, _scoring);
			lhs.lhsConstraints.push(this);
			rhs.rhsConstraints.push(this);
		}
		
		public override function isSatisfied():Boolean
		{
			return lhs.getValue().intVal <= rhs.getValue().intVal;
		}
	}

}