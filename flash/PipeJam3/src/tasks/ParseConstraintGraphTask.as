package tasks 
{
	import constraints.ConstraintGraph;
	import flash.utils.Dictionary;
	
	public class ParseConstraintGraphTask extends Task 
	{
		
		private var levelObj:Object;
		private var worldGraphDict:Dictionary;
		public var levelGraph:ConstraintGraph;
		
		public function ParseConstraintGraphTask(_levelObj:Object, _worldGraphDict:Dictionary, _dependentTaskIds:Vector.<String> = null) 
		{
			levelObj = _levelObj;
			
			worldGraphDict = _worldGraphDict
			var _id:String = levelObj["id"];
			super(_id, _dependentTaskIds);
		}
		
		public override function perform():void {
			super.perform();
			if (levelGraph == null)
			{
				levelGraph = ConstraintGraph.initFromJSON(levelObj);
				worldGraphDict[id] = levelGraph;
			}
			else
			{
				complete = levelGraph.buildNextPartOfGraph();
				//trace("Built complete=", complete);
			}
		}
		
	}

}