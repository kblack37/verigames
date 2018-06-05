package engine.component;
import data.ISerializable;

/**
 * Base class for all components
 * 
 * A component is attached to an entity and defines what systems
 * the entity interacts and, in turn, that entity's behavior
 * 
 * @author kristen autumn blackburn
 */
class BaseComponent implements ISerializable {
	
	/**
	 * The id of the entity this component is attached to
	 */
	public var id(get, set) : String;
	
	/**
	 * The type of the component
	 */
	public var typeId(get, never) : String;
	
	private var m_entityId : String;
	private var m_typeId : String;

	private function new(typeId : String) {
		m_typeId = typeId;
		
		initialize();
	}
	
	/**
	 * Resets the component to a base state. When overriding, be
	 * sure to call super()
	 */
	public function initialize() {
		m_entityId = null;
	}
	
	public function serialize() : Dynamic {
		return null;
	}
	
	public function deserialize(jsonObject : Dynamic) {
		
	}
	
	function get_id() : String {
		return m_entityId;
	}
	
	function set_id(val : String) : String {
		// A component should be assigned to only one entity until it is recycled
		if (m_entityId == null) {
			m_entityId = val;
		}
		
		return val;
	}
	
	function get_typeId() : String {
		return m_typeId;
	}
}