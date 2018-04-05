package state;

import com.greensock.TweenLite;
import flash.display.DisplayObject;
import tasks.ParseLevelXMLTask;
import tasks.Task;
import userInterface.components.GenericProgressBar;

class LoadingState extends GenericState
{
    /** Every TIME_BETWEEN_RENDERS_MS milliseconds, stop loading to render the progress bar */
    private static inline var TIME_BETWEEN_RENDERS_MS : Float = 100.0;
    
    /** RENDER_TIME_MS is the amount of time that loading is stopped in order to render the progress bar */
    private static inline var RENDER_TIME_MS : Float = 2.0;
    
    private var tasks : Array<Task> = new Array<Task>();
    private var completed_tasks : Array<Task> = new Array<Task>();
    private var progress_bar : GenericProgressBar;
    private var last_render_time : Float;
    
    public function new(_task : String = "Loading...", _progress_bar : GenericProgressBar = null)
    {
        super();
        progress_bar = _progress_bar;
        if (progress_bar == null)
        {
            progress_bar = new GenericProgressBar(_task);
        }
    }
    
    override public function stateLoad() : Void
    {
        super.stateLoad();
        if (parent)
        {
            progress_bar.x = 0.5 * parent.width;
            progress_bar.y = 0.5 * parent.height;
        }
        addChild(progress_bar);
        renderProgressBar();
        performNextTask();
    }
    
    override public function stateUnload() : Void
    {
        super.stateUnload();
        tasks = null;
        completed_tasks = null;
        progress_bar = null;
    }
    
    override public function stateUpdate() : Void
    {
    }
    
    public function performNextTask() : Void
    {
        if (tasks.length == 0)
        {
            renderProgressBar();
            TweenLite.delayedCall(RENDER_TIME_MS / 1000, onTasksComplete);
            return;
        }
        var now : Float = Date.now().time;
        if (now - last_render_time > TIME_BETWEEN_RENDERS_MS)
        {
            renderProgressBar();
            TweenLite.delayedCall(RENDER_TIME_MS / 1000, performNextTask);
            return;
        }
        tasks[0].perform();
        var my_task : Task = tasks.shift();
        completed_tasks.push(my_task);
        performNextTask();
    }
    
    public function renderProgressBar() : Void
    {
        progress_bar.update(completed_tasks.length / (tasks.length + completed_tasks.length));
        last_render_time = Date.now().time;
    }
    
    public function onTasksComplete() : Void
    {  // implemented by children  
        
    }
}

