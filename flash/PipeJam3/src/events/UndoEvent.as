package events 
{
	import scenes.BaseComponent;
	import starling.events.Event;
	
	public class UndoEvent extends Event 
	{
		public static var UNDO_EVENT:String = "undo_event";
		
		public var component:BaseComponent;
		public var eventsToUndo:Vector.<Event>;
		
		public var levelEvent:Boolean = false;
		public var addToLast:Boolean = false;
		public var addToSimilar:Boolean = false;
		
		public function UndoEvent(_eventToUndo:Event, _component:BaseComponent)
		{
			super(UNDO_EVENT, true);
			component = _component;
			eventsToUndo = new Vector.<Event>();
			eventsToUndo.push(_eventToUndo);
		}
	}
}