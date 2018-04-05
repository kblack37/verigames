package networkGraph;

import flash.utils.Dictionary;
import utilities.NameObfuscater;

class LevelNodes
{
    
    public var level_name : String;
    public var original_level_name : String;
    private var obfuscator : NameObfuscater;
    
    public var metadata : Dictionary = new Dictionary();
    
    /** This is a dictionary of BoardNodes, which is a dictionary of Nodes; INDEXED BY BOARD NAME AND NODE ID, RESPECTIVELY */
    public var boardNodesDictionary : Dictionary = new Dictionary();
    
    public function new(_original_level_name : String, _obfuscater : NameObfuscater = null)
    {
        original_level_name = _original_level_name;
        obfuscator = _obfuscater;
        if (obfuscator != null)
        {
            level_name = obfuscator.getLevelName(_original_level_name);
        }
        else
        {
            level_name = _original_level_name;
        }
    }
    
    public function addNode(_node : Node, _original_board_name : String) : Void
    {
        var new_board_name : String = _original_board_name;
        if (obfuscator != null)
        {
            new_board_name = obfuscator.getBoardName(_original_board_name, original_level_name);
        }
        if (Reflect.field(boardNodesDictionary, new_board_name) == null)
        {
            Reflect.setField(boardNodesDictionary, new_board_name, new BoardNodes(new_board_name));
        }
        (try cast(Reflect.field(boardNodesDictionary, new_board_name), BoardNodes) catch(e:Dynamic) null).addNode(_node);
    }
    
    public function getDictionary(_original_board_name : String) : BoardNodes
    {
        var new_board_name : String = _original_board_name;
        if (obfuscator != null)
        {
            new_board_name = obfuscator.getBoardName(_original_board_name, original_level_name);
        }
        return Reflect.field(boardNodesDictionary, new_board_name);
    }
    
    public function getNode(_original_board_name : String, _node_id : String) : Node
    {
        var new_board_name : String = _original_board_name;
        if (obfuscator != null)
        {
            new_board_name = obfuscator.getBoardName(_original_board_name, original_level_name);
        }
        if (Reflect.field(boardNodesDictionary, new_board_name) != null)
        {
            return (try cast(Reflect.field(boardNodesDictionary, new_board_name), BoardNodes) catch(e:Dynamic) null).nodeDictionary[_node_id];
        }
        return null;
    }
}

