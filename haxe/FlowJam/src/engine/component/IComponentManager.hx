package engine.component;

/**
 * @author kristen autumn blackburn
 */
interface IComponentManager {
	public function addComponentToEntity(entityId : String, componentType : String) : BaseComponent;
	public function removeComponentFromEntity(entityId : String, componentType : String) : Bool;
	public function entityHasComponent(entityId : String, componentType : String) : Bool;
	public function getComponentByIdAndType(entityId : String, componentType : String) : BaseComponent;
	public function getComponentsOfType(componentType : String) : Array<BaseComponent>;
	public function clear() : Void;
}