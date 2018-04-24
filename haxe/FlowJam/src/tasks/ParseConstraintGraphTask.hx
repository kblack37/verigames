package tasks;

import constraints.ConstraintGraph;
import flash.utils.Dictionary;
import graph.LevelNodes;

class ParseConstraintGraphTask extends Task
{
    
    private var levelObj : Dynamic;
    private var worldGraphDict : Dynamic;
    
    public function new(_levelObj : Dynamic, _worldGraphDict : Dynamic, _dependentTaskIds : Array<String> = null)
    {
        levelObj = _levelObj;
        worldGraphDict = _worldGraphDict;
        var _id : String = Reflect.field(levelObj, "id");
        super(_id, _dependentTaskIds);
    }
    
    override public function perform() : Void
    {
        super.perform();
        var levelGraph : ConstraintGraph = ConstraintGraph.fromJSON(levelObj);
		Reflect.setField(worldGraphDict, id, levelGraph);
        complete = true;
    }
}

