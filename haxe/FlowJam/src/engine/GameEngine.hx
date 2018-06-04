package engine;

import assets.AssetInterface;
import display.GameObjectBatch;
import display.NineSliceBatch;
import engine.Time;
import engine.component.ComponentManager;
import engine.component.IComponentManager;
import engine.component.RenderableComponent;
import events.NavigationEvent;
import networking.GameFileHandler;
import openfl.Vector;
import scenes.BaseComponent;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;
import state.FlowJamGameState;
import state.IState;
import state.IStateMachine;
import state.StateMachine;
import state.TitleScreenState;

/**
 * ...
 * @author kristen autumn blackburn
 */
class GameEngine extends Sprite implements IGameEngine 
{
	private var m_stateMachine : IStateMachine;
	private var m_time : Time;
	private var m_componentManager : IComponentManager;
	private var m_savedData : Dynamic;
	private var m_fileHandler : GameFileHandler;

	public function new() 
	{
		super();
		
		// Initialize the fields
		m_stateMachine = new StateMachine();
		m_stateMachine.registerState(new FlowJamGameState(this));
		m_stateMachine.registerState(new TitleScreenState(this));
		
		m_time = new Time();
		
		m_componentManager = new ComponentManager();
		
		m_fileHandler = new GameFileHandler();
		
		prepareAssets();
		
		// Set up the listener for when this is added to the stage
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e : Dynamic) 
	{
		// TODO: there's really better ways to do batching than this
		var gameObjectBatch : GameObjectBatch = new GameObjectBatch();
		NineSliceBatch.gameObjectBatch = gameObjectBatch;
		
		// Look for current saved data; if doesnt exist, use a default saved data
		// this should search the local machine, probably using openfl's sharedobject
		// or if there's a starling equivalent
		// or a server with save data if we're feeling fancy
		// For now, it's just an empty anonymous structure
		m_savedData = {};
		
		// Set up the enter frame listener
		this.addEventListener(Event.ENTER_FRAME, update);
		
		// Set up the state change listener
		this.addEventListener(NavigationEvent.CHANGE_SCREEN, onStateChange);
		
		// Supposedly here we need to make some audio buttons? Though these should
		// only be displayed in certain states, not all of them, eg the loading state
		
		// If the test flag is set, just jump straight into a level
		// instead of having to click through the menu
		var startState : IState = 
		#if test
			m_stateMachine.getStateInstance(FlowJamGameState);
		#else
			m_stateMachine.getStateInstance(TitleScreenState);
		#end
		
		addChild(m_stateMachine.getSprite());
		m_stateMachine.changeState(startState);
	}
	
	// TODO: this is really just awful, but we don't have time to refactor this much
	private function prepareAssets() : Void
    {
        //load images if we haven't
        if (BaseComponent.loadingAnimationImages == null)
        {
            BaseComponent.loadingAnimationImages = new Vector<Texture>();
            for (i in 1...9)
            {
				BaseComponent.loadingAnimationImages.push(AssetInterface.getTexture("img/LoadingAnimation", "Loading"+i+".png"));
            }
            
            BaseComponent.waitAnimationImages = new Vector<Texture>();
            for (ii in 1...9)
            {
				BaseComponent.waitAnimationImages.push(AssetInterface.getTexture("img/LoadingAnimation", "FlowJamWait" + ii + ".png"));
            }
        }
		
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
	
	public function getSaveData() : Dynamic 
	{
		return m_savedData;
	}
	
	public function getFileHandler() : GameFileHandler
	{
		return m_fileHandler;
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
	
	public function debugTrace(msg : String)
	{
		#if debug
			trace(msg);
		#end
	}
}