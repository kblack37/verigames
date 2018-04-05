package
{
	import flash.display.Sprite;
	
	import maxsat.MaxSatManager;
	
	public class Example extends Sprite
	{
		private var m_mgr:MaxSatManager;
		private var m_problems:Array;
			
		public function Example()
		{
			m_mgr = new MaxSatManager();
			m_problems = [];
			
			m_problems.push({
				expect: 0,
				clauses: [
					[10,  -1]
				],
				initvars: null
			});
			
			m_problems.push({
				expect: 0,
				clauses: [
					[10,  1, 2],
					[10, -1, -2],
					[10, 3, 4],
					[10, -3, -4]
					],
				initvars: null
			});
			
			m_problems.push({
				expect: 41225,
				clauses: [
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
					],
				initvars: null
			});
			
			m_problems.push({
				expect: 4, 
				clauses: [
					[1, 1],
					[1, 2],
					[1, -3],
					[1, -4],
					[1, -5],
					[1, 6],
					[1, 7],
					[1, 8],
					[1, 9],
					[1, -10],
					[100, -4, 1],
					[100, -5, 8],
					[100, -1, 4],
					[100, -10, 6],
					[100, -5, 8],
					[100, -5, 3],
					[100, -5, 9],
					[100, -7, 10],
					[100, -1, 3],
					[100, -6, 4],
					[100, -6, 5],
					[100, -10, 3],
					[100, -8, 5],
					[100, -1, 7],
					[100, -7, 8],
					[100, -4, 8],
					[100, -1, 3],
					[100, -2, 9],
					[100, -6, 4],
					[100, -10, 2]
					],
				initvars: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
			});
			
			// these have errors
			
			// duplicate literals
			m_problems.push({
				expect: -1, 
				clauses: [
					[1, 1, 1]
				],
				initvars: null
			});
			
			// unused variable
			m_problems.push({
				expect: -1, 
				clauses: [
					[1, 1, 2],
					[1, -1, -2],
					[1, 5]
				],
				initvars: null
			});
			
			// variable initialization mismatch
			m_problems.push({
				expect: -1, 
				clauses: [
					[1, 1, 2],
				],
				initvars: [0, 0, 0]
			});
			
			next_problem();
		}
		
		private function next_problem():void
		{
			trace();
			trace("=====", "next_problem of", m_problems.length, "=====");
			if (m_problems.length != 0) {
				var unsat_best:int = m_problems[0].expect;
				var clauses:Array = m_problems[0].clauses;
				var initvars:Array = m_problems[0].initvars;
				m_problems.splice(0, 1);
				
				m_mgr.start(clauses, initvars, update_callback, function(err_msg:String):void { done_callback(err_msg, unsat_best); });
			}
		}
		
		private function update_callback(vars:Array, unsat_weight:int):void
		{
			var output:String = "Update: " + unsat_weight + ";";
			
			for (var ii:int = 0; ii < vars.length; ++ ii) {
				output += " ";
				if (!vars[ii]) {
					output += "-";
				}
				output += (ii + 1);
			}
			trace(output);
		}
		
		private function done_callback(err_msg:String, unsat_best:int):void
		{
			if (err_msg) {
				trace("ERROR:", err_msg);
			}
			
			trace("Expect: " + unsat_best);
			next_problem();
		}
	}
}
