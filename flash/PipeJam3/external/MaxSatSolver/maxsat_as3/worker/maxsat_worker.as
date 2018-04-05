package
{

import flash.display.Sprite;
import flash.events.Event;
import flash.system.Worker;
import flash.system.MessageChannel;

public class maxsat_worker extends Sprite
{
	private static var o_workerToMain:MessageChannel;

	private static var o_algorithm:int;
	private static var o_clauses:Array;
	private static var o_initvars:Array;
	 
	public function maxsat_worker()
	{
		o_workerToMain = Worker.current.getSharedProperty("workerToMain");
		o_algorithm = Worker.current.getSharedProperty("algorithm");
		o_clauses = Worker.current.getSharedProperty("clauses");
		o_initvars = Worker.current.getSharedProperty("initvars");

		if (o_workerToMain && o_clauses) {
		   run();
		}
	}
 
	private static function run():void
	{
		o_workerToMain.send(false);

		try {
			maxsat.run(o_algorithm, o_clauses, o_initvars, 0, callback);
		} catch (err:Error) {
			o_workerToMain.send(err.message);
		}

		o_workerToMain.send(true);
	}

	private static function callback(vars:Array, unsat_weight:int):void
	{
		o_workerToMain.send({ vars:vars, unsat_weight:unsat_weight });
	}

}

}
