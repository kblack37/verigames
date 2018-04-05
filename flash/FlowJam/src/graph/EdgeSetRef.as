package graph 
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import events.StampChangeEvent;
	
	import graph.StampRef;
	
	public class EdgeSetRef extends EventDispatcher
	{
		public var id:String;
		// Level name to Vector.<Edge> containing edges for that level
		private var m_levelNameToEdges:Dictionary = new Dictionary();
		public var allEdges:Vector.<Edge> = new Vector.<Edge>();
		private var m_props:PropDictionary = new PropDictionary();
		// Possible stamps that the edge set can have, can only activate possible props
		private var m_possibleProps:PropDictionary;
		public var editable:Boolean = false;
		public var propsInitialized:Boolean = false;
		
		public function EdgeSetRef(_id:String) 
		{
			id = _id;
			m_possibleProps = new PropDictionary();
			// TODO: if edge set not editable, set to false
			m_possibleProps.setProp(PropDictionary.PROP_NARROW, true);
		}
		
		public function addEdge(edge:Edge, levelName:String):void
		{
			allEdges.push(edge);
			if (!m_levelNameToEdges.hasOwnProperty(levelName)) {
				m_levelNameToEdges[levelName] = new Vector.<Edge>();
			}
			getLevelEdges(levelName).push(edge);
		}
		
		public function getLevelEdges(levelName:String):Vector.<Edge>
		{
			var edges:Vector.<Edge> =  m_levelNameToEdges[levelName];
			if(edges != null)
				return edges;
			
			//assume the dictionary only has one element, if name can't be found
			for(var key:String in m_levelNameToEdges) {
				return m_levelNameToEdges[key] as Vector.<Edge>;
			}
			return null;
		}
		
		public function addStamp(_edge_set_id:String, _active:Boolean):void {
			m_possibleProps.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, true);
			m_props.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, _active);
		}
		
		public function removeStamp(_edge_set_id:String):void {
			m_possibleProps.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, false);
			m_props.setProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, false);
		}
		
		public function activateStamp(_edge_set_id:String):void {
			if (!canSetProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id)) return;
			var change:Boolean = m_props.setPropCheck(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, true);
			if (change) onActivationChange();
		}
		
		public function deactivateStamp(_edge_set_id:String):void {
			if (!canSetProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id)) return;
			var change:Boolean = m_props.setPropCheck(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id, false);
			if (change) onActivationChange();
		}
		
		public function hasActiveStampOfEdgeSetId(_edge_set_id:String):Boolean {
			return m_props.hasProp(PropDictionary.PROP_KEYFOR_PREFIX + _edge_set_id);
		}
		
		public function onActivationChange():void {
			var ev:StampChangeEvent = new StampChangeEvent(StampChangeEvent.STAMP_ACTIVATION, this);
			dispatchEvent(ev);
		}
		
		public function canSetProp(prop:String):Boolean
		{
			return m_possibleProps.hasProp(prop);
		}
		
		public function setProp(prop:String, val:Boolean):void
		{
			if (!canSetProp(prop)) return;
			var change:Boolean = m_props.setPropCheck(prop, val);
			if (change && (prop.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) == 0)) onActivationChange();
		}
		
		// Testbed
		public function getProps():PropDictionary
		{
			return m_props;
		}
	}

	
	
}