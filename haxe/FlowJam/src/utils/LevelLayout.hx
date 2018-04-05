package utils;

import flash.errors.Error;
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
class LevelLayout
{
    
    public static function parseLevelXML(my_level_xml : FastXML, network : Network, obfuscater : NameObfuscater = null) : Void
    {
        var level_edge_set_dictionary : Dictionary = new Dictionary();
        var my_levelNodes : LevelNodes = new LevelNodes(Std.string(my_level_xml.node.attribute.innerData("name")), obfuscater, level_edge_set_dictionary);
        
        if (my_level_xml.get("boards").length() == 0)
        {
            Game.printDebug("NO <boards> found. Level not created...");
            return;
        }
        
        // Check for boards
        if (my_level_xml.get("boards").get(0).get("board").length() == 0)
        {
            Game.printDebug("NO <boards> <board> 's found. Level not created...");
            return;
        }
        
        // Check for edges
        if (my_level_xml.get("boards").get(0).get("board").get("edge").node.attribute.innerData("description").length() == 0)
        {
            Game.printDebug("NO <boards> <edge> 's found. Level not created...");
            return;
        }
        
        if ((network.world_version == "1") || (network.world_version == "2") || (network.world_version == ""))
        
        // Check for linked edge sets{
            
            if (my_level_xml.get("linked-edges").get(0).get("edge-set").length() == 0)
            {
                Game.printDebug("NO <linked-edges> <edge-set> 's found. Level not created...");
                return;
            }
        }
        
        // Retrieve stub board widths
        var stub_boards_xml_list : FastXMLList = my_level_xml.get("boards").get(0).get("board-stub");
        var my_stub_board_xml : FastXML;
        for (sb in 0...stub_boards_xml_list.length())
        {
            my_stub_board_xml = stub_boards_xml_list.get(sb);
            var stub_name : String = my_stub_board_xml.node.attribute.innerData("name");
            var stub_inputs_list : FastXMLList;
            if (my_stub_board_xml.get("stub-input") != null && my_stub_board_xml.get("stub-input").length() && my_stub_board_xml.get("stub-input").get(0) != null)
            {
                stub_inputs_list = my_stub_board_xml.get("stub-input").get(0).get("stub-connection");
            }
            if (stub_inputs_list != null)
            {
                for (sbi in 0...stub_inputs_list.length())
                {
                    var input_stub_xml : FastXML = stub_inputs_list.get(sbi);
                    var input_stub_port_num : String = input_stub_xml.node.attribute.innerData("num");
                    var input_stub_width : String = input_stub_xml.node.attribute.innerData("width");
                    my_levelNodes.addStubBoardPortWidth(stub_name, input_stub_port_num, input_stub_width, true);
                }
            }
            
            var stub_outputs_list : FastXMLList;
            if (my_stub_board_xml.get("stub-output") != null && my_stub_board_xml.get("stub-output").length() && my_stub_board_xml.get("stub-output").get(0) != null)
            {
                stub_outputs_list = my_stub_board_xml.get("stub-output").get(0).get("stub-connection");
            }
            if (stub_outputs_list != null)
            {
                for (sbo in 0...stub_outputs_list.length())
                {
                    var output_stub_xml : FastXML = stub_outputs_list.get(sbo);
                    var output_stub_port_num : String = output_stub_xml.node.attribute.innerData("num");
                    var output_stub_width : String = output_stub_xml.node.attribute.innerData("width");
                    my_levelNodes.addStubBoardPortWidth(stub_name, output_stub_port_num, output_stub_width, false);
                }
            }
        }
        
        var my_edge_set : EdgeSetRef;
        var edge_id_to_edge_set_dictionary : Dictionary;
        if ((network.world_version == "1") || (network.world_version == "2") || (network.world_version == ""))
        {
            edge_id_to_edge_set_dictionary = new Dictionary();
            var edge_set_index : Int = 0;
            for (le_set in my_level_xml.get("linked-edges").get(0).get("edge-set"))
            {
                if (le_set.get("edgeref").node.attribute.innerData("id").length() > 0)
                {
                    var my_id : String = Std.string(le_set.node.attribute.innerData("id"));
                    if (my_id.length == 0)
                    {
                        my_id = Std.string(edge_set_index);
                    }
                    my_edge_set = new EdgeSetRef(my_id);
                    for (le_id_indx in 0...le_set.get("edgeref").node.attribute.innerData("id").length())
                    {
                        Reflect.setField(level_edge_set_dictionary, my_id, my_edge_set);
                        edge_id_to_edge_set_dictionary[Std.string(le_set.get("edgeref").nodes.attribute("id")[le_id_indx])] = my_edge_set;
                    }
                    for (stamp_id_indx in 0...le_set.get("stamp").length())
                    {
                        var isActive : Bool = XString.stringToBool(Std.string(le_set.get("stamp").get(stamp_id_indx).node.attribute.innerData("active")));
                        my_edge_set.addStamp(Std.string(le_set.get("stamp").get(stamp_id_indx).node.attribute.innerData("id")), isActive);
                    }
                    edge_set_index++;
                }
            }
        }
        else if (network.world_version == "3")
        {
            edge_id_to_edge_set_dictionary = network.globalEdgeIdToEdgeSetDictionary;
        }
        
