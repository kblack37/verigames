package tasks 
{
	import constraints.ConstraintGraph;
	import flash.utils.Dictionary;
	import graph.LevelNodes;
	
	public class ParseConstraintGraphTask extends Task 
	{
		
		private var levelObj:Object;
		private var worldGraphDict:Dictionary;
		
		public function ParseConstraintGraphTask(_levelObj:Object, _worldGraphDict:Dictionary, _dependentTaskIds:Vector.<String> = null) 
		{
			levelObj = _levelObj;
			worldGraphDict = _worldGraphDict
			var _id:String = levelObj["id"];
			super(_id, _dependentTaskIds);
		}
		
		public override function perform():void {
			super.perform();
			var levelGraph:ConstraintGraph = ConstraintGraph.fromJSON(levelObj);
			worldGraphDict[id] = levelGraph;
			complete = true;
		}
		
	}

}