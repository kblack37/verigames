package engine;

import assets.AssetInterface;
import engine.Time;
import engine.component.ComponentManager;
import engine.component.IComponentManager;
import events.NavigationEvent;
import starling.display.Sprite;
import starling.events.Event;
import state.IStateMachine;
import state.StateMachine;

/**
 * ...
 * @author kristen autumn blackburn
 */
class GameEngine extends Sprite implements IGameEngine 
{
	private var m_stateMachine : IStateMachine;
	private var m_time : Time;
	private var m_componentManager : IComponentManager;
	private var m_assetInterface : AssetInterface;
	private var m_savedData : Dynamic;

	public function new() 
	{
		super();
		
		// Initialize the state machine and register all the states
		m_stateMachine = new StateMachine();
		//m_stateMachine.registerState(new SplashScreenState()); eg
		
		// Initialize the time class
		m_time = new Time();
		
		m_componentManager = new ComponentManager();
		
		m_assetInterface = new AssetInterface();
		
		// Set up the listener for when this is added to the stage
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e : Dynamic) 
	{
		// Look for current saved data; if doesnt exist, use a default saved data
		// this should search the local machine, probably using openfl's sharedobject
		// or if there's a starling equivalent
		// or a server with save data if we're feeling fancy
		
		// Set up the enter frame listener
		this.addEventListener(Event.ENTER_FRAME, update);
		
		// Set up the state change listener
		this.addEventListener(NavigationEvent.CHANGE_SCREEN, onStateChange);
	}
	
	private function onStateChange(e : Dynamic) 
	{
		
	}
	
	/** INTERFACE METHODS **/
	
	public function getStateMachine() : IStateMachine 
	{
		return m_stateMachine;
	}
	
	public function getTime() : Time 
	{
		return m_time;
	}
	
	public function getComponentManager() : IComponentManager 
	{
		return m_componentManager;
	}
	
	public function getAssetInterface() : AssetInterface 
	{
		return m_assetInterface;
	}
	
	public function getSaveData() : Dynamic 
	{
		return m_savedData;
	}
	
	public function update() : Void 
	{
		
	}
	
	public function addTagToEntity(entityId : String, tag : String) : Void 
	{
		
	}
	
	public function removeTagFromEntity(entityId : String, tag : String) : Void 
	{
		
	}
	
	public function getEntitiesWithTag(tag : String) : Array<String> 
	{
		return null;
	}
	
}