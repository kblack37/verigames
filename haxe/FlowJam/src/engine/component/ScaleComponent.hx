package engine.component;

/**
 * ...
 * @author kristen autumn blackburn
 * 
 * Component of the TransformComponent that defines an entity's scale
 */
class ScaleComponent extends BaseComponent {
	
	public static var TYPE_ID : String = Type.getClassName(ScaleComponent);
	
	public var scaleX(get, never) : Float;
	public var scaleY(get, never) : Float;
	
	/**
	 * Defined as |new scale - old scale| / scaleTime
	 */
	public var scaleVelocity(get, never) : Float;
	
	/**
	 * Whether the entity is currently scaling
	 */
	public var isScaling(get, set) : Bool;
	
	private var m_scaleX : Float;
	private var m_scaleY : Float;
	private var m_scaleVelocity : Float;
	
	private var m_isScaling : Bool;
	
	private var m_scaleQueue : Array<Dynamic>;

	@:allow(TransformComponent)
	private function new() {
		super(TYPE_ID);
	}
	
	override public function initialize() {
		super.initialize();
		
		m_scaleX = 1;
		m_scaleY = 1;
		m_scaleVelocity = 0;
		m_isScaling = false;
		m_scaleQueue = new Array<Dynamic>();
	}
	
	override public function serialize() : Xml {
		return null;
	}
	
	override public function deserialize(xml : Xml) {
		
	}
	
	/**
	 * Adds a new scale to the queue
	 * @param	data
	 * 				scaleX: the new x scale of the entity
	 * 				scaleY: the new y scale of the entity
	 * 				scaleVelocity: the speed the scale occurs; set to -1 for an instant scale
	 */
	public function queueScale(data : Dynamic) {
		m_scaleQueue.push(data);
	}
	
	/**
	 * @return	True if this has a scale queued; false otherwise
	 */
	public function hasScaleQueued() : Bool {
		return m_scaleQueue.length != 0;
	}
	
	/**
	 * Changes this component's data to the next queued scale
	 */
	public function updateToQueuedScale() {
		var scaleData : Dynamic = m_scaleQueue.shift();
		if (Reflect.hasField(scaleData, "scaleX")) {
			m_scaleX = scaleData.scaleX;
		}
		if (Reflect.hasField(scaleData, "scaleY")) {
			m_scaleY = scaleData.scaleY;
		}
		if (Reflect.hasField(scaleData, "scaleVelocity")) {
			m_scaleVelocity = scaleData.scaleVelocity;
		} else {
			m_scaleVelocity = -1;
		}
	}
	
	function get_scaleX() : Float {
		return m_scaleX;
	}
	
	function get_scaleY() : Float {
		return m_scaleY;
	}
	
	function get_scaleVelocity() : Float {
		return m_scaleVelocity;
	}
	
	function get_isScaling() : Bool {
		return m_isScaling;
	}
	
	function set_isScaling(value : Bool) : Bool {
		return m_isScaling = value;
	}
}