package system
{	
	import maxsat.MaxSatManager;
	
	public class MaxSatSolver
	{
		static private var m_mgr:MaxSatManager = new MaxSatManager();
		static private var unsat_best:int = -1;
		
		static public var SOLVER_STARTED:String = "solver_started";
		static public var SOLVER_STOPPED:String = "solver_stopped";
		static public var SOLVER_UPDATED:String = "solver_updated";
		
		public static function test():void
		{
			run_solver(1, [
				[10,  1, 2],
				[10, -1, -2],
				[10, 3, 4],
				[10, -3, -4]
			], [],update_callback, done_callback);
			
			run_solver(1, [
				[76222, -1, 2],
				[76222, 1, -2],
				[41225, 2, 3],
				[41225, -2, -3],
				[50104, -3, 1],
				[50104, 3, -1],
				[125307, 4, 5],
				[125307, -4, -5],
				[51429, 5, 6],
				[51429, -5, -6]
			], [],update_callback, done_callback);
			
			run_solver(1, [
				[20, -1, 10, 3, 4, -5],
				[30, -2, 3, 1],
				[50, -1, 9],
				[60, -8, 3],
				[10, -6, 8],
				[10, -1, 10, -7, -8, -9],
				[10, -6, 10],
				[10, -5, 1, 2],
				[10, -6, 9, 3, 4, -1],
				[10, -3, 5]
			], [],update_callback, done_callback);
		}
		
		public static function run_solver(algorithm:int, clause_arrays:Array, initvars_Array:Array, updatecallback:Function, donecallback:Function):void
		{
			try
			{
				m_mgr.start(algorithm, clause_arrays, initvars_Array, updatecallback, donecallback);
			} catch (e:Error) {
			trace(e.message);
			}
		}
		
		public static function stop_solver():void
		{
			m_mgr.stop();
		}
		
		private static function update_callback(vars:Array, unsat_weight:int):int
		{
			trace("Result:");
			for (var ii:int = 0; ii < vars.length; ++ ii) {
				trace(" ", ii + 1, "=", vars[ii]);
			}
			return 1;
		}
		
		private static function done_callback(err_msg:String, unsat_best:int):void
		{ 
			if (err_msg) {
				trace("ERROR:", err_msg);
			}
			
			trace("Expect: " + unsat_best);
		}
	}
}