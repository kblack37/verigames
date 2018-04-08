package tasks;

import constraints.ConstraintGraph;
import flash.utils.Dictionary;

class ParseConstraintGraphTask extends Task
{
    
    private var levelObj : Dynamic;
    private var worldGraphDict : Dictionary;
    public var levelGraph : ConstraintGraph;
    
    public function new(_levelObj : Dynamic, _worldGraphDict : Dictionary, _dependentTaskIds : Array<String> = null)
    {
        levelObj = _levelObj;
        
        worldGraphDict = _worldGraphDict;
        var _id : String = Reflect.field(levelObj, "id");
        super(_id, _dependentTaskIds);
    }
    
    override public function perform() : Void
    {
        super.perform();
        if (levelGraph == null)
        {
            levelGraph = ConstraintGraph.initFromJSON(levelObj);
            worldGraphDict[id] = levelGraph;
        }
        else
        {
            complete = levelGraph.buildNextPartOfGraph();
        }
    }
}
