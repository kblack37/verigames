package engine;

import assets.AssetInterface;
import engine.Time;
import engine.component.ComponentManager;
import engine.component.IComponentManager;
import engine.component.RenderableComponent;
import events.NavigationEvent;
import starling.display.DisplayObject;
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
		
		// Initialize the fields
		m_stateMachine = new StateMachine();
		//m_stateMachine.registerState(new SplashScreenState()); eg
		
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
	
	private function onStateChange(e : NavigationEvent) 
	{
		var sceneClass : Class<Dynamic> = e.scene;
		m_stateMachine.changeState(m_stateMachine.getStateInstance(sceneClass));
	}
	
	/** INTERFACE METHODS **/
	
	public function getSprite() : Sprite
	{
		return this;
	}
	
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
		m_time.update();
		m_stateMachine.getCurrentState().update();
	}
	
	public function addUIComponent(entityId : String, display : DisplayObject) : Void
	{
		var renderComponent : RenderableComponent =
			try cast(m_componentManager.addComponentToEntity(entityId, RenderableComponent.TYPE_ID), RenderableComponent) catch (e : Dynamic) null;
		
		renderComponent.view = display;
	}
	
	public function getUIComponent(entityId : String) : DisplayObject
	{
		var display : DisplayObject = null;
		var renderComponent : RenderableComponent =
			try cast(m_componentManager.getComponentByIdAndType(entityId, RenderableComponent.TYPE_ID), RenderableComponent) catch (e : Dynamic) null;
		
		if (renderComponent != null)
		{
			display = renderComponent.view;
		}
		
		return display;
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