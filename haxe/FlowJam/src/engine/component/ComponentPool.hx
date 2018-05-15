package engine.component;
import haxe.ds.Vector;

/**
 * ...
 * @author kristen autumn blackburn
 */
class ComponentPool {
	
	private static inline var POOL_SIZE : Int = 256;

	private var m_pool : Vector<BaseComponent>;
	private var m_nextComponentIndex : Int;
	
	public function new(componentType : String) {
		m_pool = new Vector<BaseComponent>(POOL_SIZE);
		m_nextComponentIndex = 0;
		
		var componentClass : Class<Dynamic> = Type.resolveClass(componentType);
		for (i in 0...POOL_SIZE) {
			m_pool[i] = Type.createInstance(componentClass, [ ]);
		}
	}
	
	public function getComponent() : BaseComponent {
		var component : BaseComponent = null;
		if (m_nextComponentIndex < POOL_SIZE) {
			component = m_pool[m_nextComponentIndex];
			m_nextComponentIndex++;
		}
		return component;
	}
	
	public function putComponent(component : BaseComponent) {
		// Reset the state of the component
		component.initialize();
		
		// We should never call this if nothing has been gotten from the pool
		// but it should be guarded against anyway
		if (m_nextComponentIndex > 0) {
			var componentIndex : Int = -1;
			
			// TODO: binary search this u idiot
			for (i in 0...POOL_SIZE) {
				if (m_pool[i] == component) {
					componentIndex = i;
					break;
				}
			}
			
			var lastAliveComponent : BaseComponent = m_pool[m_nextComponentIndex - 1];
			m_pool[m_nextComponentIndex - 1] = component;
			m_pool[componentIndex] = lastAliveComponent;
			
			m_nextComponentIndex--;
		}
	}
}