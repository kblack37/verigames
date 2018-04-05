package NetworkGraph 
{
	import Events.StampChangeEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import NetworkGraph.StampRef;
	
	public class EdgeSetRef extends EventDispatcher
	{
		public var stamp_dictionary:Dictionary = new Dictionary();
		private var edge_set_dictionary:Dictionary;
		public var id:String;
		public var edge_ids:Vector.<String> = new Vector.<String>();
		
		public function EdgeSetRef(_id:String, _edge_set_dictionary:Dictionary) 
		{
			id = _id;
			edge_set_dictionary = _edge_set_dictionary;
		}
		
		public function addStamp(_edge_set_id:String, _active:Boolean):void {
			if (stamp_dictionary[_edge_set_id] == null) {
				stamp_dictionary[_edge_set_id] = new StampRef(_edge_set_id, _active, this);
			} else if ((stamp_dictionary[_edge_set_id] as StampRef).active != _active) {
				(stamp_dictionary[_edge_set_id] as StampRef).active = _active;
			}
		}
		
		public function removeStamp(_edge_set_id:String):void {
			if (stamp_dictionary[_edge_set_id] != null) {
				delete stamp_dictionary[_edge_set_id];
			}
		}
		
		public function activateStamp(_edge_set_id:String):void {
			if (stamp_dictionary[_edge_set_id] != null) {
				(stamp_dictionary[_edge_set_id] as StampRef).active = true;
			}
		}
		
		public function deactivateStamp(_edge_set_id:String):void {
			if (stamp_dictionary[_edge_set_id] != null) {
				(stamp_dictionary[_edge_set_id] as StampRef).active = false;
			}
		}
		
		public function hasActiveStampOfEdgeSetId(_edge_set_id:String):Boolean {
			if (stamp_dictionary[_edge_set_id] == null) {
				return false;
			}
			return (stamp_dictionary[_edge_set_id] as StampRef).active;
		}
		
		public function get num_stamps():uint {
			var i:int = 0;
			for (var edge_set_id:String in stamp_dictionary) {
				i++;
			}
			return i;
		}
		
		public function get num_active_stamps():uint {
			var i:int = 0;
			for (var edge_set_id:String in stamp_dictionary) {
				if ((stamp_dictionary[edge_set_id] as StampRef).active) {
					i++;
				}
			}
			return i;
		}
		
		public function getStampEdgeSetIdAt(index:uint):String {
			var i:int = 0;
			for (var edge_set_id:String in stamp_dictionary) {
				if (i == index) {
					return (stamp_dictionary[edge_set_id] as StampRef).edge_set_id;
				}
				i++;
			}
			return "";
		}
		
		public function getActiveStampEdgeSetIdAt(index:uint):String {
			var i:int = 0;
			for (var edge_set_id:String in stamp_dictionary) {
				if ((stamp_dictionary[edge_set_id] as StampRef).active) {
					if (i == index) {
						return (stamp_dictionary[edge_set_id] as StampRef).edge_set_id;
					}
					i++;
				}
			}
			return "";
		}
		
		public function getActiveStampAt(index:uint):StampRef {
			var i:int = 0;
			for (var edge_set_id:String in stamp_dictionary) {
				if ((stamp_dictionary[edge_set_id] as StampRef).active) {
					if (i == index) {
						return (stamp_dictionary[edge_set_id] as StampRef);
					}
					i++;
				}
			}
			return null;
		}
		
		public function onActivationChange(_stampRef:StampRef):void {
			var ev:StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_ACTIVATION,_stampRef);
			dispatchEvent(ev);
		}
		
	}

	
	
}