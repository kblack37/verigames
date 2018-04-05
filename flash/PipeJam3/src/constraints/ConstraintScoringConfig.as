package constraints 
{
	import flash.utils.Dictionary;
	
	public class ConstraintScoringConfig 
	{
		public static const CONSTRAINT_VALUE_KEY:String = "constraints";
		public static const TYPE_0_VALUE_KEY:String = "type:0";
		public static const TYPE_1_VALUE_KEY:String = "type:1";
		
		public var scoringDict:Dictionary = new Dictionary();
		
		public function ConstraintScoringConfig() 
		{
		}
		
		public function updateScoringValue(key:String, val:Number):void
		{
			scoringDict[key] = val;
		}
		
		public function getScoringValue(key:String):int
		{
			if (scoringDict.hasOwnProperty(key)) return scoringDict[key] as int;
			return 0;
		}
		
		public function removeScoringValue(key:String):void
		{
			if (scoringDict.hasOwnProperty(key)) delete scoringDict[key];
		}
		
		public static function merge(parentScoringConfig:ConstraintScoringConfig, childScoringConfig:ConstraintScoringConfig):ConstraintScoringConfig
		{
			var mergedScoring:ConstraintScoringConfig = new ConstraintScoringConfig();
			for (var parentKey:String in parentScoringConfig.scoringDict) mergedScoring.updateScoringValue(parentKey, parentScoringConfig.getScoringValue(parentKey));
			// Child overrides parent values
			for (var childKey:String in childScoringConfig.scoringDict) mergedScoring.updateScoringValue(childKey, childScoringConfig.getScoringValue(childKey));
			return mergedScoring;
		}
		
		public function clone():ConstraintScoringConfig
		{
			var cloneScoring:ConstraintScoringConfig = new ConstraintScoringConfig();
			for (var key:String in scoringDict) cloneScoring.updateScoringValue(key, getScoringValue(key));
			return cloneScoring;
		}
	}

}