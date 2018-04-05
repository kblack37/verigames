package Tasks 
{
	import NetworkGraph.LevelNodes;
	import NetworkGraph.Network;
	import Utilities.LevelLayout;
	
	public class ParseLevelXMLTask extends Task 
	{
		
		private var level_xml:XML;
		private var worldNodes:Network;
		
		public function ParseLevelXMLTask(_level_xml:XML, _worldNodes:Network, _id:String = "", _dependentTaskIds:Vector.<String> = null) 
		{
			level_xml = _level_xml;
			worldNodes = _worldNodes
			if (_id.length == 0) {
				_id = level_xml.attribute("name").toString();
			}
			super(_id, _dependentTaskIds);
		}
		
		public override function perform():void {
			super.perform();
			var my_level_nodes:LevelNodes = LevelLayout.parseLevelXML(level_xml, worldNodes.obfuscator);
			if (worldNodes.worldNodesDictionary[my_level_nodes.level_name] == null) {
				worldNodes.worldNodesDictionary[my_level_nodes.level_name] = my_level_nodes;
			} else {
				throw new Error("Duplicate Level entries found for level: " + level_xml.attribute("name").toString());
			}
			complete = true;
		}
		
	}

}