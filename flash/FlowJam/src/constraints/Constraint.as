package constraints 
{
	
	public class Constraint 
	{
		public static const SUBTYPE:String = "subtype";
		public static const EQUALITY:String = "equality";
		public static const MAP_GET:String = "map.get";
		public static const IF_NODE:String = "selection_check";
		public static const GENERICS_NODE:String = "enabled_check";
		
		public var type:String;
		public var lhs:ConstraintVar;
		public var rhs:ConstraintVar;
		public var scoring:ConstraintScoringConfig;
		public var id:String;
		
		public function Constraint(_type:String, _lhs:ConstraintVar, _rhs:ConstraintVar, _scoring:ConstraintScoringConfig) 
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