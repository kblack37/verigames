package utils 
{
	import graph.*;
	import graph.LevelNodes;
	import graph.Network;
	
	import system.VerigameServerConstants;
	import Game;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * Class to read XML and create/link node objects and edge objects from them
	*/
	public class LevelLayout 
	{
	
		public static function parseLevelXML(my_level_xml:XML, network:Network, obfuscater:NameObfuscater = null):void {
			var level_edge_set_dictionary:Dictionary = new Dictionary();
			var my_levelNodes:LevelNodes = new LevelNodes(my_level_xml.attribute("name").toString(), obfuscater, level_edge_set_dictionary);
			
			if (my_level_xml["boards"].length() == 0) {
				Game.printDebug("NO <boards> found. Level not created...");
				return;
			}
			
			// Check for boards
			if (my_level_xml["boards"][0]["board"].length() == 0) {
				Game.printDebug("NO <boards> <board> 's found. Level not created...");
				return;
			}
			
			// Check for edges
			if (my_level_xml["boards"][0]["board"]["edge"].attribute("description").length() == 0) {
				Game.printDebug("NO <boards> <edge> 's found. Level not created...");
				return;
			}
			
			if ((network.world_version == "1") || (network.world_version == "2")  || (network.world_version == "")) {
				// Check for linked edge sets
				if (my_level_xml["linked-edges"][0]["edge-set"].length() == 0) {
					Game.printDebug("NO <linked-edges> <edge-set> 's found. Level not created...");
					return;
				}
			}
			
			// Retrieve stub board widths
			var stub_boards_xml_list:XMLList = my_level_xml["boards"][0]["board-stub"];
			var my_stub_board_xml:XML;
			for (var sb:uint = 0; sb < stub_boards_xml_list.length(); sb++) {
				my_stub_board_xml = stub_boards_xml_list[sb];
				var stub_name:String = my_stub_board_xml.attribute("name");
				var stub_inputs_list:XMLList;
				if (my_stub_board_xml["stub-input"] && my_stub_board_xml["stub-input"].length() && my_stub_board_xml["stub-input"][0]) {
					stub_inputs_list = my_stub_board_xml["stub-input"][0]["stub-connection"];
				}
				if (stub_inputs_list) {
					for (var sbi:uint = 0; sbi < stub_inputs_list.length(); sbi++) {
						var input_stub_xml:XML = stub_inputs_list[sbi];
						var input_stub_port_num:String = input_stub_xml.attribute("num");
						var input_stub_width:String = input_stub_xml.attribute("width");
						my_levelNodes.addStubBoardPortWidth(stub_name, input_stub_port_num, input_stub_width, true);
						//trace("Found stub board '" + stub_name + "' input " + input_stub_port_num + " width:" + input_stub_width);
					}
				}
				
				var stub_outputs_list:XMLList;
				if (my_stub_board_xml["stub-output"] && my_stub_board_xml["stub-output"].length() && my_stub_board_xml["stub-output"][0]) {
					stub_outputs_list = my_stub_board_xml["stub-output"][0]["stub-connection"];
				}
				if (stub_outputs_list) {
					for (var sbo:uint = 0; sbo < stub_outputs_list.length(); sbo++) {
						var output_stub_xml:XML = stub_outputs_list[sbo];
						var output_stub_port_num:String = output_stub_xml.attribute("num");
						var output_stub_width:String = output_stub_xml.attribute("width");
						my_levelNodes.addStubBoardPortWidth(stub_name, output_stub_port_num, output_stub_width, false);
						//trace("Found stub board '" + stub_name + "' output " + output_stub_port_num + " width:" + output_stub_width);
					}
				}
			}
			
			var my_edge_set:EdgeSetRef;
			var edge_id_to_edge_set_dictionary:Dictionary;
			if ((network.world_version == "1") || (network.world_version == "2")  || (network.world_version == "")) {
				edge_id_to_edge_set_dictionary = new Dictionary();
				var edge_set_index:int = 0;
				for each (var le_set:XML in my_level_xml["linked-edges"][0]["edge-set"]) {
					if (le_set["edgeref"].attribute("id").length() > 0) {
						var my_id:String = String(le_set.attribute("id"));
						if (my_id.length == 0) {
							my_id = edge_set_index.toString();
						}
						my_edge_set = new EdgeSetRef(my_id);
						for (var le_id_indx:uint = 0; le_id_indx < le_set["edgeref"].attribute("id").length(); le_id_indx++) {
							level_edge_set_dictionary[my_id] = my_edge_set;
							edge_id_to_edge_set_dictionary[le_set["edgeref"].attribute("id")[le_id_indx].toString()] = my_edge_set;
						}
						for (var stamp_id_indx:uint = 0; stamp_id_indx < le_set["stamp"].length(); stamp_id_indx++) {
							var isActive:Boolean = XString.stringToBool(String(le_set["stamp"][stamp_id_indx].attribute("active")));
							my_edge_set.addStamp(String(le_set["stamp"][stamp_id_indx].attribute("id")), isActive);
						}
						edge_set_index++;
					}
				}
			} else if (network.world_version == "3") {
				edge_id_to_edge_set_dictionary = network.globalEdgeIdToEdgeSetDictionary;
			}
			
			var my_board_xml:XML;
			var source_node:Node, dest_node:Node;
			var boards_xml_list:XMLList = my_level_xml["boards"][0]["board"];
			for (var b:uint = 0; b < boards_xml_list.length(); b++) {
				my_board_xml = boards_xml_list[b];
				Game.printDebug("Processing board: " + my_board_xml.attribute("name"));
				
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
					var boardNode:BoardNodes = my_levelNodes.getBoardNodes(my_board_xml.attribute("name"));
					if(boardNode) {
						var boardDisplayXML:XMLList = my_board_xml["display"];
						boardNode.metadata["display"] = boardDisplayXML[0];
					} else {
						Game.printDebug("WARNING: BoardNodes not generated yet for this <display name='"+my_board_xml.attribute("name")+"'/>");
					}
				}
				
				for each (var e1:XML in my_board_xml["edge"]) {
					var md1:Metadata = attributesToMetadata(e1);
					if ( (e1["from"]["noderef"].attribute("id").length() != 1) || (e1["from"]["noderef"].attribute("port").length() != 1) ) {
						Game.printDebug("WARNING: Edge #id = " + e1.attribute("id") + " does not have a source node id/port");
						return;
					}
					if ( (e1["to"]["noderef"].attribute("id").length() != 1) || (e1["to"]["noderef"].attribute("port").length() != 1) ) {
						Game.printDebug("WARNING: Edge #id = " + e1.attribute("id") + " does not have a destination node id/port");
						return;
					}
					
					source_node = my_levelNodes.getNode(/*my_board_xml.attribute("name"),*/ e1["from"]["noderef"].attribute("id").toString());
					dest_node = my_levelNodes.getNode(/*my_board_xml.attribute("name"),*/ e1["to"]["noderef"].attribute("id").toString());
					
					if ( (source_node == null) || (dest_node == null) ) {
						Game.printDebug("WARNING: Edge #id = " + e1.attribute("id") + " could not find node with getNodeById() method.");
						return;
					}
					/*
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
					*/
					
					// For v3, add to global edge_id -> edge set dictionary
					if (network.world_version == "3") {
						var my_edge_id:String = e1.attribute("id").toString();
						var my_edge_varid:String = e1.attribute("variableID").toString();
						if (!isNaN(int(my_edge_varid)) && (int(my_edge_varid) < 0)) {
							// TODO: Undo this hack for negative variable ids
							my_edge_varid = Constants.XML_ANNOT_NEG + my_edge_id;
						}
						if (!my_edge_id) throw new Error("Bad edge id found:" + my_edge_id);
						if (!my_edge_varid) throw new Error("Bad edge variable id found:" + my_edge_varid + " edge id:" + my_edge_id);
						network.addEdge(my_edge_id, my_edge_varid);
					}
					
					if (!edge_id_to_edge_set_dictionary.hasOwnProperty(e1.attribute("id").toString())) {
						throw new Error("No EdgeSetRef found for edge id:" + e1.attribute("id").toString());
					}
					
					// Add this edge!
					var new_edge:Edge = source_node.addOutgoingEdge(e1["from"]["noderef"].attribute("port").toString(), dest_node, e1["to"]["noderef"].attribute("port").toString(), edge_id_to_edge_set_dictionary[e1.attribute("id").toString()], my_levelNodes.original_level_name, md1);
					// Check for stubs
					var subnet_port:SubnetworkPort, subboard_name:String, foundWidth:String;
					if (new_edge.from_port is SubnetworkPort) {
						subnet_port = new_edge.from_port as SubnetworkPort;
						subboard_name = (subnet_port.node as SubnetworkNode).subboard_name;
						foundWidth = my_levelNodes.getStubBoardPortWidth(subboard_name, subnet_port.port_id, false);
						if (foundWidth) {
							subnet_port.setDefaultWidth(foundWidth);
						}
					}
					if (new_edge.to_port is SubnetworkPort) {
						subnet_port = new_edge.to_port as SubnetworkPort;
						subboard_name = (subnet_port.node as SubnetworkNode).subboard_name;
						foundWidth = my_levelNodes.getStubBoardPortWidth(subboard_name, subnet_port.port_id, true);
						if (foundWidth) {
							subnet_port.setDefaultWidth(foundWidth);
						}
					}
					my_levelNodes.addEdge(new_edge);
				}
			} // loop over every node a.k.a. board
			
			if (my_level_xml["display"].length() != 0) {
				var levelDisplayXML:XMLList = my_board_xml["display"];
				my_levelNodes.metadata["display"] = levelDisplayXML;		
			}
			
			if (my_level_xml.attribute("index").length() != 0) {
				my_levelNodes.metadata["index"] = new Number(my_level_xml.attribute("index"));		
			}
			
			if (my_level_xml.attribute("qid").length() != 0 && !isNaN(int(my_level_xml.attribute("qid")))) {
				my_levelNodes.qid = int(my_level_xml.attribute("qid"));
			}
			
			my_levelNodes.associateSubnetNodesToBoardNodes();
			
			Game.printDebug("Level layout LOADED!");
			network.addLevel(my_levelNodes);
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
					Game.printWarning("WARNING! Attribute '"+attr.name()+"' value found for this XML.");
				else if (_xml.attribute(attr.name()).length() > 1)
					Game.printWarning("WARNING! More than one attribute '"+attr.name()+"' value was found for this XML.");
			}
			return new Metadata(obj, _xml);
		}
		
		public static function parseLinkedVariableIdXML(world_xml:XML, network:Network):void
		{
			var link_xml:XML = world_xml["linked-varIDs"][0];
			for (var i:int = 0; i < link_xml["varID-set"].length(); i++) {
				var var_set:XML = link_xml["varID-set"][i];
				var set_id:String = var_set.@id;
				for (var j:int = 0; j < var_set["varID"].length(); j++) {
					var var_id_xml:XML = var_set["varID"][j];
					var var_id:String = var_id_xml.@id;
					network.addLinkedVariableId(var_id, set_id);
					
					// TODO: width, editable, stamps defined here
				}
			}
		}
		
	}

}