package constraints 
{
	import starling.events.EventDispatcher;
	import utils.PropDictionary;
	
	public class ConstraintClause extends ConstraintSide
	{
		
		public function ConstraintClause(_id:String, _scoringConfig:ConstraintScoringConfig)
		{
			super(_id, _scoringConfig);
		}
		
		public function isSatisfied(varIdChanged:String, newPropValue:Boolean):Boolean
		{
			var i:int, thisConstr:Constraint;
			for (i = 0; i < lhsConstraints.length; i++)
			{
				thisConstr = lhsConstraints[i];
				if (thisConstr.rhs is ConstraintVar)
				{
					// If rhs, true if wide
					if (thisConstr.id == varIdChanged && !newPropValue) return true;
					if (!(thisConstr.rhs as ConstraintVar).getProps().hasProp(PropDictionary.PROP_NARROW)) return true;
				}
				else
				{
					throw new Error("Expecting Constraints with exactly one variable and one clause per edge");
				}
			}
			for (i = 0; i < rhsConstraints.length; i++)
			{
				thisConstr = rhsConstraints[i];
				if (thisConstr.lhs is ConstraintVar)
				{
					// If lhs, true if narrow
					if (thisConstr.id == varIdChanged && newPropValue) return true;
					if ((thisConstr.lhs as ConstraintVar).getProps().hasProp(PropDictionary.PROP_NARROW)) return true;
				}
				else
				{
					throw new Error("Expecting Constraints with exactly one variable and one clause per edge");
				}
			}
			
			return false;
		}
		
	}

}