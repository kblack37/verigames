package graph 
{
	import flash.utils.Dictionary;
	import graph.Edge;
	import graph.Port;
	import graph.PropDictionary;
	
	public class ConflictDictionary
	{
		private var portPropertyConflicts:Dictionary = new Dictionary();
		private var edgePropertyConflicts:Dictionary = new Dictionary();
		
		private var ports:Dictionary = new Dictionary();
		private var edges:Dictionary = new Dictionary();
		
		public function ConflictDictionary()
		{
		}
		
		public function iterPorts():Object
		{
			return ports;
		}
		
		public function iterEdges():Object
		{
			return edges;
		}
		
		public function addPortConflict(port:Port, prop:String, test:Boolean = false):void
		{
			//trace("added port conflict: " + port + " prop:" + prop + " test:" + test);
			if (test) return;
			
			var key:String = port.toString();
			ports[key] = port;
			if (!portPropertyConflicts.hasOwnProperty(key)) portPropertyConflicts[key] = new PropDictionary();
			(portPropertyConflicts[key] as PropDictionary).setProp(prop, true);
		}
		
		public function addEdgeConflict(edge:Edge, prop:String, test:Boolean = false):void
		{
			//trace("added edge conflict: " + edge.edge_id + " prop:" + prop + " test:" + test);
			if (test) return;
			
			var key:String = edge.edge_id;
			edges[key] = edge;
			if (!edgePropertyConflicts.hasOwnProperty(key)) edgePropertyConflicts[key] = new PropDictionary();
			(edgePropertyConflicts[key] as PropDictionary).setProp(prop, true);
		}
		
		public function getPort(portString:String):Port
		{
			if (ports.hasOwnProperty(portString)) {
				return ports[portString] as Port;
			}
			return null;
		}
		
		public function getEdge(edgeId:String):Edge
		{
			if (edges.hasOwnProperty(edgeId)) {
				return edges[edgeId] as Edge;
			}
			return null;
		}
		
		public function getPortConflicts(portString:String):PropDictionary
		{
			if (portPropertyConflicts.hasOwnProperty(portString)) {
				return portPropertyConflicts[portString] as PropDictionary;
			}
			return null;
		}
		
		public function getEdgeConflicts(edgeId:String):PropDictionary
		{
			if (edgePropertyConflicts.hasOwnProperty(edgeId)) {
				return edgePropertyConflicts[edgeId] as PropDictionary;
			}
			return null;
		}
		
		public function clone():ConflictDictionary
		{
			var prop:String;
			var newdict:ConflictDictionary = new ConflictDictionary();
			for (var portk:String in portPropertyConflicts) {
				var portConfProps:PropDictionary = getPortConflicts(portk);
				for (prop in portConfProps.iterProps()) {
					newdict.addPortConflict(getPort(portk), prop);
				}
			}
			for (var edgek:String in edgePropertyConflicts) {
				var edgeConfProps:PropDictionary = getEdgeConflicts(edgek);
				for (prop in edgeConfProps.iterProps()) {
					newdict.addEdgeConflict(getEdge(edgek), prop);
				}
			}
			return newdict;
		}
	}
}