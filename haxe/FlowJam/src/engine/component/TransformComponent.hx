package engine.component;

/**
 * ...
 * @author kristen autumn blackburn
 * 
 * A TransformComponent defines an entity's position, rotation, and scale
 */
class TransformComponent extends BaseComponent {

	public static var TYPE_ID : String = Type.getClassName(TransformComponent);
	
	public var move(get, never) : MoveComponent;
	public var rotate(get, never) : RotateComponent;
	public var scale(get, never) : ScaleComponent;
	
	private var m_moveComponent : MoveComponent;
	private var m_rotateComponent : RotateComponent;
	private var m_scaleComponent : ScaleComponent;
	
	public function new() {
		super(TYPE_ID);
	}
	
	override public function initialize() {
		super.initialize();
		
		m_moveComponent = new MoveComponent();
		m_moveComponent.id = this.id;
		m_rotateComponent = new RotateComponent();
		m_rotateComponent.id = this.id;
		m_scaleComponent = new ScaleComponent();
		m_scaleComponent.id = this.id;
	}
	
	override public function serialize() : Xml {
		return null;
	}
	
	override public function deserialize(xml : Xml) {
		
	}
	
	function get_move() : MoveComponent {
		return m_moveComponent;
	}
	
	function get_rotate() : RotateComponent {
		return m_rotateComponent;
	}
	
	function get_scale() : ScaleComponent {
		return m_scaleComponent;
	}
}