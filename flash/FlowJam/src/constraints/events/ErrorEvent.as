package constraints.events 
{
	import constraints.Constraint;
	import starling.events.Event;
	
	public class ErrorEvent extends Event 
	{
		public static const ERROR_ADDED:String = "error_added";
		public static const ERROR_REMOVED:String = "error_removed";
		
		public var constraintError:Constraint;
		
		public function ErrorEvent(type:String, _constraintError:Constraint) 
		{
			super(type);
			constraintError = _constraintError;
		}
		
	}

}