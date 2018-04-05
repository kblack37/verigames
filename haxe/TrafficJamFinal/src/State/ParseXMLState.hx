package state;

import flash.errors.Error;
import visualWorld.VerigameSystem;
import visualWorld.World;
import networkGraph.Network;
import tasks.ParseLevelXMLTask;

class ParseXMLState extends LoadingState
{
    
    private var world_xml : FastXML;
    public var world_nodes : Network;
    
    public function new(_world_xml : FastXML)
    {
        world_xml = _world_xml;
        super("Parsing XML...");
    }
    
    override public function stateLoad() : Void
    {
        var version_failed : Bool = false;
        
        if ("1" == null)
        {
            version_failed = true;
        }
        else if ("1" != PipeJamController.WORLD_INPUT_XML_VERSION)
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
        if (world_xml.node.attribute.innerData("name") != null)
        {
            if (Std.string(world_xml.node.attribute.innerData("name")).length > 0)
            {
                my_world_name = Std.string(world_xml.node.attribute.innerData("name"));
            }
        }
        
        world_nodes = new Network(my_world_name);
        
        for (level_index in 0...world_xml.get("level").length())
        {
            var my_level_xml : FastXML = world_xml.get("level").get(level_index);
            var my_task : ParseLevelXMLTask = new ParseLevelXMLTask(my_level_xml, world_nodes);
            tasks.push(my_task);
        }
        
        super.stateLoad();
    }
    
    override public function stateUnload() : Void
    {
        super.stateUnload();
        world_xml = null;
        world_nodes = null;
    }
    
    override public function onTasksComplete() : Void
    {
        PipeJamController.mainController.tasksComplete(world_nodes);
        stateUnload();
    }
}

