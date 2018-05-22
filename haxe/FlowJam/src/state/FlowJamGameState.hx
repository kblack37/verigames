package state;

import engine.IGameEngine;
import networking.TutorialController;
import scenes.game.display.World;

/**
 * ...
 * @author ...
 */
class FlowJamGameState extends BaseState 
{
	private var m_activeWorld : World;

	public function new(gameEngine : IGameEngine) 
	{
		super(gameEngine);
	}
	
	private var worldObj : Dynamic;
	private var layoutObj : Dynamic;
	private var assignmentsObj : Dynamic;
	override public function enter(from : IState, params : Dynamic)
	{
		// Here is where, depending on params, we load the tutorial or
		// some game progress & a current level
		
		// For now, this means that we're starting at a tutorial, which
		// is hard-coded in
		if (!Reflect.hasField(params, "id")) 
		{
			var tutorialControl : TutorialController = TutorialController.getTutorialController();
			worldObj = tutorialControl.tutorialObj;
			layoutObj = tutorialControl.tutorialLayoutObj;
			assignmentsObj = tutorialControl.tutorialAssignmentsObj;
		} 
		else
		{
			
		}
		
		m_gameEngine.addEventListener(ParseConstraintGraphState.WORLD_PARSED, onWorldParsed);
		var parseState : ParseConstraintGraphState = new ParseConstraintGraphState(worldObj);
		parseState.stateLoad();
	}
	
	override public function exit(to : IState) : Dynamic
	{
		return null;
	}
	
	override public function update()
	{
		super.update();
	}
	
	private function onWorldParsed(e : Dynamic)
	{
		m_gameEngine.removeEventListener(ParseConstraintGraphState.WORLD_PARSED, onWorldParsed);
		
		var worldGraphDict : Dynamic = e.data;
		m_gameEngine.debugTrace("Creating world");
		m_activeWorld = new World(worldGraphDict, worldObj, layoutObj, assignmentsObj);
		addChild(m_activeWorld);
	}
}