package tasks;

import flash.errors.Error;
import networkGraph.LevelNodes;
import networkGraph.Network;
import utilities.LevelLayout;

class ParseLevelXMLTask extends Task
{
    
    private var level_xml : FastXML;
    private var worldNodes : Network;
    
    public function new(_level_xml : FastXML, _worldNodes : Network, _id : String = "", _dependentTaskIds : Array<String> = null)
    {
        level_xml = _level_xml;
        worldNodes = _worldNodes;
        if (_id.length == 0)
        {
            _id = Std.string(level_xml.node.attribute.innerData("name"));
        }
        super(_id, _dependentTaskIds);
    }
    
    override public function perform() : Void
    {
        super.perform();
        var my_level_nodes : LevelNodes = LevelLayout.parseLevelXML(level_xml, worldNodes.obfuscator);
        if (worldNodes.worldNodesDictionary[my_level_nodes.level_name] == null)
        {
            worldNodes.worldNodesDictionary[my_level_nodes.level_name] = my_level_nodes;
        }
        else
        {
            throw new Error("Duplicate Level entries found for level: " + Std.string(level_xml.node.attribute.innerData("name")));
        }
        complete = true;
    }
}

