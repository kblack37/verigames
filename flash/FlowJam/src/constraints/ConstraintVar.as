package constraints 
{
	import constraints.events.VarChangeEvent;
	import graph.PropDictionary;
	import starling.events.EventDispatcher;
	
	public class ConstraintVar extends EventDispatcher
	{
		
		public var id:String;
		public var formattedId:String;
		public var defaultVal:ConstraintValue;
		public var constant:Boolean;
		public var scoringConfig:ConstraintScoringConfig;
		public var possibleKeyfors:Vector.<String>;
		public var keyforVals:Vector.<String>;
		
		private var m_props:PropDictionary;
		private var m_value:ConstraintValue;
		public var lhsConstraints:Vector.<SubtypeConstraint> = new Vector.<SubtypeConstraint>(); // constraints where this var appears on the left hand side (outgoing edge)
		public var rhsConstraints:Vector.<SubtypeConstraint> = new Vector.<SubtypeConstraint>(); // constraints where this var appears on the right hand side (incoming edge)
		
		public function ConstraintVar(_id:String, _val:ConstraintValue, _defaultVal:ConstraintValue, _constant:Boolean, _scoringConfig:ConstraintScoringConfig, _possibleKeyfors:Vector.<String> = null, _keyforVals:Vector.<String> = null)
		{
			id = _id;
			m_value = _val;
			defaultVal = _defaultVal;
			constant = _constant;
			scoringConfig = _scoringConfig;
			possibleKeyfors = (_possibleKeyfors == null) ? (new Vector.<String>()) : _possibleKeyfors;
			keyforVals = (_keyforVals == null) ? (new Vector.<String>()) : _keyforVals;
			m_props = new PropDictionary();
			if (m_value.intVal == 0) m_props.setProp(PropDictionary.PROP_NARROW, true);
			for (var i:int = 0; i < keyforVals.length; i++) m_props.setProp(PropDictionary.PROP_KEYFOR_PREFIX + keyforVals[i], true);
			var suffixParts:Array = id.split("__");
			var prefixId:String = suffixParts[0];
			var idParts:Array = prefixId.split("_");
			if (idParts.length != 2) trace("Warning! Expected variables of the form var_2, type_0__var_2, found:" + id);
			formattedId = idParts[0] + ":" + idParts[1];
			for (var c:int = 2; c < idParts.length; c++) formattedId += "_" + idParts[c]; // add other parts of id, if any
		}
		
		public function getValue():ConstraintValue { return m_value; }
		public function getProps():PropDictionary { return m_props; }
		
		public function setProp(prop:String, value:Boolean):void
		{
			if (prop == PropDictionary.PROP_NARROW) {
				m_value = ConstraintValue.fromStr(value ? ConstraintValue.TYPE_0 : ConstraintValue.TYPE_1);
			} else if (prop.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) == 0) {
				var keyfor:String = prop.substr(prop.indexOf(PropDictionary.PROP_KEYFOR_PREFIX) + PropDictionary.PROP_KEYFOR_PREFIX.length, prop.length - PropDictionary.PROP_KEYFOR_PREFIX.length);
				if (value) {
					if (possibleKeyfors.indexOf(keyfor) == -1) throw new Error("Error! Attempting to add keyfor: " + keyfor + " when not in possible keyfors list for varId:" + id);
					if (keyforVals.indexOf(keyfor) == -1) keyforVals.push(keyfor);
				} else {
					if (keyforVals.indexOf(keyfor) > -1) keyforVals.splice(keyforVals.indexOf(keyfor), 1);
				}
			}
			if (m_props.hasProp(prop) != value) {
				m_props.setProp(prop, value);
				dispatchEvent(new VarChangeEvent(VarChangeEvent.VAR_CHANGED_IN_GRAPH, this, prop, value));
			}
		}
		
		public function toString():String
		{
			return id + "(=" + m_value.verboseStrVal + ")";
		}
	}

}