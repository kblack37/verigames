package utilities;

import flash.errors.Error;
import networkGraph.*;
import networkGraph.LevelNodes;
import networkGraph.Network;
import visualWorld.Board;
import visualWorld.Level;
import visualWorld.VerigameSystem;
import visualWorld.World;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.utils.Dictionary;

/**
	 * Class to read XML and create/link node objects and edge objects from them
	*/
class LevelLayout
{
    
    /**
		 * Function reads XML and creates/links node objects and edge objects from previously laid out XML
		 * @param	_input_xml XML (with layout information) to be read
		 * @param	_system VerigameSystem with the world created using the input XML
		 * @return
		 */
    public static function parseLaidOutXML(_input_xml : FastXML, _system : VerigameSystem = null) : VerigameSystem
    {
        DebugTimer.beginTiming("Convert XML to node/edge/port objects");
        var input_xml : FastXML = _input_xml;
        var version_failed : Bool = false;
        if (input_xml.node.attribute.innerData("version") == null)
        {
            version_failed = true;
        }
        else if (Std.string(input_xml.node.attribute.innerData("version")) != PipeJamController.WORLD_INPUT_XML_VERSION)
        {
            version_failed = true;
        }
        if (version_failed)
        {
            VerigameSystem.printWarning("Error: World XML version used does not match the version that this game .SWF is designed to read. The game is designed to read version '" + PipeJamController.WORLD_INPUT_XML_VERSION + "'");
            throw new Error("World XML version used does not match the version that this game .SWF is designed to read. The game is designed to read version '" + PipeJamController.WORLD_INPUT_XML_VERSION + "'");
            return;
        }
        var my_world_name : String = "World 1";
        if (input_xml.node.attribute.innerData("name") != null)
        {
            if (Std.string(input_xml.node.attribute.innerData("name")).length > 0)
            {
                my_world_name = Std.string(input_xml.node.attribute.innerData("name"));
            }
        }
        
        var worldNodes : Network = new Network(my_world_name);
        
        var my_level_xml : FastXML;
        for (level_index in 0...input_xml.get("level").length())
        {
            my_level_xml = input_xml.get("level").get(level_index);
            
            var my_levelNodes : LevelNodes = parseLevelXML(my_level_xml);
            
            if (worldNodes.worldNodesDictionary[Std.string(my_level_xml.node.attribute.innerData("name"))] == null)
            {
                worldNodes.worldNodesDictionary[Std.string(my_level_xml.node.attribute.innerData("name"))] = my_levelNodes;
            }
            else
            {
                throw new Error("Duplicate level names found for level: " + Std.string(my_level_xml.node.attribute.innerData("name")));
            }
        }  // level_index for loop  
        VerigameSystem.printDebug("World layout LOADED!");
        DebugTimer.reportTime("Convert XML to node/edge/port objects");
        DebugTimer.beginTiming("Create VerigameSystem");
        if (_system == null)
        {
            _system = new VerigameSystem(0, 0, 1024, 768, null);
        }
        DebugTimer.reportTime("Create VerigameSystem");
        var new_world : World = _system.createWorldFromNodes(worldNodes, input_xml);
        _system.worlds.push(new_world);
        
        if (_system.worlds.length == 1)
        {
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
    
    public static function parseLevelXML(my_level_xml : FastXML, obfuscater : NameObfuscater = null) : LevelNodes
    {
        var my_levelNodes : LevelNodes = new LevelNodes(Std.string(my_level_xml.node.attribute.innerData("name")), obfuscater);
        
        if (my_level_xml.get("boards").length() == 0)
        {
            VerigameSystem.printDebug("NO <boards> found. Level not created...");
            return null;
        }
        
        // Obtain boards
        if (my_level_xml.get("boards").get(0).get("board").length() == 0)
        {
            VerigameSystem.printDebug("NO <boards> <board> 's found. Level not created...");
            return null;
        }
        var boards_xml_list : FastXMLList = my_level_xml.get("boards").get(0).get("board");
        
        // Obtain edges
        if (my_level_xml.get("boards").get(0).get("board").get("edge").node.attribute.innerData("description").length() == 0)
        {
            VerigameSystem.printDebug("NO <boards> <edge> 's found. Level not created...");
            return null;
        }
        
        // Obtain linked edge sets
        var edge_set_dictionary : Dictionary = new Dictionary();
        if (my_level_xml.get("linked-edges").get(0).get("edge-set").length() == 0)
        {
            VerigameSystem.printDebug("NO <linked-edges> <edge-set> 's found. Level not created...");
            return null;
        }
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
                var my_edge_set : EdgeSetRef = new EdgeSetRef(my_id, edge_set_dictionary);
                for (le_id_indx in 0...le_set.get("edgeref").node.attribute.innerData("id").length())
                {
                    edge_set_dictionary[Std.string(le_set.get("edgeref").nodes.attribute("id")[le_id_indx])] = my_edge_set;
                    my_edge_set.edge_ids.push(Std.string(le_set.get("edgeref").nodes.attribute("id")[le_id_indx]));
                }
                for (stamp_id_indx in 0...le_set.get("stamp").length())
                {
                    var isActive : Bool = XString.stringToBool(Std.string(le_set.get("stamp").get(stamp_id_indx).node.attribute.innerData("active")));
                    my_edge_set.addStamp(Std.string(le_set.get("stamp").get(stamp_id_indx).node.attribute.innerData("id")), isActive);
                }
                edge_set_index++;
            }
        }
        
        var my_board_xml : FastXML;
        var source_node : Node;
        var dest_node : Node;
        for (b in 0...boards_xml_list.length())
        {
            my_board_xml = boards_xml_list.get(b);
            VerigameSystem.printDebug("Processing board: " + my_board_xml.node.attribute.innerData("name"));
            
            
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
                var boardNode : BoardNodes = my_levelNodes.getDictionary(my_board_xml.node.attribute.innerData("name"));
                if (boardNode != null)
                {
                    var boardDisplayXML : FastXMLList = my_board_xml.get("display");
                    boardNode.metadata["display"] = boardDisplayXML.get(0);
                }
            }
            
            for (e1 in my_board_xml.get("edge"))
            {
                var md1 : Metadata = attributesToMetadata(e1);
                if ((e1.get("from").get("noderef").node.attribute.innerData("id").length() != 1) || (e1.get("from").get("noderef").node.attribute.innerData("port").length() != 1))
                {
                    VerigameSystem.printDebug("WARNING: Edge #id = " + e1.node.attribute.innerData("id") + " does not have a source node id/port");
                    return null;
                }
                if ((e1.get("to").get("noderef").node.attribute.innerData("id").length() != 1) || (e1.get("to").get("noderef").node.attribute.innerData("port").length() != 1))
                {
                    VerigameSystem.printDebug("WARNING: Edge #id = " + e1.node.attribute.innerData("id") + " does not have a destination node id/port");
                    return null;
                }
                
                source_node = my_levelNodes.getNode(my_board_xml.node.attribute.innerData("name"), Std.string(e1.get("from").get("noderef").node.attribute.innerData("id")));
                dest_node = my_levelNodes.getNode(my_board_xml.node.attribute.innerData("name"), Std.string(e1.get("to").get("noderef").node.attribute.innerData("id")));
                
                if ((source_node == null) || (dest_node == null))
                {
                    VerigameSystem.printDebug("WARNING: Edge #id = " + e1.node.attribute.innerData("id") + " could not find node with getNodeById() method.");
                    return null;
                }
                
                var spline_control_points : Array<Point> = new Array<Point>();
                for (pts in e1.get("edge-layout"))
                {
                    for (pt in pts.get("point"))
                    {
                        var pt_x : String = pt.get("x");
                        var pt_y : String = pt.get("y");
                        if (!Math.isNaN(as3hx.Compat.parseFloat(pt_x)) && !Math.isNaN(as3hx.Compat.parseFloat(pt_y)))
                        {
                            spline_control_points.push(new Point(as3hx.Compat.parseFloat(pt_x), as3hx.Compat.parseFloat(pt_y)));
                        }
                    }
                }
                
                // Add this edge!
                source_node.addOutgoingEdge(Std.string(e1.get("from").get("noderef").node.attribute.innerData("port")), dest_node, Std.string(e1.get("to").get("noderef").node.attribute.innerData("port")), spline_control_points, edge_set_dictionary[Std.string(e1.node.attribute.innerData("id"))], md1);
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
        
        VerigameSystem.printDebug("Level layout LOADED!");
        return my_levelNodes;
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
                VerigameSystem.printWarning("WARNING! Attribute '" + attr.name() + "' value found for this XML.");
            }
            else if (_xml.node.attribute.innerData(attr.name()).length() > 1)
            {
                VerigameSystem.printWarning("WARNING! More than one attribute '" + attr.name() + "' value was found for this XML.");
            }
        }
        return new Metadata(obj, _xml);
    }

    public function new()
    {
    }
}

