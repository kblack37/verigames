package system;

import flash.errors.Error;
import haxe.Constraints.Function;
import maxsat.MaxSatManager;

class MaxSatSolver
{
    private static var m_mgr : MaxSatManager = new MaxSatManager();
    private static var unsat_best : Int = -1;
    
    public static var SOLVER_STARTED : String = "solver_started";
    public static var SOLVER_STOPPED : String = "solver_stopped";
    public static var SOLVER_UPDATED : String = "solver_updated";
    
    public static function test() : Void
    {
        run_solver(1, [
                [10, 1, 2], 
                [10, -1, -2], 
                [10, 3, 4], 
                [10, -3, -4]
        ], [], update_callback, done_callback);
        
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
        ], [], update_callback, done_callback);
        
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
        ], [], update_callback, done_callback);
    }
    
    public static function run_solver(algorithm : Int, clause_arrays : Array<Dynamic>, initvars_Array : Array<Dynamic>, updatecallback : Function, donecallback : Function) : Void
    {
        try
        {
            m_mgr.start(algorithm, clause_arrays, initvars_Array, updatecallback, donecallback);
        }
        catch (e : Error)
        {
            trace(e.message);
        }
    }
    
    public static function stop_solver() : Void
    {
        m_mgr.stop();
    }
    
    private static function update_callback(vars : Array<Dynamic>, unsat_weight : Int) : Int
    {
        trace("Result:");
        for (ii in 0...vars.length)
        {
            trace(" ", ii + 1, "=", vars[ii]);
        }
        return 1;
    }
    
    private static function done_callback(err_msg : String, unsat_best : Int) : Void
    {
        if (err_msg != null)
        {
            trace("ERROR:", err_msg);
        }
        
        trace("Expect: " + unsat_best);
    }

    public function new()
    {
    }
}
