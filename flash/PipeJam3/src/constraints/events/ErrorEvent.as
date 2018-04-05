package constraints.events 
{
	import flash.utils.Dictionary;
	import starling.events.Event;
	
	public class ErrorEvent extends Event 
	{
		public static const ERROR_ADDED:String = "error_added";
		public static const ERROR_REMOVED:String = "error_removed";
		
		public var constraintChangeDict:Dictionary;
		
		public function ErrorEvent(type:String, _constraintChangeDict:Dictionary) 
		{
			super(type);
			constraintChangeDict = _constraintChangeDict;
		}
		
	}

}