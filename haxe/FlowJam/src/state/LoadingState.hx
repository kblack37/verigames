package state;

import flash.events.TimerEvent;
import flash.utils.Timer;
import tasks.Task;

class LoadingState extends GenericState
{
    /** Every TIME_BETWEEN_RENDERS_MS milliseconds, stop loading to render the progress bar */
    private static inline var TIME_BETWEEN_RENDERS_MS : Float = 100.0;
    
    /** RENDER_TIME_MS is the amount of time that loading is stopped in order to render the progress bar */
    private static inline var RENDER_TIME_MS : Float = 2.0;
    
    private var tasksVector : Array<Task> = new Array<Task>();
    private var completed_tasks : Array<Task> = new Array<Task>();
    private var last_render_time : Float;
    private var timer : Timer;
    
    public function new(_task : String = "Loading...")
    {
        super();
    }
    
    override public function stateLoad() : Void
    {
        super.stateLoad();
        updateStatus();
        performNextTask({});
    }
    
    override public function stateUnload() : Void
    {
        super.stateUnload();
        tasksVector = null;
        completed_tasks = null;
    }
    
    override public function stateUpdate() : Void
    {
    }
    
    public function performNextTask(e : Dynamic) : Void
    {
		trace(this.tasksVector.length);
        if (this.tasksVector.length == 0)
        {
            updateStatus();
            onTasksComplete();
            return;
        }
        var now : Float = Date.now().getTime();
        if (now - last_render_time > TIME_BETWEEN_RENDERS_MS)
        {
			last_render_time = now;
            updateStatus();
            timer = new Timer(RENDER_TIME_MS / 1000);
            timer.addEventListener(TimerEvent.TIMER, performNextTask);
            timer.start();
            return;
        }
        tasksVector[0].perform();
        var my_task : Task = tasksVector.shift();
        completed_tasks.push(my_task);
        performNextTask({});
    }
    
    public function updateStatus() : Void
    {
    }
    
    public function onTasksComplete() : Void
    {  // implemented by children  
        
    }
}

