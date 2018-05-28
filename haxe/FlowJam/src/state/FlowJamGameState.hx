package state;

import engine.IGameEngine;
import engine.scripting.selectors.AllSelector;
import networking.TutorialController;
import scenes.game.components.GameControlPanel;
import scenes.game.components.GridViewPanel;
import scenes.game.components.MiniMap;
import scenes.game.display.World;
import scripts.DialogScript;
import scripts.WorldMoveScript;

/**
 * This class is the main gameplay state of Flow Jam and is responsible
 * for setting up all the graphical display and the gameplay behavior
 * 
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
		var tutorialControl : TutorialController = TutorialController.getTutorialController();
		worldObj = tutorialControl.tutorialObj;
		layoutObj = tutorialControl.tutorialLayoutObj;
		assignmentsObj = tutorialControl.tutorialAssignmentsObj;
		
		m_gameEngine.addEventListener(ParseConstraintGraphState.WORLD_PARSED, onWorldParsed);
		var parseState : ParseConstraintGraphState = new ParseConstraintGraphState(m_gameEngine, worldObj);
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
		
		// After the world is created, we can initialize some UI widgets
		var gameControlPanel : GameControlPanel = new GameControlPanel();
		m_gameEngine.addUIComponent("gameControlPanel", gameControlPanel);
		addChild(gameControlPanel);
		
		var gridViewPanel : GridViewPanel = new GridViewPanel(m_activeWorld);
		m_gameEngine.addUIComponent("gridViewPanel", gridViewPanel);
		addChild(gridViewPanel);
		
		var minimap : MiniMap = new MiniMap();
		m_gameEngine.addUIComponent("minimap", minimap);
		addChild(minimap);
		
		// Now we can initialize the scripts; ideally, this would just be a class
		// that represents the usual level scripts, but we'll add them all individually
		// here for now
		// eg, to use:
		m_scriptRoot.addChild(new DialogScript(m_gameEngine, "dialogScript"));
		
		var worldScripts : AllSelector = new AllSelector("worldScripts");
		worldScripts.addChild(new WorldMoveScript(m_gameEngine, "worldMoveScript"));
		m_scriptRoot.addChild(worldScripts);
	}
}