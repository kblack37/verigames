package constraints 
{
	
	public class Constraint 
	{
		public static const SUBTYPE:String = "subtype";
		public static const EQUALITY:String = "equality";
		public static const CLAUSE:String = "clause";
		public static const MAP_GET:String = "map.get";
		public static const IF_NODE:String = "selection_check";
		public static const GENERICS_NODE:String = "enabled_check";
		
		public var type:String;
		public var lhs:ConstraintSide;
		public var rhs:ConstraintSide;
		public var scoring:ConstraintScoringConfig;
		public var id:String;
		
		public function Constraint(_type:String, _lhs:ConstraintSide, _rhs:ConstraintSide, _scoring:ConstraintScoringConfig) 
		{
			type = _type;
			lhs = _lhs;
			rhs = _rhs;
			scoring = _scoring;
			id = lhs.id + " -> " + rhs.id;
		}
		
		public function isSatisfied():Boolean
		{
			/* Implemented by children */
			return false;
		}
		
	}

}