package engine.component;
import starling.display.DisplayObject;

/**
 * ...
 * @author kristen autumn blackburn
 */
class RenderableComponent extends BaseComponent {

	public static var TYPE_ID : String = Type.getClassName(RenderableComponent);
	
	/**
	 * The Starling DisplayObject that this component represents
	 */
	public var view(get, set) : DisplayObject;
	
	/**
	 * Whether the DisplayObject is visible
	 */
	public var visible(get, set) : Bool;
	
	private var m_view : DisplayObject;
	
	private function new() {
		super(TYPE_ID);
	}
	
	override public function initialize() {
		super.initialize();
		
		m_view = null;
	}
	
	function get_view() : DisplayObject {
		return m_view;
	}
	
	function set_view(value : DisplayObject) : DisplayObject {
		return m_view = value;
	}
	
	function get_visible() : Bool {
		return m_view.visible;
	}
	
	function set_visible(value : Bool) : Bool {
		return m_view.visible = value;
	}
}