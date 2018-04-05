package maxsat
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;

	public class MaxSatManager
	{
		[Embed(source="../../worker/maxsat_worker.swf", mimeType="application/octet-stream")] private static var MaxSatWorker:Class;

		private static var o_workerBytes:ByteArray;
		
		private var m_worker:Worker;
		private var m_workerToMain:MessageChannel;
		
		private var m_algorithm:int;
		private var m_clauses:Array;
		private var m_initvars:Array;
		private var m_updateCallback:Function;
		private var m_doneCallback:Function;
		
		public function MaxSatManager()
		{
			if (!o_workerBytes) {
				o_workerBytes = new MaxSatWorker as ByteArray;
			}
		}
		
		public function start(algorithm:int, clauses:Array, initvars:Array, updateCallback:Function, doneCallback:Function):void
		{
			stop();
			m_algorithm = algorithm;
			m_clauses = clauses;
			m_initvars = initvars;
			m_updateCallback = updateCallback;
			m_doneCallback = doneCallback;
			
			m_worker = WorkerDomain.current.createWorker(o_workerBytes);
			
			m_workerToMain = m_worker.createMessageChannel(Worker.current);
			m_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);

			m_worker.setSharedProperty("workerToMain", m_workerToMain);
			m_worker.setSharedProperty("algorithm", m_algorithm);
			m_worker.setSharedProperty("clauses", m_clauses);
			m_worker.setSharedProperty("initvars", m_initvars);

			m_worker.start();
		}
		
		public function stop():void
		{
			m_clauses = null;
			m_initvars = null;
			m_updateCallback = null;
			m_doneCallback = null;

			if (m_worker) {
				m_worker.terminate();
			}
			m_worker = null;

			if (m_workerToMain) {
				m_workerToMain.removeEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
			}
			m_workerToMain = null;
		}
		
		private function onWorkerToMain(ev:Event):void
		{
			var obj:Object = m_workerToMain.receive();
			if (obj is Boolean) {
				if (!obj) {
				} else {
					doStop(null);
				}
			} else if (obj is String) {
				doStop(obj as String);
			} else {
				m_updateCallback(obj.vars, obj.unsat_weight);
			}
		}

		private function doStop(errMsg:String):void
		{
			var tmpDoneCallback:Function = m_doneCallback;
			stop();
			tmpDoneCallback(errMsg);
		}
	}
}
