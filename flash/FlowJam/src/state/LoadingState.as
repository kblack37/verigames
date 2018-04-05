package state 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import tasks.Task;
	
	public class LoadingState extends GenericState
	{
		/** Every TIME_BETWEEN_RENDERS_MS milliseconds, stop loading to render the progress bar */
		private static const TIME_BETWEEN_RENDERS_MS:Number = 100.0;
		
		/** RENDER_TIME_MS is the amount of time that loading is stopped in order to render the progress bar */
		private static const RENDER_TIME_MS:Number = 2.0;
		
		protected var tasksVector:Vector.<Task> = new Vector.<Task>();
		protected var completed_tasks:Vector.<Task> = new Vector.<Task>();
		private var last_render_time:Number;
		protected var timer:Timer;
		
		public function LoadingState(_task:String = "Loading...") 
		{
			super();
			
		}
		
		public override function stateLoad():void {
			super.stateLoad();
			updateStatus();
			performNextTask();
		}
		
		public override function stateUnload():void {
			super.stateUnload();
			tasksVector = null;
			completed_tasks = null;
		}
		
		public override function stateUpdate():void {
			
		}
		
		public function performNextTask():void {
			if (this.tasksVector.length == 0) {
				updateStatus();
				onTasksComplete();
				return;
			}
			var now:Number = new Date().time;
			if (now - last_render_time > TIME_BETWEEN_RENDERS_MS) {
				updateStatus();
				timer = new Timer(RENDER_TIME_MS / 1000);
				timer.addEventListener(TimerEvent.TIMER, performNextTask);
				timer.start();
				return;
			}
			tasksVector[0].perform();
			var my_task:Task = tasksVector.shift();
			completed_tasks.push(my_task);
			performNextTask();
		}
		
		public function updateStatus():void {
		}
		
		public function onTasksComplete():void {
			// implemented by children
		}
		
	}

}