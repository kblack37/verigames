package utils
{
	import flash.utils.Dictionary;
	
	public class PropDictionary
	{
		public static const PROP_NARROW:String = "NARROW";
		public static const PROP_KEYFOR_PREFIX:String = "KEYFOR_";
		
		private var m_props:Dictionary;
		
		public function PropDictionary()
		{
			m_props = new Dictionary();
		}

		public function setProp(prop:String, val:Boolean):void
		{
			if (val) {
				m_props[prop] = true;
			} else {
				delete m_props[prop];
			}
		}
		
		public function setPropCheck(prop:String, val:Boolean):Boolean
		{
			if (val) {
				if (m_props[prop] == undefined) {
					m_props[prop] = true;
					return true;
				} else {
					return false;
				}
			} else {
				if (m_props[prop] != undefined) {
					delete m_props[prop];
					return true;
				} else {
					return false;
				}
			}
		}

		public function hasProp(prop:String):Boolean
		{
			return m_props[prop] != undefined;
		}
		
		public function iterProps():Object
		{
			return m_props;
		}
		
		public function addProps(other:PropDictionary):void
		{
			for (var prop:String in other.m_props) {
				m_props[prop] = true;
			}
		}

		public function matches(other:PropDictionary):Boolean
		{
			var prop:String;
			for (prop in m_props) {
				if (other.m_props[prop] == undefined) {
					return false;
				}
			}
			for (prop in other.m_props) {
				if (m_props[prop] == undefined) {
					return false;
				}
			}
			return true;
		}
		
		public function clone():PropDictionary
		{
			var ret:PropDictionary = new PropDictionary();
			ret.addProps(this);
			return ret;
		}
		
		public static function getProps(props:PropDictionary, prefix:String):Vector.<String>
		{
			var ret:Vector.<String> = new Vector.<String>();
			for (var prop:String in props.iterProps()) {
				if (prop.indexOf(prefix) == 0) {
					ret.push(prop);
				}
			}
			return ret;
		}
	}
}
