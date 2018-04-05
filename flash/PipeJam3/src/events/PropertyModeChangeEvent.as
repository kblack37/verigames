package events 
{
	import starling.events.Event;
	
	public class PropertyModeChangeEvent extends Event 
	{
		public static const PROPERTY_MODE_CHANGE:String = "PROPERTY_MODE_CHANGE";
		
		public var prop:String;
		public function PropertyModeChangeEvent(_type:String, _property:String) 
		{
			super(_type, true);
			prop = _property;
		}
		
	}

}