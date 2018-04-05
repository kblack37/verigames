package constraints
{
	
	public class ConstraintEdge extends Constraint
	{
		public function ConstraintEdge(_lhs:ConstraintSide, _rhs:ConstraintSide, _scoring:ConstraintScoringConfig)
		{
			super(Constraint.CLAUSE, _lhs, _rhs, _scoring);
			lhs.lhsConstraints.push(this);
			rhs.rhsConstraints.push(this);
		}
		
		public override function isSatisfied():Boolean
		{
			return isClauseSatisfied("", false); 
		}
		
		public function isClauseSatisfied(varIdChanged:String, newPropValue:Boolean):Boolean
		{
			var clause:ConstraintClause;
			if (lhs is ConstraintClause)
			{
				return (lhs as ConstraintClause).isSatisfied(varIdChanged, newPropValue);
			}
			else if (rhs is ConstraintClause)
			{
				return (rhs as ConstraintClause).isSatisfied(varIdChanged, newPropValue);
			}
			else
			{
				throw new Error("ConstraintEdge: Expecting Constraints with exactly one variable and one clause per edge");
			}
		}
	}
}