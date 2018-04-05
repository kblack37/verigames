package state 
{
	import constraints.ConstraintGraph;
	import flash.utils.Dictionary;
	import starling.events.Event;
	import tasks.ParseConstraintGraphTask;
	
	public class ParseConstraintGraphState extends LoadingState
	{
		public static var WORLD_PARSED:String = "World Parsed";
		
		private var worldObj:Object;
		private var worldGraphsDict:Dictionary;
		
		public function ParseConstraintGraphState(_worldObj:Object) 
		{
			super();
			worldObj = _worldObj;
		}
		
		public override function stateLoad():void {
			worldGraphsDict = new Dictionary();
			var levelsArr:Array = worldObj["levels"];
			if (levelsArr) {
				for (var level_index:int = 0; level_index < worldObj["levels"].length; level_index++) {
					var levelObj:Object = worldObj["levels"][level_index];
					var my_task:ParseConstraintGraphTask = new ParseConstraintGraphTask(levelObj, worldGraphsDict);
					tasksVector.push(my_task);
				}
			} else {
				var task:ParseConstraintGraphTask = new ParseConstraintGraphTask(worldObj, worldGraphsDict);
				tasksVector.push(task);
			}
			super.stateLoad();
		}
		
		public override function stateUnload():void {
			super.stateUnload();
			worldObj = null;
			worldGraphsDict = null;
		}
		
		public override function onTasksComplete():void {
			var event:starling.events.Event = new Event(WORLD_PARSED, true, worldGraphsDict);
			dispatchEvent(event);
			stateUnload();
		}
		
	}

}