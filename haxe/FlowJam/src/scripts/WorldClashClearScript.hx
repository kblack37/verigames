package scripts;

import engine.scripting.ScriptNode;
import engine.IGameEngine;
import networking.Achievements;
import scenes.game.display.Level;
import state.FlowJamGameState;
/**
 * ...
 * @author ...
 */
class WorldClashClearScript extends ScriptNode 
{
	private var active_level : Level;
	
	private var m_gameEngine : IGameEngine;
	
	public function new(gameEngine: IGameEngine, id:String=null) 
	{
		super(id);
		active_level = cast(gameEngine.getStateMachine().getCurrentState(),FlowJamGameState).getWorld().getActiveLevel();
		gameEngine.addEventListener(Achievements.CLASH_CLEARED_ID, checkClashClearedEvent);
		
		m_gameEngine = gameEngine;
	}
	
	private function checkClashClearedEvent() : Void
    {
        if (active_level != null && active_level.m_targetScore != 0)
        {
            Achievements.checkAchievements(Achievements.CLASH_CLEARED_ID, 0);
        }
    }
	
	override public function dispose(){
		super.dispose();
		m_gameEngine.removeEventListener(Achievements.CLASH_CLEARED_ID, checkClashClearedEvent);
	}
}