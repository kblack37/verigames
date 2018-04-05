package {

import maxsat_swig;
import maxsat_package.CModule;

public class maxsat
{

	public static function run(algorithm:int, clauses:Array, initvars:Array, intermediate_callbacks:int, callback:Function):void
	{
		// this will be a pointer to allocated space
		var clause_ptr:int = 0;
		var initvar_ptr:int = 0;
		
		try {
			// compute space needed
			var clause_size:int = 0;
			for each (var clause:Array in clauses) {
				if (clause.length == 0) {
					throw new Error("Clause missing weight and literals.");
				}
				if (clause.length == 1) {
					throw new Error("Clause missing literals.");
				}
				clause_size = clause_size + clause.length + 1;
			}
			
			// allocate space
			clause_ptr = CModule.malloc(4 * clause_size);
			
			// put literals in allocated space
			var clause_fill_ptr:int = clause_ptr;
			var max_var:int = 0;
			for each (clause in clauses) {
				var weight:int = clause[0];
			
				// check that weight is not 0
				if (weight == 0) {
					throw new Error("Weight is 0.");
				}

				CModule.write32(clause_fill_ptr, weight);
				clause_fill_ptr += 4;

				for (var ii:int = 1; ii < clause.length; ++ ii) {
					var literal:int = clause[ii];
					max_var = Math.max(max_var, Math.abs(literal));

					// check that no literals are 0
					if (literal == 0) {
						throw new Error("Literal is 0.");
					}

					// check for no duplicate literals
					for (var jj:int = 1; jj < ii; ++ jj) {
						if (literal == clause[jj]) {
							throw new Error("Literal is duplicated.");
						}
					}

					CModule.write32(clause_fill_ptr, literal);
					clause_fill_ptr += 4;
				}

				CModule.write32(clause_fill_ptr, 0);
				clause_fill_ptr += 4;
			}

			// check all variables are used
			var var_used:Array = new Array(max_var);
			for each (clause in clauses) {
				for (var ii:int = 1; ii < clause.length; ++ ii) {
					var_used[Math.abs(clause[ii]) - 1] = true;
				}
			}
			for (var ii:int = 0; ii < max_var; ++ ii) {
				if (!var_used[ii]) {
					throw new Error("Variable is unused.");
				}
			}
			
			var initvar_size:int = 0;
			if (initvars) {
				if (initvars.length != max_var) {
					throw new Error("Initialization variable length mismatch.");
				}

				initvar_size = initvars.length;
				initvar_ptr = CModule.malloc(4 * initvar_size);
				for (var ii:int = 0; ii < initvars.length; ++ ii) {
					CModule.write32(initvar_ptr + 4 * ii, initvars[ii]);
				}
			}

			// create a callback wrapper to unpack data
			var callback_wrapper:Function = function(out_ptr:int, out_count:int, unsat_weight:int):int {
				// allocate array
				var vars:Array = [];
				
				// copy data into array
				for (var ii:int = 0; ii < out_count; ++ ii) {
					vars.push(CModule.read32(out_ptr + ii * 4));
				}
				
				// call callback
				return callback(vars, unsat_weight);
			};
			
			// call the solver
			maxsat_swig.run(algorithm, clause_ptr, clauses.length, initvar_ptr, initvar_size, intermediate_callbacks, callback_wrapper);
		} finally {
			// free the space if it was allocated earlier
			if (clause_ptr != 0) {
				CModule.free(clause_ptr);
			}
			if (initvar_ptr != 0) {
				CModule.free(initvar_ptr);
			}
		}
	}

}

}
