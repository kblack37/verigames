package Utilities 
{
	import NetworkGraph.*;
	import NetworkGraph.LevelNodes;
	import NetworkGraph.Network;
	
	import VisualWorld.Board;
	import VisualWorld.Level;
	import VisualWorld.VerigameSystem;
	import VisualWorld.World;
	
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * Class to read XML and create/link node objects and edge objects from them
	*/
	public class LevelLayout 
	{
		
		/**
		 * Function reads XML and creates/links node objects and edge objects from previously laid out XML
		 * @param	_input_xml XML (with layout information) to be read
		 * @param	_system VerigameSystem with the world created using the input XML
		 * @return
		 */
		public static function parseLaidOutXML(_input_xml:XML, _system:VerigameSystem = null):VerigameSystem {
			DebugTimer.beginTiming("Convert XML to node/edge/port objects");
			var input_xml:XML = _input_xml;
			var version_failed:Boolean = false;
			if (input_xml.attribute("version") == null) {
				version_failed = true;
			} else if (input_xml.attribute("version").toString() != PipeJamController.WORLD_INPUT_XML_VERSION) {
				version_failed = true;
			}
			if (version_failed) {
				VerigameSystem.printWarning("Error: World XML version used does not match the version that this game .SWF is designed to read. The game is designed to read version '" + PipeJamController.WORLD_INPUT_XML_VERSION + "'");
				throw new Error("World XML version used does not match the version that this game .SWF is designed to read. The game is designed to read version '" + PipeJamController.WORLD_INPUT_XML_VERSION + "'");
				return;
			}
			var my_world_name:String = "World 1";
			if (input_xml.attribute("name") != null) {
				if (input_xml.attribute("name").toString().length > 0) {
					my_world_name = input_xml.attribute("name").toString();
				}
			}
			
			var worldNodes:Network = new Network(my_world_name);
			
			var my_level_xml:XML;
			for (var level_index:uint = 0; level_index < input_xml["level"].length(); level_index++) {
				my_level_xml = input_xml["level"][level_index];
				
				var my_levelNodes:LevelNodes = parseLevelXML(my_level_xml);
				
				if (worldNodes.worldNodesDictionary[my_level_xml.attribute("name").toString()] == null) {
					worldNodes.worldNodesDictionary[my_level_xml.attribute("name").toString()] = my_levelNodes;
				} else {
					throw new Error("Duplicate level names found for level: " + my_level_xml.attribute("name").toString());
				}
				
			} // level_index for loop
			VerigameSystem.printDebug("World layout LOADED!");
			DebugTimer.reportTime("Convert XML to node/edge/port objects");
			DebugTimer.beginTiming("Create VerigameSystem");
			if (_system == null) {
				_system = new VerigameSystem(0, 0, 1024, 768, null);
			}
			DebugTimer.reportTime("Create VerigameSystem");
			var new_world:World = _system.createWorldFromNodes(worldNodes, input_xml);
			_system.worlds.push(new_world);
			
			if (_system.worlds.length == 1) {
				_system.current_level = _system.current_world.levels[0];
				_system.draw();
			}
			/*
			for each (var board_to_simulate:Board in _system.worlds[_system.worlds.length - 1].boards) {
				board_to_simulate.simulateDrop(true);
			}
			*/
			return _system;
			
		}
		
		public static function parseLevelXML(my_level_xml:XML, obfuscater:NameObfuscater = null):LevelNodes {
			var my_levelNodes:LevelNodes = new LevelNodes(my_level_xml.attribute("name").toString(), obfuscater);
			
			if (my_level_xml["boards"].length() == 0) {
				VerigameSystem.printDebug("NO <boards> found. Level not created...");
				return null;
			}
			
			// Obtain boards
			if (my_level_xml["boards"][0]["board"].length() == 0) {
				VerigameSystem.printDebug("NO <boards> <board> 's found. Level not created...");
				return null;
			}
			var boards_xml_list:XMLList = my_level_xml["boards"][0]["board"];
			
			// Obtain edges
			if (my_level_xml["boards"][0]["board"]["edge"].attribute("description").length() == 0) {
				VerigameSystem.printDebug("NO <boards> <edge> 's found. Level not created...");
				return null;
			}
			
			// Obtain linked edge sets
			var edge_set_dictionary:Dictionary = new Dictionary();
			if (my_level_xml["linked-edges"][0]["edge-set"].length() == 0) {
				VerigameSystem.printDebug("NO <linked-edges> <edge-set> 's found. Level not created...");
				return null;
			}
			var edge_set_index:int = 0;
			for each (var le_set:XML in my_level_xml["linked-edges"][0]["edge-set"]) {
				if (le_set["edgeref"].attribute("id").length() > 0) {
					var my_id:String = String(le_set.attribute("id"));
					if (my_id.length == 0) {
						my_id = edge_set_index.toString();
					}
					var my_edge_set:EdgeSetRef = new EdgeSetRef(my_id, edge_set_dictionary);
					for (var le_id_indx:uint = 0; le_id_indx < le_set["edgeref"].attribute("id").length(); le_id_indx++) {
						edge_set_dictionary[le_set["edgeref"].attribute("id")[le_id_indx].toString()] = my_edge_set;
						my_edge_set.edge_ids.push(le_set["edgeref"].attribute("id")[le_id_indx].toString());
					}
					for (var stamp_id_indx:uint = 0; stamp_id_indx < le_set["stamp"].length(); stamp_id_indx++) {
						var isActive:Boolean = XString.stringToBool(String(le_set["stamp"][stamp_id_indx].attribute("active")));
						my_edge_set.addStamp(String(le_set["stamp"][stamp_id_indx].attribute("id")), isActive);
					}
					edge_set_index++;
				}
			}
			
			var my_board_xml:XML;
			var source_node:Node, dest_node:Node;
			for (var b:uint = 0; b < boards_xml_list.length(); b++) {
				my_board_xml = boards_xml_list[b];
				VerigameSystem.printDebug("Processing board: " + my_board_xml.attribute("name"));
				
				
				// FORM NODE/EDGE OBJECTS FROM XML
				for each (var n1:XML in my_board_xml["node"]) {
					var md:Metadata = attributesToMetadata(n1);
					var new_node:Node;
					var my_kind:String = n1.attribute("kind");
					switch (my_kind) {
						case NodeTypes.SUBBOARD:
							new_node = new SubnetworkNode(Number(n1.layout.x), Number(n1.layout.y), Number(n1.layout.y), md);
						break;
						case NodeTypes.GET:
							new_node = new MapGetNode(Number(n1.layout.x), Number(n1.layout.y), Number(n1.layout.y), md);
						break;
						default:
							new_node = new Node(Number(n1.layout.x), Number(n1.layout.y), Number(n1.layout.y), my_kind, md);
						break;
					}
					my_levelNodes.addNode(new_node, my_board_xml.attribute("name"));
				}
				
				if (my_board_xml["display"].length() > 0) {
					var boardNode:BoardNodes = my_levelNodes.getDictionary(my_board_xml.attribute("name"));
					if(boardNode)
					{
						var boardDisplayXML:XMLList = my_board_xml["display"];
						boardNode.metadata["display"] = boardDisplayXML[0];
					}
				}
				
				for each (var e1:XML in my_board_xml["edge"]) {
					var md1:Metadata = attributesToMetadata(e1);
					if ( (e1["from"]["noderef"].attribute("id").length() != 1) || (e1["from"]["noderef"].attribute("port").length() != 1) ) {
						VerigameSystem.printDebug("WARNING: Edge #id = " + e1.attribute("id") + " does not have a source node id/port");
						return null;
					}
					if ( (e1["to"]["noderef"].attribute("id").length() != 1) || (e1["to"]["noderef"].attribute("port").length() != 1) ) {
						VerigameSystem.printDebug("WARNING: Edge #id = " + e1.attribute("id") + " does not have a destination node id/port");
						return null;
					}
					
					source_node = my_levelNodes.getNode(my_board_xml.attribute("name"), e1["from"]["noderef"].attribute("id").toString());
					dest_node = my_levelNodes.getNode(my_board_xml.attribute("name"), e1["to"]["noderef"].attribute("id").toString());
					
					if ( (source_node == null) || (dest_node == null) ) {
						VerigameSystem.printDebug("WARNING: Edge #id = " + e1.attribute("id") + " could not find node with getNodeById() method.");
						return null;
					}
					
					var spline_control_points:Vector.<Point> = new Vector.<Point>();
					for each (var pts:XML in e1["edge-layout"]) {
						for each (var pt:XML in pts["point"]) {
							var pt_x:String = pt["x"];
							var pt_y:String = pt["y"];
							if (!isNaN(Number(pt_x)) && !isNaN(Number(pt_y))) {
								spline_control_points.push(new Point(Number(pt_x), Number(pt_y)));
							}
						}
					}
					
					// Add this edge!
					source_node.addOutgoingEdge(e1["from"]["noderef"].attribute("port").toString(), dest_node, e1["to"]["noderef"].attribute("port").toString(), spline_control_points, edge_set_dictionary[e1.attribute("id").toString()], md1);
				}
			} // loop over every node a.k.a. board
			
			if (my_level_xml["display"].length() != 0) {
				var levelDisplayXML:XMLList = my_board_xml["display"];
				my_levelNodes.metadata["display"] = levelDisplayXML;		
			}
			
			if (my_level_xml.attribute("index").length() != 0) {
				my_levelNodes.metadata["index"] = new Number(my_level_xml.attribute("index"));		
			}
			
			VerigameSystem.printDebug("Level layout LOADED!");
			return my_levelNodes;
		}
		
		/**
		 * Converts all XML attributes for the XML object to metadata to be stored in an edge/node
		 * @param	_xml XML to load attributes from
		 * @return Metadata object created with attributes
		 */
		public static function attributesToMetadata(_xml:XML):Metadata {
			// This function grabs all the attribute key/value pairs and stores them as a Metadata object
			// NOTE: All values are stored as Strings, no type casting is performed unless specifically laid out
			var obj:Object = new Object();
			for each (var attr:XML in _xml.attributes()) {
				//trace("obj['" + attr.name().localName + "'] = " + _xml.attribute(attr.name()).toString());
				if (attr.name() == "id") {
					obj[attr.name().localName] = _xml.attribute(attr.name()).toString();// this could be parse to int, but is not
				} else {
					obj[attr.name().localName] = _xml.attribute(attr.name()).toString();
				}
				if (_xml.attribute(attr.name()).length() == 0)
					VerigameSystem.printWarning("WARNING! Attribute '"+attr.name()+"' value found for this XML.");
				else if (_xml.attribute(attr.name()).length() > 1)
					VerigameSystem.printWarning("WARNING! More than one attribute '"+attr.name()+"' value was found for this XML.");
			}
			return new Metadata(obj, _xml);
		}
		
	}

}