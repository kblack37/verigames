package state;

import flash.events.TimerEvent;
import flash.utils.Timer;
import starling.display.Quad;
import starling.display.Sprite;
import tasks.Task;

class LoadingState extends GenericState
{
    /** Every TIME_BETWEEN_RENDERS_MS milliseconds, stop loading to render the progress bar */
    private static inline var TIME_BETWEEN_RENDERS_MS : Float = 400.0;
    
    /** RENDER_TIME_MS is the amount of time that loading is stopped in order to render the progress bar */
    private static inline var RENDER_TIME_MS : Float = 2.0;
    
    private var tasksVector : Array<Task> = new Array<Task>();
    private var completed_tasks : Array<Task> = new Array<Task>();
    private var last_render_time : Float = Math.NaN;
    private var rendering : Bool = false;
    private var timer : Timer;
    
    private var m_statusIndicator : Sprite;
    private var m_statusQuad : Quad;
    private var m_statusIndicatorText : TextFieldWrapper;
    
    public function new(_task : String = "Loading...")
    {
        super();
    }
    
    override public function stateLoad() : Void
    {
        super.stateLoad();
        updateStatus();
    }
    
    override public function stateUnload() : Void
    {
        super.stateUnload();
        tasksVector = null;
        completed_tasks = null;
    }
    
    override public function stateUpdate() : Void
    {
        if (rendering)
        {
            return;
        }
        for (i in 0...400)
        {
            performNextTask();
        }
        var now : Float = Date.now().time;
        if (Math.isNaN(last_render_time))
        {
            last_render_time = now;
        }
        if (now - last_render_time > TIME_BETWEEN_RENDERS_MS)
        {
            updateStatus();
            timer = new Timer(RENDER_TIME_MS / 1000);
            timer.addEventListener(TimerEvent.TIMER, renderComplete);
            timer.start();
            rendering = true;
        }
    }
    
    public function renderComplete(evt : TimerEvent) : Void
    {
        rendering = false;
        last_render_time = Date.now().time;
    }
    
    public function performNextTask() : Void
    {
        if (tasksVector == null)
        {
            return;
        }
        rendering = false;
        if (tasksVector.length == 0)
        {
            updateStatus();
            onTasksComplete();
            return;
        }
        tasksVector[0].perform();
        if (tasksVector[0].complete)
        {
            var my_task : Task = tasksVector.shift();
            completed_tasks.push(my_task);
        }
    }
    
    public function updateStatus() : Void
    {  /*
			if (m_statusIndicator == null){
				m_statusIndicator = new Sprite();
				var backQ:Quad = new Quad(Constants.GameWidth / 8.0, 10.0, 0x0);
				m_statusIndicator.addChild(backQ);
				m_statusIndicatorText = TextFactory.getInstance().createDefaultTextField("0%", 60, 14, 10, 0x0);
				m_statusIndicatorText.x = -60;
				m_statusIndicator.addChild(m_statusIndicatorText);
				m_statusQuad = new Quad(1, 4, Constants.WIDE_BLUE);
				m_statusQuad.x = 4;
				m_statusQuad.y = 3;
				m_statusIndicator.addChild(m_statusQuad);
				m_statusIndicator.x = 0.5 * (Constants.GameWidth - m_statusIndicator.width);
				m_statusIndicator.y = 0.8 * Constants.GameHeight;
				addChild(m_statusIndicator);
			}
			*/  
        
    }
    
    public function onTasksComplete() : Void
    {  // implemented by children  
        
    }
}