        var my_board_xml : FastXML;
        var source_node : Node;
        var dest_node : Node;
        var boards_xml_list : FastXMLList = my_level_xml.get("boards").get(0).get("board");
        for (b in 0...boards_xml_list.length())
        {
            my_board_xml = boards_xml_list.get(b);
            Game.printDebug("Processing board: " + my_board_xml.node.attribute.innerData("name"));
            
            // FORM NODE/EDGE OBJECTS FROM XML
            for (n1 in my_board_xml.get("node"))
            {
                var md : Metadata = attributesToMetadata(n1);
                var new_node : Node;
                var my_kind : String = n1.node.attribute.innerData("kind");
                switch (my_kind)
                {
                    case NodeTypes.SUBBOARD:
                        new_node = new SubnetworkNode(as3hx.Compat.parseFloat(n1.node.layout.innerData.node.x.innerData), as3hx.Compat.parseFloat(n1.node.layout.innerData.node.y.innerData), as3hx.Compat.parseFloat(n1.node.layout.innerData.node.y.innerData), md);
                    case NodeTypes.GET:
                        new_node = new MapGetNode(as3hx.Compat.parseFloat(n1.node.layout.innerData.node.x.innerData), as3hx.Compat.parseFloat(n1.node.layout.innerData.node.y.innerData), as3hx.Compat.parseFloat(n1.node.layout.innerData.node.y.innerData), md);
                    default:
                        new_node = new Node(as3hx.Compat.parseFloat(n1.node.layout.innerData.node.x.innerData), as3hx.Compat.parseFloat(n1.node.layout.innerData.node.y.innerData), as3hx.Compat.parseFloat(n1.node.layout.innerData.node.y.innerData), my_kind, md);
                }
                my_levelNodes.addNode(new_node, my_board_xml.node.attribute.innerData("name"));
            }
            
            if (my_board_xml.get("display").length() > 0)
            {
                var boardNode : BoardNodes = my_levelNodes.getBoardNodes(my_board_xml.node.attribute.innerData("name"));
                if (boardNode != null)
                {
                    var boardDisplayXML : FastXMLList = my_board_xml.get("display");
                    boardNode.metadata["display"] = boardDisplayXML.get(0);
                }
                else
                {
                    Game.printDebug("WARNING: BoardNodes not generated yet for this <display name='" + my_board_xml.node.attribute.innerData("name") + "'/>");
                }
            }
            
            for (e1 in my_board_xml.get("edge"))
            {
                var md1 : Metadata = attributesToMetadata(e1);
                if ((e1.get("from").get("noderef").node.attribute.innerData("id").length() != 1) || (e1.get("from").get("noderef").node.attribute.innerData("port").length() != 1))
                {
                    Game.printDebug("WARNING: Edge #id = " + e1.node.attribute.innerData("id") + " does not have a source node id/port");
                    return;
                }
                if ((e1.get("to").get("noderef").node.attribute.innerData("id").length() != 1) || (e1.get("to").get("noderef").node.attribute.innerData("port").length() != 1))
                {
                    Game.printDebug("WARNING: Edge #id = " + e1.node.attribute.innerData("id") + " does not have a destination node id/port");
                    return;
                }
                
                source_node = my_levelNodes.getNode(  /*my_board_xml.attribute("name"),*/  Std.string(e1.get("from").get("noderef").node.attribute.innerData("id")));
                dest_node = my_levelNodes.getNode(  /*my_board_xml.attribute("name"),*/  Std.string(e1.get("to").get("noderef").node.attribute.innerData("id")));
                
                if ((source_node == null) || (dest_node == null))
                {
                    Game.printDebug("WARNING: Edge #id = " + e1.node.attribute.innerData("id") + " could not find node with getNodeById() method.");
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
                if (network.world_version == "3")
                {
                    var my_edge_id : String = Std.string(e1.node.attribute.innerData("id"));
                    var my_edge_varid : String = Std.string(e1.node.attribute.innerData("variableID"));
                    if (!Math.isNaN(as3hx.Compat.parseInt(my_edge_varid)) && (as3hx.Compat.parseInt(my_edge_varid) < 0))
                    
                    // TODO: Undo this hack for negative variable ids{
                        
                        my_edge_varid = Constants.XML_ANNOT_NEG + my_edge_id;
                    }
                    if (my_edge_id == null)
                    {
                        throw new Error("Bad edge id found:" + my_edge_id);
                    }
                    if (my_edge_varid == null)
                    {
                        throw new Error("Bad edge variable id found:" + my_edge_varid + " edge id:" + my_edge_id);
                    }
                    network.addEdge(my_edge_id, my_edge_varid);
                }
                
                if (!edge_id_to_edge_set_dictionary.exists(Std.string(e1.node.attribute.innerData("id"))))
                {
                    throw new Error("No EdgeSetRef found for edge id:" + Std.string(e1.node.attribute.innerData("id")));
                }
                
                // Add this edge!
                var new_edge : Edge = source_node.addOutgoingEdge(Std.string(e1.get("from").get("noderef").node.attribute.innerData("port")), dest_node, Std.string(e1.get("to").get("noderef").node.attribute.innerData("port")), edge_id_to_edge_set_dictionary[Std.string(e1.node.attribute.innerData("id"))], my_levelNodes.original_level_name, md1);
                // Check for stubs
                var subnet_port : SubnetworkPort;
                var subboard_name : String;
                var foundWidth : String;
                if (Std.is(new_edge.from_port, SubnetworkPort))
                {
                    subnet_port = try cast(new_edge.from_port, SubnetworkPort) catch(e:Dynamic) null;
                    subboard_name = (try cast(subnet_port.node, SubnetworkNode) catch(e:Dynamic) null).subboard_name;
                    foundWidth = my_levelNodes.getStubBoardPortWidth(subboard_name, subnet_port.port_id, false);
                    if (foundWidth != null)
                    {
                        subnet_port.setDefaultWidth(foundWidth);
                    }
                }
                if (Std.is(new_edge.to_port, SubnetworkPort))
                {
                    subnet_port = try cast(new_edge.to_port, SubnetworkPort) catch(e:Dynamic) null;
                    subboard_name = (try cast(subnet_port.node, SubnetworkNode) catch(e:Dynamic) null).subboard_name;
                    foundWidth = my_levelNodes.getStubBoardPortWidth(subboard_name, subnet_port.port_id, true);
                    if (foundWidth != null)
                    {
                        subnet_port.setDefaultWidth(foundWidth);
                    }
                }
                my_levelNodes.addEdge(new_edge);
            }
        }  // loop over every node a.k.a. board  
        
