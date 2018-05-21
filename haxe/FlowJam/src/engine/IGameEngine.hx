package engine;

import assets.AssetInterface;
import engine.component.IComponentManager;
import haxe.Constraints.Function;
import src.display.ISprite;
import state.IStateMachine;
import starling.events.Event;

/**
 * @author kristen autumn blackburn
 */
interface IGameEngine extends ISprite {
	public function getStateMachine() : IStateMachine;
	public function getTime() : Time;
	public function getComponentManager() : IComponentManager;
	public function getAssetInterface() : AssetInterface;
	
	// the save data should really be a defined class that gets 
	// deserialized and not just a JSON object but that takes time
	public function getSaveData() : Dynamic;
	
	/**
	 * Update is called every frame and calls update on the current state
	 * as well as Time
	 */
	public function update() : Void;
	
	public function addTagToEntity(entityId : String, tag : String) : Void;
	public function removeTagFromEntity(entityId : String, tag : String) : Void;
	public function getEntitiesWithTag(tag : String) : Array<String>;
	
	// The following functions are added to the interface in order to
	// use it as a central event source
	public function dispatchEvent(event : Event) : Void;
	public function addEventListener(type : String, listener : Function) : Void;
	public function removeEventListener(type : String, listener : Function) : Void;
}