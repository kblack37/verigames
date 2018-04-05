package State 
{
	import VisualWorld.VerigameSystem;
	import VisualWorld.World;
	import NetworkGraph.Network;
	
	import Tasks.ParseLevelXMLTask;
	
	public class ParseXMLState extends LoadingState
	{
		
		private var world_xml:XML;
		public var world_nodes:Network;
		
		public function ParseXMLState(_world_xml:XML) 
		{
			world_xml = _world_xml;
			super("Parsing XML...");
		}
		
		public override function stateLoad():void {
			
			var version_failed:Boolean = false;
			
			if ("1" == null) {
				version_failed = true;
			} else if ("1" != PipeJamController.WORLD_INPUT_XML_VERSION) {
				version_failed = true;
			}
			if (version_failed) {
				VerigameSystem.printWarning("Error: World XML version used does not match the version that this game .SWF is designed to read. The game is designed to read version '" + PipeJamController.WORLD_INPUT_XML_VERSION + "'");
				throw new Error("World XML version used does not match the version that this game .SWF is designed to read. The game is designed to read version '" + PipeJamController.WORLD_INPUT_XML_VERSION + "'");
				return;
			}
			
			var my_world_name:String = "World 1";
			if (world_xml.attribute("name") != null) {
				if (world_xml.attribute("name").toString().length > 0) {
					my_world_name = world_xml.attribute("name").toString();
				}
			}
			
			world_nodes = new Network(my_world_name);
			
			for (var level_index:uint = 0; level_index < world_xml["level"].length(); level_index++) {
				var my_level_xml:XML = world_xml["level"][level_index];
				var my_task:ParseLevelXMLTask = new ParseLevelXMLTask(my_level_xml, world_nodes);
				tasks.push(my_task);
			}
			
			super.stateLoad();
			
		}
		
		public override function stateUnload():void {
			super.stateUnload();
			world_xml = null;
			world_nodes = null;
		}
		
		public override function onTasksComplete():void {
			
			PipeJamController.mainController.tasksComplete(world_nodes);
			stateUnload();
		}
		
	}

}