        if (my_level_xml.get("display").length() != 0)
        {
            var levelDisplayXML : FastXMLList = my_board_xml.get("display");
            my_levelNodes.metadata["display"] = levelDisplayXML;
        }
        
        if (my_level_xml.node.attribute.innerData("index").length() != 0)
        {
            my_levelNodes.metadata["index"] = new Float(my_level_xml.node.attribute.innerData("index"));
        }
        
        if (my_level_xml.node.attribute.innerData("qid").length() != 0 && !Math.isNaN(as3hx.Compat.parseInt(my_level_xml.node.attribute.innerData("qid"))))
        {
            my_levelNodes.qid = as3hx.Compat.parseInt(my_level_xml.node.attribute.innerData("qid"));
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
    public static function attributesToMetadata(_xml : FastXML) : Metadata
    // This function grabs all the attribute key/value pairs and stores them as a Metadata object
    {
        
        // NOTE: All values are stored as Strings, no type casting is performed unless specifically laid out
        var obj : Dynamic = {};
        for (attr/* AS3HX WARNING could not determine type for var: attr exp: ECall(EField(EIdent(_xml),attributes),[]) type: null */ in _xml.nodes.attributes())
        
        //trace("obj['" + attr.name().localName + "'] = " + _xml.attribute(attr.name()).toString());{
            
            if (attr.name() == "id")
            {
                Reflect.setField(obj, Std.string(attr.name().localName), Std.string(_xml.node.attribute.innerData(attr.name())));
            }
            else
            {
                Reflect.setField(obj, Std.string(attr.name().localName), Std.string(_xml.node.attribute.innerData(attr.name())));
            }
            if (_xml.node.attribute.innerData(attr.name()).length() == 0)
            {
                Game.printWarning("WARNING! Attribute '" + attr.name() + "' value found for this XML.");
            }
            else if (_xml.node.attribute.innerData(attr.name()).length() > 1)
            {
                Game.printWarning("WARNING! More than one attribute '" + attr.name() + "' value was found for this XML.");
            }
        }
        return new Metadata(obj, _xml);
    }
    
    public static function parseLinkedVariableIdXML(world_xml : FastXML, network : Network) : Void
    {
        var link_xml : FastXML = world_xml.get("linked-varIDs").get(0);
        for (i in 0...link_xml.get("varID-set").length())
        {
            var var_set : FastXML = link_xml.get("varID-set").get(i);
            var set_id : String = var_set.att.id;
            for (j in 0...var_set.get("varID").length())
            {
                var var_id_xml : FastXML = var_set.get("varID").get(j);
                var var_id : String = var_id_xml.att.id;
                network.addLinkedVariableId(var_id, set_id);
            }
        }
    }

    public function new()
    {
    }
}

