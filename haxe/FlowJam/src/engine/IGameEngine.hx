package engine;

import engine.component.IComponentManager;
import state.IStateMachine;
import starling.events.Event;

/**
 * @author kristen autumn blackburn
 */
interface IGameEngine {
	public function getStateMachine() : IStateMachine;
	public function getTime() : Time;
	public function getComponentManager() : IComponentManager;
	public function update() : Void;
	
	public function addTagToEntity(entityId : String, tag : String) : Void;
	public function removeTagFromEntity(entityId : String, tag : String) : Void;
	public function getEntitiesWithTag(tag : String) : Array<String>;
	
	// The following functions are added to the interface in order to
	// use it as a central event source
	public function dispatchEvent(event : Event) : Bool;
	public function addEventListener(type : String, listener : Dynamic->Void, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void;
	public function removeEventListener(type : String, listener : Dynamic->Void, useCaputre : Bool = false) : Void;
}