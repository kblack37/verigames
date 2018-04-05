package State 
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import Tasks.ParseLevelXMLTask;
	import Tasks.Task;
	import UserInterface.Components.GenericProgressBar;
	
	public class LoadingState extends GenericState
	{
		/** Every TIME_BETWEEN_RENDERS_MS milliseconds, stop loading to render the progress bar */
		private static const TIME_BETWEEN_RENDERS_MS:Number = 100.0;
		
		/** RENDER_TIME_MS is the amount of time that loading is stopped in order to render the progress bar */
		private static const RENDER_TIME_MS:Number = 2.0;
		
		protected var tasks:Vector.<Task> = new Vector.<Task>();
		protected var completed_tasks:Vector.<Task> = new Vector.<Task>();
		protected var progress_bar:GenericProgressBar;
		private var last_render_time:Number;
		
		public function LoadingState(_task:String = "Loading...", _progress_bar:GenericProgressBar = null) 
		{
			super();
			progress_bar = _progress_bar;
			if (progress_bar == null) {
				progress_bar = new GenericProgressBar(_task);
			}
		}
		
		public override function stateLoad():void {
			super.stateLoad();
			if (parent) {
				progress_bar.x = 0.5 * parent.width;
				progress_bar.y = 0.5 * parent.height;
			}
			addChild(progress_bar);
			renderProgressBar();
			performNextTask();
		}
		
		public override function stateUnload():void {
			super.stateUnload();
			tasks = null;
			completed_tasks = null;
			progress_bar = null;
		}
		
		public override function stateUpdate():void {
			
		}
		
		public function performNextTask():void {
			if (tasks.length == 0) {
				renderProgressBar();
				TweenLite.delayedCall(RENDER_TIME_MS / 1000, onTasksComplete);
				return;
			}
			var now:Number = new Date().time;
			if (now - last_render_time > TIME_BETWEEN_RENDERS_MS) {
				renderProgressBar();
				TweenLite.delayedCall(RENDER_TIME_MS / 1000, performNextTask);
				return;
			}
			tasks[0].perform();
			var my_task:Task = tasks.shift();
			completed_tasks.push(my_task);
			performNextTask();
		}
		
		public function renderProgressBar():void {
			progress_bar.update(completed_tasks.length / (tasks.length + completed_tasks.length));
			last_render_time = new Date().time;
		}
		
		public function onTasksComplete():void {
			// implemented by children
		}
		
	}

}