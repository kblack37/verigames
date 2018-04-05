package events 
{
	import scenes.game.display.GameComponent;
	import starling.events.Event;
	
	public class GroupSelectionEvent extends GameComponentEvent 
	{
		public static var GROUP_SELECTED:String = "group_selected";
		public static var GROUP_UNSELECTED:String = "group_unselected";
		
		public var selection:Vector.<GameComponent>;
		
		public function GroupSelectionEvent(_type:String, _component:GameComponent, _selection:Vector.<GameComponent> = null) 
		{
			super(_type, _component);
			if (_selection == null) {
				_selection = new Vector.<GameComponent>();
			}
			selection = _selection;
		}
		
	}

}