package constraints 
{

	public class EqualityConstraint extends Constraint 
	{
		public function EqualityConstraint(_lhs:ConstraintVar, _rhs:ConstraintVar, _scoring:ConstraintScoringConfig) 
		{
			super(Constraint.EQUALITY, _lhs, _rhs, _scoring);
		}
		
		public override function isSatisfied():Boolean
		{
			//trace(lhs + " == " + rhs + " ? " + (lhs.getValue().intVal == rhs.getValue().intVal));
			return lhs.getValue().intVal == rhs.getValue().intVal;
		}
	}

}