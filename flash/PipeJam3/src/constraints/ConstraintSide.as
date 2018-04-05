package constraints 
{
	import constraints.events.VarChangeEvent;
	import utils.PropDictionary;
	import starling.events.EventDispatcher;
	
	public class ConstraintSide extends EventDispatcher
	{
		public var id:String;
		public var formattedId:String;
		public var groups:Vector.<String>;
		public var rank:int = 0;
		public var scoringConfig:ConstraintScoringConfig;
		
		public var lhsConstraints:Vector.<Constraint> = new Vector.<Constraint>(); // constraints where this var appears on the left hand side (outgoing edge)
		public var rhsConstraints:Vector.<Constraint> = new Vector.<Constraint>(); // constraints where this var appears on the right hand side (incoming edge)
		
		public function ConstraintSide(_id:String, _scoringConfig:ConstraintScoringConfig)
		{
			id = _id;
			scoringConfig = _scoringConfig;
			var suffixParts:Array = id.split("__");
			var prefixId:String = suffixParts[0];
			var idIndx:int = prefixId.indexOf("_");
			if (idIndx == -1) trace("WARNING! Expecting var ids of the form var_*** or type_#__var_*** FOUND: " + id);
			formattedId = prefixId.substr(0, idIndx) + ":" + prefixId.substr(idIndx + 1, prefixId.length - idIndx - 1);
		}

		public function getGroupAt(depth:uint):String
		{
			if (depth == 0) return ""; // depth = 0, always just self (ungrouped)
			if (groups == null) return "";
			if (groups.length < depth) return "";
			return groups[depth - 1];
		}
		
		public function toString():String
		{
			return id;
		}
	}

}