package state;

import constraints.ConstraintGraph;
import engine.IGameEngine;
import flash.utils.Dictionary;
import starling.events.Event;
import tasks.ParseConstraintGraphTask;

class ParseConstraintGraphState extends LoadingState
{
    public static var WORLD_PARSED : String = "World Parsed";
    
	private var m_gameEngine : IGameEngine;
	
    private var worldObj : Dynamic;
    private var worldGraphsDict : Dynamic;
    
    public function new(gameEngine : IGameEngine, _worldObj : Dynamic)
    {
        super();
		m_gameEngine = gameEngine;
        worldObj = _worldObj;
    }
    
    override public function stateLoad() : Void
    {
        worldGraphsDict = {};
        var levelsArr : Array<Dynamic> = Reflect.field(worldObj, "levels");
        if (levelsArr != null)
        {
            for (levelObj in levelsArr)
            {
                var my_task : ParseConstraintGraphTask = new ParseConstraintGraphTask(levelObj, worldGraphsDict);
                tasksVector.push(my_task);
            }
        }
        else
        {
            var task : ParseConstraintGraphTask = new ParseConstraintGraphTask(worldObj, worldGraphsDict);
            tasksVector.push(task);
        }
        super.stateLoad();
    }
    
    override public function stateUnload() : Void
    {
        super.stateUnload();
        worldObj = null;
        worldGraphsDict = null;
    }
    
    override public function onTasksComplete() : Void
    {
        var event : starling.events.Event = new Event(WORLD_PARSED, true, worldGraphsDict);
        m_gameEngine.dispatchEvent(event);
        stateUnload();
    }
}

