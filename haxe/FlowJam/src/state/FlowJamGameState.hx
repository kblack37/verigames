package state;

import engine.IGameEngine;
import engine.scripting.selectors.AllSelector;
import networking.TutorialController;
import scenes.game.components.GameControlPanel;
import scenes.game.components.GridViewPanel;
import scenes.game.components.MiniMap;
import scenes.game.display.WorldCopy;
import scripts.DialogScript;
import scripts.WorldCenterComponentScript;
import scripts.WorldClashClearScript;
import scripts.WorldErrorScript;
import scripts.WorldKeyUpScript;
import scripts.WorldMenuScript;
import scripts.WorldMiniMapScript;
import scripts.WorldMoveScript;
import scripts.WorldNavigationScript;
import scripts.WorldToolTipScript;
import scripts.WorldUndoScript;

/**
 * This class is the main gameplay state of Flow Jam and is responsible
 * for setting up all the graphical display and the gameplay behavior
 * 
 * @author ...
 */
class FlowJamGameState extends BaseState 
{
	private var m_activeWorld : WorldCopy;

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
	
	public function getWorld() : WorldCopy {
		return m_activeWorld;
	}
	
	private function onWorldParsed(e : Dynamic)
	{
		m_gameEngine.removeEventListener(ParseConstraintGraphState.WORLD_PARSED, onWorldParsed);
		
		// We have to create UI elements before World, confusingly enough
		var minimap : MiniMap = new MiniMap();
		m_gameEngine.addUIComponent("minimap", minimap);
		
		var gameControlPanel : GameControlPanel = new GameControlPanel();
		m_gameEngine.addUIComponent("gameControlPanel", gameControlPanel);
		
		var worldGraphDict : Dynamic = e.data;
		m_gameEngine.debugTrace("Creating world");
		m_activeWorld = new WorldCopy(m_gameEngine, worldGraphDict, worldObj, layoutObj, assignmentsObj);
		
		var gridViewPanel : GridViewPanel = new GridViewPanel(m_activeWorld);
		m_gameEngine.addUIComponent("gridViewPanel", gridViewPanel);
		
		addChild(m_activeWorld);
		addChild(gridViewPanel);
		addChild(gameControlPanel);
		addChild(minimap);
		
		// Now we can initialize the scripts; ideally, this would just be a class
		// that represents the usual level scripts, but we'll add them all individually
		// here for now
		// eg, to use:
		m_scriptRoot.addChild(new DialogScript(m_gameEngine, "dialogScript"));
		//m_scriptRoot.addChild(new ComponentSelectScript(m_gameEngine));
		//m_scriptRoot.addChild(new ErrorScript(m_gameEngine));
		//m_scriptRoot.addChild(new MoveScript(m_gameEngine));
		
		var worldScripts : AllSelector = new AllSelector("worldScripts");
		worldScripts.addChild(new WorldMoveScript(m_gameEngine, "worldMoveScript"));
		worldScripts.addChild(new WorldCenterComponentScript(m_gameEngine));
		worldScripts.addChild(new WorldClashClearScript(m_gameEngine));
		worldScripts.addChild(new WorldErrorScript(m_gameEngine));
		worldScripts.addChild(new WorldKeyUpScript(m_gameEngine));
		worldScripts.addChild(new WorldMenuScript(m_gameEngine));
		worldScripts.addChild(new WorldMiniMapScript(m_gameEngine));
		worldScripts.addChild(new WorldNavigationScript(m_gameEngine));
		worldScripts.addChild(new WorldToolTipScript(m_gameEngine));
		worldScripts.addChild(new WorldUndoScript(m_gameEngine));
		m_scriptRoot.addChild(worldScripts);
	}
}