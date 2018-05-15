package engine.component;
import engine.component.BaseComponent;

/**
 * ...
 * @author kristen autumn blackburn
 * 
 * This class is responsible for managing all component creation, assignment,
 * and retrieval
 */
class ComponentManager implements IComponentManager {
	
	private var m_typeToComponentsMap : Map<String, Array<BaseComponent>>;
	
	private var m_typeToIdComponentMap : Map<String, Map<String, BaseComponent>>;
	
	private var m_typeToComponentPoolMap : Map<String, ComponentPool>;
	
	private var m_typeInitedMap : Map<String, Bool>;

	public function new() {
		m_typeToComponentsMap = new Map<String, Array<BaseComponent>>();
		m_typeToIdComponentMap = new Map<String, Map<String, BaseComponent>>();
		m_typeToComponentPoolMap = new Map<String, ComponentPool>();
		m_typeInitedMap = new Map<String, Bool>();
	}
	
	/**
	 * Adds a new component to an entity and returns it
	 * @param	entityId	The entity to add the component to
	 * @param	componentType	The type of component to add
	 * @return	The component created
	 */
	public function addComponentToEntity(entityId : String, componentType : String) : BaseComponent {
		if (!m_typeInitedMap.exists(componentType)) {
			initComponentType(componentType);
		}
		
		var idToComponentMap : Map<String, BaseComponent> = m_typeToIdComponentMap.get(componentType);
		
		// Get rid of the old component if it exists
		if (idToComponentMap.exists(entityId)) {
			removeComponentFromEntity(entityId, componentType);
			trace("WARNING: entity with id " + entityId + " replaced component of type " + componentType);
		}
		
		// Get a new component from the pool
		var component : BaseComponent = m_typeToComponentPoolMap.get(componentType).getComponent();
		if (component == null) {
			trace("WARNING: out of pool space for new component of type " + componentType + " for entity with id " + entityId);
		} else {
			component.id = entityId;
			
			idToComponentMap.set(entityId, component);
			m_typeToComponentsMap.get(componentType).push(component);
		}
		
		return component;
	}
	
	/**
	 * Removes a component from an entity
	 * @param	entityId	The entity to remove the component from
	 * @param	componentType	The type of the component to remove
	 * @return	True if it succeeds; false otherwise
	 */
	public function removeComponentFromEntity(entityId : String, componentType : String) : Bool {
		var success : Bool = false;
		
		if (m_typeInitedMap.exists(componentType)) {
			var idToComponentMap : Map<String, BaseComponent> = m_typeToIdComponentMap.get(componentType);
			
			if (idToComponentMap.exists(entityId)) {
				var component : BaseComponent = idToComponentMap.get(entityId);
				idToComponentMap.remove(entityId);
				
				m_typeToComponentsMap.get(componentType).remove(component);
				
				m_typeToComponentPoolMap.get(componentType).putComponent(component);
				
				success = true;
			}
		}
		
		return success;
	}
	
	/**
	 * @param	entityId	The entity in question
	 * @param	componentType	The component type in question
	 * @return	True if the given entity has a component of that type, false otherwise
	 */
	public function entityHasComponent(entityId : String, componentType : String) : Bool {
		if (!m_typeInitedMap.exists(componentType)) {
			initComponentType(componentType);
		}
		
		return m_typeToIdComponentMap.get(componentType).exists(entityId);
	}
	
	/**
	 * Returns the component of that type attached to the given entity
	 * @param	entityId	The entity in question
	 * @param	componentType	The component type in question
	 * @return	The component, if it exists; null otherwise
	 */
	public function getComponentByIdAndType(entityId : String, componentType : String) : BaseComponent {
		if (!m_typeInitedMap.exists(componentType)) {
			initComponentType(componentType);
		}
		
		return m_typeToIdComponentMap.get(componentType).get(entityId);
	}
	
	/**
	 * Returns all components of the given type across all entities
	 * @param	componentType	The component type in question
	 * @return	An array containing all the components of the given type
	 */
	public function getComponentsOfType(componentType : String) : Array<BaseComponent> {
		if (!m_typeInitedMap.exists(componentType)) {
			initComponentType(componentType);
		}
		
		return m_typeToComponentsMap.get(componentType);
	}
	
	/**
	 * Removes all entities and components from this component manager
	 */
	public function clear() {
		m_typeToComponentsMap = new Map<String, Array<BaseComponent>>();
		m_typeToIdComponentMap = new Map<String, Map<String, BaseComponent>>();
		m_typeInitedMap = new Map<String, Bool>();
	}
	
	private function initComponentType(componentType : String) {
		m_typeToComponentsMap.set(componentType, new Array<BaseComponent>());
		m_typeToIdComponentMap.set(componentType, new Map<String, BaseComponent>());
		m_typeToComponentPoolMap.set(componentType, new ComponentPool(componentType));
		m_typeInitedMap.set(componentType, true);
	}
}